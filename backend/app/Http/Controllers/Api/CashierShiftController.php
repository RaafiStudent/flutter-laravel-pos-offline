<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CashierShift;
use App\Models\Order;
use Illuminate\Http\Request;

class CashierShiftController extends Controller
{
    /**
     * BUKA SHIFT
     */
    public function open(Request $request)
    {
        $request->validate([
            'opening_balance' => 'required|numeric|min:0',
        ]);

        // Cegah shift ganda
        $existing = CashierShift::where('user_id', $request->user()->id)
            ->where('status', 'open')
            ->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => 'Shift masih terbuka',
            ], 400);
        }

        $shift = CashierShift::create([
            'user_id' => $request->user()->id,
            'opening_balance' => $request->opening_balance,
            'opened_at' => now(),
            'status' => 'open',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Shift berhasil dibuka',
            'data' => $shift,
        ]);
    }

    /**
     * TUTUP SHIFT
     */
    public function close(Request $request)
    {
        $request->validate([
            'closing_balance' => 'required|numeric|min:0',
        ]);

        $shift = CashierShift::where('user_id', $request->user()->id)
            ->where('status', 'open')
            ->firstOrFail();

        // Hitung transaksi selama shift
        $orders = Order::where('user_id', $request->user()->id)
            ->whereBetween('transaction_date', [
                $shift->opened_at,
                now()
            ]);

        $totalTransaction = $orders->count();
        $totalOmzet = $orders->sum('total_amount');

        $expectedCash = $shift->opening_balance + $totalOmzet;
        $cashDifference = $request->closing_balance - $expectedCash;

        $shift->update([
            'closing_balance' => $request->closing_balance,
            'total_transaction' => $totalTransaction,
            'total_omzet' => $totalOmzet,
            'cash_difference' => $cashDifference,
            'closed_at' => now(),
            'status' => 'closed',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Shift ditutup',
            'data' => [
                'total_transaction' => $totalTransaction,
                'total_omzet' => $totalOmzet,
                'expected_cash' => $expectedCash,
                'cash_difference' => $cashDifference,
            ],
        ]);
    }
}
