# First-open story, "Grandpa's Dream" (17 Nov). Plays once after the title, before level 1, over the live 3D street.
# 1 the dark street   2 he comes home   3 Grandpa's notebook   4 the promise (golden dream of the factory)
# Letterbox bars, a dusk grade and serif captions keep it cinematic. Tap = next shot, Skip = straight to level 1.
extends Control
class_name StoryScene

signal finished

var app
var street
var shot := 0
var sid := 0
var done := false
var dim: ColorRect
var grade: ColorRect
var vig: TextureRect
var top_bar: ColorRect
var bot_bar: ColorRect
var cap: Label
var skip: Label
var man: CMFace
var book: StoryBook
var motes: Motes
var flash: ColorRect
var music: AudioStreamPlayer
var amb: AudioStreamPlayer
var H := 844.0

const BAR := 74.0
const BOT := 134.0   # captions sit inside the bottom bar
const CREAM := Color("#F6E7C8")
const GOLD := Color("#E9C27A")
var card: Control

static func font_var(path: String, w: int) -> Font:
	var f := FontVariation.new()
	f.base_font = load(path)
	f.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): w}
	return f

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	size = Vector2(390, H)
	grade = _rect(Color(0.06, 0.05, 0.22, 0.0))
	vig = TextureRect.new()
	vig.texture = AppFx.grad_tex([0.0, 0.55, 1.0], [Color(0, 0, 0, 0), Color(0, 0, 0, 0.18), Color(0.02, 0.0, 0.05, 0.78)], true)
	vig.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vig.stretch_mode = TextureRect.STRETCH_SCALE
	vig.size = Vector2(390 * 1.5, H * 1.25)
	vig.position = Vector2(-390 * 0.25, -H * 0.125)
	vig.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vig.modulate.a = 0.0
	add_child(vig)
	motes = Motes.new()
	motes.size = Vector2(390, H)
	add_child(motes)
	man = CMFace.new()
	man.size = Vector2(196, 307)
	man.position = Vector2(97, H)
	add_child(man)
	dim = _rect(Color(0.03, 0.02, 0.06, 0.0))
	book = StoryBook.new()
	book.size = Vector2(340, 240)
	book.pivot_offset = book.size / 2
	book.base_x = 25
	book.position = Vector2(25, H / 2 - 150)
	book.visible = false
	add_child(book)
	card = _title_card()
	top_bar = _rect(Color.BLACK)
	top_bar.size = Vector2(390, BAR)
	top_bar.position.y = -BAR
	bot_bar = _rect(Color.BLACK)
	bot_bar.size = Vector2(390, BOT + 40)
	bot_bar.position.y = H
	cap = Label.new()
	var ls := LabelSettings.new()
	ls.font = font_var("res://art/fonts/CormorantItalic.ttf", 600)
	ls.font_size = 26
	ls.font_color = CREAM
	ls.line_spacing = -2
	ls.shadow_size = 6
	ls.shadow_color = Color(0, 0, 0, 0.55)
	cap.label_settings = ls
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cap.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cap.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cap.size = Vector2(350, 100)
	cap.position = Vector2(20, H - BOT + 22)
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cap.modulate.a = 0.0
	add_child(cap)
	skip = Label.new()
	var sl := LabelSettings.new()
	sl.font = WebLayout.font("Sora-700")
	sl.font_size = 13
	sl.font_color = Color(1, 1, 1, 0.62)
	skip.label_settings = sl
	skip.text = "Skip  ›"
	skip.position = Vector2(312, 26)
	skip.modulate.a = 0.0
	add_child(skip)
	flash = _rect(Color(1, 0.96, 0.86, 0.0))
	music = AudioStreamPlayer.new()
	add_child(music)
	amb = AudioStreamPlayer.new()
	add_child(amb)

func _rect(c: Color) -> ColorRect:
	var r := ColorRect.new()
	r.color = c
	r.size = Vector2(390, H)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	return r

