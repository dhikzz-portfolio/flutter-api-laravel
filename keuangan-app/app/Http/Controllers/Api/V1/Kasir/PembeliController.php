<?php

namespace App\Http\Controllers\Api\V1\Kasir;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Buyer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PembeliController extends Controller
{
    /**
     * Daftar pembeli (search: nama / telepon).
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate(['search' => 'nullable|string']);

        $query = Buyer::query();

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('nama', 'like', '%' . $request->search . '%')
                    ->orWhere('telepon', 'like', '%' . $request->search . '%');
            });
        }

        $paginator = $query->latest()->paginate((int) $request->get('per_page', 15));

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

    /**
     * Menambah pembeli.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'telepon' => 'nullable|string|max:20',
            'alamat' => 'nullable|string',
        ]);

        $buyer = Buyer::create($validated);

        AuditLog::create([
            'user_id' => $request->user()->id,
            'aktivitas' => 'Tambah Pembeli',
            'module' => 'Pembeli',
            'referensi_id' => $buyer->id,
            'keterangan' => 'Menambahkan pembeli: ' . $buyer->nama,
        ]);

        return response()->json([
            'data' => $buyer,
            'message' => 'Pembeli berhasil ditambahkan.',
        ], 201);
    }

    /**
     * Mengubah pembeli.
     */
    public function update(Request $request, Buyer $pembeli): JsonResponse
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'telepon' => 'nullable|string|max:20',
            'alamat' => 'nullable|string',
        ]);

        $pembeli->update($validated);

        AuditLog::create([
            'user_id' => $request->user()->id,
            'aktivitas' => 'Edit Pembeli',
            'module' => 'Pembeli',
            'referensi_id' => $pembeli->id,
            'keterangan' => 'Mengubah pembeli: ' . $pembeli->nama,
        ]);

        return response()->json([
            'data' => $pembeli->fresh(),
            'message' => 'Pembeli berhasil diupdate.',
        ]);
    }
}
