@tool
class_name HeatManagementPanel
extends HUDPanel

signal coolant_pumping_changed(current_amount)

const COOLANT_STRING = "Coolant
Control
Reserve: %d"

@export var coolant_reserve : int :
	set(value):
		coolant_reserve = value
		_update_flush_button()
		if is_inside_tree():
			%CoolantLabel.text = COOLANT_STRING % coolant_reserve

@export var overall_heat_level : int
@export var heat_change_time : float
@export var heat_change_randomness : float
@export var heat_meter_container : Control

var coolant_pumping : int :
	set(value):
		coolant_pumping = value
		coolant_pumping_changed.emit(coolant_pumping)

func meter_requests_coolant(heat_meter : SystemHeatMeter):
	if coolant_reserve > 0:
		coolant_reserve -= 1
		heat_meter.coolant_level += 1
		coolant_pumping += 1

func meter_returns_coolant(heat_meter : SystemHeatMeter):
	if heat_meter.coolant_level > 0:
		heat_meter.coolant_level -= 1
		coolant_reserve += 1
		coolant_pumping -= 1

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
			if heat_meters.size() == 0:
				heat_meter.heat_level = remaining_heat
				remaining_heat = 0
			elif remaining_heat > 0:
				var system_heat = randi() % remaining_heat
				heat_meter.heat_level = system_heat
				remaining_heat -= system_heat
			else:
				heat_meter.heat_level = 0
	$HeatChangeTimer.start(_get_next_heat_change_time())

func _update_flush_button():
	if not is_inside_tree(): return
	%FlushButton.disabled = coolant_reserve < 1 or (not $FlushCooldownTimer.is_stopped())

func _on_heat_change_timer_timeout():
	cycle_heat_levels()

func _update_state():
	var max_system_temperature_ratio : float
	for heat_meter in heat_meter_container.get_children():
		if heat_meter is SystemHeatMeter:
			var system_temperature_ratio = float(heat_meter.temperature) / float(heat_meter.max_temperature)
			max_system_temperature_ratio = max(system_temperature_ratio, max_system_temperature_ratio)
	if max_system_temperature_ratio > 1.0:
		state = States.DANGER
	elif max_system_temperature_ratio > 0.8:
		state = States.WARNING
	else:
		state = States.SAFE

func _on_tick_timer_timeout():
	_update_state()

func _on_flush_cooldown_timer_timeout():
	_update_flush_button()

func _flush_systems():
	for heat_meter in heat_meter_container.get_children():
		if heat_meter is SystemHeatMeter:
			heat_meter.temperature *= 0.5

func _flush_coolant():
	coolant_reserve -= 1

func _on_flush_button_pressed():
	if coolant_reserve > 0:
		_flush_systems()
		_flush_coolant()
		$FlushCooldownTimer.start()
		_update_flush_button()

func heat_engine(amount : int):
	for heat_meter in heat_meter_container.get_children():
		if heat_meter is SystemHeatMeter:
			if heat_meter.system_name == "Engine":
				heat_meter.temperature += amount
