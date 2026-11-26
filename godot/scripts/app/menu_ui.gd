# 26 Nov: bottom menu (Areas, Trophies, Home raised, Lucky Wheel, Crackers) and its pages:
# Areas (area picture cards), Trophy Room (permanent trophies, bronze/silver/gold steps, Claim = coins),
# Lucky Wheel (free spin once a day, ad spin, timer, bulbs blink while spinning) and Profile.
# Only ready-made pictures (art/menu, tools/pic/menu_art.py) + labels; the wheel turns as one picture.
extends Control
class_name MenuUI

const TABS := ["areas", "trophy", "home", "wheel", "crackers"]
const NAMES := {"areas": "Areas", "trophy": "Trophies", "home": "Home", "wheel": "Lucky Wheel", "crackers": "Crackers"}
const BAR_Y := 742.0
var app
var nav: Control
var sel: TextureRect
var icons := {}
var tab_lbl: Label
var cur := "home"
var pages := {}
var page_root: Control

# ---------------------------------------------------------------- trophies
# id, name, line, icon, stat key, three steps, coins per step
const TRO := [
	{"id": "rocket", "n": "Rocket Master", "t": "Make %d rockets", "ic": "art/crk/b6.webp", "k": "make_rocket", "g": [50, 200, 500], "c": [100, 200, 300]},
	{"id": "star", "n": "3-Star Hero", "t": "Win %d levels with 3 stars", "ic": "art/web/fe-star.png", "k": "star3", "g": [10, 30, 60], "c": [100, 200, 400]},
	{"id": "chakra", "n": "Chakra Spinner", "t": "Fire %d ground chakras", "ic": "art/crk/b8.webp", "k": "fire_chakra", "g": [20, 80, 200], "c": [100, 200, 300]},
	{"id": "break", "n": "Obstacle Breaker", "t": "Break %d obstacles", "ic": "art/crate.webp", "k": "break", "g": [200, 1000, 3000], "c": [100, 250, 400]},
	{"id": "win", "n": "Level Winner", "t": "Win %d levels", "ic": "art/web/fe-trophy.png", "k": "win", "g": [25, 60, 100], "c": [150, 300, 500]},
	{"id": "build", "n": "Builder", "t": "Finish Area %d", "ic": "art/ui-diya.webp", "k": "areas", "g": [1, 2, 3], "c": [300, 500, 800]},
]

static func np(src: String, pos: Vector2, sz: Vector2, m: int, parent: Control) -> NinePatchRect:
	var n := NinePatchRect.new()
	n.texture = load("res://" + src)
	n.patch_margin_left = m * 3
	n.patch_margin_right = m * 3
	n.patch_margin_top = m * 3
	n.patch_margin_bottom = m * 3
	n.position = pos
	n.size = sz * 3
	n.scale = Vector2(1.0 / 3, 1.0 / 3)
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(n)
	return n

