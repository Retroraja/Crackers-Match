# dev check: build a captured web layout and save a screenshot: godot -- --ui=game --shot=/path.png
extends Control
func _ready() -> void:
	var name_ := "game"
	var shot := "user://ui.png"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ui="): name_ = a.substr(5)
		if a.begins_with("--shot="): shot = a.substr(7)
	size = Vector2(390, 844)
	var wl := WebLayout.new()
	wl.build("res://ui/%s.json" % name_, self)
	await get_tree().create_timer(0.6).timeout
	get_viewport().get_texture().get_image().save_png(shot)
	get_tree().quit()
