<?php

namespace App\Http\Controllers\Owner;

use App\Http\Controllers\Controller;
use App\Models\Sale;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $year = $request->get('year', now()->year);
        $month = $request->get('month', now()->month);

        // Summary
        $totalPenjualan = Sale::where('status', 'active')
            ->whereYear('tanggal', $year)
            ->whereMonth('tanggal', $month)
            ->sum('total');

        $totalHPP = Sale::where('status', 'active')
            ->whereYear('tanggal', $year)
            ->whereMonth('tanggal', $month)
            ->with('saleDetails')
            ->get()
            ->sum(fn($s) => $s->saleDetails->sum('hpp_total'));

        $labaKotor = $totalPenjualan - $totalHPP;

        // Monthly chart data (12 months)
        $chartData = Sale::where('status', 'active')
            ->whereYear('tanggal', $year)
            ->select(
                DB::raw('MONTH(tanggal) as bulan'),
                DB::raw('SUM(total) as penjualan'),
                DB::raw('SUM(total) as total')
            )
            ->with('saleDetails')
            ->groupBy(DB::raw('MONTH(tanggal)'))
            ->get()
            ->map(function ($item) {
                $hpp = Sale::where('status', 'active')
                    ->whereMonth('tanggal', $item->bulan)
                    ->with('saleDetails')
                    ->get()
                    ->sum(fn($s) => $s->saleDetails->sum('hpp_total'));
                return [
                    'bulan' => $item->bulan,
                    'penjualan' => $item->penjualan,
                    'hpp' => $hpp,
                    'laba' => $item->penjualan - $hpp,
                ];
            });

        $months = collect(range(1, 12))->map(fn($m) => [
            'nama' => now()->month($m)->translatedFormat('M'),
            'penjualan' => $chartData->firstWhere('bulan', $m)['penjualan'] ?? 0,
            'hpp' => $chartData->firstWhere('bulan', $m)['hpp'] ?? 0,
            'laba' => $chartData->firstWhere('bulan', $m)['laba'] ?? 0,
        ]);

        return view('owner.dashboard', compact('totalPenjualan', 'totalHPP', 'labaKotor', 'months', 'year', 'month'));
    }
}
