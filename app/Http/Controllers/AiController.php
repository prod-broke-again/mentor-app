<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Services\Ai\AiManager;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class AiController extends Controller
{
    public function ask(Request $request, AiManager $ai): JsonResponse
    {
        $data = $request->validate([
            'prompt' => ['required', 'string', 'max:4000'],
            'provider' => ['nullable', 'string', 'in:timeweb,gptunnel'],
        ]);

        $provider = $ai->provider($data['provider'] ?? null);
        $answer = $provider->complete(
            systemPrompt: 'Ты полезный ассистент. Отвечай кратко и по делу.',
            userPrompt: $data['prompt'],
            maxTokens: 500,
            model: 'gpt-4o-mini'
        );

        return response()->json([
            'ok' => $answer !== null,
            'answer' => $answer,
        ], $answer !== null ? 200 : 502);
    }
}
