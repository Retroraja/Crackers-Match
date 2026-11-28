# The match-3 board: crackers, swaps, matches, falling, specials, combos and obstacles.
extends Node2D
class_name Board

signal changed
signal finished(won: bool)

const R := 9
const C := 8
const U := 46.0
const K_ROCKET := 6
const K_CHAKRA := 8
const K_BOMB := 10
const K_BOX := 14
const GRAV := 1500.0
const VMAX := 540.0
const COL := {0: Color(0.95, 0.25, 0.3), 1: Color(0.3, 0.5, 1.0), 2: Color(0.2, 0.85, 0.45), 5: Color(1.0, 0.6, 0.15)}

var tex := {}
var t_crate: Texture2D
var t_crate2: Texture2D
var t_gold: Texture2D
var t_cab := []
var lv: Dictionary
var moves := 0
var goal := {}
var cells := []
var cabs := []
var busy := false
var over := false
var active := 0
var casc := 0
var sfx: Sfx
var fx: Fx
var lite := false
var floor_layer: Node2D
var obs_layer: Node2D
var tile_layer: Node2D
var drag_from := Vector2i(-1, -1)
var drag_start := Vector2.ZERO
var dragging := false
var idle_t := 0.0

class Tile extends Node2D:
	var k := 0
	var dir := "v"
	var fy := 0.0
	var v := 0.0
	var firing := false
	var spr: Sprite2D

func _init() -> void:
	for k in [0, 1, 2, 5, K_ROCKET, K_CHAKRA, K_BOMB, K_BOX]:
		tex[k] = load("res://art/tiles/k%d.png" % k)
	t_crate = load("res://art/crate.webp")
	t_crate2 = load("res://art/crate2.webp")
	t_gold = load("res://art/goldfloor.webp")
	t_cab = [load("res://art/cab-base.webp"), load("res://art/cab-items.webp"), load("res://art/cab-door.webp")]

func cpos(r: int, c: int) -> Vector2:
	return Vector2(c * U + U / 2.0, r * U + U / 2.0)

# ------------------------------------------------------------------ setup
func setup(level: Dictionary) -> void:
	lv = level
	moves = level["moves"]
	over = false
	busy = false
	active = 0
	for ch in get_children():
		ch.queue_free()
	floor_layer = Node2D.new()
	obs_layer = Node2D.new()
	tile_layer = Node2D.new()
	add_child(floor_layer)
	add_child(tile_layer)
	add_child(obs_layer)
	cells = []
	cabs = []
	goal = {}
	var rows: Array = level["rows"]
	for r in R:
		var row := []
		for c in C:
			var ch: String = rows[r][c]
			var cell := {"on": ch != "#", "hole": ch == "o", "ob": "", "hp": 0, "gold": false, "cab": -1, "tile": null, "spr": null, "gspr": null}
			if ch in ["g", "x", "X"]:
				cell["gold"] = true
				_add_goal("gold", 1)
			if ch in ["c", "x"]:
				cell["ob"] = "crate"
				cell["hp"] = 1
				_add_goal("crate", 1)
			if ch in ["w", "X"]:
				cell["ob"] = "steel"
				cell["hp"] = 2
				_add_goal("steel", 1)
			row.append(cell)
		cells.append(row)
	for r in R:
		for c in C:
			if rows[r][c] == "K":
				var id := cabs.size()
				var node := Node2D.new()
				node.position = cpos(r, c) + Vector2(U / 2.0, U / 2.0)
				var layers := []
				for t in t_cab:
					var s := Sprite2D.new()
					s.texture = t
					s.scale = Vector2.ONE * (U * 2.0 / t.get_width())
					node.add_child(s)
					layers.append(s)
				obs_layer.add_child(node)
				cabs.append({"r": r, "c": c, "hp": 7, "node": node, "layers": layers})
				_add_goal("cab", 6)
				for a in 2:
					for b in 2:
						cells[r + a][c + b]["ob"] = "cab"
						cells[r + a][c + b]["cab"] = id
	for r in R:
		for c in C:
			var cell: Dictionary = cells[r][c]
			if cell["gold"]:
				var g := Sprite2D.new()
				g.texture = t_gold
				g.position = cpos(r, c)
				g.scale = Vector2.ONE * (U / t_gold.get_width())
				g.modulate = Color(1, 1, 1, 0.95)
				floor_layer.add_child(g)
				cell["gspr"] = g
			if cell["ob"] == "crate" or cell["ob"] == "steel":
				var s := Sprite2D.new()
				s.texture = t_crate2 if cell["ob"] == "steel" else t_crate
				s.position = cpos(r, c)
				s.scale = Vector2.ONE * (U * 1.02 / s.texture.get_width())
				obs_layer.add_child(s)
				cell["spr"] = s
	# crackers
	var pre := {"1": K_ROCKET, "2": K_BOMB, "3": K_BOX, "4": K_CHAKRA}
	for r in R:
		for c in C:
			var cell: Dictionary = cells[r][c]
			if not _free(r, c):
				continue
			var ch: String = rows[r][c]
			var k: int = pre[ch] if pre.has(ch) else _safe_color(r, c)
			_new_tile(r, c, k, 0.0)
	_ensure_move()
	queue_redraw()
	changed.emit()

