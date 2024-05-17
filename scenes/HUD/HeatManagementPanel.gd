extends HUDPanel

const COOLANT_STRING = "Coolant
Control
Reserve: %d"

@export var coolant_reserve : int :
	set(value):
		coolant_reserve = value
		if is_inside_tree():
			%CoolantLabel.text = COOLANT_STRING % coolant_reserve

@export var heat_meter_container : Control

func meter_requests_coolant(heat_meter : SystemHeatMeter):
	if coolant_reserve > 0:
		coolant_reserve -= 1
		heat_meter.coolant_level += 1

func meter_returns_coolant(heat_meter : SystemHeatMeter):
	if heat_meter.coolant_level > 0:
		heat_meter.coolant_level -= 1
		coolant_reserve += 1

func _ready():
	super._ready()
	coolant_reserve = coolant_reserve
	for heat_meter in heat_meter_container.get_children():
		if heat_meter is SystemHeatMeter:
			heat_meter.up_button_pressed.connect(meter_requests_coolant.bind(heat_meter))
			heat_meter.down_button_pressed.connect(meter_returns_coolant.bind(heat_meter))
