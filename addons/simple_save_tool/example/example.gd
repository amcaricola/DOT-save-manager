extends Node


@onready var change_slot_0: Button = %change_slot_0
@onready var change_slot_1: Button = %change_slot_1
@onready var save_data: Button = %save_data
@onready var loda_data: Button = %loda_data


@onready var player: Node2D = %player
var original_player_position : Vector2

@onready var label_number: Label = %label_number
@onready var less_number: Button = %less_number
@onready var plus_number: Button = %plus_number


var number : int = 0:
	set(value):
		number = value
		label_number.text = str(value)


func _ready() -> void:
	push_warning("NOTE: This test scene creates save files in the 'res://' directory.")
	SAVE_MANAGER.debugging(true)
	change_slot_0.pressed.connect(_change_slot_0)
	change_slot_1.pressed.connect(_change_slot_1)
	save_data.pressed.connect(_save_data)
	loda_data.pressed.connect(_loda_data)
	less_number.pressed.connect(_less_number)
	plus_number.pressed.connect(_plus_number)
	original_player_position = player.position

func _update_player_position() -> void:
	player.position = Vector2(original_player_position.x + (10 * number), original_player_position.y)

func _less_number () -> void: 
	number = number - 1 
	_update_player_position()

func _plus_number () -> void: 
	number = number + 1
	_update_player_position()

func _change_slot_0 () -> void: SAVE_MANAGER.change_slot(0)
func _change_slot_1 () -> void: SAVE_MANAGER.change_slot(1)

func _save_data () -> void: 
	SAVE_MANAGER.set_data("number", number) #this save the data in the resource
	await SAVE_MANAGER.save_data() #this save the data in the user/res directory 


func _loda_data () -> void:
	SAVE_MANAGER.load_data() #this load the data from the user/res directory to the resource
	number = SAVE_MANAGER.get_data("number", 0) #this load the data of the resource into the variable
