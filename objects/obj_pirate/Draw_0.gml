/// The pirate's art faces right. Peeking, the leaves round his eyes rustle.
var _f = floor(image_index);
if (_f == 5) exit;
var _jx = (_f == 4) ? sin(obj_game.frame * 0.9) * 1.2 : 0;
draw_sprite_ext(sprite_index, image_index, x + _jx, y, facing, 1, 0, c_white, 1);
