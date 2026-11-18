# Area 2 (18 Nov): GHILLI CRACKERS, our first shop on Bunder Street, Chennai. Port of the approved web preview
# (area2-shop-builds-v2.mp4): a colourful bazaar street of Kenney City Kit buildings, our old orange building set
# back with a shop room in front, closed by a rusty shutter. 12 builds (36 diyas) fill it, as in Area 1:
# drop-ins with a squash, pops, dust, sparkles and a ring after each build. Animations use the Street's
# game-clock tweens (st.tween / st.after / st.pop / st.drop_in), so skip_to() replays them instantly.
extends Node3D
class_name ShopArea

const TASKS := [
	{"n": "Open the Rusty Shutter", "c": 1, "ic": "🔓", "dur": 3.6, "site": [0, 2, 0], "shot": "path"},
	{"n": "Clear Old Boxes & Sweep", "c": 1, "ic": "🧹", "dur": 3.4, "site": [0, 1, 1], "shot": "path"},
	{"n": "GHILLI CRACKERS Signboard", "c": 2, "ic": "🪧", "dur": 3.2, "site": [0, 4.6, 0], "shot": "path"},
	{"n": "Fix the Step & Tiles", "c": 2, "ic": "🧱", "dur": 3.2, "site": [0, 0.6, 1.5], "shot": "path"},
	{"n": "Paint the Shop Front", "c": 3, "ic": "🎨", "dur": 3.2, "site": [0, 3, 0], "shot": "path"},
	{"n": "Tube Lights & Ceiling Fan", "c": 3, "ic": "💡", "dur": 3.4, "site": [0, 3.2, -1.5], "shot": "path"},
	{"n": "Counter & Cash Box", "c": 3, "ic": "🪙", "dur": 3.4, "site": [0, 1.4, -1], "shot": "path"},
	{"n": "Wall Shelves of Crackers", "c": 4, "ic": "🗄️", "dur": 3.6, "site": [0, 1.6, -2.8], "shot": "path"},
	{"n": "Display Racks Outside", "c": 4, "ic": "🎆", "dur": 3.4, "site": [-1, 1, 2.2], "shot": "path"},
	{"n": "Striped Awning", "c": 4, "ic": "⛱️", "dur": 3.2, "site": [0, 4, 1], "shot": "path"},
	{"n": "Garlands, Lanterns & Photo", "c": 4, "ic": "🪔", "dur": 3.8, "site": [0, 3.4, 0], "shot": "path"},
	{"n": "Grand Opening", "c": 5, "ic": "🎀", "dur": 5.0, "site": [0, 2.4, 0], "shot": "path"},
]

var st            # Street
var VW: Array = []
var HOME := {"p": Vector3(-3.6, 3.6, 22.5), "look": Vector3(-0.4, 5.6, 0)}
var WIDE := {"p": Vector3(-4.5, 5.2, 29), "look": Vector3(-0.6, 6.4, 0)}

const CR := [Color("#D7263D"), Color("#FFC93C"), Color("#FF7A1A"), Color("#2E86DE"), Color("#7B3FBF"), Color("#2EAD5B")]
var O := {}       # parts of the scene the builds change
var fan_on := false

func _init() -> void:
	# camera for each build: a small drift towards its site (the whole shop front stays in view)
	for T in TASKS:
		var s := Vector3(T.site[0], T.site[1], T.site[2])
		VW.append({"p": HOME.p + (s - HOME.p) * 0.09 + Vector3(0, 0, -2.2), "look": HOME.look + (s - HOME.look) * 0.15})

