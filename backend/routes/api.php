<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\OrderReceiptController;

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

// Product Sync (Offline-First)
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

    // =======================
    // ORDER / TRANSAKSI
    // =======================
    Route::post('/orders', [OrderController::class, 'store']);

     Route::get('/reports/daily', [ReportController::class, 'daily']);
    Route::get('/reports/monthly', [ReportController::class, 'monthly']);

    // =======================
    // STRUK / RECEIPT
    // =======================
    Route::get('/orders/{id}/receipt', [OrderReceiptController::class, 'show']);
});