func _title_card() -> Control:
	var c := Control.new()
	c.size = Vector2(390, 160)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.modulate.a = 0.0
	add_child(c)
	var a := Label.new()
	var la := LabelSettings.new()
	la.font = WebLayout.font("Sora-700")
	la.font_size = 13
	la.font_color = GOLD
	a.label_settings = la
	a.text = "A R E A   1"
	a.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	a.size = Vector2(390, 20)
	a.position.y = 18
	a.name = "a"
	c.add_child(a)
	for s in [-1.0, 1.0]:
		var ln := ColorRect.new()
		ln.color = GOLD
		ln.size = Vector2(70, 1.5)
		ln.position = Vector2(195 + (24 if s > 0 else -94), 27)
		ln.pivot_offset = Vector2(0 if s > 0 else 70, 0.75)
		ln.scale.x = 0.0
		ln.name = "l%d" % int(s)
		c.add_child(ln)
	var t := Label.new()
	var lt := LabelSettings.new()
	lt.font = font_var("res://art/fonts/CormorantItalic.ttf", 700)
	lt.font_size = 50
	lt.font_color = Color("#FFF1D6")
	lt.shadow_size = 10
	lt.shadow_color = Color(1, 0.6, 0.2, 0.35)
	t.label_settings = lt
	t.text = "Sivakasi Street"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.size = Vector2(390, 70)
	t.position.y = 40
	t.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	t.name = "t"
	c.add_child(t)
	var sh := TextureRect.new()
	sh.texture = AppFx.grad_tex([0.0, 0.5, 1.0], [Color(1, 1, 1, 0), Color(1, 1, 1, 0.9), Color(1, 1, 1, 0)], false, Vector2(0, 0.5), Vector2(1, 0.5))
	sh.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sh.size = Vector2(60, 120)
	sh.rotation = 0.35
	sh.position = Vector2(-120, -20)
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	sh.material = m
	sh.name = "sh"
	t.add_child(sh)
	var u := Label.new()
	var lu := LabelSettings.new()
	lu.font = font_var("res://art/fonts/CormorantItalic.ttf", 500)
	lu.font_size = 18
	lu.font_color = Color(0.96, 0.9, 0.8, 0.85)
	u.label_settings = lu
	u.text = "where every light begins"
	u.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	u.size = Vector2(390, 26)
	u.position.y = 112
	u.name = "u"
	c.add_child(u)
	return c

func _sfx(n: String, v := 1.0, pitch := 1.0, delay := 0.0) -> void:
	if app and app.sfx:
		app.sfx.play(n, v, pitch, delay)

func _stream(n: String) -> AudioStream:
	for ext in ["ogg", "wav"]:
		var p := "res://sfx/%s.%s" % [n, ext]
		if ResourceLoader.exists(p):
			return load(p)
	return null

func _tw() -> Tween:
	return create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# ------------------------------------------------------------------ start / shots
func play(height: float) -> void:
	H = height
	size = Vector2(390, H)
	for r in [grade, dim, flash]:
		r.size = Vector2(390, H)
	vig.size = Vector2(390 * 1.5, H * 1.25)
	vig.position = Vector2(-390 * 0.25, -H * 0.125)
	bot_bar.position.y = H
	cap.position.y = H - BOT + 22
	man.position.y = H
	book.position.y = H / 2 - 170
	card.position.y = H / 2 - 120
	if app and app.sfx:
		app.sfx.duck(0.0)
	var on: bool = app == null or app.sfx == null or app.sfx.mus_on
	music.stream = _stream("story_theme")
	music.volume_db = linear_to_db(0.9) if on else -80.0
	music.play()
	amb.stream = _stream("story_wind")
	amb.volume_db = linear_to_db(0.5) if on else -80.0
	amb.play()
	var t := _tw()
	t.parallel().tween_property(top_bar, "position:y", 0.0, 1.0)
	t.parallel().tween_property(bot_bar, "position:y", H - BOT, 1.0)
	t.parallel().tween_property(vig, "modulate:a", 1.0, 1.2)
	t.parallel().tween_property(grade, "color:a", 0.42, 1.2)
	t.parallel().tween_property(skip, "modulate:a", 1.0, 1.0).set_delay(1.0)
	_shot(1)

