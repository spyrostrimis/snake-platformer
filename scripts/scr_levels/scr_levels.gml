/// Levels are built in code from a few shapes: ground, blocks, logs, spikes and spawns.
/// Every level, word and creature here is original.

function lvl_create(_name, _w, _h, _music, _sky_top, _sky_bottom)
{
    var _grid = array_create(_w);
    for (var _x = 0; _x < _w; _x++) _grid[_x] = array_create(_h, T_EMPTY);
    // bg_tint colours the parallax scenery; vine_odds: a vine under 1 in (vine_odds + 1) ledge tiles.
    // tileset, bg (far / top / near parallax pictures), cloud_drift and deco ("jungle" or "cave")
    // let a level look completely different, like the cavern. mushrooms: false leaves them out;
    // dark (0 to 1) lays a shadow of colour dark_col over the view, lit by torches, crystals
    // and the snakes. swim: "surface" (snakes float at the top of water) or "free" (deep water:
    // they swim anywhere).
    return { name: _name, w: _w, h: _h, grid: _grid, spawns: [], music: _music, sky_top: _sky_top, sky_bottom: _sky_bottom, arena: [0, 0],
             bg_tint: c_white, vine_odds: 3, tileset: ts_jungle, bg: [spr_bg_mountains, spr_bg_clouds, spr_bg_hills],
             cloud_drift: 1, deco: "jungle", mushrooms: true, dark: 0, dark_col: make_colour_rgb(10, 4, 16),
             water: [], currents: [], swim: "surface" };
}

/// Water in tiles _x1.._x2, rows _y1.._y2 (the top row is the surface). Snakes float and swim
/// in it; it doesn't block anything.
function lvl_water(_l, _x1, _y1, _x2, _y2)
{
    array_push(_l.water, [_x1, _y1, _x2, _y2]);
}

/// A current in tiles _x1.._x2, rows _y1.._y2 that drags snakes by (_vx, _vy) pixels a step:
/// sideways in a lake, upwards in a water spout, downwards in a waterfall.
function lvl_current(_l, _x1, _y1, _x2, _y2, _vx, _vy)
{
    array_push(_l.currents, { x1: _x1 * TILE, y1: _y1 * TILE, x2: (_x2 + 1) * TILE, y2: (_y2 + 1) * TILE, vx: _vx, vy: _vy });
}

function lvl_rect(_l, _x1, _y1, _x2, _y2, _t)
{
    for (var _x = max(0, _x1); _x <= min(_l.w - 1, _x2); _x++)
        for (var _y = max(0, _y1); _y <= min(_l.h - 1, _y2); _y++) _l.grid[_x][_y] = _t;
}

/// Solid ground from row _top down to the bottom.
function lvl_ground(_l, _x1, _x2, _top)
{
    lvl_rect(_l, _x1, _top, _x2, _l.h - 1, T_SOLID);
}

function lvl_put(_l, _kind, _tx, _ty)
{
    array_push(_l.spawns, { kind: _kind, tx: _tx, ty: _ty });
}

function lvl_gems(_l, _x1, _x2, _ty)
{
    for (var _x = _x1; _x <= _x2; _x++) lvl_put(_l, "gem", _x, _ty);
}

/// Level 1: a sunny meadow of hills, logs, a hidden alcove and a few pits.
function level_greenleaf()
{
    var L = lvl_create("GREENLEAF GROVE", 170, 15, "music_08.ogg", make_colour_rgb(22, 40, 140), make_colour_rgb(96, 168, 236));
    lvl_ground(L, 0, 24, 11);
    lvl_put(L, "start", 3, 10);
    lvl_gems(L, 7, 11, 9);
    lvl_put(L, "bug", 16, 10);
    lvl_put(L, "letter", 20, 8);

    lvl_ground(L, 28, 44, 11);
    lvl_rect(L, 33, 9, 37, 10, T_SOLID);
    lvl_rect(L, 30, 6, 35, 6, T_ONEWAY);
    lvl_put(L, "letter", 32, 5);
    lvl_put(L, "gem", 34, 5);
    lvl_put(L, "bug", 40, 10);
    lvl_put(L, "spring", 43, 10);

    lvl_rect(L, 46, 4, 52, 5, T_SOLID);
    lvl_put(L, "letter", 49, 3);
    lvl_put(L, "egg", 47, 3);
    lvl_ground(L, 45, 72, 11);
    lvl_put(L, "bee", 55, 7);
    lvl_put(L, "letter", 58, 10);

    // A sealed alcove: roll into the cracked wall to break in.
    lvl_rect(L, 63, 8, 63, 10, T_CRACK);
    lvl_rect(L, 63, 7, 69, 7, T_SOLID);
    lvl_rect(L, 69, 8, 69, 10, T_SOLID);
    lvl_put(L, "letter", 66, 10);
    lvl_put(L, "gem", 65, 10);
    lvl_put(L, "gem", 67, 10);

    lvl_ground(L, 73, 82, 11);
    lvl_put(L, "flag", 75, 10);
    lvl_put(L, "super_egg", 77, 10);    // two players only
    lvl_put(L, "letter", 79, 7);
    lvl_rect(L, 85, 9, 88, 9, T_ONEWAY);
    lvl_rect(L, 91, 7, 94, 7, T_ONEWAY);
    lvl_put(L, "letter", 92, 6);
    lvl_put(L, "bee", 89, 5);
    lvl_gems(L, 85, 88, 8);

    lvl_ground(L, 97, 122, 11);
    lvl_rect(L, 103, 10, 105, 10, T_SPIKES);
    lvl_rect(L, 108, 8, 112, 10, T_SOLID);
    lvl_put(L, "bug", 100, 10);
    lvl_put(L, "bug", 116, 10);
    lvl_put(L, "letter", 110, 7);
    lvl_put(L, "letter", 119, 10);
    lvl_put(L, "egg", 114, 10);
    lvl_put(L, "spring", 121, 10);

    lvl_ground(L, 127, 169, 11);
    lvl_rect(L, 128, 8, 130, 8, T_ONEWAY);   // a step up to the high log (5 tiles is out of jump reach)
    lvl_rect(L, 132, 6, 137, 6, T_ONEWAY);
    lvl_put(L, "letter", 134, 5);
    lvl_put(L, "bee", 140, 7);
    lvl_put(L, "letter", 145, 10);

    // Boss arena: Big Cheese guards the exit and one letter of the word.
    L.arena = [146, 163];
    lvl_rect(L, 151, 8, 155, 8, T_ONEWAY);
    lvl_put(L, "boss_mouse", 158, 10);
    lvl_put(L, "door", 165, 10);
    return L;
}

