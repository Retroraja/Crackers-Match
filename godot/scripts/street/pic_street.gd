# Picture-based areas (20 Nov): phones draw no 3D at all. Each area is cut into close-up pictures rendered on the
# computer from our 3D street at full quality with shadows (tools/pic). Every build is a cut-out sticker taken from
# the same camera; it pops in with a bounce, dust and sparkles. After a picture's last build the view slides to the
# next picture; a swipe shows the earlier ones. Same API as Street, so the home screen and app code are unchanged.
extends Street
class_name PicStreet

var view: Control          # full screen, behind the menus (cm_app puts it in the street layer)
var D: Dictionary          # res://street/pics/aN.json
var pics: Array = []       # one Control per picture: base + stickers
var cur := 0               # picture on screen
var _fx: PicFx
var _slide_t: Tween
var _drag := {}

func _ready() -> void:
	cam = Camera3D.new()
	add_child(cam)
	var L0: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://street/layout.json"))
	TASKS = L0.tasks
	view = Control.new()
	view.name = "pic_street"
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view.set_anchors_preset(Control.PRESET_FULL_RECT)
	view.clip_contents = true
	view.resized.connect(_layout)
	_fx = PicFx.new()
	_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	_load(1)

func _load(a: int) -> void:
	for p in pics:
		p.queue_free()
	pics.clear()
	D = JSON.parse_string(FileAccess.get_file_as_string("res://street/pics/a%d.json" % a))
	for P in D.pics:
		var c := Control.new()
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.size = Vector2(D.w, D.h)
		var b := TextureRect.new()
		b.texture = load(P.base)
		b.size = c.size
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.add_child(b)
		var sts := {}     # build -> its pieces (one per object: each lamp, tree, stall...)
		for S in P.st:
			var parts: Array = []
			for Q in S.parts:
				var t := TextureRect.new()
				t.texture = load(Q.img)
				t.position = Vector2(Q.r[0], Q.r[1])
				t.size = Vector2(Q.r[2], Q.r[3])
				t.pivot_offset = Vector2(Q.piv[0], Q.piv[1]) - t.position
				t.mouse_filter = Control.MOUSE_FILTER_IGNORE
				t.visible = false
				t.set_meta("big", bool(Q.big))
				c.add_child(t)
				parts.append(t)
			sts[int(S.i)] = parts
		c.set_meta("st", sts)
		c.visible = false
		view.add_child(c)
		pics.append(c)
	if _fx.get_parent():
		view.move_child(_fx, -1)
	else:
		view.add_child(_fx)
	cur = 0
	_show_built()
	_layout()

# which picture a build belongs to
func pic_of(i: int) -> int:
	i = clampi(i, 0, TASKS.size() - 1)
	for p in D.pics.size():
		if D.pics[p].builds.has(float(i)) or D.pics[p].builds.has(i):
			return p
	return D.pics.size() - 1

func home_pic() -> int:
	return pic_of(mini(step, TASKS.size() - 1))

func _show_built() -> void:
	for c in pics:
		var sts: Dictionary = c.get_meta("st")
		for i in sts:
			for t in sts[i]:
				t.visible = i < step
				t.scale = Vector2.ONE
				t.modulate.a = 1.0

func _k() -> float:
	if view.size.y <= 0.0:
		return 1.0
	return maxf(view.size.x / D.w, view.size.y / D.h)

# picture i at offset o (in screens) from the centre, with zoom z
func _place(i: int, o: float, z := 1.0) -> void:
	var c: Control = pics[i]
	var k := _k() * z
	c.scale = Vector2(k, k)
	c.position = Vector2((view.size.x - D.w * k) / 2.0 + o * view.size.x, (view.size.y - D.h * k) / 2.0)

func _layout() -> void:
	if pics.is_empty():
		return
	for i in pics.size():
		pics[i].visible = i == cur
	_place(cur, 0.0)

# screen point (view coordinates) of a point in picture i
func pic_to_screen(i: int, p: Vector2) -> Vector2:
	var c: Control = pics[i]
	return c.position + p * c.scale.x + view.global_position

