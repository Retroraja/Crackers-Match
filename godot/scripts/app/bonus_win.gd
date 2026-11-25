# 25 Nov: Coin Blast win in the win-screen style: one card with a gold border, red "COIN BLAST!" ribbon, gold rays
# turning (one picture), a coin pile, the coins counting up, coins raining (a few pooled coin pictures), and
# Next + AD Reward x2 (watch a video, the coins are doubled). Only ready-made pictures move.
extends Control
class_name BonusWin

var app
var lay := WebLayout.new()
var rays: TextureRect
var num: Label
var x2: Control
var rain: Array = []
var got := 0
var _rt: Tween

func mk(r: Array, t = null, name := "") -> Control:
	var d := {"i": 0, "id": name, "tag": "div", "r": r, "op": 1}
	if t != null:
		d.txt = t
	var c := lay.make(d, Vector2.ZERO)
	add_child(c)
	return c

func build(a) -> void:
	app = a
	size = Vector2(390, 844)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0.08, 0.02, 0.14, 0.7)
	dim.position = Vector2(0, -400)
	dim.size = Vector2(390, 1644)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var card := Panel.new()
	var cs := StyleBoxFlat.new()
	cs.bg_color = Color(0.16, 0.04, 0.24, 0.85)
	cs.border_color = Color("#FFD23F")
	cs.set_border_width_all(4)
	cs.set_corner_radius_all(30)
	cs.shadow_color = Color(1.0, 0.78, 0.2, 0.35)
	cs.shadow_size = 10
	card.add_theme_stylebox_override("panel", cs)
	card.position = Vector2(20, 150)
	card.size = Vector2(350, 520)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.clip_contents = true
	add_child(card)
	rays = TextureRect.new()
	rays.texture = load("res://art/win/rays.png")
	rays.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rays.size = Vector2(560, 560)
	rays.pivot_offset = rays.size / 2.0
	rays.position = Vector2(175 - 280, 210 - 280)
	rays.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(rays)
	# coins raining inside the card (pooled, 10 pictures)
	for i in 10:
		var c := TextureRect.new()
		c.texture = WebLayout.tex("art/ui-coin.webp")
		c.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		c.size = Vector2(26, 26)
		c.pivot_offset = Vector2(13, 13)
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.visible = false
		card.add_child(c)
		rain.append(c)
	var pile := TextureRect.new()
	pile.texture = WebLayout.tex("art/ic-coinpile.png")
	pile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pile.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pile.size = Vector2(200, 170)
	pile.position = Vector2(75, 120)
	pile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(pile)
	# red ribbon
	var rib := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#C8102E")
	sb.border_color = Color("#FFD36A")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(4)
	rib.add_theme_stylebox_override("panel", sb)
	rib.size = Vector2(250, 44)
	rib.position = Vector2(70, 128)
	rib.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rib)
	var rl := Label.new()
	var ls := LabelSettings.new()
	ls.font = load("res://art/LilitaOne.ttf")
	ls.font_size = 28
	ls.font_color = Color("#FFF3D6")
	ls.outline_size = 6
	ls.outline_color = Color("#6B0F1A")
	rl.label_settings = ls
	rl.text = "COIN BLAST!"
	rl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rl.size = rib.size
	rib.add_child(rl)
	var sub := Label.new()
	var ls2 := LabelSettings.new()
	ls2.font = load("res://art/LilitaOne.ttf")
	ls2.font_size = 18
	ls2.font_color = Color("#F6E7C8")
	sub.label_settings = ls2
	sub.text = "Total coins earned"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.size = Vector2(390, 24)
	sub.position = Vector2(0, 450)
	add_child(sub)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	row.size = Vector2(390, 64)
	row.position = Vector2(0, 478)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ic := TextureRect.new()
	ic.texture = WebLayout.tex("art/ui-coin.webp")
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.custom_minimum_size = Vector2(50, 50)
	row.add_child(ic)
	num = Label.new()
	var ln := LabelSettings.new()
	ln.font = load("res://art/LilitaOne.ttf")
	ln.font_size = 48
	ln.font_color = Color.WHITE
	ln.outline_size = 8
	ln.outline_color = Color("#6B0F1A")
	num.label_settings = ln
	num.text = "0"
	row.add_child(num)
	add_child(row)
	var nx := mk([40, 580, 145, 62], LoseUI.txt("Next", "Sora-800", 22, "#ffffff"), "next")
	x2 = mk([197, 580, 153, 62], LoseUI.txt("AD Reward x2", "Sora-800", 16, "#ffffff"), "x2")
	UISkin.button(nx, "green")
	UISkin.reskin(x2, UISkin.btn_box("yellow", 18.0))
	var xl: Label = x2.get_node("txt")
	xl.label_settings = xl.label_settings.duplicate()
	xl.label_settings.font_color = Color("#6B0F1A")
	app.tap(nx, func():
		hide_win()
		app.fw.run(false)
		app.next_level())
	app.tap(x2, _x2)
	visible = false

func open(c: int) -> void:
	got = c
	visible = true
	x2.visible = c > 0
	rays.modulate.a = 0.0
	create_tween().tween_property(rays, "modulate:a", 1.0, 0.6)
	if _rt:
		_rt.kill()
	_rt = create_tween().set_loops()
	_rt.tween_property(rays, "rotation", TAU, 40.0).from(0.0)
	num.text = "0"
	var st := {"n": 0}
	create_tween().tween_method(func(k: float):
		num.text = str(int(round(got * k * (2 - k))))
		var q := int(floor(k * 14))
		if q > st.n:
			st.n = q
			app.sfx.coin(q % 8), 0.0, 1.0, 1.4).set_delay(0.3)
	for i in rain.size():
		_drop(rain[i], 0.2 + i * 0.13)

func _drop(c: TextureRect, d: float) -> void:
	if not visible:
		return
	c.visible = true
	c.position = Vector2(randf_range(10, 310), -30)
	c.rotation = randf() * TAU
	var t := c.create_tween()
	t.tween_interval(d)
	t.tween_property(c, "position:y", 540.0, randf_range(1.1, 1.6)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(c, "rotation", c.rotation + randf_range(-3, 3), 1.4)
	t.tween_callback(func(): _drop(c, randf_range(0.0, 0.6)))

func hide_win() -> void:
	visible = false
	if _rt:
		_rt.kill()
		_rt = null
	for c in rain:
		c.visible = false

func _x2() -> void:
	if got <= 0:
		return
	var c := got
	app.show_ad(func(ok: bool):
		if not ok:
			return
		app.S.coins = int(app.S.coins) + c
		app.save()
		x2.visible = false
		create_tween().tween_method(func(k: float): num.text = str(int(round(c + c * k))), 0.0, 1.0, 0.7)
		app.sfx.play("fanfare", 0.5))
