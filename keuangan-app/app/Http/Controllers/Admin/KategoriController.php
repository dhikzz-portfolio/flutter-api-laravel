<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Category;
use Illuminate\Http\Request;

class KategoriController extends Controller
{
    public function index(Request $request)
    {
        $query = Category::withCount('products');

        if ($request->filled('search')) {
            $query->where('nama', 'like', '%' . $request->search . '%');
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $kategori = $query->orderBy('nama')->paginate(15)->withQueryString();

        return view('admin.kategori.index', compact('kategori'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255|unique:categories,nama',
        ]);

        $validated['status'] = 'aktif';

        $kategori = Category::create($validated);

        AuditLog::create([
            'user_id' => auth()->id(),
            'aktivitas' => 'Tambah Kategori',
            'module' => 'Kategori',
            'referensi_id' => $kategori->id,
            'keterangan' => 'Menambahkan kategori: ' . $kategori->nama,
        ]);

        return redirect()->route('admin.kategori.index')->with('success', 'Kategori berhasil ditambahkan.');
    }

    public function update(Request $request, Category $kategori)
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255|unique:categories,nama,' . $kategori->id,
            'status' => 'required|in:aktif,nonaktif',
        ]);

        $kategori->update($validated);

        AuditLog::create([
            'user_id' => auth()->id(),
            'aktivitas' => 'Edit Kategori',
            'module' => 'Kategori',
            'referensi_id' => $kategori->id,
            'keterangan' => 'Mengubah kategori: ' . $kategori->nama,
        ]);

        return redirect()->route('admin.kategori.index')->with('success', 'Kategori berhasil diupdate.');
    }
}
