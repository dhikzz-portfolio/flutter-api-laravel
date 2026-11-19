# Naskah Presentasi Aplikasi Fin-Ku

---

## 1. Pembuka

> *"Assalamualaikum warahmatullahi wabarakatuh. Selamat pagi/siang, Bapak/Ibu [nama pengajar/penguji].*  
> *Perkenalkan, saya [nama siswa] dari [kelas].*  
> *Hari ini saya akan mempresentasikan aplikasi mobile yang saya kembangkan dengan bahasa pemrograman Dart dan framework Flutter, yaitu **Fin-Ku**, yaitu aplikasi Sistem Informasi Keuangan berbasis mobile untuk usaha.*  
> *Aplikasi ini dirancang agar kasir, admin, maupun owner bisa memantau penjualan, stok, dan laba dalam satu aplikasi yang ringkas. Mari kita mulai."*

---

## 2. Pengenalan Aplikasi (Tujuan & Latar Belakang)

> *"Fin-Ku adalah aplikasi mobile yang membantu usaha dalam mengelola keuangan, penjualan, stok barang, hingga laporan keuangan.*  
> *Banyak sistem informasi keuangan saat ini berbasis web desktop, namun di lapangan seringkali diperlukan akses mobile yang praktis, misalnya kasir yang langsung mencatat penjualan di meja kasir, atau owner yang ingin mengecek laba kotor kapan saja.*  
> *Oleh karena itu, saya mengembangkan Fin-Ku sebagai aplikasi mobile yang menyediakan fitur utama seperti pencatatan penjualan, manajemen pembeli, pengelolaan produk dan katalog, pemantauan stok, penerimaan barang masuk melalui pembelian, pendataan barang keluar, koreksi stok, serta laporan laba/rugi yang bisa diekspor ke Excel dan PDF.*  
> *Dengan kata lain, aplikasi ini mencakup workflow mulai dari pembelian barang dari distributor, penjualan kepada pembeli, hingga pelaporan keuangan untuk owner."*

---

## 3. Arsitektur & Teknologi yang Digunakan

> *"Aplikasi ini dibangun menggunakan Flutter, yaitu SDK dari Google untuk membuat aplikasi mobile dalam satu codebase.*  
> *Semua antarmuka ditulis dengan widget-material, tema disesuaikan agar terlihat konsisten dengan identitas Fin-Ku, yaitu warna indigo sebagai warna utama brand, dilengkapi kartu putih dengan border tipis, serta tombol yang responsif.*  
> *Komunikasi dengan server menggunakan HTTP, dan sesi login disimpan di perangkat menggunakan penyimpanan terenkripsi agar credentials tidak disimpan dalam bentuk plain text.*  
> *Di sisi arsitektur, aplikasi ini menggunakan pola yang memisahkan antara fitur dan logika, sehingga menu untuk kasir, admin, dan owner disesuaikan dengan peran masing-masing pengguna.*  
> *Salah satu bagian penting adalah sistem autentikasi yang mengecek session saat aplikasi dibuka, sehingga pengguna langsung dibawa ke layar login atau langsung masuk ke menu sesuai role-nya."*

---

## 4. Alur Login dan Hak Akses Berdasarkan Role

> *"Saat aplikasi pertama kali dibuka, tampilan yang muncul adalah splash screen dengan logo Fin-Ku dan animasi loading kecil, sementara aplikasi mengecek apakah ada sesi yang tersimpan.*  
> *Jika belum ada sesi yang valid, user akan diarahkan ke halaman login.*  
> *Di halaman login, terdapat form username dan password yang diambil dari akun yang sama seperti aplikasi web Fin-Ku. User juga bisa melihat password saat mengetik dengan tombol mata, dan ada tooltip serta keterangan keamanan sesi.*  
> *Sebagai contoh praktis, saya bisa mencoba memasukkan username `admin` dan password `123456`, kemudian menekan tombol login. Jika kredensial benar, aplikasi langsung menyimpan sesi dan membuka menu sesuai role. Jika salah, akan muncul pesan error dan form siap diisi kembali. Contoh lain, untuk role kasir saya bisa mencoba username `kasir01` dengan password `kasir1234` supaya bisa melihat batasan akses kasir pada menu penjualan dan pembeli.*  
> *Setelah login berhasil, aplikasi langsung menyimpan token dan membuka menu utama sesuai role pengguna.*  
> *Fin-Ku memiliki tiga role besar, yaitu **kasir**, **admin**, dan **owner**.*  
> *Peran kasir umumnya fokus pada transaksi penjualan dan data pembeli.*  
> *Peran admin bertanggung jawab atas pengelolaan produk, kategori, distributor, pembelian, barang keluar, koreksi stok, dan riwayat stok.*  
> *Sementara owner memiliki akses baca ke data produk dan stok, serta fitur laporan laba/rugi dan manajemen user.*  
> *Pembatasan ini penting agar setiap pengguna hanya melihat dan mengelola data yang sesuai dengan tanggung jawabnya."*

