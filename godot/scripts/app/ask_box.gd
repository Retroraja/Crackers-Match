# 25 Nov: a small question card, like ExitBox: "Leave level?" (Keep playing / Leave) and the Piggy bank help card.
# One card, built once, reused; the screen behind is paused by the caller.
extends RefCounted
class_name AskBox

var root: Control
var lay := WebLayout.new()
var n := {}
var _yes: Callable
var _no: Callable

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
	var dim := mk(root, [0, -400, 390, 1644], {"bgc": UISkin.rgba("#030a1c", 0.62)})
	var card := mk(root, [35, 300, 320, 236], UISkin.card_box(), null, "card")
	mk(card, [35, 324, 320, 40], null, LoseUI.txt("Leave level?", "LilitaOne", 30, UISkin.TITLE), "t")
	UISkin.title_label(n.t.get_node("txt"))
	var body := mk(card, [55, 372, 280, 64], null, LoseUI.txt("", "Sora-700", 15, UISkin.TEXT), "b")
	var bl: Label = body.get_node("txt")
	bl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var no := mk(card, [55, 452, 136, 56], null, LoseUI.txt("Keep playing", "Sora-800", 17, "#ffffff"), "no")
	var yes := mk(card, [203, 452, 132, 56], null, LoseUI.txt("Leave", "Sora-800", 20, "#ffffff"), "yes")
	var one := mk(card, [105, 452, 180, 56], null, LoseUI.txt("Got it", "Sora-800", 20, "#ffffff"), "one")
	UISkin.button(no, "green")
	UISkin.button(yes, "red")
	UISkin.button(one, "green")
	app.tap(no, func(): _close(_no))
	app.tap(one, func(): _close(_no))
	app.tap(yes, func(): _close(_yes))
	app.tap(n.card, func(): pass)
	app.tap(dim, func(): _close(_no))

# two buttons (green "no" keeps you here, red "yes" does the action), or one green button when yes_txt is ""
func ask(title: String, body: String, no_txt: String, yes_txt: String, on_yes: Callable, on_no := Callable()) -> void:
	_yes = on_yes
	_no = on_no
	(n.t.get_node("txt") as Label).text = title
	(n.b.get_node("txt") as Label).text = body
	var two := yes_txt != ""
	n.no.visible = two
	n.yes.visible = two
	n.one.visible = not two
	(n.no.get_node("txt") as Label).text = no_txt
	(n.one.get_node("txt") as Label).text = no_txt
	(n.yes.get_node("txt") as Label).text = yes_txt
	root.visible = true
	var c: Control = n.card
	c.pivot_offset = c.size / 2
	c.scale = Vector2(0.8, 0.8)
	c.modulate.a = 0.0
	var tw := c.create_tween().set_parallel()
	tw.tween_property(c, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(c, "modulate:a", 1.0, 0.15)

func _close(f: Callable) -> void:
	root.visible = false
	if f.is_valid():
		f.call()

# Android back = the green / safe button
func back() -> void:
	_close(_no)
