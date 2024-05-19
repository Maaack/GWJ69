@tool
class_name SystemHeatMeter
extends VBoxContainer

signal up_button_pressed
signal down_button_pressed

const MAX_SYSTEM_LABEL_LENGTH : int = 4
const MAX_COOLANT_LEVEL : int = 10

@export var system_name : String :
	set(value):
		system_name = value
		shortened_name = value

@export_range(0, 20) var coolant_level : int :
	set(value):
		if value < 0 or value > MAX_COOLANT_LEVEL: return
		coolant_level = value
		if is_inside_tree():
			%CoolantLabel.text = "%d" % coolant_level

@export_range(0, 20) var heat_level : int


@export var temperature : int = 0 :
	set(value):
		temperature = value
		if temperature < 0:
			temperature = 0
		if is_inside_tree():
			%HeatMeter.value = temperature
		
@export var max_temperature : int = 1000 :
	set(value):
		max_temperature = value
		if is_inside_tree():
			%HeatMeter.max_value = max_temperature

var shortened_name : String :
	set(value):
		shortened_name = value
		if shortened_name.length() > MAX_SYSTEM_LABEL_LENGTH:
			shortened_name = shortened_name.left(MAX_SYSTEM_LABEL_LENGTH) + "."
		if is_inside_tree():
			%SystemLabel.text = shortened_name

func _on_up_button_pressed():
	up_button_pressed.emit()

func _on_down_button_pressed():
	down_button_pressed.emit()

func _ready():
	system_name = system_name

func _on_tick_timer_timeout():
	temperature += heat_level - coolant_level