---

## 5. Format Tampilan: Desktop, Web, dan Mobile

> *"Salah satu hal yang saya perhatikan dalam pengembangan ini adalah responsivitas tampilan.*  
> *Fin-Ku dirancang agar di layar lebar, seperti tablet atau browser desktop, memiliki sidebar di sebelah kiri yang bersifat tetap.*  
> *Sidebar tersebut menggunakan warna gelap dengan teks terang, mirip dengan gaya antarmuka aplikasi web Laravel yang menggunakan Tailwind CSS.*  
> *Ketika dibuka di layar sempit seperti ponsel, sidebar tidak lagi tampil tetap, melainkan diubah menjadi drawer yang bisa dibuka melalui tombol menu.*  
> *Dengan begitu, aplikasi tetap nyaman digunakan baik di perangkat mobile maupun di tampilan yang lebih lebar.*  
> *Sidebar juga menampilkan profil pengguna di bagian bawah, berisi inisial nama dan peran, serta tombol logout yang akan meminta konfirmasi sebelum keluar."*
> *Sebagai contoh, setelah login dengan akun `admin`, di sidebar akan terlihat nama administrator dan peran Admin. Jika saya menekan tombol logout, aplikasi akan menampilkan konfirmasi seperti `Yakin ingin keluar?` dan setelah dikonfirmasi, sesi akan dibatalkan serta layar login kembali muncul.*  

---

## 6. Dashboard Kasir

> *"Mari kita masuk ke dalam fitur per role. Untuk role kasir, dashboard yang muncul adalah Dashboard Kasir.*  
> *Di sini, kasir bisa melihat ringkasan hari ini, yaitu jumlah penjualan hari ini, total transaksi atau omzet hari ini, dan jumlah produk yang stoknya sudah di bawah minimum.*  
> *Selain ringkasan, dashboard kasir juga menampilkan grafik garis penjualan 7 hari terakhir.*  
> *Grafik ini membantu kasir melihat fluktuasi omzet dari hari ke hari secara visual.*  
> *Pada bagian aksi cepat, kasir bisa langsung menekan tombol Transaksi Baru untuk memulai penjualan, atau tombol Data Pembeli untuk menambah atau mengedit data pembeli.*  
> *Dengan demikian, kasir tidak perlu mencari-cari menu untuk memulai pekerjaan sehari-hari."*

---

## 7. Transaksi Penjualan / POS

