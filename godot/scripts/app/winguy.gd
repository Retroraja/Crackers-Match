# man28.js WinGuy: the suit man from his Viggle clip (24 frames, 6 columns), rises in, plays, holds, plays back.
extends Control
class_name CMWinGuy

const CW := 456.0
const CH := 544.0
const COLS := 6
const NF := 24
const FPS := 30.0
const MX := 5.0
const MY := 256.0
const SC := 0.66
const START := 0.55
const D := NF / FPS
const OUT := 0.7
const BACK := D * 1.4
var SHEET: Texture2D = preload("res://art/web/man-video.webp")
var t := 0.0
var ox := 0.0   # this control's page position (the clip is placed in page coordinates)
var oy := 0.0

func _process(dt: float) -> void:
	t += minf(dt, 0.04)
	queue_redraw()

func _draw() -> void:
	var u := t - START
	var f := 0
	if u > 0:
		if u < D: f = int(floor(u * FPS))
		elif u < D + OUT: f = NF - 1
		elif u < D + OUT + BACK: f = NF - 1 - int(floor((u - D - OUT) / BACK * NF))
		else: f = 0
	f = clampi(f, 0, NF - 1)
	var p := minf(t / 0.5, 1.0)
	var e := 1 + 2.2 * pow(p - 1, 3) + 1.2 * pow(p - 1, 2)
	var sc := 0.8 + 0.2 * e
	var bob := sin((u - D - OUT - BACK) * 2.2) * 1.2 if u > D + OUT + BACK else 0.0
	var px := 212.0
	var py := 594.0
	var tr := Transform2D(0, Vector2(-ox, -oy)) * Transform2D(0, Vector2(px, py + 70 * (1 - e))) * Transform2D(0, Vector2(sc, sc), 0, Vector2.ZERO) * Transform2D(0, Vector2(-px, -py))
	draw_set_transform_matrix(tr)
	draw_texture_rect_region(SHEET, Rect2(MX, MY + bob, CW * SC, CH * SC), Rect2((f % COLS) * CW, int(f / COLS) * CH, CW, CH), Color(1, 1, 1, minf(1.0, p * 1.6)))
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
