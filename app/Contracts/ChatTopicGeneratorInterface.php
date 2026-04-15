<?php

declare(strict_types=1);

namespace App\Contracts;

interface ChatTopicGeneratorInterface
{
    public function generateTopic(string $messagesText): ?string;
}
