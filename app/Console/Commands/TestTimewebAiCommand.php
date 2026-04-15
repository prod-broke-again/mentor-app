<?php

declare(strict_types=1);

namespace App\Console\Commands;

use App\Services\TimewebAiService;
use Illuminate\Console\Command;

final class TestTimewebAiCommand extends Command
{
    protected $signature = 'ai:test-timeweb
                            {--prompt= : Пользовательский текст запроса}';

    protected $description = 'Проверка доступности Timeweb AI (chat/completions) по ключам из .env; модель — из TIMEWEB_AI_MODEL / панели Timeweb';

    public function handle(TimewebAiService $timeweb): int
    {
        $apiKey = (string) config('services.ai.timeweb.api_key');
        $baseUrl = rtrim((string) config('services.ai.timeweb.base_url'), '/');

        if ($apiKey === '' || $baseUrl === '') {
            $this->error('В .env не заданы TIMEWEB_AI_API_KEY и/или TIMEWEB_AI_BASE_URL (см. config/services.php → ai.timeweb).');

            return self::FAILURE;
        }

        $model = (string) config('services.ai.timeweb.model', 'gemini-2.0-flash');

        $this->line('Base URL: '.$baseUrl);
        $this->line('Model (config): '.$model);
        $this->newLine();

        $userPrompt = $this->option('prompt') ?: 'Ответь одним коротким предложением: связь установлена.';

        $answer = $timeweb->complete(
            systemPrompt: 'Ты тестовый ассистент. Отвечай кратко, без Markdown.',
            userPrompt: is_string($userPrompt) ? $userPrompt : 'Ping.',
            maxTokens: 200,
            model: $model,
        );

        if ($answer === null || $answer === '') {
            $this->error('Timeweb AI вернул пустой ответ. Проверьте ключ, URL и логи (storage/logs).');

            return self::FAILURE;
        }

        $this->info('Ответ модели:');
        $this->line($answer);

        return self::SUCCESS;
    }
}
