# Area 2, option A (18 Nov): the street view home screen of GHILLI CRACKERS on Bunder Street, Chennai.
# Made only of model files (.glb): our textured street, shop row, poles, wires, auto, bike and cart
# (art/a2/gen, made by tools/a2gen.py from Poly Haven CC0 textures) plus Kenney CC0 kits (buildings behind,
# cars, street lights, palms, people). Photo sky: Poly Haven HDRI. No code-made boxes.
extends Node3D
class_name Bazaar

const A := "res://art/a2/%s.glb"
var st            # Street
var HOME := {"p": Vector3(0.3, 2.3, 15.5), "look": Vector3(0.0, 4.6, 0.0)}
var walkers: Array = []
var SKYR := 110.0
var movers: Array = []

func put(path: String, pos: Vector3, s := 1.0, rot_y := 0.0) -> Node3D:
	var ps: PackedScene = load(path if path.begins_with("res://") else A % path)
	var o: Node3D = ps.instantiate()
	o.scale = Vector3.ONE * s
	o.rotation.y = rot_y
	o.position = pos
	add_child(o)
	if path.begins_with("nature/"):
		_leaves(o)
	return o

# Kenney nature colours read cyan under the photo sky: natural greens and bark
func _leaves(o: Node3D) -> void:
	for c in o.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		for i in mi.mesh.get_surface_count():
			var src := mi.get_active_material(i)
			if src is StandardMaterial3D:
				var n := String(src.resource_name).to_lower()
				var m: StandardMaterial3D = src.duplicate()
				if n.contains("leaf") or n.contains("grass") or n.contains("green"):
					m.albedo_color = Color("#74b043")
				elif n.contains("wood") or n.contains("bark") or n.contains("trunk"):
					m.albedo_color = Color("#8a6a4a")
				mi.set_surface_override_material(i, m)

func person(kind: String, pos: Vector3, rot_y: float, anim := "idle", speed := 0.0) -> Node3D:
	var o := put("people/character-" + kind, pos, 2.5, rot_y)
	var ap: AnimationPlayer = o.find_child("AnimationPlayer", true, false)
	if ap and ap.has_animation(anim):
		ap.get_animation(anim).loop_mode = Animation.LOOP_LINEAR
		ap.play(anim)
		ap.seek(randf() * 1.0, true)
	if speed != 0.0:
		walkers.append({"o": o, "v": speed})
	return o

