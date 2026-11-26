# dev only (not exported): run the app and save screenshots.
#   godot --path . res://tools/shot/shot.tscn -- --do="S.lv=23" --do="_title_tapped()" --at=4:/tmp/a.png --do2=... 
#   --at=SEC:PNG takes a shot; --do=EXPR runs before the title tap, --at2 steps: "--step=SEC:EXPR"
extends Node
var app
func _ready() -> void:
	app = load("res://app.tscn").instantiate()
	add_child(app)
	await get_tree().process_frame
	var steps := []
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--do="): _run(a.substr(5))
		elif a.begins_with("--step="):
			var p := a.substr(7).split(":", true, 1)
			steps.append([float(p[0]), "do", p[1]])
		elif a.begins_with("--at="):
			var p := a.substr(5).split(":", true, 1)
			steps.append([float(p[0]), "shot", p[1]])
	steps.sort_custom(func(x, y): return x[0] < y[0])
	var t := 0.0
	for s in steps:
		await get_tree().create_timer(s[0] - t).timeout
		t = s[0]
		if s[1] == "do": _run(s[2])
		else:
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png(s[2])
			print("SHOT ", s[2])
	get_tree().quit()
func _run(e: String) -> void:
	var ex := Expression.new()
	if ex.parse(e) != OK: print("SHOT parse error ", e); return
	ex.execute([], app)
	if ex.has_execute_failed(): print("SHOT exec failed ", e)
