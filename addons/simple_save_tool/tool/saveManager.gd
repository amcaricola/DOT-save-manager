extends Node

## happens before the save is done
signal will_save_data()

## happens after the load is done 
signal load_data_done()


# ----- VARIABLES ----- (do not use)


var _system_file_name : String = "Save"
var _system_route :  String = "user://"
var _resource : SAVE
var _slot : int = 0
var _extension : String = ".tres"
var _file_path : String 


# ----- FUNCTIONS ----- (do not use)


func _ready() -> void:
	_update_file_path()
	_create_file(_file_path)


func _update_file_path() -> void: 
	_file_path = _system_route + _system_file_name + "_" + str(_slot) + _extension


func _create_file(path : String) -> void:
	if ResourceLoader.exists(path):
		var updated_file : Resource = load(_file_path)
		_resource = updated_file
	else: 
		_resource = SAVE.new()


func _time_deferred(time : float = 0.5) -> bool:
	await get_tree().create_timer(time).timeout
	return true


# ----- FUNCTIONS -----


## This is the name of the file, call it how you want to (this ends with ".tres" extension, so dont add it) (default -> "Save")
func change_file_name(new_name : String) -> void:
	_system_file_name = new_name
	_update_file_path()
	_create_file(_file_path)


func change_slot(new_slot : int) -> void:
	_slot = new_slot
	_update_file_path()
	_create_file(_file_path)


func save_data(time_to_deferred : float = 0.5) -> Error:
	will_save_data.emit()
	await _time_deferred(time_to_deferred)
	var res : Error = await ResourceSaver.save( _resource, _file_path, true)
	return res



func load_data() -> void:
	if ResourceLoader.exists(_file_path):
		var updated_file : Resource = load(_file_path)
		_resource = updated_file
	load_data_done.emit()


func delete_data() -> Error: 
	var res : Error = Error.ERR_FILE_CANT_OPEN
	if ResourceLoader.exists(_file_path):
		var new_instance : SAVE = SAVE.new()
		_resource = new_instance
		res = await ResourceSaver.save(_resource, _file_path, true)
	return res



func create_new_temporal_data() -> void:
	var new_instance : SAVE = SAVE.new()
	_resource = new_instance


func set_data(data_key : String, data_value : Variant) -> void: 
	_resource.DATA[data_key] = data_value


func get_data(data_key : String , default_value : Variant = null) -> Variant: 
	var data_to_return : Variant = default_value
	if !_resource.DATA.has(data_key):
		set_data(data_key, data_to_return)
	data_to_return = _resource.DATA[data_key]
	return data_to_return


func get_all_data() -> Dictionary:
	return _resource.DATA
