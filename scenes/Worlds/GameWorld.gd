@tool
extends Node3D

signal distance_changed(distance_km : float)
signal time_changed(local_time : float)
signal recording_recovered(transcript : String)
signal target_reached
signal ship_returned

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
@export var singularity : Node3D
@export var edge_marker : Marker3D
@export var schwarzschild_radius_km : float
@export var ship_moving_flag : bool = false


var target_reached_flag : bool = false
var ship_returned_flag : bool = false

@onready var _recording_times = recording_times
@onready var _recording_streams = recording_streams
@onready var _recording_transcripts = recording_transcripts

var elapsed_local_time : float :
	set(value):
		elapsed_local_time = value
		time_changed.emit(elapsed_local_time)

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
	if _recording_times.size() > 0 and %PathFollow3D.progress_ratio > _recording_times[0]:
		_play_next_event()
	if target_reached_flag:
		if ship_returned_flag: return
		if %PathFollow3D.progress_ratio < 0.5:
			# ship is back at beginning
			ship_returned.emit()
			ship_returned_flag = true
	elif %PathFollow3D.progress_ratio > 0.5:
		target_reached.emit()
		target_reached_flag = true

func _get_camera_focus_point() -> Vector3:
	return camera_target.position + Vector3.UP.cross(primary_camera.position).normalized() * camera_target_offset

func _estimate_distance_km(node_position : Vector3):
	var camera_distance := primary_camera.position.distance_to(singularity.position)
	var camera_distance_ratio := camera_distance / edge_marker.position.distance_to(singularity.position)
	return camera_distance_ratio * schwarzschild_radius_km

func _process(delta):
	if Engine.is_editor_hint(): return
	elapsed_local_time += delta
	if ship_moving_flag and ship_path_total_time > 0.0:
		%PathFollow3D.progress_ratio += delta / ship_path_total_time
		_check_progress()
	primary_camera.look_at(_get_camera_focus_point())
	distance_changed.emit(_estimate_distance_km(primary_camera.position))
