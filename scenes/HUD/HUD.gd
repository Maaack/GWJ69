extends Control

@export var hud_panels : Array[HUDPanel]
@export var panel_boot_delay : float = 0.0
@export var info_panel : InfoPanel

func _ready():
	for hud_panel in hud_panels:
		if hud_panel == null: continue
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
