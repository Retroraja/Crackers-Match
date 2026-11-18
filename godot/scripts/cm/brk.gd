# New breakable obstacles (18 Nov, approved web preview "New Breakables" v3.1): their pictures and their break
# effects. Board space (same as CMGame). The pictures come from the preview (art/brk/*.png, 312 px, the object is
# 240 px in the middle, outline baked in). Every effect here is a port of fx2.js in that preview:
# chips, glass, drops, paper, confetti, fibres, twinkles, streaks, embers, shards, sprites,
# flash, rays, rings, puffs, fireballs and foam.
extends Node2D
class_name CMBrk

const KINDS := ["pot", "soda", "coco", "match", "news", "bangle", "gift", "dstack"]   # dstack = Diya Stack ("diya" is the bring-down diya)
const HP := {"pot": 1, "soda": 1, "coco": 2, "match": 3, "news": 2, "bangle": 1, "gift": 2, "dstack": 1}
const BC := ["#E53935", "#FDD835", "#43A047", "#1E88E5", "#8E24AA", "#FF7043", "#EC407A"]
const MB := ["#E53935", "#1E88E5", "#2E9E46"]
const DPOS := [[-0.22, 0.27, 0.84], [0.2, 0.27, 0.84], [-0.01, 0.06, 0.84]]
const MPOS := [[0.0, 0.29, 0.0], [0.05, 0.05, -0.05], [-0.04, -0.19, 0.06]]
const MAT := {
	"pot": {"c": ["#C9612A", "#8A3D17", "#E07A3E", "#5E240A"], "d": "#CD8C5A", "r": "#FFB46E"},
	"soda": {"c": ["#BFF7DD", "#7EDDB2", "#E8FFF6", "#2F9E6E"], "d": "#DCFFF0", "r": "#C8FFEB"},
	"coco": {"c": ["#6B3A18", "#A0662F", "#3E1F0A", "#C4874D"], "d": "#AA7850", "r": "#FFF0D2"},
	"match": {"c": ["#E53935", "#1E88E5", "#2E9E46", "#E8C48A"], "d": "#6E6473", "r": "#FFBE5A"},
	"news": {"c": ["#F7F1E3", "#E2D9C3", "#BDB39C", "#C62828"], "d": "#EBE4D2", "r": "#FFFAEB"},
	"bangle": {"c": BC, "d": "#FFE6FA", "r": "#FFDCFF"},
	"gift": {"c": ["#22C1B5", "#0F8E86", "#FFD45A", "#E9D6A6"], "d": "#B4FAF0", "r": "#FFE178"},
	"dstack": {"c": ["#C9612A", "#8A3D17", "#E2803F", "#FFD54F"], "d": "#CD8C5A", "r": "#FFBE5A"}}
const SPLIT := [[0.03, -0.33], [0.06, -0.22], [-0.01, -0.11], [0.04, 0.0], [-0.03, 0.1], [0.03, 0.2], [-0.02, 0.3], [-0.02, 0.39]]

var g: CMGame
var TX := {}
var P: Array = []      # normal particles and sprites
var A: Array = []      # additive particles
var F: Array = []      # effects (some additive)
var held: Array = []   # an object shown while it cracks, before it shatters
var add_layer: Node2D
var RAD: Texture2D     # soft white dot
var FIRE: Texture2D    # fireball colours
var lite := false
var shake := 0.0

func _init() -> void:
	for n in ["pot_1", "pot_c", "soda_1", "coco_2", "coco_1", "match_3", "match_2", "match_1", "match_o", "news_2", "news_1",
			"bangle_1", "gift_2", "gift_1", "diya_1", "diya_c", "sheet", "bow", "flame", "half0", "half1",
			"mbox0", "mbox1", "mbox2", "ring0", "ring1", "ring2", "ring3", "ring4", "ring5", "ring6"]:
		TX[n] = load("res://art/brk/%s.png" % n)
	RAD = _radial([0.0, 0.5, 1.0], [Color(1, 1, 1, 1), Color(1, 1, 1, 0.55), Color(1, 1, 1, 0)])
	FIRE = _radial([0.0, 0.25, 0.6, 1.0], [Color("#FFECA0"), Color("#FFA028"), Color(0.88, 0.27, 0.06, 0.75), Color(0.47, 0.08, 0.04, 0)])
	add_layer = Node2D.new()
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	add_layer.material = m
	add_layer.draw.connect(_draw_add)
	add_child(add_layer)

static func _radial(off: Array, cols: Array) -> Texture2D:
	var gr := Gradient.new()
	gr.offsets = PackedFloat32Array(off)
	gr.colors = PackedColorArray(cols)
	var t := GradientTexture2D.new()
	t.gradient = gr
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 64
	t.height = 64
	return t

static func is_brk(t: String) -> bool:
	return HP.has(t)

func rnd(a: float, b: float) -> float:
	return a + randf() * (b - a)

func clear() -> void:
	P.clear()
	A.clear()
	F.clear()
	held.clear()

