@extends('layouts.app')
@section('title', 'Riwayat Stok')
@section('page-title', 'Riwayat Stok')
@section('content')

<div class="rounded-xl border border-gray-200 bg-white shadow-sm">
    <div class="border-b border-gray-100 p-4 lg:p-6">
        <form method="GET" class="flex flex-wrap items-center gap-2">
            <select name="product_id" class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                <option value="">Semua Produk</option>
                @foreach($products as $p)
                    <option value="{{ $p->id }}" {{ request('product_id') == $p->id ? 'selected' : '' }}>{{ $p->nama }}</option>
                @endforeach
            </select>
            <select name="jenis" class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                <option value="">Semua Jenis</option>
                <option value="PEMBELIAN" {{ request('jenis') === 'PEMBELIAN' ? 'selected' : '' }}>Pembelian</option>
                <option value="PENJUALAN" {{ request('jenis') === 'PENJUALAN' ? 'selected' : '' }}>Penjualan</option>
                <option value="BARANG_KELUAR" {{ request('jenis') === 'BARANG_KELUAR' ? 'selected' : '' }}>Barang Keluar</option>
                <option value="KOREKSI" {{ request('jenis') === 'KOREKSI' ? 'selected' : '' }}>Koreksi</option>
            </select>
            <input type="date" name="date_from" value="{{ request('date_from') }}" class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
            <input type="date" name="date_to" value="{{ request('date_to') }}" class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
            <button type="submit" class="rounded-lg bg-gray-100 px-3 py-2 text-sm text-gray-600 hover:bg-gray-200">Filter</button>
        </form>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead>
                <tr class="border-b border-gray-100 bg-gray-50 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                    <th class="px-4 py-3 lg:px-6">Tanggal</th>
                    <th class="px-4 py-3 lg:px-6">Produk</th>
                    <th class="px-4 py-3 lg:px-6">Jenis</th>
                    <th class="px-4 py-3 lg:px-6 text-right">Stok Sebelum</th>
                    <th class="px-4 py-3 lg:px-6 text-right">Jumlah</th>
                    <th class="px-4 py-3 lg:px-6 text-right">Stok Sesudah</th>
                    <th class="px-4 py-3 lg:px-6">Keterangan</th>
                    <th class="px-4 py-3 lg:px-6">User</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-50">
                @forelse($riwayat as $item)
                <tr class="hover:bg-gray-50">
                    <td class="px-4 py-3 text-gray-500 lg:px-6">{{ $item->tanggal->format('d/m/Y') }}</td>
                    <td class="px-4 py-3 font-medium text-gray-800 lg:px-6">{{ $item->product->nama }}</td>
                    <td class="px-4 py-3 lg:px-6">
                        @php
                            $jenisColors = [
                                'PEMBELIAN' => 'bg-green-50 text-green-700',
                                'PENJUALAN' => 'bg-blue-50 text-blue-700',
                                'BARANG_KELUAR' => 'bg-orange-50 text-orange-700',
                                'KOREKSI' => 'bg-yellow-50 text-yellow-700',
                                'PEMBATALAN_PEMBELIAN' => 'bg-red-50 text-red-700',
                                'PEMBATALAN_PENJUALAN' => 'bg-purple-50 text-purple-700',
                            ];
                        @endphp
                        <span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium {{ $jenisColors[$item->jenis] ?? 'bg-gray-100 text-gray-600' }}">{{ str_replace('_', ' ', $item->jenis) }}</span>
                    </td>
                    <td class="px-4 py-3 text-right text-gray-500 lg:px-6">{{ $item->stok_sebelum }}</td>
                    <td class="px-4 py-3 text-right font-medium lg:px-6 {{ $item->jumlah >= 0 ? 'text-green-600' : 'text-red-600' }}">{{ $item->jumlah >= 0 ? '+' : '' }}{{ $item->jumlah }}</td>
                    <td class="px-4 py-3 text-right text-gray-800 lg:px-6">{{ $item->stok_sesudah }}</td>
                    <td class="px-4 py-3 text-gray-500 lg:px-6 text-xs">{{ $item->keterangan ?? '-' }}</td>
                    <td class="px-4 py-3 text-gray-500 lg:px-6">{{ $item->user->nama }}</td>
                </tr>
                @empty
                <tr>
                    <td colspan="8" class="px-6 py-12 text-center text-gray-400">Belum ada riwayat stok.</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="border-t border-gray-100 p-4">{{ $riwayat->links() }}</div>
</div>
@endsection
