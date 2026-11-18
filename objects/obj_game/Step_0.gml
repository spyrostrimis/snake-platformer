/// The run's state machine; the snake and creatures update themselves only during play.

frame++;
for (var _k = 0; _k < array_length(pl); _k++)
{
    var _msgs = pl[_k].messages;
    for (var _i = array_length(_msgs) - 1; _i >= 0; _i--)
    {
        // Only the oldest message counts down, so they show one after another.
        if (_i == 0) _msgs[0].life--;
        if (_msgs[_i].life <= 0) array_delete(_msgs, _i, 1);
    }
}
for (var _i = array_length(popups) - 1; _i >= 0; _i--)
{
    var _p = popups[_i];
    _p.y -= 0.6;
    _p.life -= 1;
    if (_p.life <= 0) array_delete(popups, _i, 1);
}

// Online chat: T opens the box, which then takes the keyboard (nothing below reads keys,
// and the snake stands still). See scr_chat.
chat_tick();
if (!chat_open && keyboard_check_pressed(ord("T")) && chat_can()) chat_open_box();
if (chat_open)
{
    chat_step();
    if (state == "play") level_time++;
    net_pause_sync();
    exit;
}

var _enter = menu_confirm();
var _pause = keyboard_check_pressed(ord("P")) || keyboard_check_pressed(vk_escape) || any_pad_pressed(gp_start);
var _typing = (state == "online" && (online_mode == "type" || online_mode == "type_ip")) || (state == "title" && keys_wait);
var _menu = menu_input();
if (keyboard_check_pressed(ord("M")) && !_typing)
{
    sound_on = !sound_on;
    if (!sound_on) stop_music();
    else if (state == "play") play_music(lvl.music);
    else if (state == "title" || state == "credits" || state == "online") play_music("music_02.ogg");
}

// Secret code: typing JJNXT during a level skips straight to the next one (online: the host only).
// Left alone while a room code or IP is being typed, which uses keyboard_string itself.
if (!_typing)
{
    if (string_length(keyboard_string) > 20) keyboard_string = string_copy(keyboard_string, string_length(keyboard_string) - 9, 10);
    if (string_pos("jjnxt", string_lower(keyboard_string)) > 0)
    {
        keyboard_string = "";
        if ((state == "play" || state == "paused" || state == "clear") && net_mode != "client") skip_level();
    }
}

