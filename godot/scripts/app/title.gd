# Intro (RetroRaja logo) and the 2.5D title screen (street/index.html + scene9.js):
# the painted house with the living effects (sun rays, window glow, chimney smoke, petals, water glints,
# butterflies, birds, drifting clouds), the CRACKERS MATCH logo shot in by a rocket, fireworks, "Tap to Play".
extends Control
class_name TitleScreen

signal tapped
signal agreed

var app
var intro: Control
var title: Control
var LT: WebLayout
var LI: WebLayout
var fxc: SceneFx
var fw: TitleFw
var spfw: SpriteFw
var tod := "night"
var clouds: Array = []
var busyT := true
var ready_street := true
var rk_t := -1.0

func build(a) -> void:
	app = a
	size = Vector2(390, 844)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	LT = WebLayout.new()
	title = LT.build("res://ui/st_title.json", self)
	title.mouse_filter = Control.MOUSE_FILTER_STOP
	title.gui_input.connect(_title_input)
	# the effects canvas sits between the painting and the front plants
	var cvs: Control = LT.nodes[5]
	fxc = SceneFx.new()
	fxc.size = Vector2(390, 844)
	cvs.add_child(fxc)
	# the old painted front plants do not belong to the new rendered picture
	LT.nodes[6].visible = false
	# 25 Nov: new night title picture (no bakery): the bakery's sun rays / smoke / petals and the day clouds are off
	fxc.visible = false
	LT.nodes[7].visible = false
	LT.nodes[8].visible = false
	clouds = []
	fw = TitleFw.new()
	fw.size = Vector2(390, 844)
	add_child(fw)
	# 25 Nov: the title picture follows the phone's clock: afternoon 6-16, evening 16-19, night 19-6
	var hr: int = Time.get_datetime_dict_from_system().hour
	for ar in OS.get_cmdline_user_args():
		if ar.begins_with("--hour="):
			hr = int(ar.substr(7))
	tod = "aft" if hr >= 6 and hr < 16 else ("eve" if hr >= 16 and hr < 19 else "night")
	var bgi: TextureRect = LT.nodes[3].get_node_or_null("bgimg")
	if bgi and tod != "night":
		bgi.texture = WebLayout.tex("art/title_%s.webp" % tod)
	spfw = SpriteFw.new()
	spfw.size = Vector2(390, 844)
	spfw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spfw.strength = {"aft": 0.75, "eve": 0.9, "night": 1.0}[tod]
	LT.nodes[2].add_child(spfw)
	LI = WebLayout.new()
	intro = LI.build("res://ui/st_intro.json", self)
	intro.modulate.a = 1
	title.visible = false
	for i in [10, 13]:
		LT.nodes[i].modulate.a = 0
	LT.nodes[16].modulate.a = 0

func _process(dt: float) -> void:
	if not visible or not title.visible:
		return
	for c in clouds:
		var m: Array = c.get_meta("cl")
		var t: float = fmod(Time.get_ticks_msec() / 1000.0 + m[1], m[0]) / m[0]
		c.position.x = lerpf(-1.4, 4.2, t) * c.size.x

# intro for 2.6 s, then the title; the logo comes in after the Welcome card (first open) or straight away
func play(first_open: bool) -> void:
	visible = true
	busyT = true
	intro.visible = true
	intro.modulate.a = 1
	Anim.play(LI.nodes[1], "st_ip", 0.9, 0.2, "cubic-bezier(.2,1.4,.4,1)")
	app.sfx.play("brand", 0.8)
	await get_tree().create_timer(2.6).timeout
	title.visible = true
	Anim.play(LT.nodes[2], "st_breathe", 9.0, 0.0, "ease-in-out", -1, true, {}, true)
	fxc.run = false
	create_tween().tween_property(intro, "modulate:a", 0.0, 0.6)
	await get_tree().create_timer(0.6).timeout
	intro.visible = false
	if first_open:
		agreed.connect(_reveal, CONNECT_ONE_SHOT)
		app.show_agree()
	else:
		_reveal()