func lbl(parent: Control, t: String, pos: Vector2, sz: Vector2, fs: int, col: Color, outline := 0, ocol := Color.BLACK, al := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := TopBar.label(fs, col, outline, ocol)
	l.text = t
	l.position = pos
	l.size = sz
	l.horizontal_alignment = al
	parent.add_child(l)
	return l

func button(parent: Control, kind: String, t: String, r: Rect2, fs := 18) -> Control:
	var b := Control.new()
	b.position = r.position
	b.size = r.size
	parent.add_child(b)
	np("art/menu/btn_%s.png" % kind, Vector2.ZERO, r.size, 20, b)
	var l := lbl(b, t, Vector2(0, -1), r.size, fs, Color.WHITE, 6, Color(0.1, 0.25, 0.05) if kind == "green" else (Color(0.45, 0.22, 0.02) if kind == "gold" else Color(0.2, 0.22, 0.3)))
	l.name = "t"
	return b

func build(a, parent: Control) -> void:
	app = a
	size = Vector2(390, 844)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	page_root = Control.new()
	page_root.size = size
	page_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(page_root)
	nav = Control.new()
	nav.position = Vector2(0, BAR_Y)
	nav.size = Vector2(390, 102)
	add_child(nav)
	var bar := TopBar.pic("art/menu/navbar.png", Vector2.ZERO, Vector2(390, 102), nav)
	bar.stretch_mode = TextureRect.STRETCH_SCALE
	bar.mouse_filter = Control.MOUSE_FILTER_STOP
	sel = TopBar.pic("art/menu/navsel.png", Vector2(0, -16), Vector2(76, 118), nav)
	sel.stretch_mode = TextureRect.STRETCH_SCALE
	for i in TABS.size():
		var k: String = TABS[i]
		var hit := Control.new()
		hit.position = Vector2(i * 78, -16)
		hit.size = Vector2(78, 118)
		nav.add_child(hit)
		icons[k] = TopBar.pic("art/menu/nav_%s.png" % k, Vector2(i * 78 + 9, 12), Vector2(60, 60), nav)
		app.tap(hit, func(): tab(k))
	tab_lbl = lbl(nav, "", Vector2(0, 74), Vector2(78, 20), 13, Color.WHITE, 5, Color(0.08, 0.16, 0.4))
	_select("home")

func _select(k: String) -> void:
	cur = k
	var i := TABS.find(k)
	sel.position.x = i * 78 + 1
	for kk in TABS:
		var j := TABS.find(kk)
		var ic: TextureRect = icons[kk]
		if kk == k:
			ic.position = Vector2(j * 78 + 3, -10)
			ic.size = Vector2(72, 72)
		else:
			ic.position = Vector2(j * 78 + 9, 12)
			ic.size = Vector2(60, 60)
	tab_lbl.text = NAMES[k]
	tab_lbl.position.x = i * 78
	var ls := tab_lbl.label_settings
	ls.font_size = 13
	while ls.font_size > 9 and ls.font.get_string_size(NAMES[k], HORIZONTAL_ALIGNMENT_LEFT, -1, ls.font_size).x > 72:
		ls.font_size -= 1

func tab(k: String) -> void:
	if app.street.busy or app.home_ui.TUT != 0:
		return
	app.sfx.play("ui_tab", 0.8)
	Input.vibrate_handheld(15)
	if k == "crackers":
		app.sheet("bag")
		return
	open(k)

func open(k: String) -> void:
	_select(k if k in TABS else "home")
	for p in pages.values():
		p.visible = false
	if k == "home":
		return
	if not pages.has(k):
		pages[k] = _make_page(k)
	var pg: Control = pages[k]
	pg.visible = true
	call("_fill_" + k, pg)

func at_home() -> bool:
	return cur == "home"

func _make_page(k: String) -> Control:
	var pg := Control.new()
	pg.size = Vector2(390, 844)
	pg.mouse_filter = Control.MOUSE_FILTER_STOP
	page_root.add_child(pg)
	var bg := TopBar.pic("art/menu/page_bg.webp", Vector2(0, -300), Vector2(390, 1444), pg)
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	TopBar.pic("art/menu/rib_%s.png" % k, Vector2(195 - 118, 18), Vector2(236, 48), pg)
	var body := Control.new()
	body.name = "body"
	body.size = Vector2(390, 844)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pg.add_child(body)
	return pg

func _scroll(pg: Control, top: float) -> VBoxContainer:
	var sc := ScrollContainer.new()
	sc.position = Vector2(0, top)
	sc.size = Vector2(390, BAR_Y - 16 - top)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	sc.scroll_deadzone = 8
	pg.get_node("body").add_child(sc)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	vb.custom_minimum_size = Vector2(390, 0)
	sc.add_child(vb)
	return vb

func _clear(pg: Control) -> Control:
	var body: Control = pg.get_node("body")
	for c in body.get_children():
		c.queue_free()
	return body

# ---------------------------------------------------------------- Areas
const AREA_N := ["Sivakasi Street", "GHILLI Crackers", "Busy Days at GHILLI", "GHILLI Delivery Hub", "Madurai"]
func _fill_areas(pg: Control) -> void:
	_clear(pg)
	var vb := _scroll(pg, 78)
	var area: int = app.street.area
	for i in 5:
		var row := Control.new()
		row.custom_minimum_size = Vector2(390, 150)
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		vb.add_child(row)
		TopBar.pic("art/menu/area_%d.webp" % (i + 1), Vector2(16, 0), Vector2(358, 150), row).stretch_mode = TextureRect.STRETCH_SCALE
		var n := i + 1
		if n == 5:
			var cs := lbl(row, "Coming soon", Vector2(16, 40), Vector2(358, 40), 26, Color.WHITE, 8, Color(0.1, 0.1, 0.3))
			cs.label_settings.font_color = Color(1, 0.86, 0.45)
		elif n < area:
			var b := button(row, "gold", "View", Rect2(262, 98, 96, 38), 18)
			b.mouse_filter = Control.MOUSE_FILTER_PASS
			app.tap(b, func(): _view_area(n))
		elif n == area:
			var done: int = mini(app.street.step, app.street.TASKS.size())
			var b := button(row, "green", "Builds %d/%d" % [done, app.street.TASKS.size()], Rect2(232, 98, 126, 38), 16)
			b.mouse_filter = Control.MOUSE_FILTER_PASS
			app.tap(b, func(): open("home"))
		else:
			var b := button(row, "grey", "Locked", Rect2(262, 98, 96, 38), 17)
			b.mouse_filter = Control.MOUSE_FILTER_PASS
	var pad := Control.new()
	pad.custom_minimum_size = Vector2(390, 16)
	vb.add_child(pad)

# a finished area: its picture, full screen; tap to close
func _view_area(n: int) -> void:
	var src: String = ["art/web/title_aft.webp", "art/story2/s1.jpg", "art/story3/s2.jpg", "art/story4/s1.jpg"][n - 1]
	var v := Control.new()
	v.size = Vector2(390, 844)
	add_child(v)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.9)
	dim.position = Vector2(0, -400)
	dim.size = Vector2(390, 1644)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(dim)
	var p := TopBar.pic(src, Vector2(0, 0), Vector2(390, 844), v)
	p.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	lbl(v, "Area %d · %s" % [n, AREA_N[n - 1]], Vector2(0, 30), Vector2(390, 40), 24, Color.WHITE, 8, Color(0.1, 0.08, 0.2))
	lbl(v, "Tap to close", Vector2(0, 790), Vector2(390, 30), 16, Color(1, 1, 1, 0.85), 6, Color(0.1, 0.08, 0.2))
	app.tap(v, func(): v.queue_free())

