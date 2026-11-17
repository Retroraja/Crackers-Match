# Small drawn pieces of the web game screens: the giant ground chakra behind the win screen (app.js chakra/fxLoop),
# the little fireworks (winBurst/winFx), the tick mark and the lock icon.
extends RefCounted
class_name AppFx

static func grad_tex(offs: Array, cols: Array, radial: bool, from := Vector2(0.5, 0.5), to := Vector2(1.0, 0.5)) -> GradientTexture2D:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array(offs)
	g.colors = PackedColorArray(cols)
	var t := GradientTexture2D.new()
	t.gradient = g
	t.width = 256
	t.height = 256
	if radial:
		t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = from
	t.fill_to = to
	return t

static func ramp(stops: Array, t: float) -> Color:
	t = clampf(t, 0.0, 1.0)
	for i in range(1, stops.size()):
		if t <= stops[i][0]:
			var a = stops[i - 1]
			var b = stops[i]
			return Color(a[1]).lerp(Color(b[1]), (t - a[0]) / maxf(b[0] - a[0], 1e-5))
	return Color(stops[-1][1])

static func bez(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var u := 1.0 - t
	return p0 * u * u * u + p1 * 3.0 * u * u * t + p2 * 3.0 * u * t * t + p3 * t * t * t


# ---------------------------------------------------------------- giant ground chakra (win screen)
class Chakra extends Control:
	var on := false
	var rot := 0.0
	var P: Array = []
	var glow: Texture2D
	var disc: Texture2D
	var spoke := PackedVector2Array()
	var add_layer: Control
	const CX := 195.0
	const CY := 430.0
	const R := 166.0

	func _init() -> void:
		size = Vector2(390, 844)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		# rgba #FF5FD288 from R*.5 to transparent at R*1.6
		glow = AppFx.grad_tex([0.0, 0.5 / 1.6, 1.0], [Color("#FF5FD288"), Color("#FF5FD288"), Color(1, 0.37, 0.82, 0)], true)
		disc = AppFx.grad_tex([0.0, 0.1, 0.64, 1.0], [Color("#F070D8"), Color("#F070D8"), Color("#B0249E"), Color("#5A0A5E")], true, Vector2(0.5, 0.35), Vector2(1.0, 0.35))
		# spoke outline (app.js spoke)
		var a := []
		for i in 13:
			a.append(AppFx.bez(Vector2(-14, -40), Vector2(60, -60), Vector2(R * 0.55, -R * 0.2), Vector2(R * 0.98, R * 0.18), i / 12.0))
		a.append(Vector2(R * 0.98, R * 0.34))
		for i in range(1, 13):
			a.append(AppFx.bez(Vector2(R * 0.98, R * 0.34), Vector2(R * 0.5, -R * 0.02), Vector2(60, -30), Vector2(14, -40), i / 12.0))
		spoke = PackedVector2Array(a)
		add_layer = Control.new()
		add_layer.size = size
		add_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var m := CanvasItemMaterial.new()
		m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		add_layer.material = m
		add_layer.draw.connect(_draw_parts)
		add_child(add_layer)

	func start() -> void:
		on = true
		P.clear()
		visible = true

	func stop() -> void:
		on = false
		P.clear()
		visible = false

	func _process(dt: float) -> void:
		if not on:
			return
		dt = minf(dt, 0.04)
		rot += dt * 0.9
		var cs := ["#FFE27A", "#FFFFFF", "#FFB020", "#FF7AD8"]
		for i in 4:
			var a := randf() * 6.283
			var sp := 200.0 + randf() * 220.0
			P.append({"x": CX + cos(a) * 192, "y": CY + sin(a) * 192, "vx": -sin(a) * sp + cos(a) * 60, "vy": cos(a) * sp + sin(a) * 60, "l": 0.5 + randf() * 0.4, "m": 0.9, "c": Color(cs[i])})
		var k: Array = []
		for p in P:
			p.l -= dt
			if p.l <= 0:
				continue
			p.ox = p.x
			p.oy = p.y
			p.vy += 260 * dt
			p.x += p.vx * dt
			p.y += p.vy * dt
			k.append(p)
		P = k
		queue_redraw()
		add_layer.queue_redraw()

	func _draw_parts() -> void:
		for p in P:
			var c: Color = p.c
			c.a = minf(1.0, p.l / p.m * 1.6)
			add_layer.draw_line(Vector2(p.ox - p.vx * 0.02, p.oy - p.vy * 0.02), Vector2(p.x, p.y), c, 2.4, true)

	func _circle(r: float, n: int) -> PackedVector2Array:
		var a := PackedVector2Array()
		for i in n:
			var t := i / float(n) * TAU
			a.append(Vector2(cos(t), sin(t)) * r)
		return a

	func _draw() -> void:
		if not on:
			return
		var c := Vector2(CX, CY)
		draw_texture_rect(glow, Rect2(c - Vector2.ONE * R * 1.6, Vector2.ONE * R * 3.2), false)
		draw_set_transform(c, rot, Vector2.ONE)
		var pts := _circle(R, 72)
		var uv := PackedVector2Array()
		for p in pts:
			uv.append(p / (2 * R) + Vector2(0.5, 0.5))
		draw_colored_polygon(pts, Color.WHITE, uv, disc)
		var st := [[0.0, "#FFF3A6"], [0.5, "#F2B533"], [1.0, "#B5700E"]]
		var g0 := Vector2(0, -R * 0.5)
		var g1 := Vector2(R, R * 0.4)
		var gd := g1 - g0
		var n2 := spoke.size()
		for k in 4:
			var tr := Transform2D(k * PI / 2, Vector2.ZERO)
			var sp := PackedVector2Array()
			var cols := PackedColorArray()
			for p in spoke:
				sp.append(tr * p)
				cols.append(AppFx.ramp(st, (p - g0).dot(gd) / gd.length_squared()))
			# filled as a strip of quads between the upper and the lower curve (the outline is not a simple polygon)
			for i in 12:
				var a0 := i
				var a1 := i + 1
				var b0 := n2 - 1 - i
				var b1 := n2 - 2 - i
				draw_primitive(PackedVector2Array([sp[a0], sp[a1], sp[b1]]), PackedColorArray([cols[a0], cols[a1], cols[b1]]), PackedVector2Array())
				draw_primitive(PackedVector2Array([sp[a0], sp[b1], sp[b0]]), PackedColorArray([cols[a0], cols[b1], cols[b0]]), PackedVector2Array())
			var cl := sp.duplicate()
			cl.append(sp[0])
			draw_polyline(cl, Color("#8A4E08"), 2.0, true)
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
		# gold rim with a diagonal gradient
		var rs := [[0.0, "#FFF6B8"], [0.35, "#F5C23C"], [0.7, "#C7801A"], [1.0, "#FFE27A"]]
		var a0 := c - Vector2(R, R)
		var ad := Vector2(2 * R, 2 * R)
		var n := 90
		for i in n:
			var t0 := i / float(n) * TAU
			var t1 := (i + 1) / float(n) * TAU
			var q := PackedVector2Array([c + Vector2(cos(t0), sin(t0)) * (R - 2), c + Vector2(cos(t1), sin(t1)) * (R - 2), c + Vector2(cos(t1), sin(t1)) * (R + 24), c + Vector2(cos(t0), sin(t0)) * (R + 24)])
			var qc := PackedColorArray()
			for p in q:
				qc.append(AppFx.ramp(rs, (p - a0).dot(ad) / ad.length_squared()))
			draw_primitive(PackedVector2Array([q[0], q[1], q[2]]), PackedColorArray([qc[0], qc[1], qc[2]]), PackedVector2Array())
			draw_primitive(PackedVector2Array([q[0], q[2], q[3]]), PackedColorArray([qc[0], qc[2], qc[3]]), PackedVector2Array())
		draw_arc(c, R - 2, 0, TAU, 96, Color("#7A4206"), 3.0, true)
		draw_arc(c, R + 21, 3.6, 5.2, 40, Color("#FFFBE0aa"), 3.0, true)


# ---------------------------------------------------------------- small fireworks (winBurst / winFx)
# slowly turning light rays (sunburst) behind an icon
class Rays extends Control:
	var n := 12
	var col := Color(1, 0.85, 0.4, 0.5)
	var spin := 0.5
	var a := 0.0
	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		var m := CanvasItemMaterial.new()
		m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		material = m
	func _process(dt: float) -> void:
		a += dt * spin
		queue_redraw()
	func _draw() -> void:
		var c := size / 2
		var r := minf(size.x, size.y) / 2
		for i in n:
			var t := a + TAU * i / n
			var w := PI / n * 0.55
			draw_colored_polygon(PackedVector2Array([c, c + Vector2(cos(t - w), sin(t - w)) * r, c + Vector2(cos(t + w), sin(t + w)) * r]),
				col, PackedVector2Array(), null)
		draw_circle(c, r * 0.42, Color(col.r, col.g, col.b, col.a * 0.5))

# win screen: the man shows only above the line y = top and inside the ring (web winguy mask)
class RingMask extends Control:
	var top := 430.0
	var cen := Vector2(195, 430)
	var rad := 164.0
	var xf := Transform2D.IDENTITY   # stage -> local
	func _init() -> void:
		clip_children = CanvasItem.CLIP_CHILDREN_ONLY
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		draw_set_transform_matrix(xf)
		draw_rect(Rect2(-200, -400, 790, top + 400), Color.WHITE)
		draw_circle(cen, rad, Color.WHITE)

class Fireworks extends Control:
	var on := false
	var auto := false
	var P: Array = []
	var nx := 1.2
	var sfx: Sfx

	func _init() -> void:
		size = Vector2(390, 844)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		var m := CanvasItemMaterial.new()
		m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		material = m

	func burst(x: float, y: float, big: bool) -> void:
		var cs := ["#FFE27A", "#FFFFFF", "#FFB020", "#FF4B6E", "#7FD7FF"]
		var n := 70 if big else 44
		for i in n:
			var a := i / float(n) * 6.283
			var v := (210.0 if big else 150.0) * (0.55 + randf() * 0.5)
			P.append({"x": x, "y": y, "ox": x, "oy": y, "vx": cos(a) * v, "vy": sin(a) * v, "l": 0.8 + randf() * 0.6, "m": 1.4, "c": Color(cs[i % 5])})

	func run(b: bool) -> void:
		auto = b
		nx = 1.2
		if not b:
			P.clear()

	func _process(dt: float) -> void:
		if not is_visible_in_tree():
			return
		dt = minf(dt, 0.04)
		if auto:
			nx -= dt
			if nx <= 0:
				nx = 1.4 + randf() * 1.4
				burst(60 + randf() * 270, 70 + randf() * 90, false)
				if sfx:
					sfx.play("pop", 0.18, 0.9 + randf() * 0.2)
		if P.is_empty():
			return
		var k: Array = []
		for p in P:
			p.l -= dt
			if p.l <= 0:
				continue
			p.ox = p.x
			p.oy = p.y
			p.vx *= 0.985
			p.vy = p.vy * 0.985 + 80 * dt
			p.x += p.vx * dt
			p.y += p.vy * dt
			k.append(p)
		P = k
		queue_redraw()

	func _draw() -> void:
		for p in P:
			var c: Color = p.c
			c.a = minf(1.0, p.l / p.m * 1.8)
			draw_line(Vector2(p.ox - p.vx * 0.03, p.oy - p.vy * 0.03), Vector2(p.x, p.y), c, 2.0, true)


# ---------------------------------------------------------------- tick mark (the web uses the ✓ character)
class Tick extends Control:
	var col := Color.WHITE
	var w := 2.6
	func _init(sz: Vector2, c := Color.WHITE, lw := 2.6) -> void:
		size = sz
		col = c
		w = lw
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		var s := size
		draw_polyline(PackedVector2Array([Vector2(s.x * 0.27, s.y * 0.52), Vector2(s.x * 0.43, s.y * 0.68), Vector2(s.x * 0.74, s.y * 0.34)]), col, w, true)


# ---------------------------------------------------------------- round badge (counts on slots and boosters)
static func badge(text: String, bg: Color, sz: Vector2, font: Font, fs: int, rad: float, border := 0.0) -> Control:
	var p := Panel.new()
	var st := StyleBoxFlat.new()
	st.bg_color = bg
	st.set_corner_radius_all(int(rad))
	if border > 0:
		st.border_color = Color.WHITE
		st.set_border_width_all(int(border))
	st.anti_aliasing = true
	p.add_theme_stylebox_override("panel", st)
	p.size = sz
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := Label.new()
	l.name = "txt"
	l.text = text
	var ls := LabelSettings.new()
	ls.font = font
	ls.font_size = fs
	ls.font_color = Color.WHITE
	l.label_settings = ls
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.size = sz
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(l)
	return p


# ---------------------------------------------------------------- 5-point gold star (CSS clip-path star)
class Star extends Control:
	func _init(sz: Vector2) -> void:
		size = sz
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		var P := [[50, 0], [61, 35], [98, 35], [68, 57], [79, 91], [50, 70], [21, 91], [32, 57], [2, 35], [39, 35]]
		var pts := PackedVector2Array()
		var cols := PackedColorArray()
		for q in P:
			pts.append(Vector2(q[0], q[1]) / 100.0 * size)
			cols.append(Color("#FFE58A").lerp(Color("#F2B533"), q[1] / 100.0))
		draw_polygon(pts, cols)
