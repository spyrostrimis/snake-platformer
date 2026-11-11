# SNAGMAN

A side-scrolling platformer made with [GameMaker](https://gamemaker.io), a tribute to the 90s PC platformers (*Jazz Jackrabbit 2* above all), with a hangman twist. Each level hides the letters of a secret word: grab the right ones to open the exit door, and every wrong letter is a miss. A boss guards each exit and holds one letter of the word.

Two snakes to play: **Peto** (green) glides on its spinning tail and rockets upward; **Sockee** (red) double-jumps and dashes ahead. Play alone, two on one PC with a split screen, or **online** with a friend.

It grew out of [snake_hangman](https://github.com/spyrostrimis/snake_hangman) (v5 "Jungle Jam" and v6); its history from v6 on comes with it.

## Running it

Open `snake_hangman5.yyp` in GameMaker, or from the command line with [GM-CLI](https://www.npmjs.com/package/@gamemaker/gm-cli):

```bash
npx @gamemaker/gm-cli run
```

### The music (not in this repository)

The levels play the [*Jazz Jackrabbit 2 – 20th Anniversary Tribute Album*](https://jj20.bandcamp.com/album/jazz-jackrabbit-2-20th-anniversary-tribute-album) by the JJ20 Team, licensed [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/), so the tracks are kept out of git. To hear them, download the album (free), convert each track to Ogg Vorbis unchanged, and save them in this folder as `music_01.ogg` … `music_09.ogg`, numbered by track. Or copy the nine `.ogg` files from a packaged build. Without them the game plays silently, apart from its own sound effects. `.gitignore` keeps them out of commits.

## Playing

| | Move | Jump | Tongue | Roll (hold) | Boost |
|---|---|---|---|---|---|
| One player / online | Arrows or A D | Z, Space, Up or W | X or J | Shift | C |
| Split screen, P1 (top) | A D, S down | W | F | G | H |
| Split screen, P2 (bottom) | Arrows, Down | Up | J | K | L |
| Gamepad | Stick / D-pad | A | X | RB / LB / Y | B |

On the title screen: Up / Down picks one or two players, Left / Right the snake, 1-2 starts at a level, **O** opens online play, C the credits, M music on/off. In a game: P pauses, N skips the level.

Every 10 gems a snake collects give it an **extra life**.

The two snakes share one bar of misses: 6 wrong letters per level, and only **5 from level 10 on**.

### The Slingshot (two players)

A super move for when you play together, split screen or online: **Peto** is the bow, **Sockee** the arrow.

1. **Peto** jumps straight up (no Left / Right) and presses **Jump again** in the air: his helicopter, gliding slowly down with his tail spinning.
2. **Sockee** rolls (hold **Roll**) back towards Peto and, at full rolling speed, presses **Boost**: it leaps as a ball, just high enough to reach the middle of Peto's body.
3. If the ball hits Peto **in his middle**, he bends into a C around it and they fall together. (Press Boost too early or too late and it flies past.)
4. When Peto lands he **flings Sockee forward**. Sockee straightens into an arrow and **whatever it hits takes a huge hit**: it knocks out creatures on the way, and a boss loses **a third of its health bar** as the arrow bounces off it.

The numbers (hover time, leap, throw, damage) are at the top of `scripts/scr_slingshot`.

### Online

Press **O**. One player hosts (**H**) and gets a 5-character room code (copied to the clipboard); the other joins (**J**) and types it. The two games find each other through public STUN servers and a few seconds of messages on [ntfy.sh](https://ntfy.sh), then talk directly over UDP: no server to run, no port forwarding. Once connected, the host picks the snakes and presses Enter.

If the code can't connect (both players behind CGNAT), install [Tailscale](https://tailscale.com) on both PCs, and join with **I** (join by IP) using the host's Tailscale address and the room code.

How it is built: `scripts/scr_net` and `objects/obj_net` make the connection; the online game itself (the host runs the world, each PC its own snake) is in `objects/obj_game/Create_0.gml` under "Online game".

## Working on it together

- `git pull` before you start; commit small steps; `git push` when it works.
- Split the work by area, so you aren't both editing the same `.gml` file at once.
- Adding a resource (object, sprite, script) changes `snake_hangman5.yyp`: pull just before, push soon after.
- Check `git status` before committing: GameMaker sometimes re-saves files you didn't touch.
- Share playable builds as GitHub Releases, not in git.
- Project notes for Claude Code (and how to edit GameMaker files safely) are in `CLAUDE.md`.

## Credits

- Game, art and code: Spyros Trimis, Can Dereli and Claude. All characters, levels and art are original; the art is drawn in code (`art_src/make_art.js`, SVG rendered with sharp).
- Music: the JJ20 Team (Megahit, Zyrit, BPStudio, Gridscape, Bitrotator, SIDNIFY, Vincenzo and Ziona), CC BY-NC-ND 4.0. The album covers Alexander Brandon's music; *Jazz Jackrabbit 2* belongs to Epic Games. This is an unofficial fan tribute, not endorsed by Epic Games.
- Text uses Comic Sans MS, already on Windows; no fonts are bundled.
