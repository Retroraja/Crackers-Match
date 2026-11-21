# Start of Area 2 (18 Nov, v3): a picture slideshow like the approved preview (area2-story-slides-v3.mp4).
# Three pictures rendered from the game's own scenes (art/story2): the loaded truck at our Crackers Factory,
# the truck on Bunder Street, the truck at our rusty shop. Each zooms in slowly with its caption; fades between.
# Then the "AREA 2 · Bunder Street, Chennai" title card, then the shop home.
# Start of Area 3 (21 Nov, start_area = 3): picks up from the Area 2 end ("NEXT · Busy Days at GHILLI"):
#   1 Grandpa's notebook: steps 1-2 ticked, step 3 "Light up more towns" lights up in gold
#   2 the man opens the door from the shop into the dusty back store room (art/story3/s2, from scripts/street/backroom.gd)
#   3 inside the mess, the man pops up: "First, get GHILLI ready!"   then "AREA 3 · Busy Days at GHILLI"
extends AreaEndScene
class_name AreaStartScene

var pic: TextureRect
var start_area := 2
const CAPS3 := ["“Thatha, your next step…\nlight up more towns.”", "Orders need space…\ntime to open the back room!", "“First, get GHILLI ready!”"]
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
	area = start_area - 1   # the notebook: steps before this area show their tick
	super.play(height)
	(card.get_node("a") as Label).text = "A R E A   %d" % start_area
	(card.get_node("t") as Label).text = "Bunder Street, Chennai" if start_area == 2 else "Busy Days at GHILLI"
	(card.get_node("u") as Label).text = "our first shop in the big city" if start_area == 2 else "the first steps to more towns"
	grade.visible = false
	# a happy moment: the cheerful game music instead of the story theme, no wind
	amb.stop()
	music.stream = _stream("music")
	music.play()

func _shot(n: int) -> void:
	shot = n
	sid += 1
	var id := sid
	if start_area == 3 and n == 1:
		_book_slide(id)
		return
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
		pic.texture = load("res://art/story%d/s%d.jpg" % [start_area, n])
		pic.size = Vector2(390, H)
		pic.position = Vector2.ZERO
		pic.pivot_offset = pic.size / 2.0
		pic.scale = Vector2.ONE
		create_tween().tween_property(pic, "scale", Vector2.ONE * 1.06, 4.2).set_trans(Tween.TRANS_SINE))
	t.tween_property(dim, "color:a", 0.0, 0.45)
	var caps: Array = CAPS if start_area == 2 else CAPS3
	_later(0.6, id, func(): say(caps[n - 1], id, 3.0))
	if start_area == 3 and n == 2:
		_sfx("story_page", 0.5, 0.6, 0.3)   # the old door creaks open
	if start_area == 3 and n == 3:
		# the man pops up from the bottom, rolls up his sleeves (cheer), then the title
		man.base = "idle"
		man.mood("smile", 99)
		man.position.x = 2
		_tw().tween_property(man, "position:y", H - BOT - 236, 0.9).set_delay(0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_later(1.3, id, func(): man.mood("cheer", 1.2))
		_later(4.6, id, func(): _shot(n + 1))
		return
	_later(4.0, id, func(): _shot(n + 1))

# Area 3, slide 1: Grandpa's notebook on a dark page, steps 1 and 2 ticked, step 3 gets its gold line and sparkles
func _book_slide(id: int) -> void:
	pic.texture = null
	# the notebook over the dimmed shop (straight on from the Area 2 end)
	_tw().tween_property(dim, "color:a", 0.62, 0.8)
	book.reset()
	book.end_mode = true
	book.tick_i = 1
	book.tick = 1.0
	book.visible = true
	book.scale = Vector2.ONE * 0.35
	book.rotation = -0.5
	book.modulate.a = 0.0
	var b := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	b.tween_property(book, "scale", Vector2.ONE, 0.75).set_delay(0.2)
	b.parallel().tween_property(book, "rotation", 0.0, 0.75).set_delay(0.2)
	b.parallel().tween_property(book, "modulate:a", 1.0, 0.4).set_delay(0.2)
	_sfx("swoosh", 0.35, 0.7, 0.2)
	_later(1.0, id, func():
		_sfx("story_page", 1.0)
		_tw().tween_property(book, "open", 1.0, 0.75).set_trans(Tween.TRANS_CUBIC))
	_later(2.1, id, func():
		book.anim("next_hi", 1.0, 0.9)
		_sfx("story_ting", 0.6))
	_later(2.6, id, func():
		_sfx("story_chime", 0.9)
		motes.burst(Vector2(book.position.x + 245, book.position.y + 120 + 84), 34))
	_later(1.4, id, func(): say(CAPS3[0], id, 3.4))
	_later(5.4, id, func():
		var t := _tw()
		t.tween_property(book, "open", 0.0, 0.4)
		t.tween_property(book, "modulate:a", 0.0, 0.3)
		t.tween_callback(func(): book.visible = false)
		_later(0.7, id, func(): _shot(2)))

func _title(id: int) -> void:
	_tw().tween_property(pic, "modulate", Color(0.45, 0.42, 0.5), 0.6)
	super._title(id)

func _process(_dt: float) -> void:
	pass

func _cleanup() -> void:
	if street:
		street.cam_home(true)