# ---------------------------------------------------------------- Trophy Room
func stat(k: String) -> int:
	if k == "areas":
		return maxi(0, int(app.S.get("area", 1)) - 1)
	return int(app.S.get("stat", {}).get(k, 0))

func tro_got(id: String) -> int:
	return int(app.S.get("tro", {}).get(id, 0))

const TCOL := ["none", "bronze", "silver", "gold"]
func _fill_trophy(pg: Control) -> void:
	_clear(pg)
	var vb := _scroll(pg, 72)
	# summary
	var top := Control.new()
	top.custom_minimum_size = Vector2(390, 108)
	vb.add_child(top)
	np("art/menu/card.png", Vector2(16, 0), Vector2(358, 104), 20, top)
	lbl(top, "Your trophies", Vector2(16, 6), Vector2(358, 24), 16, Color8(20, 47, 96))
	var cnt := [0, 0, 0, 0]
	var steps := 0
	for T in TRO:
		var g := tro_got(T.id)
		cnt[g] += 1
		steps += g
	for i in 3:
		var col: int = 3 - i
		var x := 40 + i * 112
		TopBar.pic("art/menu/tro_%s.png" % TCOL[col], Vector2(x, 32), Vector2(40, 44), top)
		lbl(top, "x%d" % cnt[col], Vector2(x + 42, 36), Vector2(50, 36), 24, Color8(18, 43, 88), 0, Color.BLACK, HORIZONTAL_ALIGNMENT_LEFT)
	lbl(top, "%d of %d steps" % [steps, TRO.size() * 3], Vector2(16, 78), Vector2(358, 20), 14, Color8(140, 110, 70))
	for T in TRO:
		vb.add_child(_tro_row(T))
	var pad := Control.new()
	pad.custom_minimum_size = Vector2(390, 12)
	vb.add_child(pad)

