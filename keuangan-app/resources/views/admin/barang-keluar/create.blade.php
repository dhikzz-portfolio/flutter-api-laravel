@extends('layouts.app')
@section('title', 'Barang Keluar Baru')
@section('page-title', 'Barang Keluar Baru')
@section('content')

<div class="rounded-xl border border-gray-200 bg-white shadow-sm">
    <div class="border-b border-gray-100 p-4 lg:p-6">
        <h3 class="text-lg font-semibold text-gray-800">Form Barang Keluar</h3>
    </div>

    <form method="POST" action="{{ route('admin.barang-keluar.store') }}" class="p-4 lg:p-6">
        @csrf

        <div class="space-y-6">
            <div>
                <label class="mb-1 block text-sm font-medium text-gray-700">Keterangan Umum</label>
                <textarea name="keterangan" rows="2" class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" placeholder="Catatan umum (opsional)"></textarea>
            </div>

            <div>
                <div class="mb-3 flex items-center justify-between">
                    <h4 class="text-sm font-semibold text-gray-700">Detail Barang Keluar</h4>
                    <button type="button" onclick="addItem()" class="inline-flex items-center gap-1 rounded-lg bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600 hover:bg-gray-200">
                        <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
                        Tambah Item
                    </button>
                </div>

                @error('items')<div class="mb-3 rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-red-700">{{ $message }}</div>@enderror

                <div id="items-container" class="space-y-3"></div>

                <div id="empty-items" class="rounded-lg border-2 border-dashed border-gray-200 p-8 text-center">
                    <p class="text-sm text-gray-400">Klik "Tambah Item" untuk menambahkan barang keluar</p>
                </div>
            </div>
        </div>

        <div class="mt-6 flex justify-end gap-3 border-t border-gray-100 pt-6">
            <a href="{{ route('admin.barang-keluar.index') }}" class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50">Batal</a>
            <button type="submit" id="submit-btn" class="rounded-lg bg-indigo-600 px-6 py-2 text-sm font-semibold text-white hover:bg-indigo-700" disabled>Simpan</button>
        </div>
    </form>
</div>

@push('scripts')
<script>
const products = @json($products);
let itemIndex = 0;

function addItem() {
    const container = document.getElementById('items-container');
    document.getElementById('empty-items').classList.add('hidden');

    const html = `
        <div class="item-row rounded-lg border border-gray-200 p-4">
            <div class="flex items-start gap-3">
                <div class="flex-1 space-y-3">
                    <select name="items[${itemIndex}][product_id]" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                        <option value="">Pilih Produk</option>
                        ${products.map(p => `<option value="${p.id}">${p.nama} (Stok: ${p.stok})</option>`).join('')}
                    </select>
                    <div class="grid grid-cols-3 gap-3">
                        <div>
                            <label class="mb-1 block text-xs text-gray-500">Jumlah</label>
                            <input type="number" name="items[${itemIndex}][jumlah]" min="1" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                        </div>
                        <div>
                            <label class="mb-1 block text-xs text-gray-500">Jenis</label>
                            <select name="items[${itemIndex}][jenis]" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                                <option value="RUSAK">Rusak</option>
                                <option value="EXPIRED">Expired</option>
                                <option value="DIBERIKAN">Diberikan</option>
                                <option value="LAINNYA">Lainnya</option>
                            </select>
                        </div>
                        <div>
                            <label class="mb-1 block text-xs text-gray-500">Keterangan</label>
                            <input type="text" name="items[${itemIndex}][keterangan_item]" class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" placeholder="Opsional">
                        </div>
                    </div>
                </div>
                <button type="button" onclick="removeItem(this)" class="mt-6 rounded-lg p-2 text-gray-400 hover:bg-red-50 hover:text-red-600">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                </button>
            </div>
        </div>
    `;

    container.insertAdjacentHTML('beforeend', html);
    itemIndex++;
    updateSubmitBtn();
}

function removeItem(btn) {
    btn.closest('.item-row').remove();
    if (document.getElementById('items-container').children.length === 0) {
        document.getElementById('empty-items').classList.remove('hidden');
    }
    updateSubmitBtn();
}

function updateSubmitBtn() {
    document.getElementById('submit-btn').disabled = document.querySelectorAll('.item-row').length === 0;
}
</script>
@endpush
@endsection