# the picture for an obstacle in its current state
func tex_for(o: Dictionary) -> Texture2D:
	var t: String = o.t
	var hp: int = o.hp
	match t:
		"coco": return TX.coco_2 if hp >= 2 else TX.coco_1
		"match": return TX["match_%d" % clampi(hp, 1, 3)]
		"news": return TX.news_2 if hp >= 2 else TX.news_1
		"gift": return TX.gift_2 if hp >= 2 else TX.gift_1
	if t == "dstack":
		return TX.diya_1
	return TX.get(t + "_1")

# draw the obstacle in a cell (x, y = top-left, s = cell size); the picture is 1.3x the object
static func draw_ob(ci: CanvasItem, tex: Texture2D, cx: float, cy: float, s: float) -> void:
	if tex == null:
		return
	var S := s * 1.0 * 1.3
	ci.draw_texture_rect(tex, Rect2(cx - S / 2, cy - S / 2, S, S), false)

# ------------------------------------------------------------------ building blocks
func _bias(x: float, y: float, k: float, src) -> Vector2:
	if src == null:
		return Vector2.ZERO
	var d := Vector2(x, y) - (src as Vector2)
	if d.length() < 1.0:
		return Vector2.ZERO
	return d.normalized() * k

func bits(x: float, y: float, n: int, cols: Array, size: float, pw: float, o: Dictionary = {}) -> void:
	if lite:
		n = maxi(1, n / 2)
	var B: Vector2 = _bias(x, y, size * 40.0, o.get("src")) if o.get("bias", false) else Vector2.ZERO
	for i in n:
		var a: float = (o.cone + (randf() - 0.5) * o.get("spread", 1.0)) if o.has("cone") else randf() * TAU
		var sp := pw * 0.62 * (0.4 + randf() * 0.9)
		var j: float = o.get("jit", 0.0)
		var p := {"k": o.get("type", "chip"), "x": x + (randf() - 0.5) * j, "y": y + (randf() - 0.5) * j,
			"vx": cos(a) * sp + B.x, "vy": sin(a) * sp - o.get("up", 0.0) + B.y, "g": o.get("g", pw * 2.6),
			"c": Color(cols[i % cols.size()]), "r": size * (0.5 + randf() * 0.8), "life": o.get("life", 0.7) * (0.6 + randf() * 0.6),
			"age": 0.0, "rot": randf() * 6.0, "vr": (randf() - 0.5) * 16.0, "drag": o.get("drag", 0.0), "sh": randf()}
		if o.get("add", false):
			A.append(p)
		else:
			P.append(p)

func flash_fx(x: float, y: float, R: float, life := 0.18) -> void:
	F.append({"k": "flash", "x": x, "y": y, "R": R, "life": life, "age": 0.0, "a0": randf() * 6.0})

func rays(x: float, y: float, R: float, col: String, life: float, n := 14) -> void:
	F.append({"k": "rays", "x": x, "y": y, "R": R, "c": Color(col), "life": life, "age": 0.0, "n": n, "a0": randf() * 6.0})

func ring(x: float, y: float, R: float, col: String, life: float, w := 4.0) -> void:
	F.append({"k": "ring", "x": x, "y": y, "R": R, "c": Color(col), "life": life, "age": 0.0, "w": w})

func glow(x: float, y: float, R: float, col: String, life: float) -> void:
	F.append({"k": "glow", "x": x, "y": y, "R": R, "c": Color(col), "life": life, "age": 0.0})

func cloud(x: float, y: float, s: float, col: String, n: int, life := 0.85) -> void:
	if lite:
		n = maxi(2, n / 2)
	for i in n:
		var a := randf() * TAU
		var d := randf() * s * 0.3
		F.append({"k": "puff", "x": x + cos(a) * d, "y": y + sin(a) * d, "vx": cos(a) * s * rnd(0.4, 1.1), "vy": sin(a) * s * rnd(0.3, 0.8) - s * 0.35,
			"R": s * rnd(0.12, 0.2), "c": Color(col), "life": life * rnd(0.8, 1.2), "age": -i * 0.012})

func fireball(x: float, y: float, R: float, life: float) -> void:
	for i in (6 if lite else 11):
		var a := randf() * TAU
		var d := randf() * R * 0.4
		F.append({"k": "fire", "x": x + cos(a) * d, "y": y + sin(a) * d, "vx": cos(a) * R * 0.9, "vy": sin(a) * R * 0.9 - R * 0.3, "R": R * rnd(0.35, 0.6), "life": life * rnd(0.7, 1.1), "age": -i * 0.01})
	for i in 4:
		var b := randf() * TAU
		F.append({"k": "puff", "x": x + cos(b) * R * 0.3, "y": y + sin(b) * R * 0.3, "vx": cos(b) * R * 0.5, "vy": -R * rnd(0.4, 0.9), "R": R * rnd(0.3, 0.45), "c": Color("#3C2D3C"), "life": life * 2.2, "age": life * -0.35})

