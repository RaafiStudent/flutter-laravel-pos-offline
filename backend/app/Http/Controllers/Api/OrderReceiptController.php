<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;

class OrderReceiptController extends Controller
{
    public function show($id)
    {
        $order = Order::with([
            'items.product',
            'cashier'
        ])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => [
                'store' => [
                    'name' => 'TOKO MAJU JAYA',
                    'address' => 'Jl. Merdeka No. 12',
                ],
                'transaction' => [
                    'code' => $order->transaction_code,
                    'date' => $order->transaction_date->format('d-m-Y H:i'),
                    'cashier' => $order->cashier->name,
                    'payment_method' => $order->payment_method,
                ],
                'items' => $order->items->map(function ($item) {
                    return [
                        'name' => $item->product->name,
                        'qty' => $item->quantity,
                        'price' => $item->price,
                        'subtotal' => $item->price * $item->quantity,
                    ];
                }),
                'summary' => [
                    'total' => $order->total_amount,
                    'paid' => $order->payment_amount,
                    'change' => $order->change_amount,
                ],
            ],
        ]);
    }
}
