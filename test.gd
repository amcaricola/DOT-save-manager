extends Node

## type of values 
#var integer: int = 100
#var flo :  float = 0.99
#var vec2 : Vector2 = Vector2(1,2)
#var boolean : bool = true
#@onready var res : Resource = preload("uid://cqwtro3nnfa1v")
var string : String = "otra prueba"
#var dic : Dictionary = {
	#"a" : "a",
	#"b" : "b"
	#}
#var data_json : String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DOT_save.debugging(true)
	await  get_tree().create_timer(0.5).timeout
	var new_string : String = DOT_save.get_value_data("string", "bad")
	print("test - ",new_string)
	
	DOT_save.set_value_data("string", string)
	await DOT_save.save_data()
	
	new_string = DOT_save.get_value_data("string")
	print(new_string)
	
	#var data : Dictionary = DOT_save.get_all_data_from_slot()
	#printt("DICTIONARY -> ", data)
	#for key : String in data :
		#verifier(key, data[key])
#
#
#func verifier(key : String,  data : Variant) -> void:
	#var STA : String 
	#match typeof(data):
		#TYPE_STRING: STA = simple_transform(key, data, TYPE_STRING)
		#TYPE_DICTIONARY:
			#for n_key : String in data:
				#verifier(n_key, data[n_key]) 
	#data_json = data_json + STA
	#print(data_json)
#
#func simple_transform(key : String, value : Variant, type : Variant.Type ) -> String:
	#var array_to_transform : Array = [key, value, type]
	#var string_to_return : String = JSON.stringify(array_to_transform)
	#return string_to_return
#
##func simple_reconvert (json_data : String)-> Dictionary: 
	##var dictionary_to_return: Dictionary = {}
	##var jobject : Variant = JSON.parse_string(json_data)
	##print(jobject)
	##match int(jobject[2]): 
		##TYPE_STRING:
			##var item : String = jobject[1]
			##dictionary_to_return[jobject[0]] = item 
		##TYPE_DICTIONARY:
			##var internal_dic : Dictionary = simple_reconvert(jobject[0])
			##dictionary_to_return[jobject[0]] = internal_dic
	##
	##
	##
	##print(dictionary_to_return)
	##return dictionary_to_return