func sprite(tex: Texture2D, x: float, y: float, sz: float, o: Dictionary) -> void:
	var p := {"k": "spr", "tex": tex, "x": x, "y": y, "sz": sz, "vx": o.get("vx", 0.0), "vy": o.get("vy", 0.0), "g": o.get("g", 0.0), "rot": o.get("rot", 0.0), "vr": o.get("vr", 0.0),
		"life": o.get("life", 1.0), "age": 0.0, "tum": o.get("tum", 0.0), "flip": o.get("flip", 0.0), "drag": o.get("drag", 0.0), "circle": o.get("circle", null), "r": o.get("r", 0.0)}
	var B := _bias(x, y, sz * 2.5, o.get("src"))
	p.vx += B.x
	p.vy += B.y
	P.append(p)

# the picture cut into jagged pieces that tumble and fall (empty pieces are dropped)
func chunks(tex: Texture2D, x: float, y: float, s: float, cols: int, rows: int, pw: float, o: Dictionary = {}) -> void:
	if tex == null:
		return
	if lite:
		cols = maxi(2, cols - 1)
		rows = maxi(2, rows - 1)
	var img: Image = o.get("img")
	if img == null:
		img = tex.get_image()
		if img.is_compressed():
			img.decompress()
	var iw := img.get_width()
	var S := s * 1.3
	var B := _bias(x, y, s * 3.2, o.get("src"))
	var gx: Array = []
	for j in rows + 1:
		var row: Array = []
		for i in cols + 1:
			var jx := (randf() - 0.5) * 0.6 if (i > 0 and i < cols) else 0.0
			var jy := (randf() - 0.5) * 0.6 if (j > 0 and j < rows) else 0.0
			row.append(Vector2((i + jx) / cols * S - S / 2, (j + jy) / rows * S - S / 2))
		gx.append(row)
	for j in rows:
		for i in cols:
			var q: Array = [gx[j][i], gx[j][i + 1], gx[j + 1][i + 1], gx[j + 1][i]]
			var m: Vector2 = (q[0] + q[2]) / 2.0 + Vector2(randf() - 0.5, randf() - 0.5) * S * 0.06
			var tris: Array = [[q[0], q[1], m], [q[1], q[2], m], [q[2], q[3], m], [q[3], q[0], m]] if randf() < 0.5 else [[q[0], q[1], q[2]], [q[0], q[2], q[3]]]
			for t in tris:
				var c: Vector2 = (t[0] + t[1] + t[2]) / 3.0
				# keep pieces that show some of the object
				var hits := 0
				for k in 3:
					var pt: Vector2 = (t[k] + c) / 2.0
					var px := clampi(int((pt.x + S / 2) / S * iw), 0, iw - 1)
					var py := clampi(int((pt.y + S / 2) / S * iw), 0, iw - 1)
					if img.get_pixel(px, py).a > 0.25:
						hits += 1
				var cx_ := clampi(int((c.x + S / 2) / S * iw), 0, iw - 1)
				var cy_ := clampi(int((c.y + S / 2) / S * iw), 0, iw - 1)
				if img.get_pixel(cx_, cy_).a > 0.25:
					hits += 1
				if hits < 2:
					continue
				var ar: float = absf((t[1] - t[0]).cross(t[2] - t[0]))
				if ar < 4.0:
					continue
				var a := atan2(c.y, c.x)
				var sp: float = o.get("sp", 1.0) * s * (1.3 + randf() * 1.6) * pw
				var pts := PackedVector2Array()
				var uvs := PackedVector2Array()
				for v in t:
					pts.append(v - c)
					uvs.append(Vector2((v.x + S / 2) / S, (v.y + S / 2) / S))
				P.append({"k": "shard", "tex": tex, "pts": pts, "uvs": uvs, "x": x + c.x, "y": y + c.y,
					"vx": cos(a) * sp + (randf() - 0.5) * s + B.x, "vy": sin(a) * sp - s * o.get("up", 2.4) * (0.6 + randf() * 0.7) + B.y,
					"rot": 0.0, "vr": (randf() - 0.5) * 12.0, "fl": randf() * 6.0, "vf": (randf() - 0.5) * 14.0, "g": s * o.get("grav", 15.0),
					"life": o.get("life", 0.95) * (0.8 + randf() * 0.4), "age": 0.0})

func impact(k: String, x: float, y: float, s: float, final: bool, src) -> void:
	var M: Dictionary = MAT[k]
	flash_fx(x, y, s * (0.75 if final else 0.45), 0.2 if final else 0.13)
	bits(x, y, 10 if final else 7, M.c, s * 0.035, s * (4.5 if final else 3.0), {"up": s * 1.6, "g": s * 14.0, "src": src, "bias": true, "jit": s * 0.3})
	if final:
		rays(x, y, s * 1.1, M.r, 0.34, 14)
		ring(x, y, s * 0.95, M.r, 0.35, 6)
		cloud(x, y + s * 0.1, s, M.d, 7)
		shake = maxf(shake, 0.35)
		bits(x, y, 14, ["#FFFFFF", "#FFF3B0", M.c[0]], s * 0.022, s * 7.0, {"g": s * 3.0, "life": 0.35, "type": "streak", "add": true})
	else:
		bits(x, y, 6, ["#FFFFFF", "#FFF3B0"], s * 0.018, s * 5.0, {"g": s * 3.0, "life": 0.25, "type": "streak", "add": true})

