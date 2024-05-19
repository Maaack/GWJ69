extends Control

signal system_failed

@export var hud_panels : Array[HUDPanel]
@export var panel_boot_delay : float = 0.0
@export var pump_drift_mod : float = 0.0
@export var engine_heat_amount : int = 1
@export var reactor_heat_amount : int = 1
@export var info_panel : InfoPanel
@export var heat_management_panel : HeatManagementPanel
@export var lateral_thrust_panel : LateralThrustersPanel
@export var log_panel : LogPanel

var booted : bool = false

func boot():
	if booted : return
	booted = true
	$BootingAnimationPlayer.play(&"Booting")
	for hud_panel in hud_panels:
		if hud_panel == null: continue
		hud_panel.system_failed.connect(func(): system_failed.emit())
		await(get_tree().create_timer(panel_boot_delay, false).timeout)
		hud_panel.boot()

func instant_boot():
	for hud_panel in hud_panels:
		if hud_panel == null: continue
		hud_panel.instant_boot()

func set_distance(distance_km : float):
	info_panel.distance_km = distance_km

func set_local_time(local_time : float):
	info_panel.elapsed_local_time = local_time

func set_station_time(station_time : float):
	info_panel.elapsed_station_time = station_time

func _on_heat_management_panel_coolant_pumping_changed(current_amount):
	lateral_thrust_panel.drift_force_mod = 1.0 + (current_amount * pump_drift_mod)

func _on_lateral_thrusters_panel_engine_heated():
	heat_management_panel.heat_engine(engine_heat_amount)

func _on_lateral_thrusters_panel_reactor_heated():
	heat_management_panel.heat_reactor(reactor_heat_amount)

func read_transcript(transcript : String):
	log_panel.add_recording(transcript)

func _on_heat_management_panel_coolant_flushed():
	lateral_thrust_panel.flush_coolant()
