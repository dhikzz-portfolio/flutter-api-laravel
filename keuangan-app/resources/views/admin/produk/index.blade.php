@extends('layouts.app')
@section('title', 'Produk')
@section('page-title', 'Produk')
@section('content')

<div class="rounded-xl border border-gray-200 bg-white shadow-sm">
    <div class="flex flex-wrap items-center justify-between gap-3 border-b border-gray-100 p-4 lg:p-6">
        <form method="GET" class="flex flex-wrap items-center gap-2">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari produk..." class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
            <select name="status" class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                <option value="">Semua Status</option>
                <option value="aktif" {{ request('status') === 'aktif' ? 'selected' : '' }}>Aktif</option>
                <option value="nonaktif" {{ request('status') === 'nonaktif' ? 'selected' : '' }}>Nonaktif</option>
            </select>
            <button type="submit" class="rounded-lg bg-gray-100 px-3 py-2 text-sm text-gray-600 hover:bg-gray-200">Cari</button>
        </form>
        <button onclick="document.getElementById('modal-add').classList.remove('hidden')" class="inline-flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-semibold text-white hover:bg-indigo-700">
            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
            Tambah Produk
        </button>
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
                    <th class="px-4 py-3 text-right lg:px-6">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-50">
                @forelse($produk as $item)
                <tr class="hover:bg-gray-50">
                    <td class="px-4 py-3 lg:px-6 text-gray-400">{{ ($produk->currentPage() - 1) * $produk->perPage() + $loop->iteration }}</td>
                    <td class="px-4 py-3 font-medium text-gray-800 lg:px-6">{{ $item->nama }}</td>
                    <td class="px-4 py-3 text-gray-500 lg:px-6">{{ $item->category->nama }}</td>
                    <td class="px-4 py-3 text-right lg:px-6">Rp {{ number_format($item->harga_jual, 0, ',', '.') }}</td>
                    <td class="px-4 py-3 text-right lg:px-6">
                        <span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium {{ $item->stok <= $item->stok_minimum ? 'bg-red-50 text-red-700' : 'bg-green-50 text-green-700' }}">{{ $item->stok }}</span>
                    </td>
                    <td class="px-4 py-3 text-right text-gray-500 lg:px-6">Rp {{ number_format($item->hpp_rata_rata, 0, ',', '.') }}</td>
                    <td class="px-4 py-3 lg:px-6">
                        <span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium {{ $item->status === 'aktif' ? 'bg-green-50 text-green-700' : 'bg-gray-100 text-gray-600' }}">{{ ucfirst($item->status) }}</span>
                    </td>
                    <td class="px-4 py-3 text-right lg:px-6">
                        <button onclick='openEditModal(@json($item))' class="rounded-lg px-3 py-1.5 text-xs font-medium text-indigo-600 hover:bg-indigo-50">Edit</button>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="8" class="px-6 py-12 text-center text-gray-400">Belum ada data produk.</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="border-t border-gray-100 p-4">{{ $produk->links() }}</div>
</div>

{{-- Modal Add --}}
<div id="modal-add" class="hidden fixed inset-0 z-50 flex items-center justify-center bg-black/50">
    <div class="mx-4 w-full max-w-lg rounded-xl bg-white p-6 shadow-xl max-h-[90vh] overflow-y-auto">
        <h3 class="mb-4 text-lg font-semibold">Tambah Produk</h3>
        <form method="POST" action="{{ route('admin.produk.store') }}">
            @csrf
            <div class="space-y-4">
                <div>
                    <label class="mb-1 block text-sm font-medium text-gray-700">Nama Produk</label>
                    <input type="text" name="nama" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                </div>
                <div>
                    <label class="mb-1 block text-sm font-medium text-gray-700">Kategori</label>
                    <select name="category_id" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                        <option value="">Pilih Kategori</option>
                        @foreach($categories as $cat)
                            <option value="{{ $cat->id }}">{{ $cat->nama }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="mb-1 block text-sm font-medium text-gray-700">Harga Jual</label>
                        <input type="number" name="harga_jual" min="0" step="0.01" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-gray-700">Stok Awal</label>
                        <input type="number" name="stok" min="0" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                    </div>
                </div>
                <div>
                    <label class="mb-1 block text-sm font-medium text-gray-700">Stok Minimum</label>
                    <input type="number" name="stok_minimum" min="0" value="0" class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                </div>
            </div>
            <div class="mt-6 flex justify-end gap-2">
                <button type="button" onclick="document.getElementById('modal-add').classList.add('hidden')" class="rounded-lg px-4 py-2 text-sm font-medium text-gray-600 hover:bg-gray-100">Batal</button>
                <button type="submit" class="rounded-lg bg-indigo-600 px-4 py-2 text-sm font-semibold text-white hover:bg-indigo-700">Simpan</button>
            </div>
        </form>
    </div>
</div>

{{-- Modal Edit --}}
<div id="modal-edit" class="hidden fixed inset-0 z-50 flex items-center justify-center bg-black/50">
    <div class="mx-4 w-full max-w-lg rounded-xl bg-white p-6 shadow-xl max-h-[90vh] overflow-y-auto">
        <h3 class="mb-4 text-lg font-semibold">Edit Produk</h3>
        <form id="edit-form" method="POST">
            @csrf
            @method('PUT')
            <div class="space-y-4">
                <div>
                    <label class="mb-1 block text-sm font-medium text-gray-700">Nama Produk</label>
                    <input type="text" id="edit-nama" name="nama" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                </div>
                <div>
                    <label class="mb-1 block text-sm font-medium text-gray-700">Kategori</label>
                    <select id="edit-category_id" name="category_id" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                        @foreach($categories as $cat)
                            <option value="{{ $cat->id }}">{{ $cat->nama }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="mb-1 block text-sm font-medium text-gray-700">Harga Jual</label>
                        <input type="number" id="edit-harga_jual" name="harga_jual" min="0" step="0.01" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-gray-700">Stok Minimum</label>
                        <input type="number" id="edit-stok_minimum" name="stok_minimum" min="0" class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                    </div>
                </div>
                <div>
                    <label class="mb-1 block text-sm font-medium text-gray-700">Status</label>
                    <select id="edit-status" name="status" class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                        <option value="aktif">Aktif</option>
                        <option value="nonaktif">Nonaktif</option>
                    </select>
                </div>
            </div>
            <div class="mt-6 flex justify-end gap-2">
                <button type="button" onclick="document.getElementById('modal-edit').classList.add('hidden')" class="rounded-lg px-4 py-2 text-sm font-medium text-gray-600 hover:bg-gray-100">Batal</button>
                <button type="submit" class="rounded-lg bg-indigo-600 px-4 py-2 text-sm font-semibold text-white hover:bg-indigo-700">Simpan</button>
            </div>
        </form>
    </div>
</div>

@push('scripts')
<script>
function openEditModal(item) {
    document.getElementById('edit-form').action = '{{ url("admin/produk") }}/' + item.id;
    document.getElementById('edit-nama').value = item.nama;
    document.getElementById('edit-category_id').value = item.category_id;
    document.getElementById('edit-harga_jual').value = item.harga_jual;
    document.getElementById('edit-stok_minimum').value = item.stok_minimum;
    document.getElementById('edit-status').value = item.status;
    document.getElementById('modal-edit').classList.remove('hidden');
}
</script>
@endpush
@endsection
