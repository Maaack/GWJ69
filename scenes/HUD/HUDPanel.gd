@tool
class_name HUDPanel
extends Panel


func boot():
	$AnimationPlayer.play("Booting")

func _ready():
	theme_changed.connect(func(): $CoverPanel.theme_type_variation = theme_type_variation)
	$CoverPanel.theme_type_variation = theme_type_variation
