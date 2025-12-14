<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    // API ini akan dipanggil saat HP pertama kali buka / tombol Sync ditekan
    public function index()
    {
        // Ambil produk beserta kategorinya
        // Kita gunakan 'latest' agar produk baru ada di atas
        $products = Product::with('category')->latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'List Data Produk',
            'data' => $products
        ]);
    }
}