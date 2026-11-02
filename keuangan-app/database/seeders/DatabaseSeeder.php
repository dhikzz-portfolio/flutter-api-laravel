<?php

namespace Database\Seeders;

use App\Models\AuditLog;
use App\Models\Buyer;
use App\Models\Category;
use App\Models\Distributor;
use App\Models\Product;
use App\Models\Purchase;
use App\Models\PurchaseDetail;
use App\Models\Sale;
use App\Models\SaleDetail;
use App\Models\StockAdjustment;
use App\Models\StockAdjustmentDetail;
use App\Models\StockMovement;
use App\Models\StockOut;
use App\Models\StockOutDetail;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Stempel waktu untuk nomor invoice, supaya invoice tetap unik
     * walau seeder dijalankan berulang kali.
     */
    private string $stamp;

    public function run(): void
    {
        $this->stamp = now()->format('YmdHis');
        $year = now()->year;

        $this->seedUsers();
        $users = User::all()->keyBy('username');

        $this->seedCategories();
        $this->seedDistributors();
        $this->seedBuyers();
        $this->seedProducts();
        $products = Product::orderBy('id')->get()->values();

        $this->seedPurchases($year, $users, $products);
        $this->seedSales($year, $users, $products);
        $this->seedStockOuts($year, $users, $products);
        $this->seedAdjustments($year, $users, $products);
        $this->seedExtraAuditLogs($year, $users);
    }

    // =====================================================================
    // Master data
    // =====================================================================

    private function seedUsers(): void
    {
        $users = [
            // [nama, username, role, status]
            ['Owner Utama', 'owner', 'owner', 'aktif'],
            ['Owner Cabang', 'owner.cabang', 'owner', 'aktif'],
            ['Admin Utama', 'admin', 'admin', 'aktif'],
            ['Admin Gudang', 'admin.gudang', 'admin', 'aktif'],
            ['Admin Pembelian', 'admin.pembelian', 'admin', 'aktif'],
            ['Admin Stok', 'admin.stok', 'admin', 'aktif'],
            ['Kasir Satu', 'kasir', 'kasir', 'aktif'],
            ['Kasir Dua', 'kasir.dua', 'kasir', 'aktif'],
            ['Kasir Tiga', 'kasir.tiga', 'kasir', 'aktif'],
            ['Kasir Empat', 'kasir.empat', 'kasir', 'aktif'],
            ['Kasir Lima', 'kasir.lima', 'kasir', 'aktif'],
            ['Kasir Enam', 'kasir.enam', 'kasir', 'nonaktif'],
        ];

        foreach ($users as [$nama, $username, $role, $status]) {
            User::updateOrCreate(
                ['username' => $username],
                ['nama' => $nama, 'role' => $role, 'status' => $status, 'password' => 'password'],
            );
        }
    }

    private function seedCategories(): void
    {
        $categories = [
            'Makanan Ringan',
            'Minuman',
            'Sembako',
            'Bumbu Dapur',
            'Perawatan Diri',
            'Pembersih Rumah Tangga',
            'Alat Tulis',
            'Susu & Produk Bayi',
            'Bekal & Kaleng',
            'Frozen Food',
        ];

        foreach ($categories as $nama) {
            Category::updateOrCreate(['nama' => $nama], ['status' => 'aktif']);
        }
    }

    private function seedDistributors(): void
    {
        $distributors = [
            ['PT Sumber Pangan Nusantara', '081234567001', 'Jl. Industri Raya No. 12, Kawasan Industri Pulogadung, Jakarta Timur'],
            ['CV Makmur Jaya', '081234567002', 'Jl. Pasar Baru No. 45, Bandung, Jawa Barat'],
            ['PT Distribusi Sejahtera', '081234567003', 'Jl. Raya Cikarang No. 88, Bekasi, Jawa Barat'],
            ['UD Sinar Rejeki', '081234567004', 'Jl. Gajah Mada No. 21, Semarang, Jawa Tengah'],
            ['PT Grosir Sentosa', '081234567005', 'Jl. Pemuda No. 7, Surabaya, Jawa Timur'],
            ['CV Cahaya Abadi', '081234567006', 'Jl. Diponegoro No. 33, Yogyakarta, DI Yogyakarta'],
            ['PT Mitra Niaga', '081234567007', 'Jl. Ahmad Yani No. 99, Medan, Sumatera Utara'],
            ['UD Berkah Utama', '081234567008', 'Jl. Sultan Agung No. 5, Solo, Jawa Tengah'],
            ['PT Pangan Prima', '081234567009', 'Jl. Margonda Raya No. 150, Depok, Jawa Barat'],
            ['CV Tani Makmur', '081234567010', 'Jl. Raya Bogor Km 26, Cimanggis, Depok'],
        ];

        foreach ($distributors as [$nama, $telepon, $alamat]) {
            Distributor::updateOrCreate(['nama' => $nama], ['telepon' => $telepon, 'alamat' => $alamat]);
        }
    }

    private function seedBuyers(): void
    {
        $buyers = [
            ['Toko Berkah Jaya', '082198765001', 'Jl. Kenanga No. 10, Depok, Jawa Barat'],
            ['Warung Bu Sari', '082198765002', 'Jl. Melati No. 22, Depok, Jawa Barat'],
            ['Mini Market Sentosa', '082198765003', 'Jl. Margonda No. 88, Depok, Jawa Barat'],
            ['Toko Amanah', '082198765004', 'Jl. Nusantara No. 5, Bogor, Jawa Barat'],
            ['Koperasi Karyawan Sejahtera', '082198765005', 'Jl. Industri No. 40, Cibinong, Jawa Barat'],
            ['Warung Pak Budi', '082198765006', 'Jl. Anggrek No. 17, Depok, Jawa Barat'],
            ['Toko Sumber Rezeki', '082198765007', 'Jl. Sawangan Raya No. 9, Depok, Jawa Barat'],
            ['Kantin Sekolah Harapan', '082198765008', 'Jl. Pendidikan No. 1, Depok, Jawa Barat'],
            ['Warung Ibu Tini', '082198765009', 'Jl. Cempaka No. 30, Depok, Jawa Barat'],
            ['Toko Maju Bersama', '082198765010', 'Jl. Raya Cinere No. 55, Depok, Jawa Barat'],
            ['Warung Ko Ali', '082198765011', 'Jl. Mawar No. 12, Depok, Jawa Barat'],
            ['Toko Rukun Sentosa', '082198765012', 'Jl. Merpati No. 8, Sukmajaya, Depok'],
        ];

        foreach ($buyers as [$nama, $telepon, $alamat]) {
            Buyer::updateOrCreate(['nama' => $nama], ['telepon' => $telepon, 'alamat' => $alamat]);
        }
    }

    private function seedProducts(): void
    {
        // [nama, kategori, harga_jual, harga_beli_awal, stok_awal, stok_minimum]
        $products = [
            ['Keripik Singkong Balado 200g', 'Makanan Ringan', 15000, 9200, 80, 10],
            ['Wafer Cokelat Isi 10', 'Makanan Ringan', 18000, 11500, 60, 10],
            ['Teh Kotak 250ml (1 Dus)', 'Minuman', 65000, 50000, 40, 5],
            ['Air Mineral 600ml (1 Dus)', 'Minuman', 55000, 38000, 50, 5],
            ['Kopi Sachet Isi 10', 'Minuman', 12000, 8200, 100, 15],
            ['Beras Premium 5kg', 'Sembako', 72000, 61000, 45, 5],
            ['Gula Pasir 1kg', 'Sembako', 17500, 14000, 90, 15],
            ['Minyak Goreng 2L', 'Sembako', 38000, 32000, 55, 10],
            ['Kecap Manis 520ml', 'Bumbu Dapur', 24000, 18500, 70, 10],
            ['Saus Sambal 340ml', 'Bumbu Dapur', 15000, 10500, 75, 10],
            ['Shampoo Sachet Isi 12', 'Perawatan Diri', 21000, 16000, 65, 10],
            ['Sabun Mandi Batang', 'Perawatan Diri', 5000, 3400, 120, 20],
            ['Deterjen Bubuk 800g', 'Pembersih Rumah Tangga', 24000, 18500, 60, 10],
            ['Pensil 2B (Pack 12)', 'Alat Tulis', 18000, 11500, 50, 10],
            ['Susu Formula 400g', 'Susu & Produk Bayi', 85000, 69000, 25, 5],
        ];

        $categories = Category::whereIn('nama', collect($products)->pluck(1)->unique())->get()->keyBy('nama');

        foreach ($products as [$nama, $kategori, $hargaJual, $hargaBeli, $stok, $stokMinimum]) {
            // stok & hpp di-reset ke nilai awal setiap kali seeder dijalankan,
            // supaya data transaksi hasil seed selalu konsisten.
            Product::updateOrCreate(
                ['nama' => $nama],
                [
                    'category_id' => $categories[$kategori]->id,
                    'harga_jual' => $hargaJual,
                    'stok' => $stok,
                    'stok_minimum' => $stokMinimum,
                    'hpp_rata_rata' => $hargaBeli,
                    'status' => 'aktif',
                ],
            );
        }
    }

    // =====================================================================
    // Transaksi
    // =====================================================================

    private function seedPurchases(int $year, $users, $products): void
    {
        // [bulan, hari, index distributor, items: [index produk, jumlah, harga beli]]
        $plan = [
            [6, 2, 0, [[0, 15, 9200], [1, 10, 11500]]],
            [6, 5, 2, [[2, 10, 50000], [3, 15, 38000]]],
            [6, 9, 4, [[5, 12, 61000], [6, 20, 14000]]],
            [6, 14, 1, [[7, 14, 32000], [8, 10, 18500]]],
            [6, 20, 3, [[9, 12, 10500], [10, 10, 16000]]],
            [6, 26, 5, [[11, 30, 3400], [12, 10, 18500]]],
            [7, 3, 6, [[13, 15, 11500], [14, 6, 69000]]],
            [7, 8, 7, [[0, 12, 9400], [4, 15, 8200]]],
            [7, 13, 8, [[5, 10, 62500], [7, 10, 32500]]],
            [7, 18, 9, [[2, 8, 51000], [3, 10, 39500], [6, 15, 14200]]],
            [7, 23, 0, [[8, 10, 19000], [9, 10, 10800]]],
            [7, 28, 1, [[10, 10, 16200], [12, 8, 18800], [11, 20, 3500]]],
        ];

        $distributors = Distributor::orderBy('id')->get()->values();
        $admins = ['admin', 'admin.gudang', 'admin.pembelian', 'admin.stok'];

        foreach ($plan as $no => [$bulan, $hari, $distIdx, $items]) {
            $tanggal = Carbon::create($year, $bulan, $hari, 9 + ($no % 6), ($no * 7) % 60);
            $user = $users[$admins[$no % count($admins)]];

            $this->createPurchase($no + 1, $tanggal, $user, $distributors[$distIdx], $items, $products);
        }
    }

    private function createPurchase(int $no, Carbon $tanggal, User $user, Distributor $distributor, array $items, $products): void
    {
        $total = 0;
        $details = [];

        foreach ($items as [$idx, $jumlah, $hargaBeli]) {
            $subtotal = $hargaBeli * $jumlah;
            $details[] = ['product' => $products[$idx], 'jumlah' => $jumlah, 'hargaBeli' => $hargaBeli, 'subtotal' => $subtotal];
            $total += $subtotal;
        }

        $invoice = 'INV-PUR-' . $this->stamp . '-' . str_pad((string) $no, 3, '0', STR_PAD_LEFT);

        $purchase = Purchase::create([
            'invoice' => $invoice,
            'distributor_id' => $distributor->id,
            'user_id' => $user->id,
            'tanggal' => $tanggal->toDateString(),
            'total' => $total,
            'status' => 'active',
        ]);

        foreach ($details as $d) {
            PurchaseDetail::create([
                'purchase_id' => $purchase->id,
                'product_id' => $d['product']->id,
                'harga_beli' => $d['hargaBeli'],
                'jumlah' => $d['jumlah'],
                'subtotal' => $d['subtotal'],
            ]);

            // Hitung HPP weighted average, sama seperti logika PembelianController.
            $product = $d['product'];
            $product->refresh();

            $stokSebelum = $product->stok;
            $stokLama = $product->stok;
            $hppLama = (float) $product->hpp_rata_rata;
            $totalStok = $stokLama + $d['jumlah'];

            $hppBaru = $totalStok > 0
                ? (($stokLama * $hppLama) + ($d['jumlah'] * $d['hargaBeli'])) / $totalStok
                : $d['hargaBeli'];
            $hppBaru = round($hppBaru, 2);

            $product->increment('stok', $d['jumlah']);
            $product->update(['hpp_rata_rata' => $hppBaru]);

            StockMovement::create([
                'product_id' => $product->id,
                'user_id' => $user->id,
                'jenis' => 'PEMBELIAN',
                'referensi_type' => 'App\\Models\\Purchase',
                'referensi_id' => $purchase->id,
                'stok_sebelum' => $stokSebelum,
                'jumlah' => $d['jumlah'],
                'stok_sesudah' => $stokSebelum + $d['jumlah'],
                'keterangan' => 'Pembelian invoice ' . $invoice . ' - HPP baru: Rp ' . number_format($hppBaru, 0, ',', '.'),
                'tanggal' => $tanggal->toDateString(),
            ]);
        }

        $this->logAudit($user, 'Transaksi Pembelian', 'Pembelian', $purchase->id,
            "Pembelian {$invoice} - Total: Rp " . number_format($total, 0, ',', '.'), $tanggal);
    }

    private function seedSales(int $year, $users, $products): void
    {
        // [bulan, hari, index pembeli, username kasir, items: [index produk, jumlah]]
        $plan = [
            [8, 2, 0, 'kasir', [[0, 3], [2, 1]]],
            [8, 4, 1, 'kasir.dua', [[5, 1], [6, 2]]],
            [8, 6, 2, 'kasir.tiga', [[3, 2]]],
            [8, 9, 3, 'kasir', [[1, 2], [4, 3]]],
            [8, 12, 4, 'kasir.empat', [[7, 1], [8, 1]]],
            [8, 15, 5, 'kasir.lima', [[9, 2], [11, 4]]],
            [8, 18, 6, 'kasir', [[12, 1], [10, 1]]],
            [8, 22, 7, 'kasir.dua', [[13, 2]]],
            [8, 26, 8, 'kasir.tiga', [[14, 1], [0, 2]]],
            [9, 1, 9, 'kasir.empat', [[6, 3], [3, 1]]],
            [9, 3, 10, 'kasir.lima', [[2, 2], [1, 1]]],
            [9, 5, 11, 'kasir', [[5, 1]]],
            [9, 8, 0, 'kasir.dua', [[8, 2], [9, 1], [11, 2]]],
            [9, 10, 2, 'kasir.tiga', [[7, 2], [12, 1]]],
            [9, 12, 4, 'kasir.empat', [[4, 4], [0, 1]]],
            [9, 14, 6, 'kasir.lima', [[10, 2], [13, 1]]],
            [9, 16, 8, 'kasir', [[14, 1], [5, 1], [6, 2]]],
            [9, 18, 10, 'kasir.dua', [[3, 3], [1, 2], [9, 1]]],
        ];

        $buyers = Buyer::orderBy('id')->get()->values();

        foreach ($plan as $no => [$bulan, $hari, $buyerIdx, $kasirUsername, $items]) {
            $tanggal = Carbon::create($year, $bulan, $hari, 10 + ($no % 6), ($no * 11) % 60);
            $user = $users[$kasirUsername];

            $this->createSale($no + 1, $tanggal, $user, $buyers[$buyerIdx], $items, $products);
        }
    }

    private function createSale(int $no, Carbon $tanggal, User $user, Buyer $buyer, array $items, $products): void
    {
        $total = 0;
        $details = [];

        foreach ($items as [$idx, $jumlah]) {
            $product = $products[$idx];
            $product->refresh();

            if ($product->stok < $jumlah) {
                throw new \RuntimeException("Stok {$product->nama} tidak mencukupi untuk data seed.");
            }

            $hargaJual = (float) $product->harga_jual;
            $hppPerUnit = (float) $product->hpp_rata_rata;

            $details[] = [
                'product' => $product,
                'harga_jual' => $hargaJual,
                'jumlah' => $jumlah,
                'hpp_per_unit' => $hppPerUnit,
                'hpp_total' => $hppPerUnit * $jumlah,
                'subtotal' => $hargaJual * $jumlah,
            ];

            $total += $hargaJual * $jumlah;
        }

        $invoice = 'INV-SAL-' . $this->stamp . '-' . str_pad((string) $no, 3, '0', STR_PAD_LEFT);

        $sale = Sale::create([
            'invoice' => $invoice,
            'buyer_id' => $buyer->id,
            'user_id' => $user->id,
            'tanggal' => $tanggal->toDateString(),
            'total' => $total,
            'status' => 'active',
        ]);

        foreach ($details as $d) {
            SaleDetail::create([
                'sale_id' => $sale->id,
                'product_id' => $d['product']->id,
                'harga_jual' => $d['harga_jual'],
                'jumlah' => $d['jumlah'],
                'hpp_per_unit' => $d['hpp_per_unit'],
                'hpp_total' => $d['hpp_total'],
                'subtotal' => $d['subtotal'],
            ]);

            $product = $d['product'];
            $stokSebelum = $product->stok;
            $product->decrement('stok', $d['jumlah']);

            StockMovement::create([
                'product_id' => $product->id,
                'user_id' => $user->id,
                'jenis' => 'PENJUALAN',
                'referensi_type' => 'App\\Models\\Sale',
                'referensi_id' => $sale->id,
                'stok_sebelum' => $stokSebelum,
                'jumlah' => -$d['jumlah'],
                'stok_sesudah' => $stokSebelum - $d['jumlah'],
                'keterangan' => 'Penjualan invoice ' . $invoice,
                'tanggal' => $tanggal->toDateString(),
            ]);
        }

        $this->logAudit($user, 'Transaksi Penjualan', 'Penjualan', $sale->id,
            "Penjualan {$invoice} - Total: Rp " . number_format($total, 0, ',', '.'), $tanggal);
    }

    private function seedStockOuts(int $year, $users, $products): void
    {
        // [bulan, hari, username admin, keterangan, items: [index produk, jenis, jumlah, keterangan item]]
        $plan = [
            [8, 10, 'admin', 'Barang rusak karena kemasan penyok', [
                [0, 'RUSAK', 3, 'Kemasan penyok saat transportasi'],
                [3, 'RUSAK', 2, 'Botol penyok tidak layak jual'],
            ]],
            [8, 20, 'admin.gudang', 'Pemusnahan produk kedaluwarsa', [
                [4, 'EXPIRED', 5, 'Lewat tanggal kedaluwarsa'],
                [8, 'EXPIRED', 3, null],
            ]],
            [9, 3, 'admin', 'Diberikan untuk sampling promosi', [
                [11, 'DIBERIKAN', 6, 'Sampling di acara bazar'],
                [0, 'DIBERIKAN', 2, null],
            ]],
            [9, 7, 'admin.pembelian', 'Pemusnahan barang rusak gudang', [
                [1, 'RUSAK', 4, 'Produk kadaluarsa'],
                [10, 'EXPIRED', 2, null],
            ]],
            [9, 12, 'admin.gudang', 'Pengeluaran lain-lain', [
                [12, 'LAINNYA', 1, 'Untuk tes kualitas'],
                [6, 'DIBERIKAN', 3, 'Donasi komunitas sekitar'],
                [9, 'RUSAK', 2, 'Label rusak'],
            ]],
        ];

        foreach ($plan as $no => [$bulan, $hari, $adminUsername, $keterangan, $items]) {
            $tanggal = Carbon::create($year, $bulan, $hari, 11 + ($no % 4), ($no * 13) % 60);
            $user = $users[$adminUsername];

            $stockOut = StockOut::create([
                'user_id' => $user->id,
                'tanggal' => $tanggal->toDateString(),
                'keterangan' => $keterangan,
            ]);

            foreach ($items as [$idx, $jenis, $jumlah, $ketItem]) {
                $product = $products[$idx];
                $product->refresh();

                $stokSebelum = $product->stok;

                StockOutDetail::create([
                    'stock_out_id' => $stockOut->id,
                    'product_id' => $product->id,
                    'jenis' => $jenis,
                    'jumlah' => $jumlah,
                    'keterangan' => $ketItem,
                ]);

                $product->decrement('stok', $jumlah);

                StockMovement::create([
                    'product_id' => $product->id,
                    'user_id' => $user->id,
                    'jenis' => 'BARANG_KELUAR',
                    'referensi_type' => 'App\\Models\\StockOut',
                    'referensi_id' => $stockOut->id,
                    'stok_sebelum' => $stokSebelum,
                    'jumlah' => -$jumlah,
                    'stok_sesudah' => $stokSebelum - $jumlah,
                    'keterangan' => 'Barang keluar: ' . $jenis,
                    'tanggal' => $tanggal->toDateString(),
                ]);
            }

            $this->logAudit($user, 'Barang Keluar', 'Barang Keluar', $stockOut->id,
                "Barang keluar: {$keterangan} (" . count($items) . ' produk)', $tanggal);
        }
    }

    private function seedAdjustments(int $year, $users, $products): void
    {
        $deltas = [2, -1, 3, -2, 1, -3, 4, 2, -1, 1, -2, 3];
        $alasan = [
            'Stok opname bulanan',
            'Penyesuaian hasil stock count',
            'Barang hilang diduga dicuri',
            'Perbedaan hitung fisik dengan sistem',
        ];

        // Dua dokumen koreksi, masing-masing memuat 6 produk.
        $headers = [
            ['bulan' => 9, 'hari' => 20, 'username' => 'admin', 'offset' => 0],
            ['bulan' => 9, 'hari' => 25, 'username' => 'admin.gudang', 'offset' => 6],
        ];

        foreach ($headers as $no => $h) {
            $tanggal = Carbon::create($year, $h['bulan'], $h['hari'], 14 + $no, ($no * 17) % 60);
            $user = $users[$h['username']];

            $adjustment = StockAdjustment::create([
                'user_id' => $user->id,
                'tanggal' => $tanggal->toDateString(),
            ]);

            for ($i = 0; $i < 6; $i++) {
                $idx = $h['offset'] + $i;
                $product = $products[$idx];
                $product->refresh();

                $stokSebelum = $product->stok;
                $stokFisik = max(0, $stokSebelum + $deltas[$idx]);
                $selisih = $stokFisik - $stokSebelum;

                StockAdjustmentDetail::create([
                    'adjustment_id' => $adjustment->id,
                    'product_id' => $product->id,
                    'stok_sebelum' => $stokSebelum,
                    'stok_fisik' => $stokFisik,
                    'selisih' => $selisih,
                    'alasan' => $alasan[$idx % count($alasan)],
                ]);

                $product->update(['stok' => $stokFisik]);

                StockMovement::create([
                    'product_id' => $product->id,
                    'user_id' => $user->id,
                    'jenis' => 'KOREKSI',
                    'referensi_type' => 'App\\Models\\StockAdjustment',
                    'referensi_id' => $adjustment->id,
                    'stok_sebelum' => $stokSebelum,
                    'jumlah' => $selisih,
                    'stok_sesudah' => $stokFisik,
                    'keterangan' => 'Koreksi stok: ' . $alasan[$idx % count($alasan)],
                    'tanggal' => $tanggal->toDateString(),
                ]);
            }

            $this->logAudit($user, 'Koreksi Stok', 'Koreksi Stok', $adjustment->id,
                'Koreksi stok dengan 6 produk', $tanggal);
        }
    }

    private function seedExtraAuditLogs(int $year, $users): void
    {
        // [username, aktivitas, module, referensi_id, keterangan]
        $logs = [
            ['owner', 'Login Sistem', 'Autentikasi', null, 'Login berhasil dari 127.0.0.1'],
            ['owner', 'Logout Sistem', 'Autentikasi', null, 'Logout berhasil'],
            ['owner', 'Mengunduh Laporan', 'Laporan', null, 'Mengunduh laporan laba/rugi format Excel'],
            ['admin', 'Menambah Produk', 'Master Data', null, 'Menambah produk baru ke katalog'],
            ['admin', 'Mengubah Produk', 'Master Data', null, 'Mengubah harga jual produk'],
            ['admin', 'Menambah Kategori', 'Master Data', null, 'Menambah kategori produk baru'],
            ['owner', 'Menambah User', 'Pengaturan', null, 'Menambah user kasir baru'],
            ['admin', 'Melihat Detail Penjualan', 'Penjualan', null, 'Membuka detail transaksi penjualan'],
            ['admin', 'Melihat Detail Pembelian', 'Pembelian', null, 'Membuka detail transaksi pembelian'],
            ['owner', 'Login Gagal', 'Autentikasi', null, 'Percobaan login dengan password salah'],
        ];

        $base = Carbon::create($year, 9, 15, 8, 0);

        foreach ($logs as $i => [$username, $aktivitas, $module, $refId, $keterangan]) {
            $this->logAudit(
                $users[$username],
                $aktivitas,
                $module,
                $refId,
                $keterangan,
                $base->copy()->addHours($i),
            );
        }
    }

    // =====================================================================
    // Helper
    // =====================================================================

    private function logAudit(User $user, string $aktivitas, string $module, ?int $refId, string $keterangan, Carbon $tanggal): void
    {
        $log = new AuditLog([
            'user_id' => $user->id,
            'aktivitas' => $aktivitas,
            'module' => $module,
            'referensi_id' => $refId,
            'keterangan' => $keterangan,
        ]);

        // AuditLog punya $timestamps = false, jadi created_at diisi manual.
        $log->created_at = $tanggal->copy()->setTime(16, 30);
        $log->save();
    }
}
