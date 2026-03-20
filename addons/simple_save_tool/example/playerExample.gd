extends Node2D # PLAYER NODE

func _ready() -> void:
	# Connect to the global SAVEMANAGER signals
	SAVE_MANAGER.data_is_saving.connect(_player_on_save) 
	SAVE_MANAGER.data_was_loaded.connect(_player_on_load) 

func _player_on_save() -> void:
	# Automatically register position to memory before the file is written
	SAVE_MANAGER.set_data("player_position", position)

func _player_on_load() -> void:
	# Automatically update position when a load is completed
	# If no data exists, it defaults to Vector2(0,0)
	position = SAVE_MANAGER.get_data("player_position", Vector2(0,0))
