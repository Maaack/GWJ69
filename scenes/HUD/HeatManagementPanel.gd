extends HUDPanel

const COOLANT_STRING = "Coolant
Control
Reserve: %d"

@export var coolant_reserve : int :
	set(value):
		coolant_reserve = value
		if is_inside_tree():
			%CoolantLabel.text = COOLANT_STRING % coolant_reserve
@export var overall_heat_level : int
@export var heat_change_time : float
@export var heat_change_randomness : float

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
	overall_heat_level = overall_heat_level
	for heat_meter in heat_meter_container.get_children():
		if heat_meter is SystemHeatMeter:
			heat_meter.up_button_pressed.connect(meter_requests_coolant.bind(heat_meter))
			heat_meter.down_button_pressed.connect(meter_returns_coolant.bind(heat_meter))

func _get_next_heat_change_time():
	return heat_change_time + randf_range(-heat_change_randomness/2, heat_change_randomness/2)

func cycle_heat_levels():
	var heat_meters : Array = heat_meter_container.get_children()
	heat_meters.shuffle()
	var remaining_heat = overall_heat_level
	var heat_meter
	while(heat_meters.size() > 0):
		heat_meter = heat_meters.pop_back()
		if heat_meter is SystemHeatMeter:
			if remaining_heat > 0:
				var system_heat = randi() % remaining_heat
				heat_meter.heat_level = system_heat
				remaining_heat -= system_heat
			else:
				heat_meter.heat_level = 0
	$HeatChangeTimer.start(_get_next_heat_change_time())

func _on_heat_change_timer_timeout():
	cycle_heat_levels()
