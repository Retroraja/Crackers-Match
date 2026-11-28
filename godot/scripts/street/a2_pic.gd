# dev: the Area 2 start slides from the new street: -- --pic=2|3 --shot=png
extends Node

func _ready() -> void:
	var a := {}
	for s in OS.get_cmdline_user_args():
		if s.begins_with("--") and "=" in s:
			a[s.substr(2, s.find("=") - 2)] = s.substr(s.find("=") + 1)
	var st := Street.new()
	add_child(st)
	await get_tree().process_frame
	st.set_area(2)
	var bz: Bazaar = st.bazaar
	var n := int(a.get("pic", 2))
	var lorry := bz.put("gen/lorry", Vector3.ZERO)
	if n == 2:   # the lorry driving down Bunder Street
		lorry.position = Vector3(-9.0, 0.0, 7.6)
		st.camP = Vector3(-26.0, 4.0, 19.0)
		st.camL = Vector3(-6.0, 3.6, 3.0)
	else:        # parked at our rusty shop
		lorry.position = Vector3(-5.6, 0.0, 5.4)
		st.camP = Vector3(6.0, 2.8, 21.0)
		st.camL = Vector3(-1.2, 3.4, 1.5)
	st.CAMID += 1
	st.cam.fov = 38
	await get_tree().create_timer(float(a.get("wait", 1.5))).timeout
	get_viewport().get_texture().get_image().save_png(a.get("shot", "/tmp/pic.png"))
	get_tree().quit()
