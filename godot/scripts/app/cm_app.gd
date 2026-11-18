# Crackers Match app: the web game's screens (app.js, Builds 26-30) rebuilt on the captured layouts.
# Game screen (HUD, goals, star bar, cracker meter, booster bar, settings), level card, banners,
# end sequence (CRACKERS MATCH!, leftover rockets, sweep, coins to Reward), win, lose, bonus round,
# buy window, popups, toasts, test ads, hand hints, save file.
extends Node2D

const LAY := preload("res://scripts/ui/weblayout.gd")
const ICN := "res://ui/"

const NAMES := ["Bijli", "Kuruvi", "Hydrogen Bomb", "Twinkling Star", "Snake Tablet", "Bullet Bomb"]
const IDX := {"matchbox": 14, "rocket": 6, "flowerpot": 7, "chakra": 8, "skyshot": 9, "sparkler": 11, "rail": 13, "wala": 12, "atom": 10, "hammer": 17, "seven": 18, "snake": 19}
const SL := ["hammer", "sparkler", "flowerpot", "skyshot", "snake", "rail", "wala", "seven"]
const LBL := {"matchbox": "Colour Matchbox", "rocket": "Rocket", "flowerpot": "Flowerpot", "chakra": "Ground Chakra", "skyshot": "Sky Shot", "sparkler": "Sparkler", "rail": "Rail Cracker", "wala": "1000-Wala", "atom": "Bomb", "hammer": "Lakshmi Vedi Hammer", "seven": "Seven Shot", "snake": "Snake Tablet"}
const PRICE := {"matchbox": 600, "rocket": 100, "flowerpot": 900, "sparkler": 700, "chakra": 200, "rail": 1400, "skyshot": 1600, "wala": 1300, "atom": 300, "hammer": 500, "seven": 1800, "snake": 1100}
const UNL := {"hammer": 5, "sparkler": 10, "flowerpot": 15, "skyshot": 20, "snake": 25, "rail": 30, "wala": 35, "seven": 40}
const SB := ["rocket", "matchbox", "chakra", "atom"]   # in unlock order (Lv 2, 3, 5, 8)
const SBU := {"rocket": 2, "matchbox": 3, "chakra": 5, "atom": 8}
const PACK := {"rocket": 900, "chakra": 1200, "atom": 1500, "matchbox": 1900}
const SBD := {"rocket": "Start the level with a Rocket on the board!", "chakra": "Start the level with a Ground Chakra on the board!", "atom": "Start the level with a Bomb on the board!", "matchbox": "Start the level with a Colour Matchbox on the board!"}
const DESC2 := {"hammer": "Drop it on any tile: clears it and the 4 around it.", "sparkler": "A fork of sparks.", "flowerpot": "Fountain, then 7 fireballs.", "snake": "The ash snake eats 10 tiles.", "wala": "A chain of 15 pops.", "rail": "Runs a row, then back along the next.", "skyshot": "12 stars, 4 on goal tiles.", "seven": "7 comets, 3 on goals, each clears a plus."}
const MOVEP := [950, 1900, 2900]
const FREEAD := {"hammer": 1, "sparkler": 1}
const MMAX := 30
const WORDS := ["Mass!", "Theri!", "Mersal!", "Bigil!"]
const GRP := {15: 6, 16: 6}
const SPK := {6: "rocket", 7: "flowerpot", 8: "chakra", 9: "skyshot", 10: "atom", 11: "sparkler", 12: "wala", 13: "rail", 14: "matchbox", 17: "hammer", 18: "seven", 19: "snake"}
const BAN := {
	"rocket": ["Rocket", "Match 4 in a line. Tap it: it flies and clears the line.", null, 15],
	"flowerpot": ["Flowerpot", "Drag it from the bar. A fountain, then 7 fireballs.", null, 7],
	"chakra": ["Ground Chakra", "Match a 2×2 square. It spins, clears 2×2, then flies to a goal.", null, 8],
	"skyshot": ["Sky Shot", "Drag it from the bar. 12 stars rain down, 4 on goals.", null, 9],
	"hammer": ["Lakshmi Vedi Hammer", "Drag it onto any tile to break it.", null, 17],
	"seven": ["Seven Shot", "Drag it from the bar. 7 shots, 3 aimed at goals.", null, 18],
	"snake": ["Snake Tablet", "Drag it from the bar. The snake coils and eats 10 tiles.", null, 19],
	"atom": ["Bomb", "Match an L or T shape. Short fuse, then a 3×3 blast.", null, 10],
	"sparkler": ["Sparkler", "Drag it from the bar onto a tile.", null, 11],
	"wala": ["1000-Wala", "Drag it from the bar. It pops 15 tiles.", null, 12],
	"rail": ["Rail Cracker", "Drag it from the bar. It races a row and back.", null, 13],
	"matchbox": ["Colour Matchbox", "Match 5 in a line. Swap it with a cracker: lightning lights that whole colour.", null, 14],
	"crate": ["Crates", "Match next to a crate, or blast it, to break it.", "crate", null],
	"steel": ["Steel Crates", "2 hits. The first snaps the steel bands.", "steel", null],
	"gold": ["Gold Floor", "Clear the crackers on the gold tiles to collect them.", "art/goldfloor.webp", null],
	"dpot": ["Clay Diya Pots", "Match next to a pot to break it. Pots stay in place, so dig your way through.", "art/claypot.webp", null],
	"wood": ["Wooden Crates", "Each match beside the crate knocks out one panel. 4 panels to break it.", "art/woodi.webp", null],
	"wall": ["Crate Wall", "Match next to the wall 3 times. It breaks and both diyas fly to your target.", "art/plank.webp", null],
	"hole": ["Hidden Hole", "Break the crates around it. Crackers fall in and fill the hole.", "art/crate.webp", null],
	"helper": ["Helper Bombs", "Bombs are hidden among the crates. Tap one: it blasts and sets off the others!", null, 10],
	"cab_bottles": ["Soda Bottle Cabinet", "A new cabinet! Match next to it to break the glass, then every hit pops one bottle crate.", "art/cab-bottles-door.webp", null],
	"cab_cups": ["Tea Cup Cabinet", "Match next to it. The first hit opens it, then every hit blasts one stack of cups.", "art/cab-cups-door.webp", null],
	"cab_kaapi": ["Kaapi Cabinet", "Filter coffee! Match next to it to open it, then every hit knocks out one kaapi set.", "art/cab-kaapi-door.webp", null],
	"cab": ["Sweet Shop Cabinet", "Match next to it. The first hit breaks the glass doors, then every hit blasts one sweet plate.", "art/cab-door.webp", null],
	"meter": ["Cracker Meter full!", "Every match fills the meter. Drag the special from the meter onto any tile to fire it.", "art/ui-diya.webp", null],
	"howto": ["How to play", "Swap two crackers to line up 3 or more. Line up 4, 5, a square or an L shape to make special crackers. Reach the target before your moves run out.", "art/ui-diya.webp", null],
	"pot": ["Clay Pots", "Match next to a pot, or blast it. One hit and it shatters!", "art/brk/pot_1.png", null],
	"soda": ["Goli Soda", "Match next to a bottle, or blast it. One hit: glass and fizz everywhere!", "art/brk/soda_1.png", null],
	"coco": ["Coconuts", "2 hits. The first cracks it, the second splits it open.", "art/brk/coco_2.png", null],
	"match": ["Matchbox Stacks", "3 hits. Each hit knocks off one box. The last one sparks!", "art/brk/match_3.png", null],
	"news": ["Newspaper Bundles", "2 hits. The first snaps the string, the second blows the papers away.", "art/brk/news_2.png", null],
	"bangle": ["Glass Bangles", "Match next to the stack, or blast it. One hit and the bangles fly!", "art/brk/bangle_1.png", null],
	"gift": ["Gift Parcels", "2 hits. The first tears the paper, the second bursts it open.", "art/brk/gift_2.png", null],
	"dstack": ["Diya Stacks", "Match next to the stack, or blast it. The lamps light up, then break!", "art/brk/diya_1.png", null],
	"diya": ["Bring the Diya Down", "Clear the tiles below it. It must reach the bottom.", "diya", null]}

var S := {}
var save_path := "user://save.json"
var levels: Array = []
var sfx: Sfx
var stage: Control
var G: WebLayout
var game: CMGame
var deb: CMDeb
var f3: CMFly
var face: CMFace
var lite := false
var cur = 0            # level index, or "b" for the bonus round
var BL := {}           # bonus level
var realG := {}
var inflight := {}
var doneG := {}
var tries := {"ad": 0, "coin": 0}
var REW = null
var REWT := 0
var mRew = null
var ending := false
var endMv := 0
var endT: Array = []
var flyers: Array = []
var lastW := -99.0
var wordMv = null
var midAd := false
var lastAct := 0.0
var pick := {}
var card_i := 0
var ban_cb = null
var bcb = null       # buy window options
var drag = null      # {"k": .., "meter": bool}
var ghost: TextureRect
var hand: Control
var hand_tw: Tween
var demo := false
var modal_n := 0
var flyN := 0
var flyLast := -9.0
var gi := {}          # goal key -> {c, img, b, tick}
var gi_keys := ""
var wonC := 0
var win_prev := 0
var gs_open := false

# layouts
var L_card: WebLayout
var L_hard: WebLayout
var L_ban: WebLayout
var LO: LoseUI
var lose_tw: Tween
var L_win: WebLayout
var L_be: WebLayout
var L_bc: WebLayout
var L_buy: WebLayout
var L_got: WebLayout
var L_cm: WebLayout
var L_gset: WebLayout
var L_agree: WebLayout
var L_mrew: WebLayout
var gs_dim: ColorRect
var chakra: AppFx.Chakra
var fw: AppFx.Fireworks
var guy: CMWinGuy
var toast: Control
var toast_t := 0.0
var fly_layer: Control
var top_layer: Control
var fakead: Control
var slot_nodes := {}
var slot_tpl := {}
var stars_on := [false, false, false]
var street: Street
var home_ui: HomeUI
var title_s: TitleScreen
var sky_layer: CanvasLayer
var back: ColorRect

func now() -> float:
	return Time.get_ticks_msec() / 1000.0

# ================================================================== setup
func _ready() -> void:
	randomize()
	levels = Levels.all()
	load_save()
	lite = _weak_phone()
	sfx = Sfx.new()
	add_child(sfx)
	_ads_init()
	var cl := CanvasLayer.new()
	add_child(cl)
	back = ColorRect.new()
	back.color = Color(0.16, 0.05, 0.29)
	back.set_anchors_preset(Control.PRESET_FULL_RECT)
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(back)
	stage = Control.new()
	stage.size = Vector2(390, 844)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(stage)
	_fit()
	get_viewport().size_changed.connect(_fit)
	# the 3D street lives behind everything; its sky is a canvas layer at the very back
	sky_layer = CanvasLayer.new()
	sky_layer.layer = -10
	add_child(sky_layer)
	var sky := TextureRect.new()
	sky.texture = load("res://street/art/sky.png")
	sky.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sky.stretch_mode = TextureRect.STRETCH_SCALE
	sky.set_anchors_preset(Control.PRESET_FULL_RECT)
	sky_layer.add_child(sky)
	street = Street.new()
	street.lite = lite
	add_child(street)
	# Area 1 build costs for 30 levels (35 diyas): rising from 1 to 6
	for i in mini(A1_COST.size(), street.TASKS.size()):
		street.TASKS[i].c = A1_COST[i]
	if int(S.get("area", 1)) == 2:
		street.set_area(2)
	_build_game()
	home_ui = HomeUI.new()
	stage.add_child(home_ui)
	home_ui.build(self, street)
	screens["street"] = home_ui
	fly_layer = _layer("fly")
	_build_overlays()
	top_layer = _layer("top")
	ghost = TextureRect.new()
	ghost.size = Vector2(90, 110)
	ghost.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ghost.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost.visible = false
	top_layer.add_child(ghost)
	var hl := WebLayout.new()
	hand = hl.build("res://ui/hand.json", top_layer)
	hand.visible = false
	_build_toast()
	title_s = TitleScreen.new()
	stage.add_child(title_s)
	stage.move_child(title_s, home_ui.get_index() + 1)
	title_s.build(self)
	title_s.tapped.connect(_title_tapped)
	screens["title"] = title_s
	game.stopped = true
	if Array(OS.get_cmdline_user_args()).any(func(x): return String(x).begins_with("--t=")):
		show_screen("game")
		return
	show_screen("title")
	title_s.play(not S.get("agreed", false))

func _fit() -> void:
	var vs := get_viewport().get_visible_rect().size
	stage.position = Vector2(0, maxf(0.0, (vs.y - 844.0) / 2.0))

func _layer(n: String) -> Control:
	var c := Control.new()
	c.name = n
	c.size = Vector2(390, 844)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(c)
	return c

func _weak_phone() -> bool:
	if FileAccess.file_exists("user://lite"):
		return true
	var mem := OS.get_memory_info()
	var phys: int = mem.get("physical", 0)
	if phys > 0 and phys < 4800000000:
		return true
	var gpu := RenderingServer.get_video_adapter_name().to_lower()
	for w in ["mali-g52", "mali-g51", "mali-g31", "mali-g57 mc2", "mali-t", "powervr", "adreno (tm) 5", "adreno (tm) 4"]:
		if gpu.contains(w):
			return true
	return false

var _ft_n := 0
var _ft_t := 0.0
func _auto_lite(dt: float) -> void:
	if lite or not game.visible or game.stopped:
		return
	if dt < 0.2:
		_ft_n += 1
		_ft_t += dt
	if _ft_n >= 150:
		if _ft_t / _ft_n > 0.024:
			lite = true
			game.lite = true
			deb.lite = true
			f3.lite = true
			var f := FileAccess.open("user://lite", FileAccess.WRITE)
			if f:
				f.store_string("1")
		_ft_n = 0
		_ft_t = 0.0

# ================================================================== save
func load_save() -> void:
	S = {"lv": 0, "coins": 0, "diyas": 0, "best": {}, "inv": {}, "seen": {}, "pend": {}, "ads": {}, "sbGift": {}, "gift28": {}, "bdone": {}}
	if FileAccess.file_exists(save_path):
		var j = JSON.parse_string(FileAccess.get_file_as_string(save_path))
		if j is Dictionary:
			for k in j:
				S[k] = j[k]
	for k in ["best", "inv", "seen", "pend", "ads", "sbGift", "gift28", "bdone"]:
		if not S.get(k) is Dictionary:
			S[k] = {}
	S.lv = int(S.lv)
	S.coins = int(S.coins)

func save() -> void:
	var f := FileAccess.open(save_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(S))

func inv(k: String) -> int:
	return int(S.inv.get(k, 0))

func add_inv(k: String, n: int) -> void:
	S.inv[k] = inv(k) + n

func today() -> String:
	var d := Time.get_date_dict_from_system()
	return "%d-%d-%d" % [d.year, d.month, d.day]

func seen(k: String) -> bool:
	return S.seen.has("b_" + k)

# ================================================================== layout helpers
static func lbl(c: Control) -> Label:
	if c == null:
		return null
	if c.has_node("txt"):
		return c.get_node("txt")
	for ch in c.get_children():
		if ch is Label:
			return ch
	return null

func set_t(c: Control, s: String) -> void:
	var l := lbl(c)
	if l:
		l.text = s
		for ch in l.get_children():
			if ch is Label:
				ch.text = s

# set a label's text and shrink its font until it fits maxw (default: its box width)
func fit_t(c: Control, s: String, maxw := -1.0) -> void:
	set_t(c, s)
	var l := lbl(c)
	if l == null or l.label_settings == null:
		return
	if not l.has_meta("fs0"):
		l.label_settings = l.label_settings.duplicate()
		l.set_meta("fs0", l.label_settings.font_size)
		for ch in l.get_children():
			if ch is Label and ch.label_settings:
				ch.label_settings = ch.label_settings.duplicate()
	var w := maxw if maxw > 0 else maxf(l.size.x, c.size.x)
	var f: Font = l.label_settings.font
	var fs: int = l.get_meta("fs0")
	while fs > 8 and f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + l.label_settings.outline_size > w:
		fs -= 1
	for x in [l] + l.get_children():
		if x is Label and x.label_settings:
			x.label_settings.font_size = fs

static func plural(s: String) -> String:
	return s + ("es" if s.ends_with("x") or s.ends_with("s") else "s")

static func img_of(c: Control) -> TextureRect:
	if c == null:
		return null
	if c.has_node("img"):
		return c.get_node("img")
	return null

# first child element with this web tag (img, b, em, span, div...)
static func kid(c: Control, tag: String, nth := 0) -> Control:
	if c == null:
		return null
	for ch in c.get_children():
		if ch is Control and ch.has_meta("web") and ch.get_meta("web").tag == tag:
			if nth == 0:
				return ch
			nth -= 1
	return null

static func resize_box(c: Control, sz: Vector2) -> void:
	c.size = sz
	var b := boxr(c)
	if b:
		var m := -b.position.x
		b.size = sz + Vector2(m * 2, m * 2)
		b.material.set_shader_parameter("size", sz)

func set_img(c: Control, src: String) -> void:
	var t := img_of(c)
	if t:
		t.texture = WebLayout.tex(src)

static func boxr(c: Control) -> ColorRect:
	for ch in c.get_children():
		if ch is ColorRect and ch.material is ShaderMaterial:
			return ch
	return null

func set_bg(c: Control, col: Color) -> void:
	var b := boxr(c)
	if b:
		b.material.set_shader_parameter("bgc", col)
		b.material.set_shader_parameter("g0_type", 0)
		b.material.set_shader_parameter("g1_type", 0)

# build data[idx] and everything under it as a new copy under `parent`
func sub(lay: WebLayout, idx: int, parent: Control) -> Control:
	var d: Array = lay.data
	var n: Dictionary = d[idx]
	var pr: Array = d[int(n.p)].r if int(n.p) >= 0 else [0, 0]
	var built := {}
	var c := lay.make(n, Vector2(pr[0], pr[1]))
	parent.add_child(c)
	built[idx] = c
	for m in d:
		var mi := int(m.i)
		if mi <= idx:
			continue
		if built.has(int(m.p)):
			var p2: Array = d[int(m.p)].r
			var cc := lay.make(m, Vector2(p2[0], p2[1]))
			built[int(m.p)].add_child(cc)
			built[mi] = cc
	return c

func tap(c: Control, f: Callable, on_press := false) -> void:
	if c == null:
		return
	c.mouse_filter = Control.MOUSE_FILTER_STOP
	c.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and e.pressed == on_press:
			lastAct = now()
			f.call())