func site_of(i: int) -> Vector3:
	var p := pic_of(i)
	for S in D.pics[p].st:
		if int(S.i) == i:
			var q := pic_to_screen(p, Vector2(S.site[0], S.site[1]))
			return Vector3(q.x, q.y, 0.0)
	var c := view.get_global_rect().get_center()
	return Vector3(c.x, c.y, 0.0)

# --------------------------------------------------------------- Street API (2D)
func screen_pos(p3: Vector3) -> Vector2:
	return Vector2(p3.x, p3.y)

# Area 3 (23 Nov): GHILLI's order room behind the shop (pictures from scripts/street/backroom.gd, a3.json).
# Costs add up to the 25 diyas that levels 61-80 give (16 normal + 3 Hard x2 + Super Hard x3).
const A3_COST := [2, 2, 2, 3, 3, 3, 3, 3, 4]
const A3_KIND := ["stall", "house", "house", "stall", "stall", "house", "lamp", "farm", "stall"]

func set_area(a: int) -> void:
	if a == area or a < 2 or a > 3:
		return
	area = a
	if a == 2:
		TASKS = ShopArea.TASKS.duplicate(true)
	else:
		TASKS = Backroom.TASKS.duplicate(true)
		for i in TASKS.size():
			TASKS[i].c = A3_COST[i]
			TASKS[i]["kind"] = A3_KIND[i]
	SHOW = false
	won = false
	busy = false
	step = 0
	_load(a)

func kind_of(T: Dictionary) -> String:
	if T.has("kind"):
		return T.kind
	return super.kind_of(T)

func skip_to(n: int) -> void:
	step = mini(n, TASKS.size())
	_show_built()
	cur = home_pic()
	_layout()

func cam_home(instant := false) -> void:
	var p := pics.size() - 1 if step >= TASKS.size() else home_pic()
	if p == cur or instant:
		cur = p
		_layout()
		return
	slide_to(p, Callable())

func cam_to(_p: Vector3, _l: Vector3, _d: float) -> void:
	pass

func glide_to(_v: Dictionary) -> float:
	return 0.0

func hold_shot(_v: Dictionary, _d: float) -> void:
	pass

func wide() -> Dictionary:
	return {"p": Vector3.ZERO, "look": Vector3.ZERO}

func night(k: float) -> void:
	view.modulate = Color.WHITE.lerp(Color(0.42, 0.42, 0.66), k)

func story_clear() -> void:
	night(0.0)
	if _dusk_r:
		_dusk_r.queue_free()
		_dusk_r = null
	_fx.clear_glow()

# Area 1 end: the factory picture fades to its dusk render (rendered with the street's night light)
var _dusk_r: TextureRect
func dusk(d: float) -> void:
	if not ResourceLoader.exists("res://street/pics/a%d_dusk.webp" % area):
		var tw := view.create_tween()
		tw.tween_method(night, 0.0, 0.7, d)
		return
	var c: Control = pics[cur]
	_dusk_r = TextureRect.new()
	_dusk_r.texture = load("res://street/pics/a%d_dusk.webp" % area)
	_dusk_r.size = c.size
	_dusk_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dusk_r.modulate.a = 0.0
	c.add_child(_dusk_r)
	view.create_tween().set_trans(Tween.TRANS_SINE).tween_property(_dusk_r, "modulate:a", 1.0, d)

# a warm glow on window i (0-7) of the last build (two rows of four over its upper part)
func window_glow(i: int) -> void:
	var p := pics.size() - 1
	var S: Dictionary = {}
	for q in D.pics[p].st:
		if int(q.i) == TASKS.size() - 1:
			S = q
	if S.is_empty():
		return
	var r := Rect2()
	for Q in S.parts:
		if Q.r[2] * Q.r[3] > r.size.x * r.size.y:
			r = Rect2(Q.r[0], Q.r[1], Q.r[2], Q.r[3])
	var x := r.position.x + r.size.x * lerpf(0.3, 0.7, (i % 4) / 3.0)
	var y := r.position.y + r.size.y * (0.35 + 0.22 * (i / 4))
	_fx.glow(pic_to_screen(p, Vector2(x, y)) - view.global_position, 26.0 * _k() * D.w / 390.0 * 0.4)

