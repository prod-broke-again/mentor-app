<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AIProcessRequest extends FormRequest
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
            'text' => ['required_without:audio', 'nullable', 'string', 'max:8000'],
            'audio' => ['required_without:text', 'nullable', 'file', 'mimes:m4a,mp4,mp3,wav,webm,ogg', 'max:25600'],
        ];
    }
}