/// Level 2: a purple-sky climb of pillars, springs, a secret floor and more bees.
function level_mushroom()
{
    var L = lvl_create("MUSHROOM HEIGHTS", 150, 15, "music_01.ogg", make_colour_rgb(58, 26, 106), make_colour_rgb(228, 122, 184));
    lvl_ground(L, 0, 18, 11);
    lvl_put(L, "start", 3, 10);
    lvl_put(L, "bug", 12, 10);
    lvl_put(L, "letter", 15, 10);

    lvl_ground(L, 22, 30, 11);
    lvl_put(L, "spring", 29, 10);
    lvl_rect(L, 32, 7, 36, 14, T_SOLID);
    lvl_put(L, "letter", 34, 6);

    // A secret room under cracked floor: drop onto it as a ball.
    lvl_ground(L, 37, 50, 11);
    lvl_rect(L, 46, 12, 50, 13, T_EMPTY);
    lvl_rect(L, 47, 11, 49, 11, T_CRACK);
    lvl_put(L, "letter", 48, 13);
    lvl_put(L, "gem", 47, 13);
    lvl_put(L, "gem", 49, 13);
    lvl_rect(L, 39, 8, 43, 8, T_ONEWAY);
    lvl_put(L, "letter", 41, 7);
    lvl_put(L, "bee", 45, 6);

    lvl_ground(L, 51, 70, 11);
    lvl_put(L, "spring", 53, 10);
    lvl_rect(L, 55, 5, 56, 10, T_SOLID);
    lvl_rect(L, 58, 5, 62, 5, T_ONEWAY);
    lvl_put(L, "letter", 60, 4);
    // A spring on the far side of the tall wall, so it can be climbed again from the right.
    lvl_put(L, "spring", 63, 10);
    lvl_put(L, "bug", 64, 10);
    lvl_put(L, "bee", 67, 6);
    lvl_rect(L, 72, 9, 73, 9, T_ONEWAY);

    lvl_ground(L, 75, 95, 9);
    lvl_put(L, "flag", 77, 8);
    lvl_put(L, "super_egg", 86, 8);     // two players only
    lvl_rect(L, 82, 8, 84, 8, T_SPIKES);
    lvl_put(L, "letter", 88, 8);
    lvl_put(L, "letter", 93, 8);
    lvl_put(L, "bug", 91, 8);
    lvl_gems(L, 79, 81, 6);

    lvl_ground(L, 96, 111, 11);
    lvl_rect(L, 99, 7, 104, 7, T_ONEWAY);
    lvl_put(L, "letter", 101, 6);
    lvl_put(L, "bee", 106, 5);
    lvl_put(L, "spring", 110, 10);
    lvl_rect(L, 112, 6, 114, 14, T_SOLID);
    lvl_put(L, "letter", 113, 5);
    lvl_put(L, "egg", 112, 5);

    lvl_ground(L, 115, 149, 11);
    // A spring back up onto the pillar, so a missed glide over the room below can be retried.
    lvl_put(L, "spring", 116, 10);
    lvl_put(L, "bug", 120, 10);
    lvl_rect(L, 126, 8, 126, 10, T_CRACK);
    lvl_rect(L, 126, 7, 131, 7, T_SOLID);
    lvl_rect(L, 131, 8, 131, 10, T_SOLID);
    lvl_put(L, "letter", 128, 10);

    // Boss arena: the Hothead Hen guards the exit and one letter of the word.
    L.arena = [132, 146];
    lvl_rect(L, 137, 7, 141, 7, T_ONEWAY);
    lvl_put(L, "egg", 144, 10);
    lvl_put(L, "boss_hen", 141, 10);
    lvl_put(L, "door", 148, 10);
    return L;
}

