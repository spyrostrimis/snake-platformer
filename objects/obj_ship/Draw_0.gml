/// Rocking gently on the waves; sinking, it tips and goes down behind the sea floor.
var _g = obj_game;
var _down = sinking ? min(sink_t * 1.3, 600) : 0;
if (_down >= 600) exit;
var _bob = sinking ? 0 : sin(_g.frame * 0.03) * 3;
var _ang = sinking ? min(sink_t * 0.08, 12) : sin(_g.frame * 0.02) * 0.6;
draw_sprite_ext(sprite_index, 0, x, y + _bob + _down, 1, 1, _ang, c_white, 1);