func _reveal() -> void:
	app.sfx.mus_start()
	app.sfx.play("rocket", 0.7)
	spfw.rocket(195, 844 * 0.2, 0.9, func(x: float, y: float):
		app.sfx.play("blast", 0.8)
		_side_rockets()
		spfw.big(x, y, "gold", 330)
		for i in [10, 13]:
			var r: Control = LT.nodes[i]
			r.scale = Vector2.ONE
			r.remove_meta("base")
			r.modulate.a = 1
			Anim.play(r, "st_lgin", 0.7, 0.0 if i == 10 else 0.12, "cubic-bezier(.2,1.5,.4,1)")
		get_tree().create_timer(0.4).timeout.connect(func():
			spfw.big(390 * 0.2, 844 * 0.3, "red", 190)
			spfw.big(390 * 0.8, 844 * 0.34, "green", 190))
		get_tree().create_timer(0.9).timeout.connect(_show_tap))

func _show_tap() -> void:
	# "Tap to Play" stays and blinks (with a soft pulse) until the player taps.
	# (Anim's st_tap kept the hidden opacity it captured, so the prompt vanished.)
	var tp: Control = LT.nodes[16]
	Anim.stop(tp)
	tp.remove_meta("base")
	tp.pivot_offset = tp.size / 2.0
	tp.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(tp, "modulate:a", 1.0, 0.5)
	t.tween_callback(func():
		var b := tp.create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		b.tween_property(tp, "modulate:a", 0.3, 0.6)
		b.parallel().tween_property(tp, "scale", Vector2.ONE * 1.06, 0.6)
		b.tween_property(tp, "modulate:a", 1.0, 0.6)
		b.parallel().tween_property(tp, "scale", Vector2.ONE, 0.6))
	busyT = false

# 25 Nov: one firework every 1-2 s: a glowing rocket trail goes up, a big ready-made burst pops, grows and fades
func _side_rockets() -> void:
	get_tree().create_timer(1.0 + randf() * 1.0).timeout.connect(func():
		if not visible or not title.visible:
			return
		app.sfx.play("rocket", 0.3, 1.15)
		var x := 390.0 * (0.12 + randf() * 0.76)
		var y := 844.0 * (0.1 + randf() * 0.28)
		spfw.rocket(x, y, 0.75, func(bx: float, by: float):
			app.sfx.play("pop", 0.4)
			spfw.big(bx, by, ["gold", "red", "green", "willow", "blue"][randi() % 5], 170 + randf() * 90))
		_side_rockets())

func _title_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		if busyT:
			return
		busyT = true
		tapped.emit()

# fade the title away (the street or the first level comes in behind)
func leave() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.9)
	tw.tween_callback(func():
		visible = false
		modulate.a = 1
		fxc.run = false)


