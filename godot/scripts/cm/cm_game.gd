# Crackers Match board: a line-by-line copy of the web game engine (www/fx.js Game + feel.js + flow.js
# + b27.js small pieces + b28.js holes/no-shuffle + b30.js smooth play). Same numbers, same drawing order.
# Board space = the web "board" canvas: 390 x 530, placed at y = 112 on the 390 x 844 screen.
extends Node2D
class_name CMGame

signal moves_changed(n: int)
signal goal_changed(goal: Dictionary)
signal score_changed(v: int)
signal level_won(moves_left: int)
signal level_lost()

const COL := ["#E8123C", "#1E5BFF", "#0DB865", "#2B3FBF", "#8A2BE2", "#FF6A00"]  # fx.js COL (big smash)
const COLS := {0: "#E8343B", 1: "#2F6FE0", 2: "#3DBB4A", 3: "#FFD24A", 4: "#8B5CF6", 5: "#FF8A1A"}  # b27 COLS (small pieces)
const ID := {"rocket": 6, "flowerpot": 7, "chakra": 8, "skyshot": 9, "atom": 10, "sparkler": 11, "wala": 12, "rail": 13, "matchbox": 14}
const OT := {"crate": {"hp": 1, "k": "b"}, "steel": {"hp": 2, "k": "b"}, "gold": {"hp": 1, "k": "f"}, "hole": {"hp": 999, "k": "b"}, "big": {"hp": 999, "k": "b"}}
const FIX := {"big": 1, "crate": 1, "steel": 1, "hole": 1}
const GRAV := 1500.0
const VMAX := 540.0
const SWAP := 0.13

var R := 9
var C := 8
var U := 46
var OX := 11.0
var OY := 82.0
var W := 390.0
var H := 530.0

var lv: Dictionary
var b: Array = []
var fx: Array = []
var ev: Array = []
var polys: Array = []
var clock := 0.0
var stop := 0.0
var flash := 0.0
var dim := 0.0
var busy := false
var over := false
var stopped := false
var paused := false
var moves := 0
var casc := 0
var score := 0
var goal := {}
var fl := {}
var moved := false
var dirty := false
var pq = null
var arm = null
var was_rest := false
var stall := 0.0
var fin_t := 0.0
var holes_done := false
var teach = null
var ended := false
var hl = null
var frame_dt := 0.016

var T: Array = []          # tile pictures by kind (CRK.t)
var IC := {}               # obstacle pictures
var GLOW: Texture2D
var deb: CMDeb
var sfx: Sfx
var lite := false
var floor_node: Node2D

func rnd(a: float, b_: float) -> float:
	return a + randf() * (b_ - a)

# ------------------------------------------------------------------ setup
func _init() -> void:
	for i in 17:
		var p := "res://art/crk/t%d.webp" % i
		T.append(load(p) if ResourceLoader.exists(p) else null)
	for n in ["crate", "crate2", "goldfloor"]:
		IC[n] = load("res://art/%s.webp" % n)
	IC["crate2_top"] = _top_half(IC["crate2"])
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.42, 0.7, 1.0])
	g.colors = PackedColorArray([Color(1, 0.784, 0.235, 0.95), Color(1, 0.667, 0.078, 0.55), Color(1, 0.55, 0, 0.18), Color(1, 0.47, 0, 0)])
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	gt.width = 128
	gt.height = 128
	GLOW = gt
	for i in 10:
		var a := i / 10.0 * 6.283
		var b2 := (i + 1) / 10.0 * 6.283
		var m := (a + b2) / 2.0
		polys.append([Vector2(0.5 + rnd(-0.08, 0.08), 0.5 + rnd(-0.08, 0.08)), Vector2(0.5 + cos(a) * 0.8, 0.5 + sin(a) * 0.8),
			Vector2(0.5 + cos(m) * 0.86, 0.5 + sin(m) * 0.86), Vector2(0.5 + cos(b2) * 0.8, 0.5 + sin(b2) * 0.8)])

# b30 TOP30: the top half of the 2-hit crate (its red plank layer) for its flying pieces
func _top_half(t: Texture2D) -> Texture2D:
	if t == null:
		return null
	var img := t.get_image()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	var y0 := int(img.get_height() * 0.52)
	img.fill_rect(Rect2i(0, y0, img.get_width(), img.get_height() - y0), Color(0, 0, 0, 0))
	return ImageTexture.create_from_image(img)

# levels28.js mk(): map rows -> shape, obstacles, goals
static func make_level(o: Dictionary, idx: int) -> Dictionary:
	var rows: Array = o.rows
	var shape: Array = []
	var ob := {}
	var big: Array = []
	var hide: Array = []
	var pre: Array = []
	var SPK := {"1": 6, "2": 10, "3": 14, "4": 8}
	for r in rows.size():
		var row: String = rows[r]
		var sh := ""
		for c in row.length():
			var ch := row[c]
			sh += "." if ch == "#" else "x"
			if ch == "c": _add(ob, "crate", r, c)
			elif ch == "w": _add(ob, "steel", r, c)
			elif ch == "g": _add(ob, "gold", r, c)
			elif ch == "x":
				_add(ob, "crate", r, c)
				_add(ob, "gold", r, c)
			elif ch == "X":
				_add(ob, "steel", r, c)
				_add(ob, "gold", r, c)
			elif ch == "o": hide.append([r, c])
			elif ch == "K": big.append({"t": "cab", "r": r, "c": c, "w": 2, "h": 2, "n": 6})
			elif SPK.has(ch): pre.append([r, c, SPK[ch]])
		shape.append(sh)
	var L := {"name": o.name, "moves": o.moves, "colors": o.colors, "shape": shape, "ob": ob, "big": big, "goal": {}, "hide": hide,
		"pre": pre, "luck": o.get("luck", 0.0), "teach": o.get("teach", null), "idx": idx, "combo": o.get("combo", null)}
	for bb in big:
		L.goal[bb.t] = L.goal.get(bb.t, 0) + bb.n
	for k in ob:
		L.goal[k] = ob[k].size()
	return L

static func _add(ob: Dictionary, t: String, r: int, c: int) -> void:
	if not ob.has(t):
		ob[t] = []
	ob[t].append([r, c])

func start(level: Dictionary) -> void:
	lv = level
	R = lv.shape.size()
	C = String(lv.shape[0]).length()
	U = int(floor(minf(372.0 / C, (H - 24.0) / R)))
	OX = (390.0 - U * C) / 2.0
	OY = (H - U * R) / 2.0 + maxf(0.0, minf(24.0, (H - U * R) / 2.0 - 6.0))
	moves = lv.moves
	casc = 0
	score = 0
	goal = lv.goal.duplicate()
	over = false
	ended = false
	busy = false
	stopped = false
	fl = {}
	fx.clear()
	ev.clear()
	clock = 0.0
	holes_done = false
	was_rest = false
	pq = null
	arm = null
	if deb:
		deb.clear()
	fresh()
	if floor_node:
		floor_node.queue_free()
	floor_node = CMFloor.new()
	floor_node.g = self
	floor_node.show_behind_parent = true
	add_child(floor_node)
	move_child(floor_node, 0)
	moves_changed.emit(moves)
	goal_changed.emit(goal)
	_prewarm()

