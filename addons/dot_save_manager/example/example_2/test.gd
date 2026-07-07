extends Node

## type of values 
var nulo : Variant = null
var boolean : bool = true
var integer: int = 100
var flo :  float = 0.99
var string : String = "otra prueba"
var v2 : Vector2  = Vector2(0.1,0.2)
var v2i : Vector2i = Vector2i(1,2)
var v3 : Vector3 = Vector3 (0.1,0.2,0.3)
var v3i :Vector3i  = Vector3i (1,2,3)
var v4 :  Vector4= Vector4 (0.1,0.2,0.3,0.4)
var v4i :Vector4i  = Vector4i (1,2,3,4)
var color : Color = Color(0.773, 0.0, 0.0)
var res : Resource = preload("uid://dyjjpujltjiho")
var dict : Dictionary = {"a": "A", "b": 2}
var arr : Array = ["hello", "world", "form", "godot"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	DOT_save.set_value_data("nulo", nulo)
	DOT_save.set_value_data("boolean", boolean)
	DOT_save.set_value_data("integer", integer)
	DOT_save.set_value_data("flo", flo)
	DOT_save.set_value_data("string", string)
	DOT_save.set_value_data("v2", v2)
	DOT_save.set_value_data("v2i", v2i)
	DOT_save.set_value_data("v3", v3)
	DOT_save.set_value_data("v3i", v3i)
	DOT_save.set_value_data("v4", v4)
	DOT_save.set_value_data("v4i", v4i)
	DOT_save.set_value_data("color", color)
	DOT_save.set_value_data("res", res)
	DOT_save.set_value_data("dict", dict)
	DOT_save.set_value_data("arr", arr)
	await DOT_save.save_data()
	
	await get_tree().create_timer(1).timeout
	await DOT_save.load_data()
	nulo = DOT_save.get_value_data("nulo")
	boolean = DOT_save.get_value_data("boolean")
	integer = DOT_save.get_value_data("integer")
	flo = DOT_save.get_value_data("flo")
	string = DOT_save.get_value_data("string")
	v2 = DOT_save.get_value_data("v2")
	v2i = DOT_save.get_value_data("v2i")
	v3 = DOT_save.get_value_data("v3")
	v3i = DOT_save.get_value_data("v3i")
	v4 = DOT_save.get_value_data("v4")
	v4i = DOT_save.get_value_data("v4i")
	color = DOT_save.get_value_data("color") 
	res = DOT_save.get_value_data("res")
	dict = DOT_save.get_value_data("dict") 
	arr = DOT_save.get_value_data("arr") 
	
	#printt(
		#[nulo, typeof(nulo)],
		#[boolean, typeof(boolean)],
		#[integer, typeof(integer)],
		#[flo, typeof(flo)],
		#[string, typeof(string)],
		#[v2, typeof(v2)],
		#[v2i, typeof(v2i)],
		#[v3, typeof(v3)],
		#[v3i, typeof(v3i)],
		#[v4, typeof(v4)],
		#[v4i, typeof(v4i)],
		#[color, typeof(color)],
		#[res, typeof(res)],
		#[dict,typeof(dict)],
		#[arr,typeof(arr)],
	#)
	#DOT_save.delete_data()
