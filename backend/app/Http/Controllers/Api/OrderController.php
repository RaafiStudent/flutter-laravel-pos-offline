<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    public function store(Request $request)
    {
        // Validasi data yang dikirim dari Flutter
        $request->validate([
            'transaction_code' => 'required|unique:orders',
            'total_amount' => 'required|numeric',
            'payment_amount' => 'required|numeric',
            'change_amount' => 'required|numeric',
            'payment_method' => 'required|in:cash,qris,transfer',
            'transaction_date' => 'required',
            'items' => 'required|array',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.price' => 'required|numeric',
        ]);

        // Gunakan DB Transaction agar data aman
        try {
            DB::beginTransaction();

            // 1. Simpan Header Transaksi
            $order = Order::create([
                'transaction_code' => $request->transaction_code,
                'user_id' => $request->user()->id, // Ambil ID kasir dari Token
                'total_amount' => $request->total_amount,
                'payment_amount' => $request->payment_amount,
                'change_amount' => $request->change_amount,
                'payment_method' => $request->payment_method,
                'transaction_date' => $request->transaction_date,
            ]);

            // 2. Simpan Detail Item & Kurangi Stok
            foreach ($request->items as $item) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $item['product_id'],
                    'quantity' => $item['quantity'],
                    'price' => $item['price'],
                ]);

                // Kurangi Stok Produk
                $product = Product::find($item['product_id']);
                if ($product) {
                    $product->decrement('stock', $item['quantity']);
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Transaksi Berhasil Diupload',
                'data' => $order
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan transaksi: ' . $e->getMessage()
            ], 500);
        }
    }
}