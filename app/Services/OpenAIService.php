<?php

namespace App\Services;

use App\Contracts\Ai\AiProviderInterface;
use App\DTO\AIProcessData;
use App\DTO\MentorActionDto;
use App\DTO\MentorProcessResultDto;
use Illuminate\Http\Client\RequestException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use RuntimeException;

class OpenAIService
{
    public function __construct(
        private readonly AiProviderInterface $aiProvider,
    ) {}

    public function processMentor(AIProcessData $data): MentorProcessResultDto
    {
        $userText = $data->text ?? '';
        if ($data->hasAudio()) {
            $transcript = $this->transcribe($data->audioAbsolutePath ?? '', $data->audioClientMime);
            $userText = trim($userText."\n\n".$transcript);
        }

        $userText = trim($userText);
        if ($userText === '') {
            throw new RuntimeException('Empty user input after processing.');
        }

        return $this->mentorChat($userText);
    }

    private function mentorChat(string $userText): MentorProcessResultDto
    {
        $system = <<<'PROMPT'
Ты — личный финансовый наставник «Кибер-бро». Твоя главная цель — помочь пользователю закрыть кредиты и накопить на переезд во Вьетнам.
Стиль: прямой, мотивирующий, с лёгким IT/киберпанк-вайбом. Ты — строгий, но справедливый напарник. 
Правила поведения:
- Хвали за любые отложенные суммы (даже минимальные) — это шаг к цели.
- Спокойно и по фактам корректируй, если видишь лишние траты.
- Никакой агрессии, токсичности, высокомерия и оскорблений (не используй слова вроде "салага", "слабак").
Ответь СТРОГО одним JSON-объектом без markdown и без пояснений вокруг. Схема:
{"mentor_message":"string","action":{"type":"string","amount":number|null,"category":"string|null"}}
Поле action.type одно из: none, save, spend, adjust_goal.
Если речь не про деньги — amount и category можно null, type = none.
Суммы в рублях, числа без строк.
PROMPT;

        $model = (string) config('services.ai.openai.chat_model', 'gpt-4o-mini');

        $content = $this->aiProvider->complete(
            systemPrompt: $system,
            userPrompt: $userText,
            maxTokens: 800,
            model: $model,
            options: [
                'response_format' => ['type' => 'json_object'],
                'temperature' => 0.6,
            ]
        );

        if ($content === null || $content === '') {
            throw new RuntimeException('AI provider returned empty response for mentor chat.');
        }

        /** @var array<string, mixed>|null $decoded */
        $decoded = json_decode($content, true);
        if (! is_array($decoded)) {
            throw new RuntimeException('AI returned non-JSON content.');
        }

        $message = is_string($decoded['mentor_message'] ?? null) ? $decoded['mentor_message'] : 'Не удалось разобрать ответ ментора.';
        /** @var array<string, mixed> $actionRaw */
        $actionRaw = is_array($decoded['action'] ?? null) ? $decoded['action'] : [];

        return new MentorProcessResultDto(
            mentorMessage: $message,
            action: MentorActionDto::fromArray($actionRaw),
        );
    }

    private function transcribe(string $absolutePath, ?string $clientMime): string
    {
        if ($absolutePath === '' || ! is_file($absolutePath)) {
            throw new RuntimeException('Audio file is missing or not readable.');
        }

        $apiKey = (string) config('services.ai.openai.api_key');
        if ($apiKey === '') {
            throw new RuntimeException('OpenAI API key is not configured (required for audio transcription).');
        }

        $baseUrl = rtrim((string) config('services.ai.openai.base_url', 'https://api.openai.com/v1'), '/');
        $url = $baseUrl.'/audio/transcriptions';

        $filename = basename($absolutePath);
        $bytes = file_get_contents($absolutePath);
        if ($bytes === false) {
            throw new RuntimeException('Could not read audio file.');
        }

        $mime = $clientMime ?: 'application/octet-stream';

        $pending = Http::withToken($apiKey)
            ->timeout(120)
            ->connectTimeout(15)
            ->retry(2, 1000, throw: false)
            ->asMultipart()
            ->attach('file', $bytes, $filename, ['Content-Type' => $mime]);

        $org = config('services.ai.openai.organization');
        if (is_string($org) && $org !== '') {
            $pending = $pending->withHeaders(['OpenAI-Organization' => $org]);
        }

        $response = $pending->post($url, [
            'model' => config('services.ai.openai.transcription_model', 'whisper-1'),
        ]);

        try {
            $response->throw();
        } catch (RequestException $e) {
            throw new RuntimeException('OpenAI transcription failed: '.$e->getMessage(), 0, $e);
        }

        $text = $response->json('text');
        if (! is_string($text)) {
            throw new RuntimeException('Unexpected OpenAI transcription response.');
        }

        return Str::of($text)->trim()->toString();
    }
}
