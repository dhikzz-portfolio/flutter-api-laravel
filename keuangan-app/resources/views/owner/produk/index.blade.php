@extends('layouts.app')
@section('title', 'Produk')
@section('page-title', 'Produk (Lihat Saja)')
@section('content')

<div class="rounded-xl border border-gray-200 bg-white shadow-sm">
    <div class="border-b border-gray-100 p-4 lg:p-6">
        <form method="GET" class="flex items-center gap-2">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari produk..." class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
            <button type="submit" class="rounded-lg bg-gray-100 px-3 py-2 text-sm text-gray-600 hover:bg-gray-200">Cari</button>
        </form>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead>
                <tr class="border-b border-gray-100 bg-gray-50 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                    <th class="px-4 py-3 lg:px-6">No</th>
                    <th class="px-4 py-3 lg:px-6">Nama</th>
                    <th class="px-4 py-3 lg:px-6">Kategori</th>
                    <th class="px-4 py-3 lg:px-6 text-right">Harga Jual</th>
                    <th class="px-4 py-3 lg:px-6 text-right">Stok</th>
                    <th class="px-4 py-3 lg:px-6 text-right">HPP</th>
                    <th class="px-4 py-3 lg:px-6">Status</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-50">
                @forelse($produk as $item)
                <tr class="hover:bg-gray-50">
                    <td class="px-4 py-3 lg:px-6 text-gray-400">{{ ($produk->currentPage() - 1) * $produk->perPage() + $loop->iteration }}</td>
                    <td class="px-4 py-3 font-medium text-gray-800 lg:px-6">{{ $item->nama }}</td>
                    <td class="px-4 py-3 text-gray-500 lg:px-6">{{ $item->category->nama }}</td>
                    <td class="px-4 py-3 text-right lg:px-6">Rp {{ number_format($item->harga_jual, 0, ',', '.') }}</td>
                    <td class="px-4 py-3 text-right lg:px-6">{{ $item->stok }}</td>
                    <td class="px-4 py-3 text-right text-gray-500 lg:px-6">Rp {{ number_format($item->hpp_rata_rata, 0, ',', '.') }}</td>
                    <td class="px-4 py-3 lg:px-6">
                        <span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium {{ $item->status === 'aktif' ? 'bg-green-50 text-green-700' : 'bg-gray-100 text-gray-600' }}">{{ ucfirst($item->status) }}</span>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="7" class="px-6 py-12 text-center text-gray-400">Belum ada data produk.</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="border-t border-gray-100 p-4">{{ $produk->links() }}</div>
</div>
@endsection
