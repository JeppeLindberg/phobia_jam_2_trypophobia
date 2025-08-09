extends StaticBody3D

@export var player: Node3D


var dialog_array = \
[
	{
		'text': 'are you stuck in here too?'
	},
	{
		'text': 'im cold...'
	}
]


func _ready() -> void:
	add_to_group('interactable')

func interact():
	player.enter_dialog(dialog_array)
