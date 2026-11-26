# 26 Nov: 3D bottom-menu icons (map with pin, prize wheel), rendered once to pictures.
# godot --path . res://tools/pic/nav3d.tscn -- --icon=map|wheel --shot=out.png
extends Node3D
func _ready() -> void:
	var a := {}
	for s in OS.get_cmdline_user_args():
		if s.begins_with("--") and s.contains("="):
			var kv := s.substr(2).split("=", true, 1)
			a[kv[0]] = kv[1]
	get_viewport().transparent_bg = true
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0, 0, 0, 0)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(1, 1, 1)
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -35, 0)
	sun.light_energy = 1.4
	add_child(sun)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-20, 140, 0)
	fill.light_energy = 0.5
	add_child(fill)
	var cam := Camera3D.new()
	cam.fov = 30
	add_child(cam)
	var kind: String = a.get("icon", "map")
	if kind == "map":
		add_child(_map())
		cam.position = Vector3(0, 5.6, 6.8)
		cam.look_at(Vector3(0, 0.15, 0))
	else:
		add_child(_wheel())
		cam.position = Vector3(0, 0.4, 10.0)
		cam.look_at(Vector3(0, 0.0, 0))
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png(a.get("shot", "/tmp/out.png"))
	get_tree().quit()

func _mat(c: Color, rough := 0.55, metal := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	m.metallic = metal
	return m

func _map() -> Node3D:
	var n := Node3D.new()
	# 3 folded panels (zig-zag), parchment with coloured land, a dotted route
	var cols := [Color(0.96, 0.84, 0.58), Color(0.86, 0.73, 0.48), Color(0.96, 0.84, 0.58)]
	for i in 3:
		var p := MeshInstance3D.new()
		var b := BoxMesh.new()
		b.size = Vector3(0.62, 0.03, 1.3)
		p.mesh = b
		p.material_override = _mat(cols[i])
		p.position = Vector3(-0.62 + i * 0.6, 0.06 if i == 1 else 0.0, 0)
		p.rotation_degrees.z = -8.0 if i == 0 else (8.0 if i == 2 else 0.0)
		n.add_child(p)
		# green land and blue water patches
		for k in 2:
			var q := MeshInstance3D.new()
			var c := CylinderMesh.new()
			c.top_radius = 0.16 + 0.05 * k
			c.bottom_radius = c.top_radius
			c.height = 0.01
			q.mesh = c
			q.material_override = _mat(Color(0.3, 0.68, 0.28) if (i + k) % 2 == 0 else Color(0.2, 0.55, 0.9))
			q.position = p.position + Vector3(0.05 - 0.1 * k, 0.02, -0.3 + 0.55 * k)
			q.rotation_degrees.z = p.rotation_degrees.z
			n.add_child(q)
	# dotted red route
	for k in 7:
		var d := MeshInstance3D.new()
		var s := SphereMesh.new()
		s.radius = 0.028
		s.height = 0.056
		d.mesh = s
		d.material_override = _mat(Color(0.85, 0.1, 0.1))
		var t := k / 6.0
		d.position = Vector3(-0.75 + 1.3 * t, 0.07 + 0.04 * sin(t * PI), 0.35 - 0.6 * t + 0.15 * sin(t * 6.0))
		n.add_child(d)
	# red pin
	var pin := Node3D.new()
	pin.position = Vector3(0.5, 0.02, -0.25)
	n.add_child(pin)
	var cone := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.11
	cm.bottom_radius = 0.0
	cm.height = 0.36
	cone.mesh = cm
	cone.position.y = 0.2
	cone.material_override = _mat(Color(0.88, 0.08, 0.12), 0.3)
	pin.add_child(cone)
	var head := MeshInstance3D.new()
	var hs := SphereMesh.new()
	hs.radius = 0.2
	hs.height = 0.4
	head.mesh = hs
	head.position.y = 0.48
	head.material_override = _mat(Color(0.92, 0.1, 0.14), 0.25)
	pin.add_child(head)
	var dot := MeshInstance3D.new()
	var ds := SphereMesh.new()
	ds.radius = 0.075
	ds.height = 0.15
	dot.mesh = ds
	dot.position = Vector3(0, 0.5, 0.16)
	dot.material_override = _mat(Color(1, 1, 1), 0.3)
	pin.add_child(dot)
	n.rotation_degrees.y = -12
	return n

func _wheel() -> Node3D:
	var n := Node3D.new()
	var cols := [Color(0.92, 0.12, 0.2), Color(1.0, 0.78, 0.15), Color(0.15, 0.55, 0.95), Color(0.2, 0.75, 0.35), Color(0.95, 0.45, 0.1), Color(0.6, 0.25, 0.85), Color(1.0, 0.85, 0.2), Color(0.1, 0.7, 0.75)]
	var SEG := 8
	var r := 0.9
	for i in SEG:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var a0 := i * TAU / SEG
		var a1 := (i + 1) * TAU / SEG
		var steps := 10
		for k in steps:
			var b0 := lerpf(a0, a1, float(k) / steps)
			var b1 := lerpf(a0, a1, float(k + 1) / steps)
			st.set_normal(Vector3(0, 0, 1))
			st.add_vertex(Vector3(0, 0, 0.06))
			st.add_vertex(Vector3(cos(b1) * r, sin(b1) * r, 0.06))
			st.add_vertex(Vector3(cos(b0) * r, sin(b0) * r, 0.06))
		var mi := MeshInstance3D.new()
		mi.mesh = st.commit()
		mi.material_override = _mat(cols[i], 0.4)
		n.add_child(mi)
	var back := MeshInstance3D.new()
	var bc := CylinderMesh.new()
	bc.top_radius = r
	bc.bottom_radius = r
	bc.height = 0.1
	back.mesh = bc
	back.rotation_degrees.x = 90
	back.material_override = _mat(Color(0.95, 0.95, 0.95))
	n.add_child(back)
	var gold := _mat(Color(1.0, 0.72, 0.15), 0.3, 0.0)
	gold.metallic_specular = 0.9
	var rim := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = r - 0.02
	tm.outer_radius = r + 0.13
	tm.rings = 64
	rim.mesh = tm
	rim.rotation_degrees.x = 90
	rim.material_override = gold
	n.add_child(rim)
	for i in SEG:
		var bulb := MeshInstance3D.new()
		var s := SphereMesh.new()
		s.radius = 0.045
		s.height = 0.09
		bulb.mesh = s
		var a := (i + 0.5) * TAU / SEG
		bulb.position = Vector3(cos(a) * (r + 0.055), sin(a) * (r + 0.055), 0.08)
		var bm := _mat(Color(1, 1, 0.85), 0.2)
		bm.emission_enabled = true
		bm.emission = Color(1, 0.95, 0.7)
		bm.emission_energy_multiplier = 0.6
		bulb.material_override = bm
		n.add_child(bulb)
	var hub := MeshInstance3D.new()
	var hc := CylinderMesh.new()
	hc.top_radius = 0.17
	hc.bottom_radius = 0.2
	hc.height = 0.16
	hub.mesh = hc
	hub.rotation_degrees.x = 90
	hub.position.z = 0.1
	hub.material_override = gold
	n.add_child(hub)
	# pointer at the top
	var ptr := MeshInstance3D.new()
	var pc := CylinderMesh.new()
	pc.top_radius = 0.0
	pc.bottom_radius = 0.13
	pc.height = 0.28
	pc.radial_segments = 3
	ptr.mesh = pc
	ptr.rotation_degrees.z = 180
	ptr.position = Vector3(0, r + 0.12, 0.15)
	ptr.material_override = _mat(Color(0.9, 0.1, 0.12), 0.3)
	n.add_child(ptr)
	n.rotation_degrees = Vector3(-6, 18, 4)
	return n
