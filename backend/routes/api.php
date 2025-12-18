<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
use App\Http\Controllers\Api\OrderReceiptController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\OrderController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
| Semua route API untuk sistem Kasir Pintar (Offline-First POS)
|
| - Public routes: dipakai untuk initial sync
| - Protected routes: butuh token (Sanctum)
|
*/

// =======================
// PUBLIC ROUTES
// =======================

// Login (ambil token untuk kasir / admin)
Route::post('/login', [AuthController::class, 'login']);

// Sinkronisasi produk (Offline-First, TANPA LOGIN)
// Digunakan saat:
// - Aplikasi pertama kali dibuka
// - Sync data produk
Route::get('/products', [ProductController::class, 'index']);


// =======================
// PROTECTED ROUTES
// =======================
Route::middleware('auth:sanctum')->group(function () {

    // Logout (hapus token aktif)
    Route::post('/logout', [AuthController::class, 'logout']);

    // Ambil data user yang sedang login (opsional / debug)
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::middleware('auth:sanctum')->group(function () {
    Route::get('/orders/{id}/receipt', [OrderReceiptController::class, 'show']);
    // Upload transaksi dari aplikasi kasir
    // Sudah:
    // - Server Wins (stok)
    // - Idempotent (anti transaksi ganda)
    Route::post('/orders', [OrderController::class, 'store']);
});
