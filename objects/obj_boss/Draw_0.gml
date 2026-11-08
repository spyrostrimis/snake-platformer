/// The boss (flashing white when hit). The letter it holds isn't shown: it only appears
/// once the boss is beaten.
var _flash = hurt_t > 0 && (hurt_t div 4) mod 2 == 0;
if (_flash) gpu_set_fog(true, c_white, 0, 0);
draw_sprite_ext(sprite_index, image_index, x, y, facing, 1, draw_angle(), c_white, 1);
if (_flash) gpu_set_fog(false, c_white, 0, 0);