> *"Fitur paling sering digunakan oleh kasir adalah Transaksi Penjualan atau yang sering kita sebut POS, Point of Sale.*  
> *Di layar ini, kasir memilih pembeli terlebih dahulu dari daftar yang sudah ada. Jika pembeli belum ada, pembeli bisa ditambahkan melalui menu Data Pembeli.*  
> *Setelah pembeli dipilih, kasir mencari produk aktif yang tersedia menggunakan kolom pencarian produk.*  
> *Saat produk dipilih, produk akan masuk ke keranjang dengan jumlah awal satu.*  
> *Kasir bisa menambah jumlah dengan tombol tambah, mengurangi dengan tombol kurang, mengetik jumlah secara manual, atau menghapus item dari keranjang.*  
> *Sebagai contoh, setelah memilih pembeli `Budi Santoso`, saya mencari produk `Espresso Kopi`, lalu tekan produk tersebut. Keranjang akan terisi jumlah `1` dengan harga `25000`. Jika pembeli membeli `3`, saya tekan tombol tambah dua kali atau ketik jumlah `3` langsung, sehingga harga item menjadi `75000`. Jika salah, saya tekan kurang atau hapus item, dan total keseluruhan akan ikut berubah.*  
> *Setiap penyesuaian jumlah akan langsung memperbarui harga per item dan total keseluruhan.*  
> *Stok produk juga ditampilkan agar kasir tahu ketersediaan barang.*  
> *Saat tombol simpan ditekan, transaksi dikirim ke server beserta detail produk dan pembeli.*  
> *Hanya produk aktif yang bisa dipilih, dan jika stok habis, sistem akan menolak penambahan ke keranjang.*  
> *Dengan demikian, kasir tidak perlu repot menghitung total secara manual, dan risk of salah input bisa dikurangi."*

---

## 8. Data Pembeli

> *"Data pembeli merupakan fitur pendukung penting dalam aplikasi ini, karena dalam penjualan biasanya kita perlu mencatat siapa pembeli.*  
> *Di layar Data Pembeli, kasir bisa melihat daftar pembeli yang sudah pernah ditambahkan.*  
> *Setiap pembeli menampilkan nama, nomor telepon, dan alamat jika tersedia.*  
> *Kasir bisa mencari pembeli berdasarkan nama atau telepon, lalu menambah pembeli baru atau mengedit pembeli yang sudah ada.*  
> *Form pembeli terdiri dari nama wajib diisi, serta telepon dan alamat yang opsional.*  
> *Sebagai contoh, saya bisa mengisi Nama dengan `Budi Santoso`, Nomor Telepon dengan `081234567890`, dan Alamat dengan `Jl. Merdeka No. 10, Bandung`. Jika hanya nama yang diisi, pembeli tetap bisa disimpan dan muncul di daftar pembeli.*  
> *Data pembeli ini akan muncul kembali ketika kasir mencatat transaksi penjualan, sehingga pembeli tidak perlu diulang-ulang."*

---

## 9. Detail Transaksi dan Nota

> *"Setelah transaksi selesai, kasir bisa membuka detail transaksi dari daftar penjualan.*  
> *Layar detail menampilkan informasi seperti nomor invoice, tanggal, nama pembeli, dan nama kasir yang membuat.*  
> *Di dalam detail, terdapat daftar produk beserta jumlah, harga jual, dan subtotalnya.*  
> *Di bagian bawah, ditampilkan total transaksi secara lebih besar.*  
> *Status transaksi juga ditandai dengan chip Aktif atau Dibatalkan, sesuai kondisi sesungguhnya.*  
> *Jika transaksi masih aktif, kasir bisa membatalkannya setelah konfirmasi.*  
> *Saat pembatalan dikonfirmasi, server akan menyesuaikan stok dan status transaksi.*  
> *Fitur penting lainnya adalah cetak nota. Kasir bisa menekan tombol cetak untuk mencetak nota transaksi.*  
> *Fitur ini memanfaatkan printer yang tersambung di perangkat, sehingga nota bisa langsung diberikan kepada pembeli."*

---

## 10. Dashboard Admin

> *"Sekarang kita beralih ke role admin. Dashboard admin memiliki fokus berbeda, yaitu memantau pembelian dan pergerakan stok.*  
> *Di sini admin bisa melihat pembelian hari ini, barang masuk, barang keluar, dan jumlah produk yang berada di bawah stok minimum.*  
> *Jika ada produk yang stoknya menipis, admin bisa langsung melihat produk tersebut dalam daftar peringatan stok minimum.*  
> *Selain ringkasan, dashboard admin juga menampilkan grafik pergerakan stok 7 hari terakhir, yang menunjukkan barang masuk dan barang keluar per hari.*  
> *Ini membantu admin memahami pola pergerakan stok, misalnya kapan barang paling sering keluar, atau apakah barang masuk cukup mengimbangi penjualan."*

---

