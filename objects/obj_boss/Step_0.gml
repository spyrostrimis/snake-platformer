/// Shared boss logic: wake up when a snake arrives in the boss area, count down the hurt
/// flash, stay inside the arena. Each child adds its own attacks after event_inherited().
if (obj_game.state != "play") exit;
if (hurt_t > 0) hurt_t--;
if (!active && in_arena_snake() != noone)
{
    active = true;
    obj_game.boss_start(id);
}
x = clamp(x, arena_x1, arena_x2);
