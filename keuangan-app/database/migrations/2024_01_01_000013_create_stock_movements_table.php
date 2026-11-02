<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('stock_movements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained('products')->restrictOnDelete();
            $table->foreignId('user_id')->constrained('users')->restrictOnDelete();
            $table->enum('jenis', [
                'PEMBELIAN',
                'PENJUALAN',
                'BARANG_KELUAR',
                'KOREKSI',
                'PEMBATALAN_PEMBELIAN',
                'PEMBATALAN_PENJUALAN'
            ]);
            $table->string('referensi_type');
            $table->unsignedBigInteger('referensi_id');
            $table->integer('stok_sebelum');
            $table->integer('jumlah');
            $table->integer('stok_sesudah');
            $table->text('keterangan')->nullable();
            $table->date('tanggal');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('stock_movements');
    }
};
