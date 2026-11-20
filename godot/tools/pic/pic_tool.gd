# dev (20 Nov): renders the street pictures for picture-based areas from our 3D, at full quality with shadows.
# -- --area=1 --step=N --p=x,y,z --l=x,y,z --fov=52 --w=1080 --h=2338 --shot=/tmp/x.png   (one view)
# -- --area=1 --steps=0,1,2,3 --p=... --l=... --out=/tmp/dir   (one picture at several build steps: s0.png s1.png ...)
extends Node

func V3(s: String) -> Vector3:
	var a := s.split(",")
	return Vector3(float(a[0]), float(a[1]), float(a[2]))

func _ready() -> void:
	var a := {}
	for s in OS.get_cmdline_user_args():
		if s.begins_with("--") and "=" in s:
			a[s.substr(2, s.find("=") - 2)] = s.substr(s.find("=") + 1)
	RenderingServer.directional_shadow_atlas_set_size(8192, true)
	var sv := SubViewport.new()
	sv.size = Vector2i(int(a.get("w", 1080)), int(a.get("h", 2338)))
	sv.transparent_bg = true
	sv.msaa_3d = Viewport.MSAA_4X if a.has("msaa") else Viewport.MSAA_DISABLED
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(sv)
	var st := Street.new()
	st.sv = sv
	sv.add_child(st)
	await get_tree().process_frame
	var area := int(a.get("area", 1))
	if area == 2:
		st.set_area(2)
	st.sun.shadow_enabled = true
	st.sun.directional_shadow_max_distance = float(a.get("shd", 90))
	var steps: Array = []
	if a.has("steps"):
		for x in String(a.steps).split(","):
			steps.append(int(x))
	else:
		steps.append(int(a.get("step", 0)))
	for n in steps:
		st.process_mode = Node.PROCESS_MODE_INHERIT
		st.skip_to(n)
		st.SHOW = false
		st.EM.clear()
		st.fx.clear()
		st.process_mode = Node.PROCESS_MODE_DISABLED
		if a.has("night"):
			st.night(float(a.night))
		st.cam.fov = float(a.get("fov", 52))
		st.cam.position = V3(a.p)
		st.cam.look_at(V3(a.l), Vector3.UP)
		for i in 4:
			await get_tree().process_frame
		for T in st.TASKS:
			var q := st.cam.unproject_position(Vector3(T.site[0], T.site[1], T.site[2]))
			print("PIC site %s  y=%.2f x=%.2f" % [T.n, q.y / sv.size.y, q.x / sv.size.x])
		if a.has("noshot"):
			continue
		await RenderingServer.frame_post_draw
		var img := sv.get_texture().get_image()
		var path: String = a.get("shot", "/tmp/pic.png") if not a.has("out") else "%s/s%d.png" % [a.out, n]
		img.save_png(path)
		print("PIC saved ", path)
	get_tree().quit()