func _add_goal(k: String, n: int) -> void:
	goal[k] = goal.get(k, 0) + n

func _free(r: int, c: int) -> bool:
	if r < 0 or r >= R or c < 0 or c >= C:
		return false
	var cell: Dictionary = cells[r][c]
	return cell["on"] and not cell["hole"] and cell["ob"] == ""

func tile_at(r: int, c: int) -> Tile:
	if r < 0 or r >= R or c < 0 or c >= C:
		return null
	return cells[r][c]["tile"]

func kind(r: int, c: int) -> int:
	var t := tile_at(r, c)
	if t == null or t.fy > 0.5 or t.k >= 6:
		return -1
	return t.k

func _safe_color(r: int, c: int) -> int:
	var cols: Array = lv["colors"]
	for i in 20:
		var k: int = cols[randi() % cols.size()]
		var bad := (kind(r, c - 1) == k and kind(r, c - 2) == k) or (kind(r - 1, c) == k and kind(r - 2, c) == k)
		if not bad:
			return k
	return cols[0]

func _new_tile(r: int, c: int, k: int, fy: float) -> Tile:
	var t := Tile.new()
	t.k = k
	t.fy = fy
	if k == K_ROCKET:
		t.dir = "v" if randf() < 0.5 else "h"
	t.spr = Sprite2D.new()
	t.add_child(t.spr)
	_skin(t)
	t.position = cpos(r, c) - Vector2(0, fy)
	tile_layer.add_child(t)
	cells[r][c]["tile"] = t
	return t

func _skin(t: Tile) -> void:
	t.spr.texture = tex[t.k]
	var s := U * (0.92 if t.k >= 6 else 0.86) / 128.0
	t.spr.scale = Vector2(s, s)
	t.spr.rotation = PI / 2.0 if (t.k == K_ROCKET and t.dir == "h") else 0.0

# ------------------------------------------------------------------ drawing the board frame
func _draw() -> void:
	if cells.is_empty():
		return
	for r in R:
		for c in C:
			if cells[r][c]["on"]:
				draw_rect(Rect2(c * U - 4, r * U - 4, U + 8, U + 8), Color(0.91, 0.65, 0.16), true)
	for r in R:
		for c in C:
			if cells[r][c]["on"]:
				draw_rect(Rect2(c * U - 2, r * U - 2, U + 4, U + 4), Color(0.97, 0.84, 0.45), true)
	for r in R:
		for c in C:
			if cells[r][c]["on"]:
				var col := Color(0.86, 0.84, 0.95) if (r + c) % 2 else Color(0.92, 0.9, 0.98)
				if cells[r][c]["hole"]:
					col = Color(0.17, 0.05, 0.29)
				draw_rect(Rect2(c * U, r * U, U, U), col, true)

# ------------------------------------------------------------------ input
func _unhandled_input(e: InputEvent) -> void:
	if busy or over:
		return
	var p := Vector2.ZERO
	if e is InputEventScreenTouch:
		p = to_local(e.position)
		if e.pressed:
			drag_from = Vector2i(floori(p.y / U), floori(p.x / U))
			drag_start = p
			dragging = true
		else:
			if dragging and (p - drag_start).length() < 14.0:
				_tap(drag_from)
			dragging = false
	elif e is InputEventScreenDrag and dragging:
		p = to_local(e.position)
		var d := p - drag_start
		if d.length() > 18.0:
			dragging = false
			var dr := 0
			var dc := 0
			if absf(d.x) > absf(d.y):
				dc = 1 if d.x > 0 else -1
			else:
				dr = 1 if d.y > 0 else -1
			try_swap(drag_from, drag_from + Vector2i(dr, dc))