# ---------------------------------------------------------------- scene9.js living effects (title painting 780 x 1688)
class SceneFx extends Control:
	var run := false
	var t := 0.0
	var smoke: Array = []
	var petals: Array = []
	var glints: Array = []
	var birds: Array = []
	var tS := 0.0
	var tP := 0.0
	var tG := 0.0
	var tB := 1.2
	var K := 1.0
	var OX := 0.0
	var OY := 0.0
	var add_layer: Control
	var glow: Texture2D
	var smoke_tex: Texture2D
	# 20 Nov: the title picture is now rendered from our 3D street (full quality, shadows): the Bakery
	const C := {"w": 780.0, "h": 1688.0, "px": 0.5, "chim": [508, 616], "win": [[443, 981], [455, 1016], [299, 990], [311, 797], [422, 791]],
		"tree": [[118, 805], [671, 840]], "petal": ["#FFB0C8", "#FFD2A0", "#FFFFFF"], "water": [],
		"fly": [[258, 1332], [574, 1191]], "bf": [["#FFB020", "#FF7A00"], ["#7FC8FF", "#3D7BFF"]]}

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_layer = Control.new()
		add_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var m := CanvasItemMaterial.new()
		m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		add_layer.material = m
		add_layer.draw.connect(_draw_add)
		add_child(add_layer)
		glow = AppFx.grad_tex([0.0, 1.0], [Color(1, 1, 1, 1), Color(1, 1, 1, 0)], true)
		smoke_tex = AppFx.grad_tex([0.0, 0.55, 1.0], [Color(236 / 255.0, 238 / 255.0, 244 / 255.0, 1), Color(188 / 255.0, 193 / 255.0, 208 / 255.0, 0.9), Color(170 / 255.0, 176 / 255.0, 192 / 255.0, 0)], true, Vector2(0.38, 0.35), Vector2(0.88, 0.35))

	func P(x: float, y: float) -> Vector2:
		return Vector2(OX + x * K, OY + y * K)

	func rnd(a: float, b: float) -> float:
		return a + randf() * (b - a)

	func _process(dt: float) -> void:
		if not run or not is_visible_in_tree():
			return
		dt = minf(dt, 0.12)
		t += dt
		var W := size.x
		var H := size.y
		K = maxf(W / C.w, H / C.h)
		OX = (W - C.w * K) * C.px
		OY = (H - C.h * K) * 0.3
		add_layer.size = size
		tS -= dt
		if tS <= 0:
			tS = rnd(0.55, 0.8)
			smoke.append({"x": C.chim[0] + rnd(-3, 3), "y": C.chim[1], "r": rnd(6, 9), "life": 0.0, "max": rnd(4.5, 6)})
		tP -= dt
		if tP <= 0:
			tP = rnd(0.7, 1.2)
			if petals.size() < 10:
				var b: Array = C.tree
				petals.append({"x": rnd(b[0][0], b[1][0]), "y": rnd(b[0][1], b[1][1]), "vx": rnd(6, 16), "vy": rnd(10, 18), "rot": rnd(0, 6), "vr": rnd(-2, 2), "ph": rnd(0, 6),
					"col": Color(C.petal[randi() % C.petal.size()]), "life": 0.0, "max": rnd(7, 10), "s": rnd(8, 11)})
		tG -= dt
		if tG <= 0 and not C.water.is_empty():
			tG = rnd(0.18, 0.4)
			var w: Array = C.water[randi() % C.water.size()]
			glints.append({"x": w[0] + rnd(0, w[2]), "y": w[1] + rnd(0, w[3]), "life": 0.0, "max": rnd(0.7, 1.1), "s": rnd(8, 12)})
		tB -= dt
		if tB <= 0:
			tB = rnd(9, 14)
			var dir := 1 if randf() < 0.5 else -1
			var n := 2 + randi() % 2
			var y0 := rnd(230, 360)
			var v := rnd(55, 70)
			for i in n:
				birds.append({"x": (120 - i * rnd(22, 34)) if dir > 0 else (720 + i * rnd(22, 34)), "y": y0 + i * rnd(-12, 14), "v": v * dir, "ph": rnd(0, 6), "s": rnd(13, 16)})
		var k2: Array = []
		for p in smoke:
			p.life += dt
			if p.life < p.max:
				k2.append(p)
		smoke = k2
		k2 = []
		for p in petals:
			p.life += dt
			if p.life < p.max:
				p.x += (p.vx + sin(p.life * 1.6 + p.ph) * 10) * dt
				p.y += p.vy * dt
				p.rot += p.vr * dt
				k2.append(p)
		petals = k2
		k2 = []
		for p in glints:
			p.life += dt
			if p.life < p.max:
				k2.append(p)
		glints = k2
		k2 = []
		for b in birds:
			b.x += b.v * dt
			b.y += sin(t * 1000 / 900 + b.ph) * 0.06
			if b.x > 60 and b.x < 780:
				k2.append(b)
		birds = k2
		queue_redraw()
		add_layer.queue_redraw()

	func _draw_add() -> void:
		# sun glow and rays from the top right, window glow
		var W := size.x
		var H := size.y
		var tm := t * 1000.0
		var sp := Vector2(W * 0.96, -H * 0.04)
		var ga := 0.32 + 0.08 * sin(tm / 1700)
		add_layer.draw_texture_rect(glow, Rect2(sp - Vector2.ONE * W * 0.55, Vector2.ONE * W * 1.1), false, Color(1, 240 / 255.0, 190 / 255.0, ga))
		for i in 4:
			var an := 2.05 + i * 0.17 + sin(tm / 4200 + i * 1.7) * 0.03
			var ln := H * 0.85
			var wd := 0.05 + 0.015 * sin(tm / 3100 + i)
			var a := 0.16 + 0.07 * sin(tm / 2300 + i * 2.1)
			var c0 := Color(1, 248 / 255.0, 215 / 255.0, a)
			var c1 := Color(1, 248 / 255.0, 215 / 255.0, 0)
			add_layer.draw_polygon(PackedVector2Array([sp, sp + Vector2(cos(an - wd), sin(an - wd)) * ln, sp + Vector2(cos(an + wd), sin(an + wd)) * ln]), PackedColorArray([c0, c1, c1]))
		var i2 := 0
		for w in C.win:
			var q := P(w[0], w[1])
			var r := 26 * K
			var a2 := 0.28 + 0.08 * sin(tm / 430 + i2 * 1.9) + 0.05 * sin(tm / 170 + i2)
			add_layer.draw_texture_rect(glow, Rect2(q - Vector2(r, r), Vector2(r, r) * 2), false, Color(1, 200 / 255.0, 90 / 255.0, a2))
			i2 += 1

	func _draw() -> void:
		var tm := t * 1000.0
		# butterflies
		var BF := [0.0, 2.7]
		for i in 2:
			var f: Array = C.fly
			var cx: float = (f[0][0] + f[1][0]) / 2.0
			var cy: float = (f[0][1] + f[1][1]) / 2.0
			var rx: float = (f[1][0] - f[0][0]) / 2.0
			var ry: float = (f[1][1] - f[0][1]) / 2.0
			var tt: float = tm / 1000 * 0.22 + BF[i]
			var x := cx + sin(tt * 1.3) * rx * 0.9 + sin(tt * 3.1) * 12
			var y := cy + sin(tt * 2.1 + 1) * ry * 0.8 + sin(tt * 5) * 6
			var q := P(x, y)
			var dx := cos(tt * 1.3) * 1.3 + cos(tt * 3.1) * 0.3
			var fl := 0.35 + 0.65 * absf(sin(tm / 70 + i * 2))
			var s := 15 * K
			var col: Array = C.bf[i]
			draw_set_transform(q, -0.25 if dx >= 0 else 0.25, Vector2(-1 if dx < 0 else 1, 1))
			_ell(Vector2(-s * 0.55 * fl, -s * 0.35), s * 0.62 * fl, s * 0.5, -0.5, Color(col[0]))
			_ell(Vector2(s * 0.55 * fl, -s * 0.35), s * 0.62 * fl, s * 0.5, 0.5, Color(col[0]))
			_ell(Vector2(-s * 0.4 * fl, s * 0.25), s * 0.42 * fl, s * 0.34, 0.4, Color(col[1]))
			_ell(Vector2(s * 0.4 * fl, s * 0.25), s * 0.42 * fl, s * 0.34, -0.4, Color(col[1]))
			draw_rect(Rect2(-s * 0.07, -s * 0.55, s * 0.14, s * 1.05), Color("#3A2A20"))
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
		# chimney smoke
		for p in smoke:
			var k: float = p.life / p.max
			var q := P(p.x - k * 34 + sin(p.life * 1.3) * 3, p.y + 6 - k * 85)
			var r: float = (p.r + 6 + k * 36) * K
			var a := minf(1.0, p.life * 4) * pow(1 - k, 1.3) * 0.85
			draw_texture_rect(smoke_tex, Rect2(q - Vector2(r, r), Vector2(r, r) * 2), false, Color(1, 1, 1, a))
		# petals
		for p in petals:
			var k: float = p.life / p.max
			var a := minf(1.0, p.life * 2) * minf(1.0, (1 - k) * 3)
			var q := P(p.x, p.y)
			draw_set_transform(q, p.rot, Vector2(1, absf(cos(p.life * 2 + p.ph)) * 0.6 + 0.4))
			var c: Color = p.col
			c.a = a * 0.95
			_ell(Vector2.ZERO, p.s * K, p.s * 0.6 * K, 0, c)
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
		# water glints (4-point sparkle)
		for p in glints:
			var k: float = p.life / p.max
			var a := sin(k * PI) * 0.9
			var q := P(p.x, p.y)
			var r: float = p.s * K * (0.6 + k * 0.6)
			var pts := PackedVector2Array([q + Vector2(-r * 1.4, 0), q + Vector2(-r * 0.15, -r * 0.15), q + Vector2(0, -r), q + Vector2(r * 0.15, -r * 0.15), q + Vector2(r * 1.4, 0), q + Vector2(r * 0.15, r * 0.15), q + Vector2(0, r), q + Vector2(-r * 0.15, r * 0.15)])
			draw_colored_polygon(pts, Color(1, 1, 1, a))
		# birds
		for b in birds:
			var q := P(b.x, b.y)
			var w: float = b.s * K
			var f := sin(tm / 160 + b.ph) * 0.7
			var c := Color("#2B3550")
			c.a = 0.75
			var pts := PackedVector2Array()
			for j in 9:
				var u := j / 8.0
				pts.append(AppFx.bez(q + Vector2(-w, -w * f * 0.6), q + Vector2(-w * 0.4, -w * 0.25), q + Vector2(-w * 0.4, -w * 0.25), q, u))
			for j in range(1, 9):
				var u := j / 8.0
				pts.append(AppFx.bez(q, q + Vector2(w * 0.4, -w * 0.25), q + Vector2(w * 0.4, -w * 0.25), q + Vector2(w, -w * f * 0.6), u))
			draw_polyline(pts, c, maxf(1.2, K * 1.4), true)

	func _ell(c: Vector2, rx: float, ry: float, rot: float, col: Color) -> void:
		var pts := PackedVector2Array()
		for i in 20:
			var a := i / 20.0 * TAU
			pts.append(c + Vector2(cos(a) * rx, sin(a) * ry).rotated(rot))
		draw_colored_polygon(pts, col)