/// Level 3: deep in the jungle under a dark green canopy, thick with vines.
/// Climbing branches, a canopy reached by spring, root steps and a hidden hollow,
/// then the wild cat's clearing. Heights stay within a jump (4 tiles) or a spring (7).
function level_tangleroot()
{
    var L = lvl_create("TANGLEROOT DEPTHS", 168, 15, "music_07.ogg", make_colour_rgb(6, 28, 24), make_colour_rgb(34, 86, 52));
    L.bg_tint = make_colour_rgb(90, 150, 105);
    L.vine_odds = 1;

    lvl_ground(L, 0, 20, 11);
    lvl_put(L, "start", 3, 10);
    lvl_gems(L, 6, 9, 9);
    lvl_put(L, "bug", 14, 10);
    lvl_put(L, "letter", 18, 10);

    // A small pit, then two branches climbing up a tree.
    lvl_ground(L, 24, 40, 11);
    lvl_rect(L, 26, 8, 29, 8, T_ONEWAY);
    lvl_rect(L, 31, 5, 34, 5, T_ONEWAY);
    lvl_put(L, "gem", 27, 7);
    lvl_put(L, "letter", 33, 4);
    lvl_put(L, "bee", 37, 7);

    // A wide pit with one branch to hop across on.
    lvl_rect(L, 42, 9, 44, 9, T_ONEWAY);
    lvl_put(L, "gem", 43, 8);

    lvl_ground(L, 46, 85, 11);
    lvl_rect(L, 50, 8, 54, 10, T_SOLID);
    lvl_put(L, "letter", 52, 7);
    lvl_put(L, "bee", 57, 7);
    lvl_rect(L, 58, 10, 60, 10, T_SPIKES);
    lvl_put(L, "bug", 63, 10);
    // A spring up to the high canopy (7 tiles up).
    lvl_put(L, "spring", 68, 10);
    lvl_put(L, "letter", 66, 7);
    lvl_rect(L, 70, 4, 76, 4, T_ONEWAY);
    lvl_put(L, "egg", 71, 3);
    lvl_put(L, "letter", 73, 3);
    lvl_gems(L, 74, 75, 3);
    lvl_put(L, "flag", 80, 10);
    lvl_put(L, "super_egg", 83, 10);    // two players only

    // Root steps rising out of a pit, then a drop with a branch to climb back.
    lvl_ground(L, 89, 94, 11);
    lvl_ground(L, 95, 100, 9);
    lvl_ground(L, 101, 106, 7);
    lvl_put(L, "bug", 92, 10);
    lvl_put(L, "letter", 98, 8);
    lvl_put(L, "bee", 100, 5);
    lvl_put(L, "letter", 104, 6);
    lvl_rect(L, 108, 9, 109, 9, T_ONEWAY);

    lvl_ground(L, 107, 167, 11);
    lvl_put(L, "bug", 110, 10);
    lvl_put(L, "letter", 112, 10);

    // A hollow tree: roll into the cracked bark to get in.
    lvl_rect(L, 116, 8, 116, 10, T_CRACK);
    lvl_rect(L, 116, 7, 121, 7, T_SOLID);
    lvl_rect(L, 121, 8, 121, 10, T_SOLID);
    lvl_put(L, "letter", 118, 10);
    lvl_put(L, "gem", 119, 10);

    // Thorns under a branch.
    lvl_rect(L, 125, 10, 126, 10, T_SPIKES);
    lvl_rect(L, 124, 7, 128, 7, T_ONEWAY);
    lvl_put(L, "letter", 126, 6);
    lvl_gems(L, 124, 125, 6);
    lvl_put(L, "bee", 129, 6);
    lvl_put(L, "flag", 132, 10);
    lvl_put(L, "egg", 133, 10);

    // Boss clearing: Wild Whiskers guards the exit and one letter of the word.
    // Two low branches to jump onto when she pounces.
    L.arena = [136, 158];
    lvl_rect(L, 140, 8, 143, 8, T_ONEWAY);
    lvl_rect(L, 150, 8, 153, 8, T_ONEWAY);
    lvl_put(L, "boss_cat", 154, 10);
    lvl_put(L, "door", 162, 10);
    return L;
}

