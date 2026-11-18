# Start of Area 2 (18 Nov, v3): a picture slideshow like the approved preview (area2-story-slides-v3.mp4).
# Three pictures rendered from the game's own scenes (art/story2): the loaded truck at our Crackers Factory,
# the truck on Bunder Street, the truck at our rusty shop. Each zooms in slowly with its caption; fades between.
# Then the "AREA 2 · Bunder Street, Chennai" title card, then the shop home.
extends AreaEndScene
class_name AreaStartScene

var pic: TextureRect
const CAPS := ["The first load of crackers\nis ready for Chennai!", "Chennai.  Bunder Street,\nwhere the big city buys its crackers.", "“Our first shop…\na little rusty, but it's ours.”"]

func play(height: float) -> void:
	# the picture must exist before super.play() starts shot 1
	pic = TextureRect.new()
	pic.position = Vector2.ZERO
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pic.size = Vector2(390, height)
	add_child(pic)
	move_child(pic, 0)
	super.play(height)
	(card.get_node("a") as Label).text = "A R E A   2"
	(card.get_node("t") as Label).text = "Bunder Street, Chennai"
	(card.get_node("u") as Label).text = "our first shop in the big city"
	grade.visible = false
	# a happy moment: the cheerful game music instead of the story theme, no wind
	amb.stop()
	music.stream = _stream("music")
	music.play()

func _shot(n: int) -> void:
	shot = n
	sid += 1
	var id := sid
	match n:
		1, 2, 3: _slide(id, n)
		4: _title(id)
		_: _finish()

func _slide(id: int, n: int) -> void:
	grade.color.a = 0.0
	_tw().tween_property(cap, "modulate:a", 0.0, 0.2)
	var t := _tw()
	if n > 1:
		t.tween_property(dim, "color:a", 1.0, 0.3)
	t.tween_callback(func():
		if id != sid:
			return
		pic.texture = load("res://art/story2/s%d.jpg" % n)
		pic.size = Vector2(390, H)
		pic.position = Vector2.ZERO
		pic.pivot_offset = pic.size / 2.0
		pic.scale = Vector2.ONE
		create_tween().tween_property(pic, "scale", Vector2.ONE * 1.06, 4.2).set_trans(Tween.TRANS_SINE))
	t.tween_property(dim, "color:a", 0.0, 0.45)
	_later(0.6, id, func(): say(CAPS[n - 1], id, 3.0))
	_later(4.0, id, func(): _shot(n + 1))

func _title(id: int) -> void:
	_tw().tween_property(pic, "modulate", Color(0.45, 0.42, 0.5), 0.6)
	super._title(id)

func _process(_dt: float) -> void:
	pass

func _cleanup() -> void:
	if street:
		street.cam_home(true)
