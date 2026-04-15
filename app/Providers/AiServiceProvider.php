<?php

declare(strict_types=1);

namespace App\Providers;

use App\Contracts\Ai\AiProviderInterface;
use App\Services\Ai\AiManager;
use App\Services\GPTunnelService;
use App\Services\TimewebAiService;
use Illuminate\Support\ServiceProvider;

final class AiServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(TimewebAiService::class);
        $this->app->singleton(GPTunnelService::class);

        $this->app->singleton(AiManager::class, function ($app) {
            return new AiManager([
                'timeweb' => $app->make(TimewebAiService::class),
                'gptunnel' => $app->make(GPTunnelService::class),
            ]);
        });

        $this->app->bind(AiProviderInterface::class, function ($app) {
            return $app->make(AiManager::class)->provider();
        });
    }
}
