extends Node

enum SLOTS {
	SPACE_1 = 0,
	SPACE_2 = 1,
	SPACE_3 = 2
}

## Emitted before the save file is written to disk
signal data_is_saving()

## Emitted after the save file has been loaded from disk
signal data_is_loading()


# ----- INTERNAL VARIABLES (do not modify directly) -----


@onready var _resource : Array[DOT_resource_save] = [
	DOT_resource_save.new(),
	DOT_resource_save.new(),
	DOT_resource_save.new()
	]
var _system_file_name : String = "Save"
var _system_route : String = "user://"
var _slot : int = 0
var _extension : String = ".json"
var _file_path : String
var _debugging_system_route : String = "res://"
var _is_debugging : bool = false


# ----- INTERNAL METHODS (do not use directly) -----
func _ready() -> void:
	_update_file_path()
	_check_file_in_folder(_file_path)


func _update_file_path() -> void:
	var route_to_use : String = _debugging_system_route if _is_debugging else _system_route
	_file_path = route_to_use + _system_file_name + "_" + str(_slot) + _extension


func _check_file_in_folder(path : String, slot_to_check : SLOTS = _slot) -> void:
	JSON_TRANSFORMER.SYS_LOADER(_resource[slot_to_check],path )
	#if ResourceLoader.exists(path):
		#var updated_file : Resource = load(_file_path)
		#_resource[slot_to_check] = updated_file
	#else:
		#_resource[slot_to_check] = DOT_resource_save.new()


# ----- SETUP METHODS (call at _ready) -----
## Use only during development to keep save files in "res://" for easy editor inspection.
func debugging(is_active : bool) -> void:
	_is_debugging = is_active
	_update_file_path()
	_check_file_in_folder(_file_path)


## Changes the base file name (without extension). Default is "Save". Call at the start of the game.
func change_file_name(new_name : String) -> void:
	_system_file_name = new_name
	_update_file_path()
	_check_file_in_folder(_file_path)


# -------------------- SAVE / LOAD --------------------
## Creates a fresh (empty) data instance for the current slot, without touching the file on disk.
func create_new_temporal_data() -> void:
	var new_instance : DOT_resource_save = DOT_resource_save.new()
	_resource[_slot] = new_instance


## WARNING: Deletes the data and the file on disk for the current slot.
func delete_data() -> Error:
	var res : Error = Error.ERR_FILE_CANT_OPEN
	if ResourceLoader.exists(_file_path):
		var new_instance : DOT_resource_save = DOT_resource_save.new()
		_resource[_slot] = new_instance
		res = await ResourceSaver.save(_resource[_slot], _file_path, true)
	return res


## Saves the current slot data to disk (or to "res://" if debugging is enabled).
func save_data(time_to_deferred : float = 0.5) -> Error:
	data_is_saving.emit()
	await get_tree().create_timer(time_to_deferred).timeout
	#var res : Error = await ResourceSaver.save(_resource[_slot], _file_path, true)
	JSON_TRANSFORMER.SYS_SAVER(_resource[_slot],_file_path)
	return Error.ERR_ALREADY_EXISTS


## Loads the current slot data from disk (or from "res://" if debugging is enabled).
func load_data() -> void:
	#if ResourceLoader.exists(_file_path):
		#var updated_file : Resource = load(_file_path)
		#_resource[_slot] = updated_file
	JSON_TRANSFORMER.SYS_LOADER(_resource[_slot],_file_path)
	data_is_loading.emit()


## Stores a value in the DATA dictionary of the current slot.
func set_value_data(data_key : String, data_value : Variant) -> void:
	var value_to_save : Array = JSON_TRANSFORMER.stringify(data_value)
	_resource[_slot].DATA[data_key] = value_to_save
	#print(value_to_save)


## Retrieves a value from the DATA dictionary. Returns `default_value` if the key doesn't exist.
func get_value_data(data_key : String, default_value : Variant = null) -> Variant:
	var data_to_return : Variant = default_value
	if !_resource[_slot].DATA.has(data_key):
		set_value_data(data_key, data_to_return)
	data_to_return = JSON_TRANSFORMER.parcer(_resource[_slot].DATA[data_key])
	return data_to_return


# -------------------- SLOT MANAGEMENT --------------------
## Switches the active slot (max 3 slots, see SLOTS enum).
func change_slot(new_slot : SLOTS) -> void:
	_slot = new_slot
	_update_file_path()
	_check_file_in_folder(_file_path)


## Returns the entire DATA dictionary from the given slot (defaults to the current slot).
func get_all_data_from_slot(slot : SLOTS = _slot) -> Dictionary:
	_check_file_in_folder(_file_path, slot)
	return _resource[slot].DATA
