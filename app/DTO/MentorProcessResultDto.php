<?php

namespace App\DTO;

readonly class MentorProcessResultDto
{
    public function __construct(
        public string $mentorMessage,
        public MentorActionDto $action,
    ) {}

    /**
     * @return array{mentor_message: string, action: array{type: string, amount: float|null, category: string|null}}
     */
    public function toArray(): array
    {
        return [
            'mentor_message' => $this->mentorMessage,
            'action' => $this->action->toArray(),
        ];
    }
}
