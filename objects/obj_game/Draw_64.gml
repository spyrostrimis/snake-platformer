/// Draw GUI at 640 x 360 (the single camera view size): the HUD during play (one per snake,
/// in its own half of the screen with two players), and the title, credits, pause, tally,
/// game-over and victory screens.

// Everything below is laid out in 640 x 360; this scales it to the 1280 x 720 GUI.
matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, 2, 2, 1));
var _blink = (frame div 25) mod 2 == 0;
var _playing = state == "play" || state == "paused" || state == "clear";
var _views = (_playing && split_on) ? 2 : 1;
var _vh = 360 / _views;     // height of each snake's part of the HUD

// Floating scores, from world positions to the screen, in every view.
for (var _v = 0; _v < _views; _v++)
{
    var _cam = view_camera[_v];
    var _cx = camera_get_view_x(_cam);
    var _cy = camera_get_view_y(_cam);
    var _sx = 640 / camera_get_view_width(_cam);
    var _sy = _vh / camera_get_view_height(_cam);
    for (var _i = 0; _i < array_length(popups); _i++)
    {
        var _p = popups[_i];
        var _px = (_p.x - _cx) * _sx;
        var _py = (_p.y - _cy) * _sy;
        if (_px > -40 && _px < 680 && _py > -20 && _py < _vh) hud_text(_px, _v * _vh + _py, _p.text, 0.4 * _sx, fa_center, c_white, min(1, _p.life / 20));
    }
}

if (state == "title" || state == "credits" || state == "online")
{
    // Darker behind the busier pages, so their text reads well over the scenery.
    var _busy = state == "online" || state == "credits" || (state == "title" && (menu_page == "options" || menu_page == "keys" || menu_page == "local"));
    draw_set_colour(c_black);
    draw_set_alpha(_busy ? 0.6 : 0.35);
    draw_rectangle(0, 0, 640, 360, false);
    draw_set_alpha(1);
}

var _gold = make_colour_rgb(255, 230, 120);
var _title_col = make_colour_rgb(255, 200, 80);
var _hint_col = make_colour_rgb(190, 210, 255);
var _dim_col = make_colour_rgb(150, 160, 200);

