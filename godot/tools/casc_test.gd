# Check: plays random plain moves on levels 1-10 and prints chain matches per move.
# xvfb-run godot --path . --fixed-fps 60 --rendering-driver opengl3 -s tools/casc_test.gd
extends SceneTree

var g: CMGame
var d: CMDeb
var f3: CMFly
var levels: Array
var li := 0
var s := 0
var seeds := 4
var m := 0
var state := "new"
var steps := 0
var hist := {}
var long := 0.0
var nm := 0
var only := -1

func pick() -> Array:
	var out: Array = []
	for r in g.R:
		for c in g.C:
			var e = g.b[r][c]
			if e == null or e.k >= 6 or e.k < 0 or g.stuck(e):
				continue
			for o in [[0, 1], [1, 0]]:
				var f = g.at2(r + o[0], c + o[1])
				if f == null or f.k >= 6 or f.k < 0 or g.stuck(f):
					continue
				var t: int = e.k
				e.k = f.k
				f.k = t
				var ok: bool = g.makes(r, c) or g.makes(r + o[0], c + o[1])
				f.k = e.k
				e.k = t
				if ok:
					out.append([r, c, o[0], o[1]])
	return out

func _initialize() -> void:
	levels = Levels.all()
	if OS.get_environment("SEEDS") != "":
		seeds = int(OS.get_environment("SEEDS"))
	if OS.get_environment("LV") != "":
		only = int(OS.get_environment("LV")) - 1
		li = only

func report() -> void:
	var avg := 0.0
	for k in hist:
		avg += k * hist[k]
	print("L%d moves %d avgChains %.2f longest %.1fs hist %s" % [li + 1, nm, avg / maxf(1, nm), long, str(hist)])
	hist = {}
	long = 0.0
	nm = 0

func _process(_delta: float) -> bool:
	var dt := 1.0 / 60.0
	if state == "new":
		if li >= levels.size() or (only >= 0 and li != only):
			return true
		seed(1000 * li + s)
		g = CMGame.new()
		root.add_child(g)
		d = CMDeb.new()
		root.add_child(d)
		g.deb = d
		f3 = CMFly.new()
		root.add_child(f3)
		g.fly3d = f3
		g.start(CMGame.make_level(levels[li], li))
		g.gspeed = 3.0
		m = 0
		steps = 0
		state = "settle"
	elif state == "settle":
		steps += 1
		if (g.busy or not g.settled()) and steps < 1200:
			return false
		var mv := pick() if not (g.over or g.moves <= 0 or m >= 14) else []
		if mv.is_empty():
			g.queue_free()
			d.queue_free()
			f3.queue_free()
			s += 1
			if s >= seeds:
				report()
				s = 0
				li += 1
			state = "new"
			return false
		var p = mv[randi() % mv.size()]
		g.casc = 0
		g.act(p[0], p[1], p[2], p[3])
		steps = 0
		state = "move"
	elif state == "move":
		steps += 1
		if steps < 3 or ((g.busy or not g.settled()) and steps < 6000 and not g.over):
			return false
		var k: int = g.casc
		hist[k] = hist.get(k, 0) + 1
		long = maxf(long, steps * dt)
		nm += 1
		m += 1
		steps = 0
		state = "settle"
	return false
