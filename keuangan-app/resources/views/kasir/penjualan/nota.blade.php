<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Nota {{ $sale->invoice }}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Courier New', monospace; font-size: 12px; background: #f5f5f5; padding: 20px; }
        .nota { background: white; max-width: 300px; margin: 0 auto; padding: 15px; border: 1px solid #ddd; }
        .header { text-align: center; border-bottom: 2px dashed #333; padding-bottom: 10px; margin-bottom: 10px; }
        .header h1 { font-size: 16px; margin-bottom: 5px; }
        .info { margin-bottom: 10px; }
        .info p { margin-bottom: 2px; }
        .items { border-top: 1px dashed #333; border-bottom: 1px dashed #333; padding: 10px 0; margin-bottom: 10px; }
        .item { display: flex; justify-content: space-between; margin-bottom: 5px; }
        .total { text-align: right; font-weight: bold; font-size: 14px; margin-top: 10px; }
        .footer { text-align: center; margin-top: 15px; font-size: 10px; color: #666; }
        .btn-print { display: block; max-width: 300px; margin: 20px auto; padding: 10px; background: #4f46e5; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 14px; }
        @media print { body { background: white; padding: 0; } .btn-print { display: none; } .nota { border: none; } }
    </style>
</head>
<body>
    <div class="nota">
        <div class="header">
            <h1>FIN-KU</h1>
            <p>Sistem Informasi Keuangan</p>
        </div>

        <div class="info">
            <p><strong>Invoice:</strong> {{ $sale->invoice }}</p>
            <p><strong>Tanggal:</strong> {{ $sale->tanggal->format('d/m/Y H:i') }}</p>
            <p><strong>Pembeli:</strong> {{ $sale->buyer->nama }}</p>
            <p><strong>Kasir:</strong> {{ $sale->user->nama }}</p>
        </div>

        <div class="items">
            @foreach($sale->saleDetails as $detail)
            <div class="item">
                <div>
                    <p>{{ $detail->product->nama }}</p>
                    <p>{{ $detail->jumlah }} x Rp {{ number_format($detail->harga_jual, 0, ',', '.') }}</p>
                </div>
                <div>Rp {{ number_format($detail->subtotal, 0, ',', '.') }}</div>
            </div>
            @endforeach
        </div>

        <div class="total">
            <p>TOTAL: Rp {{ number_format($sale->total, 0, ',', '.') }}</p>
        </div>

        <div class="footer">
            <p>Terima kasih atas kunjungan Anda</p>
            <p>Barang yang sudah dibeli tidak dapat</p>
            <p> dikembalikan</p>
        </div>
    </div>

    <button class="btn-print" onclick="window.print()">🖨️ Cetak Nota</button>
</body>
</html>