func ghost(_on: bool, _scan := false) -> void:
	pass

func firework() -> void:
	_fx.firework(Vector2(view.size.x * randf_range(0.15, 0.85), view.size.y * randf_range(0.12, 0.38)))

func sparkle(c: Vector3, n: int, _y := 3.0) -> void:
	_fx.sparkle(Vector2(c.x, c.y) - view.global_position, n)

func ring(c: Vector3, col := Color("#fff2c0"), _y := 0.12) -> void:
	_fx.ring(Vector2(c.x, c.y) - view.global_position, col)

func dust(c: Vector3, n: int, _sp: float) -> void:
	_fx.dust(Vector2(c.x, c.y) - view.global_position, n)

# slide (2D, small zoom) to picture p
func slide_to(p: int, done: Callable) -> void:
	if p == cur:
		if done.is_valid():
			done.call()
		return
	var from := cur
	var dir := 1.0 if p > from else -1.0
	pics[p].visible = true
	cur = p
	if _slide_t:
		_slide_t.kill()
	_slide_t = view.create_tween()
	_slide_t.tween_method(func(k: float):
		var e := k * k * (3.0 - 2.0 * k)
		var z := 1.0 - 0.08 * sin(k * PI)
		_place(from, -dir * e, z)
		_place(p, dir * (1.0 - e), z), 0.0, 1.0, 1.1)
	_slide_t.tween_callback(func():
		pics[from].visible = false
		_layout()
		if done.is_valid():
			done.call())
	sfx.emit("open")

# the home screen passes drags on the empty street here: swipe to the earlier pictures and back
func drag_input(e: InputEvent) -> void:
	if busy or pics.size() < 2:
		return
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.pressed:
			_drag = {"x0": e.position.x, "dx": 0.0}
		elif not _drag.is_empty():
			var dx: float = _drag.dx
			_drag = {}
			var top := home_pic() if step < TASKS.size() else pics.size() - 1
			var to := cur
			if dx > view.size.x * 0.18 and cur > 0:
				to = cur - 1
			elif dx < -view.size.x * 0.18 and cur < top:
				to = cur + 1
			if to != cur:
				_snap_from_drag(to, dx)
			else:
				_snap_back(dx)
	elif e is InputEventMouseMotion and not _drag.is_empty():
		_drag.dx = e.position.x - float(_drag.x0)
		var top := home_pic() if step < TASKS.size() else pics.size() - 1
		var dx: float = _drag.dx
		if (dx > 0 and cur == 0) or (dx < 0 and cur >= top):
			dx *= 0.25
		var o := dx / view.size.x
		_place(cur, o)
		var nb := cur - 1 if dx > 0 else cur + 1
		for i in pics.size():
			pics[i].visible = i == cur or (i == nb and i >= 0 and i <= top)
		if nb >= 0 and nb <= top:
			_place(nb, o + (-1.0 if dx > 0 else 1.0))

func _snap_from_drag(to: int, dx: float) -> void:
	var from := cur
	var dir := 1.0 if to > from else -1.0
	var o0 := dx / view.size.x
	cur = to
	pics[to].visible = true
	var t := view.create_tween()
	t.tween_method(func(k: float):
		var e := 1.0 - pow(1.0 - k, 3.0)
		var o := lerpf(o0, -dir, e)
		_place(from, o)
		_place(to, o + dir), 0.0, 1.0, 0.35)
	t.tween_callback(_layout)
	sfx.emit("open")

func _snap_back(dx: float) -> void:
	var o0 := dx / view.size.x
	var t := view.create_tween()
	t.tween_method(func(k: float):
		_place(cur, o0 * (1.0 - k)), 0.0, 1.0, 0.25)
	t.tween_callback(_layout)