# draw every kind of effect once off-screen at the start, so the first real blast does not stutter
func _prewarm() -> void:
	var x := -300.0
	pop(x, 50, "#FFB800", 1.0)
	spark2(x, 50, 4, ["#FFFFFF"], 100)
	ring(x, 50, "#FFFFFF", 30, 4)
	puff(x, 50)
	if T[0] != null:
		deb.small(T[0], x, 50, U)
		deb.chunks(T[0], x, 50, U, 2, 2, 1.0)
	deb.bits(x, 50, 4, ["#FFFFFF"], 5, 1.0)
	fx.append({"k": "shard", "po": polys[0], "im": T[0], "x": x, "y": 50.0, "z": 0.0, "vx": 0.0, "vy": 0.0, "vz": 0.0, "r": 0.0, "vr": 0.0, "f": 0.0, "vf": 0.0, "a": 0.5})
	if sfx:
		sfx.warm()

func tile(k: int) -> Dictionary:
	return {"k": k, "fy": 0.0, "v": 0.0, "p": 0}

func rk() -> int:
	var a: Array = lv.colors
	return a[randi() % a.size()]

func rows() -> int: return R
func cols() -> int: return C
func uu() -> float: return float(U)
func cx(c: float) -> float: return OX + c * U + U / 2.0
func cy(r: float) -> float: return OY + r * U + U / 2.0

func at(t: float, f: Callable) -> void:
	ev.append({"t": clock + t, "f": f})

func at2(r: int, c: int):
	if r >= 0 and r < R and c >= 0 and c < C:
		return b[r][c]
	return null

func hole(r: int, c: int) -> bool:
	return String(lv.shape[r])[c] == "."

# ------------------------------------------------------------------ level start (fx.js fresh chain + b28 fresh)
func _fresh_base() -> void:
	b = []
	for r in R:
		var row: Array = []
		for c in C:
			var k := 0
			while true:
				k = randi() % 6
				if not ((c > 1 and row[c - 1].k == k and row[c - 2].k == k) or (r > 1 and b[r - 1][c].k == k and b[r - 2][c].k == k)):
					break
			row.append(tile(k))
		b.append(row)

func fresh() -> void:
	var t := 0
	while true:
		_fresh_base()
		for r in R:
			for c in C:
				if hole(r, c):
					b[r][c] = null
				else:
					b[r][c].k = rk()
		var fix: Array = find()
		var g := 0
		while not fix.is_empty() and g < 400:
			g += 1
			for p in fix[0].cells:
				b[p[0]][p[1]].k = rk()
			fix = find()
		t += 1
		if not ((not find().is_empty()) or not has_move()) or t >= 60:
			break
	stamp()
	for tt in lv.ob:
		for p in lv.ob[tt]:
			var e = at2(p[0], p[1])
			if e == null:
				continue
			if OT[tt].k == "f":
				fl["%d,%d" % [p[0], p[1]]] = {"t": tt, "hp": OT[tt].hp}
			else:
				e.ob = {"t": tt, "hp": OT[tt].hp, "sq": 0.0, "fl": 0.0}
	var q := 0
	while not has_move() and q < 30:
		q += 1
		shuffle()
	# fresh0 wrap: a special move is always there at the start
	var all: Array = []
	for r in R:
		for c in C:
			if at2(r, c) != null:
				all.append([r, c])
	if spmoves().is_empty():
		nudge(all, true)
	# b28: hidden holes, placed specials, no shuffle
	for p in lv.hide:
		var e = at2(p[0], p[1])
		if e != null:
			e.ob = {"t": "hole", "hp": 999, "sq": 0.0, "fl": 0.0}
			e.k = -3
	for p in lv.pre:
		var e = at2(p[0], p[1])
		if e != null and not e.has("ob"):
			e.k = p[2]
	make_move()

# b28 lesson patterns in the free top rows
func stamp() -> void:
	var tt = lv.get("teach")
	if tt == null:
		return
	var a: int = lv.colors[0]
	var bb: int = lv.colors[1]
	var M := {"rocket": {"put": [[0, 1], [0, 2], [0, 4], [1, 3]], "not": [0, 3], "mv": [1, 3, -1, 0]},
		"line5": {"put": [[0, 1], [0, 2], [0, 4], [0, 5], [1, 3]], "not": [0, 3], "mv": [1, 3, -1, 0]},
		"square": {"put": [[0, 1], [0, 2], [1, 1], [1, 3]], "not": [1, 2], "mv": [1, 3, 0, -1]},
		"lshape": {"put": [[0, 1], [0, 3], [0, 4], [1, 2], [2, 2]], "not": [0, 2], "mv": [1, 2, -1, 0]}}
	if not M.has(tt):
		return
	var m: Dictionary = M[tt]
	for p in m.put + [m.not]:
		var e = at2(p[0], p[1])
		if e == null or e.has("ob") or e.k >= 6:
			return
	var keep := {}
	for p in m.put:
		b[p[0]][p[1]].k = a
		keep[str(p)] = 1
	b[m.not[0]][m.not[1]].k = bb
	keep[str(m.not)] = 1
	var g := 0
	var f: Array = find()
	while not f.is_empty() and g < 300:
		g += 1
		for q in f:
			for p in q.cells:
				if not keep.has(str(p)):
					var e = b[p[0]][p[1]]
					if e != null and not e.has("ob") and e.k < 6:
						e.k = rk()
		f = find()
	teach = m.mv

# ------------------------------------------------------------------ rules
func stuck(e) -> bool:
	return e.has("ob")

func fixed(e) -> bool:
	return e != null and e.has("ob") and FIX.has(e.ob.t)

func rest(e) -> bool:
	return e != null and not e.get("dead", false) and not e.get("firing", false) and not e.get("swp", false) and not e.get("top", false) and not (e.fy > 0)

# fx.js kind + flow.js kind: only resting, plain crackers can match
func kind(r: int, c: int) -> int:
	var e = at2(r, c)
	if e == null or e.get("dead", false) or e.has("ob") or e.k >= 6 or e.k < 0:
		return -1
	return e.k if rest(e) else -1

func raw_k(r: int, c: int) -> int:
	if r < 0 or c < 0 or r >= R or c >= C:
		return -1
	var e = b[r][c]
	if e != null and not e.get("dead", false) and not e.has("ob") and not e.get("diya", false) and e.k >= 0 and e.k < 6:
		return e.k
	return -1

func find() -> Array:
	var M := {}
	var Hh := {}
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
					Hh[Vector2i(r, c + i)] = n
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
	var Sq := {}
	for r in R - 1:
		for c in C - 1:
			var k := kind(r, c)
			if k >= 0 and kind(r, c + 1) == k and kind(r + 1, c) == k and kind(r + 1, c + 1) == k:
				for p in [Vector2i(r, c), Vector2i(r, c + 1), Vector2i(r + 1, c), Vector2i(r + 1, c + 1)]:
					M[p] = k
					Sq[p] = 1
	var seen := {}
	var out: Array = []
	for s0 in M.keys():
		if seen.has(s0):
			continue
		var st: Array = [s0]
		var cells: Array = []
		var h := 0
		var v := 0
		var sq := false
		var kk: int = M[s0]
		seen[s0] = 1
		while not st.is_empty():
			var q: Vector2i = st.pop_back()
			cells.append([q.x, q.y])
			h = maxi(h, Hh.get(q, 0))
			v = maxi(v, V.get(q, 0))
			sq = sq or Sq.has(q)
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var z: Vector2i = q + d
				if M.get(z, -9) == kk and not seen.has(z):
					seen[z] = 1
					st.append(z)
		out.append({"cells": cells, "h": h, "v": v, "sq": sq, "k": kk})
	return out

