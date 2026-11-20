# The home screen over the 3D street (street/index.html #home and its windows):
# top bar (coins, lives, diyas, gear), Level N and Build buttons, bottom bar, Daily and Shop,
# the build window (Sivakasi Street task list), the first-build tutorial, the notification card,
# toast, "tap to speed up" / Skip while building, "Area Completed!" banner, the diya that flies to the site.
extends Control
class_name HomeUI

var app
var st: Street
var LH: WebLayout
var LB: WebLayout
var LN: WebLayout
var LA: WebLayout
var LTip: WebLayout
var home: Control
var bp: Control
var notif: Control
var agree: Control
var tdim: ColorRect
var tip: Control
var toast: Control
var toast_t := 0.0
var hint: Control
var skip: Control
var ban: Control
var fw: TitleScreen.TitleFw
var badge: Control
var hand: Control
var hand_tw: Tween
var TUT := 0
var trail: Control
var lift_nodes: Array = []

func build(a, street: Street) -> void:
	app = a
	st = street
	size = Vector2(390, 844)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# tap anywhere while building: speed up
	var catcher := Control.new()
	catcher.size = size
	catcher.mouse_filter = Control.MOUSE_FILTER_STOP
	catcher.name = "speed"
	catcher.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.pressed and st.busy:
			st.speed_up()
		elif st is PicStreet and not st.busy and home.visible:
			(st as PicStreet).drag_input(e))
	add_child(catcher)
	LH = WebLayout.new()
	home = LH.build("res://ui/st_home.json", self)
	# small fixes for text written next to pictures in the web (pill texts, Level N)
	var full: Control = LH.nodes[8]
	if app.lbl(full):
		app.lbl(full).position.x = 30
		app.lbl(full).size.x = 56
		app.lbl(full).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge = AppFx.badge("1", Color("#E8123C"), Vector2(24, 24), WebLayout.font("TitanOne"), 14, 12, 2)
	badge.position = Vector2(176 - 18, -8)
	LH.node("hBuild").add_child(badge)
	app.tap(LH.node("hPlay"), _play)
	app.tap(LH.node("hBuild"), _build_btn)
	app.tap(LH.nodes[14], func(): app.sheet("set"))
	app.tap(LH.node("pCoin"), func(): app.sheet("shop"))
	app.tap(LH.node("hShop"), func(): app.sheet("shop"))
	app.tap(LH.node("hDaily"), func(): app.sheet("daily"))
	var nav := {31: "Events", 33: "Ranks", 39: "Team", 42: "Crackers"}
	for i in nav:
		var n: String = nav[i]
		app.tap(LH.nodes[i], func():
			if n == "Crackers":
				app.sheet("bag")
			else:
				show_toast(n + " comes soon"))
	# windows
	LB = WebLayout.new()
	bp = LB.build("res://ui/st_build.json", self)
	bp.visible = false
	bp.mouse_filter = Control.MOUSE_FILTER_STOP
	app.tap(LB.node("bpX"), func():
		bp.visible = false)
	for c in LB.node("bpRows").get_children():
		c.visible = false
	LN = WebLayout.new()
	notif = LN.build("res://ui/st_notif.json", self)
	notif.visible = false
	notif.mouse_filter = Control.MOUSE_FILTER_STOP
	app.tap(LN.node("bAllow"), func():
		app.S.notif28 = 1
		app.save()
		notif.visible = false
		app.ask_notify())
	app.tap(LN.node("bLater"), func():
		app.S.notif28 = 1
		app.save()
		notif.visible = false)
	LA = WebLayout.new()
	agree = LA.build("res://ui/st_agree.json", self)
	agree.visible = false
	agree.mouse_filter = Control.MOUSE_FILTER_STOP
	# "Privacy Policy and Terms of Service" on one centred line with the red underlined links
	var p: Control = LA.nodes[3]
	for ch in p.get_children():
		if ch is Control and ch.has_meta("web"):
			ch.visible = false
	if app.lbl(p):
		app.lbl(p).visible = false
	var rt := RichTextLabel.new()
	rt.bbcode_enabled = true
	rt.fit_content = true
	rt.scroll_active = false
	rt.add_theme_font_override("normal_font", WebLayout.font("Sora-700"))
	rt.add_theme_font_size_override("normal_font_size", 15)
	rt.add_theme_color_override("default_color", Color("#5a2a1a"))
	rt.text = "[center]Before you play, please read our [color=#C8102E][u]Privacy Policy[/u][/color] and [color=#C8102E][u]Terms of Service[/u][/color].[/center]"
	rt.size = p.size
	rt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(rt)
	# tutorial dim, tip and hand
	tdim = ColorRect.new()
	tdim.color = Color(0.1, 0.04, 0.08, 0.6)
	tdim.size = size
	tdim.visible = false
	tdim.z_index = 5
	tdim.mouse_filter = Control.MOUSE_FILTER_STOP
	tdim.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.pressed:
			if TUT == 2 and LH.node("hBuild").get_global_rect().has_point(e.global_position):
				_build_btn()
			else:
				_tut_next())
	add_child(tdim)
	LTip = WebLayout.new()
	tip = LTip.build("res://ui/st_tip.json", self)
	tip.visible = false
	tip.z_index = 7
	var hl := WebLayout.new()
	hand = hl.build("res://ui/hand.json", self)
	hand.visible = false
	hand.z_index = 8
	var lt := WebLayout.new()
	toast = lt.build("res://ui/st_toast.json", self)
	toast.modulate.a = 0
	toast.z_index = 9
	var lh2 := WebLayout.new()
	hint = lh2.build("res://ui/st_hint.json", self)
	hint.visible = false
	var ls := WebLayout.new()
	skip = ls.build("res://ui/st_skip.json", self)
	skip.visible = false
	app.tap(skip, func(): st.SPEED = 30.0)
	var lb := WebLayout.new()
	ban = lb.build("res://ui/st_ban.json", self)
	ban.visible = false
	fw = TitleScreen.TitleFw.new()
	fw.size = size
	add_child(fw)
	trail = Control.new()
	trail.size = size
	trail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(trail)
	st.spend_cb = _spend
	st.changed.connect(refresh)
	st.task_done.connect(_task_done)
	st.sfx.connect(func(n: String): app.street_sfx(n))

