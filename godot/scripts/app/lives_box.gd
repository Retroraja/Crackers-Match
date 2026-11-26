# 26 Nov: the Lives card (like Royal Match). Opens from the heart pill, or from Play when there are no lives.
# Big heart with the count, "Next life in mm:ss" (or "Lives are full"), green "Watch ad +1" and yellow
# "Refill all" for coins. Built once, reused; same card look as AskBox.
extends RefCounted
class_name LivesBox

var root: Control
var lay := WebLayout.new()
var n := {}
var app

func mk(parent: Control, r: Array, box = null, t = null, name := "") -> Control:
	var d := {"i": 0, "id": name, "tag": "div", "r": r, "op": 1}
	if box != null:
		d.box = box
	if t != null:
		d.txt = t
	var po := parent.get_global_rect().position - root.get_global_rect().position if parent != root else Vector2.ZERO
	var c := lay.make(d, po)
	if name != "":
		c.name = name
		n[name] = c
	parent.add_child(c)
	return c

func build(parent: Control, a) -> void:
	app = a
	root = Control.new()
	root.size = Vector2(390, 844)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.visible = false
	parent.add_child(root)
	var dim := mk(root, [0, -400, 390, 1644], {"bgc": UISkin.rgba("#030a1c", 0.62)})
	var card := mk(root, [35, 250, 320, 330], UISkin.card_box(), null, "card")
	mk(card, [35, 272, 320, 40], null, LoseUI.txt("Lives", "LilitaOne", 30, UISkin.TITLE), "t")
	UISkin.title_label(n.t.get_node("txt"))
	TopBar.pic("art/web/fe-heart.png", Vector2(195 - 45 - 35, 316 - 250), Vector2(90, 90), card)
	var cnt := TopBar.label(40, Color.WHITE, 8, Color(0.47, 0.04, 0.12))
	cnt.position = Vector2(195 - 45 - 35, 316 - 250 - 4)
	cnt.size = Vector2(90, 90)
	card.add_child(cnt)
	n.cnt = cnt
	var body := mk(card, [55, 412, 280, 30], null, LoseUI.txt("", "Sora-700", 16, UISkin.TEXT), "b")
	(body.get_node("txt") as Label).vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var ad := mk(card, [60, 452, 270, 52], null, LoseUI.txt("Watch ad  +1", "Sora-800", 19, "#ffffff"), "ad")
	UISkin.button(ad, "green")
	var tag := AppFx.badge("AD", Color("#E8123C"), Vector2(34, 22), WebLayout.font("LilitaOne"), 14, 8, 2)
	tag.position = Vector2(10, 15)
	ad.add_child(tag)
	var buy := mk(card, [60, 512, 270, 52], null, LoseUI.txt("Refill all  %d" % app.REFILL_COST, "Sora-800", 19, "#ffffff"), "buy")
	UISkin.button(buy, "yellow")
	TopBar.pic("art/ui-coin.webp", Vector2(270 - 40, 13), Vector2(26, 26), buy)
	(buy.get_node("txt") as Label).position.x -= 14
	app.tap(ad, func():
		app.show_ad(func(ok: bool):
			if ok:
				app.add_life(1)
			refresh()))
	app.tap(buy, func():
		if int(app.S.coins) < app.REFILL_COST:
			close()
			app.sheet("shop")
			return
		app.S.coins = int(app.S.coins) - app.REFILL_COST
		app.add_life(app.LIFE_MAX)
		app.sfx.play("coin3", 0.6)
		refresh())
	app.tap(n.card, func(): pass)
	app.tap(dim, close)

func open(out := false) -> void:
	(n.t.get_node("txt") as Label).text = "Out of lives" if out else "Lives"
	refresh()
	root.visible = true
	var c: Control = n.card
	c.pivot_offset = c.size / 2
	c.scale = Vector2(0.8, 0.8)
	c.modulate.a = 0.0
	var tw := c.create_tween().set_parallel()
	tw.tween_property(c, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(c, "modulate:a", 1.0, 0.15)

func refresh() -> void:
	var l: int = app.lives_now()
	n.cnt.text = str(l)
	var full: bool = l >= app.LIFE_MAX
	(n.b.get_node("txt") as Label).text = "Lives are full!" if full else "Next life in " + app.life_txt()
	n.ad.visible = not full
	n.buy.visible = not full
	# full: a short card without the buttons
	var h := 210.0 if full else 330.0
	if absf(n.card.size.y - h) > 1:
		app.resize_box(n.card, Vector2(320, h))
		n.card.position.y = 250.0 + (330.0 - h) / 2.0
	app.home_ui.refresh_top()

# called every second while open (the timer)
func tick() -> void:
	if root.visible:
		refresh()

func close() -> void:
	root.visible = false
