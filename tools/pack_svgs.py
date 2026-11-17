# Packs godot/ui/svg/*.svg into godot/ui/svgs.json (the APK does not carry raw .svg files).
# PNG overrides: tools/art/<name>.png replaces an SVG that needs blur (Godot's SVG reader has no filters).
# Run from the repo root: python3 tools/pack_svgs.py
import json, glob, os, base64
PNG = {"svg/4d09e08c26.svg": "tools/art/hand.png"}   # tutorial hand (source: tools/art/hand.svg, rsvg-convert -z 3)
d = {}
for f in sorted(glob.glob("godot/ui/svg/*.svg")):
    k = "svg/" + os.path.basename(f)
    d[k] = "png:" + base64.b64encode(open(PNG[k], "rb").read()).decode() if k in PNG else open(f).read()
json.dump(d, open("godot/ui/svgs.json", "w"))
print(len(d), "pictures,", os.path.getsize("godot/ui/svgs.json"), "bytes")