func _tro_row(T: Dictionary) -> Control:
	var row := Control.new()
	row.custom_minimum_size = Vector2(390, 88)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	np("art/menu/card.png", Vector2(16, 0), Vector2(358, 88), 20, row)
	TopBar.pic("art/menu/circle.png", Vector2(28, 14), Vector2(60, 60), row)
	TopBar.pic(T.ic, Vector2(36, 22), Vector2(44, 44), row)
	var got := tro_got(T.id)
	var done := got >= 3
	var step := mini(got, 2)
	var goal: int = T.g[step]
	var v := mini(stat(T.k), goal)
	lbl(row, T.n, Vector2(100, 10), Vector2(180, 24), 18, Color8(16, 39, 80), 0, Color.BLACK, HORIZONTAL_ALIGNMENT_LEFT)
	lbl(row, T.t % goal, Vector2(100, 34), Vector2(190, 18), 13, Color8(130, 100, 70), 0, Color.BLACK, HORIZONTAL_ALIGNMENT_LEFT)
	np("art/menu/bar_back.png", Vector2(100, 58), Vector2(170, 16), 7, row)
	var fw := maxf(16.0, 170.0 * (1.0 if done else float(v) / goal))
	np("art/menu/bar_fill.png", Vector2(100, 58), Vector2(fw, 16), 7, row)
	lbl(row, "Complete" if done else "%d / %d" % [v, goal], Vector2(100, 57), Vector2(170, 18), 12, Color.WHITE, 4, Color(0.12, 0.24, 0.12))
	if done:
		TopBar.pic("art/menu/tro_gold.png", Vector2(302, 8), Vector2(42, 48), row)
		lbl(row, "Complete", Vector2(282, 60), Vector2(82, 18), 12, Color8(60, 140, 60))
	elif stat(T.k) >= goal:
		var b := button(row, "green", "Claim", Rect2(280, 22, 84, 44), 18)
		b.mouse_filter = Control.MOUSE_FILTER_PASS
		app.tap(b, func(): _claim(T))
		_pulse(b)
	else:
		TopBar.pic("art/menu/tro_%s.png" % TCOL[step + 1], Vector2(298, 6), Vector2(34, 40), row).modulate.a = 0.55
		TopBar.pic("art/ui-coin.webp", Vector2(296, 52), Vector2(20, 20), row)
		lbl(row, str(T.c[step]), Vector2(316, 52), Vector2(50, 20), 15, Color8(150, 100, 30), 0, Color.BLACK, HORIZONTAL_ALIGNMENT_LEFT)
	return row

func _pulse(b: Control) -> void:
	b.pivot_offset = b.size / 2
	var tw := b.create_tween().set_loops()
	tw.tween_property(b, "scale", Vector2(1.06, 1.06), 0.45)
	tw.tween_property(b, "scale", Vector2.ONE, 0.45)

func _claim(T: Dictionary) -> void:
	var g := tro_got(T.id)
	if g >= 3 or stat(T.k) < int(T.g[g]):
		return
	var tro: Dictionary = app.S.get("tro", {})
	tro[T.id] = g + 1
	app.S.tro = tro
	var c: int = T.c[g]
	app.S.coins = int(app.S.coins) + c
	app.save()
	app.sfx.play("fanfare", 0.4)
	app.popup("Trophy step done!", [["art/menu/tro_%s.png" % TCOL[g + 1], T.n, "+%d coins" % c]])
	_fill_trophy(pages.trophy)
	app.home_ui.refresh_top()

