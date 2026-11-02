<?php

namespace App\Http\Controllers\Api\V1\Kasir;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Sale;
use Illuminate\Http\JsonResponse;

class KasirDashboardController extends Controller
{
    public function index(): JsonResponse
    {
        $today = now()->toDateString();

        $penjualanHariIni = Sale::where('tanggal', $today)
            ->where('status', 'active')
            ->count();

        $totalTransaksi = Sale::where('tanggal', $today)
            ->where('status', 'active')
            ->sum('total');

        $stokMinimum = Product::where('status', 'aktif')
            ->whereColumn('stok', '<=', 'stok_minimum')
            ->count();

        return response()->json([
            'data' => [
                'penjualan_hari_ini' => (int) $penjualanHariIni,
                'total_transaksi' => (float) $totalTransaksi,
                'stok_minimum' => (int) $stokMinimum,
            ],
        ]);
    }
}
