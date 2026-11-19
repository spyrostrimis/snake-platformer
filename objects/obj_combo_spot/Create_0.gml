/// A place made for a combo move. The level sets (see lvl_combo):
///   type: "sling" (THE SLINGSHOT) or "snug" (SNUG-ATTACK)
///   dir:  the way the move throws (-1 or 1)
///   goal: "gem" (a super gem up on a ledge), "switch" (a switch behind speed blocks) or "boss"
///   land_x1, land_x2, land_top: for "gem", the ledge to land on (pixels)
/// y is the top of the floor it's on. Alone, the other snake comes in a crate under a
/// parachute when this snake gets near (see scr_buddy); with two snakes, a mark on the ground
/// and a hint say what to do.
delivered = false;
done = false;
hint_frame = 0;
target = noone;         // the super gem, the switch or the boss (found on the first step)
ready = false;

/// True once the job here is done: the gem taken, the switch pulled, the boss beaten.
goal_done = function()
{
    if (!ready) return false;
    if (goal == "switch") return !instance_exists(target) || target.pulled;
    return !instance_exists(target);
};

/// The goal for a SLINGSHOT shot: land on the ledge, or hit the boss.
shot_goal = function()
{
    if (goal == "boss" && instance_exists(target)) return { kind: "hit", x: target.x, y: target.y, w: target.hw + 8, h: target.hh + 8 };
    return { kind: "land", x1: land_x1, x2: land_x2, top: land_top };
};
