extends CanvasLayer

signal choice_made(choice : int)

func _ready():
	InGameMenuController.scene_tree = get_tree()

func _on_dive_button_pressed():
	choice_made.emit(0)

func _on_return_button_pressed():
	choice_made.emit(1)
