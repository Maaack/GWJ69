@tool
class_name HUDPanel
extends Panel

var booted : bool = false

func boot():
	if booted: return
	$BootingAnimationPlayer.play("Booting")

func instant_boot():
	if booted: return
	$BootingAnimationPlayer.play("InstantBoot")

func _ready():
	theme_changed.connect(func(): $CoverPanel.theme_type_variation = theme_type_variation)
	$CoverPanel.theme_type_variation = theme_type_variation

func _on_booting_animation_player_animation_finished(anim_name):
	booted = true
