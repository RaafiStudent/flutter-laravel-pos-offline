<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Product extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
    'category_id',
    'name',
    'sku',
    'price',
    'image',
    // ❌ stock TIDAK boleh diisi dari client
    // stok hanya boleh berubah lewat transaksi (OrderController)
];


    public function category()
    {
        return $this->belongsTo(Category::class);
    }
}