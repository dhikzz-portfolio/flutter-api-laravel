<?php

namespace App\Services;

use App\Models\Sale;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Support\Collection;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Symfony\Component\HttpFoundation\Response as SymfonyResponse;
use Symfony\Component\HttpFoundation\StreamedResponse;

class LaporanExportService
{
    /**
     * Query penjualan aktif untuk periode tertentu (dipakai index, excel, pdf).
     */
    public function salesForPeriod(?int $year, ?int $month)
    {
        $query = Sale::where('status', 'active')
            ->with(['buyer', 'saleDetails.product'])
            ->whereYear('tanggal', $year ?? now()->year);

        if ($month) {
            $query->whereMonth('tanggal', $month);
        }

        return $query->latest('tanggal')->get();
    }

    /**
     * Rekap laba/rugi untuk periode tertentu.
     *
     * @return array{penjualan: Collection, total_penjualan: float, total_hpp: float, laba_kotor: float}
     */
    public function summary(?int $year, ?int $month): array
    {
        $penjualan = $this->salesForPeriod($year, $month);

        $totalPenjualan = (float) $penjualan->sum('total');
        $totalHpp = (float) $penjualan->sum(fn ($s) => $s->saleDetails->sum('hpp_total'));

        return [
            'penjualan' => $penjualan,
            'total_penjualan' => $totalPenjualan,
            'total_hpp' => $totalHpp,
            'laba_kotor' => $totalPenjualan - $totalHpp,
        ];
    }

    /**
     * Export laporan laba/rugi ke Excel (xlsx).
     */
    public function exportExcel(?int $year, ?int $month): StreamedResponse
    {
        $year = $year ?? now()->year;
        $penjualan = $this->salesForPeriod($year, $month);

        $spreadsheet = new Spreadsheet;
        $sheet = $spreadsheet->getActiveSheet();

        $sheet->setCellValue('A1', 'Laporan Laba/Rugi');
        $sheet->setCellValue('A2', 'Periode: '.($month ? now()->month($month)->translatedFormat('F ') : '').$year);
        $sheet->mergeCells('A1:D1');
        $sheet->mergeCells('A2:D2');

        $headers = ['Tanggal', 'Invoice', 'Pembeli', 'Total Penjualan', 'HPP', 'Laba Kotor'];
        foreach ($headers as $col => $header) {
            $sheet->setCellValue(chr(65 + $col).'4', $header);
        }

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

    /**
     * Export laporan laba/rugi ke PDF.
     */
    public function exportPdf(?int $year, ?int $month): SymfonyResponse
    {
        $year = $year ?? now()->year;
        $penjualan = $this->salesForPeriod($year, $month);
        $totalPenjualan = (float) $penjualan->sum('total');
        $totalHPP = (float) $penjualan->sum(fn ($s) => $s->saleDetails->sum('hpp_total'));
        $labaKotor = $totalPenjualan - $totalHPP;

        $pdf = Pdf::loadView('owner.laporan.pdf', compact(
            'penjualan', 'totalPenjualan', 'totalHPP', 'labaKotor', 'year', 'month'
        ));

        $filename = 'Laporan_Laba_Rugi_'.$year.($month ? '_'.$month : '').'.pdf';

        return $pdf->download($filename);
    }
}
