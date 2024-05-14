extends Node

@export var rotation_speed : float = 0.0
@export var camera_node : Camera3D
@export var world_environment : WorldEnvironment

var camera_rotation_offset : float = 0.0

func _process(delta):
	var rotation_delta = rotation_speed * delta
	camera_rotation_offset += rotation_delta
	camera_node.transform = camera_node.transform.rotated(Vector3.UP, rotation_delta)
	##world_environment.environment.sky_rotation.y = camera_rotation_offset