func _shot(n: int) -> void:
	shot = n
	sid += 1
	var id := sid
	match n:
		1: _dark_street(id)
		2: _home(id)
		3: _notebook(id)
		4: _promise(id)
		5: _title(id)
		_: _finish()

func _later(s: float, id: int, f: Callable) -> void:
	get_tree().create_timer(s).timeout.connect(func():
		if id == sid and not done:
			f.call())

func say(text: String, id: int, hold: float) -> void:
	var t := _tw()
	t.tween_property(cap, "modulate:a", 0.0, 0.25)
	t.tween_callback(func():
		cap.text = text
		cap.position.y = H - BOT + 30)
	t.tween_property(cap, "modulate:a", 1.0, 0.7)
	t.parallel().tween_property(cap, "position:y", H - BOT + 22, 0.9)
	_later(hold, id, func(): _tw().tween_property(cap, "modulate:a", 0.0, 0.5))

# 1. the dark street: the camera sinks slowly into the empty street at dusk
func _dark_street(id: int) -> void:
	if street:
		street.camP = Vector3(0, 24, 84)
		street.camL = Vector3(0, 0, 30)
		street.cam_to(Vector3(-1, 7.5, 54), Vector3(-2, 2.2, 26), 6.8)
	motes.rate = 6.0
	_later(0.9, id, func(): say("Sivakasi.  The town that lights up every Diwali.", id, 2.7))
	_later(3.9, id, func(): say("But Grandpa's old street had gone dark.", id, 2.6))
	_later(6.9, id, func(): _shot(2))