func has_move() -> bool:
	for r in R:
		for c in C:
			var e = b[r][c]
			if e == null:
				continue
			if e.k >= 6:
				return true
			for o in [[r, c + 1], [r + 1, c]]:
				var f = at2(o[0], o[1])
				if f == null or stuck(e) or stuck(f):
					continue
				var t: int = e.k
				e.k = f.k
				f.k = t
				var ok := not find().is_empty()
				f.k = e.k
				e.k = t
				if ok:
					return true
	return false

func shuffle() -> void:
	var L: Array = []
	for r in R:
		for c in C:
			var e = b[r][c]
			if e != null and e.k < 6 and e.k >= 0 and not e.has("ob"):
				L.append(e)
	var g := 0
	while true:
		var ks: Array = []
		for e in L:
			ks.append(e.k)
		ks.shuffle()
		for i in L.size():
			L[i].k = ks[i]
		g += 1
		if not ((not find().is_empty()) or not has_move()) or g >= 80:
			break

# b28: no shuffling; quietly recolour one tile to make a move
func make_move() -> bool:
	if has_move():
		return true
	var L: Array = []
	for r in R:
		for c in C:
			var e = b[r][c]
			if e != null and not e.has("ob") and not e.get("diya", false) and e.k >= 0 and e.k < 6:
				L.append(e)
	L.shuffle()
	for e in L:
		var k0: int = e.k
		for k in lv.colors:
			if k == k0:
				continue
			e.k = k
			if find().is_empty() and has_move():
				e.shakeT = 0.3
				return true
		e.k = k0
	return false

func run_at(r: int, c: int):
	var k := kind(r, c)
	if k < 0:
		return null
	var h := 1
	var v := 1
	var i := 1
	while kind(r, c + i) == k: h += 1; i += 1
	i = 1
	while kind(r, c - i) == k: h += 1; i += 1
	i = 1
	while kind(r + i, c) == k: v += 1; i += 1
	i = 1
	while kind(r - i, c) == k: v += 1; i += 1
	var sq := false
	for d in [[0, 0], [0, -1], [-1, 0], [-1, -1]]:
		var a: int = r + d[0]
		var bb: int = c + d[1]
		if kind(a, bb) == k and kind(a, bb + 1) == k and kind(a + 1, bb) == k and kind(a + 1, bb + 1) == k:
			sq = true
	return {"h": h, "v": v, "sq": sq}

func is_sp(m) -> bool:
	return m != null and (m.h >= 4 or m.v >= 4 or (m.h >= 3 and m.v >= 3) or m.sq)

func spmoves() -> Array:
	var out: Array = []
	for r in R:
		for c in C:
			for d in 2:
				var r2 := r + d
				var c2 := c + 1 - d
				var e = at2(r, c)
				var f = at2(r2, c2)
				if e == null or f == null or e.k < 0 or f.k < 0 or e.k >= 6 or f.k >= 6 or stuck(e) or stuck(f) or e.k == f.k:
					continue
				var t: int = e.k
				e.k = f.k
				f.k = t
				if is_sp(run_at(r, c)) or is_sp(run_at(r2, c2)):
					out.append({"r": r, "c": c, "dr": d, "dc": 1 - d})
				f.k = e.k
				e.k = t
	return out

func makes(r: int, c: int) -> bool:
	var k := kind(r, c)
	if k < 0:
		return false
	var m = run_at(r, c)
	if m.h >= 3 or m.v >= 3:
		return true
	return m.sq

func calm_lv() -> float:
	var i: int = lv.get("idx", 0)
	return 0.8 if i < 10 else (0.7 if i < 30 else 0.6)

func nudge(cells: Array, keep_clean: bool) -> bool:
	for t in 70:
		var p = cells[randi() % cells.size()]
		var e = at2(p[0], p[1])
		if e == null or e.has("ob") or e.k < 0 or e.k >= 6:
			continue
		var old: int = e.k
		e.k = rk()
		if keep_clean and not find().is_empty():
			e.k = old
			continue
		if not spmoves().is_empty():
			return true
	return false

func left() -> int:
	var n := 0
	for k in goal:
		n += maxi(0, goal[k])
	return n

func add_score(n: int) -> void:
	score += n
	score_changed.emit(score)

func count(k, r = null, c = null) -> void:
	var key = str(k)
	if goal.get(key, 0) > 0:
		goal[key] -= 1
		goal_changed.emit(goal)

func sync() -> void:
	var n := {}
	var ch := false
	for t in OT:
		n[t] = 0
	for r in R:
		for c in C:
			var e = b[r][c]
			if e != null and e.has("ob"):
				n[e.ob.t] = n.get(e.ob.t, 0) + 1
	for k in fl:
		n[fl[k].t] = n.get(fl[k].t, 0) + 1
	for t in OT:
		if goal.has(t) and goal[t] != n[t]:
			goal[t] = n[t]
			ch = true
	if ch:
		goal_changed.emit(goal)

# ------------------------------------------------------------------ effects (fx.js)
func ring(x: float, y: float, col: String, size: float = 70.0, w: float = 8.0) -> void:
	fx.append({"k": "ring", "x": x, "y": y, "a": 0.0, "col": Color(col), "sz": size, "w": w, "l": 0.32})

# b30 cut: fewer pieces per blast, fewer still when busy or on a light phone
func _cut(n: int) -> int:
	var L := fx.size()
	if L > 160: return maxi(1, ceili(n * 0.12))
	if L > 120 or lite: return maxi(1, ceili(n * 0.3))
	return maxi(1, ceili(n * 0.5))

func spark(x: float, y: float, n: int, col, sp: float = 330.0, up: float = 60.0) -> void:
	n = _cut(n)
	for i in n:
		var a := randf() * 6.283
		var v := rnd(0.3, 1.0) * sp
		var cc = col if col is String else col[i % col.size()]
		fx.append({"k": "spark", "x": x, "y": y, "vx": cos(a) * v, "vy": sin(a) * v - up, "col": Color(cc), "a": 0.0, "l": rnd(0.3, 0.65)})

func spark2(x: float, y: float, n: int, cols: Array, sp: float, life: float = 0.0) -> void:
	for i in n:
		var a := randf() * 6.283
		var v := rnd(0.3, 1.0) * sp
		fx.append({"k": "spark", "x": x, "y": y, "vx": cos(a) * v, "vy": sin(a) * v, "col": Color(cols[i % cols.size()]), "a": 0.0, "l": life if life > 0.0 else rnd(0.3, 0.5)})

func burst(x: float, y: float, cols: Array, n: int, sp: float = 300.0) -> void:
	n = _cut(n)
	for i in n:
		var a := float(i) / n * 6.283
		var v := sp * rnd(0.72, 1.0)
		fx.append({"k": "spark", "x": x, "y": y, "vx": cos(a) * v, "vy": sin(a) * v, "col": Color(cols[i % cols.size()]), "a": 0.0, "l": rnd(0.5, 0.8), "g": 320.0, "w": 3.4})
	ring(x, y, cols[0], 130, 9)

