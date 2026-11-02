<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        // Permintaan API (JSON) mendapat respons 401/403, bukan redirect.
        $wantsJson = $request->is('api/*') || $request->expectsJson();

        if (!auth()->check()) {
            if ($wantsJson) {
                return response()->json(['message' => 'Unauthenticated.'], 401);
            }

            return redirect()->route('login');
        }

        if (!auth()->user()->isActive()) {
            auth()->logout();

            if ($wantsJson) {
                return response()->json(['message' => 'Akun Anda tidak aktif.'], 403);
            }

            return redirect()->route('login')->with('error', 'Akun Anda tidak aktif.');
        }

        if (!in_array(auth()->user()->role, $roles)) {
            if ($wantsJson) {
                return response()->json(['message' => 'Anda tidak memiliki akses ke data ini.'], 403);
            }

            abort(403, 'Anda tidak memiliki akses ke halaman ini.');
        }

        return $next($request);
    }
}
