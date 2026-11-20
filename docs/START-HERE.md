# Crackers Match — start here (for a new chat, account or computer)

Indian Diwali-crackers match-3 for Android by RetroRaja Games (Rajarajan). Game = Godot 4.3, GL Compatibility.

## Read first, in this order
1. `working-rules.md` — how Rajarajan wants Claude to work (talk first, build only on "go").
2. `fps-rules.md` — speed rules every new screen/area/animation MUST follow from the first build.
3. `current-state.md` — what the latest APK has, where everything is.
4. `plans.md` — agreed but not built (win screen, Area 3, Area 4).
5. `game-design.md` — story, areas, difficulty, obstacles, look of windows and the man.

## Repo
- Branch: `claude/build-28` (this is the live one). Game: `godot/`. Old web/Android version: `app/` (not used now).
- APK: push to the branch -> GitHub Actions "Godot APK" (`.github/workflows/godot.yml`) -> release `godot-dev`,
  file `CrackersMatchGodot.apk`. Commit message with `[preview]` = no build.
  Changes outside `godot/` start the OLD "Build APK" workflow — use `[preview]` for doc-only commits.
- Main code: `godot/scripts/app/cm_app.gd` (screens, flow, menus), `godot/scripts/cm/cm_game.gd` (the board),
  `godot/scripts/street/pic_street.gd` (picture-based areas on phones), `street.gd`/`bazaar.gd` (3D, computer only,
  used to render pictures), `godot/ui/*.json` (layouts captured from the web version).

## Run on a computer
- Godot 4.3 stable (Linux: Godot_v4.3-stable_linux.x86_64), run with the project at `godot/`.
  Headless/cloud: `xvfb-run -a godot --path godot --resolution 390x844 -- <dev args>`; run `--import --headless` once first.
- Dev args (after `--`):
  - `--pic=1` picture mode like a phone (no 3D).
  - `--flow=1 --s_agreed=1 --s_tut=1 --s_lv=30 --s_step=2 --s_area=1 --tap=2 --act=panel|build|all|play|winnext --back=N --shot=/tmp/x.png --wait=S`
  - `--t=gshot --seen=1 --lv=N [--card=1] --shot=png`, `--t=auto --lv=N --n=1`, `--t=bonus`, `--t=areaend`, `--t=story`
  - `--nobake=1` old drawing (no baked board/coin sheet), `--perf=1` timings.
- FPS number shows top-left in test builds.

## Street pictures (Area 1/2 now, Area 3+ later)
`godot/tools/pic/README.md` — render every build state from the 3D scene, cut stickers, json per area.
