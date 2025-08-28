extends Resource

class_name HighScore

@export var name: String:
	set(_name):
		name = _name.substr(0, 3)
@export var score: int
