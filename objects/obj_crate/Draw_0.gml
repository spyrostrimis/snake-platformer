/// The crate, and above it the parachute: a dome striped in the partner's colour, on strings.
if (chute > 0) draw_parachute(x + sin(t * 0.05 + 0.6) * 4, y - 32 - 52 * chute, 46 * chute, 26 * chute, x, y - 30, 16, skin.colour);
draw_sprite(sprite_index, 0, x, y);
// The snake inside, peeking out of the stencil hole: a hint who's coming.
draw_sprite_ext(skin.head, 1, x, y - 17, 0.45, 0.45, 0, c_white, 1);