func play_anim(c: CanvasItem, n: String, d: float, dl := 0.0, e := "ease", it := 1) -> void:
	Anim.play(c, n, d, dl, e, it)

func icon(k) -> String:
	var s := str(k)
	if s.is_valid_int():
		return "crk:b%d" % int(s)
	match s:
		"crate": return "art/crate.webp"
		"steel": return "art/crate2.webp"
		"gold": return "art/goldfloor.webp"
		"cab": return "ui:img/8ac48ac9b449.png"
		"cab_bottles": return "art/brk/goal_bottles.png"
		"cab_cups": return "art/brk/goal_cups.png"
		"cab_kaapi": return "art/brk/goal_kaapi.png"
		"coin": return "art/ui-coin.webp"
		"hole": return "art/crate.webp"
		"wood": return "art/woodi.webp"
		"diya": return "art/ui-diya.webp"
		"dpot": return "art/claypot.webp"
		"pot", "soda", "coco", "news", "bangle", "gift": return "art/brk/%s_%d.png" % [s, 2 if s in ["coco", "news", "gift"] else 1]
		"match": return "art/brk/match_3.png"
		"dstack": return "art/brk/diya_1.png"
	return "crk:b0"

func goal_name(k) -> String:
	var s := str(k)
	if s.is_valid_int():
		return NAMES[int(s) % NAMES.size()]
	return {"crate": "Crates", "steel": "Steel crates", "gold": "Gold floor", "cab": "Sweet plates", "cab_bottles": "Soda bottles", "cab_cups": "Tea cups", "cab_kaapi": "Kaapi sets", "coin": "Coins", "hole": "Holes", "wood": "Wooden crates", "dpot": "Clay pots", "diya": "Diyas",
		"pot": "Clay pots", "soda": "Soda bottles", "coco": "Coconuts", "match": "Matchboxes", "news": "Newspapers", "bangle": "Bangles", "gift": "Gift parcels", "dstack": "Diya stacks"}.get(s, s)

func LV() -> Dictionary:
	return BL if str(cur) == "b" else levels[int(cur)]

func is_bonus() -> bool:
	return str(cur) == "b"

# ================================================================== screens
var screens := {}
func show_screen(id: String) -> void:
	for k in screens:
		screens[k].visible = k == id
	# the street (3D) shows behind the home screen and the title fades out over it
	var st_on := id == "street"
	if street:
		street.visible = st_on
		street.process_mode = Node.PROCESS_MODE_INHERIT if st_on else Node.PROCESS_MODE_DISABLED
		street.cam.current = st_on
		sky_layer.visible = st_on and street.bazaar == null
		back.visible = not st_on
	if LO and id != "game":
		lose_hide()
	if id != "win":
		if chakra:
			chakra.stop()
		if guy:
			guy.queue_free()
			guy = null
	if fw:
		fw.run(id == "bonusEnd")
	_board_input()

func open_modal(c: Control, on: bool) -> void:
	c.visible = on
	c.mouse_filter = Control.MOUSE_FILTER_STOP if on else Control.MOUSE_FILTER_IGNORE
	_board_input()

func _board_input() -> void:
	if L_card == null or L_agree == null:
		return
	var blocked := gs_open or drag != null or (fakead != null)
	for c in [L_card.root, L_hard.root, L_ban.root, L_buy.root, L_got.root, L_bc.root, L_agree.root]:
		if c.visible:
			blocked = true
	if LO and LO.root.visible:
		blocked = true
	if L_sh and L_sh.root.visible:
		blocked = true
	if not screens.get("game", stage).visible:
		blocked = true
	if game:
		game.set_process_unhandled_input(not blocked)

# ================================================================== game screen
func _build_game() -> void:
	G = WebLayout.new()
	var root := G.build("res://ui/game.json", stage)
	screens["game"] = root
	var bd: Control = G.node("board")
	var bg: Control = G.nodes[1]
	root.move_child(bd, bg.get_index() + 1)
	var dim: Control = G.node("endDim")
	root.move_child(dim, bd.get_index() + 1)
	game = CMGame.new()
	game.sfx = sfx
	game.lite = lite
	bd.add_child(game)
	deb = CMDeb.new()
	deb.lite = lite
	G.node("deb").add_child(deb)
	game.deb = deb
	f3 = CMFly.new()
	f3.lite = lite
	G.node("sp").add_child(f3)
	game.fly3d = f3
	game.visible = true
	game.stopped = true
	# the badge head
	var fc: Control = G.nodes[32]
	face = CMFace.new()
	face.size = fc.size
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fc.add_child(face)
	# strip lights twinkle
	for i in range(4, 18):
		var n: Control = G.nodes[i]
		if n:
			Anim.play(n, "tw2", 2.0, randf() * 2.0, "ease-in-out", -1)
	Anim.play(G.node("meter"), "mg30", 2.4, 0.0, "ease-in-out", -1)
	# goal and slot templates are rebuilt per level
	for c in G.node("gGoals").get_children():
		c.queue_free()
	for c in G.node("slots").get_children():
		c.queue_free()
	G.node("cheer").modulate.a = 0
	G.node("shuf").modulate.a = 0
	G.node("skip").visible = false
	G.node("endDim").modulate.a = 0
	game.moves_changed.connect(_on_moves)
	game.goal_changed.connect(hud)
	game.score_changed.connect(sbar)
	game.level_won.connect(level_done)
	game.level_lost.connect(lost)
	game.fly.connect(fly)
	game.cheer.connect(cheer)
	game.big.connect(func():
		face.mood("wow", 1.3)
		pop_face())
	game.meter.connect(_on_meter)
	tap(G.node("bQuit"), func():
		sfx.play("swoosh", 0.4, 1.5)
		quit_level())
	tap(G.node("gGear"), func():
		sfx.play("swoosh", 0.4, 1.5)
		gset(true))
	tap(G.node("mRew"), _meter_drag, true)
	tap(G.node("skip"), func():
		if ending and game.over:
			end_off()
			won(endMv))
	# meter "on" look (mrew.json)
	L_mrew = WebLayout.new()
	L_mrew.data = JSON.parse_string(FileAccess.get_file_as_string("res://ui/mrew.json"))

func pop_face() -> void:
	Anim.play(G.nodes[29], "badge2", 0.5, 0.0, "ease-out")

func quit_level() -> void:
	if game:
		game.stopped = true
	end_off()
	home()

func start(i) -> void:
	cur = i
	var L0: Dictionary
	if is_bonus():
		L0 = BL
	else:
		L0 = CMGame.make_level(levels[int(i)], int(i))
	face.calm()
	face.mood("idle")
	doneG = {}
	inflight = {}
	tries = {"ad": 0, "coin": 0}
	wordMv = null
	midAd = false
	REW = null
	mRew = null
	mFills = 0
	G.node("cheer").modulate.a = 0
	lastW = now()
	lastAct = now()
	hide_hand()
	end_off()
	# chapter background: levels 1-10 scene 1, 11-20 scene 2, ...
	var ch: int = (int(BL.after) - 1 if is_bonus() else int(i)) / 10 + 1
	var sn: int = [1, 2, 1, 2, 1][(ch - 1) % 5]
	var bgi: Control = G.nodes[1]
	if bgi.has_node("bgimg"):
		(bgi.get_node("bgimg") as TextureRect).texture = load("res://ui/img/blur9_scene%d-s.webp" % sn)
	show_screen("game")
	set_t(G.node("gMoves"), str(L0.moves))
	set_t(G.node("gName"), "BONUS" if is_bonus() else "LEVEL %d" % (int(i) + 1))
	G.node("sbar").visible = not is_bonus()
	realG = {}
	for k in L0.goal:
		realG[str(k)] = L0.goal[k]
	gi_keys = ""
	slots()
	sfx.mus_start()
	sfx.duck(0.3)
	stars_on = [false, false, false]
	sbar(0)
	_moves_low(false)
	game.start(L0)
	game.gspeed = [1.2, 1.65, 2.2][clampi(int(S.get("speed", 1)) - 1, 0, 2)]
	game.mN = 0
	meter_ui(0)
	draw_hud()
	S.pend = {}
	save()
	if not is_bonus():
		var lvN := int(i) + 1
		for k in SL:
			if UNL[k] == lvN and not S.gift28.has(k):
				S.gift28[k] = 1
				add_inv(k, 3)
				save()
				slots()
				_after(0.9, func():
					toast28("3 free %s! Drag one onto the board." % plural(LBL[k]))
					drag_demo(k))

func _after(t: float, f: Callable) -> void:
	get_tree().create_timer(t).timeout.connect(f)

# ---------------------------------------------------------------- HUD: goals
func draw_hud() -> void:
	var gg: Control = G.node("gGoals")
	var small: Control = G.nodes[21]
	var items := {}
	if REW != null:
		set_t(small, "REWARD")
		items["rew"] = [icon("coin"), str(REW)]
	elif is_bonus():
		set_t(small, "COINS")
		var got: int = (int(BL.goal.coin) - maxi(0, int(realG.get("coin", 0)))) - int(inflight.get("coin", 0))
		items["coin"] = [icon("coin"), str(got * int(BL.val))]
	else:
		set_t(small, "TARGET")
		for k in realG:
			var v: int = maxi(0, int(realG[k])) + int(inflight.get(k, 0))
			items[k] = [icon(k), str(v) if v > 0 else ""]
	var keys := ",".join(items.keys())
	if keys != gi_keys:
		gi_keys = keys
		for c in gg.get_children():
			c.queue_free()
		gi = {}
		var n := items.size()
		var w := minf(54.0, 108.0 / maxf(1, n))
		var x0 := (108.0 - w * n) / 2.0
		var j := 0
		for k in items:
			var c := sub(G, 23, gg)
			c.position = Vector2(x0 + j * w, 0)
			c.size.x = w
			c.pivot_offset = c.size / 2
			var im: Control = kid(c, "img")
			var iw := minf(46.0, w)
			im.size = Vector2(iw, 46)
			im.position.x = (w - iw) / 2.0
			var it := img_of(im)
			if it:
				it.size = im.size
				it.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			var bb: Control = kid(c, "b")
			bb.position.x = w - bb.size.x + 1
			var tk := AppFx.Tick.new(bb.size, Color.WHITE, 2.6)
			bb.add_child(tk)
			gi[k] = {"c": c, "im": im, "b": bb, "tick": tk, "ok": null}
			j += 1
	for k in items:
		var e: Dictionary = gi[k]
		set_img(e.im, items[k][0])
		var ok: bool = items[k][1] == ""
		set_t(e.b, items[k][1])
		e.tick.visible = ok
		if e.ok != ok:
			e.ok = ok
			set_bg(e.b, Color("#22C55E") if ok else Color.WHITE)
			if ok:
				Anim.play(e.b, "tk", 0.45, 0.0, "cubic-bezier(.2,1.8,.4,1)")
		# pulse when only 1-2 are left
		if REW == null and not is_bonus():
			var v: int = int(realG.get(k, 0)) - int(inflight.get(k, 0))
			var last: bool = v > 0 and v <= 2
			if last != e.c.get_meta("last", false):
				e.c.set_meta("last", last)
				if last:
					Anim.play(e.c, "glast", 0.9, 0.0, "ease-in-out", -1)
				else:
					Anim.stop(e.c, true)

func hud(g: Dictionary) -> void:
	realG = {}
	for k in g:
		realG[str(k)] = g[k]
	var before := doneG.size()
	draw_hud()
	for k in realG:
		if int(realG[k]) <= 0 and not int(inflight.get(k, 0)) > 0 and not doneG.has(k):
			doneG[k] = 1
			sfx.chime(2)
			face.mood("cheer", 1.5)
	if doneG.size() != before:
		pop_face()

# a goal piece flies from the board to its goal icon
func fly(k, x: float, y: float) -> void:
	var key := str(k)
	if not gi.has(key):
		return
	var el: Control = gi[key].c
	var tgt := el.get_global_rect().get_center() - stage.global_position
	tgt.y -= 8
	var sx := x
	var sy := y + 120
	var im := _img_node(icon(key), Vector2(60, 60))
	im.position = Vector2(sx - 30, sy - 30)
	fly_layer.add_child(im)
	var t := now()
	flyN = 0 if t - flyLast > 0.3 else flyN + 1
	flyLast = t
	var d := tgt - Vector2(sx, sy)
	inflight[key] = int(inflight.get(key, 0)) + 1
	draw_hud()
	var st := {"n": 0.0}
	var done_f := func():
		inflight[key] = int(inflight.get(key, 0)) - 1
		draw_hud()
		if gi.has(key):
			Anim.play(gi[key].c, "gbump", 0.32, 0.0, "ease-out")
		if int(realG.get(key, 0)) <= 0 and int(inflight.get(key, 0)) <= 0 and not doneG.has(key):
			doneG[key] = 1
			sfx.play("tick")
	var tick_f := func(n: Control, dt: float):
		st.n += dt
		if st.n > 0.06:
			st.n = 0.0
			var p := n.position + Vector2(22, 22)
			game.spark(p.x, p.y - 120, 2, ["#FFD24A", "#FFFFFF"], 90)
	fly_go(im, [[0.0, Vector2.ZERO, 0.9, 0.0], [0.22, Vector2(0, -34), 1.35, 0.0], [0.6, Vector2(d.x * 0.55, d.y * 0.45 - 30), 1.15, 0.0], [1.0, d, 0.62, 0.0]], 0.78, flyN * 0.07, "ease-in", done_f, tick_f)

func _img_node(src: String, sz: Vector2) -> TextureRect:
	var im := TextureRect.new()
	im.texture = WebLayout.tex(src)
	im.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	im.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	im.size = sz
	im.pivot_offset = sz / 2
	im.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return im

# keyframe flight like element.animate(): kf = [[offset, translate, scale, rot_deg]], easing over the whole run
func fly_go(n: Control, kf: Array, d: float, dl: float, e: String, done: Callable = Callable(), tick: Callable = Callable()) -> void:
	flyers.append({"n": n, "base": n.position, "kf": kf, "d": d, "dl": dl, "t": 0.0, "e": Anim.ease_fn(e), "done": done, "tick": tick})
	_fly_apply(flyers[-1], 0.0)

func _fly_apply(f: Dictionary, p: float) -> void:
	var kf: Array = f.kf
	var a = kf[0]
	var b = kf[-1]
	for i in range(1, kf.size()):
		if p <= kf[i][0]:
			a = kf[i - 1]
			b = kf[i]
			break
	var u: float = (p - a[0]) / maxf(b[0] - a[0], 1e-5)
	u = clampf(u, 0.0, 1.0)
	var n: Control = f.n
	n.position = f.base + (a[1] as Vector2).lerp(b[1], u)
	var s: float = lerpf(a[2], b[2], u)
	n.scale = Vector2(s, s)
	n.rotation = deg_to_rad(lerpf(a[3], b[3], u))

func _flyers(dt: float) -> void:
	if flyers.is_empty():
		return
	for f in flyers.duplicate():
		if not is_instance_valid(f.n):
			flyers.erase(f)
			continue
		f.t += dt
		var t: float = f.t - f.dl
		if t < 0:
			continue
		var p := minf(1.0, t / f.d)
		var e: Array = f.e
		_fly_apply(f, Anim.bez(p, e[0], e[1], e[2], e[3]))
		if f.tick.is_valid():
			f.tick.call(f.n, dt)
		if p >= 1.0:
			flyers.erase(f)
			f.n.queue_free()
			if f.done.is_valid():
				f.done.call()

# ---------------------------------------------------------------- HUD: moves, stars, cheer words
func _on_moves(m: int) -> void:
	set_t(G.node("gMoves"), str(m))
	if m <= 3 and m > 0:
		face.mood("worried", 9)
	else:
		face.mood("smile", 0.9)
	_moves_low(m <= 5 and m > 0)
	if m <= 5 and m > 0:
		face.mood("worried", 2)

func _moves_low(on: bool) -> void:
	var c: Control = G.node("gMoves")
	var l := lbl(c)
	if l == null:
		return
	if c.get_meta("low", false) == on:
		return
	c.set_meta("low", on)
	if not c.has_meta("col0"):
		c.set_meta("col0", l.label_settings.font_color)
	l.label_settings.font_color = Color("#FF4B4B") if on else c.get_meta("col0")
	if on:
		Anim.play(c, "beat2", 0.8, 0.0, "ease-in-out", -1)
	else:
		Anim.stop(c, true)

func sbar(v) -> void:
	if is_bonus() or levels.is_empty():
		return
	var T: float = float(LV().moves) * 380.0
	var k := minf(1.0, float(v) / T)
	var fill: Control = G.node("sFill")
	resize_box(fill, Vector2(270.0 * k, fill.size.y))
	for j in 3:
		var st: Control = G.nodes[39 + j]
		var on: bool = k >= [0.3, 0.6, 1.0][j]
		if on == stars_on[j]:
			continue
		stars_on[j] = on
		var l := lbl(st)
		if l:
			l.label_settings.font_color = Color("#FFB400") if on else Color("#E6DCCB")
		st.pivot_offset = st.size / 2
		create_tween().tween_property(st, "scale", Vector2.ONE * (1.2 if on else 1.0), 0.3)
		if on and float(v) > 0:
			sfx.chime(j)
			face.mood("smile")

func cheer(c: int) -> void:
	if c >= 3:
		face.mood("grin", 1.6)
	elif c >= 2:
		face.mood("wow", 1.2)
	if c >= 3:
		word(c - 3)
	if c >= 2:
		pop_face()

func word(i: int) -> void:
	if wordMv != null and int(wordMv) - game.moves < 3:
		return
	var t := now()
	if t - lastW < 3.5:
		return
	lastW = t
	wordMv = game.moves
	var e: Control = G.node("cheer")
	var l := lbl(e)
	if l == null:
		var cl := WebLayout.new()
		var cd: Array = JSON.parse_string(FileAccess.get_file_as_string("res://ui/cheer.json"))
		l = WebLayout.label(cd[0].txt, Vector2(390, 64))
		l.name = "txt"
		e.size = Vector2(390, 64)
		e.add_child(l)
		WebLayout.apply_filter(l, cd[0].get("filt", ""))
	l.text = WORDS[mini(i, 3)]
	e.modulate.a = 1
	e.set_meta("base", [e.position, Vector2.ONE, 0.0, 1.0])
	Anim.play(e, "ch", 1.1, 0.0, "ease", 1, true)
	_after(1.15, func(): e.modulate.a = 0)

# ---------------------------------------------------------------- cracker meter
func _on_meter(n: int) -> void:
	if mRew != null or ending or mFills >= 2:
		return
	meter_ui(n)
	if n >= m_need():
		game.mN = 0
		mFills += 1
		mRew = mk28()
		meter_ui(m_need())
		sfx.play("swoosh", 0.4, 1.6)
		if not S.seen.has("meter_done"):
			_meter_rep = false
			_after(0.7, meter_demo)

