<?php

namespace App\DTO;

readonly class AIProcessData
{
    public function __construct(
        public ?string $text,
        public ?string $audioAbsolutePath,
        public ?string $audioClientMime,
    ) {}

    public function hasAudio(): bool
    {
        return $this->audioAbsolutePath !== null && $this->audioAbsolutePath !== '';
    }
}
