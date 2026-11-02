@extends('layouts.app')
@section('title', 'Koreksi Stok')
@section('page-title', 'Koreksi Stok')
@section('content')

<div class="rounded-xl border border-gray-200 bg-white shadow-sm">
    <div class="flex flex-wrap items-center justify-between gap-3 border-b border-gray-100 p-4 lg:p-6">
        <form method="GET" class="flex flex-wrap items-center gap-2">
            <input type="date" name="date_from" value="{{ request('date_from') }}" class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
            <input type="date" name="date_to" value="{{ request('date_to') }}" class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
            <button type="submit" class="rounded-lg bg-gray-100 px-3 py-2 text-sm text-gray-600 hover:bg-gray-200">Filter</button>
        </form>
        <a href="{{ route('admin.koreksi-stok.create') }}" class="inline-flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-semibold text-white hover:bg-indigo-700">
            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
            Koreksi Stok Baru
        </a>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead>
                <tr class="border-b border-gray-100 bg-gray-50 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                    <th class="px-4 py-3 lg:px-6">No</th>
                    <th class="px-4 py-3 lg:px-6">Tanggal</th>
                    <th class="px-4 py-3 lg:px-6">Produk</th>
                    <th class="px-4 py-3 lg:px-6 text-right">Stok Sistem</th>
                    <th class="px-4 py-3 lg:px-6 text-right">Stok Fisik</th>
                    <th class="px-4 py-3 lg:px-6 text-right">Selisih</th>
                    <th class="px-4 py-3 lg:px-6">Alasan</th>
                    <th class="px-4 py-3 lg:px-6">User</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-50">
                @forelse($koreksiStok as $item)
                    @foreach($item->stockAdjustmentDetails as $detail)
                    <tr class="hover:bg-gray-50">
                        <td class="px-4 py-3 lg:px-6 text-gray-400">{{ ($koreksiStok->currentPage() - 1) * $koreksiStok->perPage() + $loop->parent->iteration }}</td>
                        <td class="px-4 py-3 text-gray-500 lg:px-6">{{ $item->tanggal->format('d/m/Y') }}</td>
                        <td class="px-4 py-3 font-medium text-gray-800 lg:px-6">{{ $detail->product->nama }}</td>
                        <td class="px-4 py-3 text-right text-gray-500 lg:px-6">{{ $detail->stok_sebelum }}</td>
                        <td class="px-4 py-3 text-right text-gray-800 lg:px-6">{{ $detail->stok_fisik }}</td>
                        <td class="px-4 py-3 text-right lg:px-6">
                            <span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium {{ $detail->selisih >= 0 ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700' }}">{{ $detail->selisih >= 0 ? '+' : '' }}{{ $detail->selisih }}</span>
                        </td>
                        <td class="px-4 py-3 text-gray-500 lg:px-6">{{ $detail->alasan }}</td>
                        <td class="px-4 py-3 text-gray-500 lg:px-6">{{ $item->user->nama }}</td>
                    </tr>
                    @endforeach
                @empty
                <tr>
                    <td colspan="8" class="px-6 py-12 text-center text-gray-400">Belum ada data koreksi stok.</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="border-t border-gray-100 p-4">{{ $koreksiStok->links() }}</div>
</div>
@endsection
