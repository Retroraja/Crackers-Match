# Falling debris layer above the board: a line-by-line copy of the web game's DEB (fx.js),
# with the Build 27 "small pieces" (b27.js) and the Build 30 piece limits (b30.js).
# Coordinates are screen coordinates (390 x 844); the board sits at y = oy.
extends Node2D
class_name CMDeb

var P: Array = []   # chunks, parts and bits
var SM: Array = []  # b27 small cracker pieces (fade out)
var oy := 112.0
var lite := false

func rnd(a: float, b: float) -> float:
	return a + randf() * (b - a)

func clear() -> void:
	P.clear()
	SM.clear()
	queue_redraw()

func add(o: Dictionary) -> void:
	# b30: at most 90 (light phones) or 120 pieces; fx.js: 240
	if P.size() > (90 if lite else 120):
		P.pop_front()
	if P.size() > 240:
		P.pop_front()
	if not o.has("rot"):
		o.rot = 0.0
	if not o.has("vr"):
		o.vr = (randf() - 0.5) * 12.0
	if not o.has("g") or o.g == 0:
		o.g = 1500.0
	o.age = 0.0
	P.append(o)

# the part of a clip polygon (dest space, centred) that lies inside the w x h picture rectangle, with matching uvs
static func _clip_uv(poly: PackedVector2Array, w: float, h: float, src: Rect2, tex_size: Vector2) -> Array:
	var rect := PackedVector2Array([Vector2(-w / 2, -h / 2), Vector2(w / 2, -h / 2), Vector2(w / 2, h / 2), Vector2(-w / 2, h / 2)])
	var pts := rect
	if poly.size() >= 3:
		var cut := Geometry2D.intersect_polygons(poly, rect)
		if cut.is_empty():
			return []
		pts = cut[0]
	var uvs := PackedVector2Array()
	for p in pts:
		var fx := (p.x + w / 2) / w
		var fy := (p.y + h / 2) / h
		uvs.append(Vector2((src.position.x + fx * src.size.x) / tex_size.x, (src.position.y + fy * src.size.y) / tex_size.y))
	return [pts, uvs]

func chunks(img: Texture2D, L: float, T: float, S: float, cols: int, rows: int, pw: float, o: Dictionary = {}) -> void:
	if img == null:
		return
	var iw := float(img.get_width())
	var ih := float(img.get_height())
	for i in cols:
		for j in rows:
			var q := PackedVector2Array()
			for n in 5:
				var a := float(n) / 5.0 * 6.283 + randf() * 0.6
				q.append(Vector2(cos(a) * (0.42 + randf() * 0.2), sin(a) * (0.42 + randf() * 0.2)))
			var dx := (i + 0.5) / cols - 0.5
			var dy := (j + 0.5) / rows - 0.5
			var w := S / cols
			var h := S / rows
			var poly := PackedVector2Array()
			if o.get("poly", true) != false:
				for p in q:
					poly.append(Vector2(p.x * w * 1.6, p.y * h * 1.6))
			var src := Rect2(iw * i / cols, ih * j / rows, iw / cols, ih / rows)
			var cu := _clip_uv(poly, w, h, src, Vector2(iw, ih))
			if cu.is_empty():
				continue
			add({"img": img, "pts": cu[0], "uvs": cu[1], "w": w, "h": h,
				"x": L + S * (i + 0.5) / cols, "y": T + oy + S * (j + 0.5) / rows,
				"vx": dx * pw * 520.0 + (randf() - 0.5) * 120.0, "vy": -260.0 * pw - randf() * 240.0 + dy * 200.0,
				"g": o.get("g", 0.0), "drag": o.get("drag", 0.0)})

func part(img: Texture2D, sx: float, sy: float, sw: float, sh: float, x: float, y: float, w: float, h: float, vx: float, vy: float) -> void:
	if img == null:
		return
	var cu := _clip_uv(PackedVector2Array(), w, h, Rect2(sx, sy, sw, sh), Vector2(img.get_width(), img.get_height()))
	add({"img": img, "pts": cu[0], "uvs": cu[1], "w": w, "h": h, "x": x, "y": y + oy, "vx": vx, "vy": vy})

