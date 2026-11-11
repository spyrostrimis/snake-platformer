// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
image_speed = 0;
var _g = obj_game;
if (_g.state != "play") exit;
image_index = (_g.frame div 2) mod 2;
t += 0.15;
life--;

var _p = instance_nearest(x, y, obj_player);
if (life > 0 && _p != noone && !_p.hidden)
{
    vx = clamp(vx + sign(_p.x - x) * 0.11, -2.5, 2.5);
    vy = clamp(vy + sign(_p.y - 6 - y) * 0.09, -1.9, 1.9);
}
else
{
    // Time's up (or no snake): off it flies, up and away.
    vy = max(vy - 0.15, -3);
}
x += vx;
y += vy + sin(t) * 0.7;
if (abs(vx) > 0.3) facing = sign(vx);
if (life < -90) instance_destroy();
