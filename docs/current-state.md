# Current state — latest APK (20 Nov 2026), commit bb629d7 on claude/build-28

APK: https://github.com/Retroraja/Crackers-Match/releases/download/godot-dev/CrackersMatchGodot.apk (87 MB)

## In this APK
1. Level card over a level: the level behind pauses (no screen readback). Fixed the freeze after Coin Blast Continue / win Next.
2. Android back (cm_app on_back): popups close like X; bonus card = Go; playing = pause popup; lose = Give Up then
   Back to Street; win / Coin Blast = Next/Continue; story video / scenes = skip; building = Skip;
   home/title = "Exit game?" (exit_box.gd, only Yes quits).
3. Coin Blast: coin tiles from art/coin_sheet.png (48 shine steps). `--nobake=1` = old way.
4. Obstacles: when a crate/steel/breakable dies the cell empties (_ob_gone) -> crackers fall in. Gold floor stays.
5. Booster bar: unlocked icons full colour, price pill = [coin] 500.
6. Title: art/web/title_base.webp rendered from our 3D (Bakery, with shadows); old painted front plants hidden.
7. Colour Matchbox dropped from bar/meter clears the colour it was dropped on (e.drop_col).
8. Picture-based areas (scripts/street/pic_street.gd, PicStreet extends Street; PIC = phones or `--pic=1`):
   - Area 1: 3 pictures (builds 1-3, 4-7, 8-10). Area 2: 2 pictures (1-6, 7-12). street/pics/*.webp + a1.json/a2.json.
   - Each build = sticker pieces (one per object) that pop up from their base with dust + sparkles; the stone path fades in.
   - After a picture's last build the view slides to the next; swipe on the empty street shows earlier pictures.
   - Area 1 end: fades to a dusk render, factory windows glow, 2D fireworks, notebook, NEXT card.
     Area 2 start = picture slides (art/story2). Area 2 end = scene over the picture with sparkles.
   - Build/area-end videos deleted (video/story.ogv stays). Export excludes 3D folders (export_presets.cfg).

His phone check (Moto, 20 Nov): builds fine, slide to the bridge picture fine. Found: gaps (bright strips) above/below
the level card dim on tall screens -> fix offered (see plans.md).

## Earlier history (short)
- 14-16 Nov: web game ported to Godot (cm_game board, cm_app screens, UI captured from the web into ui/*.json).
- 17 Nov: story intro "Grandpa's Dream", Area 1 = 30 levels, 10 builds; Area 2 Chennai GHILLI shop, 12 builds, 60 levels.
- 18 Nov: breakables (pot, soda, coconut, matchbox, newspaper, bangles, gift, diyas), cabinets per type.
- 18-19 Nov: speed work (videos test, board baking, man drawn once) -> led to fps-rules.md and picture areas.
