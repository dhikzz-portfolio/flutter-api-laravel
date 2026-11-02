<?php

namespace App\Http\Controllers\Owner;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProdukController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::with('category');

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('nama', 'like', '%' . $request->search . '%')
                    ->orWhereHas('category', function ($cq) use ($request) {
                        $cq->where('nama', 'like', '%' . $request->search . '%');
                    });
            });
        }

        $produk = $query->orderBy('nama')->paginate(15)->withQueryString();

        return view('owner.produk.index', compact('produk'));
    }
}