/// Level 4: down into a cavern, brown to orange. A rock ceiling all the way, narrow tunnels
/// (one with cracked rock to roll through), bats hanging from the roof, loose rocks that
/// drop when you pass, and Big Diggs the mole at the end.
/// Reach: every step is within a jump (4 tiles), every pit at most 3 wide, and a jump never
/// needs more headroom than the ceiling gives.
function level_emberstone()
{
    var L = lvl_create("EMBERSTONE CAVERN", 160, 15, "music_06.ogg", make_colour_rgb(40, 18, 6), make_colour_rgb(190, 92, 30));
    L.tileset = ts_cave;
    L.bg = [spr_bg_cave_far, spr_bg_cave_top, spr_bg_cave_near];
    L.cloud_drift = 0;
    L.deco = "cave";
    L.vine_odds = 1;

    // The cave roof over the whole level (rows 0-1), lower in places below.
    lvl_rect(L, 0, 0, 159, 1, T_SOLID);

    // ---- The way in ----
    lvl_rect(L, 0, 2, 24, 2, T_SOLID);
    lvl_ground(L, 0, 24, 11);
    lvl_put(L, "start", 3, 10);
    lvl_gems(L, 6, 9, 9);
    lvl_put(L, "letter", 12, 10);
    lvl_put(L, "rockfall", 16, 3);
    lvl_put(L, "bat", 21, 3);

    // ---- Tunnel 1: a long, low crawl (one tile high: no jumping in here) ----
    lvl_rect(L, 25, 0, 36, 9, T_SOLID);
    lvl_ground(L, 25, 36, 11);
    lvl_gems(L, 27, 29, 10);
    lvl_gems(L, 33, 35, 10);

    // ---- A tall chamber with a pit, a plank and bats ----
    lvl_ground(L, 37, 43, 11);
    lvl_ground(L, 47, 60, 11);
    lvl_rect(L, 49, 7, 52, 7, T_ONEWAY);
    lvl_put(L, "letter", 50, 6);
    lvl_put(L, "rockfall", 41, 2);
    lvl_put(L, "letter", 40, 8);
    lvl_put(L, "bat", 45, 2);
    lvl_put(L, "rockfall", 55, 2);
    lvl_put(L, "letter", 56, 8);
    lvl_put(L, "bug", 57, 10);

    // ---- Tunnel 2: two tiles high, blocked by cracked rock: roll into it (hold Shift) ----
    lvl_rect(L, 61, 0, 74, 8, T_SOLID);
    lvl_ground(L, 61, 74, 11);
    lvl_rect(L, 68, 9, 68, 10, T_CRACK);
    lvl_gems(L, 72, 73, 10);

    // ---- Steps up and a drop, with a plank to climb back ----
    lvl_ground(L, 75, 82, 11);
    lvl_put(L, "flag", 76, 10);
    lvl_put(L, "super_egg", 79, 10);    // two players only
    lvl_put(L, "letter", 78, 8);
    lvl_ground(L, 83, 86, 9);
    lvl_ground(L, 87, 90, 7);
    lvl_put(L, "letter", 88, 6);
    lvl_put(L, "bat", 85, 2);
    lvl_ground(L, 91, 100, 11);
    lvl_rect(L, 92, 9, 93, 9, T_ONEWAY);
    lvl_put(L, "letter", 92, 8);
    lvl_rect(L, 95, 10, 96, 10, T_SPIKES);
    lvl_put(L, "letter", 98, 10);
    lvl_put(L, "bat", 97, 2);

    // ---- Tunnel 3: another low crawl ----
    lvl_rect(L, 101, 0, 112, 9, T_SOLID);
    lvl_ground(L, 101, 112, 11);
    lvl_gems(L, 103, 105, 10);

    // ---- The rockfall corridor ----
    lvl_rect(L, 113, 2, 127, 3, T_SOLID);
    lvl_ground(L, 113, 159, 11);
    lvl_put(L, "rockfall", 116, 4);
    lvl_put(L, "letter", 117, 8);
    lvl_put(L, "rockfall", 120, 4);
    lvl_put(L, "rockfall", 124, 4);
    lvl_put(L, "bug", 118, 10);
    lvl_put(L, "letter", 122, 10);
    lvl_put(L, "egg", 125, 10);
    lvl_put(L, "flag", 126, 10);

    // ---- Big Diggs' den: two planks to dodge his roll and his shockwaves ----
    lvl_rect(L, 128, 2, 159, 2, T_SOLID);
    L.arena = [128, 150];
    lvl_rect(L, 133, 8, 136, 8, T_ONEWAY);
    lvl_rect(L, 142, 8, 145, 8, T_ONEWAY);
    lvl_put(L, "bat", 139, 3);
    lvl_put(L, "boss_mole", 146, 10);
    lvl_put(L, "door", 154, 10);
    return L;
}

