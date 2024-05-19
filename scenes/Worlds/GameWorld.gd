@tool
extends Node3D

signal distance_changed(distance_km : float)
signal time_changed(local_time : float, station_time : float)
signal recording_recovered(transcript : String)
signal target_reached
signal ship_returned
signal ship_dove

@export var ship_path_total_time : float = 0.0
@export var recording_times : Array[float] :
	set(value):
		recording_times = value
		recording_times.sort()
@export var recording_streams : Array[AudioStream]
@export_multiline var recording_transcripts : Array[String]
@export var primary_camera : Camera3D
@export var camera_target : Node3D
@export var camera_target_offset : float = 1
@export var camera_reverse_offset : float = 1
@export var singularity : Node3D
@export var edge_marker : Marker3D
@export var schwarzschild_radius_km : float
@export var ship_moving_flag : bool = false
@export var galaxy_spin_rate : float = 0.0000001
var galaxy_spin_rate_mod : float = .5

var target_reached_flag : bool = false
var ship_loop_completed : bool = false

@onready var _recording_times = recording_times
@onready var _recording_streams = recording_streams
@onready var _recording_transcripts = recording_transcripts
@onready var _path_follow_node : PathFollow3D = %PathFollow3D
@onready var _station_distance : float = primary_camera.position.distance_to(singularity.position)

var elapsed_local_time : float :
	set(value):
		var time_delta = abs(value - elapsed_local_time)
		elapsed_local_time = value
		var station_time_delta = time_delta * _get_station_time_ratio()
		elapsed_station_time += station_time_delta
		_rotate_sky(station_time_delta)
		time_changed.emit(elapsed_local_time, elapsed_station_time)

var elapsed_station_time : float

func _get_station_time_ratio() -> float:
	var current_distance := primary_camera.position.distance_to(singularity.position)
	var distance_ratio := current_distance / _station_distance
	return pow(1.0 / (1.0 - sqrt(1 - distance_ratio)), 6)

func _rotate_sky(delta : float):
	$WorldEnvironment.environment.sky_rotation.y -= delta * galaxy_spin_rate * galaxy_spin_rate_mod

func _play_next_event():
	if _recording_streams.size() > 0 and _recording_times.size() > 0:
		%RecordingPlayer.stream = _recording_streams.pop_front()
		%RecordingPlayer.play()
		var transcript : String = ""
		if _recording_transcripts.size() > 0:
			transcript = _recording_transcripts.pop_front()
		recording_recovered.emit(transcript)
		_recording_times.pop_front()

func _check_progress():
	if _recording_times.size() > 0 and _path_follow_node.progress_ratio > _recording_times[0]:
		_play_next_event()
	if target_reached_flag:
		if ship_loop_completed: return
		if _path_follow_node.progress_ratio < 0.5:
			# ship is back at beginning
			if _path_follow_node.get_parent() == $LeapPath3D:
				ship_dove.emit()
			else:
				ship_returned.emit()
			ship_loop_completed = true
	elif _path_follow_node.progress_ratio > 0.5:
		target_reached.emit()
		target_reached_flag = true

func _get_camera_distance_ratio() -> float:
	var camera_distance := primary_camera.position.distance_to(singularity.position)
	var edge_marker_distance := edge_marker.position.distance_to(singularity.position)
	return camera_distance / edge_marker_distance

func _get_camera_focus_point() -> Vector3:
	var target_right_edge := camera_target.position + Vector3.UP.cross(primary_camera.position).normalized() * camera_target_offset
	var target_reverse := primary_camera.position.direction_to(camera_target.position).rotated(Vector3.UP, PI) * camera_reverse_offset
	var camera_distance_ratio := _get_camera_distance_ratio()
	if camera_distance_ratio > 1.0:
		return target_right_edge
	else:
		var min_ratio = 0.2
		var final_ratio = (camera_distance_ratio - min_ratio) / (1 - min_ratio)
		return lerp(target_reverse, target_right_edge, final_ratio)

func _estimate_distance_km(node_position : Vector3):
	var camera_distance_ratio := _get_camera_distance_ratio()
	return camera_distance_ratio * schwarzschild_radius_km

func _process(delta):
	if Engine.is_editor_hint(): return
	elapsed_local_time += delta
	if ship_moving_flag and ship_path_total_time > 0.0:
		_path_follow_node.progress_ratio += delta / ship_path_total_time
		_check_progress()
	primary_camera.look_at(_get_camera_focus_point())
	distance_changed.emit(_estimate_distance_km(primary_camera.position))

func leap():
	var progress_ratio = _path_follow_node.progress_ratio
	_path_follow_node.reparent($LeapPath3D)
	_path_follow_node.set_deferred(&"progress_ratio", progress_ratio)
