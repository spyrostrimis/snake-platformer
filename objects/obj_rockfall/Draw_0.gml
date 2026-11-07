/// The rock in the ceiling: it trembles before it drops, and grows back after it fell.
var _s = 1;
if (state == "gone") _s = clamp(1 - timer / 50, 0, 1);    // regrows in the last moments
// Online, the joiner hides its ceiling rock while the host's rock is falling below it.
if (obj_game.net_mode == "client")
{
    var _falling = false;
    with (obj_hazard) if (sprite_index == spr_rock && abs(x - other.x) < 16 && y > other.y) _falling = true;
    if (_falling) exit;
}
if (_s <= 0) exit;
var _dx = (state == "shake") ? irandom_range(-2, 2) : 0;
draw_sprite_ext(sprite_index, 0, x + _dx, y - 12 * (1 - _s), _s, _s, 0, c_white, 1);