func puff(x: float, y: float, col: String = "#FFFFFF", r: float = 10.0) -> void:
	fx.append({"k": "puff", "x": x, "y": y, "r": r, "col": Color(col), "a": 0.0, "l": 0.45, "vy": -rnd(8, 28), "vx": rnd(-14, 14)})

func obj(fn: Callable, l: float) -> void:
	fx.append({"k": "obj", "fn": fn, "a": 0.0, "l": l})

func pop(x: float, y: float, col: String, pw: float) -> void:
	var cc := Color(col)
	obj(func(t, dt):
		var q := minf(t / 0.2, 1.0)
		var rr := 14.0 + 30.0 * pw * sqrt(q)
		var al := 1.0 - q
		draw_circle(Vector2(x, y), rr, Color("#FF7A1A", al))
		draw_circle(Vector2(x, y), rr * 0.74, Color(cc, al))
		draw_circle(Vector2(x, y), rr * 0.48, Color("#FFE16B", al))
		draw_circle(Vector2(x, y), rr * 0.24, Color(1, 1, 1, al))
		return q < 1.0, 0.2)

# ------------------------------------------------------------------ hits
func hit(r: int, c: int, o: Dictionary = {}) -> void:
	var e = at2(r, c)
	if e == null:
		return
	# feel.js: a special hit by another special fires at once (step 2)
	if e.k >= 6 and not e.get("firing", false) and not e.get("dead", false) and not e.has("ob") and not (e.get("safe", 0.0) > clock):
		var d: float = o.get("d", 0.0)
		e.firing = true
		e.shakeT = 0.12
		at(d + 0.04, func():
			var f = at2(r, c)
			if not is_same(f, e):
				return
			busy = true
			go(r, c, e.k, 0, 0))
		return
	var ok: bool = not e.get("dead", false) and not e.get("diya", false) and not (e.get("safe", 0.0) > clock) and not e.has("ob") and not (e.k >= 6 and not e.get("firing", false))
	if e.get("dead", false) or e.get("diya", false) or e.get("safe", 0.0) > clock:
		return
	if e.has("ob"):
		hit_ob(e, [r, c], true)
		return
	if e.k >= 6 and not e.get("firing", false):
		e.queued = true
		return
	e.dead = true
	e.p = 1
	var dd: float = o.get("d", 0.0)
	if dd == 0.0:
		dd = 0.05
	at(dd, smash.bind(r, c, o))
	if ok:
		add_score(roundi(30.0 * (1.0 + minf(casc, 6) * 0.4)))

func smash(r: int, c: int, o: Dictionary = {}) -> void:
	var e = b[r][c]
	if e == null:
		return
	if e.has("ob"):
		hit_ob(e, [r, c], true)
		return
	if e.k < 6 and e.k >= 0:
		count(e.k, r, c)
	hit_fl(r, c)
	var x := cx(c)
	var y := cy(r)
	var lite_hit: bool = not (o.get("pw", 1.0) > 1.0) and not o.get("d2", false)
	if lite_hit:
		# b27 "small pieces": a soft pop, two halves of the cracker, a few specks
		var col: String = COLS.get(e.k, "#FFB800")
		pop(x, y, col, 0.35)
		if e.k >= 0 and e.k < T.size() and T[e.k] != null:
			deb.small(T[e.k], x, y + 0.0, U)
		spark(x, y, 3, [col, "#FFFFFF"], 190)
		b[r][c] = null
		return
	# fx.js big smash (special hits)
	var col2: String = COL[e.k] if e.k >= 0 and e.k < 6 else "#FFB800"
	var pw: float = o.get("pw", 1.0) * 1.25
	pop(x, y, col2, pw)
	for po in polys:
		var mx: float = (po[1].x + po[3].x) / 2.0 - 0.5
		var my: float = (po[1].y + po[3].y) / 2.0 - 0.5
		var v := rnd(190, 360) * pw
		fx.append({"k": "shard", "po": po, "im": T[e.k] if e.k >= 0 and e.k < T.size() else null, "x": x, "y": y, "z": 0.0,
			"vx": mx * v * 1.5 + o.get("dx", 0.0), "vy": my * v * 1.5 - 90.0 + o.get("dy", 0.0), "vz": rnd(160, 420) * pw,
			"r": 0.0, "vr": rnd(-14, 14), "f": rnd(0, 6), "vf": rnd(7, 16), "a": 0.0})
	spark(x, y, 20, [col2, "#FFFFFF", "#FFD24A", "#FF7A1A"], 360.0 * pw)
	ring(x, y, "#FFC62B", U * 0.8, 4)
	b[r][c] = null

func hit_ob(e: Dictionary, p: Array, blast_: bool) -> void:
	if not e.has("ob"):
		return
	var o: Dictionary = e.ob
	var t: String = o.t
	if t == "hole" or t == "big":
		return
	if e.get("safe", 0.0) > clock:
		return
	var x := cx(p[1])
	var y := cy(p[0])
	var S := U - 4.0
	var Lx := x - S / 2.0
	var Ty := y - S / 2.0
	var pw := 1.3 if blast_ else 1.0
	e.safe = clock + 0.3
	o.hp -= 1
	o.sq = 1.0
	o.fl = 1.0
	var dead: bool = o.hp <= 0
	ring(x, y, "#FFFFFF", S * 0.9, 5)
	if sfx:
		if dead:
			sfx.play("thud", 1.0, 1.0 - OT[t].hp * 0.06)
		else:
			sfx.play("paper", 0.7, 1.1)
	if t == "crate" or (t == "steel" and dead):
		deb.chunks(IC.crate, Lx, Ty, S, 1, 4, pw, {"poly": false})
		deb.bits(x, y, 10, ["#B9772F", "#8A5520", "#E8123C"], 6, pw)
	elif t == "steel":
		deb.bits(x, Ty + S * 0.25, 10, ["#E8402C", "#FFD24A", "#B0700C"], 5, 1)
		deb.chunks(IC.crate2_top, Lx, Ty, S, 2, 2, 1.1, {"poly": false})
	if dead:
		e.erase("ob")
		sync()

func hit_fl(r: int, c: int) -> void:
	var key := "%d,%d" % [r, c]
	if not fl.has(key):
		return
	var f: Dictionary = fl[key]
	if f.get("safe", 0.0) > clock:
		return
	f.safe = clock + 0.3
	f.hp -= 1
	var x := cx(c)
	var y := cy(r)
	var S := U - 4.0
	if f.t == "gold":
		deb.chunks(IC.goldfloor, x - S / 2, y - S / 2, S, 2, 2, 0.9, {"g": 1100.0})
		spark(x, y, 16, ["#FFF3B0", "#FFD24A", "#FFFFFF"], 240)
		ring(x, y, "#FFE58A", S * 0.8, 4)
	if sfx:
		sfx.play("paper", 0.6)
	if f.hp <= 0:
		fl.erase(key)
		sync()

