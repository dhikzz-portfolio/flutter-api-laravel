<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Category;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class KategoriController extends Controller
{
    /**
     * Daftar kategori (search nama, filter status). Diakses admin & owner.
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'search' => 'nullable|string',
            'status' => 'nullable|string|in:aktif,nonaktif',
        ]);

        $query = Category::withCount('products');

        if ($request->filled('search')) {
            $query->where('nama', 'like', '%' . $request->search . '%');
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
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
            'nama' => 'required|string|max:255|unique:categories,nama',
        ]);

        $validated['status'] = 'aktif';

        $kategori = Category::create($validated);

        AuditLog::create([
            'user_id' => $request->user()->id,
            'aktivitas' => 'Tambah Kategori',
            'module' => 'Kategori',
            'referensi_id' => $kategori->id,
            'keterangan' => 'Menambahkan kategori: ' . $kategori->nama,
        ]);

        return response()->json([
            'data' => $kategori,
            'message' => 'Kategori berhasil ditambahkan.',
        ], 201);
    }

    public function update(Request $request, Category $kategori): JsonResponse
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255|unique:categories,nama,' . $kategori->id,
            'status' => 'required|in:aktif,nonaktif',
        ]);

        $kategori->update($validated);

        AuditLog::create([
            'user_id' => $request->user()->id,
            'aktivitas' => 'Edit Kategori',
            'module' => 'Kategori',
            'referensi_id' => $kategori->id,
            'keterangan' => 'Mengubah kategori: ' . $kategori->nama,
        ]);

        return response()->json([
            'data' => $kategori->fresh(),
            'message' => 'Kategori berhasil diupdate.',
        ]);
    }
}
