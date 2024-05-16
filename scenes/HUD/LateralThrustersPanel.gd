@tool
extends HUDPanel

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
@export var engine_charge : int = 0 :
	set(value):
		if value < 0 or value > engine_max_charge : return
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
@export var warning_color : Color
@export var danger_color : Color

@onready var target_origin : Vector2 = %TargetRect.position

var noise_image : Image
var noise_iter : int
var x_noise_offset : Vector2i
var y_noise_offset : Vector2i

var thrust_vector : Vector2

func _ready():
	super._ready()
	noise_image = noise_texture.get_image()
	var noise_texture_size = Vector2i(noise_texture.get_width(), noise_texture.get_height())
	x_noise_offset = Vector2i(randi() % noise_texture_size.x, randi() % noise_texture_size.y)
	y_noise_offset = Vector2i(randi() % noise_texture_size.x, randi() % noise_texture_size.y)

func _on_tick_timer_timeout():
	noise_iter += 1
	engine_charge += engine_recharge_speed
	var noise_iter_vec := Vector2i(noise_iter, 0)
	var x_noise_pixel = (x_noise_offset + noise_iter_vec) % noise_image.get_width()
	var y_noise_pixel = (y_noise_offset + noise_iter_vec) % noise_image.get_height()
	var x_effect = (noise_image.get_pixelv(x_noise_pixel).r * 2) - 1
	var y_effect = (noise_image.get_pixelv(y_noise_pixel).r * 2) - 1
	var total_noise_force = Vector2(x_effect, y_effect) * noise_force_mod
	target_offset += total_noise_force

func _process(delta):
	var desired_charge = round(thrust_vector.length())
	if engine_charge > desired_charge:
		target_offset += thrust_vector
		engine_charge -= desired_charge

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
