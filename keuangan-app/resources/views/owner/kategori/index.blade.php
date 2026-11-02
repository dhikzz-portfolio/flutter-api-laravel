@extends('layouts.app')
@section('title', 'Kategori')
@section('page-title', 'Kategori (Lihat Saja)')
@section('content')

<div class="rounded-xl border border-gray-200 bg-white shadow-sm">
    <div class="border-b border-gray-100 p-4 lg:p-6">
        <form method="GET" class="flex items-center gap-2">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari kategori..." class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
            <button type="submit" class="rounded-lg bg-gray-100 px-3 py-2 text-sm text-gray-600 hover:bg-gray-200">Cari</button>
        </form>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead>
                <tr class="border-b border-gray-100 bg-gray-50 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                    <th class="px-4 py-3 lg:px-6">No</th>
                    <th class="px-4 py-3 lg:px-6">Nama</th>
                    <th class="px-4 py-3 lg:px-6">Status</th>
                    <th class="px-4 py-3 text-right lg:px-6">Jumlah Produk</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-50">
                @forelse($kategori as $item)
                <tr class="hover:bg-gray-50">
                    <td class="px-4 py-3 lg:px-6 text-gray-400">{{ ($kategori->currentPage() - 1) * $kategori->perPage() + $loop->iteration }}</td>
                    <td class="px-4 py-3 font-medium text-gray-800 lg:px-6">{{ $item->nama }}</td>
                    <td class="px-4 py-3 lg:px-6">
                        <span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium {{ $item->status === 'aktif' ? 'bg-green-50 text-green-700' : 'bg-gray-100 text-gray-600' }}">{{ ucfirst($item->status) }}</span>
                    </td>
                    <td class="px-4 py-3 text-right lg:px-6">{{ $item->products_count }}</td>
                </tr>
                @empty
                <tr>
                    <td colspan="4" class="px-6 py-12 text-center text-gray-400">Belum ada data kategori.</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="border-t border-gray-100 p-4">{{ $kategori->links() }}</div>
</div>
@endsection
