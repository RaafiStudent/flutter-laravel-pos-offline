<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\OrderController;

/*
|--------------------------------------------------------------------------
| API Routes - Kasir Pintar (Offline-First POS)
|--------------------------------------------------------------------------
*/

// =======================
// PUBLIC ROUTES
// =======================

// Login
Route::post('/login', [AuthController::class, 'login']);

// Product Sync (Offline-First, tanpa login)
Route::get('/products', [ProductController::class, 'index']);


// =======================
// PROTECTED ROUTES
// =======================
Route::middleware('auth:sanctum')->group(function () {

    // Logout
    Route::post('/logout', [AuthController::class, 'logout']);

    // Debug user login
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Order (Transaksi)
    Route::post('/orders', [OrderController::class, 'store']);

    // Receipt / Struk
    Route::get('/orders/{id}/receipt', [OrderController::class, 'receipt']);
});