# --------------------------------------------------------------- builds
func run_next() -> void:
	var T: Dictionary = TASKS[step]
	diyas -= int(T.c)
	changed.emit()
	var p := pic_of(step)
	var go := func():
		var i := step
		var tot := 2.2
		SPEED = maxf(SPEED, 1.6 if FAST else 1.0)
		var cont := func():
			_pop(i)
			sfx.emit("bk:%s:%.2f" % [kind_of(T), tot / SPEED])
			after(tot, _task_finished)
		if spend_cb.is_valid():
			spend_cb.call(site_of(i), cont)
		else:
			cont.call()
	if p != cur:
		slide_to(p, go)
	else:
		go.call()

# the sticker pops in: every object bounces up from its own base (front ones first), dust at the bottom, sparkles.
# Very big pieces (the stone path) fade in and settle instead.
func _pop(i: int) -> void:
	var p := pic_of(i)
	var sts: Dictionary = pics[p].get_meta("st")
	# the same build on other pictures (seen when swiping back) just appears
	for c in pics:
		if c == pics[p]:
			continue
		for t in c.get_meta("st").get(i, []):
			t.visible = true
	var parts: Array = sts.get(i, [])
	var n := parts.size()
	for j in n:
		var t: TextureRect = parts[j]
		var d := 0.0 if n < 2 else j * minf(0.12, 0.9 / n)
		t.visible = false
		after(d, _pop_part.bind(t, p, n))
	var s := site_of(i)
	after(0.45, func():
		sparkle(s, 34)
		ring(s, Color("#ffe27a")))
	after(0.95, func(): sparkle(s, 18))

func _pop_part(t: TextureRect, p: int, n: int) -> void:
	t.visible = true
	t.modulate.a = 0.0
	if t.get_meta("big", false):
		var y0 := t.position.y
		t.scale = Vector2.ONE
		tween(0.7, func(k: float):
			t.modulate.a = k
			t.position.y = y0 + 14.0 * (1.0 - sm(k)))
	else:
		t.scale = Vector2(0.3, 0.05)
		tween(0.16, func(k: float): t.modulate.a = k)
		tween(0.7, func(k: float):
			var b := back(k)
			t.scale = Vector2(lerpf(0.3, 1.0, b), lerpf(0.05, 1.0, b)))
	var base := pic_to_screen(p, t.position + t.pivot_offset)
	after(0.08, func(): dust(Vector3(base.x, base.y, 0), 6 if n > 3 else 12, 2.0))

func _task_finished() -> void:
	step += 1
	changed.emit()
	sfx.emit("area" if step >= TASKS.size() else "done")
	if auto and step < TASKS.size() and diyas >= int(TASKS[step].c):
		FN += 1
		task_done.emit(false)   # busy: the home screen saves and updates "Building n/N"
		run_next()
		return
	FAST = false
	SPEED = 1.0
	if step >= TASKS.size():
		busy = false
		changed.emit()
		win()
		task_done.emit(true)
		return
	# the picture is finished: slide on to the next one
	var p := pic_of(step)
	if p != cur:
		slide_to(p, func():
			busy = false
			changed.emit()
			task_done.emit(false))
		return
	busy = false
	changed.emit()
	task_done.emit(false)

func build_all() -> void:
	var n := can_do()
	if n < 1:
		return
	FAST = true
	FN = 1
	FT = n
	do_task(true)

func win() -> void:
	won = true
	SHOW = true
	sfx.emit("area")
	area_won.emit()

func speed_up() -> void:
	if busy:
		SPEED = minf(6.0, maxf(SPEED * 1.8, 2.0))

func _process(delta: float) -> void:
	var dt := minf(0.1, delta) * SPEED
	_tick(dt)
	if SHOW and view.is_visible_in_tree():
		fwT -= dt
		if fwT <= 0:
			firework()
			fwT = rnd(0.5, 0.9)

