class_name ModCard extends Panel

@onready var icon: TextureRect = $Icon
@onready var title: Label = $Title
@onready var desc: Label = $Description
@onready var checkbox: Checkbox = $Checkbox

var folder_path: String = ""
var meta_path: String = ""