func _tap(a: Vector2i) -> void:
	var t := tile_at(a.x, a.y)
	if t == null or t.k < 6 or moves <= 0:
		return
	idle_t = 0.0
	busy = true
	moves -= 1
	changed.emit()
	casc = 0
	await fire(a.x, a.y, -1)
	await _settle()
	_end_turn()

# ------------------------------------------------------------------ moves
func try_swap(a: Vector2i, b: Vector2i) -> void:
	if busy or over or moves <= 0:
		return
	var ta := tile_at(a.x, a.y)
	var tb := tile_at(b.x, b.y)
	if ta == null or tb == null or not _free(a.x, a.y) or not _free(b.x, b.y):
		return
	idle_t = 0.0
	busy = true
	casc = 0
	await _swap_anim(a, b)
	sfx.play("swap", 0.45, 1.0)
	var sa := ta.k >= 6
	var sb := tb.k >= 6
	if sa and sb:
		moves -= 1
		changed.emit()
		await combo(b, a, ta, tb)
	elif ta.k == K_BOX or tb.k == K_BOX:
		moves -= 1
		changed.emit()
		var box_at := b if ta.k == K_BOX else a
		var other := tb if ta.k == K_BOX else ta
		await box_fire(box_at.x, box_at.y, other.k)
	elif sa or sb:
		moves -= 1
		changed.emit()
		var sp_at := b if sa else a
		var nm_at := a if sa else b
		var g := _find_groups()
		if not g.is_empty():
			await _clear_groups(g, [nm_at])
		await fire(sp_at.x, sp_at.y, -1)
	else:
		var groups := _find_groups()
		if groups.is_empty():
			sfx.play("nope", 0.4)
			await _swap_anim(a, b)
			busy = false
			return
		moves -= 1
		changed.emit()
		await _clear_groups(groups, [a, b])
	await _settle()
	_end_turn()

func _swap_anim(a: Vector2i, b: Vector2i) -> void:
	var ta := tile_at(a.x, a.y)
	var tb := tile_at(b.x, b.y)
	cells[a.x][a.y]["tile"] = tb
	cells[b.x][b.y]["tile"] = ta
	var tw := create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(ta, "position", cpos(b.x, b.y), 0.13)
	tw.tween_property(tb, "position", cpos(a.x, a.y), 0.13)
	await tw.finished

# ------------------------------------------------------------------ matches
func _find_groups() -> Array:
	var M := {}
	var H := {}
	var V := {}
	for r in R:
		var c := 0
		while c < C:
			var k := kind(r, c)
			var n := 1
			while k >= 0 and kind(r, c + n) == k:
				n += 1
			if k >= 0 and n >= 3:
				for i in n:
					M[Vector2i(r, c + i)] = k
					H[Vector2i(r, c + i)] = n
			c += n
	for c in C:
		var r := 0
		while r < R:
			var k := kind(r, c)
			var n := 1
			while k >= 0 and kind(r + n, c) == k:
				n += 1
			if k >= 0 and n >= 3:
				for i in n:
					M[Vector2i(r + i, c)] = k
					V[Vector2i(r + i, c)] = n
			r += n
	var SQ := {}
	for r in R - 1:
		for c in C - 1:
			var k := kind(r, c)
			if k >= 0 and kind(r, c + 1) == k and kind(r + 1, c) == k and kind(r + 1, c + 1) == k:
				for p in [Vector2i(r, c), Vector2i(r, c + 1), Vector2i(r + 1, c), Vector2i(r + 1, c + 1)]:
					M[p] = k
					SQ[p] = true
	var seen := {}
	var out := []
	for s0 in M.keys():
		if seen.has(s0):
			continue
		var kk: int = M[s0]
		var st := [s0]
		var cl := []
		var h := 0
		var v := 0
		var sq := false
		seen[s0] = true
		while not st.is_empty():
			var q: Vector2i = st.pop_back()
			cl.append(q)
			h = maxi(h, H.get(q, 0))
			v = maxi(v, V.get(q, 0))
			sq = sq or SQ.has(q)
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var z: Vector2i = q + d
				if M.get(z, -1) == kk and not seen.has(z):
					seen[z] = true
					st.append(z)
		out.append({"cells": cl, "h": h, "v": v, "sq": sq, "k": kk})
	return out

