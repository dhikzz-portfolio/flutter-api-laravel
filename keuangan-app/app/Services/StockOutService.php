<?php

namespace App\Services;

use App\Models\AuditLog;
use App\Models\Product;
use App\Models\StockOut;
use App\Models\StockOutDetail;
use App\Models\StockMovement;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class StockOutService
{
    /**
     * Mencatat barang keluar (RUSAK/EXPIRED/DIBERIKAN/LAINNYA) dengan validasi stok.
     * Digunakan oleh controller web dan API.
     *
     * @param  array{keterangan?:?string, items:array<int, array{product_id:int, jenis:string, jumlah:int, keterangan_item?:?string}>}  $data
     */
    public function create(array $data, int $userId): StockOut
    {
        return DB::transaction(function () use ($data, $userId) {
            foreach ($data['items'] as $item) {
                $product = Product::where('id', $item['product_id'])
                    ->where('status', 'aktif')
                    ->lockForUpdate()
                    ->first();

                if (!$product) {
                    throw ValidationException::withMessages([
                        'items' => 'Produk tidak valid.',
                    ]);
                }

                if ($product->stok < $item['jumlah']) {
                    throw ValidationException::withMessages([
                        'items' => "Stok {$product->nama} tidak mencukupi. Stok tersedia: {$product->stok}, jumlah diminta: {$item['jumlah']}.",
                    ]);
                }
            }

            $stockOut = StockOut::create([
                'user_id' => $userId,
                'tanggal' => now()->toDateString(),
                'keterangan' => $data['keterangan'] ?? null,
            ]);

            foreach ($data['items'] as $item) {
                $product = Product::find($item['product_id']);
                $stokSebelum = $product->stok;

                StockOutDetail::create([
                    'stock_out_id' => $stockOut->id,
                    'product_id' => $item['product_id'],
                    'jenis' => $item['jenis'],
                    'jumlah' => $item['jumlah'],
                    'keterangan' => $item['keterangan_item'] ?? null,
                ]);

                $product->decrement('stok', $item['jumlah']);

                StockMovement::create([
                    'product_id' => $item['product_id'],
                    'user_id' => $userId,
                    'jenis' => 'BARANG_KELUAR',
                    'referensi_type' => 'App\\Models\\StockOut',
                    'referensi_id' => $stockOut->id,
                    'stok_sebelum' => $stokSebelum,
                    'jumlah' => -$item['jumlah'],
                    'stok_sesudah' => $product->fresh()->stok,
                    'keterangan' => 'Barang keluar: ' . $item['jenis'],
                    'tanggal' => now()->toDateString(),
                ]);
            }

            AuditLog::create([
                'user_id' => $userId,
                'aktivitas' => 'Barang Keluar',
                'module' => 'Barang Keluar',
                'referensi_id' => $stockOut->id,
                'keterangan' => 'Barang keluar dengan ' . count($data['items']) . ' produk',
            ]);

            return $stockOut;
        });
    }
}
