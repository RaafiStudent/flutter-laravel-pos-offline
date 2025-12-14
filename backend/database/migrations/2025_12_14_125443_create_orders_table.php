<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
{
    Schema::create('orders', function (Blueprint $table) {
        $table->id();
        $table->string('transaction_code')->unique(); // UUID dari Flutter
        $table->foreignId('user_id')->constrained(); // Kasir yang input
        $table->decimal('total_amount', 15, 2);
        $table->decimal('payment_amount', 15, 2);
        $table->decimal('change_amount', 15, 2); // Kembalian
        $table->enum('payment_method', ['cash', 'qris', 'transfer']);
        $table->timestamp('transaction_date'); // Waktu transaksi terjadi di HP (bukan waktu upload)
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
