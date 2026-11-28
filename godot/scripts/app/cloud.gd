# 27 Nov: Google Play Games sign-in + cloud save (plugin addons/GodotPlayGameServices, app id 37177410253).
# Guest first: progress is always saved on the phone. The cloud is used only after the player taps
# "Sign in with Google Play" on the Profile page (S.cloud = 1). Then the whole save goes to the player's
# Google account after each won level. On a new phone: sign in -> "Load your saved progress?" if the cloud
# save is further along (higher level wins). Everything is guarded: no plugin (PC, or a failure) = nothing happens.
extends Node
class_name Cloud

const FILE := "crackers_match_save"
var app
var ok := false            # the Android plugin is there
var signed := false        # the player is signed in right now
var name_txt := ""
var sign_in_c: Node
var snap_c: Node
var players_c: Node
var _asked := false        # the sign-in tap came from the button (so we may offer to load)
var _push_wait := false

func start(a) -> void:
	app = a
	if not has_node("/root/GodotPlayGameServices"):
		return
	var g = get_node("/root/GodotPlayGameServices")
	if g.initialize() != 0:
		return
	ok = true
	sign_in_c = PlayGamesSignInClient.new()
	snap_c = PlayGamesSnapshotsClient.new()
	players_c = PlayGamesPlayersClient.new()
	add_child(sign_in_c)
	add_child(snap_c)
	add_child(players_c)
	sign_in_c.user_authenticated.connect(_on_auth)
	snap_c.game_loaded.connect(_on_loaded)
	snap_c.game_saved.connect(func(saved: bool, _n: String, _d: String):
		_push_wait = false
		if not saved:
			print("Cloud: save failed"))
	snap_c.conflict_emitted.connect(func(_c): _push_wait = false)
	players_c.current_player_loaded.connect(func(p):
		if p != null and str(p.display_name) != "":
			name_txt = str(p.display_name)
			app.S.name = name_txt
			app.save()
			app.home_ui.menu.refresh_profile())
	# signed in before (he tapped the button once): check quietly; the plugin's sign-in state comes back by signal
	if int(app.S.get("cloud", 0)) == 1:
		sign_in_c.is_authenticated()

# the Profile button
func sign_in() -> void:
	if not ok:
		app.home_ui.show_toast("Google Play sign-in works only on the phone")
		return
	_asked = true
	sign_in_c.sign_in()

func _on_auth(yes: bool) -> void:
	signed = yes
	if not yes:
		if _asked:
			app.home_ui.show_toast("Sign-in did not work. Try again.")
		_asked = false
		app.home_ui.menu.refresh_profile()
		return
	var first := int(app.S.get("cloud", 0)) != 1
	app.S.cloud = 1
	app.save()
	players_c.load_current_player(false)
	app.home_ui.menu.refresh_profile()
	if _asked or first:
		app.home_ui.show_toast("Signed in. Progress saves to the cloud.")
	_asked = false
	# compare with the cloud copy (load does nothing if there is none yet)
	snap_c.load_game(FILE, false)

func _on_loaded(snap) -> void:
	if snap == null or snap.content.is_empty():
		push()
		return
	var j = JSON.parse_string(snap.content.get_string_from_utf8())
	if not (j is Dictionary):
		push()
		return
	var cl := int(j.get("lv", 0))
	var me := int(app.S.get("lv", 0))
	if cl > me:
		app.ask("Load your saved progress?", "Your Google account has Level %d. This phone has Level %d." % [cl + 1, me + 1], "Keep this phone", "Load Level %d" % (cl + 1), func():
			_use(j), func():
			push())
	else:
		push()

func _use(j: Dictionary) -> void:
	for k in j:
		app.S[k] = j[k]
	app.S.cloud = 1
	app.save()
	app.load_save()
	app.home_ui.show_toast("Progress loaded!")
	app.home()

# send the whole save to the cloud (after a won level, after sign-in)
func push() -> void:
	if not ok or not signed or _push_wait:
		return
	_push_wait = true
	var data := JSON.stringify(app.S).to_utf8_buffer()
	snap_c.save_game(FILE, "Level %d" % (int(app.S.get("lv", 0)) + 1), data, 0, int(app.S.get("lv", 0)))
