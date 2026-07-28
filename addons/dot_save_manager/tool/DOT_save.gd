extends Node

enum SLOTS {
	SPACE_0 = 0,
	SPACE_1 = 1,
	SPACE_2 = 2
}

## Emitted before the save file is written to disk
signal data_is_saving()

## Emitted after the save file has been loaded from disk
signal data_is_loading()


# ----- INTERNAL VARIABLES (do not modify directly) -----
@onready var _resource : Array[_resource_save_DOT] = [
	_resource_save_DOT.new(),
	_resource_save_DOT.new(),
	_resource_save_DOT.new()
	]

var _slot : int = 0
var _DEBUG: bool = false
var _FILE_NAME : String = "Save"

# ----- INTERNAL METHODS (do not use directly) -----
func _ready() -> void:
	_get_config_data()
	await _get_file_from_system(_slot)

func _get_config_data() -> void: 
	var _config : ConfigFile = ConfigFile.new()
	_config.load(_config_DOT.system_config_file_path)
	_DEBUG = _config.get_value("DATA", "DEBUG" , false)
	_FILE_NAME = _config.get_value("DATA", "FILE_NAME" , "Save")
	_json_transformer_DOT.ENCRYPT = _config.get_value("DATA", "ENCRYPT" , false)
	_json_transformer_DOT.ENCRYPTION_KEY = _config.get_value("DATA", "ENCRYPTION_KEY" , "json_transformer_key")
	_json_transformer_DOT.ALLOW_USER_RESOURCE = _config.get_value("DATA", "ALLOW_USER_RESOURCE" , false)
	

func _get_file_path(slot_to_check : SLOTS = _slot) -> String:
	var _file_path : String
	var route_to_use : String = "res://" if _DEBUG else "user://"
	_file_path = route_to_use + _FILE_NAME + "_" + str(slot_to_check) + ".json"
	return _file_path


func _get_file_from_system(slot_to_check : SLOTS = _slot) -> Error:
	return await _json_transformer_DOT.SYS_LOADER(_resource[slot_to_check], _get_file_path(slot_to_check))


# -------------------- SAVE / LOAD --------------------
## Creates a fresh (empty) data instance for the current slot, without touching the file on disk. loading the file will recover the data.
func create_new_temporal_data() -> void:
	var clean_save : _resource_save_DOT = _resource_save_DOT.new()
	_resource[_slot] = clean_save


## WARNING: Clears all data from the current slot and overwrites the file on disk with an empty save.
func delete_data() -> Error:
	var clean_save : _resource_save_DOT = _resource_save_DOT.new()
	_resource[_slot] = clean_save
	return await _json_transformer_DOT.SYS_SAVER(clean_save,_get_file_path(_slot))


## Saves the current slot data to disk (or to "res://" if debugging is enabled in _config_DOT).
func save_data(time_to_deferred : float = 0.5) -> Error:
	data_is_saving.emit()
	await get_tree().create_timer(time_to_deferred).timeout
	return await _json_transformer_DOT.SYS_SAVER(_resource[_slot],_get_file_path(_slot))


## Loads the current slot data from disk (or from "res://" if debugging is enabled in _config_DOT).
func load_data() -> Error:
	var loaded : Error = await _get_file_from_system()
	data_is_loading.emit()
	return loaded

## Loads the current slot data without emitting the "data_is_loading" signal. Useful for edge cases where the signal could cause unwanted side effects.
func _load_data_without_signal() -> Error:
	var loaded : Error = await _get_file_from_system()
	return loaded

## Stores a value in the DATA dictionary of the current slot.
func set_value_data(data_key : String, data_value : Variant) -> void:
	_resource[_slot].DATA[data_key] = data_value


## Retrieves a value from the DATA dictionary. Returns `default_value` if the key doesn't exist.
func get_value_data(data_key : String, default_value : Variant = null) -> Variant:
	var data_to_return : Variant = default_value
	if !_resource[_slot].DATA.has(data_key):
		set_value_data(data_key, data_to_return)
	data_to_return = _resource[_slot].DATA[data_key]
	return data_to_return


# -------------------- SLOT MANAGEMENT --------------------
## Switches the active slot (max 3 slots, see SLOTS enum) and load the file.
func change_slot(new_slot : SLOTS) -> void:
	_slot = new_slot
	await _get_file_from_system()

## Returns the entire DATA dictionary from the given slot (defaults to the current slot).
func get_all_data_from_slot(slot : SLOTS = _slot) -> Dictionary:
	await _get_file_from_system(slot)
	return _resource[slot].DATA
