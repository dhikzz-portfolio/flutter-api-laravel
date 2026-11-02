# API Documentation

## Base URL

The API base URL is platform-aware and configured in `lib/core/config/api_config.dart`:

| Environment | Base URL |
|-------------|----------|
| Android Emulator | `http://10.0.2.2:8000` |
| iOS Simulator | `http://localhost:8000` |
| Web | `http://127.0.0.1:8000` |
| Physical Device | `http://<device_ip>:8000` |

## Authentication

All API requests require proper headers. The `ApiClient` handles this automatically:

### Headers
```
Accept: application/json
Content-Type: application/json
Authorization: Bearer <token> (if authenticated)
```

### Auth Controller Endpoints

#### Login
```
POST /api/v1/auth/login
```
**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "user@example.com",
      "role": "owner",
      "isOwner": true,
      "isAdmin": false,
      "isKasir": false
    },
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  },
  "message": "Login berhasil"
}
```

#### Logout
```
POST /api/v1/auth/logout
```
**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK` with success message

#### Restore Session (auto-login)
```
GET /api/v1/auth/restore
```
**Headers:** `Authorization: Bearer <token>` (optional, uses session)

**Response:** User data if session valid, otherwise 401

## User Management Endpoints

### List Users
```
GET /api/v1/owner/user
```

**Query Parameters:**
- `page` (required): Current page number
- `per_page` (required): Items per page (default: 15)
- `search` (optional): Search by name or username
- `role` (optional): Filter by role (kasir, admin, owner)

**Response:**
```json
{
  "data": {
    "users": [
      {
        "id": 1,
        "nama": "John Smith",
        "username": "john_smith",
        "role": "kasir",
        "status": "aktif",
        "created_at": "2024-01-15T10:30:00Z"
      }
    ],
    "meta": {
      "total": 25,
      "per_page": 15,
      "current_page": 1,
      "last_page": 2,
      "from": 1,
      "to": 15
    }
  }
}
```

### Create User
```
POST /api/v1/owner/user
```

**Request Body:**
```json
{
  "nama": "John Smith",
  "username": "john_smith",
  "role": "kasir",
  "status": "aktif",
  "password": "password123"
}
```

**Response:** Success message and user data

### Update User
```
PUT /api/v1/owner/user/{id}
```

**Request Body:** Same as create, fields optional

**Response:** Updated user data

### Delete User
```
DELETE /api/v1/owner/user/{id}
```

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK` with success message

## Laporan/Report Endpoints

### Get Laporan Data
```
GET /api/v1/owner/laporan
```

**Query Parameters:**
- `year` (required): Filter by year (e.g., 2024)
- `month` (optional): Filter by month (1-12)

**Response:**
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
      {
        "bulan": 1,
        "penjualan": 500000,
        "hpp": 300000,
        "laba": 200000
      },
      {
        "bulan": 2,
        "penjualan": 450000,
        "hpp": 280000,
        "laba": 170000
      }
    ]
  }
}
```

### Export Excel
```
GET /api/v1/owner/laporan/export-excel
```

**Query Parameters:** Same as Get Laporan Data (`year`, `month` optional)

**Response:** Excel file (binary download)

### Export PDF
```
GET /api/v1/owner/laporan/export-pdf
```

**Query Parameters:** Same as Get Laporan Data (`year`, `month` optional)

**Response:** PDF file (binary download)

## Response Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Successful request |
| 201 | Created - Resource created successfully |
| 422 | Unprocessable Entity - Validation errors |
| 401 | Unauthorized - Invalid/missing token |
| 403 | Forbidden - Insufficient permissions |
| 500 | Internal Server Error |

## Error Response Format

```json
{
  "message": "Validation errors.",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password must be at least 8 characters."]
  }
}
```

## Security Notes

1. **Authentication**: Use `ApiClient` which automatically adds auth headers when token is available
2. **Rate Limiting**: Laravel default rate limits apply (typically 60/min per IP)
3. **CORS**: Configure Laravel `cors.php` to allow Flutter app origin
4. **HTTPS**: Use HTTPS in production, update API base URLs accordingly