# a blast (Rocket / Bomb) reaching an obstacle: a small explosion on the tile
func boom(x: float, y: float, s: float) -> void:
	flash_fx(x, y, s * 0.9, 0.14)
	fireball(x, y, s * 0.5, 0.45)
	ring(x, y, s * 1.2, "#FFE696", 0.35, 7)
	bits(x, y, 24, ["#FFFFFF", "#FFE082", "#FF9800", "#FF5722"], s * 0.03, s * 6.0, {"g": s * 3.0, "life": 0.35, "type": "streak", "add": true})
	bits(x, y, 8, ["#FFB300", "#FF6D00", "#FFE082"], s * 0.025, s * 3.0, {"g": s * 6.0, "life": 0.8, "type": "ember", "add": true})

# ------------------------------------------------------------------ one hit on a breakable
# k: kind, hp: hits left after this one, x/y: centre, s: object size, src: blast centre or null.
# Returns the delay (s) before the cell is really free (cracks and flames play first).
func hit(k: String, hp: int, x: float, y: float, s: float, src) -> float:
	var last := hp <= 0
	var M: Dictionary = MAT[k]
	match k:
		"pot":
			_hold(TX.pot_c, x, y, s, 0.1)
			flash_fx(x, y, s * 0.5, 0.1)
			g.at(0.1, func():
				impact(k, x, y, s, true, src)
				chunks(TX.pot_1, x, y, s, 4, 4, 1.15, {"life": 0.95, "src": src})
				bits(x, y, 22, M.c, s * 0.04, s * 4.5, {"up": s * 2.2, "g": s * 15.0, "src": src, "bias": true, "jit": s * 0.4})
				bits(x, y, 10, ["#F2E3C8", "#FFFFFF"], s * 0.02, s * 3.0, {"up": s * 1.2, "g": s * 10.0})
				cloud(x, y + s * 0.15, s * 1.2, M.d, 9, 1.0))
			return 0.1
		"soda":
			impact(k, x, y, s, true, src)
			chunks(TX.soda_1, x, y, s, 3, 5, 1.1, {"life": 0.85, "up": 3.2, "src": src})
			bits(x, y - s * 0.4, 70, ["#FFFFFF", "#E0FFF4", "#B7F5DD", "#FFFFFF"], s * 0.022, s * 6.0, {"cone": -PI / 2, "spread": 1.0, "g": s * 9.0, "life": 1.0, "type": "drop"})
			bits(x, y, 28, M.c, s * 0.035, s * 4.4, {"up": s * 2.2, "g": s * 14.0, "type": "glass", "src": src, "bias": true, "jit": s * 0.4})
			bits(x, y, 14, ["#FFFFFF", "#E8FFF6"], s * 0.035, s * 3.5, {"up": s, "g": s * 3.0, "type": "twinkle", "life": 0.6, "add": true, "jit": s * 0.4})
			for i in 7:
				F.append({"k": "foam", "x": x + rnd(-0.1, 0.1) * s, "y": y - s * (0.25 + i * 0.06), "R": s * rnd(0.08, 0.14), "life": 0.6 + i * 0.05, "age": 0.0, "vy": -s * rnd(0.4, 1.0)})
			sprite(null, x, y - s * 0.26, s, {"vx": s * rnd(-1.2, 1.2), "vy": -s * 3.0, "g": s * 14.0, "life": 1.3, "circle": "marble", "r": s * 0.055, "src": src})
		"coco":
			impact(k, x, y, s, last, src)
			if not last:
				bits(x, y, 12, ["#5A2E10", "#9C6230", "#C4874D"], s * 0.05, s * 3.2, {"up": s * 1.6, "g": s * 9.0, "type": "fiber", "drag": 1.0, "jit": s * 0.4})
				return 0.0
			for side in [-1, 1]:
				sprite(TX.half0 if side < 0 else TX.half1, x, y, s, {"vx": side * s * 1.5, "vy": -s * 2.2, "g": s * 12.0, "vr": side * 3.0, "life": 1.05, "src": src})
			bits(x, y - s * 0.05, 60, ["#FFFFFF", "#DFF4FF", "#A8DCF5", "#FFFFFF"], s * 0.024, s * 5.5, {"cone": -PI / 2, "spread": 2.4, "g": s * 12.0, "life": 0.9, "type": "drop"})
			bits(x, y, 20, ["#5A2E10", "#9C6230", "#C4874D"], s * 0.06, s * 4.0, {"up": s * 2.0, "g": s * 8.0, "type": "fiber", "drag": 1.0, "jit": s * 0.5})
			bits(x, y, 10, ["#FFFBF0", "#F2E8D2"], s * 0.04, s * 3.5, {"up": s * 2.0, "g": s * 14.0, "src": src, "bias": true})
			ring(x, y, s * 0.8, "#AAE1FF", 0.45, 5)
		"match":
			var i: int = clampi(hp, 0, 2)
			if not last:
				impact(k, x, y, s, false, src)
				var p: Array = MPOS[i]
				var dir := -1.0 if randf() < 0.5 else 1.0
				sprite(TX["mbox%d" % i], x + p[0] * s, y + p[1] * s, s, {"vx": dir * s * rnd(1.6, 2.2), "vy": -s * rnd(3.6, 4.2), "g": s * 15.0, "vr": dir * rnd(6, 9), "rot": p[2], "life": 0.95, "flip": rnd(8, 12), "src": src})
				bits(x, y + p[1] * s, 12, ["#FFE082", "#FFFFFF", "#FF9800"], s * 0.016, s * 4.0, {"up": s, "g": s * 6.0, "type": "streak", "add": true, "life": 0.35})
				bits(x, y + p[1] * s, 6, [MB[i], "#E8C48A"], s * 0.03, s * 3.0, {"up": s * 1.5, "g": s * 14.0})
				return 0.0
			_hold(TX.match_o, x, y, s, 0.18)
			g.at(0.18, func():
				var bx := x - 0.47 * s
				var by := y + 0.3 * s
				impact(k, x, y, s, true, src)
				glow(bx, by, s * 1.2, "#FFAA3C", 0.6)
				fireball(bx, by, s * 0.45, 0.5)
				bits(bx, by, 60, ["#FFF59D", "#FFD54F", "#FF9800", "#FFFFFF"], s * 0.02, s * 7.0, {"up": s * 2.5, "g": s * 7.0, "life": 0.6, "type": "streak", "add": true})
				bits(bx, by, 16, ["#FFB300", "#FF6D00", "#FFE082"], s * 0.02, s * 1.6, {"cone": -PI / 2, "spread": 1.4, "g": -s * 1.2, "life": 1.1, "type": "ember", "add": true})
				chunks(TX.match_1, x, y, s, 4, 2, 0.9, {"life": 0.85, "src": src}))
			return 0.18
		"news":
			impact(k, x, y, s, last, src)
			if not last:
				for d in [-1, 1]:
					P.append({"k": "string", "x": x, "y": y, "vx": d * s * 1.6, "vy": -s * 1.8, "g": s * 9.0, "rot": 0.0, "vr": d * 4.0, "life": 0.9, "age": 0.0, "d": d, "s": s})
				bits(x, y, 10, M.c, s * 0.03, s * 2.6, {"up": s * 1.4, "g": s * 5.0, "type": "paper", "drag": 1.2, "jit": s * 0.4})
				return 0.0
			for i in 12:
				var a := -PI / 2 + (i / 11.0 - 0.5) * 3.6 + rnd(-0.2, 0.2)
				sprite(TX.sheet, x + rnd(-0.1, 0.1) * s, y + rnd(-0.1, 0.1) * s, s * 0.5 / 0.4, {"vx": cos(a) * s * rnd(2.0, 3.2), "vy": sin(a) * s * rnd(2.0, 3.2) - s, "g": s * 3.5, "drag": 1.6, "vr": rnd(-6, 6), "rot": rnd(-0.6, 0.6), "flip": rnd(6, 12), "life": 1.2})
			bits(x, y, 30, M.c, s * 0.03, s * 5.0, {"up": s * 1.5, "g": s * 4.0, "type": "paper", "drag": 1.4, "life": 1.1, "jit": s * 0.4})
		"bangle":
			impact(k, x, y, s, true, src)
			for i in 7:
				var yy := (0.33 - i * 0.088) * s
				var dir := 1.0 if i % 2 else -1.0
				sprite(TX["ring%d" % i], x, y + yy, s, {"vx": dir * s * rnd(0.9, 2.2), "vy": -s * rnd(2.4, 3.6), "g": s * 13.0, "vr": dir * rnd(2, 6), "tum": rnd(6, 12), "life": 1.1, "src": src})
			bits(x, y, 40, BC, s * 0.03, s * 5.0, {"up": s * 2.2, "g": s * 12.0, "type": "glass", "src": src, "bias": true, "jit": s * 0.5})
			bits(x, y, 24, ["#FFFFFF", "#FFF59D", "#FFE0F7"], s * 0.035, s * 4.0, {"up": s, "g": s * 2.0, "type": "twinkle", "life": 0.75, "add": true, "jit": s * 0.5})
		"gift":
			impact(k, x, y, s, last, src)
			if not last:
				bits(x - 0.15 * s, y, 14, ["#22C1B5", "#0F8E86", "#FFD45A"], s * 0.035, s * 3.2, {"up": s * 1.6, "g": s * 6.0, "type": "paper", "drag": 1.0})
				return 0.0
			chunks(TX.gift_2, x, y, s, 3, 3, 1.1, {"life": 0.95, "up": 3.0, "grav": 12.0, "src": src})
			sprite(TX.bow, x + 0.1 * s, y - 0.2 * s, s, {"vx": s * 0.5, "vy": -s * 4.2, "g": s * 11.0, "vr": 4.0, "life": 0.9})
			glow(x, y, s * 1.4, "#FFD75A", 0.7)
			bits(x, y, 50, ["#FF4F6D", "#FFD54F", "#4FC3F7", "#7CE07C", "#B388FF", "#FFFFFF"], s * 0.03, s * 6.0, {"up": s * 2.4, "g": s * 5.0, "type": "confetti", "drag": 1.3, "life": 1.2, "jit": s * 0.3})
			bits(x, y - 0.05 * s, 30, ["#FFE082", "#FFD54F", "#FFFFFF", "#FFF59D"], s * 0.045, s * 4.5, {"up": s * 1.5, "g": s * 2.5, "type": "twinkle", "life": 0.9, "add": true, "drag": 1.0})
		"dstack":
			impact(k, x, y, s, false, src)
			var h := _hold(TX.diya_c, x, y, s, 0.42)
			h.lit = true
			glow(x, y - 0.05 * s, s * 1.3, "#FFAA3C", 1.0)
			g.at(0.42, func():
				impact(k, x, y, s, true, src)
				chunks(TX.diya_1, x, y, s, 4, 3, 1.05, {"life": 0.9, "src": src})
				for p in DPOS:
					var fx: float = x + (p[0] - 0.04 + 0.39 * p[2]) * s
					var fy: float = y + (p[1] - 0.07 * p[2]) * s
					fireball(fx, fy, s * 0.22, 0.4)
					bits(fx, fy, 14, ["#FFE082", "#FFB300", "#FF6D00"], s * 0.022, s * 1.8, {"cone": -PI / 2, "spread": 1.4, "g": -s * 1.4, "life": 1.1, "type": "ember", "add": true})
				bits(x, y, 18, M.c, s * 0.04, s * 4.0, {"up": s * 2.0, "g": s * 14.0, "src": src, "bias": true, "jit": s * 0.4}))
			return 0.42
	return 0.0

