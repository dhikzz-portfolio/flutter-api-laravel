<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Product;
use App\Models\StockMovement;
use App\Models\StockOut;
use App\Models\StockOutDetail;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BarangKeluarController extends Controller
{
    public function index(Request $request)
    {
        $query = StockOut::with(['user', 'stockOutDetails.product']);

        if ($request->filled('date_from')) {
            $query->where('tanggal', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->where('tanggal', '<=', $request->date_to);
        }

        $barangKeluar = $query->latest('tanggal')->latest('id')->paginate(15)->withQueryString();

        return view('admin.barang-keluar.index', compact('barangKeluar'));
    }

    public function create()
    {
        $products = Product::where('status', 'aktif')->where('stok', '>', 0)->orderBy('nama')->get();

        return view('admin.barang-keluar.create', compact('products'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'keterangan' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.jumlah' => 'required|integer|min:1',
            'items.*.jenis' => 'required|in:RUSAK,EXPIRED,DIBERIKAN,LAINNYA',
            'items.*.keterangan_item' => 'nullable|string',
        ]);

        return DB::transaction(function () use ($request) {
            // Validate stock
            foreach ($request->items as $item) {
                $product = Product::where('id', $item['product_id'])
                    ->where('status', 'aktif')
                    ->lockForUpdate()
                    ->first();

                if (!$product) {
                    throw \Illuminate\Validation\ValidationException::withMessages([
                        'items' => 'Produk tidak valid.',
                    ]);
                }

                if ($product->stok < $item['jumlah']) {
                    throw \Illuminate\Validation\ValidationException::withMessages([
                        'items' => "Stok {$product->nama} tidak mencukupi. Stok tersedia: {$product->stok}, jumlah diminta: {$item['jumlah']}.",
                    ]);
                }
            }

            $stockOut = StockOut::create([
                'user_id' => auth()->id(),
                'tanggal' => now()->toDateString(),
                'keterangan' => $request->keterangan,
            ]);

            foreach ($request->items as $item) {
                $product = Product::find($item['product_id']);
                $stokSebelum = $product->stok;

                StockOutDetail::create([
                    'stock_out_id' => $stockOut->id,
                    'product_id' => $item['product_id'],
                    'jenis' => $item['jenis'],
                    'jumlah' => $item['jumlah'],
                    'keterangan' => $item['keterangan_item'] ?? null,
                ]);

                $product->decrement('stok', $item['jumlah']);

                StockMovement::create([
                    'product_id' => $item['product_id'],
                    'user_id' => auth()->id(),
                    'jenis' => 'BARANG_KELUAR',
                    'referensi_type' => 'App\\Models\\StockOut',
                    'referensi_id' => $stockOut->id,
                    'stok_sebelum' => $stokSebelum,
                    'jumlah' => -$item['jumlah'],
                    'stok_sesudah' => $product->fresh()->stok,
                    'keterangan' => 'Barang keluar: ' . $item['jenis'],
                    'tanggal' => now()->toDateString(),
                ]);
            }

            AuditLog::create([
                'user_id' => auth()->id(),
                'aktivitas' => 'Barang Keluar',
                'module' => 'Barang Keluar',
                'referensi_id' => $stockOut->id,
                'keterangan' => 'Barang keluar dengan ' . count($request->items) . ' produk',
            ]);

            return redirect()->route('admin.barang-keluar.index')->with('success', 'Barang keluar berhasil dicatat.');
        });
    }
}