switch (state)
{
    case "title":
        title_pan += 0.6;
        switch (menu_page)
        {
            case "main":
                // 1 PLAYER, 2 PLAYERS, OPTIONS, ABOUT.
                if (_menu.up || _menu.down) { menu_sel.main = (menu_sel.main + (_menu.down ? 1 : 3)) mod 4; play_sfx(sfx.select); }
                else if (_menu.ok)
                {
                    switch (menu_sel.main)
                    {
                        case 0: players_n = 1; menu_go("solo"); break;
                        case 1: menu_go("duo"); break;
                        case 2: menu_go("options"); break;
                        case 3: play_sfx(sfx.select); state = "credits"; break;
                    }
                }
                break;

            case "solo":
                // Left / Right: Peto or Sockee.
                if (_menu.left || _menu.right)
                {
                    character = (character + (_menu.left ? -1 : 1) + array_length(snakes)) mod array_length(snakes);
                    play_sfx(sfx.select);
                }
                else if (_menu.ok) { play_sfx(sfx.select); players_n = 1; new_game(min(settings.dev_level, array_length(levels) - 1)); }
                else if (_menu.back) menu_go("main");
                break;

            case "duo":
                // Local (one PC, split screen) or online.
                if (_menu.up || _menu.down) { menu_sel.duo = 1 - menu_sel.duo; play_sfx(sfx.select); }
                else if (_menu.ok)
                {
                    if (menu_sel.duo == 0) { players_n = 2; menu_go("local"); }
                    else { play_sfx(sfx.select); state = "online"; online_mode = "menu"; }
                }
                else if (_menu.back) menu_go("main");
                break;

            case "local":
                // Left / Right swaps who plays which snake.
                if (_menu.left || _menu.right) { character = 1 - character; play_sfx(sfx.select); }
                else if (_menu.ok) { play_sfx(sfx.select); players_n = 2; new_game(min(settings.dev_level, array_length(levels) - 1)); }
                else if (_menu.back) menu_go("duo");
                break;

            case "options":
                var _rows = options_rows();
                var _n = array_length(_rows);
                if (_menu.up || _menu.down) { menu_sel.options = (menu_sel.options + (_menu.down ? 1 : _n - 1)) mod _n; play_sfx(sfx.select); break; }
                if (_menu.back) { settings_save(settings); menu_go("main"); break; }
                var _row = _rows[menu_sel.options].name;
                var _step = (_menu.right ? 1 : 0) - (_menu.left ? 1 : 0);
                switch (_row)
                {
                    case "music":
                    case "sfx":
                        if (_step != 0)
                        {
                            settings[$ _row] = clamp(settings[$ _row] + _step, 0, 10);
                            apply_music_volume();
                            play_sfx(sfx.select);   // a click at the new effects volume
                        }
                        break;
                    case "controls":
                        if (_menu.ok) { keys_row = 0; keys_col = 0; keys_wait = false; keys_note = ""; menu_go("keys"); }
                        break;
                    case "fullscreen":
                        if (_menu.ok || _step != 0)
                        {
                            settings.fullscreen = !settings.fullscreen;
                            window_set_fullscreen(settings.fullscreen);
                            play_sfx(sfx.select);
                        }
                        break;
                    case "dev_level":
                        if (_step != 0)
                        {
                            settings.dev_level = (settings.dev_level + _step + array_length(levels)) mod array_length(levels);
                            play_sfx(sfx.select);
                        }
                        break;
                    case "dev_lives":
                        if (_step != 0)
                        {
                            var _choices = dev_lives_choices();
                            var _at = 0;
                            for (var _i = 0; _i < array_length(_choices); _i++) if (_choices[_i] == settings.dev_lives) _at = _i;
                            settings.dev_lives = _choices[(_at + _step + array_length(_choices)) mod array_length(_choices)];
                            play_sfx(sfx.select);
                        }
                        break;
                    case "no_damage":
                    case "show_fps":
                        if (_menu.ok || _step != 0) { settings[$ _row] = !settings[$ _row]; play_sfx(sfx.select); }
                        break;
                    case "back":
                        if (_menu.ok) { settings_save(settings); menu_go("main"); }
                        break;
                }
                break;

            case "keys":
                // The Controls page: row 0 picks the key set, then one row per action
                // (Left / Right picks the slot, Enter waits for a new key, Delete clears it),
                // then Reset and Back.
                var _acts = key_actions();
                var _sets = key_sets();
                var _set_name = _sets[keys_set].name;
                var _keys = settings.keys[$ _set_name];
                var _reset_row = array_length(_acts) + 1;
                var _back_row = _reset_row + 1;
                if (keys_note_t > 0) keys_note_t--;
                if (keys_wait)
                {
                    var _act = _acts[keys_row - 1].name;
                    if (keyboard_check_pressed(vk_escape)) { keys_wait = false; play_sfx(sfx.select); break; }
                    var _k = key_capture();
                    if (_k == -1) break;
                    if (key_reserved(_k))
                    {
                        keys_note = key_name(_k) + " is kept for the game (Esc, P, M, F1, F2). Press another key.";
                        keys_note_t = 150;
                        break;
                    }
                    // The same key twice in one action's slots would be pointless: move it here.
                    var _list = _keys[$ _act];
                    for (var _i = 0; _i < KEY_SLOTS; _i++) if (_list[_i] == _k) _list[_i] = -1;
                    _list[keys_col] = _k;
                    keys_wait = false;
                    play_sfx(sfx.select);
                    if (key_clashes(settings.keys, _set_name, _act, _k)) { keys_note = key_name(_k) + " is used for something else too (shown in red)."; keys_note_t = 180; }
                    settings_save(settings);
                    break;
                }
                if (_menu.back) { settings_save(settings); menu_go("options"); break; }
                // Arrows only here (W / A / S / D may be keys being looked at, not menu moves).
                var _up = keyboard_check_pressed(vk_up) || any_pad_pressed(gp_padu);
                var _down = keyboard_check_pressed(vk_down) || any_pad_pressed(gp_padd);
                var _left = keyboard_check_pressed(vk_left) || any_pad_pressed(gp_padl);
                var _right = keyboard_check_pressed(vk_right) || any_pad_pressed(gp_padr);
                var _ok = keyboard_check_pressed(vk_enter) || any_pad_pressed(gp_face1);
                var _rows_n = _back_row + 1;
                if (_up || _down) { keys_row = (keys_row + (_down ? 1 : _rows_n - 1)) mod _rows_n; play_sfx(sfx.select); }
                else if (keys_row == 0)
                {
                    if (_left || _right) { keys_set = (keys_set + (_left ? -1 : 1) + array_length(_sets)) mod array_length(_sets); play_sfx(sfx.select); }
                }
                else if (keys_row <= array_length(_acts))
                {
                    if (_left || _right) { keys_col = (keys_col + (_left ? -1 : 1) + KEY_SLOTS) mod KEY_SLOTS; play_sfx(sfx.select); }
                    else if (_ok) { keys_wait = true; keys_note = ""; play_sfx(sfx.select); }
                    else if (keyboard_check_pressed(vk_delete) || keyboard_check_pressed(vk_backspace))
                    {
                        var _clear = _keys[$ _acts[keys_row - 1].name];
                        _clear[keys_col] = -1;
                        play_sfx(sfx.select);
                        settings_save(settings);
                    }
                }
                else if (keys_row == _reset_row && _ok)
                {
                    settings.keys[$ _set_name] = key_defaults(_set_name);
                    keys_note = _sets[keys_set].label + " keys are back to the defaults.";
                    keys_note_t = 150;
                    play_sfx(sfx.select);
                    settings_save(settings);
                }
                else if (keys_row == _back_row && _ok) { settings_save(settings); menu_go("options"); }
                break;
        }
        break;

    case "credits":
        title_pan += 0.6;
        if (_menu.ok || _menu.back) { play_sfx(sfx.select); state = "title"; menu_page = "main"; }
        break;

    case "online":
        // Host or join a room; once connected, the host picks the snakes and starts the game.
        title_pan += 0.6;
        var _esc = keyboard_check_pressed(vk_escape);
        switch (online_mode)
        {
            case "menu":
                // HOST A ROOM, JOIN WITH A CODE, JOIN BY IP (or H / J / I). Esc: back.
                var _pick = -1;
                if (_menu.up || _menu.down) { menu_sel.online = (menu_sel.online + (_menu.down ? 1 : 2)) mod 3; play_sfx(sfx.select); }
                else if (_menu.ok) _pick = menu_sel.online;
                else if (keyboard_check_pressed(ord("H"))) _pick = 0;
                else if (keyboard_check_pressed(ord("J"))) _pick = 1;
                else if (keyboard_check_pressed(ord("I"))) _pick = 2;
                if (_pick == 0)
                {
                    play_sfx(sfx.select);
                    net.host();
                    clipboard_set_text(net.code);
                    online_mode = "room";
                }
                else if (_pick == 1) { play_sfx(sfx.select); online_ip = ""; keyboard_string = ""; online_mode = "type"; }
                else if (_pick == 2) { play_sfx(sfx.select); online_ip = ""; keyboard_string = ""; online_mode = "type_ip"; }
                else if (_menu.back) menu_go("duo");
                break;

            case "type_ip":
                var _t = "";
                for (var _i = 1; _i <= string_length(keyboard_string) && string_length(_t) < 15; _i++)
                {
                    var _c = string_char_at(keyboard_string, _i);
                    if (string_pos(_c, "0123456789.") > 0) _t += _c;
                }
                keyboard_string = _t;
                online_ip = _t;
                if (keyboard_check_pressed(vk_enter) && string_length(_t) >= 7) { play_sfx(sfx.select); keyboard_string = ""; online_mode = "type"; }
                else if (_esc) { play_sfx(sfx.select); online_mode = "menu"; }
                break;

            case "type":
                online_code = net_clean_code(keyboard_string);
                keyboard_string = online_code;
                if (keyboard_check_pressed(vk_enter) && string_length(online_code) == NET_CODE_LEN)
                {
                    play_sfx(sfx.select);
                    if (online_ip != "") net.join_ip(online_ip, online_code); else net.join(online_code);
                    online_mode = "room";
                }
                else if (_esc) { play_sfx(sfx.select); online_mode = "menu"; }
                break;

            case "room":
                // The lobby: once connected, the host picks the snakes and starts the game.
                if (net.state == "connected" && net_mode == "") net_begin(net.role);
                if (net.state != "connected" && net_mode != "") net_end();
                if (keyboard_check_pressed(vk_space) && net.state == "connected") { play_sfx(sfx.jump); net.send_wave(); }
                if (net_mode == "host")
                {
                    if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_right)) { character = 1 - character; play_sfx(sfx.select); }
                    if (keyboard_check_pressed(vk_enter)) { play_sfx(sfx.select); players_n = 2; new_game(0); }
                    else
                    {
                        for (var _i = 0; _i < min(array_length(levels), 9); _i++)
                        {
                            if (keyboard_check_pressed(ord(string(_i + 1))) || keyboard_check_pressed(vk_numpad1 + _i))
                            {
                                play_sfx(sfx.select);
                                players_n = 2;
                                new_game(_i);
                                break;
                            }
                        }
                    }
                }
                if (_esc) { play_sfx(sfx.select); net.stop(); net_end(); online_mode = "menu"; }
                break;
        }
        break;

    case "play":
        level_time++;
        if (net_mode != "")
        {
            // Online, P / Esc pauses both games; the other player is told who paused.
            if (_pause) net_pause(true);
        }
        else if (_pause)
        {
            state = "paused";
            audio_pause_all();
        }
        // F1: back to the last checkpoint. F2: start the level over. (Offline only.)
        else if (keyboard_check_pressed(vk_f1)) respawn_at_checkpoints();
        else if (keyboard_check_pressed(vk_f2)) start_level();
        break;

    case "paused":
        // The pause menu: P (or Esc / Enter) carries on, N skips the level, Q quits to the title.
        // Online, only the player who paused can carry on (or the host skip); either can leave.
        if (net_mode != "")
        {
            if (keyboard_check_pressed(ord("Q"))) net_leave();
            else if (net_pause_me && keyboard_check_pressed(ord("N")) && net_mode == "host") skip_level();
            else if (net_pause_me && (_pause || _enter)) net_pause(false);
        }
        else if (keyboard_check_pressed(ord("Q")))
        {
            audio_resume_all();
            load_level(0, false);
            state = "title";
            menu_page = "main";
        }
        else if (keyboard_check_pressed(ord("N"))) skip_level();
        else if (_pause || _enter)
        {
            state = "play";
            audio_resume_all();
        }
        break;

    case "clear":
        // Online, the joiner sees the host's tally and waits for the host to carry on.
        if (net_mode == "client") break;
        // Count each snake's bonus up like the old tally screens.
        var _counting = false;
        for (var _k = 0; _k < array_length(pl); _k++)
        {
            var _p = pl[_k];
            if (_p.shown < _p.bonus)
            {
                var _step = min(_p.bonus - _p.shown, 150);
                _p.shown += _step;
                _p.score_now += _step;
                _counting = true;
            }
        }
        if (_counting)
        {
            if (frame mod 4 == 0) play_sfx(sfx.gem);
        }
        else if (_enter)
        {
            level_index++;
            if (level_index >= array_length(levels))
            {
                state = "victory";
                play_music("music_02.ogg");
            }
            else start_level();
        }
        break;

    case "gameover":
    case "victory":
        if (_enter)
        {
            load_level(0, false);
            // Online, back to the room, still connected, for another go.
            if (net_mode != "") { state = "online"; online_mode = "room"; }
            else { state = "title"; menu_page = "main"; }
        }
        break;

    case "netlost":
        if (_enter) net_leave();
        break;
}

// Online: pause or carry on to match both players' pauses.
net_pause_sync();