func _hold(tex: Texture2D, x: float, y: float, s: float, d: float) -> Dictionary:
	var h := {"tex": tex, "x": x, "y": y, "s": s, "d": d, "age": 0.0, "lit": false}
	held.append(h)
	return h

# ------------------------------------------------------------------ update + draw
func _process(delta: float) -> void:
	if P.is_empty() and A.is_empty() and F.is_empty() and held.is_empty():
		shake = 0.0
		return
	var dt := minf(delta, 0.12) * (g.gspeed if g else 1.0)
	shake = maxf(0.0, shake - dt * 3.0)
	for L in [P, A]:
		for p in L:
			p.age += dt
			if p.get("drag", 0.0) > 0.0:
				p.vx *= exp(-p.drag * dt)
				p.vy *= exp(-p.drag * dt * 0.6)
			p.vy += p.get("g", 0.0) * dt
			p.x += p.vx * dt
			p.y += p.vy * dt
			p.rot = p.get("rot", 0.0) + p.get("vr", 0.0) * dt
			if p.has("vf"):
				p.fl += p.vf * dt
	P = P.filter(func(p): return p.age < p.life)
	A = A.filter(func(p): return p.age < p.life)
	for f in F:
		f.age += dt
		if f.age > 0.0:
			if f.has("vx"):
				f.x += f.vx * dt
				f.vx *= exp(-4.0 * dt)
				f.vy *= exp(-3.0 * dt)
			if f.has("vy"):
				f.y += f.vy * dt
	F = F.filter(func(f): return f.age < f.life)
	for h in held:
		h.age += dt
	held = held.filter(func(h): return h.age < h.d)
	queue_redraw()
	add_layer.queue_redraw()

