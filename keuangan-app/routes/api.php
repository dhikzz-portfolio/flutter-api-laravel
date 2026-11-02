<?php

use App\Http\Controllers\Api\V1\Admin\AdminDashboardController;
use App\Http\Controllers\Api\V1\Admin\BarangKeluarController;
use App\Http\Controllers\Api\V1\Admin\DistributorController;
use App\Http\Controllers\Api\V1\Admin\KategoriController;
use App\Http\Controllers\Api\V1\Admin\KoreksiStokController;
use App\Http\Controllers\Api\V1\Admin\PembelianController;
use App\Http\Controllers\Api\V1\Admin\ProdukController;
use App\Http\Controllers\Api\V1\Admin\RiwayatStokController;
use App\Http\Controllers\Api\V1\Auth\ApiAuthController;
use App\Http\Controllers\Api\V1\Kasir\KasirDashboardController;
use App\Http\Controllers\Api\V1\Kasir\PembeliController;
use App\Http\Controllers\Api\V1\Kasir\PenjualanController;
use App\Http\Controllers\Api\V1\Kasir\ProdukController as KasirProduk;
use App\Http\Controllers\Api\V1\Owner\LaporanController;
use App\Http\Controllers\Api\V1\Owner\OwnerDashboardController;
use App\Http\Controllers\Api\V1\Owner\UserController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes — Fin-Ku v1
|--------------------------------------------------------------------------
| Prefix /api/v1. Autentikasi memakai Bearer token (Laravel Sanctum).
| Endpoint privat memakai middleware auth:sanctum + role:<...>.
*/

Route::prefix('v1')->group(function () {

    // =============================================
    // PUBLIC: AUTH
    // =============================================
    Route::post('auth/login', [ApiAuthController::class, 'login'])
        ->middleware('throttle:10,1');

    // =============================================
    // PRIVATE: AUTH
    // =============================================
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('auth/logout', [ApiAuthController::class, 'logout']);
        Route::get('auth/me', [ApiAuthController::class, 'me']);
    });

    // =============================================
    // KASIR
    // =============================================
    Route::middleware(['auth:sanctum', 'role:kasir'])->prefix('kasir')->group(function () {
        Route::get('dashboard', [KasirDashboardController::class, 'index']);
        Route::get('produk', [KasirProduk::class, 'index']);
        Route::get('penjualan', [PenjualanController::class, 'index']);
        Route::post('penjualan', [PenjualanController::class, 'store']);
        Route::get('penjualan/{sale}', [PenjualanController::class, 'show']);
        Route::post('penjualan/{sale}/batal', [PenjualanController::class, 'batal']);
        Route::get('pembeli', [PembeliController::class, 'index']);
        Route::post('pembeli', [PembeliController::class, 'store']);
        Route::put('pembeli/{pembeli}', [PembeliController::class, 'update']);
    });

    // =============================================
    // ADMIN
    // =============================================
    Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
        Route::get('dashboard', [AdminDashboardController::class, 'index']);

        // Pembelian
        Route::get('pembelian', [PembelianController::class, 'index']);
        Route::post('pembelian', [PembelianController::class, 'store']);
        Route::post('pembelian/{pembelian}/batal', [PembelianController::class, 'batal']);

        // Distributor
        Route::get('distributor', [DistributorController::class, 'index']);
        Route::post('distributor', [DistributorController::class, 'store']);
        Route::put('distributor/{distributor}', [DistributorController::class, 'update']);

        // Produk
        Route::get('produk', [ProdukController::class, 'index']);
        Route::post('produk', [ProdukController::class, 'store']);
        Route::put('produk/{produk}', [ProdukController::class, 'update']);

        // Kategori
        Route::get('kategori', [KategoriController::class, 'index']);
        Route::post('kategori', [KategoriController::class, 'store']);
        Route::put('kategori/{kategori}', [KategoriController::class, 'update']);

        // Barang Keluar
        Route::get('barang-keluar', [BarangKeluarController::class, 'index']);
        Route::post('barang-keluar', [BarangKeluarController::class, 'store']);

        // Koreksi Stok
        Route::get('koreksi-stok', [KoreksiStokController::class, 'index']);
        Route::post('koreksi-stok', [KoreksiStokController::class, 'store']);

        // Riwayat Stok
        Route::get('riwayat-stok', [RiwayatStokController::class, 'index']);
    });

    // =============================================
    // OWNER
    // =============================================
    Route::middleware(['auth:sanctum', 'role:owner'])->prefix('owner')->group(function () {
        Route::get('dashboard', [OwnerDashboardController::class, 'index']);

        // Data (read-only)
        Route::get('produk', [ProdukController::class, 'index']);
        Route::get('kategori', [KategoriController::class, 'index']);
        Route::get('barang-keluar', [BarangKeluarController::class, 'index']);
        Route::get('riwayat-stok', [RiwayatStokController::class, 'index']);

        // Laporan
        Route::get('laporan', [LaporanController::class, 'index']);
        Route::get('laporan/export-excel', [LaporanController::class, 'exportExcel']);
        Route::get('laporan/export-pdf', [LaporanController::class, 'exportPdf']);

        // User management
        Route::get('user', [UserController::class, 'index']);
        Route::post('user', [UserController::class, 'store']);
        Route::put('user/{user}', [UserController::class, 'update']);
        Route::delete('user/{user}', [UserController::class, 'destroy']);
    });
});
