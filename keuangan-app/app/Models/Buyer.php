<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Buyer extends Model
{
    use HasFactory;

    protected $fillable = ['nama', 'telepon', 'alamat'];

    public function sales()
    {
        return $this->hasMany(Sale::class);
    }
}