/// Level 5: deeper in the caverns, where it's dark. Torches on the walls light the way.
/// Tunnels send boulders rolling from right to left (they roll on until they drop into the
/// next pit), mole holes keep sending out little moles and cracks in the roof keep sending
/// out bats. No mushrooms down here. Hissandra the cobra waits at the end.
/// Reach: every step is within a jump (4 tiles; ledges here are at most 3 up), every pit is
/// 3 wide with the same floor height on both sides, and the low tunnel has floor on both ends.
function level_shadowrock()
{
    var L = lvl_create("SHADOWROCK HOLLOW", 172, 15, "music_03.ogg", make_colour_rgb(12, 5, 4), make_colour_rgb(84, 36, 14));
    L.tileset = ts_cave;
    L.bg = [spr_bg_cave_far, spr_bg_cave_top, spr_bg_cave_near];
    L.bg_tint = make_colour_rgb(140, 100, 90);
    L.cloud_drift = 0;
    L.deco = "cave";
    L.vine_odds = 1;
    L.mushrooms = false;
    L.dark = 0.6;

    // The cave roof over the whole level (rows 0-1).
    lvl_rect(L, 0, 0, 171, 1, T_SOLID);

    // ---- The way in: the first mole hole ----
    lvl_ground(L, 0, 21, 11);
    lvl_put(L, "start", 3, 10);
    lvl_put(L, "torch", 2, 7);
    lvl_gems(L, 6, 9, 9);
    lvl_put(L, "torch", 10, 7);
    lvl_put(L, "letter", 12, 10);
    lvl_put(L, "mole_hole", 16, 10);
    lvl_put(L, "torch", 19, 7);

    // ---- Boulder run 1: they roll out of the tunnel at 45 and drop into the pit at 22-24.
    //      Two planks overhead to wait on while one rolls by. ----
    lvl_ground(L, 25, 64, 11);
    lvl_put(L, "torch", 27, 6);
    lvl_rect(L, 30, 8, 33, 8, T_ONEWAY);
    lvl_put(L, "letter", 31, 7);
    lvl_put(L, "bat_crack", 35, 2);
    lvl_rect(L, 38, 8, 41, 8, T_ONEWAY);
    lvl_put(L, "gem", 39, 7);
    lvl_put(L, "gem", 40, 7);
    lvl_put(L, "letter", 41, 7);
    lvl_put(L, "torch", 43, 6);
    lvl_put(L, "boulders", 45, 10);

    // ---- The mole field: two holes and a rock to hop over ----
    lvl_put(L, "torch", 49, 6);
    lvl_put(L, "mole_hole", 51, 10);
    lvl_rect(L, 54, 9, 56, 10, T_SOLID);
    lvl_put(L, "letter", 55, 8);
    lvl_put(L, "mole_hole", 59, 10);
    lvl_put(L, "torch", 58, 6);
    lvl_put(L, "flag", 62, 10);
    lvl_put(L, "super_egg", 63, 10);    // two players only

    // ---- Boulder run 2: out of the tunnel at 95, along the high floor, off the step at 80
    //      and on into the pit at 65-67 ----
    lvl_ground(L, 68, 79, 11);
    lvl_put(L, "torch", 70, 7);
    lvl_put(L, "egg", 71, 10);
    lvl_put(L, "letter", 74, 10);
    lvl_put(L, "bat_crack", 76, 2);
    lvl_ground(L, 80, 108, 9);
    lvl_rect(L, 84, 6, 87, 6, T_ONEWAY);
    lvl_put(L, "letter", 85, 5);
    lvl_put(L, "letter", 87, 5);
    lvl_put(L, "torch", 89, 4);
    lvl_put(L, "bat_crack", 91, 2);
    lvl_put(L, "torch", 93, 5);
    lvl_put(L, "boulders", 95, 8);

    // ---- A low crawl through the rock (one tile high), lit only by the snake ----
    lvl_rect(L, 98, 0, 107, 7, T_SOLID);
    lvl_gems(L, 99, 101, 8);
    lvl_gems(L, 105, 106, 8);

    // ---- Boulder run 3: out of the tunnel at 128, into the pit at 112-114, over thorns ----
    lvl_ground(L, 109, 111, 11);        // two tiles down from the crawl: a jump back up
    lvl_ground(L, 115, 171, 11);
    lvl_put(L, "torch", 110, 7);
    lvl_put(L, "letter", 110, 8);
    lvl_put(L, "letter", 117, 10);
    lvl_rect(L, 120, 10, 121, 10, T_SPIKES);
    lvl_put(L, "bat_crack", 121, 2);
    lvl_put(L, "mole_hole", 124, 10);
    lvl_put(L, "torch", 123, 6);
    lvl_put(L, "letter", 126, 10);
    lvl_put(L, "boulders", 128, 10);
    lvl_put(L, "flag", 131, 10);
    lvl_put(L, "egg", 132, 10);

    // ---- Hissandra's lair: two planks to wait on while her tail and venom land ----
    L.arena = [134, 162];
    lvl_put(L, "torch", 136, 5);
    lvl_rect(L, 138, 8, 141, 8, T_ONEWAY);
    lvl_put(L, "torch", 145, 5);
    lvl_rect(L, 148, 8, 151, 8, T_ONEWAY);
    lvl_put(L, "torch", 154, 5);
    lvl_put(L, "boss_cobra", 157, 10);
    lvl_put(L, "torch", 163, 6);
    lvl_put(L, "door", 167, 10);
    lvl_put(L, "torch", 170, 7);
    return L;
}

