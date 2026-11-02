<?php

namespace App\Services;

use App\Models\AuditLog;
use App\Models\Product;
use App\Models\Purchase;
use App\Models\PurchaseDetail;
use App\Models\StockMovement;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class PurchaseService
{
    /**
     * Membuat transaksi pembelian dengan HPP weighted average.
     * Digunakan oleh controller web dan API.
     *
     * @param  array{distributor_id:int, items:array<int, array{product_id:int, jumlah:int, harga_beli:float}>}  $data
     */
    public function create(array $data, int $userId): Purchase
    {
        return DB::transaction(function () use ($data, $userId) {
            $total = 0;
            $details = [];

            foreach ($data['items'] as $item) {
                $product = Product::where('id', $item['product_id'])
                    ->where('status', 'aktif')
                    ->lockForUpdate()
                    ->first();

                if (!$product) {
                    throw ValidationException::withMessages([
                        'items' => 'Produk tidak valid atau tidak aktif.',
                    ]);
                }

                $subtotal = $item['harga_beli'] * $item['jumlah'];
                $details[] = [
                    'product_id' => $product->id,
                    'harga_beli' => $item['harga_beli'],
                    'jumlah' => $item['jumlah'],
                    'subtotal' => $subtotal,
                    '_product' => $product,
                ];

                $total += $subtotal;
            }

            $invoice = 'INV-PUR-' . now()->format('YmdHis') . '-' . strtoupper(uniqid());

            $purchase = Purchase::create([
                'invoice' => $invoice,
                'distributor_id' => $data['distributor_id'],
                'user_id' => $userId,
                'tanggal' => now()->toDateString(),
                'total' => $total,
                'status' => 'active',
            ]);

            foreach ($details as $detail) {
                PurchaseDetail::create(array_merge(
                    collect($detail)->except(['_product'])->toArray(),
                    ['purchase_id' => $purchase->id]
                ));

                $product = $detail['_product'];
                $stokSebelum = $product->stok;
                $jumlahBaru = $detail['jumlah'];
                $hargaBeliBaru = $detail['harga_beli'];

                // === HPP Weighted Average ===
                $stokLama = $product->stok;
                $hppLama = $product->hpp_rata_rata;
                $nilaiStokLama = $stokLama * $hppLama;
                $nilaiPembelianBaru = $jumlahBaru * $hargaBeliBaru;
                $totalStok = $stokLama + $jumlahBaru;

                $hppBaru = $totalStok > 0
                    ? ($nilaiStokLama + $nilaiPembelianBaru) / $totalStok
                    : $hargaBeliBaru;

                $product->increment('stok', $jumlahBaru);
                $product->update(['hpp_rata_rata' => $hppBaru]);

                StockMovement::create([
                    'product_id' => $product->id,
                    'user_id' => $userId,
                    'jenis' => 'PEMBELIAN',
                    'referensi_type' => 'App\\Models\\Purchase',
                    'referensi_id' => $purchase->id,
                    'stok_sebelum' => $stokSebelum,
                    'jumlah' => $jumlahBaru,
                    'stok_sesudah' => $product->fresh()->stok,
                    'keterangan' => 'Pembelian invoice ' . $invoice . ' - HPP baru: Rp ' . number_format($hppBaru, 0, ',', '.'),
                    'tanggal' => now()->toDateString(),
                ]);
            }

            AuditLog::create([
                'user_id' => $userId,
                'aktivitas' => 'Transaksi Pembelian',
                'module' => 'Pembelian',
                'referensi_id' => $purchase->id,
                'keterangan' => "Pembelian {$invoice} - Total: Rp " . number_format($total, 0, ',', '.'),
            ]);

            return $purchase;
        });
    }

    /**
     * Membatalkan pembelian: mengurangi stok dan menghitung ulang HPP (reverse).
     * Melempar ValidationException jika pembatalan tidak aman (stok sudah terpakai).
     */
    public function cancel(Purchase $purchase, int $userId): void
    {
        if ($purchase->status !== 'active') {
            throw ValidationException::withMessages([
                'status' => 'Transaksi ini sudah dibatalkan.',
            ]);
        }

        DB::transaction(function () use ($purchase, $userId) {
            $purchase->load('purchaseDetails.product');

            foreach ($purchase->purchaseDetails as $detail) {
                $product = $detail->product;
                if ($product->stok < $detail->jumlah) {
                    throw ValidationException::withMessages([
                        'status' => "Pembatalan tidak aman. Stok {$product->nama} saat ini ({$product->stok}) kurang dari jumlah pembelian ({$detail->jumlah}). Beberapa stok sudah digunakan.",
                    ]);
                }
            }

            $purchase->update(['status' => 'dibatalkan']);

            foreach ($purchase->purchaseDetails as $detail) {
                $product = Product::find($detail->product_id);
                $stokSebelum = $product->stok;

                $product->decrement('stok', $detail->jumlah);

                // Recalculate HPP Weighted Average (reverse)
                $stokSesudah = $product->fresh()->stok;
                $hppBaru = $stokSesudah > 0
                    ? (($stokSesudah + $detail->jumlah) * $product->hpp_rata_rata - $detail->jumlah * $detail->harga_beli) / $stokSesudah
                    : 0;
                $hppBaru = max(0, $hppBaru);

                $product->update(['hpp_rata_rata' => $hppBaru]);

                StockMovement::create([
                    'product_id' => $detail->product_id,
                    'user_id' => $userId,
                    'jenis' => 'PEMBATALAN_PEMBELIAN',
                    'referensi_type' => 'App\\Models\\Purchase',
                    'referensi_id' => $purchase->id,
                    'stok_sebelum' => $stokSebelum,
                    'jumlah' => -$detail->jumlah,
                    'stok_sesudah' => $stokSesudah,
                    'keterangan' => 'Pembatalan pembelian invoice ' . $purchase->invoice,
                    'tanggal' => now()->toDateString(),
                ]);
            }

            AuditLog::create([
                'user_id' => $userId,
                'aktivitas' => 'Pembatalan Pembelian',
                'module' => 'Pembelian',
                'referensi_id' => $purchase->id,
                'keterangan' => 'Membatalkan pembelian invoice ' . $purchase->invoice,
            ]);
        });
    }
}
