extends Node3D

@export var text_panel: Panel
@export var text: RichTextLabel
@export var base_symbols_per_sec = 10.0

@onready var cooldown = get_node('cooldown')

var dialog_step = -1
var dialog_array = []
var symbols_per_sec = 0.0
var time_progress = 0.0
var ready_for_next_text = false


func is_in_dialog():
	return dialog_array != []

func _process(delta: float) -> void:
	text_panel.visible = is_in_dialog()
	time_progress += delta * symbols_per_sec
	if is_in_dialog():
		text.text = raw_to_bb(dialog_array[dialog_step]['text'], int(time_progress))
	
		if Input.is_action_just_pressed("interact"):
			if ready_for_next_text:
				next_dialog_step()
			elif time_progress > 1.0:
				time_progress += 1000.0
	
func next_dialog_step():
	dialog_step += 1

	if dialog_step >= len(dialog_array):
		cooldown.start()
		dialog_step = -1
		dialog_array = []
		return

	time_progress = 0.0
	symbols_per_sec = base_symbols_per_sec
	ready_for_next_text = false
	text.text = raw_to_bb(dialog_array[dialog_step]['text'], int(time_progress))

func raw_to_bb(raw, symbols):
	var output = ''
	var i = 0
	while i < len(raw):
		if raw[i] == ' ':
			output += ' '
			i += 1
			symbols += 1

		if i > symbols:
			output += '[color=#FFFFFF00]' + raw[i]
		else:
			output += '[color=#FFFFFFFF]' + raw[i]
		i += 1

	if symbols >= len(raw):
		ready_for_next_text = true
	
	return output

func enter_dialog(new_dialog_array):
	if cooldown.is_stopped():
		dialog_array = new_dialog_array
		next_dialog_step()
		return true
	return false
	
