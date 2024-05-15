extends Node3D

@export var ship_path_follow : PathFollow3D
@export var ship_path_total_time : float = 0.0
@export var primary_camera : Camera3D
@export var camera_target : Node3D

func _process(delta):
	if ship_path_total_time > 0.0:
		ship_path_follow.progress_ratio += delta / ship_path_total_time
	primary_camera.look_at(camera_target.position)