func _alpha(p: Dictionary) -> float:
	var k: float = p.age / p.life
	return 1.0 if k < 0.65 else maxf(0.0, 1.0 - (k - 0.65) / 0.35)

func _draw() -> void:
	# held objects (cracking), behind the flying pieces
	for h in held:
		var sh: float = sin(h.age * 60.0) * h.s * 0.04
		draw_set_transform(Vector2(h.x + sh, h.y), sin(h.age * 47.0) * 0.06, Vector2.ONE)
		draw_ob(self, h.tex, 0.0, 0.0, h.s)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# smoke / dust puffs first
	for f in F:
		if f.k == "puff" and f.age >= 0.0:
			var k: float = f.age / f.life
			var R: float = f.R * (0.6 + k * 1.3)
			var a: float = 0.32 * (1.0 - k) * minf(1.0, f.age * 12.0)
			draw_texture_rect(RAD, Rect2(f.x - R, f.y - R, R * 2, R * 2), false, Color(f.c, a))
		elif f.k == "fire" and f.age >= 0.0:
			var k2: float = f.age / f.life
			var R2: float = f.R * (0.5 + 1.1 * sqrt(k2))
			draw_texture_rect(FIRE, Rect2(f.x - R2, f.y - R2, R2 * 2, R2 * 2), false, Color(1, 1, 1, 1.0 - k2))
		elif f.k == "foam":
			var k3: float = f.age / f.life
			draw_circle(Vector2(f.x, f.y), f.R * (0.5 + k3), Color(1, 1, 1, 0.85 * (1.0 - k3)))
		elif f.k == "ring":
			var k4: float = f.age / f.life
			var R4: float = f.R * (0.15 + 0.85 * (1.0 - pow(1.0 - k4, 3.0)))
			draw_arc(Vector2(f.x, f.y), R4, 0, TAU, 40, Color(f.c, (1.0 - k4) * 0.85), f.w * (1.0 - k4) + 1.0)
			draw_arc(Vector2(f.x, f.y), R4 * 0.96, 0, TAU, 40, Color(1, 1, 1, (1.0 - k4) * 0.5), maxf(1.0, f.w * 0.35 * (1.0 - k4)))
	for p in P:
		var al := _alpha(p)
		match p.k:
			"shard":
				draw_set_transform(Vector2(p.x, p.y), p.rot, Vector2(1, maxf(0.2, absf(cos(p.fl)))))
				draw_polygon(p.pts, PackedColorArray([Color(1, 1, 1, al)]), p.uvs, p.tex)
			"spr":
				var sy := 1.0
				if p.tum > 0.0:
					sy = absf(cos(p.age * p.tum)) + 0.12
				var sx := 1.0
				if p.flip > 0.0:
					sx = cos(p.age * p.flip)
				draw_set_transform(Vector2(p.x, p.y), p.rot, Vector2(sx, sy))
				if p.circle != null:
					draw_circle(Vector2.ZERO, p.r * 1.25, Color(0.1, 0.04, 0.14, al))
					draw_circle(Vector2.ZERO, p.r, Color(0.3, 0.56, 0.82, al))
					draw_circle(Vector2(-p.r * 0.25, -p.r * 0.25), p.r * 0.55, Color(0.82, 0.93, 1, al))
					draw_circle(Vector2(-p.r * 0.35, -p.r * 0.35), p.r * 0.22, Color(1, 1, 1, al))
				elif p.tex != null:
					var S: float = p.sz * 1.3
					draw_texture_rect(p.tex, Rect2(-S / 2, -S / 2, S, S), false, Color(1, 1, 1, al))
			"string":
				draw_set_transform(Vector2(p.x, p.y), p.rot, Vector2.ONE)
				var s: float = p.s
				var pts := PackedVector2Array([Vector2.ZERO, Vector2(p.d * s * 0.12, s * 0.1 * sin(p.age * 9.0)), Vector2(p.d * s * 0.26, s * 0.05)])
				draw_polyline(pts, Color(0.1, 0.04, 0.14, al), s * 0.045)
				draw_polyline(pts, Color(0.75, 0.54, 0.27, al), s * 0.028)
			_:
				_draw_bit(p, al)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_bit(p: Dictionary, al: float) -> void:
	var c: Color = p.c
	c.a *= al
	var r: float = p.r
	var dark := Color(0.08, 0.02, 0.12, 0.75 * al)
	match p.k:
		"drop":
			var spd := Vector2(p.vx, p.vy).length() / maxf(1.0, r * 40.0)
			draw_set_transform(Vector2(p.x, p.y), atan2(p.vy, p.vx), Vector2(1.0 + minf(1.5, spd), 0.85))
			draw_circle(Vector2.ZERO, r, c)
			draw_circle(Vector2(r * 0.2, -r * 0.3), r * 0.3, Color(1, 1, 1, 0.9 * al))
		"glass":
			draw_set_transform(Vector2(p.x, p.y), p.rot, Vector2(1, absf(cos(p.age * 12.0 + p.sh * 6.0)) + 0.2))
			var tri := PackedVector2Array([Vector2(-r, -r * 0.6), Vector2(r * 1.1, -r * 0.2), Vector2(-r * 0.2, r)])
			draw_colored_polygon(tri, c)
			tri.append(tri[0])
			draw_polyline(tri, Color(0.08, 0.02, 0.12, 0.6 * al), 1.0)
			draw_rect(Rect2(-r * 0.5, -r * 0.4, r * 0.6, r * 0.15), Color(1, 1, 1, 0.8 * al))
		"paper":
			draw_set_transform(Vector2(p.x, p.y), p.rot, Vector2(cos(p.age * 10.0 + p.sh * 6.0), 1))
			draw_rect(Rect2(-r, -r * 0.75, r * 2, r * 1.5), c)
			draw_rect(Rect2(-r, -r * 0.75, r * 2, r * 1.5), Color(0.24, 0.2, 0.16, 0.6 * al), false, 1.0)
		"confetti":
			draw_set_transform(Vector2(p.x, p.y), p.rot, Vector2(cos(p.age * 14.0 + p.sh * 6.0), 1))
			draw_rect(Rect2(-r * 0.5, -r, r, r * 2), c)
		"fiber":
			draw_set_transform(Vector2(p.x, p.y), p.rot, Vector2.ONE)
			draw_polyline(PackedVector2Array([Vector2(-r, 0), Vector2(0, r * 0.5 * sin(p.age * 10.0)), Vector2(r, 0)]), c, maxf(1.2, r * 0.18))
		"twinkle":
			pass
		_:
			draw_set_transform(Vector2(p.x, p.y), p.rot, Vector2.ONE)
			var q := PackedVector2Array([Vector2(-r, -r * 0.6), Vector2(r * 0.4, -r * 0.9), Vector2(r, r * 0.3), Vector2(-r * 0.3, r * 0.8)])
			draw_colored_polygon(q, c)
			q.append(q[0])
			draw_polyline(q, dark, 1.2)
			draw_rect(Rect2(-r * 0.5, -r * 0.55, r * 0.6, r * 0.2), Color(1, 1, 1, 0.35 * al))

