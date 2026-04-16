<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('activity_sessions', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_session_id');
            $table->string('exe', 255);
            $table->text('window_title')->nullable();
            $table->timestampTz('started_at');
            $table->timestampTz('ended_at')->nullable();
            $table->unsignedInteger('duration_seconds')->default(0);
            $table->string('device_name', 255)->nullable();
            $table->boolean('is_final')->default(false);
            $table->timestamps();

            $table->unique(['user_id', 'client_session_id']);
            $table->index(['user_id', 'started_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('activity_sessions');
    }
};
