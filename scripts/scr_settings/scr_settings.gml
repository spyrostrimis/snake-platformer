/// Options: key bindings, volumes, display and developer settings, saved in settings.ini.

#macro KEY_SLOTS 4              // keys each action can have
#macro SETTINGS_FILE "settings.ini"

/// The actions a snake can be given keys for, in the order the Controls page lists them.
function key_actions()
{
    return [
        { name: "left",   label: "Move left" },
        { name: "right",  label: "Move right" },
        { name: "down",   label: "Down / drop through" },
        { name: "jump",   label: "Jump" },
        { name: "tongue", label: "Tongue" },
        { name: "roll",   label: "Roll (hold)" },
        { name: "boost",  label: "Boost" },
    ];
}

/// The three key sets, as the Controls page shows them.
function key_sets()
{
    return [
        { name: "solo", label: "ONE PLAYER" },
        { name: "p1",   label: "PLAYER 1" },
        { name: "p2",   label: "PLAYER 2" },
    ];
}

/// The default keys of set _set: "solo" (one player), "p1" / "p2" (two players, one keyboard).
/// Every action gets KEY_SLOTS slots; -1 is an empty slot.
function key_defaults(_set)
{
    var _k;
    switch (_set)
    {
        case "solo":
            _k = { left: [vk_left, ord("A")], right: [vk_right, ord("D")], down: [vk_down, ord("S")],
                   jump: [ord("Z"), vk_space, vk_up, ord("W")], tongue: [ord("X"), ord("J")], roll: [vk_shift], boost: [ord("C")] };
            break;
        case "p1":
            _k = { left: [ord("A")], right: [ord("D")], down: [ord("S")], jump: [ord("W")], tongue: [ord("F")], roll: [ord("G")], boost: [ord("H")] };
            break;
        default:
            _k = { left: [vk_left], right: [vk_right], down: [vk_down], jump: [vk_up], tongue: [ord("J")], roll: [ord("K")], boost: [ord("L")] };
            break;
    }
    var _acts = key_actions();
    for (var _i = 0; _i < array_length(_acts); _i++)
    {
        var _list = _k[$ _acts[_i].name];
        while (array_length(_list) < KEY_SLOTS) array_push(_list, -1);
    }
    return _k;
}

/// Every option at its default.
function settings_defaults()
{
    return
    {
        music: 8,           // music volume, 0-10
        sfx: 10,            // sound effects volume, 0-10
        fullscreen: false,
        keys: { solo: key_defaults("solo"), p1: key_defaults("p1"), p2: key_defaults("p2") },
        // Developer options (offline games only).
        dev_level: 0,       // the level a new game starts at
        dev_lives: 3,       // lives each snake starts with
        no_damage: false,   // creatures and hazards take no hearts (pits still cost a life)
        show_fps: false,
        notes_key: true,    // F3 writes a developer note (see scr_notes)
    };
}

/// The lives the Developer option steps through.
function dev_lives_choices() { return [1, 3, 5, 9, 99]; }

/// The saved options, or the defaults for anything not saved yet.
function settings_load()
{
    var _s = settings_defaults();
    ini_open(SETTINGS_FILE);
    _s.music = clamp(ini_read_real("sound", "music", _s.music), 0, 10);
    _s.sfx = clamp(ini_read_real("sound", "sfx", _s.sfx), 0, 10);
    _s.fullscreen = ini_read_real("display", "fullscreen", _s.fullscreen) != 0;
    _s.dev_level = max(0, ini_read_real("dev", "level", _s.dev_level));
    _s.dev_lives = max(1, ini_read_real("dev", "lives", _s.dev_lives));
    _s.no_damage = ini_read_real("dev", "no_damage", _s.no_damage) != 0;
    _s.show_fps = ini_read_real("dev", "show_fps", _s.show_fps) != 0;
    _s.notes_key = ini_read_real("dev", "notes_key", _s.notes_key) != 0;
    var _sets = key_sets();
    var _acts = key_actions();
    for (var _j = 0; _j < array_length(_sets); _j++)
    {
        var _set = _s.keys[$ _sets[_j].name];
        for (var _i = 0; _i < array_length(_acts); _i++)
        {
            var _saved = ini_read_string("keys", _sets[_j].name + "_" + _acts[_i].name, "");
            if (_saved == "") continue;
            var _parts = string_split(_saved, ",");
            var _list = [];
            for (var _n = 0; _n < KEY_SLOTS; _n++) array_push(_list, (_n < array_length(_parts)) ? real(_parts[_n]) : -1);
            _set[$ _acts[_i].name] = _list;
        }
    }
    ini_close();
    return _s;
}

