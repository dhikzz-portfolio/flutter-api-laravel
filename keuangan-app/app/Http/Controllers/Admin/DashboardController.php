<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Purchase;
use App\Models\StockOut;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $today = now()->toDateString();

        // Pembelian hari ini
        $pembelianHariIni = Purchase::where('tanggal', $today)
            ->where('status', 'active')
            ->count();

        // Total barang masuk hari ini
        $barangMasuk = Purchase::where('tanggal', $today)
            ->where('status', 'active')
            ->with('purchaseDetails')
            ->get()
            ->sum(fn($p) => $p->purchaseDetails->sum('jumlah'));

        // Barang keluar hari ini
        $barangKeluar = StockOut::where('tanggal', $today)
            ->with('stockOutDetails')
            ->get()
            ->sum(fn($s) => $s->stockOutDetails->sum('jumlah'));

        // Produk dengan stok minimum
        $produkStokMinimum = Product::where('status', 'aktif')
            ->whereColumn('stok', '<=', 'stok_minimum')
            ->with('category')
            ->get();

        return view('admin.dashboard', compact('pembelianHariIni', 'barangMasuk', 'barangKeluar', 'produkStokMinimum'));
    }
}
