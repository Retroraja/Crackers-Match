# Area 2 (17 Nov): our first shop, Bunder Street, Chennai. A one-room shop seen from the front like a dollhouse.
# Before the shutter opens the camera is outside on the street; after that the home view looks into the room.
# Built in code from simple boxes plus the Kenney Furniture Kit (CC0, art/shop). Animations use the Street's
# game-clock tweens (st.tween / st.after / st.pop / st.drop_in / st.sink_away), so skip_to() replays them instantly.
extends Node3D
class_name ShopArea

const K := 3.0          # Kenney furniture unit -> world
const RW := 6.0         # room half width (x -6..6)
const RD := 15.0        # room depth (z 0..-15)
const RH := 3.9         # wall height

const TASKS := [
	{"n": "Open the Rusty Shutter", "c": 1, "ic": "🔓", "dur": 3.2, "site": [0, 0, 0], "shot": "path"},
	{"n": "Clean the Dusty Shop", "c": 1, "ic": "🧹", "dur": 3.4, "site": [0, 0, -8], "shot": "path"},
	{"n": "Paint the Walls", "c": 2, "ic": "🎨", "dur": 3.2, "site": [0, 0, -10], "shot": "path"},
	{"n": "Lights and Ceiling Fan", "c": 2, "ic": "💡", "dur": 3.4, "site": [0, 0, -8], "shot": "path"},
	{"n": "Counter and Cash Box", "c": 2, "ic": "🪙", "dur": 3.4, "site": [0, 0, -5], "shot": "path"},
	{"n": "Wall Shelves", "c": 2, "ic": "🗄️", "dur": 3.8, "site": [0, 0, -13], "shot": "path"},
	{"n": "Display Cabinet and Racks", "c": 3, "ic": "🎆", "dur": 4.0, "site": [0, 0, -8], "shot": "path"},
	{"n": "Signboard and Decorations", "c": 2, "ic": "🪔", "dur": 3.8, "site": [0, 0, -13], "shot": "path"},
	{"n": "Grandpa's Photo", "c": 1, "ic": "🖼️", "dur": 3.4, "site": [-4, 0, -14], "shot": "path"},
	{"n": "Grand Opening", "c": 2, "ic": "🎀", "dur": 5.4, "site": [0, 0, -2], "shot": "path"},
]

var st            # Street
var VW: Array = []
var WIDE := {"p": Vector3(0, 16, 30), "look": Vector3(0, 3, -7)}
var HOME := {"p": Vector3(0, 12.5, 20), "look": Vector3(0, 2.0, -8)}
var OUT := {"p": Vector3(0, 6.5, 30), "look": Vector3(0, 5.2, -2)}

var walls: Array = []        # [mesh, clean colour]
var floor_m: StandardMaterial3D
var shutter: Node3D
var facade: Array = []
var junk: Array = []
var lamps: Array = []
var lights: Array = []
var fan: Node3D
var counter: Array = []
var shelves: Array = []
var display: Array = []
var deco: Array = []
var photo: Array = []
var opening: Array = []
var ribbon: Array = []
var people: Array = []
var fan_on := false

func _init() -> void:
	VW = [OUT]
	for i in range(1, TASKS.size()):
		VW.append(HOME)

# ---------------------------------------------------------------- helpers
func box(size: Vector3, pos: Vector3, col: Color, par: Node3D = self, rough := 0.85) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	m.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = col
	mat.roughness = rough
	m.material_override = mat
	m.position = pos
	par.add_child(m)
	return m

func kit(n: String, pos: Vector3, rot_y := 0.0, s := K) -> Node3D:
	var ps: PackedScene = load("res://art/shop/%s.glb" % n)
	var o: Node3D = ps.instantiate() if ps else Node3D.new()
	o.scale = Vector3.ONE * s
	o.rotation.y = rot_y
	o.position = pos
	add_child(o)
	return o

