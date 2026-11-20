# Picture-based areas (20 Nov)
Phones draw no 3D. The street pictures, the per-build stickers, the title picture and the Area 1 dusk picture are
rendered on the computer from our 3D street (full quality, shadows) and cut by script.

1. `render_all.sh` (needs Godot 4.3 at /home/claude/gd/godot + xvfb): renders every build state of every picture
   into /tmp/pics/<pic>/sN.png (1620x3507, 1.5x).
2. `python3 make_pics.py /tmp/pics <godot dir>`: base pictures, one sticker piece per object per build
   (street/pics/*.webp + a1.json / a2.json), title_base.webp, a1_dusk.webp.
3. `python3 coin_sheet.py <godot dir>`: Coin Blast tile sheet (art/coin_sheet.png).

Cameras (pic_tool.gd args) are in render_all.sh. Any change to a build or the street = run 1 and 2 again.
Dev: `-- --pic=1` runs picture mode on the computer.