# 18 Nov: the meter gave rewards too often. Each fill in a level needs 50% more than the last, at most 2 rewards
# per level, and mostly Rocket / Bomb; Chakra and Colour Matchbox are rare.
var mFills := 0
func m_need() -> int:
	return int(round(MMAX * (1.0 + 0.5 * mFills)))

func mk28() -> String:
	var n: int = (int(cur) if not is_bonus() else S.lv) + 1
	var W := {"rocket": 50.0}
	if n >= 8: W["atom"] = 35.0
	if n >= 3: W["matchbox"] = 7.0
	if n >= 5: W["chakra"] = 8.0
	var tot := 0.0
	for k in W: tot += W[k]
	var x := randf() * tot
	for k in W:
		x -= W[k]
		if x <= 0.0:
			return k
	return "rocket"

func meter_ui(n: int) -> void:
	var f := 1.0 if mRew != null else minf(float(n) / m_need(), 1.0)
	var fill: Control = G.node("mFill")
	resize_box(fill, Vector2(118.0 * f, fill.size.y))
	var mi: Control = G.node("mImg")
	set_img(mi, "crk:b%d" % IDX[mRew if mRew != null else "rocket"])
	var on := mRew != null
	mi.modulate.a = 1.0 if on else 0.25
	var it := img_of(mi)
	if it:
		if on:
			it.material = null
		elif it.material == null:
			WebLayout.apply_filter(it, "grayscale(1)")
	var r: Control = G.node("mRew")
	if on:
		Anim.play(r, "mr30", 0.8, 0.0, "ease-in-out", -1)
	else:
		Anim.stop(r, true)

func _meter_drag() -> void:
	if mRew == null or game.busy or game.over:
		return
	_start_drag({"k": mRew, "meter": true})

# ---------------------------------------------------------------- booster bar
func locked(k: String) -> bool:
	return UNL.has(k) and maxi(int(S.lv), int(cur) if not is_bonus() else 0) + 1 < UNL[k]

func slots() -> void:
	var sl: Control = G.node("slots")
	for c in sl.get_children():
		c.queue_free()
	slot_nodes = {}
	for i in SL.size():
		var k: String = SL[i]
		var n := inv(k)
		var c: Control
		if locked(k):
			c = sub(G, 57, sl)
			set_t(c.get_child(c.get_child_count() - 1), "Lv %d" % UNL[k])
			_grey_locked(c, kid(c, "img"), kid(c, "i"))
		else:
			c = sub(G, 54, sl)
			var pr: Control = c.get_child(c.get_child_count() - 1)
			if n > 0:
				pr.visible = false
				var bg := AppFx.badge(str(n), Color("#E8123C"), Vector2(22, 22), WebLayout.font("TitanOne"), 12, 11)
				bg.position = Vector2(c.size.x - 25, 3)
				c.add_child(bg)
				kid(c, "img").modulate.a = 1.0
			else:
				set_t(pr, str(PRICE[k]))
		c.position = Vector2(12 + (i % 4) * 93, 702 + (i / 4) * 68) - sl.position
		set_img(kid(c, "img"), "crk:b%d" % IDX[k])
		var kk := k
		tap(c, func(): _slot_down(kk), true)
		slot_nodes[k] = c
	set_t(G.node("gCoins"), str(S.coins))

func _slot_down(k: String) -> void:
	if game.busy or game.over or ending:
		return
	if locked(k):
		sfx.play("nope")
		return
	if inv(k) <= 0:
		ask_buy(k)
		return
	_start_drag({"k": k, "meter": false})

# the picture floats above the finger so it is not hidden; the cracker lands on the tile under the PICTURE
# (its centre), shown by a gold glow. Near a tile the picture snaps onto it. Let go off the board: it flies back.
const LIFT := Vector2(0, -62)
var drop_hl: Panel
var drag_src := Vector2.ZERO
func _drop_cell(p: Vector2):
	if game == null:
		return null
	var lp: Vector2 = p + LIFT - G.node("board").position
	var c := game.cell_at(lp)
	var e = game.at2(c[0], c[1])
	if e == null:
		return null
	return c

func _show_target(c) -> void:
	if drop_hl == null:
		drop_hl = Panel.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(1, 0.85, 0.3, 0.28)
		sb.border_color = Color("#FFD23F")
		sb.set_border_width_all(3)
		sb.set_corner_radius_all(10)
		sb.shadow_color = Color(1, 0.8, 0.2, 0.6)
		sb.shadow_size = 10
		drop_hl.add_theme_stylebox_override("panel", sb)
		drop_hl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		top_layer.add_child(drop_hl)
		top_layer.move_child(drop_hl, 0)
	if c == null:
		drop_hl.visible = false
		return
	var U: float = game.U
	drop_hl.visible = true
	drop_hl.size = Vector2(U, U)
	drop_hl.position = G.node("board").position + Vector2(game.cx(c[1]), game.cy(c[0])) - Vector2(U, U) / 2.0

func _start_drag(d: Dictionary) -> void:
	stop_demo()
	var src: Control = G.node("mRew") if d.meter else slot_nodes.get(d.k, G.node("mRew"))
	drag_src = src.get_global_rect().get_center() - stage.global_position
	drag = d
	ghost.texture = WebLayout.tex("crk:b%d" % IDX[d.k])
	ghost.visible = true
	_ghost_to(stage.get_local_mouse_position())
	_board_input()

func _ghost_to(p: Vector2) -> void:
	var at := p + LIFT
	var c = _drop_cell(p) if drag != null else null
	if c != null:
		# magnet: pull the picture towards the target tile's centre
		var cc: Vector2 = G.node("board").position + Vector2(game.cx(c[1]), game.cy(c[0]))
		at = at.lerp(cc, 0.55)
	_show_target(c)
	ghost.position = at - ghost.size / 2.0

func _end_drag(p: Vector2) -> void:
	var d = drag
	var c = _drop_cell(p)
	drag = null
	_show_target(null)
	_board_input()
	if d == null:
		ghost.visible = false
		return
	var ok := false
	if c != null:
		if d.meter:
			if game.meter_pop(d.k, c[0], c[1]):
				ok = true
				mRew = null
				meter_ui(0)
				if not S.seen.has("meter_done"):
					S.seen["meter_done"] = 1
					save()
		elif game.place(d.k, c[0], c[1]):
			ok = true
			S.inv[d.k] = inv(d.k) - 1
			save()
			slots()
	if ok:
		ghost.visible = false
		return
	# missed the board: the cracker flies back home
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(ghost, "position", drag_src - ghost.size / 2.0, 0.28)
	tw.parallel().tween_property(ghost, "scale", Vector2.ONE * 0.6, 0.28)
	tw.tween_callback(func():
		ghost.visible = false
		ghost.scale = Vector2.ONE)

func drop(k: String) -> void:
	var L: Array = []
	for row in game.b:
		for e in row:
			if e != null and e.k < 6 and e.k >= 0 and not e.has("ob") and not e.get("diya", false):
				L.append(e)
	if L.is_empty():
		return
	var e = L[randi() % L.size()]
	e.k = IDX[k]
	e.shakeT = 0.4
	sfx.play("tick", 0.5)

# the hand drags a new booster from the bar onto the board, twice
func drag_demo(k: String) -> void:
	if not slot_nodes.has(k):
		return
	_drag_demo_from(slot_nodes[k], k)

# first full Cracker Meter (no banner): the hand presses the cracker in the meter and drags it onto the board,
# twice. If the player waits 5 s with the cracker still there, once more. Any touch stops it. Never again after
# the player has dragged a meter cracker once (S.seen.meter_done).
var _meter_rep := false
func meter_demo() -> void:
	if mRew == null or drag != null or demo or game == null or game.over or ending or S.seen.has("meter_done"):
		return
	toast28("Drag the cracker onto the board!")
	_drag_demo_from(G.node("mRew"), mRew, true)

var demo_tw: Tween
func stop_demo() -> void:
	if not demo:
		return
	if demo_tw:
		demo_tw.kill()
	demo = false
	if drag == null:
		ghost.visible = false
	hand.visible = false
	hand.scale = Vector2.ONE

func _drag_demo_from(sl: Control, k: String, press := false) -> void:
	var a := sl.get_global_rect().get_center() - stage.global_position
	var bpos := Vector2(195, game.cy(4) + 120)
	ghost.texture = WebLayout.tex("crk:b%d" % IDX[k])
	demo = true
	var tw := create_tween()
	demo_tw = tw
	for n in 2:
		tw.tween_callback(func():
			hand.visible = true
			hand.position = a - Vector2(10, 10)
			ghost.visible = not press)
		if press:
			# touch: the hand presses the cracker, then picks it up
			tw.tween_property(hand, "scale", Vector2.ONE * 0.82, 0.18)
			tw.tween_property(hand, "scale", Vector2.ONE, 0.14)
			tw.tween_callback(func(): ghost.visible = true)
		tw.tween_method(func(p: float):
			var e := 2 * p * p if p < 0.5 else 1 - pow(-2 * p + 2, 2) / 2
			var x := a.lerp(bpos, e)
			ghost.position = x + LIFT - ghost.size / 2.0
			hand.position = x - Vector2(10, 10), 0.0, 1.0, 1.1)
		tw.tween_interval(0.35)
	tw.tween_callback(func():
		demo = false
		if drag == null:
			ghost.visible = false
		hand.visible = false)

# ================================================================== buy window
func _build_buy() -> void:
	L_buy = WebLayout.new()
	L_buy.build("res://ui/buy.json", stage)
	L_buy.root.visible = false
	tap(L_buy.node("buyN"), func(): open_modal(L_buy.root, false))
	tap(L_buy.node("buyY"), func():
		var o = bcb
		if o == null:
			return
		open_modal(L_buy.root, false)
		if S.coins < o.price:
			toast28("Shop opens from the street (coming next)")
			return
		o.buy.call()
		sfx.play("fanfare", 0.4)
		_coins_ui())
	tap(L_buy.node("buyA"), func():
		var o = bcb
		if o == null or o.ad == null:
			return
		open_modal(L_buy.root, false)
		game.paused = true
		show_ad(func(ok: bool):
			game.paused = false
			if ok:
				o.ad.call()))

func show_buy(o: Dictionary) -> void:
	bcb = o
	set_img(L_buy.node("buyI"), o.img)
	set_t(L_buy.node("buyT"), o.title)
	var bp: Control = L_buy.node("buyP")
	set_t(bp, o.text)
	set_t(L_buy.nodes[6], "You have %d coins" % S.coins)
	var ok: bool = S.coins >= int(o.price)
	_coin_text(L_buy.node("buyY"), "Buy  " if ok else "Get coins", str(o.price) if ok else "")
	L_buy.node("buyA").visible = o.get("ad") != null
	ad_pad(L_buy.node("buyA"))
	open_modal(L_buy.root, true)
	sfx.play("swoosh", 0.5)

