# Step 1 test app: pick a level (1-10), play the board, see win/lose. FPS shown at the top for the phone test.
extends Node2D

var board: Board
var sfx: Sfx
var fx: Fx
var ui: CanvasLayer
var hud: Control
var lbl_level: Label
var lbl_moves: Label
var goal_box: HBoxContainer
var fps: Label
var menu: Control
var endp: Control
var end_title: Label
var end_btn: Button
var cur := 0
var levels: Array
var lite := false
const GOLD := Color(1.0, 0.86, 0.35)
const NAVY := Color(0.1, 0.12, 0.28)

func _ready() -> void:
	randomize()
	levels = Levels.all()
	lite = _weak_phone()
	var bg := Sprite2D.new()
	bg.texture = load("res://art/scene1.webp")
	bg.centered = false
	var sc := maxf(390.0 / bg.texture.get_width(), 844.0 / bg.texture.get_height())
	bg.scale = Vector2(sc, sc)
	bg.modulate = Color(0.75, 0.7, 0.85)
	add_child(bg)
	var dim := ColorRect.new()
	dim.color = Color(0.12, 0.03, 0.22, 0.35)
	dim.size = Vector2(390, 900)
	add_child(dim)
	sfx = Sfx.new()
	add_child(sfx)
	board = Board.new()
	board.position = Vector2((390 - Board.C * Board.U) / 2.0, 190)
	board.sfx = sfx
	board.lite = lite
	add_child(board)
	fx = Fx.new()
	fx.lite = lite
	add_child(fx)
	board.fx = fx
	board.changed.connect(_refresh)
	board.finished.connect(_on_finished)
	_build_ui()
	_show_menu()

func _weak_phone() -> bool:
	# Android: less than about 4.5 GB memory counts as a weak phone (lighter effects)
	var mem := OS.get_memory_info()
	var phys: int = mem.get("physical", 0)
	return phys > 0 and phys < 4800000000

func _panel_style(bgc: Color, border: Color, rad: int = 18) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bgc
	s.border_color = border
	s.set_border_width_all(3)
	s.set_corner_radius_all(rad)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	return s

func _label(t: String, size: int, col: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0.25, 0.05, 0.0))
	l.add_theme_constant_override("outline_size", 6)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return l

func _button(t: String, col: Color) -> Button:
	var b := Button.new()
	b.text = t
	b.add_theme_font_size_override("font_size", 24)
	var n := _panel_style(col, GOLD, 22)
	b.add_theme_stylebox_override("normal", n)
	b.add_theme_stylebox_override("hover", n)
	b.add_theme_stylebox_override("pressed", _panel_style(col.darkened(0.2), GOLD, 22))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return b

func _build_ui() -> void:
	ui = CanvasLayer.new()
	add_child(ui)
	hud = Control.new()
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(hud)
	var top := PanelContainer.new()
	top.add_theme_stylebox_override("panel", _panel_style(Color(0.24, 0.07, 0.42, 0.95), GOLD, 22))
	top.position = Vector2(10, 40)
	top.size = Vector2(370, 120)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(top)
	var hb := HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.add_theme_constant_override("separation", 14)
	top.add_child(hb)
	var lv_box := VBoxContainer.new()
	lv_box.custom_minimum_size = Vector2(100, 0)
	lbl_level = _label("Level 1", 20, GOLD)
	lbl_moves = _label("18", 42, Color.WHITE)
	var mv := _label("Moves", 16, GOLD)
	lv_box.add_child(lbl_level)
	lv_box.add_child(lbl_moves)
	lv_box.add_child(mv)
	hb.add_child(lv_box)
	var tg := VBoxContainer.new()
	tg.add_child(_label("Target", 18, GOLD))
	goal_box = HBoxContainer.new()
	goal_box.add_theme_constant_override("separation", 8)
	tg.add_child(goal_box)
	hb.add_child(tg)
	var back := _button("‹", NAVY)
	back.position = Vector2(12, 4)
	back.size = Vector2(46, 34)
	back.add_theme_font_size_override("font_size", 22)
	back.pressed.connect(_show_menu)
	hud.add_child(back)
	fps = _label("", 14, Color(0.8, 1, 0.8))
	fps.position = Vector2(250, 8)
	fps.size = Vector2(130, 24)
	fps.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ui.add_child(fps)
	_build_menu()
	_build_end()

func _build_menu() -> void:
	menu = PanelContainer.new()
	menu.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.06, 0.2, 0.96), GOLD, 26))
	menu.position = Vector2(25, 150)
	menu.size = Vector2(340, 560)
	ui.add_child(menu)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	menu.add_child(vb)
	vb.add_child(_label("Crackers Match", 36, GOLD))
	vb.add_child(_label("Godot test: board and blasts", 15, Color(0.85, 0.82, 1.0)))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	vb.add_child(grid)
	for i in levels.size():
		var b := _button("Level %d" % (i + 1), Color(0.75, 0.1, 0.2) if levels[i].get("hard", false) else Color(0.13, 0.55, 0.25))
		b.custom_minimum_size = Vector2(150, 64)
		b.pressed.connect(_start.bind(i))
		grid.add_child(b)
	var lt := _label("Light mode: " + ("on (weak phone)" if lite else "off"), 14, Color(0.8, 0.8, 0.9))
	vb.add_child(lt)

