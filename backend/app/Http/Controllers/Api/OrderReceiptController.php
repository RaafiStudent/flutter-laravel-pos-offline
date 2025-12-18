<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;

class OrderReceiptController extends Controller
{
    /**
     * Generate data struk belanja (siap cetak)
     */
    public function show($id)
    {
        $order = Order::with([
            'items.product',
            'cashier'
        ])->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Receipt data generated',
            'data' => [
                'store' => [
                    'name' => 'TOKO MAJU JAYA',
                    'address' => 'Jl. Contoh No. 123',
                ],
                'transaction' => [
                    'code' => $order->transaction_code,
                    'date' => $order->transaction_date->format('Y-m-d'),
                    'time' => $order->transaction_date->format('H:i:s'),
                    'payment_method' => $order->payment_method,
                ],
                'cashier' => [
                    'name' => $order->cashier->name,
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
