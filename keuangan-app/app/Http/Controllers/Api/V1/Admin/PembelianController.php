<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\Purchase;
use App\Services\PurchaseService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PembelianController extends Controller
{
    public function __construct(private PurchaseService $purchaseService)
    {
    }

    /**
     * Daftar pembelian (search: invoice / nama distributor, filter status & tanggal).
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'search' => 'nullable|string',
            'status' => 'nullable|string|in:active,dibatalkan',
            'date_from' => 'nullable|date',
            'date_to' => 'nullable|date',
        ]);

        $query = Purchase::with(['distributor', 'user']);

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('invoice', 'like', '%' . $request->search . '%')
                    ->orWhereHas('distributor', function ($q2) use ($request) {
                        $q2->where('nama', 'like', '%' . $request->search . '%');
                    });
            });
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

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
     * Membuat transaksi pembelian (HPP weighted average dihitung di server).
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'distributor_id' => 'required|exists:distributors,id',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.jumlah' => 'required|integer|min:1',
            'items.*.harga_beli' => 'required|numeric|min:0.01',
        ]);

        $purchase = $this->purchaseService->create($data, $request->user()->id);
        $purchase->load(['distributor', 'user', 'purchaseDetails.product']);

        return response()->json([
            'data' => $purchase,
            'message' => 'Pembelian berhasil disimpan.',
        ], 201);
    }

    /**
     * Membatalkan pembelian (stok & HPP dikembalikan oleh server bila aman).
     */
    public function batal(Request $request, Purchase $pembelian): JsonResponse
    {
        $this->purchaseService->cancel($pembelian, $request->user()->id);

        return response()->json(['message' => 'Pembelian berhasil dibatalkan.']);
    }
}
