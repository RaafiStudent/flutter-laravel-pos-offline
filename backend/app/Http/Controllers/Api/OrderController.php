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
    /**
     * Simpan transaksi dari aplikasi Flutter (Offline-First).
     * Client TIDAK PERNAH mengirim stok.
     * Stok hanya dihitung dan dikurangi oleh SERVER.
     */
    public function store(Request $request)
    {
        // ===============================
        // 1. VALIDASI DATA DARI CLIENT
        // ===============================
        $validated = $request->validate([
            'transaction_code' => 'required|string|unique:orders,transaction_code',
            'total_amount'     => 'required|numeric|min:0',
            'payment_amount'   => 'required|numeric|min:0',
            'change_amount'    => 'required|numeric|min:0',
            'payment_method'   => 'required|in:cash,qris,transfer',
            'transaction_date' => 'required|date',
            'items'            => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity'   => 'required|integer|min:1',
            'items.*.price'      => 'required|numeric|min:0',
        ]);

        // ===============================
        // 2. DATABASE TRANSACTION
        // ===============================
        try {
            DB::beginTransaction();

            // ===============================
            // 3. SIMPAN HEADER TRANSAKSI
            // ===============================
            $order = Order::create([
                'transaction_code' => $validated['transaction_code'],
                'user_id'          => $request->user()->id, // dari token Sanctum
                'total_amount'     => $validated['total_amount'],
                'payment_amount'   => $validated['payment_amount'],
                'change_amount'    => $validated['change_amount'],
                'payment_method'   => $validated['payment_method'],
                'transaction_date' => $validated['transaction_date'],
            ]);

            // ===============================
            // 4. SIMPAN DETAIL & KURANGI STOK
            // ===============================
            foreach ($validated['items'] as $item) {

                // Ambil produk (LOCK server)
                $product = Product::findOrFail($item['product_id']);

                // Validasi stok cukup
                if ($product->stock < $item['quantity']) {
                    throw new \Exception(
                        "Stok produk '{$product->name}' tidak mencukupi"
                    );
                }

                // Simpan detail transaksi
                OrderItem::create([
                    'order_id'   => $order->id,
                    'product_id' => $product->id,
                    'quantity'   => $item['quantity'],
                    'price'      => $item['price'],
                ]);

                // ⚠️ PENTING:
                // Stok hanya boleh dikurangi oleh SERVER
                // Client tidak pernah mengirim field stock
                $product->decrement('stock', $item['quantity']);
            }

            DB::commit();

            // ===============================
            // 5. RESPONSE SUKSES
            // ===============================
            return response()->json([
                'success' => true,
                'message' => 'Transaksi berhasil disinkronkan',
                'data'    => [
                    'order_id'         => $order->id,
                    'transaction_code' => $order->transaction_code,
                ],
            ], 201);

        } catch (\Exception $e) {

            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan transaksi',
                'error'   => $e->getMessage(),
            ], 500);
        }
    }
}
