extends SceneTree


func _initialize() -> void:
	var java_sdk_path := OS.get_environment("JAVA_HOME")
	var android_sdk_path := OS.get_environment("ANDROID_HOME")
	if java_sdk_path.is_empty() or android_sdk_path.is_empty():
		push_error("JAVA_HOME a ANDROID_HOME musí být nastavené.")
		quit(1)
		return

	var settings := EditorInterface.get_editor_settings()
	settings.set_setting("export/android/java_sdk_path", java_sdk_path)
	settings.set_setting("export/android/android_sdk_path", android_sdk_path)

	# EditorSettings se ukládají odloženě. Krátké čekání zajistí, že další
	# headless proces exporteru už načte právě ověřené cesty.
	await create_timer(2.0).timeout
	quit()