func bits(x: float, y: float, n: int, cols: Array, sz: float, pw: float, o: Dictionary = {}) -> void:
	# b30: fewer bits (30% on light phones or when busy, else 50%)
	n = maxi(1, ceili(n * (0.3 if (lite or P.size() > 80) else 0.5)))
	if o.get("drag", 0.0) > 0.0:
		n = ceili(n * 0.6)
	for i in n:
		var a := randf() * 6.283
		var v := (0.3 + randf()) * pw
		add({"col": Color(cols[i % cols.size()]), "x": x, "y": y + oy, "w": sz * (0.6 + randf() * 0.8), "h": sz * (0.4 + randf() * 0.6),
			"vx": cos(a) * v * 260.0, "vy": sin(a) * v * 200.0 - 220.0 * pw, "g": o.get("g", 1300.0), "drag": o.get("drag", 0.0), "shape": o.get("shape", "")})

# b27: two small halves of the cracker that hop out, drop a short way and fade
func small(img: Texture2D, cx: float, cy: float, S: float) -> void:
	if img == null:
		return
	var iw := float(img.get_width())
	var ih := float(img.get_height())
	var D := [[-1.0, 0.0], [1.0, 0.5]]
	for d in D:
		var poly := PackedVector2Array()
		for q in [[-0.5, -0.45], [0.45, -0.3], [0.4, 0.5], [-0.45, 0.38]]:
			poly.append(Vector2((q[0] + rnd(-0.06, 0.06)) * S * 0.5, (q[1] + rnd(-0.06, 0.06)) * S * 0.5))
		var src := Rect2(iw * d[1], ih * 0.1, iw * 0.5, ih * 0.8)
		var cu := _clip_uv(poly, S * 0.5, S * 0.5, src, Vector2(iw, ih))
		if cu.is_empty():
			continue
		SM.append({"img": img, "pts": cu[0], "uvs": cu[1], "x": cx + d[0] * S * 0.16, "y": cy + oy,
			"vx": d[0] * rnd(60, 110), "vy": -rnd(110, 160), "g": 900.0, "rot": 0.0, "vr": d[0] * rnd(4, 8), "age": 0.0, "life": 0.5})

func _process(delta: float) -> void:
	if not P.is_empty() or not SM.is_empty():
		queue_redraw()

var _was := false
func _draw() -> void:
	var dt := minf(get_process_delta_time(), 0.04)
	var t := Time.get_ticks_msec() / 1000.0
	var keep: Array = []
	for p in P:
		p.vy += p.g * dt
		p.age += dt
		if p.age > 3.0:
			continue
		var drag: float = p.get("drag", 0.0)
		if drag > 0.0:
			if p.age > 1.1:
				continue
			p.vx *= 1.0 - drag * dt
			p.vy = minf(p.vy, 420.0)
			p.x += sin(t * 4.0 + p.w) * 20.0 * dt
		p.x += p.vx * dt
		p.y += p.vy * dt
		p.rot += p.vr * dt
		if p.y > 904.0:
			continue
		keep.append(p)
		var al := clampf((1.1 - p.age) / 0.4, 0.0, 1.0) if drag > 0.0 else 1.0
		draw_set_transform(Vector2(p.x, p.y), p.rot, Vector2.ONE)
		if p.has("img"):
			draw_colored_polygon(p.pts, Color(1, 1, 1, al), p.uvs, p.img)
		else:
			var col: Color = p.col
			col.a *= al
			var sh: String = p.get("shape", "")
			if sh == "blob":
				_ellipse(Vector2.ZERO, p.w / 2, p.h / 2, col)
			elif sh == "drop":
				draw_colored_polygon(PackedVector2Array([Vector2(0, -8), Vector2(5, -1), Vector2(4, 4), Vector2(0, 5), Vector2(-4, 4), Vector2(-5, -1)]), col)
			elif sh == "tri":
				draw_colored_polygon(PackedVector2Array([Vector2(0, -p.h / 2), Vector2(p.w / 2, p.h / 2), Vector2(-p.w / 2, p.h / 3)]), col)
			else:
				draw_rect(Rect2(-p.w / 2, -p.h / 2, p.w, p.h), col)
	P = keep
	var keep2: Array = []
	for p in SM:
		p.age += dt
		if p.age >= p.life:
			continue
		p.vy += p.g * dt
		p.x += p.vx * dt
		p.y += p.vy * dt
		p.rot += p.vr * dt
		var f: float = p.age / p.life
		keep2.append(p)
		draw_set_transform(Vector2(p.x, p.y), p.rot, Vector2.ONE)
		draw_colored_polygon(p.pts, Color(1, 1, 1, 1.0 - f * f), p.uvs, p.img)
	SM = keep2
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _ellipse(c: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 16:
		var a := i / 16.0 * TAU
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, col)