func _process(dt: float) -> void:
	if toast_t > 0:
		toast_t -= dt
		if toast_t <= 0:
			create_tween().tween_property(toast, "modulate:a", 0.0, 0.3)

func show_toast(t: String) -> void:
	app.set_t(toast, t)
	var l: Label = app.lbl(toast)
	var w: float = l.label_settings.font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, l.label_settings.font_size).x + 36
	app.resize_box(toast, Vector2(w, toast.size.y))
	toast.position.x = 195 - w / 2
	l.size.x = w
	l.position.x = 0
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.modulate.a = 1
	toast_t = 1.8

# ---------------------------------------------------------------- home
func show_home() -> void:
	sync_out()
	home.visible = true
	home.modulate.a = 1
	refresh()
	if st.step == 0 and not app.S.get("tut", false) and st.diyas >= int(st.TASKS[0].c):
		get_tree().create_timer(0.7).timeout.connect(tutorial)
	elif int(app.S.lv) >= 2 and not app.S.get("notif28", false):
		get_tree().create_timer(0.9).timeout.connect(func():
			app.S.notif28 = 1
			app.save()
			# only Android's own permission question, once (our card before it felt like asking twice)
			app.ask_notify())

func hide_home() -> void:
	home.visible = false

func sync_in() -> void:
	var n := mini(int(app.S.get("step", 0)), st.TASKS.size())
	if n > st.step:
		st.skip_to(n)
	# diyas left = diyas earned in levels - diyas spent on builds done, so nothing is ever lost.
	# Levels 1-10 give exactly what all ten builds cost; once level 10 is won, every build can be finished.
	var earned := 0
	var r: Vector2i = app.area_levels()
	for k in app.S.get("best", {}):
		if int(k) >= r.x and int(k) < r.y:
			earned += int(app.S.best[k])
	var spent := 0
	var left := 0
	for i in st.TASKS.size():
		if i < n: spent += int(st.TASKS[i].c)
		else: left += int(st.TASKS[i].c)
	var d := maxi(0, earned - spent)
	if int(app.S.lv) >= app.area_cap():
		d = maxi(d, left)
	st.diyas = d
	app.S.diyas = d

func sync_out() -> void:
	app.S.diyas = st.diyas
	app.S.step = st.step
	app.save()