# ---------------------------------------------------------------- helpers
func mat(c: Color, rough := 0.85, metal := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	m.metallic = metal
	return m

func box(size: Vector3, pos: Vector3, c: Color, par: Node3D = self) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	m.mesh = bm
	m.material_override = mat(c)
	m.position = pos
	par.add_child(m)
	return m

func sphere(r: float, pos: Vector3, c: Color, par: Node3D = self) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2
	sm.radial_segments = 10
	sm.rings = 5
	m.mesh = sm
	m.material_override = mat(c, 0.8)
	m.position = pos
	par.add_child(m)
	return m

func kit(path: String, pos: Vector3, s: float, rot_y := 0.0, tint = null, solid := false) -> Node3D:
	var ps: PackedScene = load(path)
	var o: Node3D = ps.instantiate() if ps else Node3D.new()
	o.scale = Vector3.ONE * s
	o.rotation.y = rot_y
	o.position = pos
	add_child(o)
	if tint != null:
		for c in o.find_children("*", "MeshInstance3D", true, false):
			var mi := c as MeshInstance3D
			for i in mi.get_surface_override_material_count():
				var src = mi.get_active_material(i)
				if src is StandardMaterial3D:
					var m: StandardMaterial3D = src.duplicate()
					m.albedo_color = tint
					if solid:
						m.albedo_texture = null
					mi.set_surface_override_material(i, m)
	return o

func label(text: String, pos: Vector3, size: int, col: Color, par: Node3D = self) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.font = load("res://art/LilitaOne.ttf")
	l.font_size = size
	l.pixel_size = 0.004
	l.modulate = col
	l.outline_size = 0
	l.position = pos
	l.double_sided = false
	par.add_child(l)
	return l

# a flat signboard: coloured board, gold frame, text
func signboard(text: String, w: float, h: float, pos: Vector3, bg: Color, fg: Color, sub := "") -> Node3D:
	var g := Node3D.new()
	g.position = pos
	add_child(g)
	box(Vector3(w + 0.14, h + 0.14, 0.05), Vector3(0, 0, -0.03), Color("#f5c542"), g)
	box(Vector3(w, h, 0.06), Vector3.ZERO, bg, g)
	if text != "":
		label(text, Vector3(0, 0.08 if sub != "" else 0.0, 0.04), int(h * 62), fg, g)
		if sub != "":
			label(sub, Vector3(0, -h * 0.3, 0.04), int(h * 26), fg, g)
	return g

func tex_shutter() -> Texture2D:
	var img := Image.create(256, 256, false, Image.FORMAT_RGB8)
	for y in 256:
		var band := Color("#8a5536") if (y / 8) % 2 else Color("#a8703f")
		if y % 8 >= 6:
			band = Color("#4a2a14")
		for x in 256:
			img.set_pixel(x, y, band)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 90:
		var cx := rng.randi_range(0, 255)
		var cy := rng.randi_range(0, 255)
		var r := rng.randi_range(2, 9)
		for y in range(maxi(0, cy - r), mini(256, cy + r)):
			for x in range(maxi(0, cx - r), mini(256, cx + r)):
				if Vector2(x - cx, y - cy).length() < r:
					img.set_pixel(x, y, img.get_pixel(x, y).lerp(Color("#6e3a18"), 0.5))
	for p in [[60, 110, 46, 60, Color("#ece2c8")], [170, 130, 36, 48, Color("#e0d6bb")]]:
		for y in range(p[1], p[1] + p[3]):
			for x in range(p[0], p[0] + p[2]):
				img.set_pixel(x, y, p[4])
	for y in range(114, 132):
		for x in range(64, 102):
			img.set_pixel(x, y, Color("#c0392b"))
	return ImageTexture.create_from_image(img)

func tex_tiles() -> Texture2D:
	var img := Image.create(128, 128, false, Image.FORMAT_RGB8)
	for y in 128:
		for x in 128:
			var c := Color("#f1e3c8") if ((x / 32) + (y / 32)) % 2 == 0 else Color("#c8693e")
			if x % 32 < 2 or y % 32 < 2:
				c = Color("#8f7a66")
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)

func cracker_boxes(par: Node3D, spots: Array, size: Vector3, seed := 0) -> void:
	for i in spots.size():
		var b := box(size, spots[i], CR[(i + seed) % CR.size()], par)
		box(Vector3(size.x * 1.04, size.y * 0.2, size.z * 1.04), Vector3.ZERO, Color("#F5C542"), b)

# a sagging wire made of short boxes
func wire(a: Vector3, b: Vector3, sag: float) -> void:
	var n := 14
	for i in n:
		var t0 := float(i) / n
		var t1 := float(i + 1) / n
		var p0: Vector3 = a.lerp(b, t0) - Vector3(0, sin(t0 * PI) * sag, 0)
		var p1: Vector3 = a.lerp(b, t1) - Vector3(0, sin(t1 * PI) * sag, 0)
		var seg := box(Vector3(p0.distance_to(p1), 0.05, 0.05), (p0 + p1) / 2, Color("#222222"))
		seg.rotation.z = atan2(p1.y - p0.y, p1.x - p0.x)

