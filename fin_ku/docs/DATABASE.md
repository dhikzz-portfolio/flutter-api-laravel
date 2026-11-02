# Database Documentation

## Overview

This Flutter application connects to a Laravel backend with MySQL database. The API endpoints handle all database operations.

## Entity Relationship Overview

### Users Table (Core)
- `id` - Primary Key (Auto-increment)
- `nama` - User full name (String)
- `username` - Unique username (String)
- `email` - Email address (String, unique)
- `email_verified_at` - Email verification timestamp
- `password` - Hashed password (String)
- `role` - User role: `kasir`, `admin`, or `owner` (String)
- `status` - User status: `aktif` or `nonaktif` (String)
- `remember_token` - Remember me token
- `created_at` - Timestamp
- `updated_at` - Timestamp

### Laporan/Reports Table
- `id` - Primary Key (Auto-increment)
- `year` - Report year (Integer)
- `month` - Report month (1-12, nullable for yearly reports)
- `penjualan` - Total sales amount
- `total_penjualan` - Grand total sales
- `total_hpp` - Total Cost of Goods Sold
- `laba_kotor` - Gross profit
- `created_at` - Timestamp
- `updated_at` - Timestamp

### Monthly Report Details
- `id` - Primary Key
- `laporan_id` - Foreign Key to laporans table
- `bulan` - Month number (1-12)
- `penjualan` - Monthly sales
- `hpp` - Monthly cost of goods sold
- `laba` - Monthly profit
- `created_at` - Timestamp

## API-Driven Data Flow

All data operations go through the Laravel API:

### User Management Endpoints
- `GET /api/v1/owner/user?page=&per_page=&search=&role=` - List users with pagination and filtering
- `POST /api/v1/owner/user` - Create new user
- `PUT /api/v1/owner/user/{id}` - Update user
- `DELETE /api/v1/owner/user/{id}` - Delete user

### Laporan/Report Endpoints
- `GET /api/v1/owner/laporan?year=&month=` - Get laporan data with optional year/month filter
- `GET /api/v1/owner/laporan/export-excel` - Export laporan as Excel file
- `GET /api/v1/owner/laporan/export-pdf` - Export laporan as PDF file

## Database Configuration

### Laravel (.env)
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=fin_ku
DB_USERNAME=root
DB_PASSWORD=
```

### Migration Example (users table)
```php
Schema::create('users', function (Blueprint $table) {
    $table->id();
    $table->string('nama');
    $table->string('username')->unique();
    $table->string('email')->unique();
    $table->timestamp('email_verified_at')->nullable();
    $table->string('password');
    $table->enum('role', ['kasir', 'admin', 'owner']);
    $table->enum('status', ['aktif', 'nonaktif'])->default('aktif');
    $table->rememberToken();
    $table->timestamps();
});
```

## Data Schemas

### User Response (from API)
```json
{
  "data": {
    "users": [...],
    "meta": {
      "total": 150,
      "per_page": 15,
      "current_page": 1,
      "last_page": 10,
      "from": 1,
      "to": 15
    }
  }
}
```

### Laporan Response (from API)
```json
{
  "data": {
    "year": 2024,
    "month": 5,
    "penjualan": 5000000,
    "total_penjualan": 5000000,
    "total_hpp": 3000000,
    "laba_kotor": 2000000,
    "monthly_data": [
      {"bulan": 1, "penjualan": 500000, "hpp": 300000, "laba": 200000},
      {"bulan": 2, "penjualan": 450000, "hpp": 280000, "laba": 170000}
    ]
  }
}
```