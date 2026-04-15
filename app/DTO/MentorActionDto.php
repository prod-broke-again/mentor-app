<?php

namespace App\DTO;

readonly class MentorActionDto
{
    public function __construct(
        public string $type,
        public ?float $amount,
        public ?string $category,
    ) {}

    /**
     * @return array{type: string, amount: float|null, category: string|null}
     */
    public function toArray(): array
    {
        return [
            'type' => $this->type,
            'amount' => $this->amount,
            'category' => $this->category,
        ];
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public static function fromArray(array $data): self
    {
        $amount = $data['amount'] ?? null;

        return new self(
            type: is_string($data['type'] ?? null) ? $data['type'] : 'none',
            amount: is_numeric($amount) ? (float) $amount : null,
            category: is_string($data['category'] ?? null) ? $data['category'] : null,
        );
    }
}
