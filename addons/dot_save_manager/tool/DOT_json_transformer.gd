class_name JSON_TRANSFORMER


## transformer
static func transformer(data_dictionary : Dictionary) -> Dictionary:
	var d_to_return : Dictionary
	for key : String in data_dictionary:
		match typeof(data_dictionary[key]):
			TYPE_NIL: d_to_return[key] = [data_dictionary[key], TYPE_NIL] # null [null, 0]
			TYPE_BOOL:d_to_return[key] = [data_dictionary[key], TYPE_BOOL] #bool [true, 1]
			TYPE_INT: d_to_return[key] = [data_dictionary[key], TYPE_INT] #int [10, 2]
			TYPE_FLOAT: d_to_return[key] = [data_dictionary[key],  TYPE_FLOAT] #float [0.99, 3]
			TYPE_STRING: d_to_return[key] = [data_dictionary[key], TYPE_STRING ] #String ["word", 4]
			TYPE_VECTOR2: d_to_return[key] = vector_transformer(data_dictionary[key],2) #Vector2 [[x,y], 5]
			TYPE_VECTOR2I: d_to_return[key] = vector_transformer(data_dictionary[key],2) #Vector2i [[x,y], 6]
			TYPE_VECTOR3:d_to_return[key] = vector_transformer(data_dictionary[key],3) #Vector3 [[x,y,z], 9]
			TYPE_VECTOR3I: d_to_return[key] = vector_transformer(data_dictionary[key],3) #Vector3i [[x,y,z], 10]
			TYPE_VECTOR4: d_to_return[key] = vector_transformer(data_dictionary[key],4) #Vector4 [[x,y,z,w], 12]
			TYPE_VECTOR4I: d_to_return[key] = vector_transformer(data_dictionary[key],4) #Vector4i [[x,y,z,w], 13]
			TYPE_COLOR:  d_to_return[key] = color_transformer(data_dictionary[key]) #Color rgba [[r,g,b,a], 20]
			TYPE_OBJECT:  continue #Object [ res_path, 24]
			TYPE_DICTIONARY:  d_to_return[key] =[transformer(data_dictionary[key]), TYPE_DICTIONARY]  #Dictionary [{"string" : ["word", 4]}, 27 ]
			TYPE_ARRAY: d_to_return[key] = [array_transformer(data_dictionary[key]), TYPE_ARRAY] #Array [ [ ["word", 4],[true, 1] ] , 27 ]
			_: push_error("NOT SUPORTED - %s" %key) #typeof not suported
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


## parcer
static func parcer(value : Array) -> Variant: 
	var item_to_ret : Variant
	print(value)
	match int(value[1]):
		TYPE_STRING: item_to_ret = value[0]
	return item_to_ret


## saver and loader
static func SYS_SAVER(res : DOT_resource_save, path: String) -> void: 
	var transformed_dictionary : Dictionary = transformer(res.DATA)
	var file = FileAccess.open(path, FileAccess.WRITE)
	var json_string = JSON.stringify(transformed_dictionary, "\t")
	if file:
		file.store_string(json_string)
		file.close()
		print("¡Archivo JSON guardado exitosamente!" , path)
	else:
		print("Error al abrir el archivo.")


static func SYS_LOADER(res : DOT_resource_save, path: String) -> void: 
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var json_text = file.get_as_text()
		var loaded_data : Dictionary = JSON.parse_string(json_text)
		if loaded_data != null:
			res.DATA.merge(loaded_data)
			print("Datos cargados")
		else:
			print("Error al analizar el JSON.")
	else:
		print("No se encontró ningún archivo de guardado.")