# ---------------------------------------------------------------- fireworks over the title (fwBurst / fwRocket, additive)
class TitleFw extends Control:
	const GOLD := ["#FFE27A", "#FFFFFF", "#FFB020", "#FF4B6E"]
	var P: Array = []
	var NEW: Array = []

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		var m := CanvasItemMaterial.new()
		m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		material = m

	func burst(x: float, y: float, n: int, sp: float, cols: Array) -> void:
		for i in n:
			var a := i / float(n) * 6.283 + randf() * 0.2
			var v := sp * (0.5 + randf() * 0.55)
			NEW.append({"x": x, "y": y, "vx": cos(a) * v, "vy": sin(a) * v, "l": 1 + randf() * 0.8, "c": Color(cols[i % cols.size()]), "w": 1.6 + randf() * 1.6})

	func rocket(x0: float, x1: float, y1: float, dur: float, cb: Callable) -> void:
		NEW.append({"rk": true, "x": x0, "y": size.y + 10, "x0": x0, "x1": x1, "y1": y1, "t": 0.0, "dur": dur, "cb": cb})

	func _process(dt: float) -> void:
		if not NEW.is_empty():
			P.append_array(NEW)
			NEW.clear()
		if P.is_empty():
			return
		dt = minf(0.12, dt)
		var H := size.y
		var keep: Array = []
		var add: Array = []
		for p in P:
			if p.has("rk"):
				p.t += dt
				var k: float = minf(1.0, p.t / p.dur)
				p.x = p.x0 + (p.x1 - p.x0) * k
				p.y = H + 10 - (H + 10 - p.y1) * (1 - (1 - k) * (1 - k))
				add.append({"x": p.x, "y": p.y + 4, "vx": randf_range(-12, 12), "vy": randf_range(20, 70), "l": 0.35, "c": Color("#FFB020"), "w": 2.0})
				if k >= 1:
					p.cb.call(p.x, p.y)
				else:
					keep.append(p)
				continue
			p.l -= dt
			if p.l <= 0:
				continue
			p.vy += 80 * dt
			p.vx *= 0.985
			p.vy *= 0.985
			p.x += p.vx * dt
			p.y += p.vy * dt
			keep.append(p)
		P = keep + add + NEW
		NEW.clear()
		queue_redraw()

	func _draw() -> void:
		for p in P:
			if p.has("rk"):
				draw_circle(Vector2(p.x, p.y), 3, Color.WHITE)
				continue
			var c: Color = p.c
			c.a = minf(1.0, p.l)
			draw_circle(Vector2(p.x, p.y), p.w, c)