## 11. Manajemen Produk dan Katalog

> *"Admin memiliki hak penuh atas produk dan katalog.*  
> *Di menu Produk, admin bisa melihat daftar produk yang sudah dibuat, lengkap dengan nama, kategori, harga jual, stok, dan status aktif atau nonaktif.*  
> *Produk bisa dikelompokkan melalui kategori, sehingga lebih mudah dicari dan dikelola.*  
> *Admin bisa menambah produk baru, yaitu dengan menekan tombol Produk Baru, yang akan membuka form tambah produk.*  
> *Form ini meminta nama produk, kategori, harga jual, stok awal, dan stok minimum.*  
> *Sebagai contoh, saat menambah produk baru, saya bisa mengisi Nama Produk dengan `Espresso Kopi`, pilih Kategori `Minuman`, harga jual `25000`, stok awal `50`, dan stok minimum `10`. Setelah disimpan, produk ini akan muncul di daftar produk dan bisa dipilih saat transaksi.*  
> *Admin juga bisa membuka form edit untuk mengubah informasi produk, seperti nama, kategori, harga jual, stok minimum, dan status.*  
> *Saat produk dinonaktifkan, produk tidak akan muncul lagi dalam pencarian transaksi.*  
> *Di sisi owner, fitur produk hanya berupa tampilan baca saja, karena hak edit produk sengaja dibatasi agar hanya admin yang mengelola katalog secara langsung."*

---

## 12. Kategori

> *"Fitur Kategori digunakan untuk mengelompokkan produk agar lebih terstruktur.*  
> *Admin bisa melihat daftar kategori yang aktif atau nonaktif, serta jumlah produk di dalamnya.*  
> *Admin juga bisa menambah kategori baru dan mengedit kategori yang sudah ada, termasuk mengubah statusnya menjadi nonaktif bila kategori tersebut tidak lagi digunakan.*  
> *Sebagai contoh, saya bisa menambah kategori baru dengan nama `Minuman`, kemudian mengeditnya menjadi `Minuman Hangat` jika perlu, atau menonaktifkannya bila tidak digunakan. Kategori yang sudah dipakai produk tidak bisa dihapus agar data produk tetap rapi.*  
> *Kategori yang sudah dipakai oleh produk tidak bisa dihapus sembarangan karena akan mempengaruhi data produk yang merujuk kepadanya.*  
> *Owner hanya dapat melihat kategori dalam mode baca tanpa bisa mengubahnya."*

---

## 13. Manajemen Distributor

> *"Untuk proses pembelian, distributor atau supplier berperan penting.*  
> *Di menu Distributor, admin bisa mengelola data distributor, yaitu menambah distributor baru dan mengedit distributor yang sudah ada.*  
> *Form distributor meminta nama, telepon, dan alamat.*  
> *Sebagai contoh, saya bisa menambah distributor dengan Nama `PT Sang Nyawa Sukses`, Telepon `081299887766`, dan Alamat `Jl. Supplier No. 25, Jakarta`. Distributor ini nanti akan muncul saat membuat pembelian baru.*  
> *Setiap distributor yang muncul di daftar juga akan menampilkan jumlah transaksi pembelian yang pernah dilakukan kepadanya.*  
> *Dengan begitu, admin bisa lebih mudah menelusuri supplier mana yang sering digunakan dalam pembelian barang."*

---

## 14. Pembelian dan Pembelian Baru