func refresh() -> void:
	if not home.visible:
		return
	var n := mini(st.step, st.TASKS.size())
	# "n/10" in one label (the two-part web layout drew the slash badly), and the diya sits left of "Build"
	LH.node("hCnt").visible = false
	app.set_t(LH.nodes[27], "%d/%d" % [n, st.TASKS.size()])
	var bl: Label = app.lbl(LH.nodes[23])
	if bl:
		bl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var bar: Control = LH.node("hBar")
	app.resize_box(bar, Vector2(117.0 * n / st.TASKS.size(), bar.size.y))
	app.set_t(LH.node("tDy"), str(st.diyas))
	app.set_t(LH.node("tCoin"), str(app.S.coins))
	var c := st.can_do()
	app.set_t(badge, str(c))
	badge.visible = c > 0
	var lvN := int(app.S.lv) + 1
	var all: int = app.area_cap()
	var f: Control = LH.nodes[18]
	if lvN > all:
		LH.nodes[19].visible = false
		var la: Label = app.lbl(f)
		if la:
			la.position.x = 0
			la.size.x = f.size.x
			la.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		app.fit_t(f, "Build to Unlock" if st.area == 1 else "Area 3 Soon", f.size.x - 14)
	else:
		app.fit_t(f, "Level", 999)
		LH.nodes[19].visible = true
		app.set_t(LH.nodes[19], str(lvN))
		var l: Label = app.lbl(f)
		var fs: int = l.label_settings.font_size
		var w1: float = l.label_settings.font.get_string_size("Level ", HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var w2: float = l.label_settings.font.get_string_size(str(lvN), HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var x0 := (f.size.x - w1 - w2) / 2.0
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		l.position.x = x0
		LH.nodes[19].position.x = x0 + w1
		LH.nodes[19].size.x = w2 + 4
		var l2: Label = app.lbl(LH.nodes[19])
		if l2:
			l2.size.x = w2 + 4
			l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

func _play() -> void:
	if st.busy or TUT != 0:
		return
	sync_out()
	app.street_play()

func _build_btn() -> void:
	if st.busy or TUT == 1:
		return
	if TUT == 2:
		end_tutorial()
		app.street_sfx("start")
		hide_home()
		st.do_task(false)
		_building(true)
		return
	panel()
	bp.visible = true
	app.street_sfx("open")

# ---------------------------------------------------------------- the build window
func panel() -> void:
	var n := mini(st.step, st.TASKS.size())
	var bar: Control = LB.node("bpBar")
	app.resize_box(bar, Vector2(232.0 * n / st.TASKS.size(), bar.size.y))
	app.set_t(LB.node("bpCnt"), "%d/%d" % [n, st.TASKS.size()])
	var rows: Control = LB.node("bpRows")
	for c in rows.get_children():
		if c.has_meta("dyn"):
			c.queue_free()
	var nAll := st.can_do()
	var y := 0.0
	for i in range(st.step, mini(st.step + 2, st.TASKS.size())):
		var T: Dictionary = st.TASKS[i]
		var first := i == st.step
		var can := st.diyas >= int(T.c)
		var r: Control = app.sub(LB, 11 if first else 18, rows)
		r.set_meta("dyn", 1)
		r.visible = true
		r.position.y = y
		app.set_img(app.kid(r, "img"), "art/task-%d.webp" % (i + 1))
		app.set_t(app.kid(r, "span"), T.n)
		_wrap(app.kid(r, "span"), 128.0)
		if first:
			var bbs: Control = app.kid(r, "div")
			var bdo: Control = app.kid(bbs, "button")
			var ball: Control = app.kid(bbs, "button", 1)
			if can:
				app.set_t(bdo, "Build %d" % int(T.c))
				# text in the left part, the diya on the right: no overlap
				var bl: Label = app.lbl(bdo)
				if bl:
					bl.position.x = 4
					bl.size.x = bdo.size.x - 34
					bl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
					for ch in bl.get_children():
						if ch is Label:
							ch.size.x = bl.size.x
							ch.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				if app.kid(bdo, "img"):
					app.kid(bdo, "img").position.x = bdo.size.x - 32
				ball.visible = nAll >= 2
				app.set_t(ball, "Build All ×%d" % nAll)
				app.tap(ball, func():
					bp.visible = false
					app.street_sfx("start")
					end_tutorial()
					hide_home()
					st.build_all()
					_building(true))
				if nAll < 2:
					bdo.position.y = 25
			else:
				# not enough diyas: Play (blue) wins more
				ball.visible = false
				bdo.position.y = 25
				if app.kid(bdo, "img"):
					app.kid(bdo, "img").visible = false
				app.set_bg(bdo, Color("#2F86E0"))
				app.set_t(bdo, "Play")
			app.tap(bdo, func():
				bp.visible = false
				if st.diyas >= int(T.c):
					app.street_sfx("start")
					end_tutorial()
					hide_home()
					st.do_task(false)
					_building(true)
				else:
					sync_out()
					app.street_play())
			y += 122
		else:
			y += 82
	if st.step >= st.TASKS.size():
		var r2: Control = app.sub(LB, 18, rows)
		r2.set_meta("dyn", 1)
		r2.visible = true
		r2.modulate.a = 1
		app.set_img(app.kid(r2, "img"), "art/task-10.webp")
		app.set_t(app.kid(r2, "span"), "Sivakasi Street is complete!")
		app.kid(r2, "button").visible = false

# ---------------------------------------------------------------- while building
func _building(on: bool) -> void:
	hint.visible = on
	app.set_t(hint, "Building %d/%d · Tap to speed up" % [st.FN, st.FT] if st.FAST else "Tap to speed up")
	skip.visible = on and st.FAST
	if on:
		Anim.play(skip, "beat2", 1.2, 0.0, "ease-in-out", -1)

func _task_done(last: bool) -> void:
	sync_out()
	if st.busy:
		app.set_t(hint, "Building %d/%d · Tap to speed up" % [st.FN, st.FT])
		return
	_building(false)
	if last:
		_area_won()
	else:
		get_tree().create_timer(0.25).timeout.connect(show_home)
		if app.card_after_build:
			app.card_after_build = false
			get_tree().create_timer(0.9).timeout.connect(app.street_play)

func _area_won() -> void:
	# the end-of-area story plays first (once), then the banner, fireworks and reward as before
	get_tree().create_timer(1.2).timeout.connect(func(): app.play_area_end(_area_won_show))

func _area_won_show() -> void:
	get_tree().create_timer(0.6).timeout.connect(func():
		ban.visible = true
		Anim.play(ban, "pop2", 0.6, 0.0, "cubic-bezier(.3,1.5,.5,1)")
		for i in 7:
			get_tree().create_timer(i * 0.45).timeout.connect(func():
				var x := 390 * (0.15 + randf() * 0.7)
				app.street_sfx("rocketS")
				fw.rocket(x, x + (randf() - 0.5) * 60, 844 * (0.12 + randf() * 0.2), 0.8, func(a: float, b: float):
					app.street_sfx("blast")
					fw.burst(a, b, 90, 200, TitleScreen.TitleFw.GOLD)
					fw.burst(a, b, 40, 120, ["#FF4B6E", "#7FD1FF", "#FFFFFF"]))))
	get_tree().create_timer(5.6).timeout.connect(func():
		ban.visible = false
		app.area_reward())
	get_tree().create_timer(7.0).timeout.connect(func():
		if st.area == 1:
			app.enter_area2()
		else:
			show_home())

# the diya leaves the Build button and flies to the building site (web spendFx option B), then a burst there
func _spend(site: Vector3, done: Callable) -> void:
	var b: Control = LH.node("hBuild")
	var p0 := b.get_global_rect().get_center() - global_position
	var dot := Control.new()
	dot.size = Vector2(34, 34)
	dot.pivot_offset = Vector2(17, 17)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tr := TextureRect.new()
	tr.texture = AppFx.grad_tex([0.0, 0.3, 0.55, 0.72], [Color.WHITE, Color("#fff6c8"), Color("#ffc23a"), Color(1, 0.76, 0.23, 0)], true)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.size = dot.size
	dot.add_child(tr)
	trail.add_child(dot)
	var st_ := {"lt": 0.0}
	var tw := create_tween()
	tw.tween_method(func(k: float):
		var tg: Vector2 = st.screen_pos(site) - global_position
		var e := k * k * (3 - 2 * k)
		var x := p0.x + (tg.x - p0.x) * e + sin(e * PI) * 40
		var y := p0.y + (tg.y - p0.y) * e - sin(e * PI) * 60
		dot.position = Vector2(x, y) - Vector2(17, 17)
		var now := Time.get_ticks_msec() / 1000.0
		if now - st_.lt > 0.012:
			st_.lt = now
			_trail_dot(x, y, Color("#ffd86a"), 26, 0.45)
			_trail_dot(x + randf_range(-8, 8), y + randf_range(-8, 8), Color.WHITE, 8, 0.6), 0.0, 1.0, 0.8)
	tw.tween_callback(func():
		dot.queue_free()
		st.sparkle(site, 36, site.y + 1.5)
		st.ring(site, Color("#ffe27a"), 0.15)
		st.ring(site, Color.WHITE, 0.15))
	tw.tween_interval(0.3)
	tw.tween_callback(done)

func _trail_dot(x: float, y: float, col: Color, sz: float, life: float) -> void:
	var d := TextureRect.new()
	d.texture = AppFx.grad_tex([0.0, 0.4, 0.7], [Color.WHITE, col, Color(col, 0)], true)
	d.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	d.size = Vector2(sz, sz)
	d.pivot_offset = d.size / 2
	d.position = Vector2(x, y) - d.size / 2
	d.mouse_filter = Control.MOUSE_FILTER_IGNORE
	trail.add_child(d)
	var tw := create_tween().set_parallel()
	tw.tween_property(d, "modulate:a", 0.0, life)
	tw.tween_property(d, "scale", Vector2(0.2, 0.2), life)
	tw.chain().tween_callback(d.queue_free)

# ---------------------------------------------------------------- first build: 2 steps on a dimmed screen
func tutorial() -> void:
	TUT = 1
	tdim.visible = true
	var pill: Control = LH.nodes[11]
	_lift(pill)
	app.set_t(tip, ("You earned 1 diya! Use diyas to build your %s." % ("street" if st.area == 1 else "shop") if st.diyas == 1 else "You earned %d diyas! Use them to build your %s." % [st.diyas, "street" if st.area == 1 else "shop"]))
	_fit_tip()
	tip.visible = true
	tip.position.y = pill.get_global_rect().end.y - global_position.y + 18
	hand.visible = false

func _lift(c: Control) -> void:
	c.z_index = 6
	lift_nodes.append(c)

func _tut_next() -> void:
	if TUT != 1:
		return
	TUT = 2
	for c in lift_nodes:
		c.z_index = 0
	lift_nodes.clear()
	var b: Control = LH.node("hBuild")
	_lift(b)
	Anim.play(b, "beat2", 1.0, 0.0, "ease-in-out", -1)
	var nm: String = String(st.TASKS[0].n).trim_prefix("Build the ")
	app.set_t(tip, "Tap Build to build the %s!" % nm)
	_fit_tip()
	tip.position.y = b.get_global_rect().position.y - global_position.y - tip.size.y - 26
	var r := b.get_global_rect()
	hand.visible = true
	hand.position = Vector2(r.position.x + r.size.x * 0.5 - 22, r.end.y - 18) - global_position
	if hand_tw:
		hand_tw.kill()
	hand_tw = create_tween().set_loops()
	hand_tw.tween_property(hand, "scale", Vector2(0.85, 0.85), 0.4)
	hand_tw.tween_property(hand, "scale", Vector2.ONE, 0.4)

func end_tutorial() -> void:
	if TUT == 0:
		return
	TUT = 0
	app.S.tut = 1
	app.save()
	tdim.visible = false
	tip.visible = false
	hand.visible = false
	if hand_tw:
		hand_tw.kill()
	for c in lift_nodes:
		c.z_index = 0
		Anim.stop(c, true)
	lift_nodes.clear()
	Anim.stop(LH.node("hBuild"), true)

# the tip card hugs its text: padding 14, text centred both ways
func _fit_tip() -> void:
	var l: Label = app.lbl(tip)
	if l == null:
		return
	var w := tip.size.x
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.position = Vector2(16, 0)
	l.size = Vector2(w - 32, 10)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var lines := maxi(1, l.get_line_count())
	var th := float(lines * l.get_line_height())
	var h := th + 30.0
	app.resize_box(tip, Vector2(w, h))
	l.size = Vector2(w - 32, h)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	for ch in l.get_children():
		if ch is Label:
			ch.autowrap_mode = l.autowrap_mode
			ch.size = l.size
			ch.horizontal_alignment = l.horizontal_alignment
			ch.vertical_alignment = l.vertical_alignment

# a row title wraps inside its column and stays vertically centred on the picture
func _wrap(c: Control, w: float) -> void:
	var l: Label = app.lbl(c)
	if l == null:
		return
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.position.x = 0
	l.size = Vector2(w, 10)
	var h := float(maxi(1, l.get_line_count()) * l.get_line_height())
	var cy := c.position.y + c.size.y / 2.0
	c.size = Vector2(w, h)
	c.position.y = cy - h / 2.0
	l.size = Vector2(w, h)
	for ch in l.get_children():
		if ch is Label:
			ch.autowrap_mode = l.autowrap_mode
			ch.size = l.size