func light() -> void:
	# the photo sky lights the scene too (ambient from the sky), with a warm late-afternoon sun
	var sky := Sky.new()
	var pm := PanoramaSkyMaterial.new()
	# a plain sky picture (18 Nov): the photo sky turned into a normal jpg, no HDR work on phones
	pm.panorama = load("res://art/a2/sky/sky_ldr.jpg")
	pm.energy_multiplier = 1.0
	sky.sky_material = pm
	var env: Environment = st.env
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.sky_rotation = Vector3(0, deg_to_rad(SKYR), 0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#c8d4ea")
	env.ambient_light_energy = 0.85
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.tonemap_exposure = 1.0
	env.fog_enabled = true
	env.fog_light_color = Color("#cfe0f0")
	env.fog_depth_begin = 60
	env.fog_depth_end = 220
	var sun: DirectionalLight3D = st.sun
	sun.light_color = Color("#fff0d8")
	sun.light_energy = 1.15
	sun.shadow_enabled = not st.lite and not OS.has_feature("mobile")
	sun.directional_shadow_max_distance = 80
	sun.rotation = Vector3(deg_to_rad(-42), deg_to_rad(-35), 0)

func build() -> void:
	# street and shops
	put("gen/road", Vector3.ZERO, 1.0)
	O.shell = put("gen/ghilli", Vector3.ZERO, 1.0)
	put("gen/row", Vector3.ZERO, 1.0)
	put("gen/wires", Vector3.ZERO, 1.0)
	for x in [-26, -6, 14, 34]:
		put("gen/pole", Vector3(x, 0.18, 3.0), 1.0)
	# taller buildings behind the row (Kenney City Kit), palms and trees between them
	var back := [["building-l", -30, -18], ["building-n", -15, -22], ["building-i", -4, -17], ["building-m", 6, -24], ["building-l", 13, -17], ["building-j", 24, -20], ["building-g", -22, -15], ["building-m", 36, -26], ["building-n", -44, -24], ["building-d", 30, -14]]
	for b in back:
		put("city/" + b[0], Vector3(b[1], 0, b[2]), 9.0, PI)
	for t in [[-9.5, -13, 9.0], [2.5, -12.5, 10.0], [16.5, -13.5, 9.5], [-24, -14, 8.5], [27, -13, 9.0], [-40, -13, 9.0]]:
		put("nature/tree_palmTall", Vector3(t[0], 0, t[1]), t[2], randf() * TAU)
	for t in [[-17, -12], [10, -12]]:
		put("nature/tree_oak", Vector3(t[0], 0, t[1]), 7.0)
	# a neem tree on the far pavement (near the camera, left) and potted plants by the shops
	put("nature/tree_palmTall", Vector3(-6.6, 0.18, 2.6), 9.5, 0.6)
	put("nature/tree_palmBend", Vector3(7.2, 0.18, 2.6), 9.0, 2.6)
	put("nature/tree_detailed", Vector3(-11, 0.18, 18.5), 6.0, 0.6)
	put("nature/tree_default", Vector3(25, 0.18, 18.8), 6.5, 2.0)
	for p in [[-4.6, 1.0], [4.6, 1.0], [-13.0, 1.2], [12.9, 1.0]]:
		put("nature/pot_large", Vector3(p[0], 0.18, p[1]), 1.6)
		put("nature/plant_bush", Vector3(p[0], 0.45, p[1]), 1.4)
	# street lights on both pavements
	for x in [-15, 15, 32]:
		put("roads/light-curved", Vector3(x, 0.18, 3.0), 9.5, 0.0)
	for x in [-34, 26]:
		put("roads/light-curved", Vector3(x, 0.18, 16.1), 9.5, PI)
	put("roads/dumpster", Vector3(-22.5, 0.18, 2.4), 3.0, 0.0)
	put("gen/stall", Vector3(8.6, 0.18, 2.1), 1.0, 0.2)
	# traffic: autos, cars, bikes (parked and moving)
	put("gen/auto", Vector3(-4.6, 0.0, 5.0), 1.0, PI / 2 + 0.15)
	put("gen/bike", Vector3(4.4, 0.0, 4.6), 1.0, 0.5)
	put("gen/bike", Vector3(5.3, 0.0, 4.6), 1.0, 0.45)
	movers.append({"o": put("gen/bike", Vector3(-40, 0.0, 7.6), 1.0, PI / 2), "v": 4.5})
	put("cars/taxi", Vector3(-17.5, 0.3, 5.0), 1.7, PI / 2)
	movers.append({"o": put("gen/auto", Vector3(30, 0.0, 7.4), 1.0, PI / 2), "v": 3.6})
	put("cars/hatchback-sports", Vector3(22, 0.3, 5.0), 1.7, -PI / 2)
	# people: shoppers, a vendor, people walking past
	person("female-a", Vector3(-9.2, 0.18, 1.6), 0.3)
	person("male-c", Vector3(-7.8, 0.18, 1.9), -0.5)
	person("female-c", Vector3(9.6, 0.18, 2.2), PI, "idle")
	person("worker", Vector3(8.0, 0.18, 1.2), 0.2, "idle")
	person("male-e", Vector3(13.8, 0.18, 1.5), 0.6)
	person("female-b", Vector3(-15, 0.18, 2.6), PI / 2, "walk", 1.1)
	person("male-b", Vector3(-2, 0.18, 17.2), -PI / 2, "walk", -1.2)
	person("female-e", Vector3(6, 0.18, 17.6), PI / 2, "walk", 1.0)
	parts()
	merge_static()
	if OS.has_feature("mobile"):
		set_busy(false)

# ---------------------------------------------------------------- builds
var O := {}

# camera for each build: a soft drift ~25% of the way towards the build site (the street stays in view)
func views() -> Array:
	var out := []
	for T in ShopArea.TASKS:
		var s := Vector3(T.site[0], T.site[1], T.site[2])
		out.append({"p": HOME.p.lerp(Vector3(s.x, HOME.p.y, 7.0), 0.28), "look": HOME.look.lerp(s, 0.15)})
	return out

func hide_put(path: String, pos: Vector3, s := 1.0, rot_y := 0.0) -> Node3D:
	var o := put(path, pos, s, rot_y)
	o.visible = false
	return o

func glow_mats(o: Node3D) -> Array:
	var out := []
	for c in o.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		for i in mi.mesh.get_surface_count():
			var m := mi.get_active_material(i)
			if m is StandardMaterial3D and (m as StandardMaterial3D).emission_enabled:
				var d: StandardMaterial3D = m.duplicate()
				d.emission_energy_multiplier = 0.0
				mi.set_surface_override_material(i, d)
				out.append(d)
	return out

func parts() -> void:
	O.shell_new = hide_put("gen/ghilli_new", Vector3.ZERO)
	O.shutter = put("gen/shutter", Vector3(0, 3.3, -0.12), 1.0)
	O.bulb = put("gen/bulb", Vector3(0.4, 3.3, -2.0))
	O.bulb_m = glow_mats(O.bulb)
	O.junk = []
	for p in [[-2.6, 0.18, 1.1, 0.3], [-1.7, 0.18, 1.3, 1.1], [2.3, 0.18, 1.2, 0.6], [-1.0, 0.19, -1.8, 0.2], [1.5, 0.19, -2.4, 1.4], [0.5, 0.19, -1.2, 2.2]]:
		O.junk.append(put("res://art/shop/cardboardBoxClosed.glb", Vector3(p[0], p[1], p[2]), 3.2, p[3]))
	O.old_step = put("gen/oldstep", Vector3.ZERO)
	O.new_step = hide_put("gen/newstep", Vector3.ZERO)
	O.tiles = []
	for i in 9:
		O.tiles.append(hide_put("gen/tile", Vector3(-3.44 + i * 0.86, 0.19, 1.2)))
	O.old_board = put("gen/oldboard", Vector3(0, 3.76, 0.14))
	O.sign = hide_put("gen/sign", Vector3(0, 3.76, 0.12))
	O.sign_m = glow_mats(O.sign)
	O.tubes = [hide_put("gen/tube", Vector3(-1.5, 3.15, -3.85)), hide_put("gen/tube", Vector3(1.5, 3.15, -3.85))]
	O.tube_m = glow_mats(O.tubes[0]) + glow_mats(O.tubes[1])
	O.fan = hide_put("res://art/shop/ceilingFan.glb", Vector3(0, 3.3, -1.8), 4.5)
	O.counter = hide_put("gen/counter", Vector3(0, 0.18, -1.3))
	O.cash = hide_put("gen/cashbox", Vector3(1.3, 1.12, -1.3), 1.0, -0.2)
	O.shelves = []
	for x in [-2.5, -0.95, 0.95, 2.5]:
		O.shelves.append(hide_put("gen/shelf", Vector3(x, 0.19, -3.56)))
	O.photo = hide_put("gen/photo", Vector3(0, 2.45, -3.45))
	O.racks = [hide_put("gen/rack", Vector3(-2.9, 0.18, 2.5), 0.8, 0.12), hide_put("gen/rack", Vector3(2.9, 0.18, 2.5), 0.8, -0.12)]
	O.awn = hide_put("gen/awning", Vector3(0, 3.36, 0.16))
	O.gar = [hide_put("gen/gar_top", Vector3.ZERO), hide_put("gen/gar_side", Vector3(-3.15, 3.2, 0.3)), hide_put("gen/gar_side", Vector3(3.15, 3.2, 0.3))]
	O.lan = []
	for x in [-2.4, 0.0, 2.4]:
		O.lan.append(hide_put("gen/lantern", Vector3(x, 3.05, 1.1)))
	O.lan_m = []
	for l in O.lan:
		O.lan_m += glow_mats(l)
	O.rib = [hide_put("gen/ribbon_l", Vector3(0, 1.2, 1.05)), hide_put("gen/ribbon_r", Vector3(0, 1.2, 1.05)), hide_put("gen/bow", Vector3(0, 1.2, 1.08))]
	var lt := OmniLight3D.new()
	lt.light_color = Color("#ffd9a0")
	lt.light_energy = 0.0
	lt.omni_range = 9.0
	lt.omni_attenuation = 1.2
	lt.position = Vector3(0, 2.8, -2.4)
	add_child(lt)
	O.light = lt

func glow(ms: Array, e: float) -> void:
	for m in ms:
		m.emission_energy_multiplier = e

func done_fx(site: Vector3, d: float) -> void:
	st.after(d, func():
		st.sparkle(Vector3(site.x, 0, site.z + 0.6), 36, site.y)
		st.ring(Vector3(site.x, 0, maxf(site.z, -1.0) + 1.2)))
	st.after(d + 0.4, func(): st.glide_to(HOME))

func squash_drop(o: Node3D, delay: float, h := 3.0) -> void:
	st.drop_in(o, delay, h)
	var s: float = st._s0(o)
	st.tween(0.25, func(k: float):
		var q := sin(k * PI) * 0.18
		o.scale = Vector3(s * (1 + q * 0.6), s * (1 - q), s * (1 + q * 0.6)), delay + 0.5)

# every build of the shop (12); true when handled here
func run(name: String) -> bool:
	var i := -1
	for j in ShopArea.TASKS.size():
		if ShopArea.TASKS[j].n == name:
			i = j
	if i < 0:
		return false
	var T: Dictionary = ShopArea.TASKS[i]
	var site := Vector3(T.site[0], T.site[1], T.site[2])
	match i:
		0:   # Open the Rusty Shutter: it shakes, dust falls, it rolls up; the old bulb flickers on in the empty room
			var sh: Node3D = O.shutter
			st.tween(0.5, func(k: float):
				sh.position.x = sin(k * 40.0) * 0.04 * (1.0 - k)
				sh.position.z = -0.12 + sin(k * 33.0) * 0.02 * (1.0 - k), 0.1)
			st.after(0.25, func(): st.dust(Vector3(0, 0, 0.9), 16, 3.0))
			st.tween(1.6, func(k: float):
				sh.scale.y = maxf(0.02, 1.0 - st.sm(k))
				if k >= 1:
					sh.visible = false, 0.6)
			st.after(1.0, func(): st.dust(Vector3(0, 0, 0.6), 12, 2.6))
			for f in [[2.3, 0.7], [2.4, 0.0], [2.55, 0.9], [2.62, 0.1], [2.75, 1.0]]:
				st.after(f[0], func():
					O.light.light_energy = f[1] * 1.1
					glow(O.bulb_m, f[1] * 2.0))
			done_fx(site, 3.0)
		1:   # old boxes fly away, then a sweep of dust
			for j in O.junk.size():
				var o: Node3D = O.junk[j]
				var p0 := o.position
				var dir := -1.0 if p0.x < 0 else 1.0
				st.tween(0.9, func(k: float):
					o.position = Vector3(p0.x + dir * k * 7, p0.y + sin(k * PI) * 2.4, p0.z + k * 3)
					o.rotation.z = k * 4 * dir
					if k >= 1:
						o.visible = false, 0.2 + j * 0.14)
				st.after(0.2 + j * 0.14, func(): st.dust(p0, 6, 0.8))
			for k in 4:
				st.after(1.3 + k * 0.2, func(): st.dust(Vector3(-2.4 + k * 1.6, 0, 0.8), 8, 0.9))
			done_fx(site, 2.3)
		2:   # the new signboard drops onto the old board, its bulbs light up
			st.after(0.5, func(): (O.old_board as Node3D).visible = false)
			squash_drop(O.sign, 0.5, 2.5)
			st.tween(0.6, func(k: float): glow(O.sign_m, k * 2.0), 1.3)
			done_fx(site, 1.6)
		3:   # new tiled step, then tiles pop along the pavement
			st.after(0.6, func(): (O.old_step as Node3D).visible = false)
			squash_drop(O.new_step, 0.6, 1.5)
			for j in O.tiles.size():
				st.pop(O.tiles[j], 1.1 + j * 0.08, 0.3)
			done_fx(site, 2.3)
		4:   # paint: a burst of colour sweeps across, the old walls become the freshly painted ones
			for j in 9:
				var x := -3.6 + j * 0.9
				st.after(0.3 + j * 0.09, func():
					for y in [1.2, 2.6, 5.2]:
						st.fx.part(false, Vector3(x, y, 0.6), {"s0": 1.4, "s1": 2.6, "col": [Color("#fff1c8"), Color("#d7263d"), Color("#2ec4b6"), Color("#ffd23f")][(j + int(y)) % 4], "op": 0.85, "v": Vector3(0, -0.4, 0.8), "d": 0.9}))
			st.after(0.85, func():
				(O.shell as Node3D).visible = false
				(O.shell_new as Node3D).visible = true)
			done_fx(site, 1.9)
		5:   # two new tube lights flicker on, the fan drops in and spins
			st.pop(O.tubes[0], 0.2, 0.35)
			st.pop(O.tubes[1], 0.35, 0.35)
			squash_drop(O.fan, 0.5, 2.0)
			st.tween(0.8, func(k: float):
				var on := 1.0 if k >= 1 or fmod(k * 9.0, 1.0) > 0.4 else 0.25
				glow(O.tube_m, 2.5 * on)
				O.light.light_color = Color("#ffd9a0").lerp(Color("#fff6e6"), on)
				O.light.light_energy = 1.1 + 0.9 * on, 1.3)
			st.after(1.4, func(): fan_on = true)
			done_fx(site, 2.3)
		6:   # counter and cash box
			squash_drop(O.counter, 0.2, 3.0)
			squash_drop(O.cash, 0.9, 2.0)
			st.after(0.75, func(): st.dust(Vector3(0, 0, -1.0), 10, 2.5))
			done_fx(site, 2.1)
		7:   # shelves of crackers grow one by one, Grandpa's photo in the middle
			for j in O.shelves.size():
				st.grow(O.shelves[j], 0.2 + j * 0.22, 0.55)
			st.pop(O.photo, 1.3, 0.5)
			done_fx(site, 2.3)
		8:   # display racks on the pavement
			for j in O.racks.size():
				squash_drop(O.racks[j], 0.3 + j * 0.4, 2.0)
			done_fx(site, 1.8)
		9:   # the striped awning unrolls
			var aw: Node3D = O.awn
			st.tween(0.8, func(k: float):
				aw.visible = true
				aw.scale = Vector3(1, 1, maxf(0.01, st.back(k))), 0.3)
			done_fx(site, 1.5)
		10:  # marigold garlands, then glowing star lanterns
			for j in O.gar.size():
				st.pop(O.gar[j], 0.2 + j * 0.25, 0.4)
			for j in O.lan.size():
				squash_drop(O.lan[j], 1.2 + j * 0.2, 2.0)
			st.tween(0.6, func(k: float): glow(O.lan_m, k * 2.2), 2.0)
			done_fx(site, 2.8)
		11:  # grand opening: ribbon, cut, sparkle bursts, fireworks over the street
			for r in O.rib:
				st.pop(r, 0.2, 0.35)
			var rb: Array = O.rib
			st.tween(0.6, func(k: float):
				(rb[0] as Node3D).position.x = -k * 2
				(rb[1] as Node3D).position.x = k * 2
				(rb[0] as Node3D).scale.x = maxf(0.01, 1 - k)
				(rb[1] as Node3D).scale.x = maxf(0.01, 1 - k)
				(rb[2] as Node3D).position.y = 1.2 - k * 1.0
				if k >= 1:
					for r in rb:
						(r as Node3D).visible = false, 1.5)
			for j in 6:
				var at := Vector3(-4.0 + j * 1.6, 0, 0.5 + (j % 2))
				var hy := 2.0 + (j % 3) * 1.2
				st.after(1.6 + j * 0.35, func(): st.sparkle(at, 40, hy))
			for j in 4:
				st.after(1.8 + j * 0.5, func(): _firework(Vector3(-8 + j * 5.5, 13 + (j % 2) * 3, -14)))
			st.tween(0.8, func(k: float): O.light.light_energy = 2.0 + k * 0.6, 1.8)
			st.after(1.8, func(): st.ring(Vector3(0, 0, 1.2), Color("#ffd27a")))
			st.after(4.2, func(): st.glide_to(HOME))
	return true

var fan_on := false

func _firework(at: Vector3) -> void:
	var col: Color = [Color("#ff4d6d"), Color("#ffd24a"), Color("#3ad06a"), Color("#4aa3ff"), Color("#c86bff")][randi() % 5]
	for i in 120:
		var a := randf() * TAU
		var b := acos(randf_range(-1, 1))
		fx_part(at, Vector3(sin(b) * cos(a), cos(b), sin(b) * sin(a)) * randf_range(5, 7), col)

func fx_part(at: Vector3, v: Vector3, col: Color) -> void:
	st.fx.part(false, at, {"s0": 0.9, "s1": 0.6, "col": col, "add": true, "v": v, "g": 2.0, "d": 1.8})

# glue every part that never moves (road, shops, poles, wires, trees, parked cars...) into one mesh per
# material: the street went from ~620 drawing steps per frame to ~150 (18 Nov speed fix)
func merge_static() -> void:
	var skip := {}
	for k in O:
		var v = O[k]
		for o in (v if v is Array else [v]):
			if o is Node:
				skip[o] = true
	for w in walkers:
		skip[w.o] = true
	for m in movers:
		skip[m.o] = true
	var groups := {}
	var olds := []
	for c in get_children():
		if not (c is Node3D) or skip.has(c) or not (c as Node3D).visible:
			continue
		var mis := c.find_children("*", "MeshInstance3D", true, false)
		if c is MeshInstance3D:
			mis.append(c)
		if mis.is_empty() or not c.find_children("*", "Skeleton3D", true, false).is_empty():
			continue
		for mi in mis:
			var m3 := mi as MeshInstance3D
			if m3.mesh == null or not m3.is_visible_in_tree():
				continue
			for si in m3.mesh.get_surface_count():
				var mat := m3.get_active_material(si)
				if not groups.has(mat):
					groups[mat] = SurfaceTool.new()
				(groups[mat] as SurfaceTool).append_from(m3.mesh, si, m3.global_transform)
		olds.append(c)
	var am := ArrayMesh.new()
	for mat in groups:
		var stl: SurfaceTool = groups[mat]
		am = stl.commit(am)
		am.surface_set_material(am.get_surface_count() - 1, mat)
	var big := MeshInstance3D.new()
	big.name = "merged"
	big.mesh = am
	add_child(big)
	for c in olds:
		c.queue_free()

var busy_on := true
# fewer moving people and cars on slow phones (quality step 2)
func set_busy(on: bool) -> void:
	busy_on = on
	for i in walkers.size():
		(walkers[i].o as Node3D).visible = on or i == 0
	for i in movers.size():
		(movers[i].o as Node3D).visible = on or i == 0

func _process(dt: float) -> void:
	if fan_on and O.has("fan"):
		(O.fan as Node3D).rotate_y(dt * 7.0)
	for w in walkers:
		var o: Node3D = w.o
		o.position.x += w.v * dt
		if absf(o.position.x) > 40:
			o.position.x = -signf(w.v) * 40
	for m in movers:
		var o: Node3D = m.o
		o.position.x += m.v * dt
		if absf(o.position.x) > 55:
			o.position.x = -signf(m.v) * 55
