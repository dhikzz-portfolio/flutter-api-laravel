<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Services\StockOutService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BarangKeluarController extends Controller
{
    public function __construct(private StockOutService $stockOutService)
    {
    }

    /**
     * Daftar barang keluar (filter tanggal). Diakses admin & owner.
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'date_from' => 'nullable|date',
            'date_to' => 'nullable|date',
        ]);

        $query = \App\Models\StockOut::with(['user', 'stockOutDetails.product']);

        if ($request->filled('date_from')) {
            $query->where('tanggal', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->where('tanggal', '<=', $request->date_to);
        }

        $paginator = $query->latest('tanggal')->latest('id')
            ->paginate((int) $request->get('per_page', 15));

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
     * Mencatat barang keluar (validasi stok di server).
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'keterangan' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.jumlah' => 'required|integer|min:1',
            'items.*.jenis' => 'required|in:RUSAK,EXPIRED,DIBERIKAN,LAINNYA',
            'items.*.keterangan_item' => 'nullable|string',
        ]);

        $stockOut = $this->stockOutService->create($data, $request->user()->id);
        $stockOut->load(['user', 'stockOutDetails.product']);

        return response()->json([
            'data' => $stockOut,
            'message' => 'Barang keluar berhasil dicatat.',
        ], 201);
    }
}
