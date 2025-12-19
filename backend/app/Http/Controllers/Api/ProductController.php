<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    /**
     * Incremental & Paginated Product Sync
     * Digunakan oleh Flutter saat:
     * - Sync pertama kali
     * - Tombol Sync ditekan
     *
     * Query Params:
     * - limit (default 100)
     * - cursor (optional)
     */

    public function lowStock()
{
    $products = \App\Models\Product::whereColumn('stock', '<=', 'min_stock')
        ->orderBy('stock', 'asc')
        ->get(['id', 'name', 'stock', 'min_stock']);

    return response()->json([
        'success' => true,
        'data' => $products,
    ]);
}


    public function index(Request $request)
    {
        $limit = (int) $request->get('limit', 100);
        $limit = $limit > 0 && $limit <= 200 ? $limit : 100;

        $query = Product::with('category')
            ->orderBy('id');

        // Cursor-based pagination
        if ($request->filled('cursor')) {
            $query->where('id', '>', $request->cursor);
        }

        $products = $query
            ->limit($limit)
            ->get();

        $lastId = $products->last()?->id;

        return response()->json([
            'success' => true,
            'message' => 'Product sync batch',
            'data'    => $products,
            'meta'    => [
                'limit'       => $limit,
                'next_cursor' => $lastId,
                'has_more'    => $products->count() === $limit,
            ],
        ]);
    }
}