func _clear_groups(groups: Array, pivots: Array) -> void:
	var big := false
	var hitset := {}
	for g in groups:
		var cl: Array = g["cells"]
		var sp := -1
		if g["h"] >= 5 or g["v"] >= 5:
			sp = K_BOX
		elif g["h"] >= 3 and g["v"] >= 3:
			sp = K_BOMB
		elif g["h"] == 4 or g["v"] == 4:
			sp = K_ROCKET
		elif g["sq"]:
			sp = K_CHAKRA
		var at: Vector2i = cl[cl.size() / 2]
		for p in pivots:
			if cl.has(p):
				at = p
		if sp >= 0:
			big = true
		for p in cl:
			_hit_neighbours(p.x, p.y, hitset)
			if sp >= 0 and p == at:
				continue
			_clear_tile(p.x, p.y, false, at)
		if sp >= 0:
			var t := tile_at(at.x, at.y)
			if t:
				t.k = sp
				if sp == K_ROCKET:
					t.dir = "v" if g["h"] >= 4 else "h"
				_skin(t)
				t.scale = Vector2(0.4, 0.4)
				create_tween().tween_property(t, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				fx.ring(to_global(cpos(at.x, at.y)), Color(1, 0.85, 0.3), U, 0.35, 5.0)
				sfx.play("tick", 0.5, 1.4)
	sfx.match_sound(casc, big)
	changed.emit()
	await get_tree().create_timer(0.16).timeout

func _hit_neighbours(r: int, c: int, hitset: Dictionary) -> void:
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var a: int = r + d.x
		var b: int = c + d.y
		if a < 0 or a >= R or b < 0 or b >= C:
			continue
		var cell: Dictionary = cells[a][b]
		if cell["ob"] != "":
			var key := "cab%d" % cell["cab"] if cell["ob"] == "cab" else "%d,%d" % [a, b]
			if not hitset.has(key):
				hitset[key] = true
				_damage(a, b)

# remove a cracker (match or blast). A special that is hit fires instead.
func _clear_tile(r: int, c: int, blast: bool, toward: Vector2i = Vector2i(-1, -1)) -> void:
	var t := tile_at(r, c)
	if t == null:
		return
	if blast and t.k >= 6:
		if not t.firing:
			_chain_fire(r, c)
		return
	cells[r][c]["tile"] = null
	var col: Color = COL.get(t.k, Color(1, 0.8, 0.3))
	fx.burst(to_global(cpos(r, c)), col, 10 if blast else 12, 0.9)
	var tw := create_tween().set_parallel()
	tw.tween_property(t, "scale", Vector2(1.25, 1.25), 0.08)
	tw.tween_property(t, "modulate:a", 0.0, 0.14).set_delay(0.04)
	if toward.x >= 0 and not blast:
		tw.tween_property(t, "position", cpos(toward.x, toward.y), 0.12)
	tw.chain().tween_callback(t.queue_free)
	_clear_gold(r, c)

func _clear_gold(r: int, c: int) -> void:
	var cell: Dictionary = cells[r][c]
	if cell["gold"] and cell["ob"] == "":
		cell["gold"] = false
		goal["gold"] = maxi(0, goal.get("gold", 0) - 1)
		var g: Sprite2D = cell["gspr"]
		if g:
			fx.burst(to_global(cpos(r, c)), Color(1, 0.85, 0.3), 8, 0.7)
			var tw := create_tween()
			tw.tween_property(g, "modulate:a", 0.0, 0.25)
			tw.tween_callback(g.queue_free)
		cell["gspr"] = null

func _damage(r: int, c: int) -> void:
	var cell: Dictionary = cells[r][c]
	var ob: String = cell["ob"]
	if ob == "crate" or ob == "steel":
		cell["hp"] -= 1
		var s: Sprite2D = cell["spr"]
		var p := to_global(cpos(r, c))
		if cell["hp"] <= 0:
			cell["ob"] = ""
			goal[ob] = maxi(0, goal.get(ob, 0) - 1)
			fx.burst(p, Color(0.85, 0.5, 0.2), 12, 1.0)
			fx.burst(p, Color(0.9, 0.2, 0.15), 6, 0.8)
			sfx.play("thud", 0.55, randf_range(0.95, 1.1))
			sfx.play("paper", 0.25, 1.2, 0.02, 0.2)
			if s:
				var tw := create_tween().set_parallel()
				tw.tween_property(s, "scale", s.scale * 1.15, 0.08)
				tw.tween_property(s, "modulate:a", 0.0, 0.16)
				tw.chain().tween_callback(s.queue_free)
			cell["spr"] = null
			_open_holes()
		else:
			s.texture = t_crate
			fx.burst(p + Vector2(0, -U * 0.25), Color(0.9, 0.25, 0.2), 10, 0.9)
			sfx.play("thud", 0.45, 1.2)
	elif ob == "cab":
		var cb: Dictionary = cabs[cell["cab"]]
		if cb["hp"] <= 0:
			return
		cb["hp"] -= 1
		var p2: Vector2 = to_global(cb["node"].position)
		if cb["hp"] == 6:
			cb["layers"][2].visible = false
			fx.burst(p2, Color(0.8, 0.95, 1.0), 16, 1.1)
			sfx.play("paper", 0.5, 0.8)
		else:
			goal["cab"] = maxi(0, goal.get("cab", 0) - 1)
			cb["layers"][1].modulate.a = cb["hp"] / 6.0
			fx.burst(p2, Color(1.0, 0.7, 0.25), 12, 1.0)
			sfx.play("pop", 0.5, randf_range(0.9, 1.1))
		var n: Node2D = cb["node"]
		var tw2 := create_tween()
		tw2.tween_property(n, "scale", Vector2(1.06, 0.95), 0.06)
		tw2.tween_property(n, "scale", Vector2.ONE, 0.1)
		if cb["hp"] <= 0:
			fx.burst(p2, Color(0.7, 0.4, 0.15), 22, 1.4)
			fx.ring(p2, Color(1, 0.8, 0.4), U * 1.6)
			sfx.play("thud", 0.8, 0.8)
			var tw3 := create_tween()
			tw3.tween_property(n, "modulate:a", 0.0, 0.2)
			tw3.tween_callback(n.queue_free)
			for a in 2:
				for b in 2:
					cells[cb["r"] + a][cb["c"] + b]["ob"] = ""
					cells[cb["r"] + a][cb["c"] + b]["cab"] = -1
	changed.emit()

func _open_holes() -> void:
	var opened := true
	while opened:
		opened = false
		for r in R:
			for c in C:
				if cells[r][c]["hole"]:
					for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
						if _free(r + d.x, c + d.y):
							cells[r][c]["hole"] = false
							opened = true
							break
	queue_redraw()

# ------------------------------------------------------------------ specials
func _chain_fire(r: int, c: int) -> void:
	var t := tile_at(r, c)
	if t == null or t.firing:
		return
	t.firing = true
	active += 1
	await get_tree().create_timer(0.07).timeout
	await fire(r, c, -1)
	active -= 1

# blast hits one cell: an obstacle takes one hit (once per blast), a cracker is removed
func _blast_cell(r: int, c: int, hitset: Dictionary) -> void:
	if r < 0 or r >= R or c < 0 or c >= C:
		return
	var cell: Dictionary = cells[r][c]
	if not cell["on"] or cell["hole"]:
		return
	if cell["ob"] != "":
		var key := "cab%d" % cell["cab"] if cell["ob"] == "cab" else "%d,%d" % [r, c]
		if not hitset.has(key):
			hitset[key] = true
			_damage(r, c)
		return
	_clear_tile(r, c, true)

func _take(r: int, c: int) -> Tile:
	var t := tile_at(r, c)
	if t:
		cells[r][c]["tile"] = null
		t.firing = true
	return t

func fire(r: int, c: int, color: int) -> void:
	var t := _take(r, c)
	if t == null:
		return
	active += 1
	var p := cpos(r, c)
	var hitset := {}
	_clear_gold(r, c)
	match t.k:
		K_ROCKET:
			await _rocket(t, r, c, t.dir, hitset)
		K_CHAKRA:
			await _chakra(t, r, c, 1, hitset)
		K_BOMB:
			await _bomb(t, r, c, hitset)
		K_BOX:
			await _box(t, r, c, color if color >= 0 else _top_color(), hitset)
	active -= 1

func _rocket(t: Tile, r: int, c: int, dir: String, hitset: Dictionary) -> void:
	sfx.play("rocket", 0.8, randf_range(0.95, 1.05))
	var steps := C if dir == "h" else R
	var a := t
	var b := Tile.new()
	b.spr = Sprite2D.new()
	b.add_child(b.spr)
	b.k = K_ROCKET
	b.dir = dir
	_skin(b)
	b.position = t.position
	tile_layer.add_child(b)
	a.z_index = 5
	b.z_index = 5
	if dir == "h":
		a.spr.rotation = -PI / 2.0
		b.spr.rotation = PI / 2.0
	else:
		b.spr.rotation = PI
	var dist := U * steps
	var d1 := Vector2(-dist, 0) if dir == "h" else Vector2(0, -dist)
	var tw := create_tween().set_parallel()
	tw.tween_property(a, "position", a.position + d1, 0.42)
	tw.tween_property(b, "position", b.position - d1, 0.42)
	for i in range(1, steps):
		var dl := i * 0.035
		get_tree().create_timer(dl).timeout.connect(_rocket_step.bind(r, c, i, dir, hitset))
	_blast_cell(r, c, hitset)
	await get_tree().create_timer(steps * 0.035 + 0.05).timeout
	a.queue_free()
	b.queue_free()

func _rocket_step(r: int, c: int, i: int, dir: String, hitset: Dictionary) -> void:
	for s in [-1, 1]:
		var rr: int = r + (0 if dir == "h" else s * i)
		var cc: int = c + (s * i if dir == "h" else 0)
		if rr >= 0 and rr < R and cc >= 0 and cc < C:
			_blast_cell(rr, cc, hitset)
			if not lite and i % 2 == 0:
				fx.burst(to_global(cpos(rr, cc)), Color(1, 0.75, 0.3), 5, 0.6)

func _chakra(t: Tile, r: int, c: int, rad: int, hitset: Dictionary) -> void:
	sfx.play("chakra", 0.8)
	t.z_index = 5
	var tw := create_tween().set_parallel()
	tw.tween_property(t, "rotation", TAU * 2.0, 0.38)
	tw.tween_property(t, "scale", Vector2(1.35, 1.35), 0.38)
	await tw.finished
	var p := to_global(cpos(r, c))
	fx.ring(p, Color(1, 0.6, 0.9), U * (rad + 0.8), 0.32, 8.0)
	fx.burst(p, Color(1, 0.45, 0.85), 18, 1.2)
	sfx.play("blast", 0.55, 1.15)
	t.queue_free()
	for a in range(-rad, rad + 1):
		for b in range(-rad, rad + 1):
			_blast_cell(r + a, c + b, hitset)
	await get_tree().create_timer(0.12).timeout

func _bomb(t: Tile, r: int, c: int, hitset: Dictionary) -> void:
	sfx.play("sparkler", 0.4, 1.3, 0.0, 0.3)
	t.z_index = 5
	var base := t.position
	for i in 6:
		t.position = base + Vector2(randf_range(-2.5, 2.5), randf_range(-2.5, 2.5))
		await get_tree().create_timer(0.04).timeout
	t.position = base
	var p := to_global(cpos(r, c) + Vector2(U / 2.0, U / 2.0))
	fx.flash(p, Color(1, 0.85, 0.5), U * 2.4, 0.3)
	fx.ring(p, Color(1, 0.7, 0.3), U * 2.6, 0.36, 9.0)
	fx.burst(p, Color(1, 0.6, 0.2), 22, 1.5)
	fx.burst(p, Color(1, 1, 0.8), 12, 1.1)
	sfx.play("atom", 0.9)
	t.queue_free()
	for a in range(-1, 3):
		for b in range(-1, 3):
			_blast_cell(r + a, c + b, hitset)
	await get_tree().create_timer(0.15).timeout

func _top_color() -> int:
	var cnt := {}
	for r in R:
		for c in C:
			var t := tile_at(r, c)
			if t and t.k < 6:
				cnt[t.k] = cnt.get(t.k, 0) + 1
	var best := 0
	var bn := -1
	for k in cnt:
		if cnt[k] > bn:
			bn = cnt[k]
			best = k
	return best

func _box(t: Tile, r: int, c: int, color: int, hitset: Dictionary) -> void:
	var targets := []
	for rr in R:
		for cc in C:
			var x := tile_at(rr, cc)
			if x and x.k == color:
				targets.append(Vector2i(rr, cc))
	targets.shuffle()
	var step := 0.03 if lite else 0.05
	var dur := targets.size() * step + 0.3
	sfx.play("matchbox", 0.8)
	sfx.play("sparkler", 0.35, 1.5, 0.0, dur)
	t.z_index = 5
	var tw := create_tween().set_loops(int(dur / 0.2) + 1)
	tw.tween_property(t, "scale", Vector2(1.2, 1.2), 0.1)
	tw.tween_property(t, "scale", Vector2.ONE, 0.1)
	var from := to_global(cpos(r, c))
	for p in targets:
		var x := tile_at(p.x, p.y)
		if x:
			fx.bolt(from, to_global(cpos(p.x, p.y)), 0.2)
			x.modulate = Color(1.6, 1.6, 1.3)
			sfx.play("tick", 0.3, randf_range(1.6, 2.0))
		await get_tree().create_timer(step).timeout
	await get_tree().create_timer(0.15).timeout
	sfx.play("blast", 0.6, 1.25)
	for p in targets:
		_blast_cell(p.x, p.y, hitset)
	tw.kill()
	t.queue_free()
	await get_tree().create_timer(0.12).timeout

func box_fire(r: int, c: int, color: int) -> void:
	await fire(r, c, color)

# two specials swapped together
func combo(at: Vector2i, oth: Vector2i, ta: Tile, tb: Tile) -> void:
	var ks := [ta.k, tb.k]
	ks.sort()
	var r := at.x
	var c := at.y
	var o := _take(oth.x, oth.y)
	if o:
		o.queue_free()
	var t := _take(r, c)
	active += 1
	var hitset := {}
	sfx.play("finale", 0.6)
	if ks[0] == K_BOX and ks[1] == K_BOX:
		if t:
			t.queue_free()
		fx.flash(to_global(Vector2(C * U / 2.0, R * U / 2.0)), Color(1, 0.9, 0.6), U * 6.0, 0.45)
		for rr in R:
			for cc in C:
				if (rr + cc) % 5 == 0:
					fx.bolt(to_global(cpos(r, c)), to_global(cpos(rr, cc)), 0.25)
		await get_tree().create_timer(0.3).timeout
		for rr in R:
			for cc in C:
				_blast_cell(rr, cc, hitset)
	elif ks[1] == K_BOX:
		var sk: int = ks[0]
		if t:
			t.queue_free()
		var col := _top_color()
		var list := []
		for rr in R:
			for cc in C:
				var x := tile_at(rr, cc)
				if x and x.k == col:
					fx.bolt(to_global(cpos(r, c)), to_global(cpos(rr, cc)), 0.25)
					x.k = sk
					if sk == K_ROCKET:
						x.dir = "h" if randf() < 0.5 else "v"
					_skin(x)
					list.append(Vector2i(rr, cc))
					await get_tree().create_timer(0.04).timeout
		await get_tree().create_timer(0.2).timeout
		for p in list:
			if tile_at(p.x, p.y):
				_chain_fire(p.x, p.y)
				await get_tree().create_timer(0.06).timeout
	elif ks[0] == K_ROCKET and ks[1] == K_ROCKET:
		if t:
			t.dir = "h"
			_skin(t)
			var t2 := Tile.new()
			t2.spr = Sprite2D.new()
			t2.add_child(t2.spr)
			t2.k = K_ROCKET
			t2.dir = "v"
			_skin(t2)
			t2.position = t.position
			tile_layer.add_child(t2)
			_rocket(t2, r, c, "v", hitset)
			await _rocket(t, r, c, "h", hitset)
	elif ks[0] == K_ROCKET:
		# rocket + chakra/bomb: 3 rows and 3 columns
		sfx.play("rocket", 0.9, 0.9)
		if t:
			t.queue_free()
		for i in maxi(R, C):
			for s in [-1, 1]:
				for w in [-1, 0, 1]:
					_blast_cell(r + w, c + s * i, hitset)
					_blast_cell(r + s * i, c + w, hitset)
			await get_tree().create_timer(0.03).timeout
	else:
		# chakra/bomb pairs: a big square blast
		var rad := 2
		if ks[0] == K_BOMB and ks[1] == K_BOMB:
			rad = 3
		var p := to_global(cpos(r, c))
		if t:
			t.queue_free()
		fx.flash(p, Color(1, 0.8, 0.5), U * (rad + 1.5), 0.35)
		fx.ring(p, Color(1, 0.6, 0.3), U * (rad + 1.8), 0.4, 10.0)
		fx.burst(p, Color(1, 0.6, 0.2), 26, 1.7)
		sfx.play("atom", 1.0, 0.9)
		for a in range(-rad, rad + 1):
			for b in range(-rad, rad + 1):
				_blast_cell(r + a, c + b, hitset)
	active -= 1

# ------------------------------------------------------------------ falling and cascades
func _blocked(r: int, c: int) -> bool:
	var cell: Dictionary = cells[r][c]
	return not cell["on"] or cell["hole"] or cell["ob"] != ""

func _gravity() -> void:
	var cols: Array = lv["colors"]
	for c in C:
		var r := R - 1
		while r >= 0:
			if _blocked(r, c):
				r -= 1
				continue
			var bottom := r
			var top := r
			while top - 1 >= 0 and not _blocked(top - 1, c):
				top -= 1
			var write := bottom
			for rr in range(bottom, top - 1, -1):
				var t: Tile = cells[rr][c]["tile"]
				if t:
					if rr != write:
						cells[write][c]["tile"] = t
						cells[rr][c]["tile"] = null
						t.fy += (write - rr) * U
					write -= 1
			var n := write - top + 1
			for i in n:
				var row := write - i
				var k: int = cols[randi() % cols.size()]
				if randf() < float(lv.get("luck", 0.0)) * 0.5:
					var nb := kind(row + 1, c)
					if nb >= 0:
						k = nb
				_new_tile(row, c, k, n * U)
			r = top - 1

func _process(dt: float) -> void:
	if cells.is_empty():
		return
	for r in R:
		for c in C:
			var t: Tile = cells[r][c]["tile"]
			if t == null:
				continue
			if t.fy > 0.0:
				t.v = minf(t.v + GRAV * dt, VMAX)
				var st := t.v * dt
				if t.fy < U * 0.45:
					st *= maxf(0.35, t.fy / (U * 0.45))
				t.fy -= st
				if t.fy <= 0.6:
					t.fy = 0.0
					t.v = 0.0
				t.position = cpos(r, c) - Vector2(0, t.fy)
	if not busy and not over:
		idle_t += dt

func _falling() -> bool:
	for r in R:
		for c in C:
			var t: Tile = cells[r][c]["tile"]
			if t and t.fy > 0.0:
				return true
	return false

func _settle() -> void:
	while true:
		while active > 0:
			await get_tree().process_frame
		_gravity()
		while _falling():
			await get_tree().process_frame
		var g := _find_groups()
		if g.is_empty():
			if active == 0:
				break
			continue
		casc += 1
		await _clear_groups(g, [])

func _end_turn() -> void:
	busy = false
	changed.emit()
	var left := 0
	for k in goal:
		left += goal[k]
	if left == 0:
		over = true
		sfx.play("fanfare", 0.8)
		finished.emit(true)
		return
	if moves <= 0:
		over = true
		sfx.play("lose", 0.6)
		finished.emit(false)
		return
	_ensure_move()

func has_move() -> bool:
	for r in R:
		for c in C:
			var t := tile_at(r, c)
			if t == null:
				continue
			if t.k >= 6:
				return true
			for d in [Vector2i(0, 1), Vector2i(1, 0)]:
				var u := tile_at(r + d.x, c + d.y)
				if u == null or u.k >= 6:
					continue
				var a := t.k
				t.k = u.k
				u.k = a
				var ok := not _find_groups().is_empty()
				u.k = t.k
				t.k = a
				if ok:
					return true
	return false

# no shuffling: if there is no move, quietly recolour one cracker so there is one
func _ensure_move() -> void:
	if has_move():
		return
	var cols: Array = lv["colors"]
	for tries in 200:
		var r := randi() % R
		var c := randi() % C
		var t := tile_at(r, c)
		if t == null or t.k >= 6:
			continue
		var old := t.k
		t.k = cols[randi() % cols.size()]
		if has_move() and _find_groups().is_empty():
			_skin(t)
			return
		t.k = old