# button text with a coin picture before the number ("Buy [coin]500")
func _coin_text(c: Control, pre: String, num: String) -> void:
	var l := lbl(c)
	if l == null:
		return
	var ci: TextureRect = c.get_node_or_null("coinx")
	if num == "":
		l.text = pre
		if ci:
			ci.visible = false
		return
	var f: Font = l.label_settings.font
	var fs := l.label_settings.font_size
	var cs := fs * 0.85
	var gap := " "
	while f.get_string_size(gap, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x < cs + 12:
		gap += " "
	l.text = pre + gap + num
	var w_all := f.get_string_size(l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var w_pre := f.get_string_size(pre, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var w_gap := f.get_string_size(gap, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	if ci == null:
		ci = _img_node("art/ui-coin.webp", Vector2(cs, cs))
		ci.name = "coinx"
		c.add_child(ci)
	ci.visible = true
	ci.size = Vector2(cs, cs)
	var x0 := l.position.x + (l.size.x - w_all) / 2.0
	ci.position = Vector2(x0 + w_pre + (w_gap - cs) / 2.0, l.position.y + (l.size.y - cs) / 2.0)

# a pill sized to its text (web inline-block with padding), kept centred where it was
func fit_pill(c: Control, s: String) -> void:
	var l := lbl(c)
	if l == null:
		return
	var f: Font = l.label_settings.font
	var fs := l.label_settings.font_size
	if not c.has_meta("pill"):
		c.set_meta("pill", [c.size.x - f.get_string_size(l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x, c.position.x + c.size.x / 2.0])
	var pm: Array = c.get_meta("pill")
	l.text = s
	var w: float = f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + pm[0]
	c.position.x = pm[1] - w / 2.0
	resize_box(c, Vector2(w, c.size.y))
	l.size.x = w
	l.position.x = 0
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

# "[AD] text" buttons: the badge and the text are centred together
func ad_pad(c: Control, use_img := false, other: Control = null) -> void:
	var l := lbl(c)
	var ad: Control = kid(c, "img") if use_img else other
	for ch in c.get_children():
		if ch is Control and ch.has_meta("web") and String(ch.get_meta("web").get("cls", "")).begins_with("adb"):
			ad = ch
	if l == null or ad == null:
		return
	var f: Font = l.label_settings.font
	var tw := f.get_string_size(l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, l.label_settings.font_size).x
	var tot := ad.size.x + 5.0 + tw
	var x0 := (c.size.x - tot) / 2.0
	ad.position.x = x0
	l.position.x = x0 + ad.size.x + 5.0
	l.size.x = tw + 4
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

func _coins_ui() -> void:
	set_t(G.node("gCoins"), str(S.coins))
	set_t(L_card.node("lCoins"), str(S.coins))
	set_t(L_hard.node("lCoins"), str(S.coins))

func ask_buy(k: String) -> void:
	var ad: bool = FREEAD.has(k) and not midAd
	var buy_f := func():
		S.coins -= PRICE[k]
		add_inv(k, 1)
		save()
		slots()
	var ad_f := func():
		midAd = true
		add_inv(k, 1)
		save()
		slots()
		sfx.play("fanfare", 0.4)
	show_buy({"img": "crk:b%d" % IDX[k], "title": LBL[k], "text": DESC2.get(k, ""), "price": PRICE[k], "buy": buy_f, "ad": ad_f if ad else null})

# ================================================================== overlays
func _build_overlays() -> void:
	L_cm = WebLayout.new()
	L_cm.build("res://ui/cm.json", stage)
	L_cm.root.visible = false
	for sp in _cm_spans():
		var l := lbl(sp)
		var deep: Array = []
		for ch in l.get_children():
			if ch is Label:
				deep.append(ch)
		for ch in deep:
			var w: Label = ch.duplicate()
			var ws: LabelSettings = ch.label_settings.duplicate()
			ws.outline_size = 7
			ws.outline_color = Color.WHITE
			w.label_settings = ws
			w.name = "w" + ch.name
			l.add_child(w)
			l.move_child(w, 0)
	# level card (normal and hard look)
	L_card = WebLayout.new()
	L_card.build("res://ui/card.json", stage)
	L_hard = WebLayout.new()
	L_hard.build("res://ui/card_hard.json", stage)
	for L in [L_card, L_hard]:
		L.root.visible = false
		Anim.play(L.nodes[1], "spin2", 40.0, 0.0, "linear", -1)
		tap(L.node("lClose"), func():
			sfx.play("swoosh", 0.4)
			open_modal(L.root, false)
			_card_closed())
		tap(L.node("lPlay"), _card_play)
		# 52px taller card: room (and air above) for the wide Golden Matchbox slot under the boosters
		for ix in [2, 3, 4, 5]:
			resize_box(L.nodes[ix], L.nodes[ix].size + Vector2(0, 52))
		L.node("lPlay").position.y += 52
		tap(L.node("lAd"), _card_ad)
		ad_pad(L.node("lAd"))
	# lose / failed / win / bonus end are full screens
	L_win = WebLayout.new()
	screens["win"] = L_win.build("res://ui/win.json", stage)
	L_be = WebLayout.new()
	screens["bonusEnd"] = L_be.build("res://ui/bonusEnd.json", stage)
	for k in ["win", "bonusEnd"]:
		screens[k].visible = false
		screens[k].mouse_filter = Control.MOUSE_FILTER_STOP
	# out of moves / level failed: a card over the dimmed board (agreed design, 13 Nov)
	LO = LoseUI.new()
	LO.build(stage)
	tap(LO.n["bAd"], func():
		set_t(LO.n["lMsg"], "Loading video...")
		show_ad(func(ok: bool):
			if ok:
				tries.ad += 1
				set_t(LO.n["lMsg"], "")
				resume(5)
			else:
				set_t(LO.n["lMsg"], "No video right now. Try again soon.")))
	tap(LO.n["bCoin"], func():
		if tries.coin >= MOVEP.size():
			return
		var p: int = MOVEP[tries.coin]
		if S.coins < p:
			set_t(LO.n["lMsg"], "Not enough coins. You have %d." % S.coins)
			sfx.play("nope")
			return
		S.coins -= p
		save()
		tries.coin += 1
		resume(5))
	tap(LO.n["bGive"], func():
		lose_step(2)
		sfx.play("swoosh", 0.4))
	tap(LO.n["bRetry"], func():
		lose_hide()
		game.stopped = true
		open_card(int(cur)))
	tap(LO.n["bHome"], func():
		lose_hide()
		game.stopped = true
		home())
	# win
	chakra = AppFx.Chakra.new()
	L_win.node("fxA").add_child(chakra)
	chakra.stop()
	# the BLASTUU! arc title and the ribbon were SVG text; pre-rendered pictures are used instead
	var sv: Control = L_win.nodes[8]
	for ch in sv.get_children():
		ch.visible = false
	var box2: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://ui/img/win_svg.json"))
	for k in ["ribA", "tA"]:
		var r: Array = box2[k]
		var tr := _img_node("ui:img/win_%s.png" % k, Vector2(r[2], r[3]))
		tr.stretch_mode = TextureRect.STRETCH_SCALE
		tr.position = Vector2(r[0], r[1])
		tr.pivot_offset = Vector2(195.0 - r[0], (170.0 if k == "tA" else 660.0) - r[1])
		tr.name = k
		sv.add_child(tr)
	var ca: Control = L_win.nodes[10]
	if lbl(ca):
		lbl(ca).position.x = 181
		lbl(ca).size.x = 22
	var wc: Control = L_win.node("wCoins")
	wc.size.x = 90
	lbl(wc).size.x = 90
	lbl(wc).horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	ad_pad(L_win.nodes[18])
	tap(L_win.node("bNext"), _win_next)
	tap(L_win.node("bX2"), _win_x2)
	# bonus end
	fw = AppFx.Fireworks.new()
	fw.sfx = sfx
	L_be.node("wfx").add_child(fw)
	tap(L_be.node("beNext"), func():
		fw.run(false)
		next_level())
	# bonus card
	L_bc = WebLayout.new()
	L_bc.build("res://ui/bc30.json", stage)
	L_bc.root.visible = false
	ad_pad(L_bc.nodes[7], false, L_bc.nodes[8])
	# banners
	L_ban = WebLayout.new()
	L_ban.build("res://ui/ban.json", stage)
	L_ban.root.visible = false
	tap(L_ban.root, ban_done)
	_build_buy()
	# popups
	L_got = WebLayout.new()
	L_got.build("res://ui/got28.json", stage)
	L_got.root.visible = false
	tap(L_got.root, func(): open_modal(L_got.root, false))
	# in-game settings
	gs_dim = ColorRect.new()
	gs_dim.color = Color(0.05, 0.02, 0.12, 0.5)
	gs_dim.size = Vector2(390, 844)
	gs_dim.visible = false
	stage.add_child(gs_dim)
	tap(gs_dim, func(): gset(false))
	L_gset = WebLayout.new()
	L_gset.build("res://ui/gset.json", stage)
	L_gset.root.visible = false
	var acts := {1: "exit", 4: "info", 7: "mus", 10: "snd", 13: "vib", 16: "spd", 19: "x"}
	for i in acts:
		var a: String = acts[i]
		tap(L_gset.nodes[i], func(): _gs(a))
	# first open
	L_agree = WebLayout.new()
	L_agree.build("res://ui/agree.json", stage)
	L_agree.root.visible = false
	_build_sheets()
	# "By playing you agree to our Privacy Policy and Terms of Use." as one centred line with gold links
	var agl: Control = L_agree.nodes[5]
	for ch in agl.get_children():
		if ch is Control and ch.has_meta("web"):
			ch.visible = false
	if lbl(agl):
		lbl(agl).visible = false
	var rt := RichTextLabel.new()
	rt.bbcode_enabled = true
	rt.fit_content = true
	rt.scroll_active = false
	rt.add_theme_font_override("normal_font", WebLayout.font("Sora-500"))
	rt.add_theme_font_size_override("normal_font_size", 15)
	rt.add_theme_color_override("default_color", Color(UISkin.TEXT))
	rt.text = "[center]By playing you agree to our [color=#C8102E][u]Privacy Policy[/u][/color] and [color=#C8102E][u]Terms of Use[/u][/color].[/center]"
	rt.size = agl.size
	rt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	agl.add_child(rt)
	L_buy.nodes[6].position.y += 6
	_skin_all()



# every popup window in the street Welcome look (Skin)
func _skin_all() -> void:
	UISkin.card(L_buy.nodes[1])
	UISkin.button(L_buy.node("buyY"), "yellow")
	UISkin.button(L_buy.node("buyA"), "red")
	UISkin.button(L_buy.node("buyN"), "white")
	UISkin.card(L_agree.nodes[1])
	UISkin.button(L_agree.node("agY"), "red")
	UISkin.card(L_bc.nodes[1])
	set_bg(L_bc.nodes[7], Color(UISkin.DARK))
	UISkin.button(L_bc.node("bcGo"), "red")
	UISkin.card(L_be.nodes[4])
	UISkin.button(L_be.node("beNext"), "red")
	UISkin.card(L_got.nodes[1])
	UISkin.card(L_ban.nodes[1])
	for L in [L_card, L_hard]:
		# level card: the arch head, stars and PLAY stay; the inside becomes the cream card
		UISkin.reskin(L.nodes[4], {"bg": [UISkin.lin([[0, "#fffdf2"], [1, "#ffefc4"]])], "rad": [22, 22, 22, 22]})
		L.nodes[5].visible = false
		UISkin.reskin(L.nodes[7], {"bgc": UISkin.rgba("#FFF3D6"), "rad": [18, 18, 18, 18], "bw": [2, 2, 2, 2], "bcol": UISkin.rgba("#E8C98A")})
		if L == L_card:
			set_bg(L.nodes[6], Color(UISkin.DARK))
		for nd in L.root.find_children("*", "Control", true, false):
			var w: Dictionary = nd.get_meta("web", {})
			var l := lbl(nd)
			if l == null or l.label_settings == null:
				continue
			if String(w.get("cls", "")).begins_with("lab2"):
				UISkin.text_label(l, UISkin.DARK)
			elif w.get("tag", "") == "small" and nd.get_parent() == L.nodes[7]:
				UISkin.text_label(l, UISkin.TEXT)

# cream cards (16 Nov, 21:30): every popup window uses the cream look of the Welcome card
const CREAM := Color("#FFF8EE")
const INK := Color("#1F1B3A")
const INK2 := Color("#4B4668")

func cream_card(card: Control) -> void:
	set_bg(card, CREAM)
	_ink(card)

func _ink(c: Control) -> void:
	for ch in c.get_children():
		if not ch is Control:
			continue
		var w: Dictionary = ch.get_meta("web", {})
		var cls: String = w.get("cls", "")
		if w.get("tag", "") == "button" or cls.begins_with("adb") or cls.contains("rib") or boxr(ch) != null:
			continue
		var l := lbl(ch)
		if l and l.label_settings:
			var ls: LabelSettings = l.label_settings
			if ls.font_color.get_luminance() > 0.6:
				ls.font_color = INK if ls.font_size >= 22 else INK2
				ls.shadow_color = Color(0, 0, 0, 0)
				ls.outline_size = 0
		_ink(ch)

# level card: keep the pink arch, stars and PLAY; the inside becomes cream
func cream_inner(C: WebLayout) -> void:
	set_bg(C.nodes[4], CREAM)
	C.nodes[5].visible = false
	set_bg(C.nodes[7], Color("#F3E6D2"))
	if C == L_card:
		set_bg(C.nodes[6], Color("#6B3A7A"))
	for nd in C.root.find_children("*", "Control", true, false):
		var w: Dictionary = nd.get_meta("web", {})
		var cls: String = w.get("cls", "")
		var l := lbl(nd)
		if l == null or l.label_settings == null:
			continue
		if cls.begins_with("lab2"):
			l.label_settings.font_color = Color("#8A6A4A")
		elif w.get("tag", "") == "small" and nd.get_parent() == C.nodes[7]:
			l.label_settings.font_color = INK
			l.label_settings.shadow_color = Color(0, 0, 0, 0)

# the game theme for the remaining white cards (16 Nov): raised gold frame, dark purple inside,
# headings in the logo gold, other text light lilac (same as the Out of Moves card)
func theme_card(card: Control) -> void:
	var bx := boxr(card)
	if bx:
		bx.visible = false
	var lay := WebLayout.new()
	var sz := card.size
	var fr := lay.make({"i": 0, "id": "", "tag": "div", "r": [0, 0, sz.x, sz.y], "op": 1, "box": {"bg": [LoseUI.lin(160, [[0, "#fff3c0"], [0.3, "#e9b23a"], [0.65, "#9a6210"], [1, "#f7d878"]])],
		"rad": [26, 26, 26, 26], "sh": [LoseUI.sh(0, 6, 0, "#5e3a07"), LoseUI.sh(0, 18, 40, "#000000cc")]}}, Vector2.ZERO)
	var inn := lay.make({"i": 0, "id": "", "tag": "div", "r": [3, 3, sz.x - 6, sz.y - 6], "op": 1, "box": {"bg": [LoseUI.lin(180, [[0, "#3a1866"], [0.6, "#24104a"], [1, "#1b0b38"]])], "rad": [23, 23, 23, 23],
		"sh": [LoseUI.sh(0, 2, 0, "#ffffff22", true), LoseUI.sh(0, -3, 8, "#00000088", true)]}}, Vector2.ZERO)
	card.add_child(fr)
	card.move_child(fr, 0)
	card.add_child(inn)
	card.move_child(inn, 1)
	_theme_text(card)

func _theme_text(c: Control) -> void:
	for ch in c.get_children():
		if not ch is Control:
			continue
		var w: Dictionary = ch.get_meta("web", {})
		var cls: String = w.get("cls", "")
		if w.get("tag", "") == "button" and not cls.contains("ghost"):
			continue
		if cls.begins_with("adb") or cls.contains("ribbon"):
			continue
		var l := lbl(ch)
		if l and l.label_settings:
			var col: Color = l.label_settings.font_color
			if col.get_luminance() < 0.45:
				var ls: LabelSettings = l.label_settings
				if ls.font_size >= 24:
					ls.font_color = Color("#f6c445")
					ls.shadow_color = Color("#8a5300")
					ls.shadow_offset = Vector2(0, 3)
					ls.shadow_size = 1
				else:
					ls.font_color = Color("#c9b6ea")
		_theme_text(ch)

# ---------------------------------------------------------------- toast and popups
func _build_toast() -> void:
	toast = Control.new()
	toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast.modulate.a = 0
	top_layer.add_child(toast)

func toast28(m: String) -> void:
	for c in toast.get_children():
		c.queue_free()
	var d: Array = JSON.parse_string(FileAccess.get_file_as_string("res://ui/t28.json"))
	var n: Dictionary = d[0]
	var f := WebLayout.font(n.txt.font)
	# 18 Nov: always centred on the screen, text centred in the box, long text wraps to 2 lines
	var w := f.get_string_size(m, HORIZONTAL_ALIGNMENT_LEFT, -1, int(n.txt.fs)).x + 48.0
	var two := w > 360.0
	w = minf(w, 360.0)
	var h: float = n.r[3] + (int(n.txt.fs) * 1.25 if two else 0.0)
	n.r = [195.0 - w / 2.0, 150.0, w, h]
	n.erase("tf")
	n.txt.s = m
	n.txt.ta = "center"
	var lay := WebLayout.new()
	var c := lay.make(n, Vector2.ZERO)
	toast.add_child(c)
	for l in c.find_children("*", "Label", true, false):
		var lb := l as Label
		lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lb.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if two else TextServer.AUTOWRAP_OFF
		lb.position = Vector2(12, 0)
		lb.size = Vector2(w - 24, h)
	toast_t = 2.6
	toast.position.y = -10
	var tw := create_tween().set_parallel()
	tw.tween_property(toast, "modulate:a", 1.0, 0.25)
	tw.tween_property(toast, "position:y", 0.0, 0.25)

func popup(t: String, rows: Array) -> void:
	set_t(L_got.node("gotT"), t)
	var gl: Control = L_got.node("gotL")
	for c in gl.get_children():
		c.queue_free()
	for i in rows.size():
		var r: Array = rows[i]
		var c := sub(L_got, 4, gl)
		c.position.y = i * 72.0
		set_img(kid(c, "img"), r[0])
		var tx: Control = kid(c, "div")
		set_t(kid(tx, "b"), r[1])
		set_t(kid(tx, "span"), r[2])
	var box: Control = L_got.nodes[1]
	var extra := (rows.size() - 1) * 72.0
	box.position.y = 332 - extra / 2.0
	resize_box(box, Vector2(box.size.x, 179 + extra))
	if box.has_node("skin"):
		resize_box(box.get_node("skin"), box.size)
	for c in gl.get_children():
		set_bg(c, Color("#FFF3D6"))
		var tx: Control = kid(c, "div")
		if tx:
			if lbl(kid(tx, "b")):
				UISkin.text_label(lbl(kid(tx, "b")), UISkin.DARK)
			if lbl(kid(tx, "span")):
				UISkin.text_label(lbl(kid(tx, "span")), UISkin.TEXT)
	L_got.nodes[9].position.y = 146 + extra
	open_modal(L_got.root, true)
	Anim.play(box, "g28", 0.35, 0.0, "ease-out")
	sfx.play("fanfare", 0.4)

# ---------------------------------------------------------------- rewarded ads (AdMob through the CMAds Android plugin; a short test card elsewhere)
var ads: Object = null
var ad_cb: Callable

func _ads_init() -> void:
	if Engine.has_singleton("CMAds"):
		ads = Engine.get_singleton("CMAds")
		ads.connect("ad_done", _ad_done)
		ads.init()

func _ad_done(ok: bool) -> void:
	sfx.duck(0.3)
	var cb := ad_cb
	ad_cb = Callable()
	_board_input()
	if not ok:
		_after(0.05, func(): toast28("No video right now. Try again soon."))
	if cb.is_valid():
		cb.call(ok)

func show_ad(cb: Callable) -> void:
	if ads:
		toast28("Loading video...")
		ad_cb = cb
		sfx.duck(0.0)
		ads.showAd()
		return
	toast28("Loading video...")
	fakead = ColorRect.new()
	(fakead as ColorRect).color = Color(0, 0, 0, 0.85)
	fakead.size = Vector2(390, 844)
	fakead.mouse_filter = Control.MOUSE_FILTER_STOP
	top_layer.add_child(fakead)
	var l := Label.new()
	var ls := LabelSettings.new()
	ls.font = WebLayout.font("TitanOne")
	ls.font_size = 44
	l.label_settings = ls
	l.size = Vector2(390, 844)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fakead.add_child(l)
	_board_input()
	var st := {"n": 3}
	l.text = "Test ad\n3"
	var tm := Timer.new()
	tm.wait_time = 0.7
	fakead.add_child(tm)
	tm.timeout.connect(func():
		st.n -= 1
		l.text = "Test ad\n%d" % st.n
		if st.n <= 0:
			tm.stop()
			fakead.queue_free()
			fakead = null
			_board_input()
			cb.call(true))
	tm.start()

# ================================================================== level card
func open_card(i: int) -> void:
	card_i = i
	pick = {}
	var lvd: Dictionary = levels[i]
	var L := CMGame.make_level(lvd, i)
	var hard: bool = L.ltype == "h" or L.ltype == "s"
	var C := L_hard if hard else L_card
	(L_card if hard else L_hard).root.visible = false
	var hb: Control = C.node("lNum")
	set_t(hb.get_child(hb.get_child_count() - 1), str(i + 1))
	if hard:
		set_t(C.node("lName"), "Super Hard" if L.ltype == "s" else "Hard")
		var hn := lbl(C.node("lName"))
		if hn:
			hn.position.x = 0
			hn.size.x = C.node("lName").size.x
			hn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			for ch in hn.get_children():
				if ch is Label:
					ch.size.x = hn.size.x
					ch.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		fit_pill(C.node("lName"), String(lvd.name))
	set_t(C.node("lMoves"), "%d moves" % int(lvd.moves))
	# goals: 62 wide, 6 apart, centred
	var lg: Control = C.node("lGoals")
	var tpl: int = 10
	for c in lg.get_children():
		c.queue_free()
	var ks: Array = L.goal.keys()
	var n := ks.size()
	var tot := n * 62.0 + (n - 1) * 6.0
	lg.position.x = (300.0 - tot) / 2.0
	lg.size.x = tot
	for j in n:
		var c := sub(C, tpl, lg)
		c.position = Vector2(j * 68.0, 0)
		set_img(kid(c, "img"), icon(ks[j]))
		set_t(kid(c, "b"), str(L.goal[ks[j]]))
	var nw := false
	for k in lvd.get("intro", []):
		if not seen(k):
			nw = true
	var ln: Control = C.node("lNew")
	if ln:
		ln.visible = nw
		if nw:
			Anim.play(ln, "wob2", 2.0, 0.0, "ease-in-out", -1)
	if hard:
		var tg: Control = C.node("lTag")
		set_t(tg, "+%d" % (150 if L.ltype == "s" else 100))
		ad_pad(tg, true)
	boosters(C)
	open_modal(C.root, true)
	# entry animations (.sw)
	var hang: Control = C.nodes[2]
	Anim.play(hang, "pop2", 0.55, 0.0, "cubic-bezier(.3,1.5,.5,1)")
	Anim.play(C.nodes[7], "rise2", 0.45, 0.3)
	var head: Control = C.node("lNum").get_parent()
	Anim.play(head, "drop2", 0.6, 0.12, "cubic-bezier(.3,1.6,.5,1)")
	var lp: Control = C.node("lPlay")
	Anim.play(lp, "popb2", 0.5, 0.6, "cubic-bezier(.3,1.7,.5,1)")
	for ch in lp.get_children():
		for g in ch.get_children():
			if lbl(g) and lbl(g).text == "PLAY":
				Anim.play(g, "beat2", 1.4, 1.3, "ease-in-out", -1)
	for ch in head.get_children():
		if ch.get_meta("web", {}).get("cls", "").begins_with("st2"):
			if not ch.has_meta("star"):
				ch.set_meta("star", 1)
				var bx := boxr(ch)
				if bx:
					bx.visible = false
				ch.add_child(AppFx.Star.new(ch.size))
			Anim.play(ch, "tw2", 1.6, randf(), "ease-in-out", -1)
	sfx.play("swoosh", 0.6)
	if hard:
		var sk: Control = C.node("lSkull")
		Anim.play(sk, "sk30", 0.7, 0.25, "cubic-bezier(.3,1.6,.5,1)")
		_after(1.0, func():
			if C.root.visible:
				Anim.play(sk, "skg30", 1.8, 0.0, "ease-in-out", -1))
		_after(0.3, func():
			sfx.play("thud", 1.0, 0.45)
			var x0 := hang.position.x
			var tw := create_tween()
			for dx in [-7, 7, -4, 0]:
				tw.tween_property(hang, "position:x", x0 + dx, 0.095))

# a locked booster: its cracker shows in clear grey, a small gold lock sits in the top-left corner
func _grey_locked(c: Control, im: Control, lk: Control) -> void:
	if im:
		var it := img_of(im)
		if it:
			WebLayout.apply_filter(it, "grayscale(1) brightness(1.05)")
		im.modulate.a = 0.9
	if lk:
		lk.scale = Vector2.ONE * 0.62
		lk.pivot_offset = Vector2.ZERO
		lk.position = Vector2(3, 3)

func sb_locked(k: String) -> bool:
	return int(S.lv) < SBU[k]

func gift_sb() -> void:
	var ch := false
	for k in SB:
		if not sb_locked(k) and not S.sbGift.has(k):
			S.sbGift[k] = 1
			add_inv(k, 2)
			ch = true
			var kk: String = k
			_after(0.75, func(): toast28("New! 2 free %s" % plural(LBL[kk])))
	if ch:
		save()

# tapped: "" = the card just opened (every booster pops in); otherwise only that booster reacts
func boosters(C: WebLayout, tapped := "") -> void:
	var first := tapped == ""
	gift_sb()
	set_t(C.node("lCoins"), str(S.coins))
	var lb: Control = C.node("lBoost")
	var hard := C == L_hard
	# template button indexes: with a count / with a price / gold
	var t_have: int = 31 if hard else 22
	var t_buy: int = 39 if hard else 30
	for c in lb.get_children():
		c.queue_free()
	var xs := [1, 79, 155, 233]
	for i in SB.size():
		var k: String = SB[i]
		var n := inv(k)
		var c: Control
		if sb_locked(k):
			c = sub(C, t_buy, lb)
			var em: Control = kid(c, "em")
			set_t(em, "Lv %d" % SBU[k])
			if kid(em, "img"):
				kid(em, "img").visible = false
			set_bg(em, Color("#D92B3A"))
			var lk := sub(G, 59, c)
			_grey_locked(c, kid(c, "img"), lk)
			var kl := k
			tap(c, func():
				sfx.play("nope")
				toast28("%s unlocks at Level %d" % [LBL[kl], SBU[kl]]))
		elif n > 0:
			c = sub(C, t_have, lb)
			set_t(kid(c, "b"), str(n))
			if pick.has(k):
				_pick_mark(c)
			var kk := k
			tap(c, func():
				if pick.has(kk):
					pick.erase(kk)
				else:
					pick[kk] = true
				sfx.play("tick", 0.5)
				boosters(C, kk))
		else:
			c = sub(C, t_buy, lb)
			var em2: Control = kid(c, "em")
			set_t(em2, str(PACK[k]))
			var kk := k
			var buy_f := func():
				S.coins -= PACK[kk]
				add_inv(kk, 3)
				pick[kk] = true
				save()
				boosters(C, kk)
			tap(c, func(): show_buy({"img": "crk:b%d" % IDX[kk], "title": LBL[kk] + " ×3", "text": SBD[kk], "price": PACK[kk], "ad": null, "buy": buy_f}))
		c.position = Vector2(xs[i], 0)
		set_img(kid(c, "img"), "crk:b%d" % IDX[k])
		if first:
			Anim.play(c, "pin2", 0.4, 0.0, "cubic-bezier(.3,1.6,.5,1)")
		elif k == tapped:
			c.pivot_offset = c.size / 2
			c.scale = Vector2.ONE * 0.86
			create_tween().tween_property(c, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# golden matchbox, locked until level 100: its own wide, shiny slot so it is noticed
	var gold := _gold_slot(lb, first, Vector2(1, 96))
	tap(gold, func():
		sfx.play("nope")
		toast28("The Golden Matchbox unlocks at Level 100!"))
	var a: Control = C.node("lAd")
	a.visible = not sb_locked("rocket") and S.ads.get("card", "") != today()

func _gold_slot(parent: Control, pop: bool, at: Vector2) -> Control:
	# Golden Matchbox, locked until Lv 100: a dark royal card with a gold frame, turning light rays behind the
	# matchbox, a "LEGENDARY" tag, a shine sweep and twinkles, so it stands apart from the cream card.
	var W := 298.0
	var H := 66.0
	var root := Control.new()
	root.size = Vector2(W, H)
	root.position = at
	parent.add_child(root)
	var glow := TextureRect.new()
	glow.texture = AppFx.grad_tex([0.0, 0.6, 1.0], [Color(1, 0.8, 0.25, 0.7), Color(1, 0.6, 0.1, 0.22), Color(1, 0.5, 0, 0)], true)
	glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow.stretch_mode = TextureRect.STRETCH_SCALE
	glow.size = Vector2(W + 70, H + 56)
	glow.position = Vector2(-35, -28)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(glow)
	var gt := glow.create_tween().set_loops()
	gt.tween_property(glow, "modulate:a", 0.4, 0.9).set_trans(Tween.TRANS_SINE)
	gt.tween_property(glow, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)
	var bx := WebLayout.box({"bg": [UISkin.lin([[0, "#5A1468"], [0.55, "#3A0B4A"], [1, "#22062E"]])], "rad": [18, 18, 18, 18],
		"bw": [3, 3, 3, 3], "bcol": UISkin.rgba("#FFD23F"), "sh": [UISkin.sh(0, 0, 0, "#8A5A00", false), UISkin.sh(0, 4, 0, "#2A0A12"), UISkin.sh(0, 0, 16, "#FFC83F")]}, Vector2(W, H))
	bx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bx)
	var clip := Control.new()
	clip.clip_contents = true
	clip.size = Vector2(W - 6, H - 6)
	clip.position = Vector2(3, 3)
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(clip)
	var rays := AppFx.Rays.new()
	rays.size = Vector2(120, 120)
	rays.position = Vector2(-22, -30)
	rays.col = Color(1, 0.78, 0.3, 0.32)
	clip.add_child(rays)
	var shine := TextureRect.new()
	shine.texture = AppFx.grad_tex([0.0, 0.5, 1.0], [Color(1, 1, 1, 0), Color(1, 0.95, 0.8, 0.5), Color(1, 1, 1, 0)], false, Vector2(0, 0.5), Vector2(1, 0.5))
	shine.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shine.size = Vector2(40, H * 1.9)
	shine.rotation = 0.35
	shine.position = Vector2(-80, -H * 0.45)
	shine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.add_child(shine)
	var st := shine.create_tween().set_loops()
	st.tween_property(shine, "position:x", W + 40, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	st.tween_interval(1.6)
	st.tween_callback(func(): shine.position.x = -80)
	var ic := TextureRect.new()
	ic.texture = WebLayout.tex("crk:b14")
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.size = Vector2(60, 60)
	ic.position = Vector2(8, 3)
	ic.pivot_offset = Vector2(30, 30)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(ic)
	var it := ic.create_tween().set_loops()
	it.tween_property(ic, "scale", Vector2.ONE * 1.08, 0.8).set_trans(Tween.TRANS_SINE)
	it.tween_property(ic, "scale", Vector2.ONE, 0.8).set_trans(Tween.TRANS_SINE)
	for p in [Vector2(58, 2), Vector2(4, 46), Vector2(W - 22, 40), Vector2(W - 64, 4)]:
		var tw := Label.new()
		tw.text = "\u2726"
		var ls := LabelSettings.new()
		ls.font_size = 13
		ls.font_color = Color(1, 0.92, 0.6)
		tw.label_settings = ls
		tw.position = p
		tw.pivot_offset = Vector2(6, 9)
		tw.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(tw)
		var t2 := tw.create_tween().set_loops()
		t2.tween_interval(randf() * 0.9)
		t2.tween_property(tw, "scale", Vector2.ONE * 1.5, 0.45)
		t2.tween_property(tw, "scale", Vector2.ONE * 0.3, 0.6)
	var t := Label.new()
	t.text = "Golden Matchbox"
	var tl := LabelSettings.new()
	tl.font = WebLayout.font("TitanOne")
	tl.font_size = 21
	tl.font_color = Color("#FFD23F")
	tl.outline_size = 6
	tl.outline_color = Color("#5A2A00")
	t.label_settings = tl
	t.position = Vector2(76, 6)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(t)
	var sub_l := Label.new()
	sub_l.text = "Legendary cracker  \u00b7  Level 100"
	var sl := LabelSettings.new()
	sl.font = WebLayout.font("Sora-700")
	sl.font_size = 11
	sl.font_color = Color(1, 0.93, 0.8, 0.9)
	sub_l.label_settings = sl
	sub_l.position = Vector2(98, 38)
	sub_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(sub_l)
	var lk := sub(G, 59, root)
	lk.scale = Vector2.ONE * 0.55
	lk.pivot_offset = Vector2.ZERO
	lk.position = Vector2(77, 36)
	lk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# LEGENDARY tag on the corner
	var tag := AppFx.badge("LEGENDARY", Color("#E8123C"), Vector2(78, 18), WebLayout.font("Sora-800"), 9, 9, 2)
	tag.position = Vector2(W - 70, -9)
	tag.rotation = 0.08
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(tag)
	if pop:
		Anim.play(root, "pin2", 0.4, 0.2, "cubic-bezier(.3,1.6,.5,1)")
	return root

func _pick_mark(c: Control) -> void:
	var ring := Panel.new()
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.49, 0.94, 0.54, 0.25)
	st.border_color = Color("#4ADE80")
	st.set_border_width_all(3)
	st.set_corner_radius_all(16)
	st.anti_aliasing = true
	ring.add_theme_stylebox_override("panel", st)
	ring.size = c.size + Vector2(6, 6)
	ring.position = Vector2(-3, -3)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(ring)
	var ok := AppFx.badge("", Color("#22C55E"), Vector2(22, 22), WebLayout.font("Sora-700"), 13, 11, 2)
	ok.position = Vector2(-4, -4)
	ok.add_child(AppFx.Tick.new(Vector2(22, 22), Color.WHITE, 2.4))
	c.add_child(ok)

func _card_ad() -> void:
	show_ad(func(ok: bool):
		if not ok:
			toast28("No video right now. Try again soon.")
			return
		S.ads["card"] = today()
		add_inv("rocket", 1)
		pick["rocket"] = true
		save()
		boosters(L_hard if L_hard.root.visible else L_card)
		sfx.play("fanfare", 0.4))

func _card_play() -> void:
	open_modal(L_card.root, false)
	open_modal(L_hard.root, false)
	var lvd: Dictionary = levels[card_i]
	var Q: Array = []
	for k in lvd.get("intro", []):
		if not seen(k):
			Q.append(k)
	var use: Array = []
	for k in SB:
		if pick.has(k) and inv(k) > 0:
			use.append(k)
	run_banners(Q, func():
		start(card_i)
		for j in use.size():
			var k: String = use[j]
			S.inv[k] = inv(k) - 1
			_after(0.5 + j * 0.25, func():
				if game and not game.over:
					drop(k))
		save()
		pick = {})

func _card_closed() -> void:
	# the card's X goes home (from the street it simply closes)
	if not screens.street.visible:
		home()

# ================================================================== banners
func banner(k: String, cb) -> void:
	S.seen["b_" + k] = 1
	save()
	var b: Array = BAN[k]
	var src: String
	if b[3] != null:
		src = "crk:b%d" % int(b[3])
	elif String(b[2]).begins_with("art"):
		src = b[2]
	else:
		src = icon(b[2])
	_show_ban(src, b[0], b[1], cb)
	sfx.play("tick", 0.6)

func _show_ban(src: String, title: String, line: String, cb) -> void:
	set_img(L_ban.node("bImg"), src)
	set_t(L_ban.node("bTitle"), title)
	set_t(L_ban.node("bLine"), line)
	_fit_ban()
	ban_cb = cb if cb is Callable and cb.is_valid() else func(): pass
	open_modal(L_ban.root, true)
	Anim.play(L_ban.nodes[1], "binm", 0.3, 0.0, "cubic-bezier(.2,1.3,.4,1)")

# the web sized the title box for "Bomb": give it the card width, wrap the line, and grow the card to fit
func _fit_ban() -> void:
	var card: Control = L_ban.nodes[1]
	var ti: Control = L_ban.node("bTitle")
	var ln: Control = L_ban.node("bLine")
	var sm: Control = L_ban.nodes[5]
	if not card.has_meta("h0"):
		card.set_meta("h0", card.size.y)
	var W := card.size.x
	ti.position.x = 14
	ti.size.x = W - 28
	var tl := lbl(ti)
	if tl:
		tl.position.x = 0
		tl.size.x = W - 28
		tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		for ch in tl.get_children():
			if ch is Label:
				ch.size.x = tl.size.x
				ch.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fit_t(ti, lbl(ti).text if tl else "", W - 32)
	var ll := lbl(ln)
	if ll == null:
		return
	ln.position.x = 24
	ln.size.x = W - 48
	ll.position = Vector2.ZERO
	ll.size = Vector2(W - 48, 10)
	ll.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ll.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ll.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	var th := float(maxi(1, ll.get_line_count()) * ll.get_line_height())
	ll.size.y = th
	ln.size.y = th
	sm.position.y = ln.position.y + th + 10
	var h := maxf(float(card.get_meta("h0")), sm.position.y + sm.size.y + 24)
	resize_box(card, Vector2(W, h))

func ban_done() -> void:
	if ban_cb == null:
		return
	open_modal(L_ban.root, false)
	var f: Callable = ban_cb
	ban_cb = null
	f.call()

func run_banners(Q: Array, done: Callable) -> void:
	if Q.is_empty():
		done.call()
		return
	for k in Q.slice(1):
		S.seen["b_" + k] = 1
	banner(Q[0], done)

func new_sp() -> bool:
	if ending:
		return false
	for s in game.specials():
		var id: int = GRP.get(s.k, s.k)
		if SPK.has(id) and not seen(SPK[id]):
			banner(SPK[id], Callable())
			return true
	return false

# ================================================================== hand hint
func show_hand(h) -> void:
	if h == null or game == null:
		return
	var x: float = game.cx(h.c) - 22
	var y: float = game.cy(h.r) + 120 - 6
	hand.visible = true
	hand.position = Vector2(x, y)
	hand.pivot_offset = Vector2(36, 44)
	if hand_tw:
		hand_tw.kill()
	hand_tw = create_tween().set_loops()
	var U: float = game.U
	if h.has("tap"):
		hand_tw.tween_property(hand, "scale", Vector2.ONE * 0.82, 0.35)
		hand_tw.tween_property(hand, "scale", Vector2.ONE, 0.35)
	else:
		var to := Vector2(x + h.get("dc", 0) * U, y + h.get("dr", 0) * U)
		hand_tw.tween_callback(func():
			hand.position = Vector2(x, y)
			hand.modulate.a = 1)
		hand_tw.tween_property(hand, "position", to, 0.84)
		hand_tw.tween_property(hand, "modulate:a", 0.0, 0.36)

func hide_hand() -> void:
	if demo:
		return
	if hand:
		hand.visible = false
		hand.scale = Vector2.ONE
		hand.modulate.a = 1
	if hand_tw:
		hand_tw.kill()
		hand_tw = null

var _tick_t := 0.0
func _ticker() -> void:
	# resting(): no cracker moving and nothing queued (busy can stay up while a glow effect plays out)
	if game == null or game.b.is_empty() or game.stopped or not game.resting() or game.over or not screens.game.visible or L_ban.root.visible or ending:
		return
	if new_sp():
		hide_hand()
		return
	var idle := now() - lastAct
	if mRew != null and not _meter_rep and not demo and not S.seen.has("meter_done") and idle > 5.0:
		_meter_rep = true
		meter_demo()
		return
	var L := LV()
	if not hand.visible and not is_bonus():
		var want := false
		if int(cur) == 0:
			want = int(L.moves) - game.moves < 3
		else:
			want = (L.get("teach") != null or L.get("combo") != null) and int(L.moves) - game.moves < 1
		# level 1: the hand shows straight away for the first move, then after a short pause
		var wait := 0.3 if (int(cur) == 0 and game.moves == int(L.moves)) else 0.9
		if want and idle > wait:
			show_hand(game.hint_move())
			return
	if idle > 10.0:
		game.show_hint()

# ================================================================== end of level
func later(t: float, f: Callable) -> void:
	endT.append([t, f])

func _later_tick(dt: float) -> void:
	if endT.is_empty():
		return
	var due: Array = []
	for e in endT:
		e[0] -= dt
		if e[0] <= 0:
			due.append(e)
	for e in due:
		endT.erase(e)
	for e in due:
		e[1].call()

func end_off() -> void:
	endT.clear()
	ending = false
	var d: Control = G.node("endDim")
	d.modulate.a = 0
	L_cm.root.visible = false
	var sk: Control = G.node("skip")
	sk.visible = false
	Anim.stop(sk, true)
	for f in flyers.duplicate():
		if is_instance_valid(f.n):
			f.n.queue_free()
	flyers.clear()
	for c in fly_layer.get_children():
		c.queue_free()
	inflight = {}

var end_t0 := 0.0
func level_done(mv: int) -> void:
	if is_bonus():
		game.stopped = true
		_after(0.6, bonus_end)
		return
	if ending:
		return
	endMv = mv
	ending = true
	end_t0 = now()
	game.no_match = true
	hide_hand()
	sfx.play("fanfare", 0.85)
	face.calm()
	face.mood("cheer", 4)
	pop_face()
	later(0.5, func():
		create_tween().tween_property(G.node("endDim"), "modulate:a", 1.0, 0.35)
		lift_music())
	later(0.75, func():
		_cm_in()
		sfx.play("swoosh", 0.6))
	later(2.9, func():
		_cm_out()
		create_tween().tween_property(G.node("endDim"), "modulate:a", 0.0, 0.35)
		var sk: Control = G.node("skip")
		sk.visible = true
		sk.modulate.a = 0.9
		sk.mouse_filter = Control.MOUSE_FILTER_STOP
		Anim.play(sk, "beat2", 1.2, 0.0, "ease-in-out", -1)
		REW = 0
		REWT = 30 + mv * 5
		draw_hud()
		leftover(mv))

func _cm_spans() -> Array:
	var a: Array = []
	for w in ["w1", "w2"]:
		for s in L_cm.node(w).get_children():
			if lbl(s):
				a.append(s)
	return a

func _cm_in() -> void:
	L_cm.root.visible = true
	var sp := _cm_spans()
	for i in sp.size():
		var s: Control = sp[i]
		var d0 := 0.0 if i < 8 else 0.2
		var j := i if i < 8 else i - 8
		Anim.stop(s, true)
		s.modulate.a = 0
		s.set_meta("base", [s.position, Vector2.ONE, 0.0, 1.0])
		Anim.play(s, "flyIn2", 0.45, d0 + j * 0.045, "cubic-bezier(.3,1.6,.5,1)")
	Anim.play(L_cm.nodes[2], "ovalIn2", 0.4, 0.5, "cubic-bezier(.3,1.7,.5,1)")
	Anim.play(L_cm.nodes[1], "grpSettle2", 2.3, 0.0, "ease-out")

func _cm_out() -> void:
	var sp := _cm_spans()
	for i in sp.size():
		var s: Control = sp[i]
		var n := 8 if i < 8 else 6
		var j := i if i < 8 else i - 8
		var vars := {"sx": int((j - n / 2.0) * 28 + (randf() - 0.5) * 40), "sy": int(-80 - randf() * 120), "sr": int((randf() - 0.5) * 90)}
		Anim.play(s, "scatter2", 0.45, i * 0.02, "ease-in", 1, true, vars)
	Anim.play(L_cm.nodes[2], "ovalOut2", 0.25, 0.0, "ease-in")
	later(0.8, func(): L_cm.root.visible = false)

func lift_music() -> void:
	sfx.duck(0.42)
	sfx.play("atom", 0.7, 1.0, 0.0, 1.2, 0.1)
	sfx.play("lakshmi", 0.6, 0.85)
	var beat := 0.627
	for i in range(1, 9):
		var ii := i
		later(beat * i, func():
			if not ending:
				return
			sfx.play("thud", 0.55 if ii % 2 else 0.85, 0.8 if ii % 2 else 0.62)
			if ii % 4 == 0:
				sfx.play("lakshmi", 0.35, 1.1, 0.0, 0.4))
	later(0.5, func(): _if_end("finale", 0.5, 0.0, 0.0))
	later(2.2, func(): _if_end("skyshot", 0.4, 0.0, 0.3))
	later(3.4, func(): _if_end("wala", 0.35, 0.0, 0.1))
	later(6.5, func(): sfx.duck(0.3))

func _stage_pos(c: Control) -> Vector2:
	return c.get_global_rect().get_center() - stage.global_position

# leftover moves become rockets that fly onto the board
func leftover(mv: int) -> void:
	var n := mini(mv, 15)
	var list: Array = []
	if n == 0:
		later(0.6, func(): sweep(mv, 0))
		return
	for i in n:
		var ii := i
		later(0.18 * i, func():
			if not ending:
				return
			var mvEl: Control = G.node("gMoves")
			set_t(mvEl, str(mv - ii - 1))
			var cells: Array = []
			for p in game.c_cells([]):
				var e = game.at2(p[0], p[1])
				if e != null and e.k >= 0 and e.k < 6 and not e.has("ob") and not list.has(p):
					cells.append(p)
			if cells.is_empty():
				return
			var p = cells[randi() % cells.size()]
			list.append(p)
			var from := _stage_pos(mvEl)
			var tx: float = game.cx(p[1])
			var ty: float = game.cy(p[0]) + 112
			var im := _img_node("crk:b6", Vector2(52, 52))
			im.position = from - Vector2(26, 26)
			fly_layer.add_child(im)
			var d := Vector2(tx, ty) - from
			sfx.play("swoosh", 0.35, 1.2)
			fly_go(im, [[0.0, Vector2.ZERO, 0.7, 0.0], [0.5, Vector2(d.x * 0.5, d.y * 0.5 - 60), 1.0, -200.0], [1.0, d, 0.8, -360.0]], 0.42, 0.0, "ease-in-out", _rocket_land.bind(p, ii, tx, ty)))
	later(0.18 * n + 0.7, func(): sweep(mv, 0))

func sweep(mv: int, round_: int) -> void:
	if not ending:
		return
	if not game.ev.is_empty():
		later(0.2, func(): sweep(mv, round_))
		return
	var sp: Array = []
	for p in game.c_cells([]):
		var e = game.at2(p[0], p[1])
		if e != null and not e.get("dead", false) and e.k >= 6 and not e.has("ob"):
			sp.append(p)
	if not sp.is_empty() and round_ < 6:
		for i in sp.size():
			var p = sp[i]
			later(i * 0.12, func():
				if not ending:
					return
				var e = game.at2(p[0], p[1])
				if e == null or e.get("dead", false) or e.k < 6:
					return
				game.c_fire(p[0], p[1], e)
				coins(game.cx(p[1]), game.cy(p[0]) + 112, 2))
		later(sp.size() * 0.12 + 0.6, func(): sweep(mv, round_ + 1))
		return
	game.ended = true
	var R := game.rows()
	var C := game.cols()
	for r in R:
		for c in C:
			var e = game.at2(r, c)
			if e != null and not e.get("dead", false) and not e.get("diya", false) and not (e.has("ob") and e.ob.get("t", "") == "big"):
				var rr := r
				var cc := c
				later(r * 0.07 + absf(c - (C - 1) / 2.0) * 0.03, func():
					if not ending:
						return
					var f = game.at2(rr, cc)
					if f == null or f.get("dead", false):
						return
					if f.k >= 6:
						f.k = 0
					game.smash(rr, cc, {"pw": 1})
					if (rr + cc) % 3 == 0:
						coins(game.cx(cc), game.cy(rr) + 112, 1))
	later(0.1, func(): _if_end("finale", 0.55, 1.4, 0.0))
	later(R * 0.07 + 1.4, func(): _won_if(mv))

func _if_end(n: String, v: float, cut: float, off: float) -> void:
	if ending:
		sfx.play(n, v, 1.0, 0.0, cut, off)

func _won_if(mv: int) -> void:
	if ending:
		won(mv)

func _rocket_land(p: Array, ii: int, tx: float, ty: float) -> void:
	var e = game.at2(p[0], p[1])
	if e != null and not e.get("dead", false):
		e.k = [15, 6, 10][ii % 3]
		e.safe = game.clock + 0.3
		e.shakeT = 0.25
		game.ring(tx, ty - 112, "#FFC62B", game.uu() * 1.2, 6)
		sfx.play("lakshmi", 0.25, 1.5, 0.0, 0.25)

func _coin_land(ii: int) -> void:
	REW = mini(REWT, int(REW if REW != null else 0) + 5)
	if gi.has("rew"):
		set_t(gi["rew"].b, str(REW))
	sfx.coin(ii)

func coins(x: float, y: float, n: int) -> void:
	if not gi.has("rew"):
		return
	var el: Control = gi["rew"].c
	for i in n:
		var ii := i
		_after(i * 0.07, func():
			if not ending:
				return
			var sx := x + (randf() - 0.5) * 30
			var im := _img_node("art/ui-coin.webp", Vector2(36, 36))
			im.position = Vector2(sx - 26 + 8, y - 26 + 8)
			fly_layer.add_child(im)
			var d := _stage_pos(el) - Vector2(sx, y)
			fly_go(im, [[0.0, Vector2.ZERO, 0.9, 0.0], [0.22, Vector2(0, -30), 1.3, 0.0], [0.6, Vector2(d.x * 0.55, d.y * 0.45 - 30), 1.1, 0.0], [1.0, d, 0.6, 0.0]], 0.62, 0.0, "ease-in", _coin_land.bind(ii)))

# ================================================================== win
func won(mv: int) -> void:
	ending = false
	endT.clear()
	REW = null
	var L := LV()
	var d: int = int(L.get("diyas", 1))
	var key := str(cur)
	var old: int = int(S.best.get(key, 0))
	var c := mini(100, 50 + mv * 5)
	var first: bool = int(cur) >= int(S.lv)
	win_prev = int(cur)
	if d > old:
		S.diyas = int(S.get("diyas", 0)) + d - old
		S.best[key] = d
	var c0: int = S.coins
	S.coins += c
	var rw = L.get("reward")
	if first and rw != null:
		add_inv(rw.k, int(rw.n))
		S.seen["b_" + String(rw.k)] = 1
	if first:
		S.lv = int(cur) + 1
	var lt: String = L.get("ltype", "n")
	if first and (lt == "h" or lt == "s"):
		S.coins += 150 if lt == "s" else 100
	save()
	wonC = S.coins - c0
	game.stopped = true
	end_off()
	set_t(L_win.node("wLv"), "Level %d · %s" % [int(cur) + 1, String(levels[int(cur)].name)])
	set_t(L_win.node("wCoins"), "0")
	# diyas: 1 normal, 2 hard, 3 super hard, 74 apart and centred
	var ws: Control = L_win.node("wStars")
	for ch in ws.get_children():
		ch.queue_free()
	var tot := d * 62.0 + (d - 1) * 74.0
	var ds: Array = []
	for i in d:
		var im := sub(L_win, 14, ws)
		im.position = Vector2((390.0 - tot) / 2.0 + i * 136.0, -8.0 if i == 1 else 0.0)
		var it := img_of(im)
		if it:
			WebLayout.apply_filter(it, "grayscale(1) brightness(.55)")
		im.modulate.a = 0.8
		ds.append(im)
	show_screen("win")
	sfx.duck(0.18)
	_win_bursts(0)
	guy = CMWinGuy.new()
	var gc: Control = L_win.nodes[7]
	guy.size = gc.size
	guy.ox = 0
	guy.oy = 206
	guy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for ch in gc.get_children():
		if ch is AppFx.RingMask:
			ch.queue_free()
	var mask := AppFx.RingMask.new()
	mask.size = gc.size
	mask.xf = gc.get_global_transform().affine_inverse() * stage.get_global_transform()
	gc.add_child(mask)
	mask.add_child(guy)
	chakra.start()
	# entry animations
	Anim.play(L_win.nodes[8].get_node("tA"), "tpop2", 0.7, 0.1, "cubic-bezier(.3,1.6,.5,1)")
	Anim.play(L_win.nodes[8].get_node("ribA"), "pin2", 0.45, 0.9, "cubic-bezier(.3,1.6,.5,1)")
	Anim.play(L_win.nodes[10], "rise2", 0.4, 1.1)
	Anim.play(L_win.node("bNext"), "popb2", 0.45, 2.0, "cubic-bezier(.3,1.7,.5,1)")
	var x2: Control = L_win.node("bX2")
	x2.visible = wonC > 0
	Anim.play(x2, "popb2", 0.45, 2.0, "cubic-bezier(.3,1.7,.5,1)")
	for i in d:
		var ii := i
		later(1.3 + i * 0.25, func():
			var im: Control = ds[ii]
			var it := img_of(im)
			if it:
				WebLayout.apply_filter(it, "drop-shadow(rgb(255, 194, 30) 0px 0px 12px)")
			im.modulate.a = 1
			Anim.play(im, "pin2", 0.45, 0.0, "cubic-bezier(.3,1.7,.5,1)")
			sfx.play("lakshmi", 0.45, 1.2 + ii * 0.08, 0.0, 0.45))
	later(1.05, func(): _count(L_win.node("wCoins"), 0, c, 0.9, 8))
	if first and rw != null:
		later(2.2, func():
			toast28("%s unlocked! +%d" % [LBL.get(rw.k, rw.k), int(rw.n)])
			sfx.play("fanfare", 0.5))

func _count(c: Control, a: int, b: int, dur: float, steps: int, pre := "") -> void:
	var st := {"n": 0}
	create_tween().tween_method(func(k: float):
		var v := a + int(round((b - a) * k * (2 - k)))
		set_t(c, pre + str(v))
		var q := int(floor(k * steps))
		if q > st.n:
			st.n = q
			sfx.coin(q % 9), 0.0, 1.0, dur)

func _win_bursts(i: int) -> void:
	if not screens.win.visible:
		return
	var L := [["skyshot", 0.16, 0.95, 0.3], ["finale", 0.14, 0.95, 0.0], ["wala", 0.12, 1.0, 0.1], ["lakshmi", 0.14, 0.9, 0.0]]
	var q: Array = L[i % L.size()]
	sfx.play(q[0], q[1], q[2], 0.0, 0.0, q[3])
	_after(2.2 + randf() * 1.4, func(): _win_bursts(i + 1))

func _win_next() -> void:
	var n := (win_prev + 1) / 5
	if (win_prev == 4 or win_prev == 9) and not S.bdone.has(str(n)):
		bonus_card(n)
		return
	next_level()

# Next: straight to the next level's card. Only the very first win goes home once, for the Bakery lesson;
# the Level 2 card then opens by itself when the Bakery is built.
var card_after_build := false
func next_level() -> void:
	if win_prev == 0 and not S.get("tut", false):
		card_after_build = true
		home()
		return
	if int(S.lv) >= mini(area_cap(), levels.size()):
		home()
		return
	deb.clear()
	hide_hand()
	game.stopped = true
	show_screen("game")
	open_card(int(S.lv))

func _win_x2() -> void:
	if wonC <= 0:
		return
	var c := wonC
	show_ad(func(ok: bool):
		if not ok:
			return
		wonC = 0
		S.coins += c
		save()
		L_win.node("bX2").visible = false
		create_tween().tween_method(func(k: float): set_t(L_win.node("wCoins"), str(int(round(c + c * k)))), 0.0, 1.0, 0.7)
		sfx.play("fanfare", 0.5))

# ================================================================== bonus round (Coin Blast)
func bonus_level(n: int) -> Dictionary:
	var sh: Array = []
	var cs: Array = []
	var strip: Array = []
	var k := n % 3
	for r in 9:
		sh.append("xxxxxxxx")
		for c in 8:
			var s := (c == 3 or c == 4) if k == 0 else ((c == 2 or c == 5) if k == 1 else (r == 4 or c == 3 or c == 4))
			if not s:
				cs.append([r, c])
			else:
				strip.append([r, c])
	strip.shuffle()
	var pk := [6, 8] if n == 1 else [6, 10]
	var pre: Array = []
	for i in 2:
		pre.append([strip[i][0], strip[i][1], pk[i]])
	return {"name": "Coin Blast", "bonus": n, "after": n * 5, "moves": 10, "colors": [0, 1, 2, 5], "goal": {"coin": cs.size()}, "val": 5,
		"shape": sh, "ob": {"coin": cs}, "big": [], "hide": [], "pre": pre, "luck": 0.5, "teach": null, "idx": 10, "combo": null, "intro": [], "ltype": "n", "reward": null, "diyas": 1}

func bonus_card(n: int) -> void:
	open_modal(L_bc.root, true)
	Anim.play(L_bc.nodes[1], "g28", 0.4, 0.0, "cubic-bezier(.3,1.6,.5,1)")
	Anim.play(L_bc.nodes[4], "skg30", 1.6, 0.0, "ease-in-out", -1)
	sfx.play("fanfare", 0.35)
	var go: Control = L_bc.node("bcGo")
	if go.has_meta("cb"):
		go.gui_input.disconnect(go.get_meta("cb"))
	var f := func(e: InputEvent):
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and not e.pressed:
			open_modal(L_bc.root, false)
			start_bonus(n)
	go.mouse_filter = Control.MOUSE_FILTER_STOP
	go.gui_input.connect(f)
	go.set_meta("cb", f)

func start_bonus(n: int) -> void:
	BL = bonus_level(n)
	_show_ban("art/ui-coin.webp", "Coin Blast", "Bonus level! Break as many coins as you can in 10 moves. You keep them all.", func(): start("b"))
	sfx.play("fanfare", 0.5)

func bonus_end() -> void:
	if screens.bonusEnd.visible:
		return
	var got: int = (int(BL.goal.coin) - maxi(0, int(game.goal.get("coin", 0)))) * int(BL.val)
	S.coins += got
	S.bdone[str(BL.bonus)] = 1
	save()
	game.stopped = true
	end_off()
	set_t(L_be.node("beN"), "0")
	show_screen("bonusEnd")
	fw.run(true)
	sfx.duck(0.12)
	sfx.play("fanfare", 0.7)
	var wc: Control = L_be.nodes[4]
	wc.scale = Vector2.ONE
	wc.remove_meta("base")
	Anim.play(wc, "wcin", 0.55, 0.1, "cubic-bezier(.2,1.4,.4,1)")
	Anim.play(L_be.node("beNext"), "fin", 0.4, 1.6)
	var st := {"n": 0}
	var tw := create_tween()
	tw.tween_method(func(k: float):
		set_t(L_be.node("beN"), str(int(round(got * k * (2 - k)))))
		var q := int(floor(k * 14))
		if q > st.n:
			st.n = q
			sfx.coin(q % 8)
			if q % 4 == 0:
				fw.burst(80 + randf() * 230, 120 + randf() * 120, false), 0.0, 1.0, 1.4)
	tw.tween_callback(func():
		fw.burst(195, 330, true)
		sfx.play("pop", 0.6))
	_after(2.5, func(): sfx.duck(0.3))

# ================================================================== out of moves
func lost() -> void:
	if is_bonus():
		bonus_end()
		return
	sfx.play("lose")
	_after(0.7, func():
		if not game.over or ending:
			return
		lose_step(1)
		lost_ui())

func lose_step(k: int) -> void:
	LO.root.visible = true
	LO.s1.visible = k == 1
	LO.s2.visible = k == 2
	var card: Control = LO.s1 if k == 1 else LO.s2
	card.pivot_offset = Vector2(195, 430)
	card.scale = Vector2(0.7, 0.7)
	card.modulate.a = 0
	var tw := create_tween().set_parallel()
	tw.tween_property(card, "modulate:a", 1.0, 0.25)
	tw.tween_property(card, "scale", Vector2(1.04, 1.04), 0.25).set_ease(Tween.EASE_OUT)
	tw.chain().tween_property(card, "scale", Vector2.ONE, 0.17)
	# the green button pulses
	var g: Control = LO.n["bAd"] if k == 1 else LO.n["bRetry"]
	g.pivot_offset = g.size / 2
	g.scale = Vector2.ONE
	if lose_tw:
		lose_tw.kill()
	lose_tw = create_tween().set_loops()
	lose_tw.tween_property(g, "scale", Vector2(1.05, 1.05), 0.45)
	lose_tw.tween_property(g, "scale", Vector2.ONE, 0.45)
	var lvl := "Level %d" % (int(cur) + 1)
	for kk in ["1", "2"]:
		var rb: Control = LO.n["rib" + kk]
		fit_pill(rb, lvl)
	_lose_goals()
	_board_input()

func lose_hide() -> void:
	LO.root.visible = false
	if lose_tw:
		lose_tw.kill()
		lose_tw = null
	_board_input()

func _lose_goals() -> void:
	# goals left, fewest first, at most 3
	var ks: Array = []
	for k in realG:
		if int(realG[k]) > 0:
			ks.append(k)
	ks.sort_custom(func(a, b): return int(realG[a]) < int(realG[b]))
	ks = ks.slice(0, 3)
	var items: Array = []
	for k in ks:
		items.append([icon(k), int(realG[k])])
	LO.goals("1", items)
	LO.goals("2", items)

func lost_ui() -> void:
	LO.n["bAd"].visible = tries.ad < 1
	ad_pad(LO.n["bAd"])
	var bc: Control = LO.n["bCoin"]
	var has_p: bool = tries.coin < MOVEP.size()
	bc.visible = has_p
	if has_p:
		var p: int = MOVEP[tries.coin]
		set_t(LO.n["tag"], "      %d" % p)
		_inline(bc, LO.n["tag"])
		set_t(LO.n["lMsg"], "You have %d coins" % S.coins if S.coins < p else "")
	else:
		set_t(LO.n["lMsg"], "")

# a pill and the button text centred together (blue Buy button: [coin 950] Buy)
func _inline(c: Control, pill: Control) -> void:
	var l := lbl(c)
	var pl := lbl(pill)
	var f: Font = pl.label_settings.font
	var pw: float = f.get_string_size(pl.text, HORIZONTAL_ALIGNMENT_LEFT, -1, pl.label_settings.font_size).x + 14
	resize_box(pill, Vector2(pw, pill.size.y))
	pl.size.x = pw
	var tf: Font = l.label_settings.font
	var tw: float = tf.get_string_size(l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, l.label_settings.font_size).x
	var x0 := (c.size.x - (pw + 10 + tw)) / 2.0
	pill.position.x = x0
	l.position.x = x0 + pw + 10
	l.size.x = tw + 4
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

func resume(n: int) -> void:
	lose_hide()
	show_screen("game")
	game.more(n)
	slots()
	sfx.duck(0.3)

# ================================================================== in-game settings
func gset(o: bool) -> void:
	gs_open = o
	gs_dim.visible = o
	L_gset.root.visible = o
	game.paused = o
	if o:
		_gs_ui()
	_board_input()

func _gs_ui() -> void:
	var off := {7: not sfx.mus_on, 10: not sfx.fx_on, 13: not bool(S.get("vib", true))}
	for i in off:
		var b: Control = L_gset.nodes[i]
		var ic: Control = b.get_child(0)
		ic.modulate = Color(0.55, 0.55, 0.55) if off[i] else Color.WHITE
	set_t(L_gset.node("gSpd"), "x%d" % int(S.get("speed", 1)))

func _gs(a: String) -> void:
	sfx.play("swoosh", 0.35, 1.7)
	match a:
		"x": gset(false)
		"exit":
			gset(false)
			quit_level()
		"info":
			gset(false)
			banner("howto", Callable())
		"mus":
			sfx.set_mus(not sfx.mus_on)
			_gs_ui()
		"snd":
			sfx.set_fx(not sfx.fx_on)
			_gs_ui()
		"vib":
			S.vib = not bool(S.get("vib", true))
			save()
			if S.vib:
				Input.vibrate_handheld(30)
			_gs_ui()
		"spd":
			S.speed = int(S.get("speed", 1)) % 3 + 1
			save()
			game.gspeed = [1.2, 1.65, 2.2][int(S.speed) - 1]
			_gs_ui()

# ================================================================== first open and home
func _first_open() -> void:
	open_modal(L_agree.root, true)
	tap(L_agree.node("agY"), func():
		S.agreed = 1
		S.seen["b_howto"] = 1
		for k in levels[0].get("intro", []):
			S.seen["b_" + k] = 1
		save()
		open_modal(L_agree.root, false)
		start(0))

# home is the street: diyas earned in levels build it
func home() -> void:
	deb.clear()
	hide_hand()
	ghost.visible = false
	game.stopped = true
	for c in [L_card.root, L_hard.root]:
		open_modal(c, false)
	show_screen("street")
	home_ui.sync_in()
	street.cam_home(true)
	sfx.duck(0.15)
	home_ui.show_home()

func street_play() -> void:
	if int(S.lv) >= area_cap():
		toast28("Finish the builds to open Area 2!" if street.area == 1 else "Area 3 is coming soon!")
		return
	open_card(mini(int(S.lv), levels.size() - 1))

# areas: Area 1 = levels 1-30 (Sivakasi Street), Area 2 = levels 31-60 (Ghilli Crackers, Bunder Street, Chennai)
func area_levels() -> Vector2i:
	return Vector2i(0, 30) if street.area == 1 else Vector2i(30, 60)

const A1_COST := [1, 2, 2, 3, 3, 4, 4, 5, 5, 6]
func area_cap() -> int:
	return mini(area_levels().y, levels.size())

# after the Area 1 reward: switch the 3D world to the shop and play the Chennai start card
func enter_area2() -> void:
	S.area = 2
	S.step1 = int(S.get("step", 0))
	S.step = 0
	save()
	# the start scene opens on the Area 1 street (truck at the factory) and switches the world to the shop itself
	home_ui.home.visible = false
	var cl := CanvasLayer.new()
	cl.layer = 60
	add_child(cl)
	var st := AreaStartScene.new()
	st.app = self
	st.street = street
	street.sky_node = sky_layer.get_child(0)
	cl.add_child(st)
	st.play(get_viewport().get_visible_rect().size.y)
	st.finished.connect(func():
		street.set_area(2)
		sky_layer.visible = false
		home_ui.sync_in()
		home_ui.show_home())
	st.tree_exited.connect(cl.queue_free)

# first open: "Grandpa's Dream" over the live street, then level 1
func play_story(then: Callable) -> void:
	show_screen("street")
	home_ui.sync_in()
	home_ui.home.visible = false
	var cl := CanvasLayer.new()
	cl.layer = 60
	add_child(cl)
	var st := StoryScene.new()
	st.app = self
	st.street = street
	street.sky_node = sky_layer.get_child(0)
	cl.add_child(st)
	st.play(get_viewport().get_visible_rect().size.y)
	st.finished.connect(func():
		S.story = 1
		save()
		then.call())
	st.tree_exited.connect(cl.queue_free)

# end of Area 1 (once): factory lights, fireworks, the truck leaves for Chennai, the notebook tick
func play_area_end(then: Callable) -> void:
	var key := "end%d" % street.area
	if S.get(key, 0):
		then.call()
		return
	home_ui.home.visible = false
	var cl := CanvasLayer.new()
	cl.layer = 60
	add_child(cl)
	var st := AreaEndScene.new()
	st.area = street.area
	st.app = self
	st.street = street
	street.sky_node = sky_layer.get_child(0)
	cl.add_child(st)
	st.play(get_viewport().get_visible_rect().size.y)
	st.finished.connect(func():
		S[key] = 1
		save()
		then.call())
	st.tree_exited.connect(cl.queue_free)

func _title_tapped() -> void:
	var first := int(S.lv) == 0
	if first:
		# first time: straight into level 1 (its banners are already seen)
		S.seen["b_howto"] = 1
		for k in levels[0].get("intro", []):
			S.seen["b_" + k] = 1
		save()
		get_tree().create_timer(0.38).timeout.connect(func():
			title_s.visible = false
			if S.get("story", 0):
				start(0)
			else:
				play_story(func(): start(0)))
		title_s.leave()
		return
	show_screen("street")
	title_s.visible = true
	home_ui.sync_in()
	street.cam_home(true)
	home_ui.home.visible = false
	title_s.leave()
	get_tree().create_timer(0.9).timeout.connect(func(): home_ui.show_home())

# the street Welcome card (first open), over the title
func show_agree() -> void:
	home_ui.visible = true
	for c in home_ui.get_children():
		if c != home_ui.agree:
			c.set_meta("was", c.visible)
	home_ui.home.visible = false
	home_ui.agree.visible = true
	home_ui.agree.z_index = 20
	stage.move_child(home_ui, title_s.get_index() + 1)
	tap(home_ui.LA.node("bAgree"), func():
		S.agreed = 1
		save()
		home_ui.agree.visible = false
		stage.move_child(home_ui, title_s.get_index())
		title_s.agreed.emit())

func street_sfx(n: String) -> void:
	if n.begins_with("bk:"):
		var q := n.split(":")
		sfx.build_sound(q[1], float(q[2]))
		return
	match n:
		"rocket": sfx.play("rocket", 0.7)
		"rocketS": sfx.play("rocket", 0.35, 1.15)
		"blast": sfx.play("blast", 0.8)
		"pop": sfx.play("pop", 0.45)
		"open": sfx.play("swoosh", 0.35)
		"start":
			sfx.duck(0.06)
			sfx.play("sparkler", 0.3, 1.6)
			sfx.chime(0)
		"build": sfx.play("swoosh", 0.45)
		"done":
			sfx.play("bk_tada", 1.0)
			sfx.play("pop", 0.5)
			for i in 3:
				sfx.play("chime%d" % i, 0.6, 1.0, 0.12 + i * 0.11)
			_after(0.9, func(): sfx.duck(0.15))
		"area":
			sfx.play("win", 0.8)
			_after(3.0, func(): sfx.duck(0.15))

# area reward: Area 1 = 500 coins, 3 rockets, 3 chakras. Area 2 = 1000 coins, 3 matchboxes, 2 atoms.
func area_reward() -> void:
	var a2: bool = street.area == 2
	var c := 1000 if a2 else 500
	var k1 := "matchbox" if a2 else "rocket"
	var k2 := "atom" if a2 else "chakra"
	var n2 := 2 if a2 else 3
	S.coins = int(S.coins) + c
	add_inv(k1, 3)
	add_inv(k2, n2)
	save()
	popup("Area %d Complete!" % street.area, [["art/ui-coin.webp", "+%d coins" % c, "You have %d" % S.coins], ["crk:b%d" % IDX[k1], "+3 " + LBL[k1], "You have %d" % inv(k1)], ["crk:b%d" % IDX[k2], "+%d %s" % [n2, LBL[k2]], "You have %d" % inv(k2)]])
	sfx.play("win", 0.8)

func ask_notify() -> void:
	if ads:
		ads.askNotify()
	elif OS.get_name() == "Android":
		OS.request_permission("android.permission.POST_NOTIFICATIONS")

# ================================================================== frame
func _process(dt: float) -> void:
	_auto_lite(dt)
	_later_tick(dt)
	_flyers(dt)
	_tick_t += dt
	if _tick_t >= 0.3:
		_tick_t = 0.0
		_ticker()
	if toast_t > 0:
		toast_t -= dt
		if toast_t <= 0:
			create_tween().tween_property(toast, "modulate:a", 0.0, 0.25)

func _input(e: InputEvent) -> void:
	if e is InputEventMouseButton and not e.pressed and game and game.stopped and not ending and screens.game.visible and fakead == null:
		var any := false
		for c in [L_card.root, L_hard.root, L_ban.root, L_buy.root, L_got.root, L_bc.root, L_agree.root]:
			any = any or c.visible
		if not any and not gs_open and not LO.root.visible:
			open_card(mini(int(S.lv), levels.size() - 1))
			return
	# the end sequence (leftover moves, blasts, coins) skips on a tap anywhere on the screen
	if e is InputEventMouseButton and e.pressed and ending and game and game.over and now() - end_t0 > 1.0 and screens.game.visible:
		get_viewport().set_input_as_handled()
		end_off()
		won(endMv)
		return
	if e is InputEventMouseButton and e.pressed:
		lastAct = now()
		stop_demo()
		hide_hand()
		if game:
			game.hl = null
	if drag == null:
		return
	if e is InputEventMouseMotion:
		_ghost_to(stage.get_local_mouse_position())
	elif e is InputEventMouseButton and not e.pressed:
		_end_drag(stage.get_local_mouse_position())

# ================================================================== dev checks: -- --t=<scene> --lv=N --wait=S --shot=path
func _enter_tree() -> void:
	var a := {}
	for s in OS.get_cmdline_user_args():
		if s.begins_with("--") and "=" in s:
			a[s.substr(2, s.find("=") - 2)] = s.substr(s.find("=") + 1)
	if a.has("t"):
		save_path = "user://save_dev.json"
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
		call_deferred("_dev", a)
	elif a.has("flow"):
		# whole-app checks: -- --flow=1 --s_lv=3 --s_diyas=2 --s_step=1 --s_agreed=1 --tap=6 --act=panel|tut|build|shop|daily|bag|set --shot=png --wait=S
		save_path = "user://save_dev.json"
		var d := {"agreed": int(a.get("s_agreed", 0)), "lv": int(a.get("s_lv", 0)), "diyas": int(a.get("s_diyas", 0)), "step": int(a.get("s_step", 0)), "coins": int(a.get("s_coins", 300)), "tut": int(a.get("s_tut", 0)), "area": int(a.get("s_area", 1)), "story": 1, "end1": int(a.get("s_area", 1)) - 1}
		# diyas are worked out from the levels won (best) minus the builds done
		var bst := {}
		var lvs := Levels.all()
		for i in mini(d.lv, lvs.size()):
			bst[str(i)] = 2 if lvs[i].get("ltype", "n") == "h" else 1
		d["best"] = bst
		var f := FileAccess.open(save_path, FileAccess.WRITE)
		f.store_string(JSON.stringify(d))
		f = null
		call_deferred("_flow", a)

func _flow(a: Dictionary) -> void:
	if a.has("tap"):
		await get_tree().create_timer(float(a.tap)).timeout
		_title_tapped()
		await get_tree().create_timer(1.6).timeout
	if a.has("act"):
		var act: String = a.act
		if act in ["shop", "daily", "bag", "set"]:
			sheet(act)
		elif act == "panel":
			home_ui._build_btn()
		elif act == "build":
			home_ui.panel()
			street.do_task(false)
			home_ui.hide_home()
			home_ui._building(true)
		elif act == "all":
			home_ui.hide_home()
			street.build_all()
			home_ui._building(true)
		elif act == "play":
			home_ui._play()
		elif act == "winnext":
			title_s.visible = false
			start(0)
			await get_tree().create_timer(1.0).timeout
			won(8)
			await get_tree().create_timer(3.5).timeout
			_win_next()
	if a.has("shot"):
		await get_tree().create_timer(float(a.get("wait", 1.0))).timeout
		get_viewport().get_texture().get_image().save_png(a.shot)
		get_tree().quit()

func _dev(a: Dictionary) -> void:
	await get_tree().process_frame
	for m in [L_agree.root]:
		open_modal(m, false)
	S.agreed = 1
	if a.has("seen"):
		for k in BAN:
			S.seen["b_" + k] = 1
	S.coins = int(a.get("coins", 250))
	S.lv = int(a.get("slv", 9))
	var lv := int(a.get("lv", 6)) - 1
	var t: String = a.t
	if t == "card":
		open_card(lv)
	elif t == "game" or t == "end" or t == "lose" or t == "win" or t == "meter" or t == "cheer":
		open_modal(L_card.root, false)
		open_modal(L_hard.root, false)
		start(lv)
		if t == "end":
			await get_tree().create_timer(1.0).timeout
			game.over = true
			game.busy = true
			level_done(int(a.get("mv", 8)))
		elif t == "lose":
			await get_tree().create_timer(0.5).timeout
			game.over = true
			lost()
		elif t == "win":
			await get_tree().create_timer(0.5).timeout
			won(int(a.get("mv", 8)))
		elif t == "meter":
			_on_meter(30)
		elif t == "cheer":
			wordMv = null
			lastW = -99
			word(2)
	elif t == "spt":
		# dev: fire each special that used to be a plain swap, with screenshots
		open_modal(L_card.root, false)
		open_modal(L_hard.root, false)
		start(lv)
		game.moves = 99
		await get_tree().create_timer(1.0).timeout
		var ks: Array = String(a.get("ks", "7,9,12,13,18,19")).split(",")
		for kq in ks:
			var kk := int(kq)
			while game.busy:
				await get_tree().create_timer(0.2).timeout
			var e = game.at2(1, 3)
			if e == null or e.has("ob"):
				continue
			e.k = kk
			game.use(1, 3, 0, 0)
			for tq in [0.35, 0.6, 0.6]:
				await get_tree().create_timer(tq).timeout
				get_viewport().get_texture().get_image().save_png("%s-k%d-%.2f.png" % [a.shots, kk, tq])
			await get_tree().create_timer(1.5).timeout
		get_tree().quit()
	elif t == "brkt":
		# dev: a level with breakables; hit them all, then a bomb in the middle, with screenshots
		open_modal(L_card.root, false)
		open_modal(L_hard.root, false)
		start(lv)
		await get_tree().create_timer(1.2).timeout
		if a.has("toast"):
			toast28(String(a.toast).replace("_", " "))
			await get_tree().create_timer(0.4).timeout
		get_viewport().get_texture().get_image().save_png(a.shots + "-0.png")
		var cells: Array = []
		for r in game.R:
			for c in game.C:
				var e = game.at2(r, c)
				if e != null and e.has("ob") and CMBrk.is_brk(e.ob.t):
					cells.append([r, c])
		var n := 0
		for q in cells.slice(0, 6):
			game.hit_ob(game.at2(q[0], q[1]), q, false)
		for k in [0.06, 0.12, 0.2, 0.35]:
			await get_tree().create_timer(k).timeout
			n += 1
			get_viewport().get_texture().get_image().save_png("%s-1-%d.png" % [a.shots, n])
		await get_tree().create_timer(1.5).timeout
		var mid: Array = cells[cells.size() / 2] if cells.size() > 0 else [4, 4]
		game.boom(mid[0], mid[1], 1)
		for k in [0.05, 0.1, 0.15, 0.3]:
			await get_tree().create_timer(k).timeout
			n += 1
			get_viewport().get_texture().get_image().save_png("%s-2-%d.png" % [a.shots, n])
		await get_tree().create_timer(2.0).timeout
		get_viewport().get_texture().get_image().save_png(a.shots + "-3.png")
		get_tree().quit()
	elif t == "auto":
		# plays levels by itself: hint moves until the level ends, then Next / Try again, for N levels
		var n_lv := int(a.get("n", 2))
		open_modal(L_card.root, false)
		open_modal(L_hard.root, false)
		start(lv)
		var played := 0
		var t0 := now()
		while played < n_lv and now() - t0 < float(a.get("max", 240)):
			await get_tree().create_timer(0.25).timeout
			if L_ban.root.visible:
				print("AUTO banner -> tap")
				ban_done()
				continue
			if screens.win.visible:
				await get_tree().create_timer(2.5).timeout
				print("AUTO win level ", int(cur) + 1, " coins ", S.coins, " lv ", S.lv)
				played += 1
				_win_next()
				await get_tree().create_timer(1.0).timeout
				if screens.street.visible:
					print("AUTO street: diyas ", S.diyas, " step ", S.get("step", 0))
					home_ui.end_tutorial()
					home_ui.notif.visible = false
					street_play()
					await get_tree().create_timer(1.0).timeout
				if L_bc.root.visible:
					print("AUTO bonus card")
					open_modal(L_bc.root, false)
					start_bonus(int(S.lv) / 5)
				elif L_card.root.visible or L_hard.root.visible:
					print("AUTO card -> play")
					_card_play()
				continue
			if LO.root.visible:
				print("AUTO lost level ", int(cur) + 1, " -> +5 coins? ", S.coins)
				played += 1
				lose_step(2)
				await get_tree().create_timer(0.5).timeout
				lose_hide()
				game.stopped = true
				open_card(int(cur))
				await get_tree().create_timer(0.5).timeout
				_card_play()
				continue
			if screens.bonusEnd.visible:
				await get_tree().create_timer(2.0).timeout
				print("AUTO bonus end coins ", S.coins)
				fw.run(false)
				home()
				await get_tree().create_timer(1.0).timeout
				home_ui.end_tutorial()
				home_ui.notif.visible = false
				street_play()
				await get_tree().create_timer(1.0).timeout
				_card_play()
				continue
			if ending:
				continue
			if not game.busy and not game.over and not game.stopped:
				var h = game.hint_move()
				if h != null:
					if h.has("tap"):
						game.tap_sp(h.r, h.c)
					else:
						game.act(h.r, h.c, h.dr, h.dc)
		print("AUTO done played=", played)
		get_tree().quit()
	elif t == "ban":
		banner(String(a.get("k", "chakra")), Callable())
	elif t == "bonus":
		open_modal(L_card.root, false)
		BL = bonus_level(1)
		start("b")
	elif t == "bonusEnd":
		BL = bonus_level(1)
		start("b")
		await get_tree().create_timer(0.5).timeout
		bonus_end()
	elif t == "bc":
		bonus_card(1)
	elif t == "buy":
		open_modal(L_card.root, false)
		open_modal(L_hard.root, false)
		start(lv)
		ask_buy("hammer")
	elif t == "gset":
		open_modal(L_card.root, false)
		open_modal(L_hard.root, false)
		start(lv)
		gset(true)
	elif t == "popup":
		popup("You got", [["art/ui-coin.webp", "+500 coins", "You have 750"], ["crk:b6", "+3 Rocket", "You have 5"]])
	elif t == "agree":
		open_modal(L_card.root, false)
		open_modal(L_hard.root, false)
		open_modal(L_agree.root, true)
	elif t == "toast":
		toast28("3 free Lakshmi Vedi Hammers! Drag one onto the board.")
	elif t == "story":
		open_modal(L_card.root, false)
		open_modal(L_hard.root, false)
		play_story(func(): start(0))
	elif t == "area2":
		# dev / preview video: Area 1 done -> Chennai start card -> all 10 shop builds -> Area 2 end -> reward
		open_modal(L_card.root, false)
		open_modal(L_hard.root, false)
		title_s.visible = false
		S.step = 99
		S.end1 = 1
		S.end2 = 0
		S.lv = 60
		S.tut = 1
		var bst := {}
		for i in 60:
			bst[str(i)] = 2 if levels[i].get("ltype", "n") == "h" else 1
		S.best = bst
		show_screen("street")
		home_ui.sync_in()
		home_ui.home.visible = false
		await get_tree().create_timer(1.0).timeout
		enter_area2()
		if a.has("shots"):
			for k in [2.6, 7.0, 11.4, 14.6]:
				get_tree().create_timer(k).timeout.connect(func(): get_viewport().get_texture().get_image().save_png("%s-0-story-%04.1f.png" % [a.shots, k]))
		await get_tree().create_timer(19.0).timeout
		if a.has("shots"):
			get_viewport().get_texture().get_image().save_png(a.shots + "-1-outside.png")
		home_ui.hide_home()
		street.do_task(true)
		if a.has("shots"):
			for k in [3, 10, 17, 24, 31, 38, 45, 52]:
				get_tree().create_timer(float(k)).timeout.connect(func(): get_viewport().get_texture().get_image().save_png("%s-2-build%02d.png" % [a.shots, k]))
		home_ui._building(true)
		for i in 400:
			await get_tree().create_timer(0.5).timeout
			if a.has("shots") and street.step >= street.TASKS.size() and not a.has("_s3"):
				a["_s3"] = 1
				get_viewport().get_texture().get_image().save_png(a.shots + "-3-done.png")
			if S.get("end2", 0):
				break
		await get_tree().create_timer(7.5).timeout
		if a.has("quit"):
			get_tree().quit()
	elif t == "nightt":
		open_modal(L_card.root, false)
		open_modal(L_hard.root, false)
		title_s.visible = false
		S.step = 99
		show_screen("street")
		home_ui.sync_in()
		home_ui.home.visible = false
		street.cam_home(true)
		await get_tree().create_timer(1.5).timeout
		get_viewport().get_texture().get_image().save_png(a.shots + "-n0.png")
		var mode := String(a.get("m", "night"))
		if mode == "night":
			street.night(0.8)
			await get_tree().create_timer(0.5).timeout
			street.night(0.0)
		elif mode == "fx":
			for i in 9: street.firework()
			await get_tree().create_timer(1.0).timeout
			street.fx.clear()
		elif mode == "both":
			street.night(0.8)
			for i in 9: street.firework()
			await get_tree().create_timer(1.0).timeout
			street.story_clear()
		await get_tree().create_timer(1.5).timeout
		get_viewport().get_texture().get_image().save_png(a.shots + "-n1-" + mode + ".png")
		get_tree().quit()
	elif t == "areaend":
		# dev / preview video: Area 1 fully built, then the end scene, then quit
		open_modal(L_card.root, false)
		open_modal(L_hard.root, false)
		title_s.visible = false
		S.step = 99
		S.end1 = 0
		show_screen("street")
		home_ui.sync_in()
		home_ui.home.visible = false
		var w: Dictionary = street.wide()
		street.camP = w.p
		street.camL = w.look
		await get_tree().create_timer(float(a.get("wait", 1.0))).timeout
		if a.has("shots"):
			for k in [3.0, 10.5, 13.0]:
				get_tree().create_timer(k).timeout.connect(func(): get_viewport().get_texture().get_image().save_png("%s-%04.1f.png" % [a.shots, k]))
		play_area_end(func():
			home_ui._area_won_show()
			if a.has("shots"):
				for k in [0.3, 1.5, 3.0, 5.0]:
					get_tree().create_timer(k).timeout.connect(func(): get_viewport().get_texture().get_image().save_png("%s-end-%03.1f.png" % [a.shots, k]))
			await get_tree().create_timer(float(a.get("after", 6.0))).timeout
			if a.has("shots"):
				get_viewport().get_texture().get_image().save_png(a.shots + "-after.png")
			if a.has("quit"):
				get_tree().quit())
	if a.has("shot"):
		await get_tree().create_timer(float(a.get("wait", 1.5))).timeout
		if t == "end":
			var ov: Control = L_cm.nodes[2]
			var dm: Control = G.node("endDim")
			print("DBG oval vis=", ov.is_visible_in_tree(), " sc=", ov.scale, " mod=", ov.modulate, " pos=", ov.position, " size=", ov.size, " box=", boxr(ov))
			print("DBG dim vis=", dm.is_visible_in_tree(), " mod=", dm.modulate, " idx=", dm.get_index(), " board idx=", G.node("board").get_index(), " box=", boxr(dm))
		var img := get_viewport().get_texture().get_image()
		img.save_png(a.shot)
		get_tree().quit()

# ================================================================== menu sheets (app.js: Shop, Daily reward, My crackers, Settings)
const CP := [{"n": "Starter pack", "c": 1000, "p": "₹49", "st": true}, {"n": "1,000 coins", "c": 1000, "p": "₹89"}, {"n": "2,800 coins", "c": 2800, "p": "₹199"},
	{"n": "6,500 coins", "c": 6500, "p": "₹449"}, {"n": "15,000 coins", "c": 15000, "p": "₹899"}]
const DAYS := [50, 75, 100, 150, 200, 250, {"k": "atom", "n": 1}]
var L_sh: WebLayout      # sheet chrome + shop row templates
var L_sd: WebLayout      # daily templates
var L_ss: WebLayout      # settings templates
var L_sb: WebLayout      # bag templates
var sh_scroll: ScrollContainer
var sh_body: Control
var sh_name := ""

func _build_sheets() -> void:
	L_sh = WebLayout.new()
	L_sh.build("res://ui/sh_shop.json", stage)
	L_sh.root.visible = false
	L_sh.root.mouse_filter = Control.MOUSE_FILTER_STOP
	L_sh.root.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and not e.pressed and not L_sh.nodes[1].get_global_rect().has_point(e.global_position):
			close_sheet())
	tap(L_sh.node("sClose"), close_sheet)
	var body: Control = L_sh.node("sBody")
	for c in body.get_children():
		c.visible = false
	sh_scroll = ScrollContainer.new()
	sh_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sh_scroll.position = body.position
	sh_scroll.size = Vector2(body.size.x, 400)
	body.get_parent().add_child(sh_scroll)
	sh_body = Control.new()
	sh_body.mouse_filter = Control.MOUSE_FILTER_PASS
	sh_scroll.add_child(sh_body)
	for n in ["sh_daily", "sh_set", "sh_bag"]:
		var L := WebLayout.new()
		L.data = JSON.parse_string(FileAccess.get_file_as_string("res://ui/%s.json" % n))
		match n:
			"sh_daily": L_sd = L
			"sh_set": L_ss = L
			"sh_bag": L_sb = L

func daily_can() -> bool:
	return S.get("daily", {}).get("last", "") != today()

func sheet(n: String) -> void:
	sh_name = n
	sfx.play("swoosh", 0.5)
	var ttl: String = {"shop": "Shop", "daily": "Daily reward", "bag": "My crackers", "set": "Settings"}[n]
	set_t(L_sh.node("sTitle"), ttl)
	for c in sh_body.get_children():
		c.queue_free()
	var y := 0.0
	match n:
		"shop": y = _shop_rows()
		"daily": y = _daily_rows()
		"bag": y = _bag_rows()
		"set": y = _set_rows()
	sh_body.custom_minimum_size = Vector2(354, y)
	sh_body.size = sh_body.custom_minimum_size
	# the sheet grows with its content, up to the shop's height
	var box: Control = L_sh.nodes[1]
	var h := minf(658.0, y + 84 + 24)
	box.position.y = 844 - h
	resize_box(box, Vector2(390, h))
	L_sh.node("sClose").position.y = 14
	L_sh.node("sTitle").position.y = 22
	sh_scroll.position = Vector2(18, 68)
	sh_scroll.size = Vector2(354, h - 68 - 12)
	L_sh.root.visible = true
	box.position.y += 60
	create_tween().tween_property(box, "position:y", 844 - h, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_board_input()

func close_sheet() -> void:
	L_sh.root.visible = false
	_board_input()
	if home_ui:
		home_ui.refresh()

func _row_h(text: String, w: float, fs: int, font: Font) -> float:
	var tw := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var lines := maxi(1, int(ceil(tw / maxf(w - 6, 10))))
	return lines * fs * 1.3

func _text_row(L: WebLayout, idx: int, y: float) -> Control:
	var r := sub(L, idx, sh_body)
	r.position = Vector2(0, y)
	return r

func _srow(L: WebLayout, idx: int, y: float, img: String, b: String, small: String) -> Control:
	var r := sub(L, idx, sh_body)
	r.position = Vector2(0, y)
	if img != "" and kid(r, "img"):
		set_img(kid(r, "img"), img)
	var dv := kid(r, "div")
	set_t(kid(dv, "b"), b)
	var sm := kid(dv, "small")
	var l := lbl(sm)
	set_t(sm, small)
	var hh := 0.0
	if l:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		hh = _row_h(small, dv.size.x, l.label_settings.font_size, l.label_settings.font)
		sm.size.y = hh
		l.size = Vector2(dv.size.x, hh)
	var rh := maxf(72.0, 22 + hh + 30)
	resize_box(r, Vector2(r.size.x, rh))
	# keep the picture and the button in the middle of the row
	var dy := (rh - 82.0) / 2.0
	for c in r.get_children():
		if c is Control and c.has_meta("web") and c.get_meta("web").tag in ["img", "button"]:
			c.position.y = (rh - c.size.y) / 2.0
	dv.position.y = (rh - (22 + hh)) / 2.0
	r.set_meta("h", rh)
	return r

func _sbtn(b: Control, text: String, on: bool, coin: bool) -> void:
	if coin:
		if kid(b, "img"):
			kid(b, "img").visible = false
		_coin_text_left(b, text)
	else:
		if kid(b, "img"):
			kid(b, "img").visible = false
		set_t(b, text)
	set_bg(b, Color("#4CAF50") if on else Color("#BDB3A6"))

# "[coin] 900" inside a small button
func _coin_text_left(b: Control, num: String) -> void:
	var l := lbl(b)
	if l == null:
		return
	var f: Font = l.label_settings.font
	var fs := l.label_settings.font_size
	var ci: TextureRect = b.get_node_or_null("coinx")
	if ci == null:
		ci = _img_node("art/ui-coin.webp", Vector2(16, 16))
		ci.name = "coinx"
		b.add_child(ci)
	ci.visible = true
	ci.size = Vector2(16, 16)
	l.text = num
	var w := f.get_string_size(num, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var x0 := (b.size.x - (16 + 4 + w)) / 2.0
	ci.position = Vector2(x0, (b.size.y - 16) / 2.0)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	l.position.x = x0 + 20
	l.size.x = w + 4

func _shop_rows() -> float:
	var y := 0.0
	var p := _text_row(L_sh, 5, y)
	if kid(p, "b"):
		kid(p, "b").visible = false
	set_t(p, "You have %d coins." % S.coins)
	if lbl(p):
		lbl(p).position.x = 0
		lbl(p).horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	y += 30
	var h3 := _text_row(L_sh, 7, y)
	set_t(h3, "Start boosters (3 each)")
	y += 23
	for k in SB:
		var r := _srow(L_sh, 8, y, "crk:b%d" % IDX[k], LBL[k] + " ×3", SBD[k])
		var b := kid(r, "button")
		_sbtn(b, str(PACK[k]), true, true)
		var kk: String = k
		tap(b, func():
			if S.coins < PACK[kk]:
				sfx.play("nope")
				return
			S.coins -= PACK[kk]
			add_inv(kk, 3)
			save()
			sfx.play("fanfare", 0.4)
			sheet("shop"))
		y += float(r.get_meta("h")) + 10
	var h3b := _text_row(L_sh, 7, y + 2)
	set_t(h3b, "Coins")
	y += 25
	for i in CP.size():
		var cp: Dictionary = CP[i]
		if cp.get("st", false) and S.get("starter", false):
			continue
		var r := _srow(L_sh, 8, y, "art/ui-coin.webp", cp.n, "1,000 coins + 2 of each start booster. One time only." if cp.get("st", false) else "%s coins" % _commas(int(cp.c)))
		var b := kid(r, "button")
		_sbtn(b, cp.p, true, false)
		tap(b, func():
			S.coins += int(cp.c)
			if cp.get("st", false):
				S.starter = 1
				for k in SB:
					add_inv(k, 2)
			save()
			sfx.play("fanfare", 0.5)
			sheet("shop"))
		y += float(r.get_meta("h")) + 10
	var note := _text_row(L_sh, 5, y)
	if kid(note, "b"):
		kid(note, "b").visible = false
	set_t(note, "Test build: coin packs are free.")
	return y + 30

func _commas(n: int) -> String:
	var s := str(n)
	var o := ""
	while s.length() > 3:
		o = "," + s.substr(s.length() - 3) + o
		s = s.substr(0, s.length() - 3)
	return s + o

func _daily_rows() -> float:
	var d: Dictionary = S.get("daily", {"n": 0})
	var can := daily_can()
	var n: int = (int(d.get("n", 0)) % 7) if can else posmod(int(d.get("n", 0)) - 1, 7)
	var days: Control = sub(L_sd, 5, sh_body)
	days.position = Vector2(0, 0)
	for c in days.get_children():
		c.queue_free()
	for i in 7:
		var r = DAYS[i]
		var obj: bool = r is Dictionary
		var got: bool = i < n or (not can and i == n)
		var tpl := 24 if i == 6 else (6 if (can and i == n) else 9)
		var c := sub(L_sd, tpl, days)
		c.position = Vector2((i % 4) * 90.67, (i / 4) * 97)
		if i != 6:
			c.position.x = (i % 4) * 90.67
		set_t(c, "Day %d" % (i + 1))
		if lbl(c):
			lbl(c).vertical_alignment = VERTICAL_ALIGNMENT_TOP
			lbl(c).position.y = 6
		set_img(kid(c, "img"), ("crk:b%d" % IDX[r.k]) if obj else "art/ui-coin.webp")
		set_t(kid(c, "b"), LBL[r.k] if obj else str(r))
		if got:
			c.modulate = Color(1, 1, 1, 0.55)
			var tk := AppFx.Tick.new(Vector2(26, 26), Color("#22C55E"), 4)
			tk.position = Vector2(c.size.x - 30, 4)
			c.add_child(tk)
	var b := sub(L_sd, 27, sh_body)
	b.position = Vector2(0, 200)
	set_t(b, "Claim" if can else "Come back tomorrow")
	if not can:
		set_bg(b, Color("#BDB3A6"))
	tap(b, func():
		if not daily_can():
			return
		var dd: Dictionary = S.get("daily", {"n": 0})
		var rr = DAYS[int(dd.get("n", 0)) % 7]
		if rr is Dictionary:
			add_inv(rr.k, int(rr.n))
		else:
			S.coins += int(rr)
		S.daily = {"n": int(dd.get("n", 0)) + 1, "last": today()}
		save()
		sfx.play("win", 0.6)
		sheet("daily"))
	return 258.0

func _bag_rows() -> float:
	var y := 0.0
	var ks: Array = SB + SL
	for k in ks:
		var r := _srow(L_sb, 5, y, "crk:b%d" % IDX[k], "%s × %d" % [LBL[k], inv(k)], SBD.get(k, DESC2.get(k, "")))
		y += float(r.get_meta("h")) + 10
	var p := _text_row(L_ss, 23, y)
	set_t(p, "Rocket, Flowerpot, Ground Chakra and Sky Shot are made by matching on the board.")
	if lbl(p):
		lbl(p).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl(p).size.y = 40
	return y + 50

func _set_rows() -> float:
	var on: bool = sfx.mus_on or sfx.fx_on
	var r1 := sub(L_ss, 5, sh_body)
	r1.position = Vector2(0, 0)
	set_t(kid(kid(r1, "div"), "small"), "On" if on else "Off")
	var b1 := kid(r1, "button")
	_sbtn(b1, "On" if on else "Off", on, false)
	tap(b1, func():
		var v: bool = not (sfx.mus_on or sfx.fx_on)
		sfx.set_mus(v)
		sfx.set_fx(v)
		sheet("set"))
	var r2 := sub(L_ss, 10, sh_body)
	r2.position = Vector2(0, 74)
	var spdb := kid(r2, "div", 1)
	var cur_s := int(S.get("speed", 1))
	var bs: Array = []
	for c in spdb.get_children():
		if c is Control and c.has_meta("web"):
			bs.append(c)
	for i in bs.size():
		var v := i + 1
		_sbtn(bs[i], "%dx" % v, cur_s == v, false)
		tap(bs[i], func():
			S.speed = v
			save()
			if game:
				game.gspeed = [1.2, 1.65, 2.2][v - 1]
			sfx.play("tick", 0.5)
			sheet("set"))
	var r3 := sub(L_ss, 18, sh_body)
	r3.position = Vector2(0, 148)
	var rb := kid(r3, "button")
	tap(rb, func():
		if rb.get_meta("sure", false):
			S = {"agreed": 1}
			save()
			close_sheet()
			get_tree().reload_current_scene()
		else:
			rb.set_meta("sure", true)
			set_t(rb, "Sure?"))
	var p := sub(L_ss, 23, sh_body)
	p.position = Vector2(0, 240)
	return 258.0