static func _star(R: float, r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI / 2 + i * PI / 5
		var q := R if i % 2 == 0 else r
		pts.append(Vector2(cos(a) * q, sin(a) * q))
	return pts

func _draw_add() -> void:
	var L := add_layer
	# flames on held diyas
	for h in held:
		if h.lit:
			var lit := minf(1.0, h.age / h.d * 3.0) * (1.0 + 0.4 * sin(h.age * 30.0))
			for p in DPOS:
				var fx: float = h.x + (p[0] - 0.04 + 0.395 * p[2]) * h.s
				var fy: float = h.y + (p[1] - 0.075 * p[2]) * h.s
				var fs: float = h.s * 0.34 * lit * (1.0 + 0.15 * sin(h.age * 31.0 + p[1] * 9.0))
				L.draw_texture_rect(RAD, Rect2(fx - fs, fy - fs * 1.4, fs * 2, fs * 2), false, Color(1, 0.7, 0.3, 0.7))
				L.draw_texture_rect(TX.flame, Rect2(fx - fs * 0.65, fy - fs * 1.15, fs * 1.3, fs * 1.3), false)
	for f in F:
		if f.age < 0.0:
			continue
		var k: float = f.age / f.life
		match f.k:
			"glow":
				L.draw_texture_rect(RAD, Rect2(f.x - f.R, f.y - f.R, f.R * 2, f.R * 2), false, Color(f.c, (1.0 - k) * 0.8))
			"rays":
				var R: float = f.R * (0.5 + 0.7 * k)
				var al := (1.0 - k) * 0.7
				for i in f.n:
					var a: float = f.a0 + k * 0.4 + i * TAU / f.n
					var w: float = f.R * 0.07 * (0.6 if i % 2 else 1.0)
					var Lr: float = R * (0.7 if i % 2 else 1.0)
					var dir := Vector2(cos(a), sin(a))
					var nrm := Vector2(-dir.y, dir.x)
					var c := Vector2(f.x, f.y)
					L.draw_polygon(PackedVector2Array([c - nrm * w, c + dir * Lr, c + nrm * w]), PackedColorArray([Color(f.c, al), Color(f.c, 0.0), Color(f.c, al)]))
			"flash":
				var R2: float = f.R * (0.6 + 0.6 * k)
				var a2 := 1.0 - k
				L.draw_texture_rect(RAD, Rect2(f.x - R2 * 0.5, f.y - R2 * 0.5, R2, R2), false, Color(1, 1, 1, a2))
				for j in 4:
					var aa: float = f.a0 + j * PI / 2
					var d := Vector2(cos(aa), sin(aa))
					var n := Vector2(-d.y, d.x)
					var c2 := Vector2(f.x, f.y)
					var ln := R2 * (0.7 if j % 2 else 1.0)
					L.draw_colored_polygon(PackedVector2Array([c2 - n * R2 * 0.05, c2 + d * ln, c2 + n * R2 * 0.05]), Color(1, 1, 0.94, a2))
			"fire":
				if k < 0.45:
					var R3: float = f.R * (0.5 + 1.1 * sqrt(k)) * 0.45
					L.draw_texture_rect(RAD, Rect2(f.x - R3, f.y - R3, R3 * 2, R3 * 2), false, Color(1, 1, 0.86, 0.5 * (1.0 - k / 0.45)))
	for p in A:
		var al2 := _alpha(p)
		var c3: Color = p.c
		c3.a *= al2
		var k5: float = p.age / p.life
		if p.k == "twinkle":
			var r: float = p.r * (1.0 - k5 * 0.5) * (0.7 + 0.3 * sin(p.age * 30.0))
			L.draw_set_transform(Vector2(p.x, p.y), p.rot, Vector2.ONE)
			L.draw_colored_polygon(_star(r, r * 0.3), c3)
			L.draw_set_transform(Vector2(p.x, p.y), p.rot + 0.785, Vector2.ONE)
			L.draw_colored_polygon(_star(r * 0.6, r * 0.2), Color(1, 1, 1, al2))
			L.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			var Lk := 0.035 if p.k == "streak" else 0.06
			var w2: float = p.r * (1.0 - k5 * 0.7)
			if p.k == "ember":
				w2 *= 0.7 + 0.3 * sin(p.age * 40.0 + p.sh * 9.0)
			L.draw_line(Vector2(p.x - p.vx * Lk, p.y - p.vy * Lk), Vector2(p.x, p.y), c3, maxf(1.0, w2 * 2.0))
			L.draw_circle(Vector2(p.x, p.y), maxf(0.6, w2 * 0.7), Color(1, 1, 1, al2))
