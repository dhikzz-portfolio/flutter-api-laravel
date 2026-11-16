<?php

namespace App\Http\Controllers\Owner;

use App\Http\Controllers\Controller;
use App\Models\Sale;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

class LaporanController extends Controller
{
    public function index(Request $request)
    {
        $year = $request->get('year', now()->year);
        $month = $request->get('month');

        $query = Sale::where('status', 'active')
            ->with(['buyer', 'saleDetails.product']);

        if ($month) {
            $query->whereMonth('tanggal', $month);
        }
        $query->whereYear('tanggal', $year);

        $penjualan = $query->latest('tanggal')->get();

        $totalPenjualan = $penjualan->sum('total');
        $totalHPP = $penjualan->sum(fn ($s) => $s->saleDetails->sum('hpp_total'));
        $labaKotor = $totalPenjualan - $totalHPP;

        // Monthly breakdown
        $monthlyData = Sale::where('status', 'active')
            ->whereYear('tanggal', $year)
            ->select(
                DB::raw('MONTH(tanggal) as bulan'),
                DB::raw('SUM(total) as total_penjualan')
            )
            ->with('saleDetails')
            ->groupBy(DB::raw('MONTH(tanggal)'))
            ->get()
            ->map(function ($item) {
                $hpp = Sale::where('status', 'active')
                    ->whereYear('tanggal', now()->year)
                    ->whereMonth('tanggal', $item->bulan)
                    ->with('saleDetails')
                    ->get()
                    ->sum(fn ($s) => $s->saleDetails->sum('hpp_total'));

                return [
                    'bulan' => now()->month($item->bulan)->translatedFormat('F'),
                    'penjualan' => $item->total_penjualan,
                    'hpp' => $hpp,
                    'laba' => $item->total_penjualan - $hpp,
                ];
            });

        return view('owner.laporan.index', compact(
            'penjualan', 'totalPenjualan', 'totalHPP', 'labaKotor',
            'year', 'month', 'monthlyData'
        ));
    }

    public function exportExcel(Request $request)
    {
        $year = $request->get('year', now()->year);
        $month = $request->get('month');

        $query = Sale::where('status', 'active')
            ->with(['buyer', 'saleDetails.product']);

        if ($month) {
            $query->whereMonth('tanggal', $month);
        }
        $query->whereYear('tanggal', $year);

        $penjualan = $query->latest('tanggal')->get();

        $spreadsheet = new Spreadsheet;
        $sheet = $spreadsheet->getActiveSheet();

        // Header
        $sheet->setCellValue('A1', 'Laporan Laba/Rugi');
        $sheet->setCellValue('A2', 'Periode: '.($month ? now()->month($month)->translatedFormat('F ') : '').$year);
        $sheet->mergeCells('A1:D1');
        $sheet->mergeCells('A2:D2');

        // Column headers
        $headers = ['Tanggal', 'Invoice', 'Pembeli', 'Total Penjualan', 'HPP', 'Laba Kotor'];
        foreach ($headers as $col => $header) {
            $sheet->setCellValue(chr(65 + $col).'4', $header);
        }

        // Data
        $row = 5;
        foreach ($penjualan as $sale) {
            $hpp = $sale->saleDetails->sum('hpp_total');
            $sheet->setCellValue('A'.$row, $sale->tanggal->format('d/m/Y'));
            $sheet->setCellValue('B'.$row, $sale->invoice);
            $sheet->setCellValue('C'.$row, $sale->buyer->nama);
            $sheet->setCellValue('D'.$row, $sale->total);
            $sheet->setCellValue('E'.$row, $hpp);
            $sheet->setCellValue('F'.$row, $sale->total - $hpp);
            $row++;
        }

        // Totals
        $sheet->setCellValue('C'.$row, 'TOTAL');
        $sheet->setCellValue('D'.$row, $penjualan->sum('total'));
        $sheet->setCellValue('E'.$row, $penjualan->sum(fn ($s) => $s->saleDetails->sum('hpp_total')));
        $sheet->setCellValue('F'.$row, $penjualan->sum('total') - $penjualan->sum(fn ($s) => $s->saleDetails->sum('hpp_total')));

        $writer = new Xlsx($spreadsheet);
        $filename = 'Laporan_Laba_Rugi_'.$year.($month ? '_'.$month : '').'.xlsx';

        return response()->streamDownload(function () use ($writer) {
            $writer->save('php://output');
        }, $filename, [
            'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ]);
    }

    public function exportPdf(Request $request)
    {
        $year = $request->get('year', now()->year);
        $month = $request->get('month');

        $query = Sale::where('status', 'active')
            ->with(['buyer', 'saleDetails.product']);

        if ($month) {
            $query->whereMonth('tanggal', $month);
        }
        $query->whereYear('tanggal', $year);

        $penjualan = $query->latest('tanggal')->get();
        $totalPenjualan = $penjualan->sum('total');
        $totalHPP = $penjualan->sum(fn ($s) => $s->saleDetails->sum('hpp_total'));
        $labaKotor = $totalPenjualan - $totalHPP;

        $pdf = Pdf::loadView('owner.laporan.pdf', compact(
            'penjualan', 'totalPenjualan', 'totalHPP', 'labaKotor', 'year', 'month'
        ));

        $filename = 'Laporan_Laba_Rugi_'.$year.($month ? '_'.$month : '').'.pdf';

        return $pdf->download($filename);
    }
}
