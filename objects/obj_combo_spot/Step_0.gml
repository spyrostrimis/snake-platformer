var _g = obj_game;
if (_g.state != "play" || done) exit;
if (!ready)
{
    // What the move is for (the level made it after this spot).
    ready = true;
    if (goal == "gem") target = instance_nearest((land_x1 + land_x2) / 2, land_top, obj_super_gem);
    else if (goal == "switch") target = instance_nearest(x, y, obj_switch);
    else target = _g.boss;
}
if (goal_done()) { done = true; exit; }

var _solo = array_length(_g.pl) == 1 && _g.net_mode == "";
if (_solo)
{
    // Alone: the partner is delivered when the snake comes near (once).
    var _p = _g.pl[0].inst;
    if (!delivered && instance_exists(_p) && abs(_p.x - x) < 300 && abs(_p.y - y) < 220)
    {
        delivered = true;
        var _top = camera_get_view_y(view_camera[0]) - 40;
        instance_create_layer(x, _top, "Instances", obj_crate, { spot: id, skin_id: 1 - _g.character });
        _g.say("A PARTNER IS ON THE WAY!", 150);
        _g.play_sfx(_g.sfx.select);
    }
    exit;
}

// Two snakes: a hint for whoever comes near.
for (var _k = 0; _k < array_length(_g.pl); _k++)
{
    var _q = _g.pl[_k].inst;
    if (!instance_exists(_q) || _q.remote || abs(_q.x - x) > 200 || abs(_q.y - y) > 160 || _g.frame < hint_frame) continue;
    hint_frame = _g.frame + 900;
    if (type == "sling") _g.say("SLINGSHOT SPOT! PETO: HOLD ROLL + TONGUE (THE BOW). SOCKEE: ROLL + BOOST IN", 240, _g.pl[_k]);
    else _g.say("SNUG-ATTACK SPOT! SOCKEE: HOLD ROLL + TONGUE (THE C). PETO: ROLL INTO HIM", 240, _g.pl[_k]);
}
