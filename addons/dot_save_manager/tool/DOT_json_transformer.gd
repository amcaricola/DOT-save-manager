class_name JSON_TRANSFORMER

static func stringify(value : Variant) -> Array: 
	var arr_to_ret : Array 
	match typeof(value):
		TYPE_STRING: arr_to_ret = [ str(value) , typeof(value)]
	return arr_to_ret
	

static func parcer(value : Array) -> Variant: 
	var item_to_ret : Variant
	print(value)
	match value[1]:
		TYPE_STRING: item_to_ret = value[0]
	return item_to_ret


static func SYS_SAVER(res : DOT_resource_save, path: String) -> void: 
	var file = FileAccess.open(path, FileAccess.WRITE)
	var json_string = JSON.stringify(res.DATA, "\t")
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
		
		# Analiza el string de texto para convertirlo nuevamente en un diccionario de Godot
		var loaded_data = JSON.parse_string(json_text)
		
		if loaded_data != null:
			res.DATA = loaded_data
			print("Datos cargados:")
			# Ahora puedes acceder a tus datos, ej: loaded_data["health"]
		else:
			print("Error al analizar el JSON.")
	else:
		print("No se encontró ningún archivo de guardado.")
