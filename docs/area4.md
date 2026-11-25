# Area 4: GHILLI Delivery Hub (agreed 23 Nov 2026)

In the game since 25 Nov (levels 81-100). Home camera and positions: tools/pic/a4_render.sh.

## Home view
- One fixed scene: the GHILLI shop front, seen from a corner side angle at about first-floor height, looking along the footpath.
- Same Area 2 Chennai street style (Kenney street, wires, palms, autos).
- Evening sunset light, with the shop tube lights and serial bulbs on.
- Everything sits in front of the shop under the awning: the order board by the shutter, the packing table, the grey van and the bikes at the kerb, and the customer queue on the footpath.

## Builds (9)
1. Fix the grey van. Keep it grey and sharp, never red.
2. Order board
3. Packing table
4. Delivery bikes
5. Temple delivery
6. Wedding hall delivery
7. School delivery
8. Apartment delivery
9. Marina party delivery

## Each delivery build (about 5 s)
1. Zoom into the order board. That place's order card gets a green tick and a DELIVERED stamp.
2. Pan to the grey van. The van picture slides off the screen (simple 2D slide, no 3D).
3. Fade into the place, in the same street style. The van rolls in and the boxes are unloaded.
4. Fade back to the shop home view. The customer queue grows.

Rules:
- No gifts; customers are buying.
- No growing lights.
- The van moves only on builds, never per level, and never locks the Level button.

## Ending
The Madurai call leads to Area 5 (the Madurai shop). Diwali night comes much later.

## Files
- `godot/tools/pic/a4_mock.gd`: render tool (`--mode=hub` for the home view, `--mode=street` for the places). The options are `--sunset`, `--novan`, `--stamps=N` and `--boxes=N`.
- `godot/tools/pic/a4_temple_delivery.py`: puts the temple delivery video together from the renders.
- `previews/area4-mock/`: pictures and videos. `area4-delivery-hub-home.jpg` and `area4-temple-delivery.mp4` are the agreed look. The older map, low-view and road tests were rejected and are kept only for reference.
