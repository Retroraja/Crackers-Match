# cabinet.js FX3D layer: pieces that fly toward the player, tumble in 3D and fall off the screen,
# plus the impact effects (flash, ring, burst lines, dust). Screen coordinates; the board sits at y = OY.
extends Node2D
class_name CMFly

const OY := 112.0
var P: Array = []
var E: Array = []
var dim := 0.0
var FLASH: Texture2D

func rnd(a: float, b: float) -> float:
	return a + randf() * (b - a)

func _ready() -> void:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.4, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 240 / 255.0, 190 / 255.0, 0.6), Color(1, 220 / 255.0, 150 / 255.0, 0)])
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	gt.width = 128
	gt.height = 128
	FLASH = gt

# piece = {tex, pts (local, centred, px), uvs} or {poly (colour shape), col}
func fly(piece: Dictionary, cx: float, cy: float, o: Dictionary = {}) -> void:
	var q := piece.duplicate()
	q.merge({"s0": o.get("s0", 1.0), "x": cx, "y": cy + OY, "t": 0.0, "life": o.get("life", 3.0), "vx": o.get("vx", 0.0), "vy": o.get("vy", -300.0),
		"g": o.get("g", 1300.0), "z": 0.0, "vz": o.get("vz", 1.4), "zmax": o.get("zmax", 1.6), "ax": 0.0, "ay": 0.0,
		"wx": o.get("wx", 0.0), "wy": o.get("wy", 0.0), "rot": o.get("rot", 0.0), "vr": o.get("vr", 0.0), "nb": o.get("nb", false)}, true)
	P.append(q)

# small 3D crumb or splinter
func crumb(col: String, kind: String, sz: float) -> Dictionary:
	var k := sz / 24.0
	var pts := PackedVector2Array()
	if kind == "s":
		for p in [Vector2(2, 10), Vector2(22, 7), Vector2(23, 13), Vector2(3, 16)]:
			pts.append((p - Vector2(12, 12)) * k)
	else:
		for i in 7:
			var a := i / 7.0 * 6.283
			var r := rnd(6, 10)
			pts.append(Vector2(cos(a) * r, sin(a) * r) * k)
	return {"poly": pts, "col": Color(col), "kind": kind, "k": k}

func spray(px: float, py: float, cols: Array, n: int, kind: String, o: Dictionary = {}) -> void:
	for i in n:
		var up: float = o.get("up", 0.0)
		var a := (-PI / 2 + rnd(-up, up)) if up > 0.0 else rnd(0, 6.28)
		var v := rnd(o.get("v0", 120.0), o.get("v1", 380.0))
		var sz := rnd(o.get("s0", 4.0), o.get("s1", 9.0))
		fly(crumb(cols[i % cols.size()], kind, sz), px + rnd(-8, 8), py + rnd(-8, 8), {"s0": 1.0, "vx": cos(a) * v, "vy": sin(a) * v - (0.0 if up > 0.0 else rnd(150, 300)),
			"vz": rnd(0.6, 1.8), "zmax": rnd(0.6, 1.6), "wx": rnd(-14, 14), "wy": rnd(-14, 14), "vr": rnd(-10, 10), "g": o.get("g", 1200.0), "life": 2.5, "nb": true})

func impact(cx: float, cy: float, r: float, big: bool) -> void:
	var y := cy + OY
	var a: Array = []
	var n := 14 if big else 10
	for i in n:
		a.append(i / float(n) * 6.283 + rnd(-0.15, 0.15))
	E.append({"k": "flash", "x": cx, "y": y, "r": r * 1.3, "t": 0.0, "d": 0.22})
	E.append({"k": "ring", "x": cx, "y": y, "r": r, "t": 0.0, "d": 0.35})
	E.append({"k": "lines", "x": cx, "y": y, "r": r * 1.3, "a": a, "t": 0.0, "d": 0.3})
	for i in (10 if big else 6):
		var b := rnd(0, 6.28)
		var v := rnd(30, 90)
		E.append({"k": "dust", "x": cx + rnd(-r * 0.4, r * 0.4), "y": y + rnd(-r * 0.3, r * 0.4), "vx": cos(b) * v, "vy": sin(b) * v - 20, "r": rnd(8, 16) * (1.5 if big else 1.0),
			"col": Color(230 / 255.0, 205 / 255.0, 170 / 255.0) if i % 2 else Color(1, 245 / 255.0, 225 / 255.0), "t": 0.0, "d": rnd(0.45, 0.7)})

