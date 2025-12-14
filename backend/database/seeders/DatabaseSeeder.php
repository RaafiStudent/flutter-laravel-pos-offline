<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Buat User Kasir
        User::create([
            'name' => 'Kasir Utama',
            'email' => 'kasir@admin.com',
            'password' => Hash::make('password'), // Password default
        ]);

        // 2. Buat Kategori
        $catMakanan = Category::create(['name' => 'Makanan Berat']);
        $catMinuman = Category::create(['name' => 'Minuman Kopi']);
        $catSnack = Category::create(['name' => 'Cemilan']);

        // 3. Buat Produk Dummy
        Product::create([
            'category_id' => $catMinuman->id,
            'name' => 'Kopi Susu Gula Aren',
            'sku' => 'DRK001',
            'price' => 18000,
            'stock' => 50,
            'image' => 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=300&auto=format&fit=crop' 
        ]);

        Product::create([
            'category_id' => $catMinuman->id,
            'name' => 'Americano Hot',
            'sku' => 'DRK002',
            'price' => 15000,
            'stock' => 100,
            'image' => 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?q=80&w=300&auto=format&fit=crop'
        ]);

        Product::create([
            'category_id' => $catMakanan->id,
            'name' => 'Nasi Goreng Spesial',
            'sku' => 'FOOD001',
            'price' => 25000,
            'stock' => 20,
            'image' => 'https://images.unsplash.com/photo-1603133872878-684f108fd1f6?q=80&w=300&auto=format&fit=crop'
        ]);

        Product::create([
            'category_id' => $catSnack->id,
            'name' => 'French Fries',
            'sku' => 'SNK001',
            'price' => 12000,
            'stock' => 30,
            'image' => 'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?q=80&w=300&auto=format&fit=crop'
        ]);
    }
}