# 2. he comes home
func _home(id: int) -> void:
	if street:
		street.cam_to(Vector3(-1.4, 7.0, 51), Vector3(-2, 2.4, 22), 4.5)
	man.mood("worried", 99)
	man.base = "worried"
	var t := _tw()
	t.tween_property(man, "position:y", H - BOT - 250, 1.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_sfx("swoosh", 0.25, 0.8)
	_later(0.7, id, func(): say("“I'm home, Grandpa.”", id, 3.0))
	_later(4.4, id, func(): _shot(3))

# 3. Grandpa's notebook
func _notebook(id: int) -> void:
	var t := _tw()
	t.tween_property(man, "position:y", H, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(dim, "color:a", 0.62, 0.8)
	_tw().tween_property(cap, "modulate:a", 0.0, 0.3)
	book.reset()
	book.visible = true
	book.scale = Vector2.ONE * 0.35
	book.rotation = -0.5
	book.modulate.a = 0.0
	var b := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	b.tween_property(book, "scale", Vector2.ONE, 0.75).set_delay(0.3)
	b.parallel().tween_property(book, "rotation", 0.0, 0.75).set_delay(0.3)
	b.parallel().tween_property(book, "modulate:a", 1.0, 0.4).set_delay(0.3)
	_sfx("swoosh", 0.35, 0.7, 0.3)
	_later(1.2, id, func():
		_sfx("story_page", 1.0)
		_tw().tween_property(book, "open", 1.0, 0.75).set_trans(Tween.TRANS_CUBIC))
	_later(2.1, id, func(): book.write(3.4, app))
	_later(5.8, id, func():
		book.sign_off()
		_sfx("story_chime", 0.8))
	_later(6.3, id, func(): motes.burst(Vector2(280, H / 2 - 60), 26))
	_later(7.6, id, func(): _shot(4))

# 4. the promise: the notebook closes, the street brightens, the factory glows like a dream
func _promise(id: int) -> void:
	var t := _tw()
	t.tween_property(book, "open", 0.0, 0.45)
	t.tween_property(book, "scale", Vector2.ONE * 0.2, 0.35)
	t.parallel().tween_property(book, "modulate:a", 0.0, 0.35)
	t.tween_callback(func(): book.visible = false)
	_sfx("story_page", 0.6, 1.15)
	_tw().tween_property(dim, "color:a", 0.0, 1.0).set_delay(0.4)
	_tw().tween_property(grade, "color:a", 0.18, 3.0).set_delay(0.6)
	if street:
		street.cam_to(Vector3(0, 9.5, -24), Vector3(0, 4.6, -57), 2.6)
		_later(0.9, id, func():
			street.ghost(true)
			_sfx("story_dream", 0.9))
	motes.rate = 14.0
	man.base = "idle"
	man.mood("smile", 99)
	man.position.x = 2
	var m := _tw()
	m.tween_property(man, "position:y", H - BOT - 236, 1.0).set_delay(2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_later(2.6, id, func(): man.mood("cheer", 1.2))
	_later(2.3, id, func(): say("“I'll finish what you started…\none diya at a time.”", id, 3.6))
	_later(6.6, id, func(): _shot(5))

# 5. title card (from v2): "AREA 1", gold lines, "Sivakasi Street" with a light sweep
func _title(id: int) -> void:
	var t := _tw()
	t.tween_property(man, "position:y", H + 40, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(dim, "color:a", 0.5, 0.8)
	t.parallel().tween_property(cap, "modulate:a", 0.0, 0.3)
	var c := card
	c.modulate.a = 0.0
	c.get_node("t").position.y = 52
	var ct := _tw()
	ct.tween_property(c, "modulate:a", 1.0, 0.8).set_delay(0.3)
	ct.parallel().tween_property(c.get_node("t"), "position:y", 40.0, 1.0).set_delay(0.3)
	for n in ["l-1", "l1"]:
		_tw().tween_property(c.get_node(n), "scale:x", 1.0, 0.9).set_delay(0.5)
	var sh: Control = c.get_node("t/sh")
	sh.position.x = -120
	_tw().tween_property(sh, "position:x", 420.0, 1.1).set_delay(1.2)
	_sfx("story_chime", 0.6, 1.0, 0.5)
	_later(3.3, id, func(): _shot(6))

func _finish() -> void:
	if done:
		return
	done = true
	sid += 1
	_sfx("story_rise", 1.0)
	var t := _tw()
	t.tween_property(flash, "color:a", 1.0, 0.45)
	t.parallel().tween_property(music, "volume_db", -40.0, 0.9)
	t.parallel().tween_property(amb, "volume_db", -60.0, 0.6)
	t.tween_callback(func():
		if street:
			street.ghost(false)
		finished.emit())
	t.tween_property(flash, "color:a", 0.0, 0.5)
	t.tween_callback(queue_free)

func _gui_input(e: InputEvent) -> void:
	if done or not (e is InputEventMouseButton and e.pressed):
		return
	accept_event()
	var p: Vector2 = e.position
	if p.y < BAR + 20 and p.x > 270:
		_finish()
	elif shot < 6:
		_shot(shot + 1)

# ------------------------------------------------------------------ golden dust drifting up
class Motes extends Control:
	var P: Array = []
	var rate := 6.0
	var acc := 0.0
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		var m := CanvasItemMaterial.new()
		m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		material = m
	func burst(at: Vector2, n: int) -> void:
		for i in n:
			var a := randf() * TAU
			P.append({"p": at + Vector2(randf_range(-60, 60), randf_range(-30, 30)), "v": Vector2(cos(a) * 30, -40 - randf() * 70), "t": 0.0, "d": 1.4 + randf(), "r": 1.5 + randf() * 2.5})
	func _process(dt: float) -> void:
		acc += dt * rate
		while acc > 1.0:
			acc -= 1.0
			P.append({"p": Vector2(randf() * size.x, size.y * (0.55 + randf() * 0.4)), "v": Vector2(randf_range(-6, 6), -14 - randf() * 22), "t": 0.0, "d": 3.0 + randf() * 3.0, "r": 1.0 + randf() * 2.2})
		var keep: Array = []
		for o in P:
			o.t += dt
			o.p += o.v * dt
			o.p.x += sin(o.t * 2.0 + o.r) * 6.0 * dt
			if o.t < o.d:
				keep.append(o)
		P = keep
		queue_redraw()
	func _draw() -> void:
		for o in P:
			var k: float = o.t / o.d
			var a: float = sin(k * PI) * 0.8
			draw_circle(o.p, o.r * 3.0, Color(1, 0.75, 0.3, a * 0.18))
			draw_circle(o.p, o.r, Color(1, 0.9, 0.6, a))
