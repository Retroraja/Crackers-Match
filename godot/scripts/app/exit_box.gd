# Android back on the home street (20 Nov): a small "Exit game?" box. Only Yes quits.
extends RefCounted
class_name ExitBox

var root: Control
var lay := WebLayout.new()
var n := {}

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

func build(parent: Control, app) -> void:
	root = Control.new()
	root.size = Vector2(390, 844)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.visible = false
	parent.add_child(root)
	mk(root, [0, 0, 390, 844], {"bgc": UISkin.rgba("#030a1c", 0.6)})
	var card := mk(root, [45, 322, 300, 200], UISkin.card_box(), null, "card")
	# (child boxes are given in screen coordinates, like LoseUI)
	mk(card, [45, 352, 300, 40], null, LoseUI.txt("Exit game?", "LilitaOne", 30, UISkin.TITLE), "t")
	UISkin.title_label(n.t.get_node("txt"))
	var no := mk(card, [69, 440, 118, 52], null, LoseUI.txt("No", "Sora-800", 20, "#ffffff"), "no")
	var yes := mk(card, [203, 440, 118, 52], null, LoseUI.txt("Yes", "Sora-800", 20, "#ffffff"), "yes")
	UISkin.button(no, "red")
	UISkin.button(yes, "white")
	app.tap(no, close)
	app.tap(yes, func(): app.get_tree().quit())
	app.tap(n.card, func(): pass)
	app.tap(root.get_child(0), close)

func open() -> void:
	root.visible = true
	var c: Control = n.card
	c.pivot_offset = c.size / 2
	c.scale = Vector2(0.8, 0.8)
	c.modulate.a = 0.0
	var tw := c.create_tween().set_parallel()
	tw.tween_property(c, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(c, "modulate:a", 1.0, 0.15)

func close() -> void:
	root.visible = false
