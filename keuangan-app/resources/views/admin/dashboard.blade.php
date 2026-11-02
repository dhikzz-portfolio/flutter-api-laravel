@extends('layouts.app')
@section('title', 'Dashboard Admin')
@section('page-title', 'Dashboard')
@section('content')

<div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
    {{-- Pembelian Hari Ini --}}
    <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-sm font-medium text-gray-500">Pembelian Hari Ini</p>
                <p class="mt-1 text-3xl font-bold text-gray-900">{{ $pembelianHariIni }}</p>
                <p class="text-xs text-gray-400">transaksi</p>
            </div>
            <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
                <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></svg>
            </div>
        </div>
    </div>

    {{-- Barang Masuk --}}
    <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-sm font-medium text-gray-500">Barang Masuk Hari Ini</p>
                <p class="mt-1 text-3xl font-bold text-gray-900">{{ $barangMasuk }}</p>
                <p class="text-xs text-gray-400">unit</p>
            </div>
            <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-green-50 text-green-600">
                <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M5 10l7-7m0 0l7 7m-7-7v18"/></svg>
            </div>
        </div>
    </div>

    {{-- Barang Keluar --}}
    <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-sm font-medium text-gray-500">Barang Keluar Hari Ini</p>
                <p class="mt-1 text-3xl font-bold text-gray-900">{{ $barangKeluar }}</p>
                <p class="text-xs text-gray-400">unit</p>
            </div>
            <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-red-50 text-red-600">
                <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 14l-7 7m0 0l-7-7m7 7V3"/></svg>
            </div>
        </div>
    </div>

    {{-- Stok Minimum --}}
    <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-sm font-medium text-gray-500">Stok Minimum</p>
                <p class="mt-1 text-3xl font-bold text-orange-600">{{ $produkStokMinimum->count() }}</p>
                <p class="text-xs text-gray-400">produk perlu restok</p>
            </div>
            <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-orange-50 text-orange-600">
                <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.34 16.5c-.77.833.192 2.5 1.732 2.5z"/></svg>
            </div>
        </div>
    </div>
</div>

{{-- Produk Stok Minimum --}}
@if($produkStokMinimum->isNotEmpty())
<div class="mt-6 rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
    <h3 class="mb-4 text-lg font-semibold text-gray-800">Produk Stok Minimum</h3>
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead>
                <tr class="border-b border-gray-100 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                    <th class="pb-3 pr-4">Produk</th>
                    <th class="pb-3 pr-4">Kategori</th>
                    <th class="pb-3 pr-4 text-right">Stok</th>
                    <th class="pb-3 text-right">Min.</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-50">
                @foreach($produkStokMinimum as $produk)
                <tr>
                    <td class="py-3 pr-4 font-medium text-gray-800">{{ $produk->nama }}</td>
                    <td class="py-3 pr-4 text-gray-500">{{ $produk->category->nama }}</td>
                    <td class="py-3 pr-4 text-right">
                        <span class="inline-flex items-center rounded-full bg-red-50 px-2 py-0.5 text-xs font-medium text-red-700">{{ $produk->stok }}</span>
                    </td>
                    <td class="py-3 text-right text-gray-500">{{ $produk->stok_minimum }}</td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>
@endif
@endsection
