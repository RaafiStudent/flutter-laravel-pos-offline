<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class ReportController extends Controller
{
    /**
     * LAPORAN HARIAN
     * GET /api/reports/daily?date=2025-12-18
     */
    public function daily(Request $request)
    {
        $date = $request->get('date', now()->toDateString());

        $orders = DB::table('orders')
            ->whereDate('transaction_date', $date);

        $totalTransaction = $orders->count();
        $totalOmzet = $orders->sum('total_amount');

        $topProducts = DB::table('order_items')
            ->join('orders', 'order_items.order_id', '=', 'orders.id')
            ->join('products', 'order_items.product_id', '=', 'products.id')
            ->whereDate('orders.transaction_date', $date)
            ->select(
                'products.name',
                DB::raw('SUM(order_items.quantity) as total_qty')
            )
            ->groupBy('products.name')
            ->orderByDesc('total_qty')
            ->limit(5)
            ->get();

        return response()->json([
            'success' => true,
            'period' => 'daily',
            'date' => $date,
            'summary' => [
                'total_transaction' => $totalTransaction,
                'total_omzet' => $totalOmzet,
            ],
            'top_products' => $topProducts,
        ]);
    }

    /**
     * LAPORAN BULANAN
     * GET /api/reports/monthly?month=12&year=2025
     */
    public function monthly(Request $request)
    {
        $month = $request->get('month', now()->month);
        $year  = $request->get('year', now()->year);

        $orders = DB::table('orders')
            ->whereMonth('transaction_date', $month)
            ->whereYear('transaction_date', $year);

        $totalTransaction = $orders->count();
        $totalOmzet = $orders->sum('total_amount');

        $topProducts = DB::table('order_items')
            ->join('orders', 'order_items.order_id', '=', 'orders.id')
            ->join('products', 'order_items.product_id', '=', 'products.id')
            ->whereMonth('orders.transaction_date', $month)
            ->whereYear('orders.transaction_date', $year)
            ->select(
                'products.name',
                DB::raw('SUM(order_items.quantity) as total_qty')
            )
            ->groupBy('products.name')
            ->orderByDesc('total_qty')
            ->limit(5)
            ->get();

        return response()->json([
            'success' => true,
            'period' => 'monthly',
            'month' => $month,
            'year' => $year,
            'summary' => [
                'total_transaction' => $totalTransaction,
                'total_omzet' => $totalOmzet,
            ],
            'top_products' => $topProducts,
        ]);
    }
}
