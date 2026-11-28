@tool
extends EditorPlugin

var exp: CMAdsExport

func _enter_tree() -> void:
	exp = CMAdsExport.new()
	add_export_plugin(exp)

func _exit_tree() -> void:
	remove_export_plugin(exp)
	exp = null

class CMAdsExport extends EditorExportPlugin:
	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_android_libraries(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		return PackedStringArray(["cmads/bin/cmads-release.aar"])

	func _get_android_dependencies(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		return PackedStringArray(["com.google.android.gms:play-services-ads:23.6.0"])

	func _get_name() -> String:
		return "CMAds"
