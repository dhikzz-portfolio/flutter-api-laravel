<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class ApiAuthController extends Controller
{
    /**
     * Login menggunakan username & password, mengeluarkan Bearer token (Sanctum).
     */
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        $user = User::where('username', $request->username)->first();

        if (!$user || $user->status !== 'aktif') {
            throw ValidationException::withMessages([
                'username' => !$user ? 'Username tidak ditemukan.' : 'Akun Anda tidak aktif.',
            ]);
        }

        if (!Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'password' => 'Password salah.',
            ]);
        }

        $token = $user->createToken('mobile-app')->plainTextToken;

        AuditLog::create([
            'user_id' => $user->id,
            'aktivitas' => 'Login',
            'module' => 'Auth',
            'keterangan' => 'Berhasil login dari aplikasi mobile',
        ]);

        return response()->json([
            'data' => [
                'token' => $token,
                'token_type' => 'Bearer',
                'user' => $user->only(['id', 'nama', 'username', 'role', 'status']),
            ],
            'message' => 'Login berhasil.',
        ]);
    }

    /**
     * Logout: mencabut token yang sedang digunakan.
     */
    public function logout(Request $request): JsonResponse
    {
        AuditLog::create([
            'user_id' => $request->user()->id,
            'aktivitas' => 'Logout',
            'module' => 'Auth',
            'keterangan' => 'Berhasil logout dari aplikasi mobile',
        ]);

        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logout berhasil.']);
    }

    /**
     * Mengambil profil user yang sedang login.
     */
    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'data' => $request->user()->only(['id', 'nama', 'username', 'role', 'status']),
        ]);
    }
}
