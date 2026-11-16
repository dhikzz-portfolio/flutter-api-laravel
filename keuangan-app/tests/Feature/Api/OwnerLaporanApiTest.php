<?php

namespace Tests\Feature\Api;

use App\Models\Buyer;
use App\Models\Category;
use App\Models\Product;
use App\Models\Sale;
use App\Models\SaleDetail;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OwnerLaporanApiTest extends TestCase
{
    use RefreshDatabase;

    private function makeOwner(): User
    {
        return User::create([
            'nama' => 'Owner Uji',
            'username' => 'owner-sample',
            'password' => 'password',
            'role' => 'owner',
            'status' => 'aktif',
        ]);
    }

    private function makeSale(User $owner): Sale
    {
        $buyer = Buyer::create(['nama' => 'Toko Uji']);
        $kategori = Category::create(['nama' => 'Sembako', 'status' => 'aktif']);
        $produk = Product::create([
            'nama' => 'Beras Uji 5kg',
            'category_id' => $kategori->id,
            'harga_jual' => 100000,
            'stok' => 10,
            'stok_minimum' => 2,
            'hpp_rata_rata' => 60000,
            'status' => 'aktif',
        ]);

        $sale = Sale::create([
            'invoice' => 'INV-UJI-001',
            'buyer_id' => $buyer->id,
            'user_id' => $owner->id,
            'tanggal' => now()->toDateString(),
            'total' => 100000,
            'status' => 'active',
        ]);

        SaleDetail::create([
            'sale_id' => $sale->id,
            'product_id' => $produk->id,
            'harga_jual' => 100000,
            'jumlah' => 1,
            'hpp_per_unit' => 60000,
            'hpp_total' => 60000,
            'subtotal' => 100000,
        ]);

        return $sale;
    }

    public function test_laporan_menghitung_penjualan_hpp_dan_laba(): void
    {
        $owner = $this->makeOwner();
        $this->makeSale($owner);

        $response = $this->actingAs($owner, 'sanctum')
            ->getJson('/api/v1/owner/laporan?year='.now()->year);

        $response->assertOk()
            ->assertJsonPath('data.total_penjualan', 100000)
            ->assertJsonPath('data.total_hpp', 60000)
            ->assertJsonPath('data.laba_kotor', 40000)
            ->assertJsonCount(1, 'data.penjualan')
            ->assertJsonCount(12, 'data.monthly_data');
    }

    public function test_export_excel_mengembalikan_file_xlsx(): void
    {
        $owner = $this->makeOwner();
        $this->makeSale($owner);

        $response = $this->actingAs($owner, 'sanctum')
            ->get('/api/v1/owner/laporan/export-excel?year='.now()->year);

        $response->assertOk()
            ->assertHeader('content-type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

        $this->assertStringStartsWith('PK', $response->streamedContent());
    }

    public function test_export_pdf_mengembalikan_file_pdf(): void
    {
        $owner = $this->makeOwner();
        $this->makeSale($owner);

        $response = $this->actingAs($owner, 'sanctum')
            ->get('/api/v1/owner/laporan/export-pdf?year='.now()->year);

        $response->assertOk()
            ->assertHeader('content-type', 'application/pdf');

        $this->assertStringStartsWith('%PDF', $response->getContent());
    }
}
