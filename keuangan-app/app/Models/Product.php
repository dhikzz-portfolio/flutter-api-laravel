<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'category_id',
        'nama',
        'harga_jual',
        'stok',
        'stok_minimum',
        'hpp_rata_rata',
        'status',
    ];

    protected $casts = [
        'harga_jual' => 'decimal:2',
        'hpp_rata_rata' => 'decimal:2',
    ];

    // === Relationships ===

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function saleDetails()
    {
        return $this->hasMany(SaleDetail::class);
    }

    public function purchaseDetails()
    {
        return $this->hasMany(PurchaseDetail::class);
    }

    public function stockOutDetails()
    {
        return $this->hasMany(StockOutDetail::class);
    }

    public function stockAdjustmentDetails()
    {
        return $this->hasMany(StockAdjustmentDetail::class);
    }

    public function stockMovements()
    {
        return $this->hasMany(StockMovement::class);
    }

    // === Helpers ===

    public function isActive(): bool
    {
        return $this->status === 'aktif';
    }

    public function isStokMinimum(): bool
    {
        return $this->stok <= $this->stok_minimum;
    }
}
