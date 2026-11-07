var _g = obj_game;
if (_g.state != "play") exit;
// Online, the host decides when rocks fall; the joiner only shows its ceiling rocks.
if (_g.net_mode == "client") exit;

switch (state)
{
    case "ready":
        var _under = false;
        with (obj_player) if (!hidden && y > other.y && y - other.y < 320 && abs(x - other.x) < 42) _under = true;
        if (_under)
        {
            state = "shake";
            timer = 26;
            _g.play_sfx(_g.sfx.flap);
        }
        break;

    case "shake":
        if (_g.frame mod 4 == 0) part_particles_create(_g.ps, x + irandom_range(-8, 8), y + 8, _g.pt_dust, 1);
        if (--timer <= 0)
        {
            var _h = instance_create_layer(x, y, "Instances", obj_hazard);
            _h.sprite_index = spr_rock;
            _h.vy = 1;
            _h.grav = 0.35;
            _h.net_id = _g.net_next_id++;
            _g.play_sfx(_g.sfx.smash);
            state = "gone";
            timer = regrow;
        }
        break;

    case "gone":
        if (--timer <= 0) state = "ready";
        break;
}
