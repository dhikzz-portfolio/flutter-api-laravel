<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Product;
use App\Models\StockAdjustment;
use App\Models\StockAdjustmentDetail;
use App\Models\StockMovement;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class KoreksiStokController extends Controller
{
    public function index(Request $request)
    {
        $query = StockAdjustment::with(['user', 'stockAdjustmentDetails.product']);

        if ($request->filled('date_from')) {
            $query->where('tanggal', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->where('tanggal', '<=', $request->date_to);
        }

        $koreksiStok = $query->latest('tanggal')->latest('id')->paginate(15)->withQueryString();

        return view('admin.koreksi-stok.index', compact('koreksiStok'));
    }

    public function create()
    {
        $products = Product::where('status', 'aktif')->orderBy('nama')->get();

        return view('admin.koreksi-stok.create', compact('products'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.stok_fisik' => 'required|integer|min:0',
            'items.*.alasan' => 'required|string',
        ]);

        return DB::transaction(function () use ($request) {
            $adjustment = StockAdjustment::create([
                'user_id' => auth()->id(),
                'tanggal' => now()->toDateString(),
            ]);

            foreach ($request->items as $item) {
                $product = Product::where('id', $item['product_id'])
                    ->lockForUpdate()
                    ->first();

                $stokSebelum = $product->stok;
                $stokFisik = $item['stok_fisik'];
                $selisih = $stokFisik - $stokSebelum;

                StockAdjustmentDetail::create([
                    'adjustment_id' => $adjustment->id,
                    'product_id' => $item['product_id'],
                    'stok_sebelum' => $stokSebelum,
                    'stok_fisik' => $stokFisik,
                    'selisih' => $selisih,
                    'alasan' => $item['alasan'],
                ]);

                // Update stok
                $product->update(['stok' => $stokFisik]);

                StockMovement::create([
                    'product_id' => $item['product_id'],
                    'user_id' => auth()->id(),
                    'jenis' => 'KOREKSI',
                    'referensi_type' => 'App\\Models\\StockAdjustment',
                    'referensi_id' => $adjustment->id,
                    'stok_sebelum' => $stokSebelum,
                    'jumlah' => $selisih,
                    'stok_sesudah' => $stokFisik,
                    'keterangan' => 'Koreksi stok: ' . $item['alasan'],
                    'tanggal' => now()->toDateString(),
                ]);
            }

            AuditLog::create([
                'user_id' => auth()->id(),
                'aktivitas' => 'Koreksi Stok',
                'module' => 'Koreksi Stok',
                'referensi_id' => $adjustment->id,
                'keterangan' => 'Koreksi stok dengan ' . count($request->items) . ' produk',
            ]);

            return redirect()->route('admin.koreksi-stok.index')->with('success', 'Koreksi stok berhasil dicatat.');
        });
    }
}
