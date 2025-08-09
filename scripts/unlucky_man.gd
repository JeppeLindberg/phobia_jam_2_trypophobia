extends StaticBody3D

@export var player: Node3D


var step = 1

var dialog_array_1 = \
[
	{
		'text': '... Are anyone there?'
	},
	{
		'text': '... no...'
	},
	{
		'text': '... Please, no...'
	},
	{
		'text': 'You need to leave...'
	},
	{
		'text': 'This place is'
	},
	{
		'text': 'bad.'
	},
	{
		'text': 'Its too late for me.'
	},
	{
		'text': 'But you can still make it...'
	}
]

var dialog_array_2 = \
[
	{
		'text': 'I should have never taken this job...'
	}
]


func _ready() -> void:
	add_to_group('interactable')

func interact():
	if step == 1:
		player.enter_dialog(dialog_array_1)
		step = 2
	else:
		player.enter_dialog(dialog_array_2)
		