# ---------------------------------------------------------------- Lucky Wheel
const PRIZES := [
	{"t": "100 coins", "k": "coins", "n": 100, "w": 24, "ic": "art/ui-coin.webp"},
	{"t": "Rocket", "k": "rocket", "n": 1, "w": 12, "ic": "art/crk/b6.webp"},
	{"t": "50 coins", "k": "coins", "n": 50, "w": 26, "ic": "art/ui-coin.webp"},
	{"t": "Hammer", "k": "hammer", "n": 1, "w": 8, "ic": "art/crk/b17.webp"},
	{"t": "+1 life", "k": "life", "n": 1, "w": 10, "ic": "art/web/fe-heart.png"},
	{"t": "200 coins", "k": "coins", "n": 200, "w": 12, "ic": "art/ui-coin.webp"},
	{"t": "Bomb", "k": "atom", "n": 1, "w": 6, "ic": "art/crk/b10.webp"},
	{"t": "500 coins chest", "k": "coins", "n": 500, "w": 2, "ic": "art/web/ui-chest.webp"},
]
const AD_SPINS := 3
var wheel: Control
var lit: TextureRect
var spinning := false
var blink_t := 0.0
var w_free: Control
var w_ad: Control
var w_info: Label

func _fill_wheel(pg: Control) -> void:
	if wheel != null:
		_wheel_ui()
		return
	var body: Control = pg.get_node("body")
	lbl(body, "Spin every day for free prizes!", Vector2(0, 76), Vector2(390, 24), 16, Color(1, 0.94, 0.78), 6, Color(0.08, 0.16, 0.4))
	TopBar.pic("art/menu/wheel_glow.png", Vector2(195 - 200, 358 - 200), Vector2(400, 400), body).stretch_mode = TextureRect.STRETCH_SCALE
	wheel = Control.new()
	wheel.position = Vector2(195 - 165, 358 - 165)
	wheel.size = Vector2(330, 330)
	wheel.pivot_offset = Vector2(165, 165)
	wheel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(wheel)
	TopBar.pic("art/menu/wheel.png", Vector2.ZERO, Vector2(330, 330), wheel)
	lit = TopBar.pic("art/menu/wheel_lit.png", Vector2.ZERO, Vector2(330, 330), wheel)
	lit.visible = false
	TopBar.pic("art/menu/wheel_hub.png", Vector2(165 - 40, 165 - 40), Vector2(80, 80), body).position = Vector2(195 - 40, 358 - 40)
	TopBar.pic("art/menu/wheel_ptr.png", Vector2(195 - 22, 358 - 165 - 28), Vector2(44, 58), body)
	w_free = button(body, "green", "SPIN FREE", Rect2(70, 556, 250, 62), 28)
	w_ad = button(body, "gold", "Spin again", Rect2(90, 630, 210, 52), 20)
	var tag := AppFx.badge("AD", Color("#E8123C"), Vector2(36, 22), WebLayout.font("LilitaOne"), 14, 8, 2)
	tag.position = Vector2(12, 15)
	w_ad.add_child(tag)
	w_info = lbl(body, "", Vector2(0, 696), Vector2(390, 24), 15, Color(0.86, 0.9, 1), 5, Color(0.08, 0.16, 0.4))
	app.tap(w_free, func(): _spin(false))
	app.tap(w_ad, func():
		if spinning:
			return
		app.show_ad(func(ok: bool):
			if ok:
				_spin(true)))
	_wheel_ui()

func _wheel_ui() -> void:
	if wheel == null:
		return
	var free: bool = str(app.S.get("wheel_day", "")) != app.today()
	var ads_used := int(app.S.get("wheel_ads", {}).get(app.today(), 0))
	w_free.visible = free
	w_ad.visible = not free and ads_used < AD_SPINS
	var now := Time.get_datetime_dict_from_system()
	var left := 86400 - (int(now.hour) * 3600 + int(now.minute) * 60 + int(now.second))
	w_info.text = "Free spin ready!" if free else "Next free spin in %02d:%02d:%02d" % [left / 3600, (left / 60) % 60, left % 60]

func _pick() -> int:
	var tot := 0
	for p in PRIZES:
		tot += int(p.w)
	var r := randi() % tot
	for i in PRIZES.size():
		r -= int(PRIZES[i].w)
		if r < 0:
			return i
	return 0

