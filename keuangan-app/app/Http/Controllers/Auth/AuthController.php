<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function showLogin()
    {
        if (Auth::check()) {
            return $this->redirectByRole();
        }
        return view('auth.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        $user = \App\Models\User::where('username', $request->username)->first();

        if (!$user) {
            return back()->withErrors(['username' => 'Username tidak ditemukan.'])->onlyInput('username');
        }

        if ($user->status !== 'aktif') {
            return back()->withErrors(['username' => 'Akun Anda tidak aktif.'])->onlyInput('username');
        }

        if (!Auth::attempt($request->only('username', 'password'), $request->boolean('remember'))) {
            return back()->withErrors(['password' => 'Password salah.'])->onlyInput('username');
        }

        $request->session()->regenerate();

        // Audit log
        AuditLog::create([
            'user_id' => auth()->id(),
            'aktivitas' => 'Login',
            'module' => 'Auth',
            'keterangan' => 'Berhasil login',
        ]);

        return $this->redirectByRole();
    }

    public function logout(Request $request)
    {
        AuditLog::create([
            'user_id' => auth()->id(),
            'aktivitas' => 'Logout',
            'module' => 'Auth',
            'keterangan' => 'Berhasil logout',
        ]);

        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login');
    }

    private function redirectByRole()
    {
        $user = auth()->user();

        return match ($user->role) {
            'kasir' => redirect()->route('kasir.dashboard'),
            'admin' => redirect()->route('admin.dashboard'),
            'owner' => redirect()->route('owner.dashboard'),
            default => redirect()->route('login'),
        };
    }
}