/// Level 6: the last stage of the caverns, an ancient bone pit. Dim again, purple-brown.
/// Little skeletons with swords and skeleton birds: only a boost breaks them (jump over
/// them or boost into them). Loose rocks in the roof, a low crawl, and at the bottom
/// Rex Bonejaw, the dinosaur skeleton, who can only be beaten with boosts too.
/// Reach: every step is 2 tiles, planks at most 3 above their floor, pits 3 wide with the same
/// floor height on both sides. No skeleton waits in the crawl (Peto can't boost in there).
function level_bonepit()
{
    var L = lvl_create("BONEYARD DEPTHS", 182, 15, "music_06.ogg", make_colour_rgb(16, 6, 18), make_colour_rgb(70, 34, 60));
    L.tileset = ts_bone;
    L.bg = [spr_bg_cave_far, spr_bg_cave_top, spr_bg_cave_near];
    L.bg_tint = make_colour_rgb(150, 105, 150);
    L.cloud_drift = 0;
    L.deco = "bone";
    L.vine_odds = 1;
    L.mushrooms = false;
    L.dark = 0.55;
    L.dark_col = make_colour_rgb(26, 6, 30);

    // The cave roof over the whole level (rows 0-1).
    lvl_rect(L, 0, 0, 181, 1, T_SOLID);

    // ---- The way down: the first skeleton ----
    lvl_ground(L, 0, 20, 11);
    lvl_put(L, "start", 3, 10);
    lvl_put(L, "torch", 2, 7);
    lvl_gems(L, 6, 9, 9);
    lvl_put(L, "torch", 11, 7);
    lvl_put(L, "letter", 12, 10);
    lvl_put(L, "skel", 17, 10);
    lvl_put(L, "torch", 19, 7);

    // ---- A pit, a plank and the first skeleton bird ----
    lvl_ground(L, 24, 40, 11);
    lvl_rect(L, 28, 8, 31, 8, T_ONEWAY);
    lvl_put(L, "letter", 29, 7);
    lvl_gems(L, 30, 31, 7);
    lvl_put(L, "bonebird", 33, 4);
    lvl_put(L, "torch", 35, 6);
    lvl_put(L, "skel", 37, 10);

    // ---- Up onto a long ledge: skeletons on patrol, rocks in the roof ----
    lvl_ground(L, 41, 60, 9);
    lvl_put(L, "letter", 43, 8);
    lvl_put(L, "rockfall", 47, 2);
    lvl_put(L, "skel", 50, 8);
    lvl_put(L, "torch", 52, 5);
    lvl_put(L, "bonebird", 54, 3);
    lvl_gems(L, 54, 56, 6);
    lvl_put(L, "letter", 55, 8);
    lvl_put(L, "flag", 58, 8);
    lvl_put(L, "super_egg", 59, 8);     // two players only

    // ---- Down two, then a low crawl through the bones (one tile high) ----
    lvl_ground(L, 61, 75, 11);
    lvl_put(L, "torch", 62, 7);
    lvl_rect(L, 64, 0, 72, 9, T_SOLID);
    lvl_gems(L, 65, 67, 10);
    lvl_gems(L, 69, 71, 10);
    lvl_put(L, "torch", 74, 7);

    // ---- The ossuary: a pit, planks to hide on, skeletons and birds ----
    lvl_ground(L, 76, 79, 11);
    lvl_ground(L, 83, 100, 11);
    lvl_put(L, "bonebird", 81, 4);
    lvl_put(L, "letter", 78, 8);
    lvl_put(L, "skel", 86, 10);
    lvl_put(L, "letter", 85, 10);
    lvl_rect(L, 89, 8, 92, 8, T_ONEWAY);
    lvl_put(L, "letter", 90, 7);
    lvl_put(L, "torch", 88, 5);
    lvl_put(L, "skel", 95, 10);
    lvl_put(L, "bonebird", 96, 4);
    lvl_put(L, "egg", 98, 10);
    lvl_put(L, "torch", 99, 6);

    // ---- Steps up to a skeleton's lookout and down again ----
    lvl_ground(L, 101, 106, 9);
    lvl_ground(L, 107, 112, 7);
    lvl_put(L, "skel", 110, 6);
    lvl_put(L, "letter", 109, 6);
    lvl_put(L, "torch", 106, 4);
    lvl_ground(L, 113, 120, 9);
    lvl_rect(L, 114, 6, 116, 6, T_ONEWAY);
    lvl_put(L, "letter", 115, 5);
    lvl_gems(L, 117, 119, 8);

    // ---- The rockfall gallery ----
    lvl_ground(L, 121, 181, 11);
    lvl_put(L, "rockfall", 124, 2);
    lvl_put(L, "bonebird", 126, 4);
    lvl_put(L, "letter", 127, 10);
    lvl_put(L, "rockfall", 129, 2);
    lvl_put(L, "skel", 131, 10);
    lvl_put(L, "torch", 132, 6);
    lvl_put(L, "flag", 135, 10);
    lvl_put(L, "egg", 136, 10);

    // ---- Rex Bonejaw's den: two planks, out of reach of his tail ----
    L.arena = [139, 170];
    lvl_put(L, "torch", 140, 5);
    lvl_rect(L, 144, 8, 147, 8, T_ONEWAY);
    lvl_put(L, "torch", 151, 5);
    lvl_rect(L, 157, 8, 160, 8, T_ONEWAY);
    lvl_put(L, "torch", 162, 5);
    lvl_put(L, "boss_dino", 164, 10);
    lvl_put(L, "torch", 171, 6);
    lvl_put(L, "door", 176, 10);
    lvl_put(L, "torch", 180, 7);
    return L;
}

