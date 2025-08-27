extends Label

const ANIMATION_RISE_HEIGHT = 10
const ANIMATION_DURATION = 0.35

func _ready():
	var item = get_canvas_item()
	RenderingServer.canvas_item_set_z_index(item, 3)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", position.y - ANIMATION_RISE_HEIGHT, ANIMATION_DURATION)
	await tween.finished
	queue_free()
