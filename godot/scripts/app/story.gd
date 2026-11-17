# First-open story, "Grandpa's Dream" v2 (17 Nov). Plays once after the title, before level 1, over the live 3D street.
# v1 is kept in previews/ (story-v1-*). Shots are cut on the music's bars (72 bpm, a bar = 3.33 s):
#   0.0  1 the street at night, the camera sinks in
#   6.7  2 he walks in, looks along the street, sighs
#  13.3  3 Grandpa's notebook: cover opens, pages fan, the pen writes his line
#  20.0  4 the promise: diyas light up along the path, the factory is traced in gold
#  26.7  5 title card "Area 1 · Sivakasi Street", then a warm flash into level 1
# Background blur stands in for depth of field; film grain and a dusk grade give one look. Tap = next shot, Skip = level 1.
extends Control
class_name StoryScene

signal finished

var app
var street
var shot := 0
var sid := 0
var done := false
var grade: ColorRect
var blur: ColorRect
var vig: TextureRect
var back_glow: TextureRect
var top_bar: ColorRect
var bot_bar: ColorRect
var cap: Label
var skip: Label
var man: CMFace
var book: StoryBook
var motes: Motes
var dim: ColorRect
var grain: ColorRect
var card: Control
var flash: ColorRect
var music: AudioStreamPlayer
var amb: AudioStreamPlayer
var H := 844.0
var walk := 0.0      # 0..1 how much he is walking (bob + sway)
var wt := 0.0

const BAR := 74.0
const BOT := 134.0
const CREAM := Color("#F6E7C8")
const GOLD := Color("#E9C27A")

static func font_var(path: String, w: int) -> Font:
	var f := FontVariation.new()
	f.base_font = load(path)
	f.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): w}
	return f

static func shader_rect(code: String) -> ColorRect:
	var r := ColorRect.new()
	var sh := Shader.new()
	sh.code = code
	var m := ShaderMaterial.new()
	m.shader = sh
	r.material = m
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	grade = _rect(Color(0.05, 0.05, 0.2, 0.0))
	# soft background blur (depth of field stand-in): 13 taps on the screen's mipmaps
	blur = shader_rect("""
shader_type canvas_item;
uniform sampler2D scr : hint_screen_texture, filter_linear_mipmap;
uniform float amt = 0.0;
void fragment() {
	vec2 px = SCREEN_PIXEL_SIZE * amt * 3.0;
	float lod = amt * 0.9;
	vec4 c = textureLod(scr, SCREEN_UV, lod) * 0.2;
	for (int i = 0; i < 12; i++) {
		float a = float(i) * 0.5236;
		c += textureLod(scr, SCREEN_UV + vec2(cos(a), sin(a)) * px * (i % 2 == 0 ? 1.0 : 1.8), lod) * (0.8 / 12.0);
	}
	COLOR = vec4(c.rgb, 1.0);
	COLOR.a = clamp(amt * 2.0, 0.0, 1.0);
}
""")
	add_child(blur)
	vig = TextureRect.new()
	vig.texture = AppFx.grad_tex([0.0, 0.55, 1.0], [Color(0, 0, 0, 0), Color(0, 0, 0, 0.2), Color(0.02, 0.0, 0.06, 0.82)], true)
	vig.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vig.stretch_mode = TextureRect.STRETCH_SCALE
	vig.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vig.modulate.a = 0.0
	add_child(vig)
	motes = Motes.new()
	add_child(motes)
	# warm light behind him so he sits in the scene
	back_glow = TextureRect.new()
	back_glow.texture = AppFx.grad_tex([0.0, 1.0], [Color(1, 0.72, 0.4, 0.38), Color(1, 0.6, 0.3, 0)], true)
	back_glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	back_glow.stretch_mode = TextureRect.STRETCH_SCALE
	back_glow.size = Vector2(360, 360)
	back_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back_glow.modulate.a = 0.0
	add_child(back_glow)
	man = CMFace.new()
	man.size = Vector2(196, 307)
	man.position = Vector2(-260, H)
	man.breathe = 1.0
	add_child(man)
	dim = _rect(Color(0.02, 0.01, 0.05, 0.0))
	book = StoryBook.new()
	book.size = Vector2(340, 240)
	book.pivot_offset = book.size / 2
	book.base_x = 25
	book.visible = false
	add_child(book)
	card = _title_card()
	top_bar = _rect(Color.BLACK)
	bot_bar = _rect(Color.BLACK)
	cap = Label.new()
	var ls := LabelSettings.new()
	ls.font = font_var("res://art/fonts/CormorantItalic.ttf", 600)
	ls.font_size = 26
	ls.font_color = CREAM
	ls.line_spacing = -2
	cap.label_settings = ls
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cap.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cap.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cap.size = Vector2(350, 100)
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cap.modulate.a = 0.0
	add_child(cap)
	skip = Label.new()
	var sl := LabelSettings.new()
	sl.font = WebLayout.font("Sora-700")
	sl.font_size = 13
	sl.font_color = Color(1, 1, 1, 0.6)
	skip.label_settings = sl
	skip.text = "Skip  ›"
	skip.position = Vector2(312, 28)
	skip.modulate.a = 0.0
	add_child(skip)
	grain = shader_rect("""
shader_type canvas_item;
float h(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void fragment() {
	float n = h(floor(FRAGCOORD.xy / 1.5) + floor(TIME * 24.0) * 1.37);
	COLOR = vec4(vec3(n), 0.045);
}
""")
	add_child(grain)
	flash = _rect(Color(1, 0.95, 0.84, 0.0))
	music = AudioStreamPlayer.new()
	add_child(music)
	amb = AudioStreamPlayer.new()
	add_child(amb)