/// Level 7: under the caverns, a sunken grotto of sand, rocks and water. Lakes to swim
/// across (snakes float and can jump out of the water), currents that drag the snakes along
/// (a friendly one across the first lake, a water spout up to a high ledge, a flooded tunnel
/// that sweeps you through; and a dangerous one pulling towards a waterfall), jumping
/// piranhas, and Baron Clawbucks the giant crab at the end.
/// Reach: steps are 2 tiles, letters at most 3 above a floor or the water surface, log gaps
/// at most 3 wide; the high ledge is reached by the spout, and left again by steps (and back).
/// No letters in the flooded tunnel or the crab's arena.
function level_grotto()
{
    var L = lvl_create("SUNKEN GROTTO", 190, 15, "music_05.ogg", make_colour_rgb(4, 20, 30), make_colour_rgb(30, 92, 112));
    L.tileset = ts_sand;
    L.bg = [spr_bg_cave_far, spr_bg_cave_top, spr_bg_cave_near];
    L.bg_tint = make_colour_rgb(110, 170, 185);
    L.cloud_drift = 0;
    L.deco = "sea";
    L.vine_odds = 1;
    L.mushrooms = false;
    L.dark = 0.3;
    L.dark_col = make_colour_rgb(2, 16, 26);

    // The cave roof over the whole level (rows 0-1).
    lvl_rect(L, 0, 0, 189, 1, T_SOLID);

    // ---- The shore ----
    lvl_ground(L, 0, 24, 11);
    lvl_put(L, "start", 3, 10);
    lvl_put(L, "torch", 2, 7);
    lvl_gems(L, 6, 9, 9);
    lvl_put(L, "letter", 12, 8);
    lvl_put(L, "torch", 14, 7);
    lvl_rect(L, 18, 9, 19, 10, T_SOLID);
    lvl_put(L, "bat_crack", 21, 2);
    lvl_put(L, "letter", 22, 8);

    // ---- Lake 1: a gentle current carries you across; piranhas below ----
    lvl_ground(L, 25, 40, 13);
    lvl_water(L, 25, 11, 40, 12);
    lvl_current(L, 25, 11, 40, 12, 1.3, 0);
    lvl_put(L, "piranha", 29, 11);
    lvl_put(L, "letter", 33, 8);
    lvl_put(L, "piranha", 36, 11);

    // ---- Sand and rocks, then a pool with a water spout up the cliff ----
    lvl_ground(L, 41, 56, 11);
    lvl_put(L, "torch", 43, 7);
    lvl_gems(L, 45, 47, 9);
    lvl_put(L, "letter", 47, 8);
    lvl_put(L, "bat_crack", 50, 2);
    lvl_rect(L, 52, 9, 53, 10, T_SOLID);
    lvl_ground(L, 57, 60, 13);
    lvl_water(L, 57, 11, 60, 12);
    lvl_current(L, 58, 2, 59, 12, 0, -6.5);   // the spout lifts you up past the ledge
    lvl_put(L, "torch", 56, 7);

    // ---- The high ledge, and steps down its far side (and back up) ----
    lvl_ground(L, 61, 75, 5);
    lvl_put(L, "torch", 64, 2);
    lvl_put(L, "letter", 68, 3);
    lvl_gems(L, 70, 72, 3);
    lvl_ground(L, 76, 78, 7);
    lvl_ground(L, 79, 81, 9);
    lvl_put(L, "letter", 80, 6);
    lvl_ground(L, 82, 86, 11);
    lvl_put(L, "flag", 84, 10);
    lvl_put(L, "super_egg", 85, 10);    // two players only

    // ---- Lake 2, the falls: a strong current drags you under the floating logs and on to
    //      the waterfall. Hop from log to log (gaps 2-3 wide); in the water, swim hard or jump. ----
    lvl_ground(L, 87, 103, 13);
    lvl_water(L, 87, 11, 103, 12);
    lvl_current(L, 87, 11, 103, 12, 1.8, 0);
    lvl_rect(L, 89, 10, 90, 10, T_ONEWAY);
    lvl_rect(L, 93, 10, 94, 10, T_ONEWAY);
    lvl_rect(L, 97, 10, 98, 10, T_ONEWAY);
    lvl_rect(L, 101, 10, 102, 10, T_ONEWAY);
    lvl_put(L, "piranha", 92, 11);
    lvl_put(L, "letter", 98, 6);
    lvl_put(L, "piranha", 100, 11);
    lvl_put(L, "torch", 96, 6);
    lvl_current(L, 104, 11, 105, 14, 0, 5);   // the waterfall into the pit

    // ---- Sand, then a flooded tunnel: no air, and a current sweeps you through ----
    lvl_ground(L, 106, 114, 11);
    lvl_put(L, "torch", 107, 7);
    lvl_rect(L, 109, 9, 110, 10, T_SOLID);
    lvl_put(L, "letter", 112, 8);
    lvl_rect(L, 115, 0, 126, 9, T_SOLID);
    lvl_ground(L, 115, 126, 13);
    lvl_water(L, 115, 10, 126, 12);
    lvl_current(L, 115, 10, 126, 12, 2.2, 0);
    lvl_gems(L, 117, 124, 10);

    // ---- A piranha pool under a plank, and the beach ----
    lvl_ground(L, 127, 130, 11);
    lvl_ground(L, 131, 134, 13);
    lvl_water(L, 131, 11, 134, 12);
    lvl_rect(L, 130, 8, 135, 8, T_ONEWAY);
    lvl_put(L, "letter", 132, 6);
    lvl_put(L, "piranha", 133, 11);
    lvl_ground(L, 135, 189, 11);
    lvl_put(L, "torch", 128, 7);
    lvl_put(L, "letter", 137, 8);
    lvl_put(L, "flag", 139, 10);
    lvl_put(L, "egg", 140, 10);
    lvl_put(L, "bat_crack", 140, 2);

    // ---- Baron Clawbucks' beach: two planks to get above his claws and banknotes ----
    L.arena = [143, 175];
    lvl_put(L, "torch", 145, 5);
    lvl_rect(L, 149, 8, 152, 8, T_ONEWAY);
    lvl_put(L, "torch", 158, 5);
    lvl_rect(L, 164, 8, 167, 8, T_ONEWAY);
    lvl_put(L, "torch", 171, 5);
    lvl_put(L, "boss_crab", 170, 10);
    lvl_put(L, "torch", 178, 6);
    lvl_put(L, "door", 184, 10);
    lvl_put(L, "torch", 187, 7);
    return L;
}

