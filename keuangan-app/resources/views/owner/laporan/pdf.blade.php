<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Laporan Laba/Rugi</title>
    <style>
        body { font-family: sans-serif; font-size: 12px; color: #333; }
        h1 { font-size: 18px; margin-bottom: 5px; }
        h2 { font-size: 14px; color: #666; margin-bottom: 20px; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 8px; border: 1px solid #ddd; text-align: left; }
        th { background: #f5f5f5; font-weight: bold; }
        .text-right { text-align: right; }
        .summary { margin-bottom: 20px; }
        .summary p { margin: 5px 0; }
        .total { font-weight: bold; font-size: 14px; }
    </style>
</head>
<body>
    <h1>Laporan Laba/Rugi</h1>
    <h2>Periode: {{ $month ? now()->month($month)->translatedFormat('F ') : '' }}{{ $year }}</h2>

    <div class="summary">
        <p><strong>Total Penjualan:</strong> Rp {{ number_format($totalPenjualan, 0, ',', '.') }}</p>
        <p><strong>Total HPP:</strong> Rp {{ number_format($totalHPP, 0, ',', '.') }}</p>
        <p class="total"><strong>Laba Kotor:</strong> Rp {{ number_format($labaKotor, 0, ',', '.') }}</p>
    </div>

    <table>
        <thead>
            <tr>
                <th>Tanggal</th>
                <th>Invoice</th>
                <th>Pembeli</th>
                <th class="text-right">Total</th>
                <th class="text-right">HPP</th>
                <th class="text-right">Laba</th>
            </tr>
        </thead>
        <tbody>
            @foreach($penjualan as $sale)
            <tr>
                <td>{{ $sale->tanggal->format('d/m/Y') }}</td>
                <td>{{ $sale->invoice }}</td>
                <td>{{ $sale->buyer->nama }}</td>
                <td class="text-right">Rp {{ number_format($sale->total, 0, ',', '.') }}</td>
                <td class="text-right">Rp {{ number_format($sale->saleDetails->sum('hpp_total'), 0, ',', '.') }}</td>
                <td class="text-right">Rp {{ number_format($sale->total - $sale->saleDetails->sum('hpp_total'), 0, ',', '.') }}</td>
            </tr>
            @endforeach
        </tbody>
        <tfoot>
            <tr style="font-weight: bold; background: #f5f5f5;">
                <td colspan="3">TOTAL</td>
                <td class="text-right">Rp {{ number_format($totalPenjualan, 0, ',', '.') }}</td>
                <td class="text-right">Rp {{ number_format($totalHPP, 0, ',', '.') }}</td>
                <td class="text-right">Rp {{ number_format($labaKotor, 0, ',', '.') }}</td>
            </tr>
        </tfoot>
    </table>

    <p style="margin-top: 30px; font-size: 10px; color: #999;">Dicetak pada: {{ now()->format('d/m/Y H:i') }}</p>
</body>
</html>
