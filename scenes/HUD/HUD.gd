extends Control

@export var hud_panels : Array[HUDPanel]
@export var panel_boot_delay : float = 0.0

func _ready():
	print(panel_boot_delay)
	for hud_panel in hud_panels:
		if hud_panel == null: continue
		await(get_tree().create_timer(panel_boot_delay, false).timeout)
		hud_panel.boot()