# ------------------------------------------------------------------ a match
func blast(g: Array, pref) -> void:
	var mk := false
	var seen := {}
	for q in g:
		for p in q.cells:
			for d in [[1, 0], [-1, 0], [0, 1], [0, -1]]:
				var a: int = p[0] + d[0]
				var bb: int = p[1] + d[1]
				var e = at2(a, bb)
				var id := "%d,%d" % [a, bb]
				if e != null and e.has("ob") and not seen.has(id):
					seen[id] = 1
					hit_ob(e, [a, bb], false)
				if e != null and not seen.has("f" + id):
					seen["f" + id] = 1
					hit_fl(a, bb)
	for q in g:
		var type = null
		if ended: pass
		elif maxi(q.h, q.v) >= 5: type = "matchbox"
		elif q.h >= 3 and q.v >= 3: type = "atom"
		elif q.h == 4 or q.v == 4: type = "rocket"
		elif q.sq: type = "chakra"
		var need := {"rocket": 1, "matchbox": 2, "chakra": 4, "atom": 7}
		if type != null and lv.get("idx", 0) < need.get(type, 0):
			type = null
		var sp = null
		if type != null:
			if pref != null:
				for p in pref:
					if sp == null:
						for z in q.cells:
							if z[0] == p[0] and z[1] == p[1]:
								sp = p
			if sp == null:
				sp = q.cells[q.cells.size() >> 1]
		var i := 0
		for p in q.cells:
			var e = b[p[0]][p[1]]
			if e == null:
				i += 1
				continue
			if e.has("ob"):
				hit_ob(e, p, false)
				i += 1
				continue
			if sp != null and p[0] == sp[0] and p[1] == sp[1]:
				hit_fl(p[0], p[1])
				count(q.k, p[0], p[1])
				e.k = (15 if q.h == 4 else (6 if q.v == 4 else 15)) if type == "rocket" else ID[type]
				e.safe = clock + 0.5
				ring(cx(p[1]), cy(p[0]), "#FFC62B", U * 1.6, 9)
				burst(cx(p[1]), cy(p[0]), ["#FFD24A", "#FFFFFF", "#FF7A1A"], 18, 260)
				flash = maxf(flash, 0.25)
				mk = true
				add_score(150)
			else:
				hit(p[0], p[1], {"d": 0.02 + i * 0.016})
			i += 1
	if sfx:
		var n := 0
		for q in g:
			if n >= 4:
				break
			sfx.match_sound(casc, q.cells.size() >= 4)
			n += 1
		if mk:
			sfx.play("sparkler", 0.4, 1.6, 0.0, 0.22)
	finish(0.24)

func finish(t: float) -> void:
	fin_t = maxf(fin_t, clock + t)

# specials (step 2)
func go(r: int, c: int, k: int, dr: int, dc: int) -> void:
	var e = at2(r, c)
	if e != null:
		e.firing = true
	at(0.1, func():
		var f = at2(r, c)
		if f != null:
			f.firing = false
			f.k = randi() % 3
			hit(r, c, {"d": 0.0, "pw": 1.2}))

# ------------------------------------------------------------------ flow.js: gravity, falling, swaps
func mov(e) -> bool:
	return not e.get("dead", false) and not e.get("firing", false) and not e.get("swp", false) and not e.get("top", false) and not fixed(e)

func gravity() -> bool:
	var moved_any := false
	var born: Array = []
	for c in C:
		var r := R - 1
		var spawn := 0
		while r >= 0:
			if hole(r, c):
				r -= 1
				continue
			var e = b[r][c]
			if e != null:
				r -= 1
				continue
			var q := r - 1
			var src := -1
			var top := true
			var bar := -1
			while q >= 0:
				if hole(q, c):
					q -= 1
					continue
				var f = b[q][c]
				if f != null:
					if mov(f): src = q
					elif fixed(f): bar = q
					else: top = false
					break
				q -= 1
			if src >= 0:
				var f2 = b[src][c]
				b[r][c] = f2
				b[src][c] = null
				if not (f2.fy > 0):
					f2.wt = 0.0
				f2.fy = f2.fy + (r - src) * U
				f2.bo = 0.0
				moved_any = true
				r -= 1
				continue
			if top:
				var n := tile(rk())
				n.fy = ((r - bar) * U * 0.6 if bar >= 0 else (r + 1) * U + U * 0.15) + spawn * U
				n.v = 0.0
				n.fresh = 1
				n.wt = 0.0
				b[r][c] = n
				born.append([r, c])
				spawn += 1
				moved_any = true
				r -= 1
				continue
			r -= 1
	if not born.is_empty():
		luck(born)
	return moved_any

# b27 lucky refills
func shape_sc(r: int, c: int) -> Dictionary:
	var k := raw_k(r, c)
	if k < 0:
		return {"sc": 0}
	var h: Array = [[r, c]]
	var v: Array = [[r, c]]
	var sq: Array = []
	var i := c - 1
	while raw_k(r, i) == k: h.append([r, i]); i -= 1
	i = c + 1
	while raw_k(r, i) == k: h.append([r, i]); i += 1
	i = r - 1
	while raw_k(i, c) == k: v.append([i, c]); i -= 1
	i = r + 1
	while raw_k(i, c) == k: v.append([i, c]); i += 1
	for a in [-1, 0]:
		for bb in [-1, 0]:
			if raw_k(r + a, c + bb) == k and raw_k(r + a + 1, c + bb) == k and raw_k(r + a, c + bb + 1) == k and raw_k(r + a + 1, c + bb + 1) == k:
				sq = [[r + a, c + bb], [r + a + 1, c + bb], [r + a, c + bb + 1], [r + a + 1, c + bb + 1]]
	var sc := 4 if (h.size() >= 5 or v.size() >= 5) else (3 if (h.size() >= 3 and v.size() >= 3) else (2 if (h.size() == 4 or v.size() == 4) else (2 if not sq.is_empty() else 0)))
	return {"sc": sc, "cells": h + v + sq}

func luck(born: Array) -> void:
	var p: float = lv.get("luck", 0.0)
	if p <= 0.0 or ended or over or randf() > p:
		return
	var sp: Array = []
	for r in R:
		for c in C:
			var e = b[r][c]
			if e != null and not e.get("dead", false) and not e.has("ob") and e.k >= 6:
				sp.append([r, c])
	var best = null
	var bs := 0.0
	var near := randf() < 0.5
	for q in born:
		var n = b[q[0]][q[1]]
		if n == null or n.k >= 6:
			continue
		var k0: int = n.k
		for k in lv.colors:
			n.k = k
			var sh := shape_sc(q[0], q[1])
			if sh.sc > 0:
				var sc: float = sh.sc + randf()
				if near and not sp.is_empty():
					var d := 99
					for a in sh.cells:
						for z in sp:
							d = mini(d, absi(a[0] - z[0]) + absi(a[1] - z[1]))
					if d <= 1:
						sc += 10
				if sc > bs:
					bs = sc
					best = [q, k]
		n.k = k0
	if best != null:
		var n = b[best[0][0]][best[0][1]]
		n.k = best[1]
		n.lucky = 1

func fall(dt: float) -> Dictionary:
	var landed := false
	var any := false
	for r in R:
		for c in C:
			var e = b[r][c]
			if e == null:
				continue
			if e.fy > 0:
				any = true
				if e.get("wt", 0.0) > 0.0:
					e.wt -= dt
					continue
				e.v = minf(e.v + GRAV * dt, VMAX)
				var st: float = e.v * dt
				if e.fy < U * 0.45:
					st *= maxf(0.35, e.fy / (U * 0.45))
				e.fy -= st
				if e.fy <= 0.6:
					e.fy = 0.0
					e.v = 0.0
					e.bo = 0.0
					landed = true
					if e.get("fresh", 0):
						e.fresh = 0
						calm(r, c, e)
			elif e.get("bo", 0.0) > 0.0:
				e.bo = maxf(0.0, e.bo - dt)
	return {"landed": landed, "any": any}