# ---------------------------------------------------------------- the street and the shop (start state)
func build() -> void:
	var CITY := "res://art/city/%s.glb"
	box(Vector3(200, 0.2, 80), Vector3(0, -0.1, 12), Color("#5f5b62"))
	box(Vector3(200, 0.35, 3.4), Vector3(0, 0.05, 1.7), Color("#b8ad9e"))
	box(Vector3(200, 0.36, 0.25), Vector3(0, 0.06, 3.35), Color("#8e8577"))
	for x in range(-100, 100, 6):
		box(Vector3(3, 0.02, 0.22), Vector3(x, 0.01, 10), Color("#f2e6c8"))
	for b in [["building-e", -20.5, Color("#FFC93C")], ["building-g", -9.2, Color("#FF8FB1")], ["building-f", 0.0, Color("#FFB25C")], ["building-c", 8.9, Color("#5FD3C6")], ["building-d", 17.5, Color("#B79BFF")]]:
		kit(CITY % b[0], Vector3(b[1], 0, -9.6 if b[0] == "building-f" else -6.6), 12.0, 0.0, b[2])
	# the shop room behind the shutter (dark and dusty until painted)
	O.room = [box(Vector3(7.8, 0.1, 3.3), Vector3(0, 0.02, -1.65), Color("#5a4c40")), box(Vector3(7.8, 3.9, 0.1), Vector3(0, 1.95, -3.3), Color("#4a4038")),
		box(Vector3(0.1, 3.9, 3.3), Vector3(-3.9, 1.95, -1.65), Color("#463c34")), box(Vector3(0.1, 3.9, 3.3), Vector3(3.9, 1.95, -1.65), Color("#463c34")),
		box(Vector3(7.8, 0.1, 3.3), Vector3(0, 3.9, -1.65), Color("#3a322c"))]
	O.room_to = [Color("#d98a3a"), Color("#FFD23F"), Color("#2EC4B6"), Color("#2EC4B6"), Color("#FF6B6B")]
	var lt := OmniLight3D.new()
	lt.light_color = Color("#ffe2b0")
	lt.light_energy = 0.0
	lt.omni_range = 9.0
	lt.position = Vector3(0, 3.2, -1.2)
	add_child(lt)
	O.light = lt
	# front: fascia, pillars, old blank board, rusty shutter, cracked step, old boxes
	O.fascia = box(Vector3(8.5, 1.5, 0.4), Vector3(0, 4.65, -0.15), Color("#6b5444"))
	O.pl = [box(Vector3(0.4, 3.95, 0.45), Vector3(-4.1, 1.97, -0.05), Color("#7b5a44")), box(Vector3(0.4, 3.95, 0.45), Vector3(4.1, 1.97, -0.05), Color("#7b5a44"))]
	O.old_board = signboard("", 7.6, 1.0, Vector3(0, 4.65, 0.08), Color("#5d4535"), Color.BLACK)
	var sh := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(7.8, 3.7)
	sh.mesh = q
	var sm := StandardMaterial3D.new()
	sm.albedo_texture = tex_shutter()
	sm.roughness = 0.95
	sm.cull_mode = BaseMaterial3D.CULL_DISABLED
	sh.material_override = sm
	sh.position = Vector3(0, 1.95, -0.08)
	add_child(sh)
	O.shutter = sh
	O.step = box(Vector3(8.6, 0.25, 1.2), Vector3(0, 0.18, 0.7), Color("#8f887c"))
	O.junk = []
	for i in 5:
		O.junk.append(kit("res://art/shop/cardboardBoxClosed.glb", Vector3(-3.3 + i * 1.3 + (i % 2) * 0.2, 0.3, 1.0 + (i % 2) * 0.4), 3.2, i * 0.4))
	# life on our building: flower boxes, clothes line
	for x in [-2.75, 2.75]:
		box(Vector3(2.2, 0.35, 0.5), Vector3(x, 6.0, 0.25), Color("#8a4b2a"))
		for i in 5:
			sphere(0.2, Vector3(x - 0.9 + i * 0.45, 6.3, 0.25), [Color("#E84A5F"), Color("#F6C453"), Color("#FF7A1A")][i % 3])
	wire(Vector3(-4, 8.6, 0.4), Vector3(4, 8.6, 0.4), 0.5)
	var cloth := [Color("#E84A5F"), Color("#2E86DE"), Color("#F6C453"), Color("#ffffff")]
	for i in 4:
		box(Vector3(0.7, 0.9, 0.03), Vector3(-2.4 + i * 1.5, 8.0 - sin((i + 1) / 5.0 * PI) * 0.45, 0.4), cloth[i])
	# left neighbour: textile shop
	kit(CITY % "detail-awning-wide", Vector3(-8.9, 0, -0.4), 12.0, 0.0, Color("#E85D3B"), true)
	signboard("LAKSHMI TEXTILES", 7.6, 1.0, Vector3(-8.9, 4.7, 0.02), Color("#b3171e"), Color("#ffe9a8"))
	var cl := [Color("#E84A5F"), Color("#F6C453"), Color("#2E86DE"), Color("#7B3FBF"), Color("#2EAD5B"), Color("#FF7A1A")]
	for i in 6:
		var c := MeshInstance3D.new()
		var cy := CylinderMesh.new()
		cy.top_radius = 0.28
		cy.bottom_radius = 0.28
		cy.height = 1.6
		c.mesh = cy
		c.material_override = mat(cl[i], 0.7)
		c.position = Vector3(-11.6 + i * 0.55, 1.15 + (i % 2) * 0.1, 1.1)
		add_child(c)
	box(Vector3(4, 0.9, 1.2), Vector3(-7.4, 0.45, 1.0), Color("#8a5a3c"))
	# right neighbour: steel vessels
	kit(CITY % "detail-awning-wide", Vector3(8.9, 0, -0.4), 12.0, 0.0, Color("#2E86DE"), true)
	signboard("MURUGAN STORES", 7.6, 1.0, Vector3(8.9, 4.7, 0.02), Color("#1f4f9e"), Color("#fff1c4"), "STEEL · BRASS · VESSELS")
	for i in 7:
		var v := MeshInstance3D.new()
		var vc := CylinderMesh.new()
		vc.top_radius = 0.3
		vc.bottom_radius = 0.38
		vc.height = 0.55
		v.mesh = vc
		v.material_override = mat(Color("#d9dde3"), 0.25, 0.9)
		v.position = Vector3(6.4 + i * 0.72, 0.33, 1.1)
		add_child(v)
	signboard("KAAPI BAR", 6.0, 1.0, Vector3(-20.5, 4.7, 0.02), Color("#2e7d4f"), Color("#fff3c4"))
	signboard("SRI GANESH SWEETS", 6.5, 1.0, Vector3(17.5, 4.7, 0.02), Color("#d35400"), Color("#fff3c4"))
	for b in [[-11.8, Color("#E84A5F"), "SAREES"], [-6.6, Color("#F6C453"), "SILK"], [6.4, Color("#2E86DE"), "VESSELS"], [11.4, Color("#2EAD5B"), "KAAPI"]]:
		var bn := box(Vector3(1.1, 4.4, 0.04), Vector3(b[0], 8.4, 0.35), b[1])
		var t := ""
		for ch in String(b[2]):
			t += ch + "\n"
		label(t.strip_edges(), Vector3(0, 0, 0.03), 70, Color("#fff7d6"), bn)
	for x in [-14.6, 4.6]:
		box(Vector3(0.25, 7.5, 0.25), Vector3(x, 3.75, 3.1), Color("#4a4a4a"))
		box(Vector3(1.4, 0.18, 0.18), Vector3(x + 0.5, 7.3, 3.1), Color("#4a4a4a"))
	wire(Vector3(-14.6, 7.4, 3.1), Vector3(4.6, 7.4, 3.1), 0.9)
	wire(Vector3(-14.6, 7.0, 3.1), Vector3(4.6, 7.0, 3.1), 0.7)
	wire(Vector3(4.6, 7.4, 3.1), Vector3(24, 7.6, 3.1), 0.8)
	kit("res://art/shop/pottedPlant.glb", Vector3(-5.2, 0, 1.2), 3.2)
	kit("res://art/shop/pottedPlant.glb", Vector3(4.6, 0, 1.2), 3.2)
	kit("res://art/vehicles/taxi.glb", Vector3(-12.5, 0, 6.0), 1.7, PI / 2)
	kit("res://art/vehicles/van.glb", Vector3(13, 0, 6.3), 1.7, -PI / 2)
	_build_parts()

