extends Node

enum SLOTS { 
	SPACE_1 = 0, 
	SPACE_2 = 1, 
	SPACE_3 = 2
	} 

## happens before the save is done
signal data_is_saving()

## happens after the load is done 
signal data_is_loading()


# ----- VARIABLES ----- (do not use)


@onready var _resource : Array[DOT_resource_save] = [
	DOT_resource_save.new(),
	DOT_resource_save.new(),
	DOT_resource_save.new()
	]
var _system_file_name : String = "Save"
var _system_route :  String = "user://"
var _slot : int = 0
var _extension : String = ".tres"
var _file_path : String 
var _debugging_system_route : String = "res://"
var _is_debugging : bool = false


# ----- (do not use) - functions ----- 
func _ready() -> void:
	_update_file_path()
	_check_file_in_folder(_file_path)


func _update_file_path() -> void: 
	var route_to_use : String = _debugging_system_route if _is_debugging else _system_route
	_file_path = route_to_use + _system_file_name + "_" + str(_slot) + _extension


func _check_file_in_folder(path : String, slot_to_check : SLOTS = _slot) -> void:
	if ResourceLoader.exists(path):
		var updated_file : Resource = load(_file_path)
		_resource[slot_to_check] = updated_file
	else: 
		_resource[slot_to_check] = DOT_resource_save.new()


# ----- Managers to use at _ready - functions -----
## use this only when developing to keep the saved Resource in the "res://" folder for your needs.
func debugging(is_activate : bool) -> void:
	_is_debugging = is_activate
	_update_file_path()
	_check_file_in_folder(_file_path)


## This is the name of the file, call it how you want to (this ends with ".tres" extension, so dont add it) (default -> "Save"), IMPORTANT: use it at the start of the game.
func change_file_name(new_name : String) -> void:
	_system_file_name = new_name
	_update_file_path()
	_check_file_in_folder(_file_path)


# -------------------- SAVE and LOAD data - functions --------------------
## create a new "temporal/clear" data of the current slot
func create_new_temporal_data() -> void:
	var new_instance : DOT_resource_save = DOT_resource_save.new()
	_resource[_slot] = new_instance


## WARNING: deletes the DATA and the FILE in system of the current slot
func delete_data() -> Error: 
	var res : Error = Error.ERR_FILE_CANT_OPEN
	if ResourceLoader.exists(_file_path):
		var new_instance : DOT_resource_save = DOT_resource_save.new()
		_resource[_slot] = new_instance
		res = await ResourceSaver.save(_resource[_slot], _file_path, true)
	return res


## save the resource in FILE SYSTEM (or "res://" if debugging is TRUE)
func save_data(time_to_deferred : float = 0.5) -> Error:
	data_is_saving.emit()
	await get_tree().create_timer(time_to_deferred).timeout
	var res : Error = await ResourceSaver.save( _resource[_slot], _file_path, true)
	return res


## load the resource in FILE SYSTEM (or "res://" if debugging is TRUE)
func load_data() -> void:
	if ResourceLoader.exists(_file_path):
		var updated_file : Resource = load(_file_path)
		_resource[_slot] = updated_file
	data_is_loading.emit()


## save Values, data of your variables 
func set_value_data(data_key : String, data_value : Variant) -> void: 
	_resource[_slot].DATA[data_key] = data_value


## load Values,data into your variables
func get_value_data(data_key : String , default_value : Variant = null) -> Variant: 
	var data_to_return : Variant = default_value
	if !_resource[_slot].DATA.has(data_key):
		set_value_data(data_key, data_to_return)
	data_to_return = _resource[_slot].DATA[data_key]
	return data_to_return


# -------------------- SLOTS MANAGE - functions --------------------
## change current save slot, usefull if you want more than 1 save (MAX 3 slots, check SLOTS enum)
func change_slot(new_slot : SLOTS) -> void:
	_slot = new_slot
	_update_file_path()
	_check_file_in_folder(_file_path)

## if needed, you can retrive all the data from a slot
func get_all_data_from_slot(slot : SLOTS = _slot) -> Dictionary:
	_check_file_in_folder(_file_path,slot)
	return _resource[slot].DATA