func calm(r: int, c: int, e: Dictionary) -> void:
	if e.get("lucky", 0):
		e.lucky = 0
		return
	if ended or e.k < 0 or e.k >= 6 or randf() > calm_lv():
		return
	var kk: int = e.k
	var t := 0
	while t < 6 and makes(r, c):
		e.k = rk()
		t += 1
	if makes(r, c):
		e.k = kk

func settled() -> bool:
	if not ev.is_empty():
		return false
	for f in fx:
		if f.k == "obj":
			return false
	for r in R:
		for c in C:
			var e = b[r][c]
			if e == null:
				if not hole(r, c):
					return false
				continue
			if e.fy > 0 or e.get("dead", false) or e.get("firing", false) or e.get("swp", false) or e.get("top", false):
				return false
	return true

static func back(t: float) -> float:
	var c1 := 1.4
	var c3 := c1 + 1.0
	return 1.0 + c3 * pow(t - 1.0, 3) + c1 * pow(t - 1.0, 2)

func swap(r: int, c: int, tr: int, tc: int, done: Callable) -> void:
	var a = b[r][c]
	var n = b[tr][tc]
	var dx := tc - c
	var dy := tr - r
	b[r][c] = n
	b[tr][tc] = a
	a.swp = true
	a.top = true
	a.lift = 0.0
	if n != null:
		n.swp = true
	obj(func(t, dt):
		var f := minf(t / SWAP, 1.0)
		var e := back(f)
		a.sx = -dx * (1.0 - e)
		a.sy = -dy * (1.0 - e)
		a.lift = sin(f * PI)
		if n != null:
			n.sx = dx * (1.0 - e)
			n.sy = dy * (1.0 - e)
		if f >= 1.0:
			a.sx = 0.0
			a.sy = 0.0
			a.top = false
			a.lift = 0.0
			a.swp = false
			if n != null:
				n.sx = 0.0
				n.sy = 0.0
				n.swp = false
			done.call(is_same(b[tr][tc], a), n != null and is_same(b[r][c], n))
			return false
		return true, SWAP + 0.05)

func spend() -> void:
	moved = true
	hl = null
	moves -= 1
	casc = 0
	teach = null
	moves_changed.emit(moves)

func act(r: int, c: int, dr: int, dc: int, retry: bool = false) -> void:
	if over or moves <= 0 or stopped or paused:
		return
	var e = at2(r, c)
	var t = at2(r + dr, c + dc)
	if e == null:
		return
	if stuck(e):
		if sfx: sfx.play("nope", 0.5)
		return
	if not rest(e):
		if not retry: later(r, c, dr, dc)
		return
	if t == null:
		if e.k >= 6: use(r, c, 0, 0)
		return
	if stuck(t):
		if e.k >= 6: use(r, c, 0, 0)
		elif sfx: sfx.play("nope", 0.5)
		return
	if not rest(t):
		if not retry: later(r, c, dr, dc)
		return
	if e.k >= 6:
		use(r, c, dr, dc)
		return
	if t.k >= 6:
		use(r + dr, c + dc, -dr, -dc)
		return
	var r2 := r + dr
	var c2 := c + dc
	if sfx: sfx.play("swap", 0.6)
	swap(r, c, r2, c2, func(okA, okB):
		var g: Array = []
		for q in find():
			for p in q.cells:
				if (p[0] == r and p[1] == c) or (p[0] == r2 and p[1] == c2):
					g.append(q)
					break
		if g.is_empty():
			if okA and okB:
				if sfx: sfx.play("nope", 0.5)
				swap(r2, c2, r, c, func(_a, _b): pass)
			return
		spend()
		blast(g, [[r2, c2], [r, c]]))

func later(r: int, c: int, dr: int, dc: int) -> void:
	pq = {"r": r, "c": c, "dr": dr, "dc": dc, "t": clock}

func tap_sp(r: int, c: int) -> void:
	var e = at2(r, c)
	if e == null or e.k < 6 or over or moves <= 0:
		return
	if rest(e) and not e.get("queued", false):
		use(r, c, 0, 0)
	else:
		pq = {"r": r, "c": c, "tap": 1, "t": clock}

func use(r: int, c: int, dr: int, dc: int) -> void:
	var e = b[r][c]
	spend()
	go(r, c, e.k, dr, dc)

# ------------------------------------------------------------------ end of turn (fx.js onDone + b28)
func on_done() -> void:
	if not over and not has_move():
		make_move()
	sync()
	if over:
		return
	if left() == 0:
		over = true
		busy = true
		level_won.emit(moves)
		return
	if fire_next():
		return
	var g := find()
	if not g.is_empty():
		casc += 1
		busy = true
		blast(g, null)
		return
	if moved:
		moved = false
		if left() == 0:
			over = true
			busy = true
			level_won.emit(moves)
			return
	if moves <= 0:
		over = true
		busy = true
		level_lost.emit()
		return

func fire_next() -> bool:
	for r in R:
		for c in C:
			var e = b[r][c]
			if e != null and e.get("queued", false):
				e.queued = false
				busy = true
				go(r, c, e.k, 0, 0)
				return true
	return false

# b28 hidden holes open when a neighbour opens
func open_holes() -> void:
	var L: Array = lv.hide
	if L.is_empty() or holes_done:
		return
	var open: Array = []
	for p in L:
		if not _is_hole(p[0], p[1]):
			continue
		for d in [[1, 0], [-1, 0], [0, 1], [0, -1]]:
			var r: int = p[0] + d[0]
			var c: int = p[1] + d[1]
			if r < 0 or c < 0 or r >= R or c >= C or hole(r, c):
				continue
			var e = b[r][c]
			if not _is_hole(r, c) and (e == null or not e.has("ob")):
				open.append(p)
	if open.is_empty():
		return
	var seen := {}
	var q: Array = open.duplicate()
	while not q.is_empty():
		var p = q.pop_back()
		var k := str(p)
		if seen.has(k) or not _is_hole(p[0], p[1]):
			continue
		seen[k] = 1
		b[p[0]][p[1]] = null
		spark(cx(p[1]), cy(p[0]), 6, ["#FFD24A", "#FFFFFF"], 140)
		for d in [[1, 0], [-1, 0], [0, 1], [0, -1]]:
			q.append([p[0] + d[0], p[1] + d[1]])
	var any := false
	for p in L:
		if _is_hole(p[0], p[1]):
			any = true
	if not any:
		holes_done = true
	if sfx: sfx.play("pop", 0.4)

func _is_hole(r: int, c: int) -> bool:
	var e = at2(r, c)
	return e != null and e.has("ob") and e.ob.t == "hole"

