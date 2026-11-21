# dev (21 Nov): renders the Area 3 back store room (scripts/street/backroom.gd) at full quality with shadows.
# -- --p=x,y,z --l=x,y,z --fov=50 --w=1080 --h=2338 --shot=/tmp/x.png
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
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(sv)
	var we := WorldEnvironment.new()
	we.environment = Environment.new()
	sv.add_child(we)
	var sun := DirectionalLight3D.new()
	sv.add_child(sun)
	var room := Backroom.new()
	sv.add_child(room)
	room.front = a.has("front")
	room.ceiling = a.has("ceil")
	room.light(we.environment, sun)
	room.build()
	var cam := Camera3D.new()
	sv.add_child(cam)
	cam.fov = float(a.get("fov", 50))
	cam.position = V3(a.get("p", "0,4.6,6.0"))
	cam.look_at(V3(a.get("l", "0,0.8,-3.6")), Vector3.UP)
	cam.current = true
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	sv.get_texture().get_image().save_png(a.get("shot", "/tmp/a3.png"))
	print("PIC saved ", a.get("shot", "/tmp/a3.png"))
	get_tree().quit()
