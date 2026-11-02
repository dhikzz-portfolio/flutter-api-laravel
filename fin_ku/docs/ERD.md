# Entity Relationship Diagram (ERD)

## Database Diagram

```
┌─────────────┐      ┌────────────────┐      ┌─────────────────┐
│    users     |      |    laporans    |      | monthly_reports │
├─────────────┤      ├────────────────┤      ├─────────────────┤
│ id [PK]     │──┐     │ id [PK]      │      │ id [PK]         │
│ name        │──┼────▶│ year         │──┐    │ laporan_id [FK] │
│ username    │  │     │ month        │  │───▶│ bulan           │
│ email       │──┼────▶│ penjualan    │  │     │ penjualan       │
│ email_verified_at│ │ │ total_penjualan│ │ │ │ hpp            │
│ password    │──┼────▶│ total_hpp    │  │ │ │ laba           │
│ role        │──┼────▶│ laba_kotor   │  │ │ └─────────────────┘
│ status      │──┼────▶│ created_at   │  │ │
│ remember_token│ │ │ updated_at   │──┘ │ │
│ created_at  │──┼────▶│              │        │ │
│ updated_at  │      │              │        │ └──────┬─────────┘
└─────────────┘      └────────────────┘        │           │
                                                   │           │
                                                   └───────────┘
```

## Relationships

### 1. Users → Laporan (One-to-Many)
- One user can have multiple laporan entries
- Foreign key: `laporans.user_id` (if applicable) or reports are generated system-wide
- In current implementation: Laporan are system-wide, not user-specific

### 2. Laporan → Monthly_Reports (One-to-Many)
- One laporan (yearly/monthly) can have multiple monthly breakdown entries
- Foreign key: `laporan_id` in monthly_reports table
- Each monthly report contains: month number, penjualan, hpp, laba

### 3. Users → Roles
- `role` enum: `kasir`, `admin`, `owner`
- Permissions based on role:
  - `kasir`: Can view own data, limited access
  - `admin`: Can manage users, view all reports
  - `owner`: Full access to all features (laporan, user management)

## Key Tables Description

### users
Core user table storing authentication and authorization data.
- Used for login via `AuthController`
- Role-based access control
- Pagination and filtering in user management screen

### laporans
Contains aggregated financial data per year/month.
- Summary cards on laporan screen show: penjualan, hpp, laba_kotor
- Export functionality (Excel/PDF) generates from this data
- Filterable by year and specific month

### monthly_reports
Contains detailed breakdown per month within a laporan.
- Data table on laporan screen displays monthly_data
- Each row: bulan (month namaBl), penjualan, hpp, laba
- Supports horizontal scrolling table view

## Diagram Notation

This ERD uses Crow's Foot notation:
- `|` - Primary Key
- `│` - Attributes
- `→` - Foreign Key relationship
- `*` - Many side
- `1` - One side

---

**Note**: The actual database schema is managed through Laravel migrations. 
This documentation reflects the current API-driven data structure.