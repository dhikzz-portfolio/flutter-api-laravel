# Fin-Ku Documentation

Welcome to the Fin-Ku Flutter application documentation. This project is a mobile application for managing financial data, user management, and generating laporan (reports).

## Documentation Structure

| File | Description |
|------|-------------|
| `INSTALLATION.md` | Step-by-step setup and installation guide |
| `DATABASE.md` | Database schema and data flow documentation |
| `ERD.md` | Entity Relationship Diagram visual guide |
| `DEPLOYMENT.md` | Build and deployment instructions |
| `API.md` | Complete API endpoint reference |

## Project Overview

Fin-Ku is a Flutter-based mobile application that connects to a Laravel backend API. The application features:

- **Owner Laporan Screen**: Period-based financial reports with summary cards and monthly breakdown
- **Owner User Management**: User CRUD operations with role-based access (kasir, admin, owner)
- **Role-Based Navigation**: Bottom navigation tailored to user roles
- **Platform-Aware API**: Automatic URL configuration for Android, iOS, and Web

## Key Features

### Owner Laporan Screen
- Period filter (year + month selector)
- Summary cards (Penjualan, HPP, Laba Kotor with Rupiah formatting)
- Monthly breakdown table with per-month data
- Export Excel and Export PDF functionality
- Loading, error, empty, and success states
- Persistent year selection via SharedPreferences

### Owner User Management
- User list with pagination
- Search and filter by role
- Create user form with validation
- Edit user functionality
- Delete user with confirmation dialog
- Role-based color chips (kasir: hijau, admin: kuning, owner: merah)

### Role-Based Navigation
- Dashboard, Laporan, User tabs for owner role
- Kasir: Home, Penjualan, Pembeli
- Admin: Home, Pembelian, Master

## Prerequisites

- Flutter SDK >= 3.16
- Laravel backend API running
- MySQL database

## Quick Start

1. See `docs/INSTALLATION.md` for setup
2. Ensure Laravel API is running
3. Run `flutter run` to start the application
4. Default login credentials should be configured in the Laravel seeders

## Support

For issues or questions, check the individual documentation files or contact the development team.