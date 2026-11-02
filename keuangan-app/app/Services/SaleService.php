<?php

namespace App\Services;

use App\Models\AuditLog;
use App\Models\Product;
use App\Models\Sale;
use App\Models\SaleDetail;
use App\Models\StockMovement;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class SaleService
{
    /**
     * Membuat transaksi penjualan (termasuk validasi stok, detail, pengurangan stok,
     * stock movement, dan audit log). Digunakan oleh controller web dan API.
     *
     * @param  array{buyer_id:int, items:array<int, array{product_id:int, jumlah:int}>}  $data
     */
    public function create(array $data, int $userId): Sale
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

                if ($product->stok < $item['jumlah']) {
                    throw ValidationException::withMessages([
                        'items' => "Stok {$product->nama} tidak mencukupi. Stok tersedia: {$product->stok}, jumlah diminta: {$item['jumlah']}.",
                    ]);
                }

                $subtotal = $product->harga_jual * $item['jumlah'];
                $hppTotal = $product->hpp_rata_rata * $item['jumlah'];

                $details[] = [
                    'product_id' => $product->id,
                    'harga_jual' => $product->harga_jual,
                    'jumlah' => $item['jumlah'],
                    'hpp_per_unit' => $product->hpp_rata_rata,
                    'hpp_total' => $hppTotal,
                    'subtotal' => $subtotal,
                ];

                $total += $subtotal;
            }

            $invoice = 'INV-SAL-' . now()->format('YmdHis') . '-' . strtoupper(uniqid());

            $sale = Sale::create([
                'invoice' => $invoice,
                'buyer_id' => $data['buyer_id'],
                'user_id' => $userId,
                'tanggal' => now()->toDateString(),
                'total' => $total,
                'status' => 'active',
            ]);

            foreach ($details as $detail) {
                SaleDetail::create(array_merge($detail, ['sale_id' => $sale->id]));

                $product = Product::find($detail['product_id']);
                $stokSebelum = $product->stok;
                $product->decrement('stok', $detail['jumlah']);

                StockMovement::create([
                    'product_id' => $detail['product_id'],
                    'user_id' => $userId,
                    'jenis' => 'PENJUALAN',
                    'referensi_type' => 'App\\Models\\Sale',
                    'referensi_id' => $sale->id,
                    'stok_sebelum' => $stokSebelum,
                    'jumlah' => -$detail['jumlah'],
                    'stok_sesudah' => $product->fresh()->stok,
                    'keterangan' => 'Penjualan invoice ' . $invoice,
                    'tanggal' => now()->toDateString(),
                ]);
            }

            AuditLog::create([
                'user_id' => $userId,
                'aktivitas' => 'Transaksi Penjualan',
                'module' => 'Penjualan',
                'referensi_id' => $sale->id,
                'keterangan' => "Penjualan {$invoice} - Total: Rp " . number_format($total, 0, ',', '.'),
            ]);

            return $sale;
        });
    }

    /**
     * Membatalkan penjualan dan mengembalikan stok.
     */
    public function cancel(Sale $sale, int $userId): void
    {
        if ($sale->status !== 'active') {
            throw ValidationException::withMessages([
                'status' => 'Transaksi ini sudah dibatalkan.',
            ]);
        }

        DB::transaction(function () use ($sale, $userId) {
            $sale->load('saleDetails');
            $sale->update(['status' => 'dibatalkan']);

            foreach ($sale->saleDetails as $detail) {
                $product = Product::find($detail->product_id);
                $stokSebelum = $product->stok;
                $product->increment('stok', $detail->jumlah);

                StockMovement::create([
                    'product_id' => $detail->product_id,
                    'user_id' => $userId,
                    'jenis' => 'PEMBATALAN_PENJUALAN',
                    'referensi_type' => 'App\\Models\\Sale',
                    'referensi_id' => $sale->id,
                    'stok_sebelum' => $stokSebelum,
                    'jumlah' => $detail->jumlah,
                    'stok_sesudah' => $product->fresh()->stok,
                    'keterangan' => 'Pembatalan penjualan invoice ' . $sale->invoice,
                    'tanggal' => now()->toDateString(),
                ]);
            }

            AuditLog::create([
                'user_id' => $userId,
                'aktivitas' => 'Pembatalan Penjualan',
                'module' => 'Penjualan',
                'referensi_id' => $sale->id,
                'keterangan' => 'Membatalkan penjualan invoice ' . $sale->invoice,
            ]);
        });
    }
}
