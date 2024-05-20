extends Control

enum GameChoice{
	LEAP,
	RETURN
}

@export var return_scene : PackedScene
@export var leap_scene : PackedScene
@export var lose_scene : PackedScene
@export var decision_scene : PackedScene

var intro_done : bool = false
var skip_pressed_once : bool = false

func _unhandled_input(event):
	if event.is_action_pressed(&"ui_accept") \
	or event.is_action_pressed(&"ui_select"):
		if intro_done : return
		if not skip_pressed_once:
			skip_pressed_once = true
			$SkipLabel.show()
		else:
			var animation_state_machine : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
			animation_state_machine.start(&"Booting")
	if event.is_action_pressed(&"ui_hide"):
		%HUDViewportContainer.visible = !%HUDViewportContainer.visible

func _ready():
	InGameMenuController.scene_tree = get_tree()
	if Input.is_action_pressed(&"ui_console"):
		%HUD.instant_boot()

func _on_level_lost():
	InGameMenuController.open_menu(lose_scene, get_viewport())

func _on_game_world_distance_changed(distance_km):
	%HUD.set_distance(distance_km)

func _on_game_world_time_changed(local_time, station_time):
	%HUD.set_local_time(local_time)
	%HUD.set_station_time(station_time)

func _on_hud_system_failed():
	_on_level_lost()

func _on_game_choice_made(choice : int):
	InGameMenuController.close_menu()
	match(choice):
		GameChoice.LEAP:
			%GameWorld.leap()
		GameChoice.RETURN:
			pass

func _on_load_game_decision():
	InGameMenuController.open_menu(decision_scene, get_viewport())
	if InGameMenuController.current_menu.has_signal("choice_made"):
		InGameMenuController.current_menu.choice_made.connect(_on_game_choice_made)

func _on_game_world_target_reached():
	_on_load_game_decision()

func _on_game_world_ship_returned():
	InGameMenuController.open_menu(return_scene, get_viewport())

func _on_game_world_ship_dove():
	InGameMenuController.open_menu(leap_scene, get_viewport())

func _on_game_world_recording_recovered(transcript):
	%HUD.read_transcript(transcript)

func _on_booting_animation_player_animation_finished(anim_name):
	if anim_name.find("Intro") != -1:
		intro_done = true

func _on_booting_animation_player_current_animation_changed(name):
	if name.find("Booting") != -1:
		intro_done = true