# ------------------------------------------------------------------ frame
func _process(delta: float) -> void:
	if b.is_empty() or stopped:
		return
	var dt := minf(delta, 0.04)
	if stop > 0.0:
		stop -= dt
		dt *= 0.06
	frame_dt = dt
	open_holes()
	gravity()
	var f := fall(dt)
	if not over and not paused:
		if f.landed or dirty:
			dirty = false
			var g := find()
			if not g.is_empty():
				casc += 1
				blast(g, null)
		if pq != null:
			if clock - pq.t > 1.2:
				pq = null
			else:
				var e = at2(pq.r, pq.c)
				if e != null and rest(e):
					var q = pq
					pq = null
					if q.has("tap"): tap_sp(q.r, q.c)
					else: act(q.r, q.c, q.dr, q.dc, true)
	clock += dt
	var due: Array = []
	var rest_ev: Array = []
	for e in ev:
		if e.t <= clock: due.append(e)
		else: rest_ev.append(e)
	ev = rest_ev
	for e in due:
		e.f.call()
	flash *= 0.84
	queue_redraw()
	var st := settled()
	if st:
		stall = 0.0
		if not was_rest:
			was_rest = true
			busy = false
			if not over and not stopped:
				on_done()
	else:
		was_rest = false
		busy = true
		_unstick(dt)

func _unstick(dt: float) -> void:
	for f in fx:
		if f.k == "obj":
			stall = 0.0
			return
	if not ev.is_empty():
		stall = 0.0
		return
	stall += dt
	if stall < 4.0:
		return
	stall = 0.0
	for r in R:
		for c in C:
			var e = b[r][c]
			if e == null:
				continue
			if e.get("dead", false):
				b[r][c] = null
			else:
				e.firing = false
				e.swp = false
				e.top = false
				e.sx = 0.0
				e.sy = 0.0
				if e.fy < 0: e.fy = 0.0

# ------------------------------------------------------------------ input (flow.js bind)
func _unhandled_input(event: InputEvent) -> void:
	if b.is_empty() or over:
		return
	if event is InputEventScreenTouch:
		var p: Vector2 = make_input_local(event).position
		if event.pressed:
			var c := int(floor((p.x - OX) / U))
			var r := int(floor((p.y - OY) / U))
			if at2(r, c) == null:
				return
			arm = {"r": r, "c": c, "x": p.x, "y": p.y}
		else:
			var a = arm
			arm = null
			if a != null:
				tap_sp(a.r, a.c)
	elif event is InputEventScreenDrag:
		var a = arm
		if a == null:
			return
		var p: Vector2 = make_input_local(event).position
		var dx: float = p.x - a.x
		var dy: float = p.y - a.y
		if absf(dx) < U * 0.24 and absf(dy) < U * 0.24:
			return
		arm = null
		var dr := 0
		var dc := 0
		if absf(dx) > absf(dy): dc = 1 if dx > 0 else -1
		else: dr = 1 if dy > 0 else -1
		act(a.r, a.c, dr, dc)

# ------------------------------------------------------------------ drawing (fx.js draw)
func rr_poly(x: float, y: float, w: float, h: float, rad: float) -> PackedVector2Array:
	rad = minf(rad, minf(w, h) / 2.0)
	var pts := PackedVector2Array()
	var cs := [[x + w - rad, y + rad, -PI / 2], [x + w - rad, y + h - rad, 0.0], [x + rad, y + h - rad, PI / 2], [x + rad, y + rad, PI]]
	for cc in cs:
		for i in 5:
			var a: float = cc[2] + i / 4.0 * PI / 2
			pts.append(Vector2(cc[0] + cos(a) * rad, cc[1] + sin(a) * rad))
	return pts

func fill_rr(x: float, y: float, w: float, h: float, rad: float, col: Color) -> void:
	draw_colored_polygon(rr_poly(x, y, w, h, rad), col)

func stroke_rr(x: float, y: float, w: float, h: float, rad: float, col: Color, width: float) -> void:
	var p := rr_poly(x, y, w, h, rad)
	p.append(p[0])
	draw_polyline(p, col, width, true)

func spr_tex(t: Texture2D, x: float, y: float, sz: float, rot: float = 0.0, sy: float = 1.0) -> void:
	if t == null:
		return
	draw_set_transform(Vector2(x, y), rot, Vector2(1, sy))
	draw_texture_rect(t, Rect2(-sz / 2, -sz / 2, sz, sz), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw() -> void:
	if b.is_empty():
		return
	var dt := frame_dt
	var u := float(U)
	_draw_gold(u)
	for pass_i in 2:
		for r in range(R - 1, -1, -1):
			for k in C:
				var e = b[r][k]
				if e == null or (pass_i == 0) == e.get("top", false):
					continue
				var x: float = OX + k * u + e.get("sx", 0.0) * u
				var y: float = OY + r * u - e.fy + e.get("sy", 0.0) * u
				var sz := u
				if e.get("lift", 0.0) != 0.0:
					sz *= 1.0 + 0.12 * e.lift
				if e.get("shakeT", 0.0) > 0.0:
					e.shakeT -= dt
					sz *= 1.0 + 0.05 * sin(maxf(0.0, minf(1.0, e.shakeT / 0.35)) * PI)
				var px := x + (u - sz) / 2.0
				var py := y + (u - sz) / 2.0
				if y + u < OY - 14:
					continue
				if e.k >= 6 and e.k < T.size():
					_draw_special(e, r, k, px, py, sz)
				elif e.k >= 0 and e.k < T.size() and T[e.k] != null:
					draw_texture_rect(T[e.k], Rect2(px + 0.5, py + 0.5, sz - 1, sz - 1), false)
				_draw_over(e, px, py, sz)
				if e.get("dead", false):
					fill_rr(px + 3, py + 3, sz - 6, sz - 6, 11, Color(1, 1, 1, 0.62))
	if dim > 0.01:
		fill_rr(OX - 9, OY - 9, u * C + 18, u * R + 18, 22, Color(30 / 255.0, 20 / 255.0, 70 / 255.0, dim))
	var cur: Array = fx
	fx = []
	var keep: Array = []
	for f in cur:
		f.a += dt
		if f.k == "ring":
			var q: float = f.a / f.l
			if q > 1.0:
				continue
			draw_arc(Vector2(f.x, f.y), u * 0.25 + f.sz * q, 0, TAU, 40, Color(f.col, 1.0 - q), f.w * (1.0 - q) + 1.0, true)
			keep.append(f)
		elif f.k == "spark":
			f.vy += f.get("g", 720.0) * dt
			f.vx *= 0.985
			var ox: float = f.x
			var oy: float = f.y
			f.x += f.vx * dt
			f.y += f.vy * dt
			if f.a > f.l:
				continue
			var al := minf(1.0, (f.l - f.a) * 6.0)
			var w: float = f.get("w", 2.6)
			var p0 := Vector2(f.x, f.y)
			var p1 := Vector2(ox - f.vx * 0.016, oy - f.vy * 0.016)
			var col := Color(f.col, al)
			draw_line(p0, p1, col, w, true)
			keep.append(f)
		elif f.k == "puff":
			f.x += f.vx * dt
			f.y += f.vy * dt
			var q2: float = f.a / f.l
			if q2 > 1.0:
				continue
			draw_circle(Vector2(f.x, f.y), f.r * (1.0 + q2 * 1.5), Color(f.col, 0.75 * (1.0 - q2)))
			keep.append(f)
		elif f.k == "obj":
			var res = f.fn.call(f.a, dt)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			if res != false and f.a <= maxf(f.l, 0.01):
				keep.append(f)
		else:
			f.vy += 900.0 * dt
			f.vz -= 880.0 * dt
			f.x += f.vx * dt
			f.y += f.vy * dt
			f.z += f.vz * dt
			f.r += f.vr * dt
			f.f += f.vf * dt
			if f.a > 0.95 or f.im == null:
				continue
			var sc := maxf(0.35, 1.0 + f.z / 190.0)
			var xf := Transform2D(f.r, Vector2(f.x, f.y - f.z * 0.3)) * Transform2D(0.0, Vector2(sc, sc * (absf(cos(f.f)) * 0.85 + 0.15)), 0.0, Vector2.ZERO) * Transform2D(0.0, Vector2(-u / 2, -u / 2))
			draw_set_transform_matrix(xf)
			var pts := PackedVector2Array()
			var uvs := PackedVector2Array()
			for p in f.po:
				pts.append(p * u)
				uvs.append(p.clamp(Vector2.ZERO, Vector2.ONE))
			var cut := Geometry2D.intersect_polygons(pts, PackedVector2Array([Vector2(0, 0), Vector2(u, 0), Vector2(u, u), Vector2(0, u)]))
			if not cut.is_empty():
				var pp: PackedVector2Array = cut[0]
				var uv2 := PackedVector2Array()
				for p in pp:
					uv2.append(p / u)
				draw_colored_polygon(pp, Color(1, 1, 1, minf(1.0, (0.95 - f.a) * 5.0)), uv2, f.im)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			keep.append(f)
	fx = keep + fx
	if fx.size() > 900:
		fx = fx.slice(fx.size() - 900)
	if flash > 0.02:
		draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, flash * 0.75))

