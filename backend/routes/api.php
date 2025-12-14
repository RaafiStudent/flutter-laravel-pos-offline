<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Public Routes (Bisa diakses tanpa Token)
Route::post('/login', [AuthController::class, 'login']);

// Protected Routes (Harus punya Token yang valid)
Route::middleware('auth:sanctum')->group(function () {
    
    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Master Data (Untuk Sync ke Local Database)
    Route::get('/products', [ProductController::class, 'index']);
    
    // Nanti kita tambah route 'orders' di sini untuk upload transaksi
});