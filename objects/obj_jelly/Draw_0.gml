/// The jellyfish, and while it's electrified a flickering ring showing how far the shock reaches.
draw_sprite(sprite_index, image_index, x, y);
if (floor(image_index) == 2)
{
    draw_set_alpha(0.25 + 0.15 * sin(obj_game.frame * 0.6));
    draw_circle_colour(x, y + 10, 54, make_colour_rgb(255, 240, 120), make_colour_rgb(255, 240, 120), true);
    draw_circle_colour(x, y + 10, 50, make_colour_rgb(255, 250, 180), make_colour_rgb(255, 250, 180), true);
    draw_set_alpha(1);
}