func _draw_special(e: Dictionary, r: int, k: int, px: float, py: float, sz: float) -> void:
	var pu := 0.5 + 0.5 * sin(clock * 5.0 + r + k)
	var s2 := sz * (1.08 + 0.05 * pu)
	var ox2 := px + (sz - s2) / 2.0
	var oy2 := py + (sz - s2) / 2.0 - 3.0
	var pts := PackedVector2Array()
	for i in 20:
		var a := i / 20.0 * TAU
		pts.append(Vector2(px + sz / 2 + cos(a) * sz * 0.42, py + sz * 0.96 + sin(a) * sz * 0.1))
	draw_colored_polygon(pts, Color(60 / 255.0, 30 / 255.0, 90 / 255.0, 0.28))
	if not lite:
		var gs := s2 * (1.55 + 0.12 * pu)
		draw_texture_rect(GLOW, Rect2(ox2 + s2 / 2 - gs / 2, oy2 + s2 / 2 - gs / 2, gs, gs), false, Color(1, 1, 1, 0.5 + 0.4 * pu))
	if T[e.k] != null:
		draw_texture_rect(T[e.k], Rect2(ox2, oy2, s2, s2), false)
	stroke_rr(ox2 + 1, oy2 + 1, s2 - 2, s2 - 2, 11, Color("#FFC62B"), 3)
	var sw := fmod(clock * 0.55 + (r + k) * 0.13, 1.0) * s2 * 2.4 - s2 * 0.7
	var band := PackedVector2Array([Vector2(ox2 + sw, oy2), Vector2(ox2 + sw + 12, oy2), Vector2(ox2 + sw - s2 * 0.4 + 12, oy2 + s2), Vector2(ox2 + sw - s2 * 0.4, oy2 + s2)])
	var cut := Geometry2D.intersect_polygons(band, rr_poly(ox2 + 1, oy2 + 1, s2 - 2, s2 - 2, 11))
	for p in cut:
		draw_colored_polygon(p, Color(1, 1, 1, 0.55))

func _draw_over(e: Dictionary, x: float, y: float, s: float) -> void:
	if not e.has("ob"):
		return
	var o: Dictionary = e.ob
	var t: String = o.t
	if t == "hole":
		var p := rr_poly(x + 1, y + 1, s - 2, s - 2, 8)
		var cols := PackedColorArray()
		for v in p:
			cols.append(Color("#1B0B33").lerp(Color("#3A1C66"), clampf((v.y - y) / s, 0.0, 1.0)))
		draw_polygon(p, cols)
		stroke_rr(x + 1, y + 1, s - 2, s - 2, 8, Color(1, 210 / 255.0, 90 / 255.0, 0.25), 1.5)
		return
	var k: float = 1.0 + o.get("sq", 0.0) * 0.18
	if o.get("sq", 0.0) > 0.0:
		o.sq = maxf(0.0, o.sq - 0.07)
		var tr := Transform2D(0.0, Vector2(x + s / 2 + sin(clock * 60.0) * o.sq * 3.0, y + s / 2)) * Transform2D(0.0, Vector2(k, 2.0 - k), 0.0, Vector2.ZERO) * Transform2D(0.0, Vector2(-x - s / 2, -y - s / 2))
		draw_set_transform_matrix(tr)
	if t == "crate" or t == "steel":
		var im: Texture2D = IC.crate2 if (t == "steel" and o.hp > 1) else IC.crate
		draw_texture_rect(im, Rect2(x - 2, y - 2, s + 4, s + 4), false)
	if o.get("fl", 0.0) > 0.0:
		fill_rr(x, y, s, s, 9, Color(1, 1, 1, o.fl * 0.8))
		o.fl = maxf(0.0, o.fl - 0.12)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# gold floor tiles (step 2 brings the fx26 carpet; this is the plain fx.js look)
func _draw_gold(u: float) -> void:
	for key in fl:
		var f: Dictionary = fl[key]
		if f.t != "gold":
			continue
		var a: PackedStringArray = key.split(",")
		var fx_ := OX + int(a[1]) * u + 2
		var fy_ := OY + int(a[0]) * u + 2
		draw_texture_rect(IC.goldfloor, Rect2(fx_ - 1, fy_ - 1, u - 2, u - 2), false)


# the board frame and cells, drawn once (fx.js drawFloor)
class CMFloor extends Node2D:
	var g: CMGame
	func _draw() -> void:
		var u := float(g.U)
		var OX := g.OX
		var OY := g.OY
		var cells: Array = []
		for r in g.R:
			for k in g.C:
				if not g.hole(r, k):
					cells.append(Vector2(OX + k * u, OY + r * u))
		# soft drop shadow (canvas shadowBlur 22, offset 8, rgba(10,0,30,.55)), built from a few wider, fainter layers
		for i in range(6, 0, -1):
			var grow := i * 3.0
			for p in cells:
				g_fill(p.x - 8 - grow, p.y - 8 - grow + 8, u + 16 + grow * 2, u + 16 + grow * 2, 14 + grow, Color(10 / 255.0, 0, 30 / 255.0, 0.55 / 7.0))
		for p in cells:
			g_fill(p.x - 8, p.y - 8, u + 16, u + 16, 14, Color("#E9A72A"))
		for p in cells:
			g_fill(p.x - 6, p.y - 7, u + 12, u + 12, 12, Color("#FFE08A"))
		for p in cells:
			g_fill(p.x - 6, p.y - 5, u + 12, u + 11, 12, Color("#E9A72A"))
		for p in cells:
			g_fill(p.x - 3, p.y - 3, u + 6, u + 6, 9, Color("#3A1466"))
		for r in g.R:
			for k in g.C:
				if not g.hole(r, k):
					draw_rect(Rect2(OX + k * u, OY + r * u, u, u), Color("#CEC6EC") if (r + k) % 2 else Color("#DCD6F2"))
	func g_fill(x: float, y: float, w: float, h: float, rad: float, col: Color) -> void:
		draw_colored_polygon(g.rr_poly(x, y, w, h, rad), col)
