@extends('layouts.app')
@section('title', 'Transaksi Penjualan')
@section('page-title', 'Transaksi Penjualan')
@section('content')

<div class="rounded-xl border border-gray-200 bg-white shadow-sm">
    <div class="flex flex-wrap items-center justify-between gap-3 border-b border-gray-100 p-4 lg:p-6">
        <form method="GET" class="flex flex-wrap items-center gap-2">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari invoice/pembeli..." class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
            <input type="date" name="date_from" value="{{ request('date_from') }}" class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
            <input type="date" name="date_to" value="{{ request('date_to') }}" class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
            <button type="submit" class="rounded-lg bg-gray-100 px-3 py-2 text-sm text-gray-600 hover:bg-gray-200">Cari</button>
        </form>
        <a href="{{ route('kasir.penjualan.create') }}" class="inline-flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-semibold text-white hover:bg-indigo-700">
            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
            Transaksi Baru
        </a>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead>
                <tr class="border-b border-gray-100 bg-gray-50 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                    <th class="px-4 py-3 lg:px-6">No</th>
                    <th class="px-4 py-3 lg:px-6">Invoice</th>
                    <th class="px-4 py-3 lg:px-6">Tanggal</th>
                    <th class="px-4 py-3 lg:px-6">Pembeli</th>
                    <th class="px-4 py-3 lg:px-6 text-right">Total</th>
                    <th class="px-4 py-3 lg:px-6">Status</th>
                    <th class="px-4 py-3 text-right lg:px-6">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-50">
                @forelse($penjualan as $item)
                <tr class="hover:bg-gray-50">
                    <td class="px-4 py-3 lg:px-6 text-gray-400">{{ ($penjualan->currentPage() - 1) * $penjualan->perPage() + $loop->iteration }}</td>
                    <td class="px-4 py-3 font-mono text-xs font-medium text-gray-800 lg:px-6">{{ $item->invoice }}</td>
                    <td class="px-4 py-3 text-gray-500 lg:px-6">{{ $item->tanggal->format('d/m/Y') }}</td>
                    <td class="px-4 py-3 text-gray-500 lg:px-6">{{ $item->buyer->nama }}</td>
                    <td class="px-4 py-3 text-right font-medium text-gray-800 lg:px-6">Rp {{ number_format($item->total, 0, ',', '.') }}</td>
                    <td class="px-4 py-3 lg:px-6">
                        <span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium {{ $item->status === 'active' ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700' }}">{{ $item->status === 'active' ? 'Aktif' : 'Dibatalkan' }}</span>
                    </td>
                    <td class="px-4 py-3 text-right lg:px-6">
                        <div class="flex items-center justify-end gap-1">
                            @if($item->status === 'active')
                                <a href="{{ route('kasir.penjualan.nota', $item) }}" class="rounded-lg px-3 py-1.5 text-xs font-medium text-green-600 hover:bg-green-50">Nota</a>
                                <form method="POST" action="{{ route('kasir.penjualan.batal', $item) }}" onsubmit="return confirm('Yakin ingin membatalkan transaksi ini? Stok akan dikembalikan.')">
                                    @csrf
                                    <button type="submit" class="rounded-lg px-3 py-1.5 text-xs font-medium text-red-600 hover:bg-red-50">Batal</button>
                                </form>
                            @else
                                <span class="text-xs text-gray-400">-</span>
                            @endif
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="7" class="px-6 py-12 text-center text-gray-400">Belum ada transaksi penjualan.</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="border-t border-gray-100 p-4">{{ $penjualan->links() }}</div>
</div>
@endsection
