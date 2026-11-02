<?php

namespace App\Http\Controllers\Kasir;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Buyer;
use Illuminate\Http\Request;

class PembeliController extends Controller
{
    public function index(Request $request)
    {
        $query = Buyer::query();

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('nama', 'like', '%' . $request->search . '%')
                    ->orWhere('telepon', 'like', '%' . $request->search . '%');
            });
        }

        $pembeli = $query->latest()->paginate(15)->withQueryString();

        return view('kasir.pembeli.index', compact('pembeli'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'telepon' => 'nullable|string|max:20',
            'alamat' => 'nullable|string',
        ]);

        $buyer = Buyer::create($validated);

        AuditLog::create([
            'user_id' => auth()->id(),
            'aktivitas' => 'Tambah Pembeli',
            'module' => 'Pembeli',
            'referensi_id' => $buyer->id,
            'keterangan' => 'Menambahkan pembeli: ' . $buyer->nama,
        ]);

        return redirect()->route('kasir.pembeli.index')->with('success', 'Pembeli berhasil ditambahkan.');
    }

    public function update(Request $request, Buyer $pembeli)
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'telepon' => 'nullable|string|max:20',
            'alamat' => 'nullable|string',
        ]);

        $pembeli->update($validated);

        AuditLog::create([
            'user_id' => auth()->id(),
            'aktivitas' => 'Edit Pembeli',
            'module' => 'Pembeli',
            'referensi_id' => $pembeli->id,
            'keterangan' => 'Mengubah pembeli: ' . $pembeli->nama,
        ]);

        return redirect()->route('kasir.pembeli.index')->with('success', 'Pembeli berhasil diupdate.');
    }
}
