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
var _panel_state : States

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
	if anim_name.find("Booting") != -1:
		booted = true

func _update_panel():
	if _panel_state == state : return
	match(state):
		States.SAFE:
			$StateAnimationPlayer.play(&"SAFE")
			$StateAnimationPlayer2.play(&"SAFE")
			if not $DangerTimer.is_stopped():
				$DangerTimer.stop()
		States.WARNING:
			$StateAnimationPlayer.play(&"WARNING")
			$StateAnimationPlayer2.play(&"WARNING")
			if not $DangerTimer.is_stopped():
				$DangerTimer.stop()
		States.DANGER:
			$StateAnimationPlayer.play(&"DANGER")
			$StateAnimationPlayer2.play(&"DANGER")
			if $DangerTimer.is_stopped():
				$DangerTimer.start()
	_panel_state = state

func _on_danger_timer_timeout():
	system_failed.emit()