> *"Menu Pembelian adalah fitur untuk mencatat barang yang masuk dari distributor.*  
> *Admin bisa melihat daftar pembelian yang pernah dibuat, lengkap dengan nomor invoice, nama distributor, tanggal, dan total nilai pembelian.*  
> *Status pembelian juga ditandai dengan chip Aktif atau Dibatalkan.*  
> *Admin bisa mencari pembelian berdasarkan invoice atau nama distributor, serta menyaring berdasarkan rentang tanggal.*  
> *Untuk membuat pembelian baru, admin menekan tombol Pembelian Baru, lalu memilih distributor dan memilih produk beserta jumlah dan harga beli.*  
> *Sebagai contoh, saya memilih distributor `PT Sang Nyawa Sukses`, lalu menambahkan produk `Espresso Kopi` dengan jumlah `20` dan harga beli `18000`. Jika saya menambahkan lagi produk `Kopi Kapal Api` jumlah `10` harga beli `15000`, total pembelian akan terhitung otomatis. Setelah disimpan, stok produk bertambah sesuai jumlah yang dimasukkan.*  
> *Setiap produk yang dimasukkan akan ditambahkan ke keranjang pembelian, dan total akan diperbarui secara otomatis.*  
> *Pada form pembelian, harga beli bisa disesuaikan, dan sistem menyimpan data beserta detail produknya.*  
> *Pembelian yang sudah dibuat bisa dibuka detailnya, dan jika perlu, admin bisa membatalkannya setelah konfirmasi.*  
> *Pembatalan ini penting karena stok dan harga pokok harus dikembalikan ke kondisi semula agar data keuangan tetap akurat."*

---

## 15. Barang Keluar

> *"Fitur Barang Keluar digunakan untuk mencatat pengeluaran barang yang tidak terkait penjualan.*  
> *Misalnya, barang yang rusak, kedaluwarsa, diberikan kepada pihak lain, atau keluar untuk keperluan lain dengan keterangan tertentu.*  
> *Admin bisa melihat daftar barang keluar, menyaring berdasarkan rentang tanggal, dan membuka detail masing-masing dokumen.*  
> *Untuk membuat barang keluar baru, admin menekan tombol Catat Keluar, lalu memilih beberapa produk beserta jumlah dan jenis keluarannya.*  
> *Sebagai contoh, saya memilih produk `Espresso Kopi`, jumlah `2`, jenis `Rusak`, lalu menambahkan keterangan `Kemasan sobek`. Jika stok saat ini hanya `5`, form akan menolak jika jumlah yang dimasukkan lebih dari `5`, agar data stok tetap akurat.*  
> *Jenis yang tersedia biasanya seperti Rusak, Expired, Diberikan, dan Lainnya.*  
> *Admin juga bisa menambahkan keterangan umum maupun keterangan per item.*  
> *Form ini akan mencegah entry jika jumlah melebihi stok yang tersedia, agar data stok tetap realistis."*

---

## 16. Koreksi Stok

> *"Fitur Koreksi Stok atau stok opname digunakan ketika stok di lapangan berbeda dengan data di sistem.*  
> *Admin bisa melihat daftar koreksi stok yang sudah dibuat, beserta selisih total per dokumen.*  
> *Di dalam form koreksi baru, admin bisa memilih produk dan memasukkan selisih yang ditemukan saat pencacahan ulang.*  
> *Misalnya, jika stok sistem menunjukkan 50, tetapi persediaan fisik hanya 48, maka selisih yang dimasukkan adalah -2.*  
> *Form koreksi juga bisa mencantumkan alasan atau keterangan tambahan.*  
> *Sebagai contoh, saya bisa mencantumkan alasan seperti `Selisih pencacahan tanggal 10` atau `Barang rusak tidak tercatat`. Dengan alasan yang jelas, riwayat stok dan laporan keuangan lebih mudah ditelusuri nanti.*  
> *Fitur ini sangat penting dalam manajemen stok karena stok yang tidak akurat bisa menyebabkan overselling atau kesalahan dalam laporan keuangan."*

---

## 17. Riwayat Stok

> *"Untuk memantau perubahan stok dari waktu ke waktu, admin bisa membuka Riwayat Stok.*  
> *Di layar ini, admin bisa melihat urutan peristiwa yang mempengaruhi stok, seperti barang masuk dari pembelian, barang keluar karena penjualan, barang rusak, expired, diberikan, atau koreksi stok.*  
> *Riwayat stok bisa disaring berdasarkan rentang tanggal sehingga admin bisa menelusuri pergerakan barang pada periode tertentu.*  
> *Fitur ini membantu admin memahami apakah stok masuk konsisten, kapan barang keluar paling banyak, dan apakah ada anomali yang perlu diperiksa."*

---

## 18. Dashboard Owner

