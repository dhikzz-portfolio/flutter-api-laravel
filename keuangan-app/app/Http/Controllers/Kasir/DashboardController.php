<?php

namespace App\Http\Controllers\Kasir;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Sale;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $today = now()->toDateString();

        // Penjualan hari ini
        $penjualanHariIni = Sale::where('tanggal', $today)
            ->where('status', 'active')
            ->count();

        // Total transaksi hari ini
        $totalTransaksi = Sale::where('tanggal', $today)
            ->where('status', 'active')
            ->sum('total');

        // Produk dengan stok minimum
        $stokMinimum = Product::where('status', 'aktif')
            ->whereColumn('stok', '<=', 'stok_minimum')
            ->count();

        return view('kasir.dashboard', compact('penjualanHariIni', 'totalTransaksi', 'stokMinimum'));
    }
}
