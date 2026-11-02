<?php

namespace Tests\Feature\Api;

use App\Models\Buyer;
use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class KasirApiTest extends TestCase
{
    use RefreshDatabase;

    private function makeUser(array $attrs = []): User
    {
        return User::create(array_merge([
            'nama' => 'Tester',
            'username' => 'kasir-sample',
            'password' => 'password',
            'role' => 'kasir',
            'status' => 'aktif',
        ], $attrs));
    }

    public function test_kasir_endpoint_butuh_autentikasi(): void
    {
        $this->getJson('/api/v1/kasir/produk')->assertStatus(401);
        $this->getJson('/api/v1/kasir/dashboard')->assertStatus(401);
    }

    public function test_rollain_role_tidak_bisa_akses_kasir(): void
    {
        $admin = $this->makeUser(['username' => 'admin-sample', 'role' => 'admin']);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/kasir/produk');

        $response->assertStatus(403);
    }

    public function test_kasir_melihat_hanya_produk_aktif_dengan_stok(): void
    {
        $kasir = $this->makeUser();
        $kategori = Category::create(['nama' => 'Minuman', 'status' => 'aktif']);

        Product::create(['nama' => 'Teh Kotak', 'category_id' => $kategori->id, 'harga_jual' => 65000, 'stok' => 10, 'stok_minimum' => 5, 'hpp_rata_rata' => 0, 'status' => 'aktif']);
        Product::create(['nama' => 'Teh Nonaktif', 'category_id' => $kategori->id, 'harga_jual' => 60000, 'stok' => 10, 'stok_minimum' => 5, 'hpp_rata_rata' => 0, 'status' => 'nonaktif']);
        Product::create(['nama' => 'Teh Habis', 'category_id' => $kategori->id, 'harga_jual' => 60000, 'stok' => 0, 'stok_minimum' => 5, 'hpp_rata_rata' => 0, 'status' => 'aktif']);

        $response = $this->actingAs($kasir, 'sanctum')->getJson('/api/v1/kasir/produk');

        $response->assertStatus(200);
        $this->assertSame(1, count($response->json('data')));
        $this->assertSame('Teh Kotak', $response->json('data.0.nama'));
        $this->assertSame('Minuman', $response->json('data.0.category.nama'));
    }

    public function test_buat_penjualan_menyimpan_data_dan_memotong_stok(): void
    {
        $kasir = $this->makeUser();
        $kategori = Category::create(['nama' => 'Sembako', 'status' => 'aktif']);
        $produk = Product::create(['nama' => 'Beras 5kg', 'category_id' => $kategori->id, 'harga_jual' => 72000, 'stok' => 10, 'stok_minimum' => 5, 'hpp_rata_rata' => 60000, 'status' => 'aktif']);
        $pembeli = Buyer::create(['nama' => 'Toko Alpha']);

        $response = $this->actingAs($kasir, 'sanctum')->postJson('/api/v1/kasir/penjualan', [
            'buyer_id' => $pembeli->id,
            'items' => [
                ['product_id' => $produk->id, 'jumlah' => 2],
            ],
        ]);

        $response->assertStatus(201);

        $this->assertDatabaseHas('sales', ['buyer_id' => $pembeli->id, 'total' => '144000.00', 'status' => 'active']);
        $this->assertDatabaseHas('sale_details', ['product_id' => $produk->id, 'harga_jual' => '72000.00', 'jumlah' => 2, 'subtotal' => '144000.00']);

        $this->assertSame(8, $produk->fresh()->stok);
    }

    public function test_penjualan_tolak_jumlah_lebih_dari_stok(): void
    {
        $kasir = $this->makeUser();
        $kategori = Category::create(['nama' => 'Sembako', 'status' => 'aktif']);
        $produk = Product::create(['nama' => 'Gula 1kg', 'category_id' => $kategori->id, 'harga_jual' => 17500, 'stok' => 3, 'stok_minimum' => 5, 'hpp_rata_rata' => 14000, 'status' => 'aktif']);
        $pembeli = Buyer::create(['nama' => 'Toko Beta']);

        $response = $this->actingAs($kasir, 'sanctum')->postJson('/api/v1/kasir/penjualan', [
            'buyer_id' => $pembeli->id,
            'items' => [
                ['product_id' => $produk->id, 'jumlah' => 10],
            ],
        ]);

        $response->assertStatus(422);
        $this->assertDatabaseCount('sales', 0);
    }
}
