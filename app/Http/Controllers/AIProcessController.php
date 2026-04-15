<?php

namespace App\Http\Controllers;

use App\DTO\AIProcessData;
use App\Http\Requests\AIProcessRequest;
use App\Models\MentorMessage;
use App\Services\OpenAIService;
use Illuminate\Http\JsonResponse;
use RuntimeException;
use Throwable;

class AIProcessController extends Controller
{
    public function __construct(
        private readonly OpenAIService $openAIService,
    ) {}

    public function __invoke(AIProcessRequest $request): JsonResponse
    {
        $data = new AIProcessData(
            text: $request->filled('text') ? $request->string('text')->toString() : null,
            audioAbsolutePath: $request->file('audio')?->getRealPath() ?: null,
            audioClientMime: $request->file('audio')?->getMimeType(),
        );

        try {
            $result = $this->openAIService->processMentor($data);
        } catch (RuntimeException $e) {
            return response()->json([
                'message' => $e->getMessage(),
            ], 422);
        } catch (Throwable $e) {
            report($e);

            return response()->json([
                'message' => 'AI processing failed.',
            ], 502);
        }

        /** @var \App\Models\User $user */
        $user = $request->user();

        MentorMessage::query()->create([
            'user_id' => $user->id,
            'body' => $result->mentorMessage,
            'action_type' => $result->action->type,
            'action_amount' => $result->action->amount,
            'action_category' => $result->action->category,
        ]);

        return response()->json($result->toArray());
    }
}
