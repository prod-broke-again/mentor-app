<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional location to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    'ai' => [
        'default' => env('AI_PROVIDER', 'timeweb'),
        'timeweb' => [
            'api_key' => env('TIMEWEB_AI_API_KEY'),
            'base_url' => env('TIMEWEB_AI_BASE_URL'),
        ],
        'gptunnel' => [
            'api_key' => env('GPTUNNEL_API_KEY'),
            'base_url' => env('GPTUNNEL_AI_BASE_URL', 'https://gptunnel.ru/v1'),
        ],
        'openai' => [
            'api_key' => env('OPENAI_API_KEY'),
            'base_url' => env('OPENAI_BASE_URL', 'https://api.openai.com/v1'),
            'organization' => env('OPENAI_ORGANIZATION'),
            'chat_model' => env('OPENAI_CHAT_MODEL', 'gpt-4o-mini'),
            'transcription_model' => env('OPENAI_TRANSCRIPTION_MODEL', 'whisper-1'),
        ],
        'google' => [
            'api_key' => env('GOOGLE_AI_API_KEY'),
            'base_url' => env('GOOGLE_AI_BASE_URL', 'https://generativelanguage.googleapis.com/v1beta'),
        ],
    ],

];
