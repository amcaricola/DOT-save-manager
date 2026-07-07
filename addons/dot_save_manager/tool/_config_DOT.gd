@tool
extends Node
class_name _config_DOT

## Use "res://" in the file route, for debug or develop (default FALSE) 
var DEBUG : bool = true
## File name in the system ejp: "user://Save_0.json"  (default Save) 
var FILE_NAME : String = "Save"
## for encrypting the json File (default FALSE) 
var ENCRYPT : bool = false
var ENCRYPTION_KEY : String = "json_transformer_key"
## support load resource form "user://" folder, use it with care (default FALSE) 
var ALLOW_USER_RESOURCE : bool = false

# -- UI ---
## coment
@onready var check_debug: CheckBox = %check_debug
@onready var line_file_name: LineEdit = %line_file_name
@onready var check_encrypt: CheckBox = %check_encrypt
@onready var line_encrypt_key: LineEdit = %line_encrypt_key
@onready var check_allow_user_res: CheckBox = %check_allow_user_res
@onready var apply_button: Button = %Apply_button

static var system_config_file_path : String = "res://addons/dot_save_manager/tool/_config_DOT.cfg"
var _config_cfg : ConfigFile

# -- functions ---
func _ready() -> void:
	_config_cfg = ConfigFile.new()
	_load_config_resource()
	_get_cofig_into_vars()
	_set_var_into_panel()
	apply_button.pressed.connect(_save_changes)

func _load_config_resource() -> void: 
	var error = _config_cfg.load(system_config_file_path)
	if error != OK or !_config_cfg.get_value("DATA", "CREATED", false):
		_save_config_resource()


func _save_config_resource() -> void:
	_config_cfg.set_value("DATA","CREATED", true)
	_config_cfg.set_value("DATA","DEBUG", DEBUG)
	_config_cfg.set_value("DATA","FILE_NAME", FILE_NAME)
	_config_cfg.set_value("DATA","ENCRYPT", ENCRYPT)
	_config_cfg.set_value("DATA","ENCRYPTION_KEY", ENCRYPTION_KEY)
	_config_cfg.set_value("DATA","ALLOW_USER_RESOURCE", ALLOW_USER_RESOURCE)
	_config_cfg.save(system_config_file_path)


func _get_cofig_into_vars() -> void: 
	DEBUG = _config_cfg.get_value("DATA", "DEBUG", DEBUG)
	FILE_NAME = _config_cfg.get_value("DATA", "FILE_NAME", FILE_NAME)
	ENCRYPT = _config_cfg.get_value("DATA", "ENCRYPT", ENCRYPT)
	ENCRYPTION_KEY = _config_cfg.get_value("DATA", "ENCRYPTION_KEY", ENCRYPTION_KEY)
	ALLOW_USER_RESOURCE = _config_cfg.get_value("DATA", "ALLOW_USER_RESOURCE", ALLOW_USER_RESOURCE)
	pass


func _set_var_into_panel()-> void: 
	check_debug.button_pressed = DEBUG
	line_file_name.text = FILE_NAME
	check_encrypt.button_pressed = ENCRYPT
	line_encrypt_key.text = ENCRYPTION_KEY
	check_allow_user_res.button_pressed = ALLOW_USER_RESOURCE
	

func _save_changes() -> void:
	DEBUG = check_debug.button_pressed
	FILE_NAME = line_file_name.text
	ENCRYPT = check_encrypt.button_pressed
	ENCRYPTION_KEY = line_encrypt_key.text
	ALLOW_USER_RESOURCE = check_allow_user_res.button_pressed
	_save_config_resource()
	print("DOT_save - Changes applied")
