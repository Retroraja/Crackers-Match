# FPS rules — read before building ANY new screen, area, build animation or scene

Learned from his phones (OPPO A78, wife's Redmi 12, Moto) 14-20 Nov 2026. Follow from the first build of every new area.
Redmi 12 is the weakest — target 40+ there, 55+ on the OPPO.

## Never on phones
- No live 3D. Areas, builds, area start/end, title = pictures rendered on the computer (godot/tools/pic, full quality
  + shadows), shown as 2D. (Live 3D gave 7-10 fps on the OPPO.)
- No videos for builds or area scenes (only the story intro video). Videos made the APK 163 MB (now 87 MB).
- No screen readback at runtime (get_viewport().get_texture().get_image()). It hung the Redmi (win/Coin Blast freeze).
- No Geometry2D / polygon cutting / gradients built every frame for things that look the same each frame.
- No full-screen shader effects or blur running every frame.

## Always
- Anything that does not change: draw it ONCE into a picture (board frame, tile looks, the man's coat/head). Best:
  made on the computer as a PNG sheet (like art/coin_sheet.png, tools/pic/coin_sheet.py) — straight alpha, crisp.
  A runtime SubViewport bake gives dark edges (premultiplied alpha) and blur.
- Animated sheets instead of live drawing: e.g. shine = N frames in a sheet, pick the frame (coin tiles: 48 steps).
- Redraw only while something moves; idle = no queue_redraw (board does 4/s safety only).
- Faces/characters: body drawn once, only eyes/mouth redraw when they change; bounce = move the node, not redraw.
- Full-screen layers: as few as possible on top of each other (flatten backgrounds into one picture, hide what is covered).
- Screens behind a popup PAUSE (process off), never keep animating under it.
- Rays / glows = one picture rotated or faded, not drawn shapes. Fireworks/sparkles = small 2D particle counts
  (≤ ~40 per burst), spaced out.
- Build animations = sticker pieces (one per object) that pop/bounce/fade with tweens; dust/sparkles 2D.
  Slides between pictures = moving 2 pictures.
- Pictures sized for the phone: 1080 px wide street pictures (webp), stickers cropped to their box.
- Tall phones: anything full-screen (dims, backgrounds) must cover the whole screen height, not just 390x844
  (project stretch = keep_width; the 390x844 stage is centred vertically).

## Making new area pictures (rules for the render tool)
- Render at 1.5x and shrink (no MSAA in the Godot compatibility renderer: code-made meshes vanish with it).
- Freeze everything while rendering (people, cars, water, smoke, fireworks) so build stickers are clean differences.
- Keep build sites between ~10% and ~78% of the picture height (top bar and Build/nav buttons cover the rest).
- 2-3 pictures per area; each build belongs to one picture; stickers are taken for every picture the build shows in.

## Checks before an APK
- Run the new screen on the computer with the FPS counter; look for anything that redraws every frame without moving.
- Say clearly in the reply what is and is not in the APK.
