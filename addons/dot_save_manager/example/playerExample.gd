extends Node2D # PLAYER NODE

func _ready() -> void:
	# Connect to the global SAVEMANAGER signals
	DOT_save.data_is_saving.connect(_player_on_save) 
	DOT_save.data_is_loading.connect(_player_on_load) 

func _player_on_save() -> void:
	# Automatically register position to memory before the file is written
	DOT_save.set_value_data("player_position", position)

func _player_on_load() -> void:
	# Automatically update position when a load is completed
	# If no data exists, it defaults to Vector2(0,0)
	position = DOT_save.get_value_data("player_position", Vector2(0,0))
