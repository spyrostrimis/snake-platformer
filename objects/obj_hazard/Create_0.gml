/// A boss projectile (a cheese wedge or a feather). The boss sets sprite, vx, vy and grav.
/// Level 5 adds two that stay around after touching a snake: a rolling boulder (roll = true)
/// and the cobra's poison puddle.
vx = 0;
vy = 0;
grav = 0;
life = 360;
sway = false;
spin = true;            // tumbles as it flies (the mole's shockwave sets this false)
image_speed = 0;
image_angle = random(360);
t = random(10);
net_id = -1;            // online: the same number on both PCs
net_tx = x;             // joiner: where the host says it is
net_ty = y;

// A boulder rolls along the floor like a creature (entity_move needs these).
roll = false;
hw = 16;
hh = 16;
on_ground = false;
hit_wall = 0;
hit_ceiling = false;
drop_through = false;

/// Boulders and poison puddles hurt a snake but stay (or keep rolling) afterwards, and the
/// tongue can't swat them away. Only looks at the sprite, so it works the same on both PCs.
lasts = function() { return sprite_index == spr_boulder || sprite_index == spr_puddle; };

/// True if snake _p overlaps this.
touches = function(_p)
{
    var _sw = 7;
    var _sh = 7;
    if (sprite_index == spr_boulder) { _sw = 16; _sh = 16; }
    else if (sprite_index == spr_puddle) { _sw = 22; _sh = 6; }
    return abs(_p.x - x) < _p.hw + _sw && abs(_p.y - y) < _p.hh + _sh;
};

/// Snake _p ran into a boulder or a puddle: a boosting snake smashes a boulder (returns
/// true: the boulder is gone), anything else hurts the snake (if it isn't flashing already).
lasting_hit = function(_p)
{
    if (sprite_index == spr_boulder && _p.boost_t > 0)
    {
        part_particles_create(obj_game.ps, x, y, obj_game.pt_rock, 12);
        obj_game.play_sfx(obj_game.sfx.smash);
        return true;
    }
    if (_p.invuln == 0) with (_p) take_hit(sign(x - other.x));
    return false;
};
