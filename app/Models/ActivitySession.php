<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property int $user_id
 * @property string $client_session_id
 * @property string $exe
 * @property string|null $window_title
 * @property Carbon $started_at
 * @property Carbon|null $ended_at
 * @property int $duration_seconds
 * @property string|null $device_name
 * @property bool $is_final
 */
class ActivitySession extends Model
{
    protected $fillable = [
        'user_id',
        'client_session_id',
        'exe',
        'window_title',
        'started_at',
        'ended_at',
        'duration_seconds',
        'device_name',
        'is_final',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'started_at' => 'datetime',
            'ended_at' => 'datetime',
            'is_final' => 'boolean',
        ];
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
