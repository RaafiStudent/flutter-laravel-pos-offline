<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\OrderController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// =======================
// PUBLIC ROUTES
// =======================

// Login (ambil token)
Route::post('/login', [AuthController::class, 'login']);

// Product Sync (Offline-First, TANPA LOGIN)
Route::get('/products', [ProductController::class, 'index']);


// =======================
// PROTECTED ROUTES
// =======================
Route::middleware('auth:sanctum')->group(function () {

    // Logout
    Route::post('/logout', [AuthController::class, 'logout']);

    // Get user info (optional)
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Upload transaksi (AMAN + IDEMPOTENT)
    Route::post('/orders', [OrderController::class, 'store']);
});
