@extends('layouts.app')
@section('title', 'Dashboard Kasir')
@section('page-title', 'Dashboard')
@section('content')

<div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
    {{-- Penjualan Hari Ini --}}
    <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-sm font-medium text-gray-500">Penjualan Hari Ini</p>
                <p class="mt-1 text-3xl font-bold text-gray-900">{{ $penjualanHariIni }}</p>
                <p class="text-xs text-gray-400">transaksi</p>
            </div>
            <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-green-50 text-green-600">
                <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
            </div>
        </div>
    </div>

    {{-- Total Transaksi --}}
    <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-sm font-medium text-gray-500">Total Transaksi Hari Ini</p>
                <p class="mt-1 text-3xl font-bold text-gray-900">Rp {{ number_format($totalTransaksi, 0, ',', '.') }}</p>
            </div>
            <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600">
                <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
        </div>
    </div>

    {{-- Stok Minimum --}}
    <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-sm font-medium text-gray-500">Stok Minimum</p>
                <p class="mt-1 text-3xl font-bold text-orange-600">{{ $stokMinimum }}</p>
                <p class="text-xs text-gray-400">produk perlu restok</p>
            </div>
            <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-orange-50 text-orange-600">
                <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.34 16.5c-.77.833.192 2.5 1.732 2.5z"/></svg>
            </div>
        </div>
    </div>
</div>

{{-- Quick Action --}}
<div class="mt-6 rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
    <h3 class="mb-4 text-lg font-semibold text-gray-800">Aksi Cepat</h3>
    <div class="flex flex-wrap gap-3">
        <a href="{{ route('kasir.penjualan.create') }}" class="inline-flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition-colors hover:bg-indigo-700">
            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
            Transaksi Baru
        </a>
        <a href="{{ route('kasir.pembeli.index') }}" class="inline-flex items-center gap-2 rounded-lg border border-gray-300 bg-white px-4 py-2.5 text-sm font-medium text-gray-700 transition-colors hover:bg-gray-50">
            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"/></svg>
            Data Pembeli
        </a>
    </div>
</div>
@endsection
