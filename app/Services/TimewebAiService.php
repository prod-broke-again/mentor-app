<?php

declare(strict_types=1);

namespace App\Services;

use App\Contracts\Ai\AiProviderInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

final class TimewebAiService implements AiProviderInterface
{
    /**
     * Параметр $model из контракта для Timeweb не используется: модель задаётся в панели Timeweb
     * и дублируется в `config('services.ai.timeweb.model')` / `TIMEWEB_AI_MODEL`.
     */
    public function complete(
        string $systemPrompt,
        string $userPrompt,
        int $maxTokens = 300,
        string $model = 'gpt-4o-mini',
        array $options = []
    ): ?string {
        $apiKey = (string) config('services.ai.timeweb.api_key');
        $baseUrl = rtrim((string) config('services.ai.timeweb.base_url'), '/');
        if ($apiKey === '' || $baseUrl === '') {
            Log::warning('TimewebAiService: API key or base URL missing');

            return null;
        }

        $resolvedModel = (string) config('services.ai.timeweb.model', 'gemini-2.0-flash');

        $url = $baseUrl.'/chat/completions';

        try {
            $response = Http::withToken($apiKey)
                ->timeout(30)
                ->connectTimeout(10)
                ->retry(2, 500, throw: false)
                ->post($url, [
                    'model' => $resolvedModel,
                    'messages' => [
                        ['role' => 'system', 'content' => $systemPrompt],
                        ['role' => 'user', 'content' => $userPrompt],
                    ],
                    'max_tokens' => $maxTokens,
                ] + $options);

            if (! $response->successful()) {
                Log::warning('TimewebAiService HTTP error', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);

                return null;
            }

            $content = data_get($response->json(), 'choices.0.message.content');

            return is_string($content) ? $content : null;
        } catch (\Throwable $e) {
            Log::warning('TimewebAiService request failed', ['error' => $e->getMessage()]);

            return null;
        }
    }
}
