<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use SimpleSoftwareIO\QrCode\Facades\QrCode;
use Illuminate\Support\Facades\Storage;

class OrderController extends Controller
{
    /**
     * Simpan transaksi dari aplikasi Flutter (Offline-First).
     */
    public function store(Request $request)
    {
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

        try {
            DB::beginTransaction();

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
                    throw new \Exception("Stok produk '{$product->name}' tidak mencukupi");
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
                'message' => 'Transaksi berhasil disinkronkan',
                'data'    => [
                    'order_id' => $order->id,
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

    /**
     * Generate data struk belanja
     */
    public function receipt($id)
{
    $order = Order::with(['items.product', 'cashier'])->findOrFail($id);

    // Generate QR Code (isi: kode transaksi)
    $qrContent = $order->transaction_code;

    $qrImage = QrCode::format('png')
        ->size(300)
        ->generate($qrContent);

    // Simpan QR sementara (opsional)
    $qrPath = 'receipts/qr_' . $order->id . '.png';
    Storage::disk('public')->put($qrPath, $qrImage);

    return response()->json([
        'success' => true,
        'data' => [
            'store' => [
                'name' => 'TOKO MAJU JAYA',
                'address' => 'Jl. Contoh No. 123',
            ],
            'transaction' => [
                'code' => $order->transaction_code,
                'date' => $order->transaction_date->format('d-m-Y H:i'),
                'cashier' => $order->cashier->name,
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
                'payment_method' => strtoupper($order->payment_method),
            ],
            'qr' => [
                'content' => $qrContent,
                'image_url' => asset('storage/' . $qrPath),
            ],
        ],
    ]);
}
