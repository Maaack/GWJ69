extends Node3D

signal distance_changed(distance_km : float)
signal time_changed(local_time : float)

@export var ship_path_follow : PathFollow3D
@export var ship_path_total_time : float = 0.0
@export var primary_camera : Camera3D
@export var camera_target : Node3D
@export var singularity : Node3D
@export var starting_distance_km : float

@onready var starting_distance : float = primary_camera.position.distance_to(singularity.position)

var elapsed_local_time : float :
	set(value):
		elapsed_local_time = value
		time_changed.emit(elapsed_local_time)

func _process(delta):
	elapsed_local_time += delta
	if ship_path_total_time > 0.0:
		ship_path_follow.progress_ratio += delta / ship_path_total_time
	primary_camera.look_at(camera_target.position)
	var distance_ratio = primary_camera.position.distance_to(singularity.position) / starting_distance
	distance_changed.emit(starting_distance_km * distance_ratio)
