<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Category;
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

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        $produk = $query->orderBy('nama')->paginate(15)->withQueryString();
        $categories = Category::where('status', 'aktif')->orderBy('nama')->get();

        return view('admin.produk.index', compact('produk', 'categories'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'category_id' => 'required|exists:categories,id',
            'harga_jual' => 'required|numeric|min:0',
            'stok' => 'required|integer|min:0',
            'stok_minimum' => 'required|integer|min:0',
        ]);

        $validated['hpp_rata_rata'] = 0;
        $validated['status'] = 'aktif';

        $produk = Product::create($validated);

        AuditLog::create([
            'user_id' => auth()->id(),
            'aktivitas' => 'Tambah Produk',
            'module' => 'Produk',
            'referensi_id' => $produk->id,
            'keterangan' => 'Menambahkan produk: ' . $produk->nama,
        ]);

        return redirect()->route('admin.produk.index')->with('success', 'Produk berhasil ditambahkan.');
    }

    public function update(Request $request, Product $produk)
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'category_id' => 'required|exists:categories,id',
            'harga_jual' => 'required|numeric|min:0',
            'stok_minimum' => 'required|integer|min:0',
            'status' => 'required|in:aktif,nonaktif',
        ]);

        $produk->update($validated);

        AuditLog::create([
            'user_id' => auth()->id(),
            'aktivitas' => 'Edit Produk',
            'module' => 'Produk',
            'referensi_id' => $produk->id,
            'keterangan' => 'Mengubah produk: ' . $produk->nama,
        ]);

        return redirect()->route('admin.produk.index')->with('success', 'Produk berhasil diupdate.');
    }
}
