var _g = obj_game;
if (instance_exists(obj_boss_bombard)) boss_seen = true;
if (_g.state != "play") exit;
// The bombard is beaten: down she goes.
if (!sinking && boss_seen && !instance_exists(obj_boss_bombard))
{
    sinking = true;
    sink_t = 0;
    for (var _tx = hull[0]; _tx <= hull[2]; _tx++)
        for (var _ty = hull[1]; _ty <= hull[3]; _ty++) _g.grid[_tx][_ty] = T_EMPTY;
    _g.shake(16);
    _g.play_sfx(_g.sfx.smash);
    _g.say("THE SHIP IS SINKING!", 150);
}
if (sinking)
{
    sink_t++;
    if (_g.frame mod 3 == 0) _g.burst(x + random_range(-200, 200), y + random_range(-6, 6), make_colour_rgb(220, 240, 255), 3);
    if (sink_t == 150 && !door_made)
    {
        // The exit, out on the rocks beyond where she lay.
        door_made = true;
        var _d = instance_create_layer(door_tx * TILE + 16, door_ty * TILE + 32, "Instances", obj_door);
        _d.open = array_length(word_hidden_letters(_g.word, _g.guessed)) == 0;
        _g.burst(_d.x, _d.y - 30, make_colour_rgb(120, 255, 140), 20);
        _g.play_sfx(_g.sfx.flag);
        _g.say("THE WAY TO THE EXIT IS CLEAR: SWIM OVER!", 180);
    }
}
