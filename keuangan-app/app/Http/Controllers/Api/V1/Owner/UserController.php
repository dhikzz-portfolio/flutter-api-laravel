<?php

namespace App\Http\Controllers\Api\V1\Owner;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    /**
     * Daftar user (search nama/username, filter role). Diakses owner.
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'search' => 'nullable|string',
            'role' => 'nullable|string|in:kasir,admin,owner',
        ]);

        $query = User::query();

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('nama', 'like', '%' . $request->search . '%')
                    ->orWhere('username', 'like', '%' . $request->search . '%');
            });
        }

        if ($request->filled('role')) {
            $query->where('role', $request->role);
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
            'username' => 'required|string|max:255|unique:users,username',
            'password' => 'required|string|min:6',
            'role' => 'required|in:kasir,admin,owner',
            'status' => 'required|in:aktif,nonaktif',
        ]);

        $validated['password'] = Hash::make($validated['password']);

        $user = User::create($validated);

        AuditLog::create([
            'user_id' => $request->user()->id,
            'aktivitas' => 'Tambah User',
            'module' => 'User',
            'referensi_id' => $user->id,
            'keterangan' => 'Menambahkan user: ' . $user->nama . ' (' . $user->role . ')',
        ]);

        return response()->json([
            'data' => $user,
            'message' => 'User berhasil ditambahkan.',
        ], 201);
    }

    public function update(Request $request, User $user): JsonResponse
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'username' => 'required|string|max:255|unique:users,username,' . $user->id,
            'role' => 'required|in:kasir,admin,owner',
            'status' => 'required|in:aktif,nonaktif',
            'password' => 'nullable|string|min:6',
        ]);

        if (!empty($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        } else {
            unset($validated['password']);
        }

        $user->update($validated);

        AuditLog::create([
            'user_id' => $request->user()->id,
            'aktivitas' => 'Edit User',
            'module' => 'User',
            'referensi_id' => $user->id,
            'keterangan' => 'Mengubah user: ' . $user->nama,
        ]);

        return response()->json([
            'data' => $user->fresh(),
            'message' => 'User berhasil diupdate.',
        ]);
    }

    public function destroy(Request $request, User $user): JsonResponse
    {
        if ($user->id === $request->user()->id) {
            return response()->json([
                'message' => 'Tidak dapat menghapus akun sendiri.',
            ], 422);
        }

        $nama = $user->nama;
        $user->delete();

        AuditLog::create([
            'user_id' => $request->user()->id,
            'aktivitas' => 'Hapus User',
            'module' => 'User',
            'referensi_id' => $user->id,
            'keterangan' => 'Menghapus user: ' . $nama,
        ]);

        return response()->json(['message' => 'User berhasil dihapus.']);
    }
}
