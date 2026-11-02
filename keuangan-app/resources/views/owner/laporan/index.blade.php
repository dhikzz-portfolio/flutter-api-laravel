@extends('layouts.app')
@section('title', 'Laporan Laba/Rugi')
@section('page-title', 'Laporan Laba/Rugi')
@section('content')

<div class="rounded-xl border border-gray-200 bg-white shadow-sm">
    <div class="border-b border-gray-100 p-4 lg:p-6">
        <form method="GET" class="flex flex-wrap items-center gap-3">
            <select name="year" class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                @for($y = now()->year; $y >= now()->year - 5; $y--)
                    <option value="{{ $y }}" {{ $year == $y ? 'selected' : '' }}>{{ $y }}</option>
                @endfor
            </select>
            <select name="month" class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                <option value="">Semua Bulan</option>
                @for($m = 1; $m <= 12; $m++)
                    <option value="{{ $m }}" {{ $month == $m ? 'selected' : '' }}>{{ now()->month($m)->translatedFormat('F') }}</option>
                @endfor
            </select>
            <button type="submit" class="rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-700">Filter</button>

            <div class="ml-auto flex gap-2">
                <a href="{{ route('owner.laporan.export-excel', ['year' => $year, 'month' => $month]) }}" class="inline-flex items-center gap-1 rounded-lg bg-green-600 px-3 py-2 text-sm font-medium text-white hover:bg-green-700">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                    Excel
                </a>
                <a href="{{ route('owner.laporan.export-pdf', ['year' => $year, 'month' => $month]) }}" class="inline-flex items-center gap-1 rounded-lg bg-red-600 px-3 py-2 text-sm font-medium text-white hover:bg-red-700">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                    PDF
                </a>
            </div>
        </form>
    </div>

    {{-- Summary --}}
    <div class="grid grid-cols-1 gap-4 p-4 sm:grid-cols-3 lg:p-6">
        <div class="rounded-lg bg-gray-50 p-4">
            <p class="text-sm text-gray-500">Total Penjualan</p>
            <p class="text-xl font-bold text-gray-900">Rp {{ number_format($totalPenjualan, 0, ',', '.') }}</p>
        </div>
        <div class="rounded-lg bg-gray-50 p-4">
            <p class="text-sm text-gray-500">Total HPP</p>
            <p class="text-xl font-bold text-gray-900">Rp {{ number_format($totalHPP, 0, ',', '.') }}</p>
        </div>
        <div class="rounded-lg {{ $labaKotor >= 0 ? 'bg-green-50' : 'bg-red-50' }} p-4">
            <p class="text-sm {{ $labaKotor >= 0 ? 'text-green-600' : 'text-red-600' }}">Laba Kotor</p>
            <p class="text-xl font-bold {{ $labaKotor >= 0 ? 'text-green-700' : 'text-red-700' }}">Rp {{ number_format($labaKotor, 0, ',', '.') }}</p>
        </div>
    </div>

    {{-- Monthly Breakdown --}}
    <div class="border-t border-gray-100 p-4 lg:p-6">
        <h4 class="mb-4 text-sm font-semibold text-gray-700">Breakdown Bulanan {{ $year }}</h4>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="border-b border-gray-100 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                        <th class="pb-3">Bulan</th>
                        <th class="pb-3 text-right">Penjualan</th>
                        <th class="pb-3 text-right">HPP</th>
                        <th class="pb-3 text-right">Laba Kotor</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                    @foreach($monthlyData as $m)
                    <tr class="{{ $month && $month == $loop->iteration ? 'bg-indigo-50' : '' }}">
                        <td class="py-2 font-medium text-gray-800">{{ $m['bulan'] }}</td>
                        <td class="py-2 text-right">Rp {{ number_format($m['penjualan'], 0, ',', '.') }}</td>
                        <td class="py-2 text-right">Rp {{ number_format($m['hpp'], 0, ',', '.') }}</td>
                        <td class="py-2 text-right font-medium {{ $m['laba'] >= 0 ? 'text-green-600' : 'text-red-600' }}">Rp {{ number_format($m['laba'], 0, ',', '.') }}</td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>

    {{-- Detail Transactions --}}
    <div class="border-t border-gray-100 p-4 lg:p-6">
        <h4 class="mb-4 text-sm font-semibold text-gray-700">Detail Transaksi</h4>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="border-b border-gray-100 bg-gray-50 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                        <th class="px-4 py-3">Tanggal</th>
                        <th class="px-4 py-3">Invoice</th>
                        <th class="px-4 py-3">Pembeli</th>
                        <th class="px-4 py-3 text-right">Total</th>
                        <th class="px-4 py-3 text-right">HPP</th>
                        <th class="px-4 py-3 text-right">Laba</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                    @forelse($penjualan as $sale)
                    <tr class="hover:bg-gray-50">
                        <td class="px-4 py-3 text-gray-500">{{ $sale->tanggal->format('d/m/Y') }}</td>
                        <td class="px-4 py-3 font-mono text-xs text-gray-800">{{ $sale->invoice }}</td>
                        <td class="px-4 py-3 text-gray-500">{{ $sale->buyer->nama }}</td>
                        <td class="px-4 py-3 text-right font-medium text-gray-800">Rp {{ number_format($sale->total, 0, ',', '.') }}</td>
                        <td class="px-4 py-3 text-right text-gray-500">Rp {{ number_format($sale->saleDetails->sum('hpp_total'), 0, ',', '.') }}</td>
                        <td class="px-4 py-3 text-right font-medium {{ ($sale->total - $sale->saleDetails->sum('hpp_total')) >= 0 ? 'text-green-600' : 'text-red-600' }}">Rp {{ number_format($sale->total - $sale->saleDetails->sum('hpp_total'), 0, ',', '.') }}</td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="6" class="px-6 py-12 text-center text-gray-400">Tidak ada data transaksi untuk periode ini.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection
