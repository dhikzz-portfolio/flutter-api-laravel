<?php

use App\Http\Controllers\Auth\AuthController;
use Illuminate\Support\Facades\Route;

// =============================================
// AUTH ROUTES
// =============================================
Route::get('/login', [AuthController::class, 'showLogin'])->name('login')->middleware('guest');
Route::post('/login', [AuthController::class, 'login'])->middleware('guest');
Route::post('/logout', [AuthController::class, 'logout'])->name('logout')->middleware('auth');

// =============================================
// KASIR ROUTES
// =============================================
Route::middleware(['auth', 'role:kasir'])->prefix('kasir')->name('kasir.')->group(function () {
    // Dashboard
    Route::get('/dashboard', [\App\Http\Controllers\Kasir\DashboardController::class, 'index'])->name('dashboard');

    // Penjualan
    Route::resource('penjualan', \App\Http\Controllers\Kasir\PenjualanController::class)->except(['show']);
    Route::get('penjualan/{sale}/nota', [\App\Http\Controllers\Kasir\PenjualanController::class, 'nota'])->name('penjualan.nota');
    Route::post('penjualan/{sale}/batal', [\App\Http\Controllers\Kasir\PenjualanController::class, 'batal'])->name('penjualan.batal');

    // Pembeli
    Route::resource('pembeli', \App\Http\Controllers\Kasir\PembeliController::class)->except(['show', 'destroy']);
});

// =============================================
// ADMIN ROUTES
// =============================================
Route::middleware(['auth', 'role:admin'])->prefix('admin')->name('admin.')->group(function () {
    // Dashboard
    Route::get('/dashboard', [\App\Http\Controllers\Admin\DashboardController::class, 'index'])->name('dashboard');

    // Pembelian
    Route::resource('pembelian', \App\Http\Controllers\Admin\PembelianController::class)->except(['show']);
    Route::post('pembelian/{pembelian}/batal', [\App\Http\Controllers\Admin\PembelianController::class, 'batal'])->name('pembelian.batal');

    // Distributor
    Route::resource('distributor', \App\Http\Controllers\Admin\DistributorController::class)->except(['show', 'destroy']);

    // Produk
    Route::resource('produk', \App\Http\Controllers\Admin\ProdukController::class)->except(['show', 'destroy']);

    // Kategori
    Route::resource('kategori', \App\Http\Controllers\Admin\KategoriController::class)->except(['show', 'destroy']);

    // Barang Keluar
    Route::resource('barang-keluar', \App\Http\Controllers\Admin\BarangKeluarController::class)->except(['show', 'edit', 'update']);

    // Koreksi Stok
    Route::resource('koreksi-stok', \App\Http\Controllers\Admin\KoreksiStokController::class)->except(['show', 'edit', 'update']);

    // Riwayat Stok
    Route::get('riwayat-stok', [\App\Http\Controllers\Admin\RiwayatStokController::class, 'index'])->name('riwayat-stok.index');
});

// =============================================
// OWNER ROUTES
// =============================================
Route::middleware(['auth', 'role:owner'])->prefix('owner')->name('owner.')->group(function () {
    // Dashboard
    Route::get('/dashboard', [\App\Http\Controllers\Owner\DashboardController::class, 'index'])->name('dashboard');

    // Produk (view only)
    Route::get('produk', [\App\Http\Controllers\Owner\ProdukController::class, 'index'])->name('produk.index');

    // Kategori (view only)
    Route::get('kategori', [\App\Http\Controllers\Owner\KategoriController::class, 'index'])->name('kategori.index');

    // Barang Keluar (view only)
    Route::get('barang-keluar', [\App\Http\Controllers\Owner\BarangKeluarController::class, 'index'])->name('barang-keluar.index');

    // Riwayat Stok (view only)
    Route::get('riwayat-stok', [\App\Http\Controllers\Owner\RiwayatStokController::class, 'index'])->name('riwayat-stok.index');

    // Laporan Laba/Rugi
    Route::get('laporan', [\App\Http\Controllers\Owner\LaporanController::class, 'index'])->name('laporan.index');
    Route::get('laporan/export-excel', [\App\Http\Controllers\Owner\LaporanController::class, 'exportExcel'])->name('laporan.export-excel');
    Route::get('laporan/export-pdf', [\App\Http\Controllers\Owner\LaporanController::class, 'exportPdf'])->name('laporan.export-pdf');

    // User Management
    Route::resource('user', \App\Http\Controllers\Owner\UserController::class)->except(['show']);
});

// =============================================
// DEFAULT REDIRECT
// =============================================
Route::get('/', function () {
    if (auth()->check()) {
        return match (auth()->user()->role) {
            'kasir' => redirect()->route('kasir.dashboard'),
            'admin' => redirect()->route('admin.dashboard'),
            'owner' => redirect()->route('owner.dashboard'),
            default => redirect()->route('login'),
        };
    }
    return redirect()->route('login');
});
