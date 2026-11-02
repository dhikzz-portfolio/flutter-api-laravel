<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\StockAdjustment;
use App\Services\StockAdjustmentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class KoreksiStokController extends Controller
{
    public function __construct(private StockAdjustmentService $adjustmentService)
    {
    }

    /**
     * Daftar koreksi stok (filter tanggal).
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'date_from' => 'nullable|date',
            'date_to' => 'nullable|date',
        ]);

        $query = StockAdjustment::with(['user', 'stockAdjustmentDetails.product']);

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
     * Mencatat koreksi stok (stok_fisik vs stok sistem).
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.stok_fisik' => 'required|integer|min:0',
            'items.*.alasan' => 'required|string',
        ]);

        $adjustment = $this->adjustmentService->create($data, $request->user()->id);
        $adjustment->load(['user', 'stockAdjustmentDetails.product']);

        return response()->json([
            'data' => $adjustment,
            'message' => 'Koreksi stok berhasil dicatat.',
        ], 201);
    }
}
