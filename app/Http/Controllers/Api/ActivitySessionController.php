<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StoreActivitySessionRequest;
use App\Jobs\AnalyzeActivitySessionJob;
use App\Models\ActivitySession;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class ActivitySessionController extends Controller
{
    public function store(StoreActivitySessionRequest $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $data = $request->validated();

        $event = $data['event'] ?? 'session_end';
        $isFinal = $event === 'session_end';

        $endedAt = $data['ended_at'] ?? null;
        if ($event === 'heartbeat' && $endedAt === null) {
            $endedAt = now();
        }

        $payload = [
            'exe' => $data['exe'],
            'window_title' => $data['window_title'] ?? null,
            'started_at' => $data['started_at'],
            'ended_at' => $endedAt,
            'duration_seconds' => $data['duration_seconds'],
            'device_name' => $data['device_name'] ?? null,
            'is_final' => $isFinal,
        ];

        $session = ActivitySession::query()->updateOrCreate(
            [
                'user_id' => $user->id,
                'client_session_id' => $data['client_session_id'],
            ],
            $payload,
        );

        if ($isFinal) {
            AnalyzeActivitySessionJob::dispatch($session->id);
        }

        $status = $session->wasRecentlyCreated ? 201 : 200;

        return response()->json([
            'id' => $session->id,
            'client_session_id' => $session->client_session_id,
            'is_final' => $session->is_final,
        ], $status);
    }
}
