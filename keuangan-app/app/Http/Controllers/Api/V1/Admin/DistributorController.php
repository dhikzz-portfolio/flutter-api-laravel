<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Distributor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DistributorController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $request->validate(['search' => 'nullable|string']);

        $query = Distributor::withCount('purchases');

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('nama', 'like', '%' . $request->search . '%')
                    ->orWhere('telepon', 'like', '%' . $request->search . '%');
            });
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
            'telepon' => 'nullable|string|max:20',
            'alamat' => 'nullable|string',
        ]);

        $distributor = Distributor::create($validated);

        AuditLog::create([
            'user_id' => $request->user()->id,
            'aktivitas' => 'Tambah Distributor',
            'module' => 'Distributor',
            'referensi_id' => $distributor->id,
            'keterangan' => 'Menambahkan distributor: ' . $distributor->nama,
        ]);

        return response()->json([
            'data' => $distributor,
            'message' => 'Distributor berhasil ditambahkan.',
        ], 201);
    }

    public function update(Request $request, Distributor $distributor): JsonResponse
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'telepon' => 'nullable|string|max:20',
            'alamat' => 'nullable|string',
        ]);

        $distributor->update($validated);

        AuditLog::create([
            'user_id' => $request->user()->id,
            'aktivitas' => 'Edit Distributor',
            'module' => 'Distributor',
            'referensi_id' => $distributor->id,
            'keterangan' => 'Mengubah distributor: ' . $distributor->nama,
        ]);

        return response()->json([
            'data' => $distributor->fresh(),
            'message' => 'Distributor berhasil diupdate.',
        ]);
    }
}
