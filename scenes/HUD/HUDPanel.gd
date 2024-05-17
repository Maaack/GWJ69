@tool
class_name HUDPanel
extends Panel

signal system_failed

enum States{
	SAFE,
	WARNING,
	DANGER
}

@export var state : States :
	set(value):
		state = value
		_update_panel()
@export var warning_color : Color
@export var danger_color : Color

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

func _on_booting_animation_player_animation_finished(anim_name : StringName):
	if anim_name.find("Boot") != -1:
		booted = true

func _update_panel():
	match(state):
		States.SAFE:
			self_modulate = Color.WHITE
			if not $DangerTimer.is_stopped():
				$DangerTimer.stop()
		States.WARNING:
			self_modulate = warning_color
			if not $DangerTimer.is_stopped():
				$DangerTimer.stop()
		States.DANGER:
			self_modulate = danger_color
			if $DangerTimer.is_stopped():
				$DangerTimer.start()

func _on_danger_timer_timeout():
	system_failed.emit()
