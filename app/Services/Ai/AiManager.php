<?php

declare(strict_types=1);

namespace App\Services\Ai;

use App\Contracts\Ai\AiProviderInterface;
use InvalidArgumentException;

final class AiManager
{
    /**
     * @param  array<string, AiProviderInterface>  $providers
     */
    public function __construct(
        private readonly array $providers
    ) {}

    public function provider(?string $name = null): AiProviderInterface
    {
        $name ??= (string) config('services.ai.default', 'timeweb');
        if (! isset($this->providers[$name])) {
            throw new InvalidArgumentException("AI provider [{$name}] is not configured.");
        }

        return $this->providers[$name];
    }
}
