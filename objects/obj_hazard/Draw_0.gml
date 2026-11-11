// The whirlwind spins (its frames turn with the game's clock, the same on both PCs).
var _f = (sprite_index == spr_whirl) ? (obj_game.frame div 4) mod 3 : 0;
draw_sprite_ext(sprite_index, _f, x, y, 1, 1, image_angle, c_white, 1);
