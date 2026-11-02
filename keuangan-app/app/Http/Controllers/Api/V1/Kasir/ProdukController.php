<?php

namespace App\Http\Controllers\Api\V1\Kasir;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProdukController extends Controller
{
    /**
     * Daftar produk aktif untuk kasir memilih item transaksi (POS).
     * Hanya produk dengan status aktif dan stok tersedia, seperti form web.
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate(['search' => 'nullable|string']);

        $query = Product::with('category')
            ->where('status', 'aktif')
            ->where('stok', '>', 0)
            ->orderBy('nama');

        if ($request->filled('search')) {
            $query->where('nama', 'like', '%' . $request->search . '%');
        }

        return response()->json([
            'data' => $query->get(),
        ]);
    }
}
