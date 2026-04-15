<?php

declare(strict_types=1);

namespace App\Contracts\Ai;

interface AiProviderInterface
{
    public function complete(
        string $systemPrompt,
        string $userPrompt,
        int $maxTokens = 300,
        string $model = 'gpt-4o-mini',
        array $options = []
    ): ?string;
}