func _process(_d: float) -> void:
	if not P.is_empty() or not E.is_empty() or dim > 0.0:
		queue_redraw()

func _draw() -> void:
	var dt := minf(get_process_delta_time(), 0.04)
	if dim > 0.0:
		dim = maxf(0.0, dim - dt * 1.6)
		draw_rect(Rect2(0, 0, 390, 844), Color(10 / 255.0, 0, 25 / 255.0, minf(0.35, dim)))
	var ke: Array = []
	for e in E:
		e.t += dt
		var p: float = e.t / e.d
		if p >= 1.0:
			continue
		ke.append(e)
		if e.k == "ring":
			draw_arc(Vector2(e.x, e.y), e.r * (0.3 + p * 1.2), 0, TAU, 40, Color(1, 247 / 255.0, 214 / 255.0, (1 - p) * 0.9), 8 * (1 - p) + 1, true)
		elif e.k == "lines":
			for a in e.a:
				var r0: float = e.r * (0.2 + p * 0.9)
				var r1: float = r0 + e.r * (0.55 * (1 - p) + 0.1)
				draw_line(Vector2(e.x + cos(a) * r0, e.y + sin(a) * r0), Vector2(e.x + cos(a) * r1, e.y + sin(a) * r1), Color(1, 1, 1, 1 - p), 3 * (1 - p) + 0.5, true)
		elif e.k == "dust":
			draw_circle(Vector2(e.x + e.vx * e.t, e.y + e.vy * e.t), e.r * (0.5 + p * 1.3), Color(e.col, (1 - p) * 0.55))
		elif e.k == "flash":
			draw_texture_rect(FLASH, Rect2(e.x - e.r, e.y - e.r, e.r * 2, e.r * 2), false, Color(1, 1, 1, (1 - p) * 0.7))
	E = ke
	if P.size() > 150:
		P = P.slice(P.size() - 150)
	P.sort_custom(func(a, b): return a.s0 * (1 + a.z) < b.s0 * (1 + b.z))
	var kp: Array = []
	for o in P:
		o.t += dt
		o.vy += o.g * dt
		o.x += o.vx * dt
		o.y += o.vy * dt
		o.z = minf(o.zmax, o.z + o.vz * dt)
		o.vz *= pow(0.25, dt)
		o.ax += o.wx * dt
		o.ay += o.wy * dt
		o.rot += o.vr * dt
		var hh: float = o.get("h", 20.0)
		if o.y - hh * (1 + o.z) > 870 or o.t > o.life:
			continue
		kp.append(o)
		var s: float = o.s0 * (1 + o.z)
		var fx := cos(o.ay)
		var fy := cos(o.ax)
		var back := fx * fy < 0
		draw_set_transform(Vector2(o.x, o.y), o.rot, Vector2(s * maxf(0.06, absf(fx)), s * maxf(0.06, absf(fy))))
		if o.has("tex"):
			var m := Color(0.55, 0.55, 0.55) if back else Color.WHITE
			draw_colored_polygon(o.pts, m, o.uvs, o.tex)
		else:
			draw_colored_polygon(o.poly, o.col)
			if o.kind == "s":
				draw_rect(Rect2(Vector2(4 - 12, 9 - 12) * o.k, Vector2(16, 2) * o.k), Color(1, 240 / 255.0, 210 / 255.0, 0.6))
			else:
				draw_circle(Vector2(-3, -3) * o.k, 3 * o.k, Color(1, 1, 1, 0.45))
	P = kp
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
