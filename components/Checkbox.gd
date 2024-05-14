class_name Checkbox extends Sprite2D

@onready var parent: ModCard = $"../"

func _on_button_pressed() -> void:
	var enabled:bool = bool(frame)
	frame = int(not enabled)

	var path: String = "%s/%s" % [parent.folder_path, "_polymod_meta"]
	if enabled:
		DirAccess.rename_absolute(path + ".json", path + "_disabled.json")
	else:
		DirAccess.rename_absolute(path + "_disabled.json", path + ".json")
