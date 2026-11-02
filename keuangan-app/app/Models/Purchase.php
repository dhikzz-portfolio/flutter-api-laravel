<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Purchase extends Model
{
    use HasFactory;

    protected $fillable = [
        'invoice',
        'distributor_id',
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

    public function distributor()
    {
        return $this->belongsTo(Distributor::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function purchaseDetails()
    {
        return $this->hasMany(PurchaseDetail::class);
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
