<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Goal;
use App\Models\MentorMessage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    private const DEFAULT_TARGET_RUB = 180_000;

    public function __invoke(Request $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();

        $goal = Goal::query()
            ->where('user_id', $user->id)
            ->where('location_slug', 'vietnam')
            ->orderByDesc('id')
            ->first();

        $messages = MentorMessage::query()
            ->where('user_id', $user->id)
            ->orderByDesc('created_at')
            ->limit(20)
            ->get(['id', 'body', 'action_type', 'action_amount', 'action_category', 'created_at']);

        return response()->json([
            'target_amount_rub' => self::DEFAULT_TARGET_RUB,
            'goal' => $goal ? [
                'id' => $goal->id,
                'title' => $goal->title,
                'target_amount' => (string) $goal->target_amount,
                'current_amount' => (string) $goal->current_amount,
                'location_slug' => $goal->location_slug,
            ] : null,
            'progress_current_rub' => $goal ? (float) $goal->current_amount : 0.0,
            'mentor_messages' => $messages->map(fn (MentorMessage $m) => [
                'id' => $m->id,
                'body' => $m->body,
                'action' => [
                    'type' => $m->action_type,
                    'amount' => $m->action_amount !== null ? (float) $m->action_amount : null,
                    'category' => $m->action_category,
                ],
                'created_at' => $m->created_at?->toIso8601String(),
            ]),
        ]);
    }
}