# ---------------------------------------------------------------- build parts (hidden until built)
func _build_parts() -> void:
	O.sign = signboard("GHILLI CRACKERS", 7.6, 1.05, Vector3(0, 4.65, 0.1), Color("#c0161f"), Color("#ffe27a"))
	var tm := StandardMaterial3D.new()
	tm.albedo_texture = tex_tiles()
	tm.uv1_triplanar = true
	tm.uv1_scale = Vector3.ONE * 0.5
	O.new_step = box(Vector3(8.6, 0.28, 1.2), Vector3(0, 0.19, 0.7), Color.WHITE)
	O.new_step.material_override = tm
	O.tiles = []
	for i in 10:
		O.tiles.append(box(Vector3(0.86, 0.04, 0.9), Vector3(-3.87 + i * 0.86, 0.36, 1.78), Color("#c8693e") if i % 2 else Color("#f1e3c8")))
	O.tube = box(Vector3(1.8, 0.09, 0.09), Vector3(0, 3.55, -3.2), Color.WHITE)
	var tmat: StandardMaterial3D = O.tube.material_override
	tmat.emission_enabled = true
	tmat.emission = Color("#fff3d6")
	tmat.emission_energy_multiplier = 0.0
	O.fan = kit("res://art/shop/ceilingFan.glb", Vector3(0, 3.85, -1.6), 4.5)
	O.counter = []
	for i in 4:
		O.counter.append(kit("res://art/shop/kitchenBar.glb", Vector3(-2.58 + i * 1.29, 0, -1.0), 3.0))
	O.counter.append(kit("res://art/shop/kitchenBarEnd.glb", Vector3(-2.58 + 4 * 1.29, 0, -1.0), 3.0))
	O.counter.append(kit("res://art/shop/radio.glb", Vector3(0.9, 1.26, -1.3), 2.2, PI))
	O.shelves = []
	for i in 6:
		var s := kit("res://art/shop/bookcaseOpen.glb", Vector3(-3.62 + i * 1.22, 0, -2.5), 3.0)
		var spots := []
		for shf in 3:
			for k in 2:
				spots.append(Vector3(0.1 + k * 0.17, 0.12 + shf * 0.26, -0.12))
		cracker_boxes(s, spots, Vector3(0.13, 0.12, 0.13), i * 3)
		O.shelves.append(s)
	O.racks = []
	for x in [-3.1, 1.25]:
		var r := kit("res://art/shop/tableGlass.glb", Vector3(x, 0.3, 2.25), 2.2)
		var spots2 := []
		for k in 4:
			spots2.append(Vector3(0.12 + k * 0.17, 0.38, -0.22))
		cracker_boxes(r, spots2, Vector3(0.14, 0.09, 0.2), 2 if x > 0 else 0)
		O.racks.append(r)
	var awn := Node3D.new()
	awn.position = Vector3(0, 3.98, 0.05)
	awn.rotation.x = 0.22
	add_child(awn)
	for i in 8:
		box(Vector3(1.06, 0.08, 1.9), Vector3(-3.7 + i * 1.06, 0, 0.95), Color("#fff1d6") if i % 2 else Color("#d7263d"), awn)
	O.awn = awn
	O.gar = []
	for i in 34:
		var t := i / 33.0
		O.gar.append(sphere(0.12, Vector3(-4.1 + 8.2 * t, 3.88 - sin(t * PI) * 0.45, 0.32), Color("#ffd23f") if i % 3 == 0 else Color("#ff8a00")))
	for sx in [-4.1, 4.1]:
		for i in 12:
			O.gar.append(sphere(0.11, Vector3(sx, 3.7 - i * 0.28, 0.3), Color("#ffd23f") if i % 3 == 0 else Color("#ff8a00")))
	O.lan = []
	for x in [-2.6, 0.0, 2.6]:
		var l := sphere(0.3, Vector3(x, 3.2, 0.55), Color("#ff7a1a"))
		var lm: StandardMaterial3D = l.material_override
		lm.emission_enabled = true
		lm.emission = Color("#ff8a2a")
		lm.emission_energy_multiplier = 0.8
		O.lan.append(l)
	var ph := Node3D.new()
	ph.position = Vector3(0, 3.2, -3.22)
	add_child(ph)
	box(Vector3(0.85, 1.0, 0.06), Vector3.ZERO, Color("#4a2a18"), ph)
	var pq := MeshInstance3D.new()
	var qq := QuadMesh.new()
	qq.size = Vector2(0.68, 0.82)
	pq.mesh = qq
	var pmat := StandardMaterial3D.new()
	pmat.albedo_texture = load("res://art/shop/grandpa.png")
	pq.material_override = pmat
	pq.position = Vector3(0, 0, 0.04)
	ph.add_child(pq)
	O.photo = ph
	O.rib = [box(Vector3(4.0, 0.16, 0.05), Vector3(-2.0, 1.3, 0.45), Color("#E3202F")), box(Vector3(4.0, 0.16, 0.05), Vector3(2.0, 1.3, 0.45), Color("#E3202F")), box(Vector3(0.5, 0.5, 0.08), Vector3(0, 1.3, 0.47), Color("#FFC93C"))]
	for a in [[O.sign, O.new_step, O.tube, O.fan, O.awn, O.photo], O.tiles, O.counter, O.shelves, O.racks, O.gar, O.lan, O.rib]:
		for n in a:
			(n as Node3D).visible = false

