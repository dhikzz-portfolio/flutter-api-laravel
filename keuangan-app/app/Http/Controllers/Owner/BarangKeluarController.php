<?php

namespace App\Http\Controllers\Owner;

use App\Http\Controllers\Controller;
use App\Models\StockOut;
use Illuminate\Http\Request;

class BarangKeluarController extends Controller
{
    public function index(Request $request)
    {
        $query = StockOut::with(['user', 'stockOutDetails.product']);

        if ($request->filled('date_from')) {
            $query->where('tanggal', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->where('tanggal', '<=', $request->date_to);
        }

        $barangKeluar = $query->latest('tanggal')->latest('id')->paginate(15)->withQueryString();

        return view('owner.barang-keluar.index', compact('barangKeluar'));
    }
}
