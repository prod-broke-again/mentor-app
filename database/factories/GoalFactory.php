<?php

namespace Database\Factories;

use App\Models\Goal;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Goal>
 */
class GoalFactory extends Factory
{
    protected $model = Goal::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'title' => 'Переезд во Вьетнам',
            'target_amount' => 180_000,
            'current_amount' => 0,
            'location_slug' => 'vietnam',
        ];
    }
}
