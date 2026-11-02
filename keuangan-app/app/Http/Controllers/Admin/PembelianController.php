<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Distributor;
use App\Models\Product;
use App\Models\Purchase;
use App\Models\PurchaseDetail;
use App\Models\StockMovement;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PembelianController extends Controller
{
    public function index(Request $request)
    {
        $query = Purchase::with(['distributor', 'user']);

        if ($request->filled('search')) {
            $query->where('invoice', 'like', '%' . $request->search . '%')
                ->orWhereHas('distributor', function ($q) use ($request) {
                    $q->where('nama', 'like', '%' . $request->search . '%');
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

        $pembelian = $query->latest('tanggal')->latest('id')->paginate(15)->withQueryString();

        return view('admin.pembelian.index', compact('pembelian'));
    }

    public function create()
    {
        $distributors = Distributor::orderBy('nama')->get();
        $products = Product::where('status', 'aktif')->orderBy('nama')->get();

        return view('admin.pembelian.create', compact('distributors', 'products'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'distributor_id' => 'required|exists:distributors,id',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.jumlah' => 'required|integer|min:1',
            'items.*.harga_beli' => 'required|numeric|min:0.01',
        ]);

        return DB::transaction(function () use ($request) {
            $total = 0;
            $details = [];

            foreach ($request->items as $item) {
                $product = Product::where('id', $item['product_id'])
                    ->where('status', 'aktif')
                    ->lockForUpdate()
                    ->first();

                if (!$product) {
                    throw \Illuminate\Validation\ValidationException::withMessages([
                        'items' => 'Produk tidak valid atau tidak aktif.',
                    ]);
                }

                $subtotal = $item['harga_beli'] * $item['jumlah'];
                $details[] = [
                    'product_id' => $product->id,
                    'harga_beli' => $item['harga_beli'],
                    'jumlah' => $item['jumlah'],
                    'subtotal' => $subtotal,
                    '_product' => $product,
                ];

                $total += $subtotal;
            }

            // Generate unique invoice
            $invoice = 'INV-PUR-' . now()->format('YmdHis') . '-' . strtoupper(uniqid());

            // Create purchase
            $purchase = Purchase::create([
                'invoice' => $invoice,
                'distributor_id' => $request->distributor_id,
                'user_id' => auth()->id(),
                'tanggal' => now()->toDateString(),
                'total' => $total,
                'status' => 'active',
            ]);

            // Create purchase details, update stock, and recalculate HPP
            foreach ($details as $detail) {
                PurchaseDetail::create(array_merge(
                    collect($detail)->except(['_product'])->toArray(),
                    ['purchase_id' => $purchase->id]
                ));

                $product = $detail['_product'];
                $stokSebelum = $product->stok;
                $jumlahBaru = $detail['jumlah'];
                $hargaBeliBaru = $detail['harga_beli'];

                // === HPP Weighted Average ===
                $stokLama = $product->stok;
                $hppLama = $product->hpp_rata_rata;
                $nilaiStokLama = $stokLama * $hppLama;
                $nilaiPembelianBaru = $jumlahBaru * $hargaBeliBaru;
                $totalStok = $stokLama + $jumlahBaru;

                if ($totalStok > 0) {
                    $hppBaru = ($nilaiStokLama + $nilaiPembelianBaru) / $totalStok;
                } else {
                    $hppBaru = $hargaBeliBaru;
                }

                // Update product
                $product->increment('stok', $jumlahBaru);
                $product->update(['hpp_rata_rata' => $hppBaru]);

                // Stock movement
                StockMovement::create([
                    'product_id' => $product->id,
                    'user_id' => auth()->id(),
                    'jenis' => 'PEMBELIAN',
                    'referensi_type' => 'App\\Models\\Purchase',
                    'referensi_id' => $purchase->id,
                    'stok_sebelum' => $stokSebelum,
                    'jumlah' => $jumlahBaru,
                    'stok_sesudah' => $product->fresh()->stok,
                    'keterangan' => 'Pembelian invoice ' . $invoice . ' - HPP baru: Rp ' . number_format($hppBaru, 0, ',', '.'),
                    'tanggal' => now()->toDateString(),
                ]);
            }

            AuditLog::create([
                'user_id' => auth()->id(),
                'aktivitas' => 'Transaksi Pembelian',
                'module' => 'Pembelian',
                'referensi_id' => $purchase->id,
                'keterangan' => "Pembelian {$invoice} - Total: Rp " . number_format($total, 0, ',', '.'),
            ]);

            return redirect()->route('admin.pembelian.index')->with('success', 'Pembelian berhasil disimpan.');
        });
    }

    public function batal(Purchase $pembelian){

        if ($pembelian->status !== 'active') {
            return back()->with('error', 'Transaksi ini sudah dibatalkan.');
        }

        return DB::transaction(function () use ($pembelian) {
            $pembelian->load('purchaseDetails.product');

            // Check if reversal is safe
            foreach ($pembelian->purchaseDetails as $detail) {
                $product = $detail->product;
                if ($product->stok < $detail->jumlah) {
                    return back()->with('error', "Pembatalan tidak aman. Stok {$product->nama} saat ini ({$product->stok}) kurang dari jumlah pembelian ({$detail->jumlah}). Beberapa stok sudah digunakan.");
                }
            }
            $pembelian->update(['status' => 'dibatalkan']);

            foreach ($pembelian->purchaseDetails as $detail) {
                $product = Product::find($detail->product_id);
                $stokSebelum = $product->stok;

                // Decrease stock
                $product->decrement('stok', $detail->jumlah);

                // Recalculate HPP Weighted Average (reverse)
                $stokSesudah = $product->fresh()->stok;
                $hppBaru = $stokSesudah > 0
                    ? (($stokSesudah + $detail->jumlah) * $product->hpp_rata_rata - $detail->jumlah * $detail->harga_beli) / $stokSesudah
                    : 0;
                $hppBaru = max(0, $hppBaru);

                $product->update(['hpp_rata_rata' => $hppBaru]);

                StockMovement::create([
                    'product_id' => $detail->product_id,
                    'user_id' => auth()->id(),
                    'jenis' => 'PEMBATALAN_PEMBELIAN',
                    'referensi_type' => 'App\\Models\\Purchase',
                    'referensi_id' => $pembelian->id,
                    'stok_sebelum' => $stokSebelum,
                    'jumlah' => -$detail->jumlah,
                    'stok_sesudah' => $stokSesudah,
                    'keterangan' => 'Pembatalan pembelian invoice ' . $pembelian->invoice,
                    'tanggal' => now()->toDateString(),
                ]);
            }

            AuditLog::create([
                'user_id' => auth()->id(),
                'aktivitas' => 'Pembatalan Pembelian',
                'module' => 'Pembelian',
                'referensi_id' => $pembelian->id,
                'keterangan' => 'Membatalkan pembelian invoice ' . $pembelian->invoice,
            ]);

            return redirect()->route('admin.pembelian.index')->with('success', 'Pembelian berhasil dibatalkan.');
        });
    }
}
