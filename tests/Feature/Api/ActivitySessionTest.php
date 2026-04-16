<?php

use App\Models\ActivitySession;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

it('requires authentication for activity sessions', function (): void {
    $this->postJson('/api/v1/activity/sessions', [
        'client_session_id' => '550e8400-e29b-41d4-a716-446655440000',
        'exe' => 'chrome.exe',
        'started_at' => now()->subMinutes(5)->toIso8601String(),
        'ended_at' => now()->toIso8601String(),
        'duration_seconds' => 300,
    ])->assertUnauthorized();
});

it('stores a finalized activity session', function (): void {
    $user = User::factory()->create();
    $token = $user->createToken('test-device')->plainTextToken;

    $started = now()->subMinutes(5);
    $ended = now();

    $response = $this->postJson('/api/v1/activity/sessions', [
        'client_session_id' => '550e8400-e29b-41d4-a716-446655440000',
        'exe' => 'chrome.exe',
        'window_title' => 'Example',
        'started_at' => $started->toIso8601String(),
        'ended_at' => $ended->toIso8601String(),
        'duration_seconds' => 300,
        'device_name' => 'test',
    ], [
        'Authorization' => 'Bearer '.$token,
    ]);

    $response->assertCreated()
        ->assertJsonPath('is_final', true);

    expect(ActivitySession::query()->count())->toBe(1);

    $session = ActivitySession::query()->firstOrFail();
    expect($session->user_id)->toBe($user->id)
        ->and($session->exe)->toBe('chrome.exe')
        ->and($session->is_final)->toBeTrue();
});

it('updates the same client_session_id on heartbeat then finalizes', function (): void {
    $user = User::factory()->create();
    $token = $user->createToken('test-device')->plainTextToken;
    $sid = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';

    $started = now()->subMinutes(2);

    $this->postJson('/api/v1/activity/sessions', [
        'client_session_id' => $sid,
        'exe' => 'code.exe',
        'window_title' => 'project',
        'started_at' => $started->toIso8601String(),
        'duration_seconds' => 60,
        'event' => 'heartbeat',
    ], [
        'Authorization' => 'Bearer '.$token,
    ])->assertCreated();

    $this->postJson('/api/v1/activity/sessions', [
        'client_session_id' => $sid,
        'exe' => 'code.exe',
        'window_title' => 'project',
        'started_at' => $started->toIso8601String(),
        'ended_at' => now()->toIso8601String(),
        'duration_seconds' => 120,
        'event' => 'session_end',
    ], [
        'Authorization' => 'Bearer '.$token,
    ])->assertOk();

    expect(ActivitySession::query()->count())->toBe(1);
    expect(ActivitySession::query()->firstOrFail()->is_final)->toBeTrue()
        ->and(ActivitySession::query()->firstOrFail()->duration_seconds)->toBe(120);
});
