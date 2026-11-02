@extends('layouts.app')
@section('title', 'Transaksi Penjualan Baru')
@section('page-title', 'Transaksi Penjualan Baru')
@section('content')

<div class="rounded-xl border border-gray-200 bg-white shadow-sm">
    <div class="border-b border-gray-100 p-4 lg:p-6">
        <h3 class="text-lg font-semibold text-gray-800">Form Transaksi Penjualan</h3>
    </div>

    <form method="POST" action="{{ route('kasir.penjualan.store') }}" class="p-4 lg:p-6" id="sale-form">
        @csrf

        <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
            {{-- Info Transaksi --}}
            <div class="lg:col-span-1">
                <div class="space-y-4">
                    <div>
                        <label class="mb-1 block text-sm font-medium text-gray-700">Pembeli <span class="text-red-500">*</span></label>
                        <select name="buyer_id" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                            <option value="">Pilih Pembeli</option>
                            @foreach($buyers as $buyer)
                                <option value="{{ $buyer->id }}" {{ old('buyer_id') == $buyer->id ? 'selected' : '' }}>{{ $buyer->nama }}</option>
                            @endforeach
                        </select>
                        @error('buyer_id')<p class="mt-1 text-xs text-red-600">{{ $message }}</p>@enderror
                    </div>

                    <div class="rounded-lg bg-gray-50 p-4">
                        <p class="text-sm text-gray-500">Tanggal</p>
                        <p class="font-medium text-gray-800">{{ now()->translatedFormat('l, d M Y') }}</p>
                    </div>

                    <div class="rounded-lg bg-gray-50 p-4">
                        <p class="text-sm text-gray-500">Total</p>
                        <p id="total-display" class="text-2xl font-bold text-indigo-600">Rp 0</p>
                    </div>
                </div>
            </div>

            {{-- Items --}}
            <div class="lg:col-span-2">
                <div class="mb-3 flex items-center justify-between">
                    <h4 class="text-sm font-semibold text-gray-700">Detail Produk</h4>
                    <button type="button" onclick="addItem()" class="inline-flex items-center gap-1 rounded-lg bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600 hover:bg-gray-200">
                        <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
                        Tambah Item
                    </button>
                </div>

                @error('items')<div class="mb-3 rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-red-700">{{ $message }}</div>@enderror

                <div id="items-container" class="space-y-3">
                    {{-- Items will be added dynamically --}}
                </div>

                <div id="empty-items" class="rounded-lg border-2 border-dashed border-gray-200 p-8 text-center">
                    <p class="text-sm text-gray-400">Klik "Tambah Item" untuk memulai transaksi</p>
                </div>
            </div>
        </div>

        <div class="mt-6 flex justify-end gap-3 border-t border-gray-100 pt-6">
            <a href="{{ route('kasir.penjualan.index') }}" class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50">Batal</a>
            <button type="submit" id="submit-btn" class="rounded-lg bg-indigo-600 px-6 py-2 text-sm font-semibold text-white hover:bg-indigo-700" disabled>Simpan Transaksi</button>
        </div>
    </form>
</div>

@push('scripts')
<script>
const products = @json($products);
let itemIndex = 0;

function addItem() {
    const container = document.getElementById('items-container');
    const emptyMsg = document.getElementById('empty-items');
    emptyMsg.classList.add('hidden');

    const html = `
        <div class="item-row rounded-lg border border-gray-200 p-4" data-index="${itemIndex}">
            <div class="flex items-start gap-3">
                <div class="flex-1 space-y-3">
                    <div>
                        <select name="items[${itemIndex}][product_id]" required onchange="updatePrice(this)" class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                            <option value="">Pilih Produk</option>
                            ${products.map(p => `<option value="${p.id}" data-harga="${p.harga_jual}" data-stok="${p.stok}">${p.nama} (Stok: ${p.stok})</option>`).join('')}
                        </select>
                    </div>
                    <div class="grid grid-cols-3 gap-3">
                        <div>
                            <label class="mb-1 block text-xs text-gray-500">Harga Jual</label>
                            <input type="text" class="item-harga rounded-lg border border-gray-200 bg-gray-50 px-3 py-2 text-sm text-gray-500" readonly value="Rp 0">
                        </div>
                        <div>
                            <label class="mb-1 block text-xs text-gray-500">Jumlah <span class="text-red-500">*</span></label>
                            <input type="number" name="items[${itemIndex}][jumlah]" min="1" required onchange="updateSubtotal(this)" onkeyup="updateSubtotal(this)" class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" placeholder="0">
                        </div>
                        <div>
                            <label class="mb-1 block text-xs text-gray-500">Subtotal</label>
                            <input type="text" class="item-subtotal rounded-lg border border-gray-200 bg-gray-50 px-3 py-2 text-sm text-gray-500" readonly value="Rp 0">
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
    const container = document.getElementById('items-container');
    if (container.children.length === 0) {
        document.getElementById('empty-items').classList.remove('hidden');
    }
    updateTotal();
    updateSubmitBtn();
}

function updatePrice(select) {
    const row = select.closest('.item-row');
    const option = select.options[select.selectedIndex];
    const harga = option.dataset.harga || 0;
    const stok = option.dataset.stok || 0;
    row.querySelector('.item-harga').value = 'Rp ' + Number(harga).toLocaleString('id-ID');
    row.querySelector('.item-harga').dataset.rawValue = harga;
    row.querySelector('.item-harga').dataset.stok = stok;
    row.querySelector('input[name*="jumlah"]').value = '';
    row.querySelector('.item-subtotal').value = 'Rp 0';
    updateTotal();
}

function updateSubtotal(input) {
    const row = input.closest('.item-row');
    const harga = parseFloat(row.querySelector('.item-harga').dataset.rawValue) || 0;
    const stok = parseInt(row.querySelector('.item-harga').dataset.stok) || 0;
    const jumlah = parseInt(input.value) || 0;

    if (jumlah > stok) {
        input.setCustomValidity(`Stok tidak cukup. Maks: ${stok}`);
        input.reportValidity();
    } else {
        input.setCustomValidity('');
    }

    const subtotal = harga * jumlah;
    row.querySelector('.item-subtotal').value = 'Rp ' + subtotal.toLocaleString('id-ID');
    updateTotal();
}

function updateTotal() {
    let total = 0;
    document.querySelectorAll('.item-row').forEach(row => {
        const harga = parseFloat(row.querySelector('.item-harga').dataset.rawValue) || 0;
        const jumlah = parseInt(row.querySelector('input[name*="jumlah"]').value) || 0;
        total += harga * jumlah;
    });
    document.getElementById('total-display').textContent = 'Rp ' + total.toLocaleString('id-ID');
}

function updateSubmitBtn() {
    const hasItems = document.querySelectorAll('.item-row').length > 0;
    document.getElementById('submit-btn').disabled = !hasItems;
}
</script>
@endpush
@endsection
