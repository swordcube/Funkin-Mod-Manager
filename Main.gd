class_name Main extends Control

# [ Public API ]
const GAME_PATH_FILE: String = "user://game_path.txt"

@onready var select_game_folder: FileDialog = $SelectGameFolder
@onready var mod_list: VBoxContainer = $ModListArea/ModList
@onready var mod_template: ModCard = $ModListArea/ModList/Template

var game_folder: String = ""

# [ Private API ]
func _ready() -> void:
	if not FileAccess.file_exists(GAME_PATH_FILE):
		print("this bitch has no game path!")
		await get_tree().create_timer(0.5).timeout
		select_game_folder.popup_centered()
	else:
		print("this bitch has a game path!")
		_update_game_folder()
		_reload_mods()

func _update_game_folder() -> void:
	game_folder = FileAccess.open(GAME_PATH_FILE, FileAccess.READ).get_as_text().strip_edges()
	print("game folder is %s" % game_folder)

func _reload_mods() -> void:
	var mods_folder:String = "%s/%s" % [game_folder, "mods"]
	if not DirAccess.dir_exists_absolute(mods_folder):
		DirAccess.make_dir_recursive_absolute(mods_folder)
	
	for dir in DirAccess.open(mods_folder).get_directories():
		var meta_jsons:PackedStringArray = [
			"%s/%s/%s" % [mods_folder, dir, "_polymod_meta.json"],
			"%s/%s/%s" % [mods_folder, dir, "_polymod_meta_disabled.json"]
		]
		for json_path in meta_jsons:
			if not FileAccess.file_exists(json_path):
				continue
			
			var json: Dictionary = load(json_path).data
			var card: ModCard = mod_template.duplicate()
			card.visible = true
			card.folder_path = "%s/%s" % [mods_folder, dir]
			card.meta_path = json_path
			mod_list.add_child(card)
			
			card.title.text = json.title
			card.desc.text = json.description
			
			var icon_path: String = "%s/%s/%s" % [mods_folder, dir, "_polymod_icon.png"]
			if FileAccess.file_exists(icon_path):
				card.icon.texture = ImageTexture.create_from_image(Image.load_from_file(icon_path))
			
			card.checkbox.frame = int(not json_path.ends_with("_disabled.json"))

func _on_select_game_folder_canceled() -> void:
	await get_tree().create_timer(0.5).timeout
	select_game_folder.show() # bitch no!

func _on_select_game_folder_dir_selected(dir: String) -> void:
	game_folder = dir
	FileAccess.open(GAME_PATH_FILE, FileAccess.WRITE).store_string(dir)
	print("game folder set to %s" % game_folder)
	_reload_mods()

func _on_play_game_pressed() -> void:
	var drive: String = game_folder.replace("\\", "/").split("/")[0]
	var bat_file: String = "%s/%s" % [OS.get_executable_path().get_base_dir(), "RunFunkin.bat"]
	
	if FileAccess.file_exists(bat_file):
		OS.create_process(bat_file, [drive, game_folder])
	else:
		OS.create_process(ProjectSettings.globalize_path("res://run.bat"), [drive, game_folder])
	
	get_tree().quit()
