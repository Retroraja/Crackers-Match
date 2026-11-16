# Sound: a small pool of players. Normal match = his recorded blast, option 5 "Mixed".
extends Node
class_name Sfx

const NAMES := ["blastnew", "rocket", "chakra", "atom", "matchbox", "sparkler", "blast", "swap", "nope", "pop", "tick",
	"thud", "swoosh", "win", "lose", "fanfare", "finale", "paper", "music", "lakshmi", "wala", "rail", "flowerpot", "skyshot", "brand",
	"chime0", "chime1", "chime2", "coin0", "coin1", "coin2", "coin3", "coin4", "coin5", "coin6", "coin7", "coin8"]
var mus_on := true
var fx_on := true
var _duck := 0.3
var streams := {}
var pool: Array[AudioStreamPlayer] = []
var music: AudioStreamPlayer
var rr := 0
var last_match := -9.0
var last_extra := -9.0
const VARS := [[0.28, 1.0], [0.24, 1.06], [0.32, 0.95], [0.26, 1.03]]

func _ready() -> void:
	for n in NAMES:
		for ext in ["mp3", "ogg", "wav"]:
			var p := "res://sfx/%s.%s" % [n, ext]
			if ResourceLoader.exists(p):
				streams[n] = load(p)
	for i in 16:
		var a := AudioStreamPlayer.new()
		add_child(a)
		pool.append(a)
	music = AudioStreamPlayer.new()
	add_child(music)
	if streams.has("music"):
		var m: AudioStream = streams["music"].duplicate()
		m.set("loop", true)
		music.stream = m
		music.volume_db = linear_to_db(0.3)
		music.play()
	var cf := ConfigFile.new()
	if cf.load("user://sound.cfg") == OK:
		mus_on = cf.get_value("s", "mus", true)
		fx_on = cf.get_value("s", "fx", true)
	_apply_mus()

# play every sound once, silently, so the first real one starts on time
func warm() -> void:
	for n in streams:
		if n == "music":
			continue
		var a := _player()
		a.stream = streams[n]
		a.volume_db = -80.0
		a.play()
		a.stop()

func _player() -> AudioStreamPlayer:
	for a in pool:
		if not a.playing:
			return a
	return pool[0]

# name, volume 0..1, pitch, delay seconds, cut length seconds (0 = full)
func play(n: String, v: float = 1.0, pitch: float = 1.0, delay: float = 0.0, cut: float = 0.0, off: float = 0.0) -> void:
	if not streams.has(n) or not fx_on:
		return
	if delay > 0.0:
		get_tree().create_timer(delay).timeout.connect(play.bind(n, v, pitch, 0.0, cut, off))
		return
	var a := _player()
	a.stream = streams[n]
	a.pitch_scale = clampf(pitch, 0.3, 3.0)
	a.volume_db = linear_to_db(clampf(v, 0.01, 1.5))
	a.play(off)
	if cut > 0.0:
		var tw := create_tween()
		tw.tween_interval(maxf(cut - 0.12, 0.02))
		tw.tween_property(a, "volume_db", -60.0, 0.12)
		tw.tween_callback(a.stop)

# normal match: next of 4 short variations, a semitone higher per cascade step, sparkle from step 5
func match_sound(cascade: int, big: bool) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if absf(now - last_match) < 0.045:
		if absf(now - last_extra) > 0.045:
			last_extra = now
			play("blastnew", 0.25, 0.8, 0.01, 0.25)
		return
	last_match = now
	var vv: Array = VARS[rr % 4]
	rr += 1
	var st := pow(2.0, mini(cascade, 8) / 12.0)
	play("blastnew", (0.85 if big else 0.65) * randf_range(0.92, 1.08), vv[1] * st * (0.9 if big else 1.0) * randf_range(0.985, 1.015), 0.0, vv[0] + (0.08 if big else 0.0))
	if cascade >= 4:
		for i in 3:
			play("pop", 0.35, 1.6 + i * 0.25, 0.08 + i * 0.055, 0.2)

# sound.js extras
func chime(i: int) -> void:
	play("chime%d" % (i % 3))

func coin(n: int) -> void:
	play("coin%d" % clampi(n, 0, 8))

func duck(v: float) -> void:
	_duck = v
	if music and mus_on:
		var tw := create_tween()
		tw.tween_property(music, "volume_db", linear_to_db(maxf(v, 0.001)), 0.3)

func _apply_mus() -> void:
	if music:
		music.volume_db = linear_to_db(maxf(_duck, 0.001)) if mus_on else -80.0

func set_mus(b: bool) -> void:
	mus_on = b
	_apply_mus()
	_save()

func set_fx(b: bool) -> void:
	fx_on = b
	_save()

func _save() -> void:
	var cf := ConfigFile.new()
	cf.set_value("s", "mus", mus_on)
	cf.set_value("s", "fx", fx_on)
	cf.save("user://sound.cfg")
