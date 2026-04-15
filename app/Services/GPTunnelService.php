<?php

declare(strict_types=1);

namespace App\Services;

use App\Contracts\Ai\AiProviderInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

final class GPTunnelService implements AiProviderInterface
{
    public function complete(
        string $systemPrompt,
        string $userPrompt,
        int $maxTokens = 300,
        string $model = 'gpt-4o-mini',
        array $options = []
    ): ?string {
        $apiKey = (string) config('services.ai.gptunnel.api_key');
        $baseUrl = rtrim((string) config('services.ai.gptunnel.base_url', 'https://gptunnel.ru/v1'), '/');
        if ($apiKey === '') {
            Log::warning('GPTunnelService: API key missing');

            return null;
        }

        $url = $baseUrl.'/chat/completions';

        try {
            $response = Http::withHeaders([
                'Authorization' => $apiKey,
            ])
                ->timeout(30)
                ->connectTimeout(10)
                ->retry(2, 500, throw: false)
                ->post($url, [
                    'model' => $model,
                    'messages' => [
                        ['role' => 'system', 'content' => $systemPrompt],
                        ['role' => 'user', 'content' => $userPrompt],
                    ],
                    'max_tokens' => $maxTokens,
                    'useWalletBalance' => true,
                ] + $options);

            if (! $response->successful()) {
                Log::warning('GPTunnelService HTTP error', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);

                return null;
            }

            $content = data_get($response->json(), 'choices.0.message.content');

            return is_string($content) ? $content : null;
        } catch (\Throwable $e) {
            Log::warning('GPTunnelService request failed', ['error' => $e->getMessage()]);

            return null;
        }
    }
}
