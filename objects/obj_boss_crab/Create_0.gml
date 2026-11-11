/// Baron Clawbucks, the giant red crab of the sunken grotto. He scuttles sideways and has
/// three attacks:
/// Money boomerang: he raises a banknote in his big claw and flings it; it spins out, slows,
/// and comes back to him (angry: two in a row). The tongue can swat one away.
/// Claw snap: he lunges sideways at you with his big claw thrust out, snapping.
/// Claw smash: both claws high, then slammed into the sand; shockwaves run out both ways.
/// Stomp his shell, boost or lash him with the tongue to hurt him. Right after a hit his
/// shell is too hot to land on: he reels, then scuttles away.
/// Frames: idle A, idle B, claw up with a note, throw, snap, claws up, smash, dizzy.
event_inherited();
boss_name = "BARON CLAWBUCKS";
hw = 56;
hh = 56;
hp_max = 12;
hp = hp_max;
points = 25000;
music = "music_04.ogg";
drop_through = true;    // too heavy for the planks
state = "walk";         // walk | aim | throw | snapwind | snap | smashwind | smash | dizzy | flee
timer = 90;
last_hp = hp;
throws_left = 0;

spiky_back = function() { return hurt_t > 0; };

/// This PC's snakes inside the box (_x1.._x2, _y1.._y2) get hurt, pushed towards _dir.
claw_zone = function(_x1, _x2, _y1, _y2, _dir)
{
    var _l = min(_x1, _x2);
    var _r = max(_x1, _x2);
    with (obj_player)
    {
        if (!remote && !hidden && invuln == 0 && x + hw > _l && x - hw < _r && y + hh > _y1 && y - hh < _y2) take_hit(_dir);
    }
};

/// The snapping claw (frame 4) and the smashing claws (frame 6) hurt. Only uses x, facing and
/// image_index, so online each PC checks its own snake.
claw_check = function()
{
    var _f = floor(image_index);
    if (_f == 4) claw_zone(x + facing * 60, x + facing * 148, y - 30, y + 22, facing);
    else if (_f == 6)
    {
        claw_zone(x + 48, x + 134, y + 6, y + hh, 1);
        claw_zone(x - 134, x - 48, y + 6, y + hh, -1);
    }
};

/// Flings a banknote boomerang the way he faces: mostly low (jump it), sometimes high (stay
/// down and let it fly over). A snake up on a plank gets one thrown at its own height.
throw_note = function()
{
    var _ny = y + hh - ((irandom(2) == 0) ? 66 : 22);
    var _p = instance_nearest(x, y, obj_player);
    if (_p != noone && !_p.hidden && _p.y < y + hh - 70) _ny = clamp(_p.y + irandom_range(-6, 6), y - 160, y + hh - 22);
    var _h = shoot(spr_banknote, x + facing * 80, _ny, facing * 8.5, 0, 0);
    _h.boomer = facing;
    _h.home_x = x + facing * 60;
    _h.spin = false;
    _h.life = 230;
    obj_game.play_sfx(obj_game.sfx.throw_);
};
