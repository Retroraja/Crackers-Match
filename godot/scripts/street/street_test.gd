# dev view of the street: -- --st=home|wide|done|build --step=N --wait=S --shot=png
extends Node

func _ready() -> void:
	var a := {}
	for s in OS.get_cmdline_user_args():
		if s.begins_with("--") and "=" in s:
			a[s.substr(2, s.find("=") - 2)] = s.substr(s.find("=") + 1)
	var cl := CanvasLayer.new()
	cl.layer = -10
	add_child(cl)
	var sky := TextureRect.new()
	sky.texture = load("res://street/art/sky.png")
	sky.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sky.stretch_mode = TextureRect.STRETCH_SCALE
	sky.set_anchors_preset(Control.PRESET_FULL_RECT)
	cl.add_child(sky)
	var st := Street.new()
	add_child(st)
	await get_tree().process_frame
	if a.has("sun"):
		st.sun.light_energy = float(a.sun)
	if a.has("amb"):
		st.env.ambient_light_energy = float(a.amb)
	if a.has("wh"):
		st.env.tonemap_white = float(a.wh)
	if a.has("ex"):
		st.expo = float(a.ex)
	if a.has("ac"):
		st.env.ambient_light_color = Color(a.ac)
	if a.has("sc"):
		st.sun.light_color = Color(a.sc)
	if a.has("tm"):
		st.env.tonemap_mode = int(a.tm)
	st.diyas = 20
	var n := int(a.get("step", 0))
	if n > 0:
		st.skip_to(n)
	var mode: String = a.get("st", "home")
	if mode == "wide":
		var w := st.wide()
		st.camP = w.p
		st.camL = w.look
	elif mode == "build":
		st.cam_home(true)
		st.do_task(false)
	else:
		st.cam_home(true)
	if a.has("shot"):
		await get_tree().create_timer(float(a.get("wait", 1.0))).timeout
		get_viewport().get_texture().get_image().save_png(a.shot)
		get_tree().quit()
