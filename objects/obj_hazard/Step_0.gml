/// Fly, break on the ground or walls, and hurt the snake on contact (a rolling ball smashes it).
/// Boulders roll along the floor instead; venom leaves a poison puddle where it lands.
var _g = obj_game;
if (_g.state != "play") exit;
if (net_mirror())
{
    // Online, the joiner's projectiles copy the host's, and only hit the joiner's snake.
    x = lerp(x, net_tx, 0.5);
    y = lerp(y, net_ty, 0.5);
    var _me = (array_length(_g.pl) == 2) ? _g.pl[_g.my_pid].inst : noone;
    if (instance_exists(_me) && !_me.hidden && touches(_me))
    {
        if (lasts())
        {
            // A boulder or puddle stays; only a boosting snake smashes a boulder.
            if (!lasting_hit(_me)) exit;
        }
        else if (_me.ball) _g.burst(x, y, c_white, 6);
        else with (_me) take_hit(sign(x - other.x));
        if (sprite_index == spr_ink && !_me.ball) _me.inked = 170;
        _g.net_gone[$ string(net_id)] = true;
        _g.net_event({ t: "hazard", i: net_id });
        instance_destroy();
    }
    exit;
}

// ---------- A whirlwind of wasps: spins along the sand, back and forth ----------
if (whirl)
{
    x += vx;
    life--;
    if (is_blocking(tile_at(x + sign(vx) * 24, y)) || (vx < 0 && x < wx1) || (vx > 0 && x > wx2)) vx = -vx;
    if (_g.frame mod 5 == 0) part_particles_create(_g.ps, x + random_range(-16, 16), y + 46, _g.pt_dust, 1);
    if (life <= 0)
    {
        _g.burst(x, y + 20, make_colour_rgb(255, 220, 60), 8);
        instance_destroy();
        exit;
    }
    with (obj_player) if (!remote && !hidden && other.touches(id)) other.lasting_hit(id);
    exit;
}

// ---------- A boulder: rolls left along the floor until it drops off a cliff ----------
if (roll)
{
    var _vx = vx;
    vy = min(vy + 0.45, 10);
    entity_move();
    image_angle -= _vx * 3.2;
    if (hit_wall != 0)
    {
        // Ran into a wall: it bursts into gravel.
        part_particles_create(_g.ps, x, y, _g.pt_rock, 12);
        instance_destroy();
        exit;
    }
    vx = _vx;
    if (on_ground && _g.frame mod 6 == 0) part_particles_create(_g.ps, x, y + hh, _g.pt_dust, 1);
    if (y > _g.lvl_h * TILE + 48 || x < -48) { instance_destroy(); exit; }
    var _gone = false;
    with (obj_player) if (!_gone && !remote && !hidden && other.touches(id)) _gone = other.lasting_hit(id);
    if (_gone) instance_destroy();
    exit;
}

// ---------- A banknote boomerang: out, slowing, and back again ----------
if (boomer != 0)
{
    t += 1;
    vx -= boomer * 0.13;
    x += vx;
    y += vy + sin(t * 0.1) * 1.3;
    image_angle += 15;
    life--;
    if (life <= 0 || (t > 40 && sign(vx) == -boomer && abs(x - home_x) < 20) || x < -40 || x > _g.lvl_w * TILE + 40)
    {
        _g.burst(x, y, make_colour_rgb(150, 220, 140), 4);
        instance_destroy();
        exit;
    }
    var _hb = noone;
    with (obj_player) if (!remote && !hidden && _hb == noone && other.touches(id)) _hb = id;
    if (_hb != noone)
    {
        if (_hb.ball) _g.burst(x, y, c_white, 6);
        else with (_hb) take_hit(sign(x - other.x));
        instance_destroy();
    }
    exit;
}

t += 0.1;
vy += grav;
x += vx + (sway ? sin(t) * 1.2 : 0);
y += vy;
image_angle += sway ? sin(t) * 3 : (spin ? vx * 5 : 0);
life--;

var _t = tile_at(x, y + 6);
var _still = sprite_index == spr_puddle;     // a puddle lies on the floor: only time ends it
if (life <= 0 || (!_still && (is_blocking(_t) || y > _g.lvl_h * TILE)))
{
    part_particles_create(_g.ps, x, y, _g.pt_dust, 3);
    // Venom splashes into a poison puddle on the floor.
    if (sprite_index == spr_venom && life > 0 && is_blocking(_t))
    {
        var _floor = floor((y + 6) / TILE) * TILE;
        // The floor top: climb out of the block it landed in.
        while (is_blocking(tile_at(x, _floor - 1)) && _floor > 0) _floor -= TILE;
        var _p = instance_create_layer(x, _floor - 4, "Instances", obj_hazard);
        _p.sprite_index = spr_puddle;
        _p.spin = false;
        _p.image_angle = 0;
        _p.life = 220;
        _p.net_id = _g.net_next_id++;
    }
    instance_destroy();
    exit;
}
// The first snake it touches.
var _hit = noone;
with (obj_player) if (!remote && !hidden && _hit == noone && other.touches(id)) _hit = id;
if (_hit != noone)
{
    if (lasts()) lasting_hit(_hit);
    else
    {
        if (_hit.ball) _g.burst(x, y, c_white, 6);
        else with (_hit) take_hit(sign(x - other.x));
        // Octopus ink blots the snake's screen for a while.
        if (sprite_index == spr_ink && !_hit.ball) _hit.inked = 170;
        if (sprite_index == spr_ink) _g.burst(x, y, make_colour_rgb(40, 20, 60), 14);
        instance_destroy();
    }
}
