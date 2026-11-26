# 26 Nov: the new home top bar (previews/top-bar.png): small gold profile frame, three cream pills with a gold rim
# (coins, lives, diyas) whose big icons sit half outside the pill, the blue gear, and a soft dark fade behind.
# Only ready-made pictures (art/topbar) and labels: no drawing, no effects. Numbers shrink to fit their pill and
# from 1,000,000 they show the short form (1.2M).
extends Control
class_name TopBar

const Y := 44.0          # centre line of the bar
const PW := 72.0         # pill width
const PH := 32.0
var app
var coin_l: Label
var life_l: Label
var life_n: Label
var diya_l: Label
var pills := {}
var box := {}
var avatar: TextureRect

static func short(v: int) -> String:
	if v >= 1000000:
		var m := v / 1000000.0
		return ("%.1fM" % m).replace(".0M", "M") if m < 100 else "%dM" % int(m)
	return str(v)

static func label(fs: int, col: Color, outline := 0, ocol := Color.BLACK) -> Label:
	var l := Label.new()
	var ls := LabelSettings.new()
	ls.font = WebLayout.font("LilitaOne")
	ls.font_size = fs
	ls.font_color = col
	if outline > 0:
		ls.outline_size = outline
		ls.outline_color = ocol
	l.label_settings = ls
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

static func pic(src: String, pos: Vector2, sz: Vector2, parent: Control) -> TextureRect:
	var t := TextureRect.new()
	t.texture = load("res://" + src)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.position = pos
	t.size = sz
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(t)
	return t

func build(a) -> void:
	app = a
	size = Vector2(390, 90)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fade := pic("art/topbar/fade.png", Vector2(0, -60), Vector2(390, 170), self)
	fade.stretch_mode = TextureRect.STRETCH_SCALE
	# profile
	var pf := Control.new()
	pf.position = Vector2(10, Y - 22)
	pf.size = Vector2(44, 44)
	add_child(pf)
	pic("art/topbar/frame.png", Vector2.ZERO, Vector2(44, 44), pf)
	avatar = pic("art/crk/b10.webp", Vector2(7, 7), Vector2(30, 30), pf)
	app.tap(pf, func(): app.open_page("profile"))
	coin_l = _pill("coin", 72, "art/ui-coin.webp")
	life_l = _pill("life", 166, "art/web/fe-heart.png")
	diya_l = _pill("diya", 260, "art/ui-diya.webp")
	pic("art/topbar/plus.png", Vector2(72 + 6, Y + 8 - 9), Vector2(18, 18), box.coin)
	life_n = label(18, Color.WHITE, 6, Color(0.47, 0.04, 0.12))
	life_n.position = Vector2(166 - 14, Y - 20)
	life_n.size = Vector2(40, 40)
	box.life.add_child(life_n)
	var gear := Control.new()
	gear.position = Vector2(390 - 10 - 42, Y - 21)
	gear.size = Vector2(42, 42)
	add_child(gear)
	pic("art/topbar/gear.png", Vector2.ZERO, Vector2(42, 42), gear)
	app.tap(gear, func(): app.sheet("set"))
	app.tap(pills.coin, func(): app.sheet("shop"))
	app.tap(pills.life, func(): app.lives_card())
	app.tap(pills.diya, func(): app.home_ui._build_btn())

func _pill(k: String, x: float, icon: String) -> Label:
	var c := Control.new()
	c.position = Vector2.ZERO
	c.size = Vector2(x + PW, 90)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(c)
	box[k] = c
	# the tap area covers the pill and its icon
	var hit := Control.new()
	hit.position = Vector2(x - 16, Y - 22)
	hit.size = Vector2(PW + 16, 44)
	c.add_child(hit)
	pills[k] = hit
	var p := pic("art/topbar/pill.png", Vector2(x, Y - PH / 2), Vector2(PW, PH), c)
	p.stretch_mode = TextureRect.STRETCH_SCALE
	pic(icon, Vector2(x - 14, Y - 20), Vector2(40, 40), c)
	var l := label(17, Color8(28, 40, 92))
	l.position = Vector2(x + 26, Y - PH / 2)
	l.size = Vector2(PW - 32, PH)
	c.add_child(l)
	return l

func _fit(l: Label, s: String) -> void:
	l.text = s
	var f: Font = l.label_settings.font
	var fs := 17
	while fs > 9 and f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > l.size.x:
		fs -= 1
	l.label_settings.font_size = fs

func refresh(coins: int, lives: int, life_txt: String, diyas: int) -> void:
	_fit(coin_l, short(coins))
	_fit(life_l, life_txt)
	life_n.text = str(lives)
	_fit(diya_l, short(diyas))
