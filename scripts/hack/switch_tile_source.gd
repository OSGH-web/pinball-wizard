@tool
extends EditorScript

func _run() -> void:
	var tileset = load("res://resources/tilesets/small_tileset_green.tres")
	var new_texture = load("res://assets/sprites/8_8_green_tileset.png")
	print(tileset)
	tileset.get_source(0).texture = new_texture

	# 2. Define the save path
	var save_path = "res://resources/tilesets/small_green_tileset_test.tres" 

	# 3. Save the resource
	var error = ResourceSaver.save(tileset, save_path)
	if error != OK:
		print("Error saving resource: ", error)
	else:
		print("Resource saved successfully to: ", save_path)
