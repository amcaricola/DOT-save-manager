class_name _json_transformer_DOT

## ---------------------------------------- transformer ----------------------------------------
static func transformer(data_dictionary : Dictionary) -> Dictionary:
	var d_to_return : Dictionary
	for key : String in data_dictionary:
		var value : Variant = data_dictionary[key]
		match typeof(data_dictionary[key]):
			TYPE_NIL: d_to_return[key] = [value, TYPE_NIL] # null [null, 0]
			TYPE_BOOL:d_to_return[key] = [value, TYPE_BOOL] #bool [true, 1]
			TYPE_INT: d_to_return[key] = [value, TYPE_INT] #int [10, 2]
			TYPE_FLOAT: d_to_return[key] = [value,  TYPE_FLOAT] #float [0.99, 3]
			TYPE_STRING: d_to_return[key] = [value, TYPE_STRING ] #String ["word", 4]
			TYPE_VECTOR2: d_to_return[key] = vector_transformer(value,2) #Vector2 [[x,y], 5]
			TYPE_VECTOR2I: d_to_return[key] = vector_transformer(value,2) #Vector2i [[x,y], 6]
			TYPE_VECTOR3:d_to_return[key] = vector_transformer(value,3) #Vector3 [[x,y,z], 9]
			TYPE_VECTOR3I: d_to_return[key] = vector_transformer(value,3) #Vector3i [[x,y,z], 10]
			TYPE_VECTOR4: d_to_return[key] = vector_transformer(value,4) #Vector4 [[x,y,z,w], 12]
			TYPE_VECTOR4I: d_to_return[key] = vector_transformer(value,4) #Vector4i [[x,y,z,w], 13]
			TYPE_COLOR:  d_to_return[key] = color_transformer(value) #Color rgba [[r,g,b,a], 20]
			TYPE_OBJECT:  d_to_return[key] = resource_transformer(value) #Object [ res_path, 24]
			TYPE_DICTIONARY:  d_to_return[key] =[transformer(value), TYPE_DICTIONARY]  #Dictionary [{"string" : ["word", 4]}, 27 ]
			TYPE_ARRAY: d_to_return[key] = [array_transformer(value), TYPE_ARRAY] #Array [ [ ["word", 4],[true, 1] ] , 27 ]
			_: push_error("NOT SUPORTED - %s - %s" %[key,value]) #typeof not suported
	return d_to_return

static func vector_transformer(value : Variant, vector_size : int) -> Array: 
	var arr_to_return : Array 
	match vector_size:
		2: arr_to_return = [value.x, value.y]
		3: arr_to_return = [value.x, value.y, value.z]
		4: arr_to_return  = [value.x, value.y, value.z, value.w]
	return [arr_to_return, typeof(value)]

static func color_transformer(value : Color) -> Array:
	return [ [value.r,value.g,value.b,value.a], typeof(value)]

static func array_transformer(arr :Array) -> Dictionary:
	var temp_dict : Dictionary
	for i :int in arr.size():
		temp_dict[str(i)] = arr[i]
	var dict_to_return : Dictionary = transformer(temp_dict)
	return dict_to_return 

static func resource_transformer(res: Resource) -> Array: 
		return [ res.resource_path, typeof(res)]


## ---------------------------------------- parser ----------------------------------------
static func parser(data_dictionary : Dictionary) -> Variant: 
	var d_to_return : Dictionary
	for key : String in data_dictionary:
		var value : Variant = data_dictionary[key][0]
		var type : Variant = data_dictionary[key][1]
		match int(type):
			TYPE_NIL: d_to_return[key] = null # null [null, 0]
			TYPE_BOOL:d_to_return[key] = value #bool [true, 1]
			TYPE_INT: d_to_return[key] = int(value) #int [10, 2]
			TYPE_FLOAT: d_to_return[key] = float(value) #float [0.99, 3]
			TYPE_STRING: d_to_return[key] = str(value) #String ["word", 4]
			TYPE_VECTOR2: d_to_return[key] =  Vector2(value[0],value[1]) #Vector2 [[x,y], 5]
			TYPE_VECTOR2I: d_to_return[key] =  Vector2i(value[0],value[1]) #Vector2i [[x,y], 6]
			TYPE_VECTOR3:d_to_return[key] = Vector3(value[0],value[1],value[2]) #Vector3 [[x,y,z], 9]
			TYPE_VECTOR3I: d_to_return[key] = Vector3i(value[0],value[1],value[2]) #Vector3i [[x,y,z], 10]
			TYPE_VECTOR4: d_to_return[key] = Vector4(value[0],value[1],value[2],value[3]) #Vector4 [[x,y,z,w], 12]
			TYPE_VECTOR4I: d_to_return[key] = Vector4i(value[0],value[1],value[2],value[3]) #Vector4i [[x,y,z,w], 13]
			TYPE_COLOR:  d_to_return[key] = Color(value[0],value[1],value[2],value[3]) #Color rgba [[r,g,b,a], 20]
			TYPE_OBJECT: d_to_return[key] = resource_parser(value) #Object [ res_path, 24]
			TYPE_DICTIONARY:  d_to_return[key] = parser(value)  #Dictionary [{"string" : ["word", 4]}, 27 ]
			TYPE_ARRAY: d_to_return[key] = array_parser(value) #Array [ [ ["word", 4],[true, 1] ] , 27 ]
			_: push_error("NOT SUPORTED - %s - %s" %[key,value]) #typeof not suported
	return d_to_return

static func array_parser(data : Dictionary) -> Array: 
	var arr_to_return : Array = []
	var dict : Dictionary = parser(data)
	for key : String in dict:
		arr_to_return.append(dict[key])
	return arr_to_return

static func resource_parser (path : String) -> Resource: 
	if path.contains("user://") and !_config_DOT.ALLOW_USER_RESOURCE: return null
	return load(path)


## ---------------------------------------- saver and loader ----------------------------------------
static func SYS_SAVER(res : _resource_save_DOT, path: String) -> Error: 
	var transformed_dictionary : Dictionary = transformer(res.DATA)
	var file : FileAccess 
	if _config_DOT.ENCRYPT: 
		file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, _config_DOT.ENCRYPTION_KEY)
	else : 
		file = FileAccess.open(path, FileAccess.WRITE)
	var json_string = JSON.stringify(transformed_dictionary, "\t")
	if file:
		file.store_string(json_string)
		file.close()
		return Error.OK
	else:
		return Error.FAILED


static func SYS_LOADER(res : _resource_save_DOT, path: String) -> Error: 
	if FileAccess.file_exists(path):
		var file : FileAccess 
		if _config_DOT.ENCRYPT: 
			file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, _config_DOT.ENCRYPTION_KEY)
		else : 
			file = FileAccess.open(path, FileAccess.READ)
		var json_text = file.get_as_text()
		var loaded_data : Dictionary = JSON.parse_string(json_text)
		var parsed_dictionary : Dictionary = parser(loaded_data)
		if !parsed_dictionary.is_empty():
			res.DATA.merge(parsed_dictionary, true)
			return Error.OK
		else:
			return Error.ERR_UNCONFIGURED
	else:
		return Error.FAILED
