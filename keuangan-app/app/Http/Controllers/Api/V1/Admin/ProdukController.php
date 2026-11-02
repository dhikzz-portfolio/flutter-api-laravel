<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProdukController extends Controller
{
    /**
     * Daftar produk (search nama/kategori, filter status & category).
     * Diakses admin (CRUD) dan owner (read-only).
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'search' => 'nullable|string',
            'status' => 'nullable|string|in:aktif,nonaktif',
            'category_id' => 'nullable|integer|exists:categories,id',
        ]);

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

        $paginator = $query->orderBy('nama')->paginate((int) $request->get('per_page', 15));

        return response()->json([
            'data' => $paginator->items(),
            'meta' => [
                'current_page' => $paginator->currentPage(),
                'last_page' => $paginator->lastPage(),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
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
            'user_id' => $request->user()->id,
            'aktivitas' => 'Tambah Produk',
            'module' => 'Produk',
            'referensi_id' => $produk->id,
            'keterangan' => 'Menambahkan produk: ' . $produk->nama,
        ]);

        return response()->json([
            'data' => $produk->load('category'),
            'message' => 'Produk berhasil ditambahkan.',
        ], 201);
    }

    public function update(Request $request, Product $produk): JsonResponse
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
            'user_id' => $request->user()->id,
            'aktivitas' => 'Edit Produk',
            'module' => 'Produk',
            'referensi_id' => $produk->id,
            'keterangan' => 'Mengubah produk: ' . $produk->nama,
        ]);

        return response()->json([
            'data' => $produk->fresh()->load('category'),
            'message' => 'Produk berhasil diupdate.',
        ]);
    }
}