/// Level 8: the deep. Completely under water: the snakes swim anywhere (Jump/Up swims up,
/// Down dives). Reefs, a channel with a current against you, a vent that lifts you to a high
/// shelf, a down-current over a bed of sea urchins, a jellyfish forest with a fast lane
/// along the top, a reef maze, and at the end Queen Voltella guarding a huge sunken ship
/// (only its bow shows here; level 9 is inside it). The way in is the hole in its hull.
/// Reach: everything is open water, so every place can be swum to; passages are 3+ tiles
/// tall and no letter sits in one, or in the queen's arena.
function level_deep()
{
    var L = lvl_create("THE DEEP", 200, 20, "music_05.ogg", make_colour_rgb(2, 10, 30), make_colour_rgb(10, 50, 90));
    L.tileset = ts_sand;
    L.bg = [spr_bg_cave_far, spr_bg_cave_top, spr_bg_cave_near];
    L.bg_tint = make_colour_rgb(70, 120, 170);
    L.cloud_drift = 0;
    L.deco = "sea";
    L.vine_odds = 2;
    L.mushrooms = false;
    L.dark = 0.45;
    L.dark_col = make_colour_rgb(0, 8, 26);
    L.swim = "free";

    // Rock above, water everywhere below it.
    lvl_rect(L, 0, 0, 199, 1, T_SOLID);
    lvl_water(L, 0, 2, 199, 19);

    // ---- The sea floor where you start ----
    lvl_ground(L, 0, 24, 16);
    lvl_put(L, "start", 3, 15);
    lvl_put(L, "anemone", 2, 15);
    lvl_gems(L, 6, 10, 12);
    lvl_put(L, "letter", 12, 10);
    lvl_put(L, "anemone", 14, 15);
    lvl_put(L, "piranha", 19, 9);
    lvl_rect(L, 21, 11, 22, 15, T_SOLID);

    // ---- Under the reef: a channel with a current pushing against you ----
    lvl_ground(L, 25, 50, 17);
    lvl_rect(L, 30, 2, 44, 8, T_SOLID);
    lvl_current(L, 28, 9, 46, 16, -1.3, 0);
    lvl_put(L, "anemone", 27, 16);
    lvl_gems(L, 31, 33, 14);
    lvl_put(L, "octopus", 34, 14);
    lvl_put(L, "letter", 37, 12);
    lvl_put(L, "jelly", 40, 11);
    lvl_put(L, "anemone", 47, 16);

    // ---- A vent lifts you to a high shelf; beyond it, a down-current over sea urchins ----
    lvl_ground(L, 51, 75, 18);
    lvl_put(L, "anemone", 52, 17);
    lvl_current(L, 54, 4, 55, 17, 0, -3.5);
    lvl_rect(L, 58, 5, 67, 6, T_SOLID);
    lvl_put(L, "letter", 62, 4);
    lvl_put(L, "octopus", 66, 3);
    lvl_rect(L, 60, 17, 66, 17, T_SPIKES);
    lvl_current(L, 60, 8, 66, 16, 0, 2.2);
    lvl_put(L, "jelly", 63, 11);
    lvl_put(L, "piranha", 70, 8);
    lvl_put(L, "letter", 72, 10);
    lvl_put(L, "jelly", 70, 14);
    lvl_put(L, "anemone", 73, 17);

    // ---- The jellyfish forest, with a fast lane along the top ----
    lvl_ground(L, 76, 100, 17);
    lvl_put(L, "flag", 77, 16);
    lvl_put(L, "super_egg", 78, 16);    // two players only
    lvl_current(L, 78, 3, 99, 6, 1.8, 0);
    lvl_gems(L, 85, 95, 4);
    lvl_put(L, "jelly", 80, 8);
    lvl_put(L, "anemone", 82, 16);
    lvl_put(L, "jelly", 84, 13);
    lvl_put(L, "jelly", 88, 9);
    lvl_put(L, "letter", 90, 15);
    lvl_put(L, "jelly", 92, 12);
    lvl_put(L, "anemone", 94, 16);
    lvl_put(L, "jelly", 96, 8);

    // ---- The reef maze: through a gap low, over a wall, under a wall ----
    lvl_ground(L, 101, 125, 18);
    lvl_rect(L, 104, 2, 107, 9, T_SOLID);
    lvl_rect(L, 104, 13, 107, 17, T_SOLID);
    lvl_put(L, "anemone", 109, 17);
    lvl_put(L, "letter", 110, 6);
    lvl_put(L, "piranha", 110, 12);
    lvl_rect(L, 113, 6, 116, 17, T_SOLID);
    lvl_put(L, "piranha", 118, 9);
    lvl_put(L, "letter", 118, 14);
    lvl_put(L, "anemone", 118, 17);
    lvl_rect(L, 120, 2, 123, 11, T_SOLID);
    lvl_put(L, "anemone", 124, 17);

    // ---- Open water before the wreck: a current helps you along the bottom ----
    lvl_ground(L, 126, 149, 16);
    lvl_current(L, 126, 11, 148, 15, 1.4, 0);
    lvl_put(L, "letter", 128, 9);
    lvl_put(L, "anemone", 129, 15);
    lvl_put(L, "piranha", 131, 6);
    lvl_put(L, "octopus", 133, 13);
    lvl_put(L, "jelly", 136, 8);
    lvl_put(L, "letter", 138, 5);
    lvl_put(L, "octopus", 141, 12);
    lvl_put(L, "anemone", 143, 15);
    lvl_put(L, "jelly", 145, 6);
    lvl_put(L, "letter", 146, 10);
    lvl_put(L, "flag", 147, 15);
    lvl_put(L, "egg", 148, 15);

    // ---- Queen Voltella's water, in front of the sunken ship ----
    lvl_ground(L, 150, 199, 17);
    L.arena = [151, 180];
    lvl_put(L, "anemone", 153, 16);
    lvl_rect(L, 156, 15, 157, 16, T_SOLID);
    lvl_put(L, "anemone", 163, 16);
    lvl_put(L, "boss_jelly", 168, 9);
    lvl_put(L, "anemone", 171, 16);
    lvl_rect(L, 174, 15, 175, 16, T_SOLID);
    lvl_put(L, "anemone", 179, 16);
    // The bow of the huge wreck; its hull runs on past the end of the level.
    lvl_put(L, "wreck", 181, 16);
    lvl_put(L, "door", 190, 16);
    return L;
}

function level_list()
{
    return [level_greenleaf, level_mushroom, level_tangleroot, level_emberstone, level_shadowrock, level_bonepit, level_grotto, level_deep];
}
