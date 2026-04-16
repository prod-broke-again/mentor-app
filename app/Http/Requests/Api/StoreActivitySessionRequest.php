<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * Контракт API: POST /api/v1/activity/sessions
 *
 * @see docs/activity-api.md
 */
class StoreActivitySessionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'client_session_id' => ['required', 'uuid'],
            'exe' => ['required', 'string', 'max:255'],
            'window_title' => ['nullable', 'string', 'max:2000'],
            'started_at' => ['required', 'date'],
            'ended_at' => [
                Rule::requiredIf(fn (): bool => ($this->input('event') ?? 'session_end') === 'session_end'),
                'nullable',
                'date',
                'after_or_equal:started_at',
            ],
            'duration_seconds' => ['required', 'integer', 'min:0', 'max:864000'],
            'device_name' => ['nullable', 'string', 'max:255'],
            'event' => ['nullable', Rule::in(['heartbeat', 'session_end'])],
        ];
    }
}
