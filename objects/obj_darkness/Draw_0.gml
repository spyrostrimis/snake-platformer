/// Runs once per view: paint the shadow on a view-sized surface, cut the lights out of it,
/// lay it over the view, then add a warm glow around the torches.
var _g = obj_game;
var _cam = view_camera[view_current];
var _cx = camera_get_view_x(_cam);
var _cy = camera_get_view_y(_cam);
var _cw = camera_get_view_width(_cam);
var _ch = camera_get_view_height(_cam);
if (!surface_exists(surf) || surface_get_width(surf) != _cw || surface_get_height(surf) != _ch)
{
    if (surface_exists(surf)) surface_free(surf);
    surf = surface_create(_cw, _ch);
}

var _flick = 1 + sin(_g.frame * 0.21) * 0.04 + sin(_g.frame * 0.53) * 0.03;
var _ls = sprite_get_width(spr_light) / 2;     // a light of size 1 reaches this far

surface_set_target(surf);
draw_clear_alpha(_g.lvl.dark_col, _g.lvl.dark);
// Lights take the shadow away where they are (multiply the shadow by 1 - the light).
gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
for (var _i = 0; _i < array_length(_g.lights); _i++)
{
    var _l = _g.lights[_i];
    var _r = _l.r * (_l.torch ? _flick : 1);
    if (_l.x + _r * _ls < _cx || _l.x - _r * _ls > _cx + _cw || _l.y + _r * _ls < _cy || _l.y - _r * _ls > _cy + _ch) continue;
    draw_sprite_ext(spr_light, 0, _l.x - _cx, _l.y - _cy, _r, _r, 0, c_white, 1);
}
with (obj_player) if (!hidden) draw_sprite_ext(spr_light, 0, x - _cx, y - _cy, 1.9, 1.9, 0, c_white, 1);
with (obj_pickup) draw_sprite_ext(spr_light, 0, x - _cx, y - _cy, 0.6, 0.6, 0, c_white, 0.8);
with (obj_boss) draw_sprite_ext(spr_light, 0, x - _cx, y - _cy - 20, 2.6, 2.6, 0, c_white, 0.9);
// Creatures that glow (jellyfish, octopuses) light up a little patch round them.
with (obj_enemy) if (variable_instance_exists(id, "glow") && glow > 0) draw_sprite_ext(spr_light, 0, x - _cx, y - _cy, glow * (floor(image_index) == 2 ? 1.5 : 1), glow * (floor(image_index) == 2 ? 1.5 : 1), 0, c_white, 1);
with (obj_hazard) if (sprite_index == spr_spark) draw_sprite_ext(spr_light, 0, x - _cx, y - _cy, 0.5, 0.5, 0, c_white, 0.9);
with (obj_hazard) if (sprite_index == spr_venom || sprite_index == spr_puddle) draw_sprite_ext(spr_light, 0, x - _cx, y - _cy, 0.45, 0.45, 0, c_white, 0.8);
gpu_set_blendmode(bm_normal);
surface_reset_target();
draw_surface(surf, _cx, _cy);

// Warm firelight around the torches, and a faint green shine around the poison.
gpu_set_blendmode(bm_add);
for (var _i = 0; _i < array_length(_g.lights); _i++)
{
    var _l = _g.lights[_i];
    if (!_l.torch || abs(_l.x - (_cx + _cw / 2)) > _cw || abs(_l.y - (_cy + _ch / 2)) > _ch) continue;
    draw_sprite_ext(spr_light, 0, _l.x, _l.y, 1.5 * _flick, 1.5 * _flick, 0, make_colour_rgb(110, 50, 8), 0.55);
}
with (obj_hazard) if (sprite_index == spr_venom || sprite_index == spr_puddle) draw_sprite_ext(spr_light, 0, x, y, 0.4, 0.4, 0, make_colour_rgb(40, 110, 10), 0.6);
gpu_set_blendmode(bm_normal);