> *"Beralih ke role owner, tampilan yang muncul adalah Dashboard Owner.*  
> *Owner tidak perlu mencatat transaksi operasional seperti kasir atau admin, melainkan mengawasi performa usaha secara keseluruhan.*  
> *Di dashboard ini, owner bisa memilih bulan dan tahun, lalu melihat ringkasan periode tersebut, yaitu total penjualan, total HPP, dan laba kotor.*  
> *Sebagai contoh, saya bisa memilih Bulan `Januari` dan Tahun `2026`, lalu menekan tombol lihat ringkasan. Jika saya tidak memilih bulan, aplikasi akan menampilkan ringkasan untuk seluruh tahun berjalan. Contoh hasilnya, total penjualan misalnya `15.000.000`, total HPP `9.500.000`, dan laba kotor `5.500.000` yang ditampilkan dalam warna yang menunjukkan untung.*  
> *Laba kotor dihitung sebagai selisih antara total penjualan dengan total HPP untuk periode yang dipilih.*  
> *Jika laba kotor bernilai positif, nilainya ditampilkan dalam warna yang menunjukkan untung; jika negatif, ditampilkan dalam warna yang menunjukkan rugi.*  
> *Dashboard owner juga dilengkapi grafik garis bulanan yang menunjukkan perbandingan penjualan dan laba kotor selama setahun.*  
> *Dengan demikian, owner bisa menilai tren keuangan dan memutuskan apakah perlu pengaturan harga, pengurangan biaya pembelian, atau strategi penjualan lainnya."*

---

## 19. Laporan Laba/Rugi

> *"Fitur laporan laba/rugi adalah salah satu fitur paling penting bagi owner, karena disini owner bisa melihat detail keuangan secara lebih lengkap.*  
> *Laporan ini bisa difilter berdasarkan tahun dan bulan.*  
> *Sebagai contoh, saya bisa memilih Tahun `2026` dan Bulan `Mei` untuk melihat laporan laba rugi bulan Mei saja. Jika saya hanya memilih Tahun `2026` tanpa bulan, laporan akan menampilkan seluruh bulan dalam tahun tersebut. Dari sini saya bisa menekan tombol ekspor ke Excel atau PDF untuk menyimpan atau mengirim laporan.*  
> *Jika bulan tidak dipilih, laporan akan menampilkan seluruh tahun.*  
> *Di dalam laporan, owner bisa melihat ringkasan total penjualan, total HPP, dan laba kotor untuk periode yang dipilih.*  
> *Laporan juga menampilkan grafik bulanan penjualan dan laba kotor, serta tabel breakdown bulanan yang memuat penjualan, HPP, dan laba kotor per bulan.*  
> *Selain itu, terdapat daftar detail transaksi yang menunjukkan tanggal, invoice, pembeli, total, HPP, dan laba per transaksi.*  
> *Fitur yang sangat membantu owner adalah ekspor laporan ke Excel atau PDF.*  
> *Dengan ekspor, owner bisa menyimpan laporan di perangkat atau mengirimkannya ke pihak lain tanpa harus mencetak langsung dari aplikasi."*

---

## 20. Manajemen User

> *"Karena Fin-Ku dirancang untuk digunakan oleh beberapa orang dengan peran berbeda, owner juga memiliki fitur Manajemen User.*  
> *Di layar ini, owner bisa melihat daftar user yang terdaftar di aplikasi, lengkap dengan nama, username, role, dan status aktif atau nonaktif.*  
> *Owner bisa mencari user berdasarkan nama atau username, dan menyaring berdasarkan role, yaitu kasir, admin, atau owner.*  
> *Owner juga bisa menambah user baru, mengedit user yang sudah ada, maupun menghapus user.*  
> *Form tambah atau edit user meminta nama, username, password minimal enam karakter, role, dan status.*  
> *Sebagai contoh, saat menambah user kasir baru, saya bisa mengisi Nama `Siti Rahayu`, Username `kasir02`, Password `kasir02`, lalu pilih Role `kasir` dan Status `Aktif`. Jika mengedit user yang sudah ada dan tidak ingin mengubah password, kolom password dikosongkan saja. Owner tidak bisa menghapus akun pribadinya sendiri.*  
> *Saat mengedit, password bisa dikosongkan jika owner tidak ingin mengubahnya.*  
> *Owner tidak bisa menghapus akun mereka sendiri untuk mencegah penguncian diri secara tidak sengaja.*  
> *Dengan fitur ini, owner memiliki kendali penuh terhadap siapa yang bisa login ke aplikasi."*