func _rect(c: Color) -> ColorRect:
	var r := ColorRect.new()
	r.color = c
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

func _blur(to: float, d: float) -> void:
	var m: ShaderMaterial = blur.material
	create_tween().tween_method(func(v: float): m.set_shader_parameter("amt", v), float(m.get_shader_parameter("amt")), to, d).set_trans(Tween.TRANS_SINE)

# ------------------------------------------------------------------ start
func play(height: float) -> void:
	H = height
	size = Vector2(390, H)
	for r in [grade, blur, dim, grain, flash]:
		r.size = Vector2(390, H)
	(blur.material as ShaderMaterial).set_shader_parameter("amt", 0.0)
	vig.size = Vector2(390 * 1.5, H * 1.25)
	vig.position = Vector2(-390 * 0.25, -H * 0.125)
	motes.size = Vector2(390, H)
	top_bar.size = Vector2(390, BAR)
	top_bar.position.y = -BAR
	bot_bar.size = Vector2(390, BOT + 40)
	bot_bar.position.y = H
	cap.position = Vector2(20, H - BOT + 22)
	man.position.y = H - BOT - 236
	book.position.y = H / 2 - 170
	card.position.y = H / 2 - 120
	if street:
		street.night(1.0)
	if app and app.sfx:
		app.sfx.duck(0.0)
	var on: bool = app == null or app.sfx == null or app.sfx.mus_on
	music.stream = _stream("story_theme")
	music.volume_db = linear_to_db(0.9) if on else -80.0
	music.play()
	amb.stream = _stream("story_wind")
	amb.volume_db = linear_to_db(0.55) if on else -80.0
	amb.play()
	var t := _tw()
	t.parallel().tween_property(top_bar, "position:y", 0.0, 1.2)
	t.parallel().tween_property(bot_bar, "position:y", H - BOT, 1.2)
	t.parallel().tween_property(vig, "modulate:a", 1.0, 1.4)
	t.parallel().tween_property(grade, "color:a", 0.3, 1.4)
	t.parallel().tween_property(skip, "modulate:a", 1.0, 1.0).set_delay(1.2)
	_shot(1)

func _process(dt: float) -> void:
	wt += dt
	# walking: a step every 0.55 s, head and shoulders bob, the body sways a little
	var ph := wt * TAU / 0.55
	man.bob = absf(sin(ph)) * 7.0 * walk
	man.sway = sin(ph) * 0.018 * walk
	back_glow.position = man.position + Vector2(man.size.x / 2 - 180, man.size.y * 0.42 - 180)
	back_glow.modulate.a = man.modulate.a * (0.0 if man.position.y > H - BOT - 60 else 1.0)

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

# 1. night: the camera sinks slowly into the empty, dark street
func _dark_street(id: int) -> void:
	if street:
		street.camP = Vector3(0, 26, 88)
		street.camL = Vector3(0, 0, 30)
		street.cam_to(Vector3(-1, 7.2, 55), Vector3(-2, 2.2, 26), 6.6)
	motes.rate = 5.0
	_later(0.8, id, func(): say("Sivakasi.  The town that lights up every Diwali.", id, 2.7))
	_later(3.8, id, func(): say("But Grandpa's old street had gone dark.", id, 2.6))
	_later(6.67, id, func(): _shot(2))

