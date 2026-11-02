<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Distributor;
use Illuminate\Http\Request;

class DistributorController extends Controller
{
    public function index(Request $request)
    {
        $query = Distributor::withCount('purchases');

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('nama', 'like', '%' . $request->search . '%')
                    ->orWhere('telepon', 'like', '%' . $request->search . '%');
            });
        }

        $distributor = $query->orderBy('nama')->paginate(15)->withQueryString();

        return view('admin.distributor.index', compact('distributor'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'telepon' => 'nullable|string|max:20',
            'alamat' => 'nullable|string',
        ]);

        $distributor = Distributor::create($validated);

        AuditLog::create([
            'user_id' => auth()->id(),
            'aktivitas' => 'Tambah Distributor',
            'module' => 'Distributor',
            'referensi_id' => $distributor->id,
            'keterangan' => 'Menambahkan distributor: ' . $distributor->nama,
        ]);

        return redirect()->route('admin.distributor.index')->with('success', 'Distributor berhasil ditambahkan.');
    }

    public function update(Request $request, Distributor $distributor)
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'telepon' => 'nullable|string|max:20',
            'alamat' => 'nullable|string',
        ]);

        $distributor->update($validated);

        AuditLog::create([
            'user_id' => auth()->id(),
            'aktivitas' => 'Edit Distributor',
            'module' => 'Distributor',
            'referensi_id' => $distributor->id,
            'keterangan' => 'Mengubah distributor: ' . $distributor->nama,
        ]);

        return redirect()->route('admin.distributor.index')->with('success', 'Distributor berhasil diupdate.');
    }
}
