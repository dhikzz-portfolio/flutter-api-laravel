<?php

namespace App\Services;

use App\Models\AuditLog;
use App\Models\Product;
use App\Models\StockAdjustment;
use App\Models\StockAdjustmentDetail;
use App\Models\StockMovement;
use Illuminate\Support\Facades\DB;

class StockAdjustmentService
{
    /**
     * Mencatat koreksi stok (stok fisik vs stok sistem).
     * Digunakan oleh controller web dan API.
     *
     * @param  array{items:array<int, array{product_id:int, stok_fisik:int, alasan:string}>}  $data
     */
    public function create(array $data, int $userId): StockAdjustment
    {
        return DB::transaction(function () use ($data, $userId) {
            $adjustment = StockAdjustment::create([
                'user_id' => $userId,
                'tanggal' => now()->toDateString(),
            ]);

            foreach ($data['items'] as $item) {
                $product = Product::where('id', $item['product_id'])
                    ->lockForUpdate()
                    ->first();

                $stokSebelum = $product->stok;
                $stokFisik = $item['stok_fisik'];
                $selisih = $stokFisik - $stokSebelum;

                StockAdjustmentDetail::create([
                    'adjustment_id' => $adjustment->id,
                    'product_id' => $item['product_id'],
                    'stok_sebelum' => $stokSebelum,
                    'stok_fisik' => $stokFisik,
                    'selisih' => $selisih,
                    'alasan' => $item['alasan'],
                ]);

                $product->update(['stok' => $stokFisik]);

                StockMovement::create([
                    'product_id' => $item['product_id'],
                    'user_id' => $userId,
                    'jenis' => 'KOREKSI',
                    'referensi_type' => 'App\\Models\\StockAdjustment',
                    'referensi_id' => $adjustment->id,
                    'stok_sebelum' => $stokSebelum,
                    'jumlah' => $selisih,
                    'stok_sesudah' => $stokFisik,
                    'keterangan' => 'Koreksi stok: ' . $item['alasan'],
                    'tanggal' => now()->toDateString(),
                ]);
            }

            AuditLog::create([
                'user_id' => $userId,
                'aktivitas' => 'Koreksi Stok',
                'module' => 'Koreksi Stok',
                'referensi_id' => $adjustment->id,
                'keterangan' => 'Koreksi stok dengan ' . count($data['items']) . ' produk',
            ]);

            return $adjustment;
        });
    }
}
