<?php

namespace App\Jobs;

use App\Models\ActivitySession;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

/**
 * Анализ завершённой сессии активности (LLM / правила) — заглушка для очереди.
 */
class AnalyzeActivitySessionJob implements ShouldQueue
{
    use Queueable;

    public function __construct(
        public int $activitySessionId
    ) {}

    public function handle(): void
    {
        $session = ActivitySession::query()->find($this->activitySessionId);
        if ($session === null) {
            return;
        }

        // Здесь позже: промпт к LLM, классификация exe/title, уведомления ментора.
    }
}
