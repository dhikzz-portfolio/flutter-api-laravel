<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Sale extends Model
{
    use HasFactory;

    protected $fillable = [
        'invoice',
        'buyer_id',
        'user_id',
        'tanggal',
        'total',
        'status',
    ];

    protected $casts = [
        'tanggal' => 'date',
        'total' => 'decimal:2',
    ];

    // === Relationships ===

    public function buyer()
    {
        return $this->belongsTo(Buyer::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function saleDetails()
    {
        return $this->hasMany(SaleDetail::class);
    }

    // === Helpers ===

    public function isActive(): bool
    {
        return $this->status === 'active';
    }

    public function isDibatalkan(): bool
    {
        return $this->status === 'dibatalkan';
    }
}
