@extends('layouts.app')
@section('title', 'Manajemen User')
@section('page-title', 'Manajemen User')
@section('content')

<div class="rounded-xl border border-gray-200 bg-white shadow-sm">
    <div class="flex flex-wrap items-center justify-between gap-3 border-b border-gray-100 p-4 lg:p-6">
        <form method="GET" class="flex flex-wrap items-center gap-2">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari user..." class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
            <select name="role" class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                <option value="">Semua Role</option>
                <option value="kasir" {{ request('role') === 'kasir' ? 'selected' : '' }}>Kasir</option>
                <option value="admin" {{ request('role') === 'admin' ? 'selected' : '' }}>Admin</option>
                <option value="owner" {{ request('role') === 'owner' ? 'selected' : '' }}>Owner</option>
            </select>
            <button type="submit" class="rounded-lg bg-gray-100 px-3 py-2 text-sm text-gray-600 hover:bg-gray-200">Cari</button>
        </form>
        <button onclick="document.getElementById('modal-add').classList.remove('hidden')" class="inline-flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-semibold text-white hover:bg-indigo-700">
            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
            Tambah User
        </button>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead>
                <tr class="border-b border-gray-100 bg-gray-50 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                    <th class="px-4 py-3 lg:px-6">No</th>
                    <th class="px-4 py-3 lg:px-6">Nama</th>
                    <th class="px-4 py-3 lg:px-6">Username</th>
                    <th class="px-4 py-3 lg:px-6">Role</th>
                    <th class="px-4 py-3 lg:px-6">Status</th>
                    <th class="px-4 py-3 text-right lg:px-6">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-50">
                @forelse($users as $item)
                <tr class="hover:bg-gray-50">
                    <td class="px-4 py-3 lg:px-6 text-gray-400">{{ ($users->currentPage() - 1) * $users->perPage() + $loop->iteration }}</td>
                    <td class="px-4 py-3 font-medium text-gray-800 lg:px-6">{{ $item->nama }}</td>
                    <td class="px-4 py-3 text-gray-500 lg:px-6">{{ $item->username }}</td>
                    <td class="px-4 py-3 lg:px-6">
                        @php
                            $roleColors = ['kasir' => 'bg-blue-50 text-blue-700', 'admin' => 'bg-purple-50 text-purple-700', 'owner' => 'bg-yellow-50 text-yellow-700'];
                        @endphp
                        <span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium {{ $roleColors[$item->role] ?? '' }}">{{ ucfirst($item->role) }}</span>
                    </td>
                    <td class="px-4 py-3 lg:px-6">
                        <span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium {{ $item->status === 'aktif' ? 'bg-green-50 text-green-700' : 'bg-gray-100 text-gray-600' }}">{{ ucfirst($item->status) }}</span>
                    </td>
                    <td class="px-4 py-3 text-right lg:px-6">
                        <div class="flex items-center justify-end gap-1">
                            <button onclick='openEditModal(@json($item))' class="rounded-lg px-3 py-1.5 text-xs font-medium text-indigo-600 hover:bg-indigo-50">Edit</button>
                            @if($item->id !== auth()->id())
                                <form method="POST" action="{{ route('owner.user.destroy', $item) }}" onsubmit="return confirm('Yakin ingin menghapus user ini?')">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="rounded-lg px-3 py-1.5 text-xs font-medium text-red-600 hover:bg-red-50">Hapus</button>
                                </form>
                            @endif
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="6" class="px-6 py-12 text-center text-gray-400">Belum ada data user.</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="border-t border-gray-100 p-4">{{ $users->links() }}</div>
</div>

{{-- Modal Add --}}
<div id="modal-add" class="hidden fixed inset-0 z-50 flex items-center justify-center bg-black/50">
    <div class="mx-4 w-full max-w-md rounded-xl bg-white p-6 shadow-xl">
        <h3 class="mb-4 text-lg font-semibold">Tambah User</h3>
        <form method="POST" action="{{ route('owner.user.store') }}">
            @csrf
            <div class="space-y-4">
                <div>
                    <label class="mb-1 block text-sm font-medium text-gray-700">Nama</label>
                    <input type="text" name="nama" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                </div>
                <div>
                    <label class="mb-1 block text-sm font-medium text-gray-700">Username</label>
                    <input type="text" name="username" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                </div>
                <div>
                    <label class="mb-1 block text-sm font-medium text-gray-700">Password</label>
                    <input type="password" name="password" required minlength="6" class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="mb-1 block text-sm font-medium text-gray-700">Role</label>
                        <select name="role" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                            <option value="kasir">Kasir</option>
                            <option value="admin">Admin</option>
                            <option value="owner">Owner</option>
                        </select>
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-gray-700">Status</label>
                        <select name="status" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                            <option value="aktif">Aktif</option>
                            <option value="nonaktif">Nonaktif</option>
                        </select>
                    </div>
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
    <div class="mx-4 w-full max-w-md rounded-xl bg-white p-6 shadow-xl">
        <h3 class="mb-4 text-lg font-semibold">Edit User</h3>
        <form id="edit-form" method="POST">
            @csrf
            @method('PUT')
            <div class="space-y-4">
                <div>
                    <label class="mb-1 block text-sm font-medium text-gray-700">Nama</label>
                    <input type="text" id="edit-nama" name="nama" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                </div>
                <div>
                    <label class="mb-1 block text-sm font-medium text-gray-700">Username</label>
                    <input type="text" id="edit-username" name="username" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                </div>
                <div>
                    <label class="mb-1 block text-sm font-medium text-gray-700">Password <span class="text-xs text-gray-400">(kosongkan jika tidak diubah)</span></label>
                    <input type="password" name="password" minlength="6" class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="mb-1 block text-sm font-medium text-gray-700">Role</label>
                        <select id="edit-role" name="role" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                            <option value="kasir">Kasir</option>
                            <option value="admin">Admin</option>
                            <option value="owner">Owner</option>
                        </select>
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-gray-700">Status</label>
                        <select id="edit-status" name="status" required class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                            <option value="aktif">Aktif</option>
                            <option value="nonaktif">Nonaktif</option>
                        </select>
                    </div>
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
    document.getElementById('edit-form').action = '{{ url("owner/user") }}/' + item.id;
    document.getElementById('edit-nama').value = item.nama;
    document.getElementById('edit-username').value = item.username;
    document.getElementById('edit-role').value = item.role;
    document.getElementById('edit-status').value = item.status;
    document.getElementById('modal-edit').classList.remove('hidden');
}
</script>
@endpush
@endsection