# ---------------------------------------------------------------- the builds
func _done_fx(site: Vector3, d: float) -> void:
	st.after(d, func():
		st.sparkle(Vector3(site.x, 0, site.z + 0.6), 36, site.y)
		st.ring(Vector3(site.x, 0, maxf(site.z, -1.0) + 1.2)))

func _squash_drop(o: Node3D, delay: float, h := 3.0) -> void:
	st.drop_in(o, delay, h)
	var s: float = st._s0(o)
	st.tween(0.25, func(k: float):
		var q := sin(k * PI) * 0.18
		o.scale = Vector3(s * (1 + q * 0.6), s * (1 - q), s * (1 + q * 0.6)), delay + 0.5)

func run(name: String) -> void:
	var i := -1
	for j in TASKS.size():
		if TASKS[j].n == name:
			i = j
	if i < 0:
		return
	var site := Vector3(TASKS[i].site[0], TASKS[i].site[1], TASKS[i].site[2])
	match i:
		0:   # the shutter rolls up
			var sh: MeshInstance3D = O.shutter
			st.after(0.3, func(): st.dust(Vector3(0, 0, 0.6), 18, 3.0))
			st.tween(1.8, func(k: float):
				var a: float = st.sm(k)
				sh.scale.y = maxf(0.02, 1.0 - a)
				sh.position.y = 1.95 + a * 1.85
				if k >= 1:
					sh.visible = false, 0.3)
			_done_fx(site, 2.4)
		1:   # old boxes fly away
			for j in O.junk.size():
				var o: Node3D = O.junk[j]
				var p0 := o.position
				var dir := 1.0 if j % 2 else -1.0
				st.tween(0.9, func(k: float):
					o.position = Vector3(p0.x + dir * k * 6, p0.y + sin(k * PI) * 2.2, p0.z + k * 2)
					o.rotation.z = k * 4
					if k >= 1:
						o.visible = false, 0.2 + j * 0.12)
				st.after(0.2 + j * 0.12, func(): st.dust(p0, 6, 0.8))
			_done_fx(site, 2.2)
		2:   # the signboard drops onto the old board
			st.after(0.5, func(): (O.old_board as Node3D).visible = false)
			_squash_drop(O.sign, 0.5, 2.5)
			_done_fx(site, 1.6)
		3:   # new tiled step and pavement tiles
			st.after(0.7, func(): (O.step as Node3D).visible = false)
			_squash_drop(O.new_step, 0.7, 1.5)
			for j in O.tiles.size():
				st.pop(O.tiles[j], 1.1 + j * 0.08, 0.3)
			_done_fx(site, 2.4)
		4:   # paint: front red and blue, the room yellow and turquoise
			var parts: Array = [[O.fascia, Color("#d7263d")], [O.pl[0], Color("#2E86DE")], [O.pl[1], Color("#2E86DE")]]
			for j in O.room.size():
				parts.append([O.room[j], O.room_to[j]])
			for p in parts:
				var m: StandardMaterial3D = (p[0] as MeshInstance3D).material_override
				var c0 := m.albedo_color
				var c1: Color = p[1]
				st.tween(1.4, func(k: float): m.albedo_color = c0.lerp(c1, st.sm(k)), 0.3)
			_done_fx(site, 2.0)
		5:   # tube light flickers on, fan drops and spins
			st.pop(O.tube, 0.2, 0.35)
			_squash_drop(O.fan, 0.5, 2.0)
			var tm: StandardMaterial3D = (O.tube as MeshInstance3D).material_override
			var lt: OmniLight3D = O.light
			st.tween(0.8, func(k: float):
				var on := 1.0 if k >= 1 or fmod(k * 9.0, 1.0) > 0.4 else 0.25
				tm.emission_energy_multiplier = 2.0 * on
				lt.light_energy = 1.6 * on, 1.3)
			st.after(1.4, func(): fan_on = true)
			_done_fx(site, 2.4)
		6:
			for j in O.counter.size():
				_squash_drop(O.counter[j], 0.2 + j * 0.16, 3.0)
			st.after(0.8, func(): st.dust(Vector3(0, 0, -1.0), 10, 2.5))
			_done_fx(site, 2.2)
		7:
			for j in O.shelves.size():
				st.grow(O.shelves[j], 0.2 + j * 0.2, 0.55)
			_done_fx(site, 2.4)
		8:
			for j in O.racks.size():
				st.pop(O.racks[j], 0.3 + j * 0.4, 0.5)
			_done_fx(site, 1.8)
		9:   # the striped awning unrolls
			var aw: Node3D = O.awn
			st.tween(0.8, func(k: float):
				aw.visible = true
				aw.scale = Vector3(1, 1, maxf(0.01, st.back(k))), 0.3)
			_done_fx(site, 1.6)
		10:  # garlands, lanterns, Grandpa's photo
			for j in O.gar.size():
				st.pop(O.gar[j], 0.2 + j * 0.03, 0.25)
			for j in O.lan.size():
				_squash_drop(O.lan[j], 1.8 + j * 0.2, 2.0)
			st.pop(O.photo, 2.6, 0.5)
			_done_fx(site, 3.0)
		11:  # grand opening: ribbon, cut, sparkle bursts, lights up
			for r in O.rib:
				st.pop(r, 0.2, 0.35)
			var rb: Array = O.rib
			st.tween(0.6, func(k: float):
				(rb[0] as Node3D).position.x = -2.0 - k * 2
				(rb[1] as Node3D).position.x = 2.0 + k * 2
				(rb[0] as Node3D).scale.x = maxf(0.01, 1 - k)
				(rb[1] as Node3D).scale.x = maxf(0.01, 1 - k)
				(rb[2] as Node3D).position.y = 1.3 - k * 1.2
				if k >= 1:
					for r in rb:
						(r as Node3D).visible = false, 1.5)
			for j in 6:
				var at := Vector3(-4.0 + j * 1.6, 0, 0.5 + (j % 2))
				var hy := 2.0 + (j % 3) * 1.2
				st.after(1.6 + j * 0.35, func(): st.sparkle(at, 40, hy))
			var lt2: OmniLight3D = O.light
			st.tween(0.8, func(k: float): lt2.light_energy = 1.6 + k * 1.0, 1.8)
			st.after(1.8, func(): st.ring(Vector3(0, 0, 1.2), Color("#ffd27a")))

func _process(dt: float) -> void:
	if fan_on and O.has("fan") and (O.fan as Node3D).visible:
		(O.fan as Node3D).rotate_y(dt * 6.0)
