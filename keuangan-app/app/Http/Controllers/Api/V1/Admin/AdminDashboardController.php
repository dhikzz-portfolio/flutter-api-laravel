<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Purchase;
use App\Models\StockOut;
use Illuminate\Http\JsonResponse;

class AdminDashboardController extends Controller
{
    public function index(): JsonResponse
    {
        $today = now()->toDateString();

        $pembelianHariIni = Purchase::where('tanggal', $today)
            ->where('status', 'active')
            ->count();

        $barangMasuk = Purchase::where('tanggal', $today)
            ->where('status', 'active')
            ->with('purchaseDetails')
            ->get()
            ->sum(fn ($p) => $p->purchaseDetails->sum('jumlah'));

        $barangKeluar = StockOut::where('tanggal', $today)
            ->with('stockOutDetails')
            ->get()
            ->sum(fn ($s) => $s->stockOutDetails->sum('jumlah'));

        $produkStokMinimum = Product::where('status', 'aktif')
            ->whereColumn('stok', '<=', 'stok_minimum')
            ->with('category')
            ->get();

        return response()->json([
            'data' => [
                'pembelian_hari_ini' => (int) $pembelianHariIni,
                'barang_masuk' => (int) $barangMasuk,
                'barang_keluar' => (int) $barangKeluar,
                'produk_stok_minimum' => $produkStokMinimum,
            ],
        ]);
    }
}