/// Saves options _s to settings.ini.
function settings_save(_s)
{
    ini_open(SETTINGS_FILE);
    ini_write_real("sound", "music", _s.music);
    ini_write_real("sound", "sfx", _s.sfx);
    ini_write_real("display", "fullscreen", _s.fullscreen);
    ini_write_real("dev", "level", _s.dev_level);
    ini_write_real("dev", "lives", _s.dev_lives);
    ini_write_real("dev", "no_damage", _s.no_damage);
    ini_write_real("dev", "show_fps", _s.show_fps);
    ini_write_real("dev", "notes_key", _s.notes_key);
    var _sets = key_sets();
    var _acts = key_actions();
    for (var _j = 0; _j < array_length(_sets); _j++)
    {
        var _set = _s.keys[$ _sets[_j].name];
        for (var _i = 0; _i < array_length(_acts); _i++)
        {
            var _list = _set[$ _acts[_i].name];
            var _txt = "";
            for (var _n = 0; _n < array_length(_list); _n++) _txt += ((_n > 0) ? "," : "") + string(_list[_n]);
            ini_write_string("keys", _sets[_j].name + "_" + _acts[_i].name, _txt);
        }
    }
    ini_close();
}

/// True while any key in _list is held.
function keys_held(_list)
{
    for (var _i = 0; _i < array_length(_list); _i++) if (_list[_i] > 0 && keyboard_check(_list[_i])) return true;
    return false;
}

/// True if any key in _list was pressed this step.
function keys_pressed(_list)
{
    for (var _i = 0; _i < array_length(_list); _i++) if (_list[_i] > 0 && keyboard_check_pressed(_list[_i])) return true;
    return false;
}

/// The key pressed this step (for "press a key" on the Controls page), or -1.
function key_capture()
{
    for (var _k = 8; _k < 256; _k++)
    {
        // Left / right Shift, Ctrl and Alt also show up as plain Shift, Ctrl and Alt (16-18).
        if (_k >= 160 && _k <= 165) continue;
        if (keyboard_check_pressed(_k)) return _k;
    }
    return -1;
}

/// Keys the game keeps for itself: they can't be given to a snake.
function key_reserved(_k)
{
    return _k == vk_escape || _k == ord("P") || _k == ord("M") || _k == ord("T") || _k == vk_f1 || _k == vk_f2 || _k == vk_f3;
}

/// A short name for key code _k.
function key_name(_k)
{
    if (_k < 0) return "-";
    if ((_k >= ord("A") && _k <= ord("Z")) || (_k >= ord("0") && _k <= ord("9"))) return chr(_k);
    if (_k >= vk_numpad0 && _k <= vk_numpad9) return "Num " + string(_k - vk_numpad0);
    if (_k >= vk_f1 && _k <= vk_f12) return "F" + string(_k - vk_f1 + 1);
    switch (_k)
    {
        case vk_left: return "Left";
        case vk_right: return "Right";
        case vk_up: return "Up";
        case vk_down: return "Down";
        case vk_space: return "Space";
        case vk_shift: return "Shift";
        case vk_control: return "Ctrl";
        case vk_alt: return "Alt";
        case vk_enter: return "Enter";
        case vk_backspace: return "Backspace";
        case vk_tab: return "Tab";
        case vk_insert: return "Insert";
        case vk_delete: return "Delete";
        case vk_home: return "Home";
        case vk_end: return "End";
        case vk_pageup: return "Page Up";
        case vk_pagedown: return "Page Down";
        case vk_multiply: return "Num *";
        case vk_add: return "Num +";
        case vk_subtract: return "Num -";
        case vk_divide: return "Num /";
        case vk_decimal: return "Num .";
        case 186: return ";";
        case 187: return "=";
        case 188: return ",";
        case 189: return "-";
        case 190: return ".";
        case 191: return "/";
        case 192: return "`";
        case 219: return "[";
        case 220: return "\\";
        case 221: return "]";
        case 222: return "'";
    }
    return "Key " + string(_k);
}

/// True if key _k (in set _set, action _act) is also used by another action of the same set,
/// or, for the two-player sets, anywhere in the other player's set (one keyboard, two snakes).
function key_clashes(_keys, _set, _act, _k)
{
    if (_k < 0) return false;
    var _acts = key_actions();
    var _mine = _keys[$ _set];
    for (var _i = 0; _i < array_length(_acts); _i++)
    {
        if (_acts[_i].name == _act) continue;
        if (array_contains(_mine[$ _acts[_i].name], _k)) return true;
    }
    if (_set == "solo") return false;
    var _other = _keys[$ (_set == "p1") ? "p2" : "p1"];
    for (var _i = 0; _i < array_length(_acts); _i++) if (array_contains(_other[$ _acts[_i].name], _k)) return true;
    return false;
}

/// The keys of _list as "Z / Space", for the hints on the menus.
function keys_text(_list)
{
    var _t = "";
    for (var _i = 0; _i < array_length(_list); _i++)
    {
        if (_list[_i] < 0) continue;
        _t += ((_t != "") ? " / " : "") + key_name(_list[_i]);
    }
    return (_t == "") ? "-" : _t;
}

/// The menus' controls this step: arrows / WASD or the D-pad to move, Enter / Space / A to
/// choose, Esc / B to go back.
function menu_input()
{
    var _m =
    {
        up:    keyboard_check_pressed(vk_up)    || keyboard_check_pressed(ord("W")) || any_pad_pressed(gp_padu),
        down:  keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S")) || any_pad_pressed(gp_padd),
        left:  keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A")) || any_pad_pressed(gp_padl),
        right: keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || any_pad_pressed(gp_padr),
        ok:    menu_confirm(),
        back:  keyboard_check_pressed(vk_escape) || any_pad_pressed(gp_face2),
    };
    return _m;
}
