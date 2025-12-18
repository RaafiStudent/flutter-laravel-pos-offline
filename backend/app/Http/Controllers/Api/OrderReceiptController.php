<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;

class OrderReceiptController extends Controller
{
    public function show($id)
    {
        $order = Order::with(['items.product', 'cashier'])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => [
                'store' => [
                    'name' => 'TOKO MAJU JAYA'
                ],
                'transaction' => [
                    'code' => $order->transaction_code,
                    'date' => $order->transaction_date->format('Y-m-d'),
                    'time' => $order->transaction_date->format('H:i:s'),
                ],
                'cashier' => $order->cashier->name,
                'items' => $order->items->map(function ($item) {
                    return [
                        'name' => $item->product->name,
                        'qty' => $item->quantity,
                        'price' => $item->price,
                        'subtotal' => $item->quantity * $item->price,
                    ];
                }),
                'summary' => [
                    'total' => $order->total_amount,
                    'paid' => $order->payment_amount,
                    'change' => $order->change_amount,
                ]
            ]
        ]);
    }
}