# a Kenney City Kit building, its white walls tinted (Chennai colours) and its green trims recoloured
func city(n: String, pos: Vector3, s: float, wall: Color, trim: Color, rot_y := 0.0) -> Node3D:
	var o := kit_at("res://art/city/%s.glb" % n, pos, rot_y, s)
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode cull_disabled;
uniform sampler2D tex : source_color, filter_nearest;
uniform vec3 wall = vec3(1.0);
uniform vec3 trim = vec3(0.85, 0.2, 0.2);
void fragment() {
	vec3 c = texture(tex, UV).rgb;
	float mx = max(c.r, max(c.g, c.b));
	float mn = min(c.r, min(c.g, c.b));
	if (mx - mn < 0.09 && mx > 0.7) {
		c = wall * mx;
	} else if (c.g > c.r * 1.3 && c.g > c.b * 1.05) {
		c = trim * clamp(dot(c, vec3(0.3, 0.59, 0.11)) / 0.42, 0.5, 1.4);
	}
	ALBEDO = c;
	ROUGHNESS = 0.8;
}
"""
	for c in o.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		var src = mi.get_active_material(0)
		if src is BaseMaterial3D and src.albedo_texture:
			var m := ShaderMaterial.new()
			m.shader = sh
			m.set_shader_parameter("tex", src.albedo_texture)
			m.set_shader_parameter("wall", Vector3(wall.r, wall.g, wall.b))
			m.set_shader_parameter("trim", Vector3(trim.r, trim.g, trim.b))
			mi.material_override = m
	return o

func kit_at(path: String, pos: Vector3, rot_y: float, s: float) -> Node3D:
	var ps: PackedScene = load(path)
	var o: Node3D = ps.instantiate() if ps else Node3D.new()
	o.scale = Vector3.ONE * s
	o.rotation.y = rot_y
	o.position = pos
	add_child(o)
	return o

# plaster for walls, terracotta-and-cream tiles for the floor (both drawn in code, mapped by world position)
func plaster_tex() -> Texture2D:
	var n := FastNoiseLite.new()
	n.frequency = 0.05
	var t := NoiseTexture2D.new()
	t.width = 256
	t.height = 256
	t.seamless = true
	t.noise = n
	var g := Gradient.new()
	g.set_color(0, Color(0.86, 0.84, 0.8))
	g.set_color(1, Color(1, 1, 1))
	t.color_ramp = g
	return t

func tile_tex() -> Texture2D:
	var img := Image.create(128, 128, false, Image.FORMAT_RGB8)
	for y in 128:
		for x in 128:
			var a := (x / 64 + y / 64) % 2 == 0
			var col := Color("#F1E3C8") if a else Color("#C8693E")
			if x % 64 < 3 or y % 64 < 3:
				col = Color("#8f7a66")
			img.set_pixel(x, y, col)
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)

func textured(m: MeshInstance3D, t: Texture2D, sc: float) -> void:
	var mat: StandardMaterial3D = m.material_override
	mat.albedo_texture = t
	mat.uv1_triplanar = true
	mat.uv1_scale = Vector3.ONE * sc

func hide_all(a: Array) -> void:
	for o in a:
		(o as Node3D).visible = false

const CRK_COLS := [Color("#D7263D"), Color("#FFC93C"), Color("#FF7A1A"), Color("#2E86DE"), Color("#7B3FBF"), Color("#2EAD5B")]
func cracker_box(pos: Vector3, size: Vector3, i: int, par: Node3D = self) -> MeshInstance3D:
	var b := box(size, pos, CRK_COLS[i % CRK_COLS.size()], par, 0.5)
	box(Vector3(size.x + 0.02, size.y * 0.18, size.z + 0.02), Vector3.ZERO, Color("#F5C542"), b, 0.3)
	return b

# ---------------------------------------------------------------- build the room (everything not yet done is hidden)
func build() -> void:
	# street outside and the neighbours
	box(Vector3(60, 0.2, 30), Vector3(0, -0.1, 14), Color("#8b8378"))
	box(Vector3(60, 0.25, 2.4), Vector3(0, 0.02, 1.4), Color("#a39a8c"))
	# Bunder Street: colourful city blocks on both sides of our shop (Kenney City Kit, tinted)
	city("building-k", Vector3(-19.0, 0, -5.3), 12.0, Color("#F2C94C"), Color("#D7263D"))
	city("building-g", Vector3(12.4, 0, -5.2), 12.0, Color("#F4A6B7"), Color("#2E86DE"))
	city("building-c", Vector3(-36.8, 0, -6.3), 12.0, Color("#9ED9CF"), Color("#E85D3B"))
	city("building-f", Vector3(23.4, 0, -5.9), 12.0, Color("#FFD9A0"), Color("#2EAD5B"))
	for i in 5:
		city("low-detail-building-wide-a" if i % 2 else "low-detail-building-d", Vector3(-30 + i * 15, 0, 34), 12.0, Color("#E8D9C5"), Color("#B3171E"), PI)
	# our building: upper floors above the shop and a striped canopy (outside only; hidden once the shutter opens)
	facade.append(city("building-h", Vector3(0, RH - 0.05, -6.6), 13.6, Color("#FFE7B3"), Color("#B3171E")))
	var cano := Node3D.new()
	add_child(cano)
	for i in 8:
		box(Vector3(1.5, 0.12, 2.0), Vector3(-5.25 + i * 1.5, RH + 0.25, 1.0), Color("#D7263D") if i % 2 == 0 else Color("#FFF1D6"), cano, 0.7)
	cano.rotation.x = 0.18
	facade.append(cano)
	# floor
	var fl := box(Vector3(2 * RW, 0.2, RD), Vector3(0, -0.05, -RD / 2), Color("#6f6458"))
	floor_m = fl.material_override
	textured(fl, tile_tex(), 0.25)
	var pl := plaster_tex()
	# walls (dirty grey until painted): back, left, right, and a dado band
	walls.append([box(Vector3(2 * RW + 0.6, RH, 0.3), Vector3(0, RH / 2, -RD - 0.15), Color("#8a8378")), Color("#FFE6B8")])
	for s in [-1.0, 1.0]:
		walls.append([box(Vector3(0.3, RH, RD), Vector3(s * (RW + 0.15), RH / 2, -RD / 2), Color("#7f786e")), Color("#FFDCA8")])
	walls.append([box(Vector3(2 * RW, 1.0, 0.05), Vector3(0, 0.5, -RD + 0.02), Color("#5d574f")), Color("#8E2B2B")])
	for s in [-1.0, 1.0]:
		walls.append([box(Vector3(0.05, 1.0, RD), Vector3(s * (RW - 0.02), 0.5, -RD / 2), Color("#5d574f")), Color("#8E2B2B")])
	for w in walls:
		textured(w[0], pl, 0.18)
	# wooden beams along the wall tops and brick pillars at the front corners give the room some weight
	box(Vector3(2 * RW + 1.0, 0.35, 0.5), Vector3(0, RH + 0.1, -RD - 0.1), Color("#6B3F25"))
	for s in [-1.0, 1.0]:
		box(Vector3(0.5, 0.35, RD + 0.4), Vector3(s * (RW + 0.2), RH + 0.1, -RD / 2), Color("#6B3F25"))
		var pil := box(Vector3(0.8, RH + 0.5, 0.8), Vector3(s * (RW + 0.25), (RH + 0.5) / 2, 0.05), Color("#B5583A"))
		textured(pil, pl, 0.3)
	# front: lintel above the shutter, and the rusty shutter itself (ridged)
	facade.append(box(Vector3(2 * RW + 0.6, 0.9, 0.4), Vector3(0, RH - 0.2, 0.1), Color("#9c7a64")))
	shutter = Node3D.new()
	add_child(shutter)
	box(Vector3(2 * RW, RH - 0.6, 0.12), Vector3(0, (RH - 0.6) / 2, 0.2), Color("#8a5a3c"), shutter, 0.95)
	for i in 14:
		box(Vector3(2 * RW, 0.06, 0.16), Vector3(0, 0.15 + i * 0.24, 0.24), Color("#6e4329") if i % 3 else Color("#a86a40"), shutter, 0.95)
	box(Vector3(1.2, 0.18, 0.2), Vector3(0, 0.35, 0.33), Color("#3b3b3b"), shutter, 0.4)
	facade.append(shutter)
	# junk: old boxes and cobwebs
	var J := [[-4.6, -3.0, 0.4], [-3.8, -3.6, -0.3], [3.9, -5.2, 0.9], [4.6, -9.0, 0.2], [-4.4, -11.5, -0.7], [1.2, -12.6, 0.5], [-1.5, -6.6, 1.2]]
	for i in J.size():
		var q: Array = J[i]
		junk.append(kit("cardboardBoxOpen" if i % 2 else "cardboardBoxClosed", Vector3(q[0], 0, q[1]), q[2], 3.6))
	for c in [[-RW + 0.4, RH - 0.5, -RD + 0.4, 0.8], [RW - 0.4, RH - 0.5, -RD + 0.4, -0.8], [-RW + 0.3, RH - 0.6, -4.0, 1.57]]:
		var w := MeshInstance3D.new()
		var qm := QuadMesh.new()
		qm.size = Vector2(1.8, 1.8)
		w.mesh = qm
		var wm := StandardMaterial3D.new()
		wm.albedo_texture = _web_tex()
		wm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		wm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		wm.cull_mode = BaseMaterial3D.CULL_DISABLED
		w.material_override = wm
		w.position = Vector3(c[0], c[1], c[2])
		w.rotation.y = c[3]
		add_child(w)
		junk.append(w)
	# 4. lights and fan
	for x in [-3.0, 3.0]:
		var l := kit("lampSquareCeiling", Vector3(x - 0.18, RH - 0.7, -9.0), 0.0, 3.0)
		lamps.append(l)
		var o := OmniLight3D.new()
		o.light_color = Color(1, 0.86, 0.62)
		o.light_energy = 0.0
		o.omni_range = 11.0
		o.position = Vector3(x, RH - 1.0, -8.5)
		add_child(o)
		lights.append(o)
	fan = kit("ceilingFan", Vector3(0, RH - 0.1, -6.5), 0.0, 4.0)
	lamps.append(fan)
	# 5. counter (Kenney kitchen bar) with the cash box (radio) and a stool behind
	for i in 6:
		counter.append(kit("kitchenBar", Vector3(-3.9 + i * 1.29, 0, -4.2), 0.0))
	counter.append(kit("kitchenBarEnd", Vector3(-3.9 + 6 * 1.29, 0, -4.2), 0.0))
	counter.append(kit("radio", Vector3(1.2, 1.26, -4.5), PI, 2.4))
	counter.append(kit("stoolBar", Vector3(-1.0, 0, -6.4), 0.0, 3.0))
	# 6. wall shelves along the back wall, stocked with cracker boxes
	for i in 8:
		var bc := kit("bookcaseOpen", Vector3(-4.85 + i * 1.22, 0, -RD + 0.78), 0.0, 3.0)
		shelves.append(bc)
		for sh in 3:
			for k in 2:
				cracker_box(Vector3(0.1 + k * 0.17, 0.12 + sh * 0.26, -0.12), Vector3(0.13, 0.12, 0.13), i * 3 + sh + k, bc)
	# 7. display cabinets (glass tables) and side racks, stocked
	for s in [-1.0, 1.0]:
		var tg := kit("tableGlass", Vector3(s * 4.6 - 1.25, 0, -6.6), 0.0, 3.0)
		display.append(tg)
		for k in 4:
			cracker_box(Vector3(0.12 + k * 0.17, 0.36, -0.22), Vector3(0.14, 0.08, 0.2), k + (3 if s > 0 else 0), tg)
		var rk := kit("bookcaseClosedWide", Vector3(s * (RW - 0.77), 0, -9.0 - s * 1.2), -s * PI / 2, 3.0)
		display.append(rk)
		for k in 3:
			cracker_box(Vector3(0.15 + k * 0.25, 0.86, -0.12), Vector3(0.2, 0.14, 0.18), k + 2, rk)
	# 8. signboard with marigold garlands and wall lanterns
	var sb := box(Vector3(6.6, 0.95, 0.2), Vector3(0, RH - 0.45, -RD + 0.12), Color("#B3171E"), self, 0.5)
	box(Vector3(6.8, 1.1, 0.12), Vector3(0, 0, -0.06), Color("#F5C542"), sb, 0.3)
	var lb := Label3D.new()
	lb.text = "SIVAKASI CRACKERS"
	lb.font = load("res://art/LilitaOne.ttf")
	lb.font_size = 96
	lb.pixel_size = 0.0045
	lb.modulate = Color("#FFE27A")
	lb.outline_modulate = Color("#5a0a0e")
	lb.outline_size = 18
	lb.position = Vector3(0, 0, 0.12)
	sb.add_child(lb)
	deco.append(sb)
	for g in [[Vector3(-RW + 0.2, RH - 0.15, -0.6), Vector3(RW - 0.2, RH - 0.15, -0.6)], [Vector3(-RW + 0.25, RH - 0.15, -1.0), Vector3(-RW + 0.25, RH - 0.15, -RD + 0.4)], [Vector3(RW - 0.25, RH - 0.15, -1.0), Vector3(RW - 0.25, RH - 0.15, -RD + 0.4)]]:
		deco.append(_garland(g[0], g[1], 0.7))
	for s in [-1.0, 1.0]:
		deco.append(kit("lampWall", Vector3(s * (RW - 0.05), 2.2, -6.0), -s * PI / 2, 3.0))
	# 9. Grandpa's photo with a small lamp below it
	var fr := box(Vector3(1.0, 1.2, 0.08), Vector3(-RW + 0.9, 3.3, -RD + 0.1), Color("#4a2a18"), self, 0.6)
	var ph := MeshInstance3D.new()
	var pq := QuadMesh.new()
	pq.size = Vector2(0.8, 1.0)
	ph.mesh = pq
	var pm := StandardMaterial3D.new()
	pm.albedo_texture = load("res://art/shop/grandpa.png")
	ph.material_override = pm
	ph.position = Vector3(0, 0, 0.05)
	fr.add_child(ph)
	photo.append(fr)
	photo.append(_garland(Vector3(-RW + 0.35, 3.85, -RD + 0.2), Vector3(-RW + 1.45, 3.85, -RD + 0.2), 0.35))
	# 10. opening: entrance rug, plants, the ribbon (two halves) and customers
	opening.append(kit("rugRectangle", Vector3(-2.35, 0.02, -0.4), 0.0, 3.0))
	for s in [-1.0, 1.0]:
		opening.append(kit("pottedPlant", Vector3(s * 5.0 - 0.3, 0, -0.8), 0.0, 3.0))
		ribbon.append(box(Vector3(5.6, 0.18, 0.05), Vector3(s * 2.8, 1.4, -0.2), Color("#E3202F"), self, 0.4))
	ribbon.append(box(Vector3(0.6, 0.6, 0.08), Vector3(0, 1.4, -0.18), Color("#FFC93C"), self, 0.4))
	# opening night: a row of diyas along the counter front (lit by the Grand Opening)
	for a in [lamps, counter, shelves, display, deco, photo, opening, ribbon, people]:
		hide_all(a)

func _person(col: Color) -> Node3D:
	var p := Node3D.new()
	add_child(p)
	var b := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = 0.38
	cm.height = 1.5
	b.mesh = cm
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	b.material_override = m
	b.position.y = 0.75
	p.add_child(b)
	var h := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.3
	sm.height = 0.6
	h.mesh = sm
	var hm := StandardMaterial3D.new()
	hm.albedo_color = Color("#C68B5E")
	h.material_override = hm
	h.position.y = 1.75
	p.add_child(h)
	var hair := MeshInstance3D.new()
	var hs := SphereMesh.new()
	hs.radius = 0.31
	hs.height = 0.36
	hs.is_hemisphere = true
	hair.mesh = hs
	var hr := StandardMaterial3D.new()
	hr.albedo_color = Color("#1d1410")
	hair.material_override = hr
	hair.position.y = 1.8
	p.add_child(hair)
	return p

func _garland(a: Vector3, b: Vector3, sag: float) -> Node3D:
	var g := Node3D.new()
	add_child(g)
	var n := int(a.distance_to(b) / 0.26)
	var sm := SphereMesh.new()
	sm.radius = 0.13
	sm.height = 0.26
	sm.radial_segments = 8
	sm.rings = 4
	var mo := StandardMaterial3D.new()
	mo.albedo_color = Color("#FF8A00")
	var my := StandardMaterial3D.new()
	my.albedo_color = Color("#FFD23F")
	for i in n + 1:
		var t: float = float(i) / maxf(1, n)
		var m := MeshInstance3D.new()
		m.mesh = sm
		m.material_override = my if i % 3 == 0 else mo
		m.position = a.lerp(b, t) - Vector3(0, sin(t * PI * 2.0) * 0.0 + sin(t * PI) * sag, 0)
		g.add_child(m)
	return g

func _web_tex() -> Texture2D:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c := Vector2(0, 0)
	for k in 7:
		var a: float = k * PI / 12.0
		for r in 64:
			var p: Vector2 = c + Vector2(cos(a), sin(a)) * float(r)
			if p.x < 64 and p.y < 64:
				img.set_pixelv(p, Color(0.9, 0.9, 0.9, 0.7))
	for ring in [14, 26, 38, 50]:
		for s in 90:
			var a2: float = s / 90.0 * PI / 2.0
			var p2: Vector2 = c + Vector2(cos(a2), sin(a2)) * float(ring)
			if p2.x < 64 and p2.y < 64:
				img.set_pixelv(p2, Color(0.9, 0.9, 0.9, 0.55))
	return ImageTexture.create_from_image(img)

# ---------------------------------------------------------------- the builds
func run(name: String) -> void:
	match name:
		"Open the Rusty Shutter":
			var y0 := shutter.position.y
			st.after(0.2, func(): st.dust(Vector3(0, 0, 1), 16, 5))
			st.tween(1.6, func(k: float):
				shutter.position.y = y0 + st.sm(k) * (RH - 0.6)
				shutter.scale.y = maxf(0.05, 1.0 - st.sm(k) * 0.95), 0.4)
			st.after(2.1, func():
				for f in facade:
					f.visible = false
				st.sparkle(Vector3(0, 0, -4), 30, 2.5))
		"Clean the Dusty Shop":
			for i in junk.size():
				st.sink_away(junk[i], 0.2 + i * 0.22)
				var p: Vector3 = junk[i].position
				st.after(0.2 + i * 0.22, func(): st.dust(p, 5, 0.8))
			var c0 := floor_m.albedo_color
			st.tween(1.2, func(k: float): floor_m.albedo_color = c0.lerp(Color.WHITE, k), 1.6)
			st.after(2.8, func(): st.sparkle(Vector3(0, 0, -8), 30, 2))
		"Paint the Walls":
			for i in walls.size():
				var w: MeshInstance3D = walls[i][0]
				var to: Color = walls[i][1]
				var mat: StandardMaterial3D = w.material_override
				var from := mat.albedo_color
				st.tween(1.0, func(k: float): mat.albedo_color = from.lerp(to, st.sm(k)), 0.3 + i * 0.3)
			st.after(2.4, func():
				st.sparkle(Vector3(0, 0, -12), 30, 3)
				st.ring(Vector3(0, 0, -9)))
		"Lights and Ceiling Fan":
			for i in lamps.size():
				st.drop_in(lamps[i], 0.2 + i * 0.3, 2.5)
			st.after(1.4, func(): fan_on = true)
			for i in lights.size():
				var o: OmniLight3D = lights[i]
				st.tween(0.6, func(k: float): o.light_energy = k * 2.4 * (0.6 + 0.4 * absf(sin(k * 9.0))) if k < 1 else 2.4, 1.3 + i * 0.25)
			st.after(2.2, func(): st.sparkle(Vector3(0, 0, -8), 26, 3.4))
		"Counter and Cash Box":
			for i in counter.size():
				st.drop_in(counter[i], 0.2 + i * 0.16, 3)
			st.after(1.0, func(): st.dust(Vector3(0, 0, -4.4), 10, 3))
			st.after(2.2, func():
				st.sparkle(Vector3(1.2, 0, -4.5), 30, 1.8)
				st.ring(Vector3(0, 0, -4.4)))
		"Wall Shelves":
			for i in shelves.size():
				st.grow(shelves[i], 0.2 + i * 0.2, 0.55)
			st.after(2.6, func(): st.sparkle(Vector3(0, 0, -13.5), 36, 2.4))
		"Display Cabinet and Racks":
			for i in display.size():
				st.pop(display[i], 0.3 + i * 0.35, 0.5)
			st.after(2.6, func():
				st.sparkle(Vector3(-4.6, 0, -6.6), 24, 1.6)
				st.sparkle(Vector3(4.6, 0, -6.6), 24, 1.6))
		"Signboard and Decorations":
			for i in deco.size():
				st.drop_in(deco[i], 0.2 + i * 0.3, 2.0)
			st.after(2.4, func():
				st.sparkle(Vector3(0, 0, -14.5), 40, 3.6)
				st.ring(Vector3(0, 0, -12), Color("#ffd27a")))
		"Grandpa's Photo":
			for i in photo.size():
				st.pop(photo[i], 0.3 + i * 0.4, 0.55)
			st.after(1.6, func():
				st.fx.part(false, Vector3(-RW + 0.9, 2.45, -RD + 0.4), {"s0": 0.2, "s1": 1.6, "col": Color(1, 0.66, 0.26), "op": 0.9, "d": 999.0, "add": true, "in": 0.5, "fl": 9.0})
				st.fx.part(false, Vector3(-RW + 0.9, 2.45, -RD + 0.4), {"s0": 0.05, "s1": 0.5, "col": Color(1, 0.95, 0.75), "op": 1.0, "d": 999.0, "add": true, "in": 0.35, "fl": 13.0})
				st.sparkle(Vector3(-RW + 0.9, 0, -RD + 0.6), 24, 3.2))
		"Grand Opening":
			for i in opening.size():
				st.pop(opening[i], 0.1 + i * 0.12, 0.45)
			for r in ribbon:
				st.pop(r, 0.2, 0.4)
			# the ribbon is cut: the two halves swing down, the bow drops
			st.after(1.4, func(): st.sparkle(Vector3(0, 0, -0.2), 40, 1.6))
			for i in ribbon.size():
				var rb: Node3D = ribbon[i]
				var s := -1.0 if i == 0 else 1.0
				if i < 2:
					# each half snaps back towards its post and disappears
					var x0r: float = rb.position.x
					st.tween(0.5, func(k: float):
						rb.position.x = x0r + s * k * 2.8
						rb.scale.x = maxf(0.01, 1.0 - k)
						if k >= 1:
							rb.visible = false, 1.45)
				else:
					st.tween(0.5, func(k: float): rb.position.y = 1.4 - k * 1.3, 1.45)
			for i in 9:
				var at := Vector3(-4.0 + i * 1.0, 0.25, -3.6)
				st.after(2.0 + i * 0.12, func():
					st.fx.part(false, at, {"s0": 0.15, "s1": 1.2, "col": Color(1, 0.66, 0.26), "op": 0.9, "d": 999.0, "add": true, "in": 0.4, "fl": 9.0})
					st.fx.part(false, at, {"s0": 0.05, "s1": 0.35, "col": Color(1, 0.95, 0.75), "op": 1.0, "d": 999.0, "add": true, "in": 0.3, "fl": 13.0}))
			for o in lights:
				var ol: OmniLight3D = o
				st.tween(0.8, func(k: float): ol.light_energy = 2.4 + k * 1.2, 2.2)
			st.after(3.0, func():
				st.sparkle(Vector3(0, 0, -4), 60, 3.4)
				st.ring(Vector3(0, 0, -3), Color("#ffd27a")))

func _process(dt: float) -> void:
	if fan_on and is_instance_valid(fan) and fan.visible:
		fan.rotate_y(dt * 7.0)