switch (state)
{
    case "title":
        switch (menu_page)
        {
            case "main":
                draw_sprite_ext(spr_logo, 0, 320, 92 + sin(frame * 0.04) * 4, 0.78, 0.78, sin(frame * 0.03) * 1.5, c_white, 1);
                menu_list(320, 178, ["1 PLAYER", "2 PLAYERS", "OPTIONS", "ABOUT"], menu_sel.main, 30, 0.55);
                body_text(320, 330, "Arrows: choose    Enter: OK    M: music on / off", _hint_col, fa_center);
                break;

            case "solo":
                hud_text(320, 22, "1 PLAYER", 0.75, fa_center, _title_col);
                body_text(320, 62, "Choose your snake", _hint_col, fa_center);
                // Both snakes, the chosen one big and bright.
                for (var _i = 0; _i < array_length(snakes); _i++)
                {
                    var _sn = snakes[_i];
                    var _on = _i == character;
                    var _sx = 230 + _i * 180;
                    var _bob = _on ? sin(frame * 0.1) * 3 : 0;
                    draw_sprite_ext(_sn.head, 0, _sx, 132 + _bob, _on ? 2.2 : 1.5, _on ? 2.2 : 1.5, 0, _on ? c_white : make_colour_rgb(90, 90, 110), 1);
                    hud_text(_sx, 172, _sn.name, _on ? 0.55 : 0.42, fa_center, _on ? _sn.colour : _dim_col);
                }
                title_arrow(130, 140, -1, _blink ? c_white : _hint_col);
                title_arrow(510, 140, 1, _blink ? c_white : _hint_col);
                // The power text names the default boost key, C: show the one set in the Options.
                body_text(320, 204, string_replace(snakes[character].power, "C:", keys_text(settings.keys.solo.boost) + ":"), c_white, fa_center);
                if (_blink) hud_text(320, 230, "PRESS ENTER TO START", 0.45, fa_center);
                if (settings.dev_level > 0) body_text(320, 254, "Starting at level " + string(settings.dev_level + 1) + " (Developer option)", make_colour_rgb(255, 170, 90), fa_center);
                var _k = settings.keys.solo;
                body_text(320, 274, "Move: " + keys_text(_k.left) + ", " + keys_text(_k.right) + "    Jump: " + keys_text(_k.jump), c_white, fa_center);
                body_text(320, 290, "Tongue: " + keys_text(_k.tongue) + "    Roll (hold): " + keys_text(_k.roll) + "    Boost: " + keys_text(_k.boost), c_white, fa_center);
                body_text(320, 306, "In a level:  P pause    F1 back to the checkpoint    F2 restart.  Keys: Options > Controls", _hint_col, fa_center);
                body_text(320, 330, "Left / Right: choose    Enter: start    Esc: back", _hint_col, fa_center);
                break;

            case "duo":
                hud_text(320, 40, "2 PLAYERS", 0.75, fa_center, _title_col);
                menu_list(320, 130, ["LOCAL", "ONLINE"], menu_sel.duo, 36, 0.6);
                var _about = (menu_sel.duo == 0)
                    ? "Two players on this PC: split screen, one keyboard (or gamepads)."
                    : "Play with a friend on another PC: host a room or join with its code.";
                body_text(320, 226, _about, c_white, fa_center);
                body_text(320, 330, "Arrows: choose    Enter: OK    Esc: back", _hint_col, fa_center);
                break;

            case "local":
                hud_text(320, 22, "2 PLAYERS - LOCAL", 0.7, fa_center, _title_col);
                body_text(320, 60, "Shared word, own lives and misses. Player 1 plays on top, player 2 below.", _hint_col, fa_center);
                for (var _i = 0; _i < 2; _i++)
                {
                    var _sn = snakes[(_i == 0) ? character : 1 - character];
                    var _cx = 180 + _i * 280;
                    var _k = settings.keys[$ (_i == 0) ? "p1" : "p2"];
                    draw_sprite_ext(_sn.head, 0, _cx, 112 + sin(frame * 0.1 + _i * 3) * 3, 1.8, 1.8, 0, c_white, 1);
                    hud_text(_cx, 144, "P" + string(_i + 1) + " " + _sn.name, 0.48, fa_center, _sn.colour);
                    body_text(_cx, 174, "Move: " + keys_text(_k.left) + ", " + keys_text(_k.right) + "    Down: " + keys_text(_k.down), c_white, fa_center);
                    body_text(_cx, 190, "Jump: " + keys_text(_k.jump) + "    Tongue: " + keys_text(_k.tongue), c_white, fa_center);
                    body_text(_cx, 206, "Roll (hold): " + keys_text(_k.roll) + "    Boost: " + keys_text(_k.boost), c_white, fa_center);
                }
                title_arrow(320, 120, -1, _blink ? c_white : _hint_col);
                title_arrow(340, 120, 1, _blink ? c_white : _hint_col);
                if (_blink) hud_text(320, 240, "PRESS ENTER TO START", 0.45, fa_center);
                if (settings.dev_level > 0) body_text(320, 264, "Starting at level " + string(settings.dev_level + 1) + " (Developer option)", make_colour_rgb(255, 170, 90), fa_center);
                body_text(320, 286, "One gamepad plays as player 2; two gamepads give one each.  Keys: Options > Controls", _hint_col, fa_center);
                body_text(320, 330, "Left / Right: swap snakes    Enter: start    Esc: back", _hint_col, fa_center);
                break;

            case "options":
                hud_text(320, 14, "OPTIONS", 0.7, fa_center, _title_col);
                menu_panel(128, 44, 512, 296);
                var _rows = options_rows();
                var _y = 48;
                for (var _i = 0; _i < array_length(_rows); _i++)
                {
                    var _r = _rows[_i];
                    if (_r.header != "") { hud_text(150, _y + 2, _r.header, 0.3, fa_left, _hint_col); _y += 14; }
                    if (_r.name == "back") _y += 8;
                    var _on = _i == menu_sel.options;
                    if (_on)
                    {
                        draw_set_colour(make_colour_rgb(60, 80, 160));
                        draw_set_alpha(0.55);
                        draw_roundrect(140, _y - 1, 500, _y + 17, false);
                        draw_set_alpha(1);
                    }
                    var _lc = _on ? _gold : c_white;
                    var _label = "";
                    var _value = "";
                    switch (_r.name)
                    {
                        case "music":      _label = "Music volume"; break;
                        case "sfx":        _label = "Sound effects volume"; break;
                        case "controls":   _label = "Change keys"; _value = "Enter >"; break;
                        case "fullscreen": _label = "Full screen"; _value = settings.fullscreen ? "ON" : "OFF"; break;
                        case "dev_level":  _label = "Start at level"; _value = "< " + string(settings.dev_level + 1) + ": " + level_names[settings.dev_level] + " >"; break;
                        case "dev_lives":  _label = "Lives at the start"; _value = "< " + string(settings.dev_lives) + " >"; break;
                        case "no_damage":  _label = "No damage (pits still count)"; _value = settings.no_damage ? "ON" : "OFF"; break;
                        case "show_fps":   _label = "Show frames per second"; _value = settings.show_fps ? "ON" : "OFF"; break;
                        case "back":       _label = "Back"; break;
                    }
                    body_text(150, _y, _label, _lc, fa_left);
                    if (_r.name == "music" || _r.name == "sfx")
                    {
                        // A bar of ten blocks.
                        var _vol = settings[$ _r.name];
                        for (var _b = 0; _b < 10; _b++)
                        {
                            draw_set_colour((_b < _vol) ? (_on ? _gold : make_colour_rgb(140, 230, 120)) : make_colour_rgb(40, 46, 80));
                            draw_rectangle(340 + _b * 13, _y + 3, 350 + _b * 13, _y + 13, false);
                        }
                        draw_set_colour(c_white);
                        body_text(490, _y, string(_vol * 10) + "%", _lc, fa_right);
                    }
                    else if (_value != "") body_text(490, _y, _value, (_value == "ON") ? make_colour_rgb(140, 255, 140) : _lc, fa_right);
                    _y += 20;
                }
                var _sel_row = _rows[menu_sel.options].name;
                if (string_pos("dev_", _sel_row) == 1 || _sel_row == "no_damage" || _sel_row == "show_fps")
                    body_text(320, 308, "Developer options, for testing: they change games on this PC only, not online.", make_colour_rgb(255, 170, 90), fa_center);
                body_text(320, 330, "Up / Down: choose    Left / Right: change    Enter: OK    Esc: back", _hint_col, fa_center);
                break;

            case "keys":
                hud_text(320, 12, "CONTROLS", 0.7, fa_center, _title_col);
                var _sets = key_sets();
                var _acts = key_actions();
                var _set_name = _sets[keys_set].name;
                var _keys = settings.keys[$ _set_name];
                menu_panel(96, 36, 584, 274);
                // The key sets, as tabs.
                for (var _i = 0; _i < array_length(_sets); _i++)
                {
                    var _tx = 200 + _i * 120;
                    var _on = _i == keys_set;
                    hud_text(_tx, 44, _sets[_i].label, 0.34, fa_center, _on ? _gold : _dim_col);
                    if (_on)
                    {
                        draw_set_colour((keys_row == 0 && _blink) ? _gold : make_colour_rgb(190, 150, 60));
                        draw_roundrect(_tx - 54, 40, _tx + 54, 58, true);
                        draw_set_colour(c_white);
                    }
                }
                var _set_about = ["Playing alone", "Two players on one keyboard: player 1 (top screen)", "Two players on one keyboard: player 2 (bottom screen)"];
                body_text(320, 64, _set_about[keys_set], _hint_col, fa_center);

                // The table: one row per action, one column per key slot.
                var _ty = 86;
                body_text(110, _ty, "Action", _dim_col, fa_left);
                for (var _c = 0; _c < KEY_SLOTS; _c++) body_text(290 + _c * 80, _ty, "Key " + string(_c + 1), _dim_col, fa_center);
                for (var _i = 0; _i < array_length(_acts); _i++)
                {
                    var _ry = _ty + 18 + _i * 18;
                    var _row_on = keys_row == _i + 1;
                    body_text(110, _ry, _acts[_i].label, _row_on ? _gold : c_white, fa_left);
                    var _list = _keys[$ _acts[_i].name];
                    for (var _c = 0; _c < KEY_SLOTS; _c++)
                    {
                        var _cx = 290 + _c * 80;
                        var _cell_on = _row_on && _c == keys_col;
                        if (_cell_on)
                        {
                            draw_set_colour(make_colour_rgb(60, 80, 160));
                            draw_set_alpha(0.6);
                            draw_roundrect(_cx - 36, _ry - 1, _cx + 36, _ry + 16, false);
                            draw_set_alpha(1);
                            draw_set_colour(keys_wait ? _gold : make_colour_rgb(190, 150, 60));
                            draw_roundrect(_cx - 36, _ry - 1, _cx + 36, _ry + 16, true);
                            draw_set_colour(c_white);
                        }
                        var _txt = key_name(_list[_c]);
                        var _col = (_list[_c] < 0) ? make_colour_rgb(90, 100, 140) : c_white;
                        if (key_clashes(settings.keys, _set_name, _acts[_i].name, _list[_c])) _col = make_colour_rgb(255, 110, 110);
                        if (_cell_on && keys_wait) { _txt = _blink ? "press a key" : ""; _col = _gold; }
                        body_text(_cx, _ry, _txt, _col, fa_center);
                    }
                }
                var _reset_row = array_length(_acts) + 1;
                menu_list(320, 236, ["RESET TO DEFAULTS", "BACK"], keys_row - _reset_row, 20, 0.36);
                if (keys_wait) body_text(320, 284, "Press the new key for " + string_lower(_acts[keys_row - 1].label) + "    (Esc: cancel)", _gold, fa_center);
                else if (keys_note_t > 0) body_text(320, 284, keys_note, make_colour_rgb(255, 200, 120), fa_center);
                body_text(320, 308, "Gamepads: stick / D-pad move, A jump, X tongue, hold RB / LB / Y roll, B boost.", _dim_col, fa_center);
                body_text(320, 330, "Up / Down: choose    Left / Right: key slot    Enter: change    Delete: clear    Esc: back", _hint_col, fa_center);
                break;
        }
        break;

    case "online":
        hud_text(320, 22, "ONLINE", 0.8, fa_center, _title_col);
        switch (online_mode)
        {
            case "menu":
                body_text(320, 66, "Play with a friend on another PC.", _hint_col, fa_center);
                menu_list(320, 110, ["HOST A ROOM", "JOIN WITH A CODE", "JOIN BY IP"], menu_sel.online, 34, 0.5);
                var _about = ["Make a room and give your friend its code (it's copied to the clipboard).",
                              "Type the 5-character code your friend's room shows.",
                              "The fallback when the code doesn't connect: type the host's IP (for example its Tailscale address), then the code."];
                body_text(320, 232, _about[menu_sel.online], c_white, fa_center);
                body_text(320, 330, "Arrows: choose    Enter: OK    Esc: back", _hint_col, fa_center);
                break;

            case "type_ip":
                hud_text(320, 120, "HOST IP", 0.5, fa_center);
                hud_text(320, 160, online_ip + (_blink ? "-" : " "), 0.7, fa_center, _gold);
                body_text(320, 220, "Type the IP, then Enter.    Esc: back", c_white, fa_center);
                break;

            case "type":
                hud_text(320, 120, "ROOM CODE", 0.5, fa_center);
                var _shown = online_code;
                while (string_length(_shown) < NET_CODE_LEN) _shown += "-";
                hud_text(320, 158, _shown, 1, fa_center, _gold);
                if (online_ip != "") body_text(320, 214, "Joining " + online_ip, c_white, fa_center);
                body_text(320, 232, "Type the 5-character code your friend sees, then Enter.    Esc: back", c_white, fa_center);
                break;

            case "room":
                var _n = net;
                if (_n.role == "host")
                {
                    body_text(320, 92, "Your room code (copied to the clipboard):", c_white, fa_center);
                    hud_text(320, 108, _n.code, 1.1, fa_center, _gold);
                }
                else hud_text(320, 108, "ROOM " + _n.code, 0.7, fa_center, _gold);
                var _col = (_n.state == "connected") ? make_colour_rgb(140, 255, 140) : ((_n.state == "failed" || _n.state == "lost") ? make_colour_rgb(255, 130, 140) : c_white);
                body_text(320, 168, _n.status, _col, fa_center);
                if (_n.detail != "") body_text(320, 186, _n.detail, make_colour_rgb(255, 230, 140), fa_center);
                if (_n.state == "connected")
                {
                    var _ping = (_n.ping_ms < 0) ? "..." : string(round(_n.ping_ms)) + " ms";
                    body_text(320, 186, "Ping " + _ping + "    linked over " + _n.link + " with " + _n.peer_ip + ":" + string(_n.peer_port), make_colour_rgb(140, 255, 140), fa_center);
                    body_text(320, 204, "Space: wave to your friend    You waved " + string(_n.waves_out) + "    Your friend waved " + string(_n.waves_in), _gold, fa_center);
                    // The lobby: the host picks the snakes and starts the game.
                    var _mine = (_n.role == "host") ? snakes[character] : snakes[1 - net_lobby_c];
                    var _yours = (_n.role == "host") ? snakes[1 - character] : snakes[net_lobby_c];
                    body_text(320, 222, "You play " + _mine.nice + " (" + _mine.kind + "), your friend plays " + _yours.nice + ".", _mine.colour, fa_center);
                    if (_n.role == "host")
                    {
                        if (_blink) hud_text(320, 244, "ENTER: START THE GAME", 0.45, fa_center, make_colour_rgb(160, 255, 140));
                        body_text(320, 266, "Left / Right: swap snakes    1-" + string(min(array_length(levels), 9)) + ": start at that level", c_white, fa_center);
                    }
                    else body_text(320, 250, "Waiting for your friend to start the game...", make_colour_rgb(160, 255, 140), fa_center);
                }
                var _me = (_n.pub_ip != "") ? _n.pub_ip + ":" + string(_n.pub_port) : "unknown";
                body_text(320, 296, "Your internet address: " + _me + "    Local port: " + string(_n.lport), make_colour_rgb(170, 190, 230), fa_center);
                body_text(320, 318, (net.state == "connected") ? "T: chat with your friend    Esc: leave the room" : "Esc: leave the room", _hint_col, fa_center);
                break;
        }
        break;

    case "credits":
        hud_text(320, 20, "ABOUT", 0.8, fa_center, _title_col);
        menu_panel(108, 52, 532, 268);
        body_text(320, 58, "SNAGMAN: a tribute to the 90s PC platformers, starring Peto and Sockee.", _hint_col, fa_center);
        hud_text(320, 82, "CREDITS", 0.4, fa_center, _gold);
        body_text(320, 102, "Game, art and code: Spyros Trimis, Can Dereli and Claude, made with GameMaker", c_white, fa_center);
        body_text(320, 126, "Music: \"Jazz Jackrabbit 2 - 20th Anniversary Tribute Album\" by the JJ20 Team", make_colour_rgb(255, 230, 140), fa_center);
        body_text(320, 144, "jj20.bandcamp.com - licensed CC BY-NC-ND 4.0, used unchanged", make_colour_rgb(255, 230, 140), fa_center);
        body_text(320, 168, "Tubelectric: Megahit    Jazz Jackrabbit 2 Theme: Zyrit    Carrotus: Vincenzo", c_white, fa_center);
        body_text(320, 186, "Pull Back the Bass, Water Level: BPStudio    Dark Groove: Gridscape", c_white, fa_center);
        body_text(320, 204, "Bonus Stage: Bitrotator    Labratory Level: SIDNIFY    Jazz be Damned: Ziona", c_white, fa_center);
        body_text(320, 230, "The album covers music by Alexander Brandon; Jazz Jackrabbit 2 belongs to Epic Games.", _hint_col, fa_center);
        body_text(320, 248, "This game is a free, unofficial fan tribute and is not endorsed by Epic Games.", _hint_col, fa_center);
        body_text(320, 330, "Enter / Esc: back", _hint_col, fa_center);
        break;

    case "play":
    case "paused":
    case "clear":
        // One HUD per snake, each in its own part of the screen (the whole of it when alone).
        for (var _k = 0; _k < array_length(pl); _k++)
        {
            // Online, only this PC's snake has a HUD.
            if (net_mode != "" && _k != my_pid) continue;
            var _p = pl[_k];
            var _oy = (net_mode != "") ? 0 : _k * _vh;

            // Octopus ink on this snake's screen: dark blots that fade away.
            if (instance_exists(_p.inst) && _p.inst.inked > 0)
            {
                draw_set_alpha(min(1, _p.inst.inked / 60) * 0.9);
                draw_set_colour(make_colour_rgb(22, 10, 34));
                for (var _b = 0; _b < 7; _b++)
                {
                    var _bx = 70 + ((_b * 173) mod 500);
                    var _bly = _oy + 50 + ((_b * 97) mod max(40, _vh - 100));
                    var _br = (45 + ((_b * 37) mod 45)) * ((_vh < 300) ? 0.6 : 1);
                    draw_circle(_bx, _bly, _br, false);
                    draw_circle(_bx + _br * 0.7, _bly + _br * 0.4, _br * 0.55, false);
                    draw_circle(_bx - _br * 0.6, _bly + _br * 0.5, _br * 0.4, false);
                }
                draw_set_alpha(1);
                draw_set_colour(c_white);
            }

            // Score, top left, seven digits like the old games.
            var _sc = string(_p.score_now);
            while (string_length(_sc) < 7) _sc = "0" + _sc;
            hud_text(10, _oy + 6, _sc, 0.62);
            draw_sprite_ext(spr_gem, 0, 18, _oy + 44, 0.8, 0.8, 0, c_white, 1);
            hud_text(30, _oy + 35, "x" + string(_p.gems), 0.42);

            // Hearts, top right.
            for (var _i = 0; _i < 5; _i++)
            {
                draw_sprite_ext(spr_heart, 0, 626 - _i * 22, _oy + 16, 1, 1, 0, (_i < _p.hearts) ? c_white : make_colour_rgb(50, 40, 60), (_i < _p.hearts) ? 1 : 0.6);
            }

            // The shared word, top centre: a bubble per letter.
            var _n = string_length(word);
            var _wx = 320 - (_n * 26) / 2 + 13;
            for (var _i = 0; _i < _n; _i++)
            {
                var _ch = string_char_at(word, _i + 1);
                var _found = letter_is_guessed(guessed, _ch);
                draw_sprite_ext(spr_orb, 0, _wx + _i * 26, _oy + 22, 0.72, 0.72, 0, _found ? c_white : make_colour_rgb(90, 100, 140), 1);
                hud_text(_wx + _i * 26, _oy + 13, _found ? _ch : "?", 0.42, fa_center, _found ? c_white : make_colour_rgb(160, 170, 210));
            }

            // A boss's name and health bar, under the word: only on the screen of a snake that
            // is in the boss area (the other snake may still be far behind).
            var _sees_boss = instance_exists(boss) && boss.active;
            if (_sees_boss && instance_exists(_p.inst)) _sees_boss = _p.inst.x > boss.arena_x1 - 200 && _p.inst.x < boss.arena_x2 + 200;
            if (_sees_boss)
            {
                var _bw = 220;
                var _bx = 320 - _bw / 2;
                hud_text(320, _oy + 42, boss.boss_name, 0.36, fa_center, make_colour_rgb(255, 160, 120));
                draw_set_colour(make_colour_rgb(20, 16, 40));
                draw_roundrect(_bx - 3, _oy + 60, _bx + _bw + 3, _oy + 72, false);
                var _f = max(0, boss.hp / boss.hp_max);
                draw_rectangle_colour(_bx, _oy + 63, _bx + _bw * _f, _oy + 69, c_red, make_colour_rgb(255, 200, 60), make_colour_rgb(255, 200, 60), c_red, false);
                draw_set_colour(c_white);
                draw_roundrect(_bx - 3, _oy + 60, _bx + _bw + 3, _oy + 72, true);
            }

            // Lives, bottom left: this snake's own head.
            var _by = _oy + _vh;
            draw_sprite_ext(_p.skin.head, 0, 24, _by - 20, 0.75, 0.75, 0, c_white, 1);
            hud_text(42, _by - 34, "x" + string(_p.lives_left), 0.5);

            // Misses, bottom right: this snake's wrong letters with a red cross.
            hud_text(452, _by - 30, "MISSES", 0.34, fa_left, make_colour_rgb(255, 170, 170));
            for (var _i = 0; _i < max_misses; _i++)
            {
                var _mx = 520 + _i * 19;
                draw_set_colour(make_colour_rgb(20, 24, 60));
                draw_set_alpha(0.6);
                draw_roundrect(_mx - 8, _by - 34, _mx + 8, _by - 12, false);
                draw_set_alpha(1);
                if (_i < string_length(_p.miss_letters))
                {
                    hud_text(_mx, _by - 33, string_char_at(_p.miss_letters, _i + 1), 0.4, fa_center, make_colour_rgb(200, 200, 220));
                    draw_set_colour(make_colour_rgb(255, 40, 60));
                    draw_line_width(_mx - 7, _by - 14, _mx + 7, _by - 32, 2);
                }
            }

            // The friend's Box Snake Egg, when it's off this snake's screen: a small arrow at
            // the edge, in the friend's colour, points the way.
            if (!_p.out && instance_exists(obj_box_egg))
            {
                var _ecam = view_camera[(net_mode != "") ? 0 : _k];
                var _ecx = camera_get_view_x(_ecam);
                var _ecy = camera_get_view_y(_ecam);
                var _esx = 640 / camera_get_view_width(_ecam);
                var _esy = _vh / camera_get_view_height(_ecam);
                with (obj_box_egg)
                {
                    if (broken || pid == _p.pid) continue;
                    var _ex = (x - _ecx) * _esx;
                    var _ey = _oy + (y - 8 - _ecy) * _esy;
                    if (_ex >= 0 && _ex <= 640 && _ey >= _oy && _ey <= _oy + _vh) continue;
                    var _ang = point_direction(320, _oy + _vh / 2, _ex, _ey);
                    var _ax = clamp(_ex, 20, 620);
                    var _ay = clamp(_ey, _oy + 20, _oy + _vh - 20);
                    var _col = skin_of().colour;
                    var _al = 0.6 + 0.25 * sin(obj_game.frame * 0.12);
                    draw_set_alpha(_al);
                    draw_set_colour(make_colour_rgb(16, 26, 64));
                    draw_triangle(_ax + lengthdir_x(12, _ang), _ay + lengthdir_y(12, _ang), _ax + lengthdir_x(10, _ang + 140), _ay + lengthdir_y(10, _ang + 140), _ax + lengthdir_x(10, _ang - 140), _ay + lengthdir_y(10, _ang - 140), false);
                    draw_set_colour(_col);
                    draw_triangle(_ax + lengthdir_x(9, _ang), _ay + lengthdir_y(9, _ang), _ax + lengthdir_x(7, _ang + 140), _ay + lengthdir_y(7, _ang + 140), _ax + lengthdir_x(7, _ang - 140), _ay + lengthdir_y(7, _ang - 140), false);
                    // A tiny egg behind the arrow, so it's clear what it points at.
                    var _bx = _ax - lengthdir_x(14, _ang);
                    var _bym = _ay - lengthdir_y(14, _ang);
                    draw_set_colour(make_colour_rgb(255, 244, 214));
                    draw_ellipse(_bx - 4, _bym - 5, _bx + 4, _bym + 5, false);
                    draw_set_alpha(1);
                    draw_set_colour(c_white);
                }
            }

            // Out of lives, inside a Box Snake Egg: this screen now follows the friend.
            var _egg_in = false;
            with (obj_box_egg) if (pid == _p.pid) _egg_in = true;
            if (_p.out && _egg_in && array_length(pl) == 2)
            {
                var _mate = pl[1 - _k];
                var _ty = _oy + _vh * 0.64;
                draw_set_colour(c_black);
                draw_set_alpha(0.15);
                draw_rectangle(0, _oy, 640, _oy + _vh, false);
                draw_set_alpha(1);
                hud_text(320, _ty, _p.skin.name + " IS A BOX SNAKE EGG", (_views == 1) ? 0.5 : 0.4, fa_center, _p.skin.colour);
                body_text(320, _ty + ((_views == 1) ? 28 : 20), "Watching " + _mate.skin.nice + ". When " + _mate.skin.nice + " breaks your egg, you're back with one life!", c_white, fa_center);
            }
            // Out of lives: say so over this snake's half, which now follows the other snake.
            else if (_p.out)
            {
                draw_set_colour(c_black);
                draw_set_alpha(0.35);
                draw_rectangle(0, _oy, 640, _oy + _vh, false);
                draw_set_alpha(1);
                hud_text(320, _oy + _vh / 2 - 22, _p.skin.name + " IS OUT", 0.6, fa_center, make_colour_rgb(255, 120, 130));
                body_text(320, _oy + _vh / 2 + 4, "Back with one life on the next level", c_white, fa_center);
            }
            // Messages, one at a time, in the middle of this snake's screen.
            else if (array_length(_p.messages) > 0 && state == "play")
            {
                var _m = _p.messages[0];
                hud_text(320, _oy + ((_views == 1) ? 120 : 84), _m.text, (_views == 1) ? 0.5 : 0.42, fa_center, c_white, min(1, _m.life / 20));
            }
        }

        // The line between the two halves.
        if (_views == 2)
        {
            draw_set_colour(make_colour_rgb(16, 26, 64));
            draw_rectangle(0, 178, 640, 181, false);
            draw_set_colour(c_white);
        }

        if (state == "paused")
        {
            draw_set_colour(c_black);
            draw_set_alpha(0.5);
            draw_rectangle(0, 0, 640, 360, false);
            draw_set_alpha(1);
            if (net_mode == "")
            {
                hud_text(320, 150, "PAUSED", 0.9, fa_center);
                body_text(320, 200, "P: carry on    N: skip level    Q: quit to the title screen", c_white, fa_center);
            }
            else
            {
                // Online: the one who paused gets the menu; the other is told who to wait for.
                var _friend = (array_length(pl) == 2) ? pl[1 - my_pid].skin : snakes[0];
                if (net_pause_me)
                {
                    hud_text(320, 140, "PAUSED", 0.9, fa_center);
                    body_text(320, 190, "P: carry on    " + ((net_mode == "host") ? "N: skip level    " : "") + "Q: leave the online game", c_white, fa_center);
                    body_text(320, 212, "Your friend's game is paused too.", make_colour_rgb(190, 210, 255), fa_center);
                    if (net_pause_peer) body_text(320, 234, _friend.nice + " has paused too: play carries on when you both do.", _friend.colour, fa_center);
                }
                else
                {
                    hud_text(320, 140, "WAIT! " + _friend.name + " HAS PAUSED HIS GAME!", 0.55, fa_center, _friend.colour);
                    body_text(320, 190, "The game carries on when " + _friend.nice + " comes back.    Q: leave the online game", c_white, fa_center);
                }
            }
        }
        if (state == "clear")
        {
            draw_set_colour(make_colour_rgb(10, 20, 60));
            draw_set_alpha(0.7);
            draw_roundrect(120, 80, 520, 290, false);
            draw_set_alpha(1);
            hud_text(320, 96, "LEVEL COMPLETE!", 0.8, fa_center, make_colour_rgb(160, 255, 140));
            hud_text(320, 140, word, 0.7, fa_center, make_colour_rgb(255, 220, 90));
            body_text(320, 178, "Letters x1000, time bonus, and 500 for every miss you saved", c_white, fa_center);
            var _done = true;
            for (var _k = 0; _k < array_length(pl); _k++)
            {
                var _p = pl[_k];
                if (_p.shown < _p.bonus) _done = false;
                var _label = (array_length(pl) == 1) ? "BONUS " : _p.skin.name + " BONUS ";
                hud_text(320, 200 + _k * 22, _label + string(_p.shown), 0.5, fa_center, (array_length(pl) == 1) ? c_white : _p.skin.colour);
            }
            if (net_mode == "client") body_text(320, 256, "Waiting for your friend to carry on...", c_white, fa_center);
            else if (_done && _blink) hud_text(320, 254, "PRESS ENTER", 0.5, fa_center);
        }
        break;

    case "netlost":
        hud_text(320, 130, "CONNECTION LOST", 0.9, fa_center, make_colour_rgb(255, 120, 130));
        body_text(320, 186, "Nothing more came from your friend's game.", c_white, fa_center);
        if (_blink) hud_text(320, 250, "PRESS ENTER", 0.5, fa_center);
        break;

    case "gameover":
        hud_text(320, 130, "GAME OVER", 1.1, fa_center, make_colour_rgb(255, 90, 110));
        hud_text(320, 186, "THE WORD WAS " + word, 0.5, fa_center);
        for (var _k = 0; _k < array_length(pl); _k++)
        {
            var _p = pl[_k];
            var _label = (array_length(pl) == 1) ? "SCORE " : _p.skin.name + " ";
            hud_text(320, 214 + _k * 24, _label + string(_p.score_now), 0.5, fa_center, (array_length(pl) == 1) ? c_white : _p.skin.colour);
        }
        if (_blink) hud_text(320, 274, "PRESS ENTER", 0.5, fa_center);
        break;

    case "victory":
        draw_set_colour(c_black);
        draw_set_alpha(0.4);
        draw_rectangle(0, 0, 640, 360, false);
        draw_set_alpha(1);
        hud_text(320, 110, "YOU DID IT!", 1.1, fa_center, make_colour_rgb(160, 255, 140));
        body_text(320, 170, "Every word found, every door open. The jungle is safe!", c_white, fa_center);
        for (var _k = 0; _k < array_length(pl); _k++)
        {
            var _p = pl[_k];
            var _label = (array_length(pl) == 1) ? "SCORE " : _p.skin.name + " ";
            hud_text(320, 200 + _k * 24, _label + string(_p.score_now), 0.6, fa_center, (array_length(pl) == 1) ? c_white : _p.skin.colour);
        }
        if (_blink) hud_text(320, 270, "PRESS ENTER", 0.5, fa_center);
        break;
}

// Online chat: the latest lines, and the box while typing.
chat_draw();

// Developer option: frames per second, bottom centre.
if (settings.show_fps) body_text(320, 344, "FPS " + string(fps) + " (" + string(round(fps_real)) + ")", make_colour_rgb(140, 255, 140), fa_center);
matrix_set(matrix_world, matrix_build_identity());
