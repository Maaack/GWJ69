@tool
class_name LateralThrustersPanel
extends HUDPanel

signal engine_heated

const WALK_DIRECTION_CHANGE_CHANCE : float = 0.1

@export var target_offset : Vector2 :
	set(value):
		target_offset = value
		if is_inside_tree():
			var offset_total = target_offset * target_offset_mod
			%TargetRect.position = target_origin + offset_total
			var offset_total_length = offset_total.length()
			if offset_total_length > danger_offset_length:
				%TargetRect.modulate = danger_color
			elif offset_total_length > danger_offset_length * 0.75:
				%TargetRect.modulate = warning_color
			elif offset_total_length > danger_offset_length * 0.50:
				%TargetRect.modulate = fine_color
			else:
				%TargetRect.modulate = good_color

@export var target_offset_mod : float = 1.0
@export var danger_offset_length : float = 100.0

@export var noise_texture : NoiseTexture2D 
@export var noise_force_mod : float = 1.0
@export var drift_force_mod : float = 1.0
@export var engine_charge : int = 0 :
	set(value):
		if value < 0  : value = 0
		if value > engine_max_charge : value = engine_max_charge
		engine_charge = value
		if is_inside_tree():
			%EngineChargeBar.value = engine_charge

@export var engine_max_charge : int = 1000:
	set(value):
		if value < 0 : return
		engine_max_charge = value
		if is_inside_tree():
			%EngineChargeBar.max_value = engine_max_charge

@export var engine_recharge_speed : int = 1
@export var good_color : Color
@export var fine_color : Color

@onready var target_origin : Vector2 = %TargetRect.position

var noise_image : Image
var x_noise_iter : int
var y_noise_iter : int
var x_noise_offset : Vector2i
var y_noise_offset : Vector2i
var x_noise_vector : Vector2i
var y_noise_vector : Vector2i

var thrust_vector : Vector2

var direction_array : Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT,
]

func _ready():
	super._ready()
	noise_image = noise_texture.get_image()
	var noise_texture_size = Vector2i(noise_texture.get_width(), noise_texture.get_height())
	x_noise_offset = Vector2i(randi() % noise_texture_size.x, randi() % noise_texture_size.y)
	y_noise_offset = Vector2i(randi() % noise_texture_size.x, randi() % noise_texture_size.y)

func _get_x_noise_pixel() -> Vector2i:
	x_noise_iter += 1
	var noise_iter_vec := x_noise_vector * x_noise_iter
	var x_noise_pixel := (x_noise_offset + noise_iter_vec) % noise_image.get_width()
	if randf() < WALK_DIRECTION_CHANGE_CHANCE:
		x_noise_offset = x_noise_pixel
		x_noise_vector = direction_array.pick_random()
		x_noise_iter = 0
	return x_noise_pixel

func _get_y_noise_pixel() -> Vector2i:
	y_noise_iter += 1
	var noise_iter_vec := y_noise_vector * y_noise_iter
	var y_noise_pixel := (y_noise_offset + noise_iter_vec) % noise_image.get_height()
	if randf() < WALK_DIRECTION_CHANGE_CHANCE:
		y_noise_offset = y_noise_pixel
		y_noise_vector = direction_array.pick_random()
		y_noise_iter = 0
	return y_noise_pixel

func _update_state():
	var offset_total_length = (target_offset * target_offset_mod).length()
	if offset_total_length > danger_offset_length:
		state = States.DANGER
	elif offset_total_length > danger_offset_length * 0.75:
		state = States.WARNING
	else:
		state = States.SAFE

func _on_tick_timer_timeout():
	_update_state()
	var desired_charge = round(thrust_vector.length())
	if desired_charge > 0 and engine_charge > desired_charge:
		target_offset += thrust_vector
		engine_charge -= desired_charge
		engine_heated.emit()

func _on_drift_tick_timer_timeout():
	var x_noise_pixel = _get_x_noise_pixel()
	var y_noise_pixel = _get_y_noise_pixel()
	var x_effect = (noise_image.get_pixelv(x_noise_pixel).r * 2) - 1
	var y_effect = (noise_image.get_pixelv(y_noise_pixel).r * 2) - 1
	var total_noise_force = Vector2(x_effect, y_effect)
	total_noise_force *= noise_force_mod
	total_noise_force *= drift_force_mod
	target_offset += total_noise_force

func _on_up_button_button_down():
	thrust_vector += Vector2.UP

func _on_up_button_button_up():
	thrust_vector -= Vector2.UP

func _on_left_button_button_down():
	thrust_vector += Vector2.LEFT

func _on_left_button_button_up():
	thrust_vector -= Vector2.LEFT

func _on_right_button_button_down():
	thrust_vector += Vector2.RIGHT

func _on_right_button_button_up():
	thrust_vector -= Vector2.RIGHT

func _on_down_button_button_down():
	thrust_vector += Vector2.DOWN

func _on_down_button_button_up():
	thrust_vector -= Vector2.DOWN

func _on_recharge_tick_timer_timeout():
	if round(thrust_vector.length()) > 0: return
	engine_charge += engine_recharge_speed
