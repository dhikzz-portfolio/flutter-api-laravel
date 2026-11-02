@extends('layouts.app')
@section('title', 'Dashboard Owner')
@section('page-title', 'Dashboard')
@section('content')

{{-- Filter --}}
<div class="mb-6 flex flex-wrap items-center gap-3">
    <form method="GET" class="flex flex-wrap items-center gap-3">
        <select name="month" class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-700 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
            <option value="">Semua Bulan</option>
            @for($m = 1; $m <= 12; $m++)
                <option value="{{ $m }}" {{ $month == $m ? 'selected' : '' }}>{{ now()->month($m)->translatedFormat('F') }}</option>
            @endfor
        </select>
        <select name="year" class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-700 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
            @for($y = now()->year; $y >= now()->year - 5; $y--)
                <option value="{{ $y }}" {{ $year == $y ? 'selected' : '' }}>{{ $y }}</option>
            @endfor
        </select>
        <button type="submit" class="rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-700">Filter</button>
    </form>
</div>

{{-- Summary Cards --}}
<div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
    <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <p class="text-sm font-medium text-gray-500">Total Penjualan</p>
        <p class="mt-1 text-2xl font-bold text-gray-900">Rp {{ number_format($totalPenjualan, 0, ',', '.') }}</p>
    </div>
    <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <p class="text-sm font-medium text-gray-500">Total HPP</p>
        <p class="mt-1 text-2xl font-bold text-gray-900">Rp {{ number_format($totalHPP, 0, ',', '.') }}</p>
    </div>
    <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <p class="text-sm font-medium text-gray-500">Laba Kotor</p>
        <p class="mt-1 text-2xl font-bold {{ $labaKotor >= 0 ? 'text-green-600' : 'text-red-600' }}">Rp {{ number_format($labaKotor, 0, ',', '.') }}</p>
    </div>
</div>

{{-- Chart --}}
<div class="mt-6 rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
    <h3 class="mb-4 text-lg font-semibold text-gray-800">Grafik Bulanan {{ $year }}</h3>
    <div class="overflow-x-auto">
        <div class="min-w-[600px]">
            {{-- Simple bar chart using CSS --}}
            <div class="space-y-3">
                @php
                    $maxValue = max($months->pluck('penjualan')->max(), 1);
                @endphp
                @foreach($months as $m)
                <div class="flex items-center gap-3">
                    <span class="w-10 text-right text-xs font-medium text-gray-500">{{ $m['nama'] }}</span>
                    <div class="flex-1">
                        <div class="flex gap-1">
                            <div class="h-5 rounded bg-indigo-500 transition-all" style="width: {{ ($m['penjualan'] / $maxValue) * 100 }}%" title="Penjualan: Rp {{ number_format($m['penjualan'], 0, ',', '.') }}"></div>
                            <div class="h-5 rounded bg-green-500 transition-all" style="width: {{ ($m['laba'] / max($maxValue, 1)) * 100 }}%" title="Laba: Rp {{ number_format($m['laba'], 0, ',', '.') }}"></div>
                        </div>
                    </div>
                    <span class="w-32 text-right text-xs text-gray-500">Rp {{ number_format($m['penjualan'], 0, ',', '.') }}</span>
                </div>
                @endforeach
            </div>
            <div class="mt-4 flex gap-4 text-xs text-gray-500">
                <span class="flex items-center gap-1"><span class="inline-block h-2 w-2 rounded-full bg-indigo-500"></span> Penjualan</span>
                <span class="flex items-center gap-1"><span class="inline-block h-2 w-2 rounded-full bg-green-500"></span> Laba Kotor</span>
            </div>
        </div>
    </div>
</div>

{{-- Quick Actions --}}
<div class="mt-6 rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
    <h3 class="mb-4 text-lg font-semibold text-gray-800">Lainnya</h3>
    <div class="flex flex-wrap gap-3">
        <a href="{{ route('owner.laporan.index') }}" class="inline-flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition-colors hover:bg-indigo-700">
            Lihat Laporan Lengkap
        </a>
    </div>
</div>
@endsection
