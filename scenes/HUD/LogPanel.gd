@tool
class_name LogPanel
extends HUDPanel

const LOG_LABEL_STRING = "[right]%s[/right]"
const END_OF_RECORDING_STRING = "[END OF RECORDING]"

@export var full_string : String :
	set(value):
		full_string = value
		if is_inside_tree():
			%LogLabel.text = LOG_LABEL_STRING % [full_string]
@export var chars_per_print : int = 1
@export_multiline var end_of_recording_text : String = END_OF_RECORDING_STRING

var text_buffer : String

func add_recording(new_log : String):
	add_log(new_log)
	text_buffer += "\n" + end_of_recording_text

func add_log(new_log : String):
	text_buffer += "\n\n"
	text_buffer += new_log

func _on_print_timer_timeout():
	var print_chars := text_buffer.left(chars_per_print)
	text_buffer = text_buffer.right(-chars_per_print)
	full_string += print_chars
	
