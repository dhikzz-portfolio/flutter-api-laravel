<?php

namespace App\Http\Controllers\Owner;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function index(Request $request)
    {
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

        $users = $query->orderBy('nama')->paginate(15)->withQueryString();

        return view('owner.user.index', compact('users'));
    }

    public function store(Request $request)
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
            'user_id' => auth()->id(),
            'aktivitas' => 'Tambah User',
            'module' => 'User',
            'referensi_id' => $user->id,
            'keterangan' => 'Menambahkan user: ' . $user->nama . ' (' . $user->role . ')',
        ]);

        return redirect()->route('owner.user.index')->with('success', 'User berhasil ditambahkan.');
    }

    public function update(Request $request, User $user)
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
            'user_id' => auth()->id(),
            'aktivitas' => 'Edit User',
            'module' => 'User',
            'referensi_id' => $user->id,
            'keterangan' => 'Mengubah user: ' . $user->nama,
        ]);

        return redirect()->route('owner.user.index')->with('success', 'User berhasil diupdate.');
    }

    public function destroy(User $user)
    {
        if ($user->id === auth()->id()) {
            return back()->with('error', 'Tidak dapat menghapus akun sendiri.');
        }

        $nama = $user->nama;
        $user->delete();

        AuditLog::create([
            'user_id' => auth()->id(),
            'aktivitas' => 'Hapus User',
            'module' => 'User',
            'keterangan' => 'Menghapus user: ' . $nama,
        ]);

        return redirect()->route('owner.user.index')->with('success', 'User berhasil dihapus.');
    }
}
