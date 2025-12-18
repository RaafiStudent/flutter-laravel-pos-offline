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
     * Simpan transaksi (offline-first)
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'transaction_code' => 'required|string',
            'total_amount'     => 'required|numeric',
            'payment_amount'   => 'required|numeric',
            'change_amount'    => 'required|numeric',
            'payment_method'   => 'required|string',
            'transaction_date' => 'required|date',
            'items'            => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity'   => 'required|integer|min:1',
            'items.*.price'      => 'required|numeric',
        ]);

        // Cegah double transaksi
        $existing = Order::where('transaction_code', $validated['transaction_code'])->first();
        if ($existing) {
            return response()->json([
                'success' => true,
                'message' => 'Transaksi sudah tersimpan',
                'data' => $existing
            ]);
        }

        DB::beginTransaction();
        try {
            $order = Order::create([
                'transaction_code' => $validated['transaction_code'],
                'user_id'          => $request->user()->id,
                'total_amount'     => $validated['total_amount'],
                'payment_amount'   => $validated['payment_amount'],
                'change_amount'    => $validated['change_amount'],
                'payment_method'   => $validated['payment_method'],
                'transaction_date' => $validated['transaction_date'],
            ]);

            foreach ($validated['items'] as $item) {
                $product = Product::findOrFail($item['product_id']);

                if ($product->stock < $item['quantity']) {
                    throw new \Exception('Stok tidak cukup');
                }

                OrderItem::create([
                    'order_id'   => $order->id,
                    'product_id' => $product->id,
                    'quantity'   => $item['quantity'],
                    'price'      => $item['price'],
                ]);

                $product->decrement('stock', $item['quantity']);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Transaksi berhasil',
                'data' => $order
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