---

## 21. Halaman Profil dan Pengaturan Server

> *"Di bagian pengaturan, semua peran memiliki halaman Profil & Sesi, yang biasa berada di paling bawah sidebar.*  
> *Di halaman ini, pengguna bisa melihat identitas akun yang sedang login, seperti nama, username, role, dan status.*  
> *Halaman ini juga menyediakan fitur yang sangat praktis, yaitu pengaturan alamat server API.*  
> *Karena aplikasi mobile ini terhubung ke server, kadang-kadang alamat server perlu disesuaikan, terutama jika aplikasi dijalankan bersama server lokal atau server pengembangan.*  
> *Pengguna bisa mengubah base URL, menyimpannya, mengembalikannya ke default, atau mencoba koneksi untuk memastikan server dapat dijangkau dan sesi masih valid.*  
> *Sebagai contoh, jika server lokal berjalan di `http://192.168.1.10:8000`, saya bisa mengubah base URL menjadi alamat itu, lalu menekan tombol simpan dan mencoba koneksi untuk memastikan aplikasi bisa berkomunikasi dengan server. Jika ingin kembali ke pengaturan awal, saya bisa menekan tombol kembali ke default.*  
> *Di halaman yang sama, pengguna juga bisa logout setelah konfirmasi, sehingga sesi akan dicabut di server dan token lokal akan dihapus."*

---

## 22. Keamanan dan Pengalaman Pengguna

> *"Selain fitur fungsional, saya juga memperhatikan beberapa hal terkait keamanan dan kenyamanan pengguna.*  
> *Sesi disimpan dalam penyimpanan terenkripsi, sehingga token login tidak mudah dibaca dari perangkat.*  
> *Jika server melewatkan response 401, artinya sesi tidak valid, aplikasi akan otomatis logout dan memberitahu pengguna agar login kembali.*  
> *Form login dan form-form lain juga dilengkapi validasi sederhana, pesan error, dan loading indicator, sehingga pengguna tahu apa yang terjadi saat data sedang diproses atau terjadi masalah koneksi.*  
> *Tampilan aplikasi juga konsisten, dengan kartu, tombol, dan tipografi yang seragam di semua halaman. Warna digunakan secara terstruktur, misalnya warna utama untuk aksi penting, warna biru untuk informasi, warna hijau untuk kondisi baik, dan warna merah untuk kondisi error atau pembatalan."*

---

## 23. Kesimpulan

> *"Sebagai kesimpulan, Fin-Ku adalah aplikasi mobile Sistem Informasi Keuangan yang dirancang untuk mendukung operasional usaha mulai dari kasir hingga owner.*  
> *Aplikasi ini menyediakan login berbasis role, dashboard yang relevan untuk tiap peran, transaksi penjualan yang praktis, manajemen pembeli, pengelolaan produk dan kategori, pencatatan pembelian dari distributor, penanganan barang keluar, koreksi stok, riwayat stok, serta laporan laba/rugi yang bisa diekspor ke Excel dan PDF.*  
> *Dengan begitu, Fin-Ku tidak hanya membantu pencatatan sehari-hari, tetapi juga memberikan pemantauan keuangan dan stok yang lebih terstruktur.*  
> *Bagi pengembangan selanjutnya, fitur seperti integrasi printer nota yang lebih lengkap, notifikasi, hingga penyimpanan data offline bisa ditambahkan agar aplikasi semakin membantu pengguna di lapangan.*  
> *Demikian yang dapat saya sampaikan. Terima kasih atas perhatian Bapak/Ibu, dan saya siap menerima pertanyaan."*

---

*Dokumen ini disusun sebagai naskah presentasi siswa untuk aplikasi Flutter Fin-Ku.*
