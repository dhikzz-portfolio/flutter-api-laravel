@extends('layouts.app')
@section('title', 'Koreksi Stok Baru')
@section('page-title', 'Koreksi Stok Baru')
@section('content')

<div class="rounded-xl border border-gray-200 bg-white shadow-sm">
    <div class="border-b border-gray-100 p-4 lg:p-6">
        <h3 class="text-lg font-semibold text-gray-800">Form Koreksi Stok</h3>
        <p class="mt-1 text-sm text-gray-500">Selisih = Stok Fisik - Stok Sistem</p>
    </div>

    <form method="POST" action="{{ route('admin.koreksi-stok.store') }}" class="p-4 lg:p-6">
        @csrf

        <div class="space-y-6">
            <div>
                <div class="mb-3 flex items-center justify-between">
                    <h4 class="text-sm font-semibold text-gray-700">Detail Koreksi</h4>
                    <button type="button" onclick="addItem()" class="inline-flex items-center gap-1 rounded-lg bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600 hover:bg-gray-200">
                        <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
                        Tambah Item
                    </button>
                </div>

                @error('items')<div class="mb-3 rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-red-700">{{ $message }}</div>@enderror

                <div id="items-container" class="space-y-3"></div>

                <div id="empty-items" class="rounded-lg border-2 border-dashed border-gray-200 p-8 text-center">
                    <p class="text-sm text-gray-400">Klik "Tambah Item" untuk menambahkan koreksi</p>
                </div>
            </div>
        </div>

        <div class="mt-6 flex justify-end gap-3 border-t border-gray-100 pt-6">
            <a href="{{ route('admin.koreksi-stok.index') }}" class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50">Batal</a>
            <button type="submit" id="submit-btn" class="rounded-lg bg-indigo-600 px-6 py-2 text-sm font-semibold text-white hover:bg-indigo-700" disabled>Simpan Koreksi</button>
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
            <div class="space-y-3">
                <div>
                    <label class="mb-1 block text-xs text-gray-500">Produk</label>
                    <select name="items[${itemIndex}][product_id]" required onchange="updateStokSistem(this)" class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                        <option value="">Pilih Produk</option>
                        ${products.map(p => `<option value="${p.id}" data-stok="${p.stok}">${p.nama} (Stok Sistem: ${p.stok})</option>`).join('')}
                    </select>
                </div>
                <div class="grid grid-cols-3 gap-3">
                    <div>
                        <label class="mb-1 block text-xs text-gray-500">Stok Sistem</label>
                        <input type="text" class="item-stok-sistem rounded-lg border border-gray-200 bg-gray-50 px-3 py-2 text-sm text-gray-500" readonly value="-">
                    </div>
                    <div>
                        <label class="mb-1 block text-xs text-gray-500">Stok Fisik</label>
                        <input type="number" name="items[${itemIndex}][stok_fisik]" min="0" required onchange="updateSelisih(this)" onkeyup="updateSelisih(this)" class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                    </div>
                    <div>
                        <label class="mb-1 block text-xs text-gray-500">Selisih</label>
                        <input type="text" class="item-selisih rounded-lg border border-gray-200 bg-gray-50 px-3 py-2 text-sm text-gray-500" readonly value="-">
                    </div>
                </div>
                <div>
                    <label class="mb-1 block text-xs text-gray-500">Alasan <span class="text-red-500">*</span></label>
                    <input type="text" name="items[${itemIndex}][alasan]" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" placeholder="Alasan koreksi">
                </div>
            </div>
            <button type="button" onclick="removeItem(this)" class="mt-3 rounded-lg p-2 text-gray-400 hover:bg-red-50 hover:text-red-600">
                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
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

function updateStokSistem(select) {
    const row = select.closest('.item-row');
    const option = select.options[select.selectedIndex];
    row.querySelector('.item-stok-sistem').value = option.dataset.stok || '-';
    row.querySelector('.item-selisih').value = '-';
}

function updateSelisih(input) {
    const row = input.closest('.item-row');
    const stokSistemText = row.querySelector('.item-stok-sistem').value;
    if (stokSistemText === '-') return;
    const stokSistem = parseInt(stokSistemText);
    const stokFisik = parseInt(input.value) || 0;
    const selisih = stokFisik - stokSistem;
    row.querySelector('.item-selisih').value = (selisih >= 0 ? '+' : '') + selisih;
}

function updateSubmitBtn() {
    document.getElementById('submit-btn').disabled = document.querySelectorAll('.item-row').length === 0;
}
</script>
@endpush
@endsection
