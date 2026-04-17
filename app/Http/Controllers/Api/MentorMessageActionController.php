<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Goal;
use App\Models\MentorMessage;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MentorMessageActionController extends Controller
{
    private const DEFAULT_TARGET_RUB = 180_000;

    public function __invoke(Request $request, MentorMessage $mentorMessage): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        if ($mentorMessage->user_id !== $user->id) {
            return response()->json(['message' => 'Сообщение не найдено.'], 404);
        }

        $type = mb_strtolower((string) $mentorMessage->action_type);
        $amount = $mentorMessage->action_amount !== null ? (float) $mentorMessage->action_amount : null;

        if (! in_array($type, ['save', 'spend'], true) || $amount === null || $amount <= 0) {
            return response()->json(['message' => 'В сообщении нет сохраняемого действия.'], 422);
        }

        $marker = 'mentor_message:'.$mentorMessage->id;

        $existing = Transaction::query()
            ->where('user_id', $user->id)
            ->where('comment', $marker)
            ->first();

        if ($existing !== null) {
            return response()->json([
                'applied' => true,
                'already_applied' => true,
                'transaction_id' => $existing->id,
            ]);
        }

        $transactionId = null;
        $goalCurrent = null;

        DB::transaction(function () use ($type, $amount, $marker, $user, &$transactionId, &$goalCurrent): void {
            $transaction = Transaction::query()->create([
                'user_id' => $user->id,
                'amount' => $amount,
                'type' => $type,
                'category' => 'mentor',
                'comment' => $marker,
            ]);

            $delta = $type === 'save' ? $amount : -$amount;

            $goal = Goal::query()->firstOrCreate(
                ['user_id' => $user->id, 'location_slug' => 'vietnam'],
                [
                    'title' => 'Вьетнам',
                    'target_amount' => self::DEFAULT_TARGET_RUB,
                    'current_amount' => 0,
                ],
            );

            $current = (float) $goal->current_amount;
            $next = max(0, $current + $delta);
            $goal->current_amount = $next;
            $goal->save();

            $transactionId = $transaction->id;
            $goalCurrent = $next;
        });

        return response()->json([
            'applied' => true,
            'already_applied' => false,
            'transaction_id' => $transactionId,
            'goal_current_amount' => $goalCurrent,
        ]);
    }
}
