<?php

use App\Http\Controllers\AIProcessController;
use App\Http\Controllers\AiController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DashboardController;
use Illuminate\Support\Facades\Route;

Route::post('ai/ask', [AiController::class, 'ask'])->middleware('throttle:30,1');

Route::prefix('auth')->group(function (): void {
    Route::post('login', [AuthController::class, 'login']);
});

Route::middleware('auth:sanctum')->group(function (): void {
    Route::post('auth/logout', [AuthController::class, 'logout']);
    Route::get('user', [AuthController::class, 'user']);
    Route::get('dashboard', DashboardController::class);
    Route::post('ai/process', AIProcessController::class)->middleware('throttle:20,1');
});