# 2. he walks in from the left while the camera trucks with him, stops, looks along the street, sighs
func _home(id: int) -> void:
	if street:
		street.cam_to(Vector3(1.2, 6.8, 50), Vector3(-0.5, 2.3, 22), 5.5)
	_blur(0.9, 1.6)
	man.mood("worried", 99)
	man.base = "worried"
	man.position.x = -230
	man.turn = 0.6
	walk = 1.0
	var t := _tw()
	t.tween_property(man, "position:x", 97.0, 2.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(self, "walk", 0.0, 0.8).set_delay(1.9)
	for i in 4:
		_sfx("story_step", 0.5, randf_range(0.92, 1.05), 0.1 + i * 0.55)
	t.tween_property(man, "turn", -0.85, 0.7)
	t.tween_interval(0.5)
	t.tween_property(man, "turn", 0.8, 0.9)
	t.tween_interval(0.4)
	t.tween_property(man, "turn", 0.0, 0.6)
	t.tween_property(man, "shrug", 1.0, 0.5)
	t.tween_property(man, "shrug", 0.0, 0.9)
	_later(3.0, id, func(): say("“I'm home, Grandpa.”", id, 3.2))
	_later(5.2, id, func(): _sfx("story_sigh", 0.5))
	_later(6.67, id, func(): _shot(3))

# 3. Grandpa's notebook
func _notebook(id: int) -> void:
	walk = 0.0
	var t := _tw()
	t.tween_property(man, "position:y", H + 40, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(dim, "color:a", 0.5, 0.8)
	_blur(1.6, 1.0)
	_tw().tween_property(cap, "modulate:a", 0.0, 0.3)
	book.reset()
	book.visible = true
	book.scale = Vector2.ONE * 0.5
	book.rotation = -0.18
	book.modulate.a = 0.0
	book.position.y = H / 2 - 120
	var b := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	b.tween_property(book, "scale", Vector2.ONE, 0.8).set_delay(0.25)
	b.parallel().tween_property(book, "rotation", 0.0, 0.8).set_delay(0.25)
	b.parallel().tween_property(book, "modulate:a", 1.0, 0.4).set_delay(0.25)
	b.parallel().tween_property(book, "position:y", H / 2 - 170, 0.8).set_delay(0.25)
	_sfx("swoosh", 0.3, 0.7, 0.25)
	_later(1.0, id, func():
		_sfx("story_page", 1.0)
		_tw().tween_property(book, "open", 1.0, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT))
	_later(1.8, id, func():
		_sfx("story_page", 0.55, 1.2)
		book.fan_pages(0.7))
	_later(2.5, id, func(): book.shine_photo(1.0))
	_later(2.7, id, func(): book.write(3.0, app))
	_later(5.8, id, func():
		book.sign_off()
		_sfx("story_chime", 0.8))
	_later(6.1, id, func(): motes.burst(Vector2(290, H / 2 - 70), 26))
	_later(6.67, id, func(): _shot(4))

# 4. the promise: the notebook closes, diyas light up along the path, the factory is traced in gold
func _promise(id: int) -> void:
	var t := _tw()
	t.tween_property(book, "open", 0.0, 0.45)
	t.tween_property(book, "scale", Vector2.ONE * 0.3, 0.35)
	t.parallel().tween_property(book, "modulate:a", 0.0, 0.35)
	t.tween_callback(func(): book.visible = false)
	_sfx("story_page", 0.6, 1.15)
	_tw().tween_property(dim, "color:a", 0.0, 0.9).set_delay(0.4)
	_blur(0.0, 1.0)
	if street:
		street.cam_to(Vector3(0, 9.0, -20), Vector3(0, 4.4, -57), 3.0)
		var k := [0]
		street.story_diyas(2.6, func():
			_sfx("story_ting", 0.35, 1.0 + k[0] * 0.04)
			k[0] += 1)
		_later(2.5, id, func():
			street.ghost(true)
			_sfx("story_dream", 0.9))
	_tw().tween_property(grade, "color:a", 0.12, 3.0).set_delay(0.8)
	motes.rate = 12.0
	man.base = "idle"
	man.mood("smile", 99)
	man.turn = -0.3
	man.position = Vector2(-10, H)
	var m := _tw()
	m.tween_property(man, "position:y", H - BOT - 236, 1.0).set_delay(3.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	m.tween_property(man, "turn", 0.0, 0.6)
	_later(4.5, id, func(): man.mood("cheer", 1.4))
	_later(3.4, id, func(): say("“I'll finish what you started…\none diya at a time.”", id, 3.0))
	_later(6.67, id, func(): _shot(5))

# 5. title card
func _title(id: int) -> void:
	var t := _tw()
	t.tween_property(man, "position:y", H + 40, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(dim, "color:a", 0.45, 0.8)
	t.parallel().tween_property(cap, "modulate:a", 0.0, 0.3)
	_blur(1.1, 1.0)
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
	_later(3.3, id, func(): _shot(6))

func _finish() -> void:
	if done:
		return
	done = true
	sid += 1
	_sfx("story_rise", 1.0)
	var t := _tw()
	t.tween_property(flash, "color:a", 1.0, 0.5)
	t.parallel().tween_property(music, "volume_db", -40.0, 1.0)
	t.parallel().tween_property(amb, "volume_db", -60.0, 0.6)
	t.tween_callback(func():
		if street:
			street.ghost(false)
			street.story_clear()
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
			P.append({"p": Vector2(randf() * size.x, size.y * (0.5 + randf() * 0.4)), "v": Vector2(randf_range(-6, 6), -14 - randf() * 22), "t": 0.0, "d": 3.0 + randf() * 3.0, "r": 1.0 + randf() * 2.0})
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
			draw_circle(o.p, o.r * 3.0, Color(1, 0.75, 0.3, a * 0.16))
			draw_circle(o.p, o.r, Color(1, 0.9, 0.6, a))
