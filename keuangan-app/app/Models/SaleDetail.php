<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SaleDetail extends Model
{
    use HasFactory;

    protected $fillable = [
        'sale_id',
        'product_id',
        'harga_jual',
        'jumlah',
        'hpp_per_unit',
        'hpp_total',
        'subtotal',
    ];

    protected $casts = [
        'harga_jual' => 'decimal:2',
        'hpp_per_unit' => 'decimal:2',
        'hpp_total' => 'decimal:2',
        'subtotal' => 'decimal:2',
    ];

    public function sale()
    {
        return $this->belongsTo(Sale::class);
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