func _spin(ad: bool) -> void:
	if spinning:
		return
	if not ad:
		if str(app.S.get("wheel_day", "")) == app.today():
			return
		app.S.wheel_day = app.today()
	else:
		var wa: Dictionary = app.S.get("wheel_ads", {})
		if not wa.has(app.today()):
			wa = {}
		wa[app.today()] = int(wa.get(app.today(), 0)) + 1
		app.S.wheel_ads = wa
	app.save()
	var i := _pick()
	spinning = true
	w_free.visible = false
	w_ad.visible = false
	w_info.text = "Good luck!"
	app.sfx.play("swoosh", 0.5)
	# prize i sits at i*45+22.5 degrees (clockwise from the top): turn it under the pointer, 5 full turns first
	var start := fmod(wheel.rotation_degrees, 360.0)
	wheel.rotation_degrees = start
	var target := 360.0 * 6 - (i * 45.0 + 22.5) + randf_range(-14, 14)
	var tw := wheel.create_tween()
	tw.tween_property(wheel, "rotation_degrees", target, 4.2).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw.finished.connect(func():
		spinning = false
		lit.visible = false
		_give(i)
		_wheel_ui())

func _give(i: int) -> void:
	var p: Dictionary = PRIZES[i]
	match p.k:
		"coins":
			app.S.coins = int(app.S.coins) + int(p.n)
		"life":
			app.add_life(int(p.n))
		_:
			app.add_inv(p.k, int(p.n))
	app.save()
	app.popup("You won!", [[p.ic, p.t, "From the Lucky Wheel"]])
	app.home_ui.refresh_top()

# ---------------------------------------------------------------- Profile
func _fill_profile(pg: Control) -> void:
	var body := _clear(pg)
	np("art/menu/card.png", Vector2(16, 80), Vector2(358, 190), 20, body)
	TopBar.pic("art/topbar/frame.png", Vector2(195 - 45, 96), Vector2(90, 90), body)
	TopBar.pic("art/crk/b10.webp", Vector2(195 - 30, 111), Vector2(60, 60), body)
	lbl(body, str(app.S.get("name", "Guest")), Vector2(16, 190), Vector2(358, 30), 24, Color8(16, 39, 80))
	var b := button(body, "green", "Sign in with Google Play", Rect2(48, 224, 294, 40), 17)
	app.tap(b, func(): app.home_ui.show_toast("Google Play sign-in comes soon"))
	np("art/menu/card.png", Vector2(16, 284), Vector2(358, 300), 20, body)
	lbl(body, "My records", Vector2(16, 296), Vector2(358, 28), 20, Color8(16, 39, 80))
	var tro := 0
	for T in TRO:
		tro += tro_got(T.id)
	var recs := [
		["art/web/fe-trophy.png", "Levels won", str(int(app.S.lv))],
		["art/web/fe-star.png", "3-star wins", str(stat("star3"))],
		["art/crk/b6.webp", "Rockets made", str(stat("make_rocket"))],
		["art/crate.webp", "Obstacles broken", str(stat("break"))],
		["art/ui-diya.webp", "Areas finished", str(stat("areas"))],
		["art/menu/tro_gold.png", "Trophy steps", "%d / %d" % [tro, TRO.size() * 3]],
	]
	for j in recs.size():
		var y := 332 + j * 40
		TopBar.pic(recs[j][0], Vector2(36, y), Vector2(30, 30), body)
		lbl(body, recs[j][1], Vector2(78, y), Vector2(200, 30), 17, Color8(90, 60, 40), 0, Color.BLACK, HORIZONTAL_ALIGNMENT_LEFT)
		lbl(body, recs[j][2], Vector2(250, y), Vector2(104, 30), 19, Color8(16, 39, 80), 0, Color.BLACK, HORIZONTAL_ALIGNMENT_RIGHT)

# ---------------------------------------------------------------- every frame: only the blinking bulbs and the timer
var sec := 0.0
func _process(dt: float) -> void:
	if spinning:
		blink_t -= dt
		if blink_t <= 0:
			blink_t = 0.14
			lit.visible = not lit.visible
	sec -= dt
	if sec <= 0:
		sec = 1.0
		if cur == "wheel" and not spinning:
			_wheel_ui()
