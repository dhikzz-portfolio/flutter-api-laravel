<?php

namespace App\Http\Controllers\Api\V1\Kasir;

use App\Http\Controllers\Controller;
use App\Models\Buyer;
use App\Models\Sale;
use App\Services\SaleService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PenjualanController extends Controller
{
    public function __construct(private SaleService $saleService)
    {
    }

    /**
     * Daftar penjualan (search: invoice / nama pembeli, filter tanggal).
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'search' => 'nullable|string',
            'date_from' => 'nullable|date',
            'date_to' => 'nullable|date',
        ]);

        $query = Sale::with(['buyer', 'user'])
            ->where('status', 'active');

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('invoice', 'like', '%' . $request->search . '%')
                    ->orWhereHas('buyer', function ($q2) use ($request) {
                        $q2->where('nama', 'like', '%' . $request->search . '%');
                    });
            });
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
     * Membuat transaksi penjualan (harga & stok divalidasi di server).
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'buyer_id' => 'required|exists:buyers,id',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.jumlah' => 'required|integer|min:1',
        ]);

        $sale = $this->saleService->create($data, $request->user()->id);
        $sale->load(['buyer', 'user', 'saleDetails.product']);

        return response()->json([
            'data' => $sale,
            'message' => 'Transaksi berhasil disimpan.',
        ], 201);
    }

    /**
     * Detail penjualan (nota).
     */
    public function show(Sale $sale): JsonResponse
    {
        $sale->load(['buyer', 'user', 'saleDetails.product']);

        return response()->json(['data' => $sale]);
    }

    /**
     * Membatalkan penjualan (stok dikembalikan oleh server).
     */
    public function batal(Request $request, Sale $sale): JsonResponse
    {
        $this->saleService->cancel($sale, $request->user()->id);

        return response()->json(['message' => 'Penjualan berhasil dibatalkan.']);
    }
}