# 25 Nov: title fireworks made only of ready-made pictures (art/fx/fw_*.png, tools/pic/title_bursts.py), pooled:
# 4 bursts + 3 rocket trails, moved / scaled / faded with tweens. Same cost as before.
class SpriteFw extends Control:
	var strength := 1.0
	var pool: Array = []
	var trails: Array = []
	var T := {}
	func _ready() -> void:
		for k in ["gold", "red", "green", "willow", "blue"]:
			T[k] = load("res://art/fx/fw_%s.png" % k)
		for i in 4:
			var b := TextureRect.new()
			b.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			b.mouse_filter = Control.MOUSE_FILTER_IGNORE
			b.visible = false
			add_child(b)
			pool.append(b)
		for i in 3:
			var t := TextureRect.new()
			t.texture = load("res://art/fx/fw_trail.png")
			t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			t.size = Vector2(18, 96)
			t.mouse_filter = Control.MOUSE_FILTER_IGNORE
			t.visible = false
			add_child(t)
			trails.append(t)
	func rocket(x: float, y: float, dur: float, done: Callable) -> void:
		var t: TextureRect = null
		for q in trails:
			if not q.visible:
				t = q
				break
		if t == null:
			done.call(x, y)
			return
		t.visible = true
		t.modulate.a = strength
		var y0 := 844.0 * 0.5   # from behind the roof
		t.position = Vector2(x - 9, y0)
		var tw := t.create_tween()
		tw.tween_property(t, "position:y", y - 8.0, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_callback(func():
			t.visible = false
			done.call(x, y))
	func big(x: float, y: float, kind: String, sz: float) -> void:
		var b: TextureRect = null
		for q in pool:
			if not q.visible:
				b = q
				break
		if b == null:
			return
		b.texture = T[kind]
		b.visible = true
		b.size = Vector2(sz, sz)
		b.pivot_offset = b.size / 2.0
		b.position = Vector2(x, y) - b.size / 2.0
		b.scale = Vector2.ONE * 0.2
		b.modulate = Color(1, 1, 1, strength)
		var tw := b.create_tween()
		tw.tween_property(b, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(b, "position:y", b.position.y + (26.0 if kind == "willow" else 10.0), 1.3)
		tw.parallel().tween_property(b, "modulate:a", 0.0, 0.85).set_delay(0.45)
		tw.tween_callback(func(): b.visible = false)