# --------------------------------------------------------------- 2D effects: sparkles, dust puffs, rings, fireworks
class PicFx extends Control:
	var P: Array = []
	func sparkle(c: Vector2, n: int) -> void:
		for i in n:
			var a := randf() * TAU
			var v := randf_range(40.0, 170.0)
			P.append({"k": 0, "p": c + Vector2(randf_range(-10, 10), randf_range(-10, 10)), "v": Vector2(cos(a), sin(a)) * v + Vector2(0, -40),
				"t": 0.0, "d": randf_range(0.6, 1.1), "s": randf_range(2.0, 4.5), "c": [Color("#fff6c8"), Color("#ffd24a"), Color.WHITE][i % 3]})
		set_process(true)
	func dust(c: Vector2, n: int) -> void:
		for i in n:
			var a := randf_range(-PI, 0.0)
			P.append({"k": 1, "p": c + Vector2(randf_range(-30, 30), randf_range(-4, 4)), "v": Vector2(cos(a) * randf_range(30, 90), sin(a) * randf_range(10, 40)),
				"t": 0.0, "d": randf_range(0.7, 1.2), "s": randf_range(8.0, 16.0), "c": Color("#e9dcc6")})
		set_process(true)
	var G: Array = []
	func glow(c: Vector2, r: float) -> void:
		G.append({"p": c, "r": r, "t": 0.0})
		set_process(true)
	func clear_glow() -> void:
		G.clear()
		queue_redraw()
	func ring(c: Vector2, col: Color) -> void:
		P.append({"k": 2, "p": c, "v": Vector2.ZERO, "t": 0.0, "d": 0.6, "s": 70.0, "c": col})
		set_process(true)
	func firework(c: Vector2) -> void:
		var cols := [Color("#FFD24A"), Color("#FF4B6E"), Color("#7FD1FF"), Color("#B6FF7A"), Color.WHITE]
		var col: Color = cols[randi() % cols.size()]
		for i in 36:
			var a := TAU * i / 36.0
			var v := randf_range(90.0, 130.0)
			P.append({"k": 3, "p": c, "v": Vector2(cos(a), sin(a)) * v, "t": 0.0, "d": randf_range(1.0, 1.4), "s": 2.6, "c": col})
		set_process(true)
	func _process(dt: float) -> void:
		var keep: Array = []
		for q in P:
			q.t += dt
			if q.t >= q.d:
				continue
			q.p += q.v * dt
			if q.k == 3:
				q.v *= 0.97
				q.v.y += 40.0 * dt
			elif q.k == 1:
				q.v *= 0.94
			else:
				q.v.y += 60.0 * dt
			keep.append(q)
		P = keep
		for g in G:
			g.t += dt
		queue_redraw()
		if P.is_empty() and G.is_empty():
			set_process(false)
	func _draw() -> void:
		for g in G:
			var a: float = minf(1.0, g.t / 0.4) * (0.85 + 0.15 * sin(g.t * 5.0))
			draw_circle(g.p, g.r * 2.2, Color(1, 0.7, 0.3, 0.18 * a))
			draw_circle(g.p, g.r * 1.2, Color(1, 0.8, 0.45, 0.35 * a))
			draw_circle(g.p, g.r * 0.5, Color(1, 0.95, 0.75, 0.8 * a))
		for q in P:
			var k: float = q.t / q.d
			var c: Color = q.c
			match int(q.k):
				0:
					c.a = 1.0 - k
					var s: float = q.s * (1.0 - k * 0.5)
					draw_rect(Rect2(q.p - Vector2(s, s * 0.25), Vector2(s * 2, s * 0.5)), c)
					draw_rect(Rect2(q.p - Vector2(s * 0.25, s), Vector2(s * 0.5, s * 2)), c)
				1:
					c.a = 0.55 * (1.0 - k)
					draw_circle(q.p, q.s * (0.6 + k), c)
				2:
					c.a = 1.0 - k
					draw_arc(q.p, q.s * (0.3 + k), 0, TAU, 40, c, 4.0 * (1.0 - k) + 1.0, true)
				3:
					c.a = 1.0 - k * k
					draw_circle(q.p, q.s * (1.0 - k * 0.6), c)
