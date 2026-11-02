<?php

namespace App\Http\Controllers\Api\V1\Owner;

use App\Http\Controllers\Controller;
use App\Services\LaporanExportService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response as SymfonyResponse;

class LaporanController extends Controller
{
    public function __construct(private LaporanExportService $exportService)
    {
    }

    /**
     * Laporan laba/rugi per periode (tahun/bulan) + rekap bulanan.
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'year' => 'nullable|integer|min:2000|max:2100',
            'month' => 'nullable|integer|min:1|max:12',
        ]);

        $year = (int) $request->get('year', now()->year);
        $month = $request->filled('month') ? (int) $request->get('month') : null;

        $summary = $this->exportService->summary($year, $month);

        // Rekap bulanan untuk tahun berjalan
        $yearlySales = \App\Models\Sale::where('status', 'active')
            ->whereYear('tanggal', $year)
            ->with('saleDetails')
            ->get();

        $monthlyData = collect(range(1, 12))->map(function ($m) use ($yearlySales) {
            $rows = $yearlySales->filter(fn ($s) => (int) $s->tanggal->month === $m);
            $penjualan = (float) $rows->sum('total');
            $hpp = (float) $rows->sum(fn ($s) => $s->saleDetails->sum('hpp_total'));

            return [
                'bulan' => $m,
                'nama' => now()->month($m)->translatedFormat('F'),
                'penjualan' => $penjualan,
                'hpp' => $hpp,
                'laba' => $penjualan - $hpp,
            ];
        })->values();

        return response()->json([
            'data' => [
                'year' => $year,
                'month' => $month,
                'penjualan' => $summary['penjualan'],
                'total_penjualan' => $summary['total_penjualan'],
                'total_hpp' => $summary['total_hpp'],
                'laba_kotor' => $summary['laba_kotor'],
                'monthly_data' => $monthlyData,
            ],
        ]);
    }

    public function exportExcel(Request $request): SymfonyResponse
    {
        $request->validate([
            'year' => 'nullable|integer|min:2000|max:2100',
            'month' => 'nullable|integer|min:1|max:12',
        ]);

        return $this->exportService->exportExcel(
            $request->filled('year') ? (int) $request->get('year') : null,
            $request->filled('month') ? (int) $request->get('month') : null,
        );
    }

    public function exportPdf(Request $request): SymfonyResponse
    {
        $request->validate([
            'year' => 'nullable|integer|min:2000|max:2100',
            'month' => 'nullable|integer|min:1|max:12',
        ]);

        return $this->exportService->exportPdf(
            $request->filled('year') ? (int) $request->get('year') : null,
            $request->filled('month') ? (int) $request->get('month') : null,
        );
    }
}
