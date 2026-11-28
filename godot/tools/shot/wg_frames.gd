# dev only: renders the win-screen man frame by frame at a fixed 1/30 s step (smooth, whatever the computer speed)
extends Node
func _ready() -> void:
	var bg := ColorRect.new(); bg.color = Color("#5a1e7a"); bg.size = Vector2(390, 600); add_child(bg)
	var g = load("res://scripts/app/winguy.gd").new()
	g.size = Vector2(390, 600); add_child(g); g.set_process(false)
	await get_tree().process_frame
	for i in 75:
		g._dt = 1.0 / 30.0; g.t += g._dt; g.queue_redraw()
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("/tmp/wgA/f%03d.png" % i)
	get_tree().quit()
