<?php

namespace App\Http\Controllers\Api\V1\Owner;

use App\Http\Controllers\Controller;
use App\Models\Sale;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OwnerDashboardController extends Controller
{
    /**
     * Dashboard owner: ringkasan bulan terpilih + data grafik 12 bulan.
     * Grupasi dilakukan di PHP agar tidak terikat dialect SQL tertentu.
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'year' => 'nullable|integer|min:2000|max:2100',
            'month' => 'nullable|integer|min:1|max:12',
        ]);

        $year = (int) $request->get('year', now()->year);
        $month = (int) $request->get('month', now()->month);

        $sales = Sale::where('status', 'active')
            ->whereYear('tanggal', $year)
            ->with('saleDetails')
            ->get();

        // Ringkasan bulan terpilih
        $salesBulan = $sales->filter(fn ($s) => (int) $s->tanggal->month === $month);
        $totalPenjualan = (float) $salesBulan->sum('total');
        $totalHpp = (float) $salesBulan->sum(fn ($s) => $s->saleDetails->sum('hpp_total'));
        $labaKotor = $totalPenjualan - $totalHpp;

        // Data grafik 12 bulan
        $months = collect(range(1, 12))->map(function ($m) use ($sales) {
            $rows = $sales->filter(fn ($s) => (int) $s->tanggal->month === $m);
            $penjualan = (float) $rows->sum('total');
            $hpp = (float) $rows->sum(fn ($s) => $s->saleDetails->sum('hpp_total'));

            return [
                'bulan' => $m,
                'nama' => now()->month($m)->translatedFormat('M'),
                'penjualan' => $penjualan,
                'hpp' => $hpp,
                'laba' => $penjualan - $hpp,
            ];
        });

        return response()->json([
            'data' => [
                'year' => $year,
                'month' => $month,
                'total_penjualan' => $totalPenjualan,
                'total_hpp' => $totalHpp,
                'laba_kotor' => $labaKotor,
                'months' => $months->values(),
            ],
        ]);
    }
}
