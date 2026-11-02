<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\StockMovement;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RiwayatStokController extends Controller
{
    /**
     * Riwayat stok (filter produk, jenis, tanggal). Diakses admin & owner.
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'product_id' => 'nullable|integer|exists:products,id',
            'jenis' => 'nullable|string|in:PEMBELIAN,PENJUALAN,PEMBATALAN_PEMBELIAN,PEMBATALAN_PENJUALAN,BARANG_KELUAR,KOREKSI',
            'date_from' => 'nullable|date',
            'date_to' => 'nullable|date',
        ]);

        $query = StockMovement::with(['product', 'user']);

        if ($request->filled('product_id')) {
            $query->where('product_id', $request->product_id);
        }

        if ($request->filled('jenis')) {
            $query->where('jenis', $request->jenis);
        }

        if ($request->filled('date_from')) {
            $query->where('tanggal', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->where('tanggal', '<=', $request->date_to);
        }

        $paginator = $query->latest('tanggal')->latest('id')
            ->paginate((int) $request->get('per_page', 20));

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
}
