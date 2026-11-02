<?php

namespace App\Http\Controllers\Kasir;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Buyer;
use App\Models\Product;
use App\Models\Sale;
use App\Services\SaleService;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class PenjualanController extends Controller
{    public function index(Request $request)
    {
        $query = Sale::with(['buyer', 'user'])->where('status', 'active');

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('invoice', 'like', '%' . $request->search . '%')
                    ->orWhereHas('buyer', function ($q) use ($request) {
                        $q->where('nama', 'like', '%' . $request->search . '%');
                    });
            });
        }

        if ($request->filled('date_from')) {
            $query->where('tanggal', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->where('tanggal', '<=', $request->date_to);
        }

        $penjualan = $query->latest('tanggal')->latest('id')->paginate(15)->withQueryString();

        return view('kasir.penjualan.index', compact('penjualan'));
    }

    public function create()
    {
        $buyers = Buyer::orderBy('nama')->get();
        $products = Product::where('status', 'aktif')->where('stok', '>', 0)->orderBy('nama')->get();

        return view('kasir.penjualan.create', compact('buyers', 'products'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'buyer_id' => 'required|exists:buyers,id',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.jumlah' => 'required|integer|min:1',
        ]);

        try {
            $sale = $this->saleService->create($data, auth()->id());
        } catch (ValidationException $e) {
            return back()->withInput()->withErrors($e->errors());
        }

        return redirect()->route('kasir.penjualan.nota', $sale)->with('success', 'Transaksi berhasil disimpan.');
    }

    public function nota(Sale $sale)
    {
        $sale->load(['buyer', 'user', 'saleDetails.product']);

        return view('kasir.penjualan.nota', compact('sale'));
    }

    public function batal(Sale $sale)
    {
        if ($sale->status !== 'active') {
            return back()->with('error', 'Transaksi ini sudah dibatalkan.');
        }

        return DB::transaction(function () use ($sale) {
            $sale->update(['status' => 'dibatalkan']);

            // Return stock
            foreach ($sale->saleDetails as $detail) {
                $product = Product::find($detail->product_id);
                $stokSebelum = $product->stok;
                $product->increment('stok', $detail->jumlah);

                StockMovement::create([
                    'product_id' => $detail->product_id,
                    'user_id' => auth()->id(),
                    'jenis' => 'PEMBATALAN_PENJUALAN',
                    'referensi_type' => 'App\\Models\\Sale',
                    'referensi_id' => $sale->id,
                    'stok_sebelum' => $stokSebelum,
                    'jumlah' => $detail->jumlah,
                    'stok_sesudah' => $product->fresh()->stok,
                    'keterangan' => 'Pembatalan penjualan invoice ' . $sale->invoice,
                    'tanggal' => now()->toDateString(),
                ]);
            }

            AuditLog::create([
                'user_id' => auth()->id(),
                'aktivitas' => 'Pembatalan Penjualan',
                'module' => 'Penjualan',
                'referensi_id' => $sale->id,
                'keterangan' => 'Membatalkan penjualan invoice ' . $sale->invoice,
            ]);

            return redirect()->route('kasir.penjualan.index')->with('success', 'Penjualan berhasil dibatalkan.');
        });
    }
}