func _build_end() -> void:
	endp = PanelContainer.new()
	endp.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.06, 0.2, 0.96), GOLD, 26))
	endp.position = Vector2(45, 300)
	endp.size = Vector2(300, 220)
	endp.visible = false
	ui.add_child(endp)
	var vb := VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 16)
	endp.add_child(vb)
	end_title = _label("", 34, GOLD)
	vb.add_child(end_title)
	end_btn = _button("Next", Color(0.13, 0.55, 0.25))
	end_btn.custom_minimum_size = Vector2(220, 64)
	end_btn.pressed.connect(_end_pressed)
	vb.add_child(end_btn)
	var lv_b := _button("Levels", NAVY)
	lv_b.custom_minimum_size = Vector2(220, 52)
	lv_b.pressed.connect(_show_menu)
	vb.add_child(lv_b)

func _show_menu() -> void:
	endp.visible = false
	menu.visible = true
	hud.visible = false
	board.visible = false

func _start(i: int) -> void:
	cur = i
	menu.visible = false
	endp.visible = false
	hud.visible = true
	board.visible = true
	board.setup(levels[i])
	sfx.play("swoosh", 0.4)

func _refresh() -> void:
	lbl_level.text = "Level %d" % (cur + 1)
	lbl_moves.text = str(board.moves)
	for ch in goal_box.get_children():
		ch.queue_free()
	var icons := {"crate": "res://art/crate.webp", "steel": "res://art/crate2.webp", "gold": "res://art/goldfloor.webp", "cab": "res://art/sweet0.webp"}
	for k in ["cab", "crate", "steel", "gold"]:
		if not board.goal.has(k):
			continue
		var vb := VBoxContainer.new()
		var tr := TextureRect.new()
		tr.texture = load(icons[k])
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.custom_minimum_size = Vector2(46, 46)
		vb.add_child(tr)
		var n: int = board.goal[k]
		vb.add_child(_label("✓" if n == 0 else str(n), 20, Color(0.6, 1, 0.6) if n == 0 else Color.WHITE))
		goal_box.add_child(vb)

func _on_finished(won: bool) -> void:
	await get_tree().create_timer(0.6).timeout
	end_title.text = "Level Complete!" if won else "Out of Moves"
	end_btn.text = "Next" if won and cur < levels.size() - 1 else "Try Again"
	endp.visible = true
	endp.set_meta("won", won)

func _end_pressed() -> void:
	var won: bool = endp.get_meta("won", false)
	if won and cur < levels.size() - 1:
		_start(cur + 1)
	else:
		_start(cur)

func _process(_dt: float) -> void:
	fps.text = "%d fps%s" % [Engine.get_frames_per_second(), " · light" if lite else ""]

# ---- automated check (desktop only): godot --path . -- --test
func _enter_tree() -> void:
	if "--autotest" in OS.get_cmdline_user_args():
		call_deferred("_auto_test")

func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("user://%s.png" % name)

func _find_move() -> Array:
	for r in Board.R:
		for c in Board.C:
			for d in [Vector2i(0, 1), Vector2i(1, 0)]:
				var a := board.tile_at(r, c)
				var b := board.tile_at(r + d.x, c + d.y)
				if a == null or b == null or not board._free(r, c) or not board._free(r + d.x, c + d.y):
					continue
				if a.k >= 6 or b.k >= 6:
					return [Vector2i(r, c), Vector2i(r + d.x, c + d.y)]
				var t := a.k
				a.k = b.k
				b.k = t
				var ok := not board._find_groups().is_empty()
				b.k = a.k
				a.k = t
				if ok:
					return [Vector2i(r, c), Vector2i(r + d.x, c + d.y)]
	return []

func _auto_test() -> void:
	await get_tree().create_timer(0.5).timeout
	await _shot("t0_menu")
	for li in [0, 9, 8]:
		_start(li)
		await get_tree().create_timer(0.8).timeout
		await _shot("t_l%d_start" % (li + 1))
		var moves_done := 0
		var t0 := Time.get_ticks_msec()
		while moves_done < 40 and not board.over and Time.get_ticks_msec() - t0 < 60000:
			while board.busy:
				await get_tree().process_frame
			var m := _find_move()
			if m.is_empty():
				break
			board.try_swap(m[0], m[1])
			moves_done += 1
			await get_tree().create_timer(0.25).timeout
			if moves_done == 1:
				await _shot("t_l%d_m1" % (li + 1))
		while board.busy:
			await get_tree().process_frame
		await get_tree().create_timer(0.8).timeout
		await _shot("t_l%d_end" % (li + 1))
		print("LEVEL ", li + 1, " moves_done=", moves_done, " over=", board.over, " goal=", board.goal, " moves_left=", board.moves)
	get_tree().quit()
