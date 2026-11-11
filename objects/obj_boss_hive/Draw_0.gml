/// The vine from the palm's crown down to the hive, then the hive itself.
if (ready)
{
    draw_set_colour(make_colour_rgb(30, 70, 20));
    draw_line_width(anchor_x, anchor_y, x, y - 74, 6);
    draw_set_colour(make_colour_rgb(80, 150, 50));
    draw_line_width(anchor_x, anchor_y, x, y - 74, 3);
    draw_set_colour(c_white);
}
event_inherited();
