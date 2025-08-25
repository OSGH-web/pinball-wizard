extends Node2D
class_name RolloverButton


enum RolloverButtonState { UNSET, SET }

var state = RolloverButtonState.UNSET



func _on_body_entered(body: Node2D) -> void:
	if state == RolloverButtonState.UNSET:
		set_rolloverbutton()


func reset_rolloverbutton():
	state = RolloverButtonState.UNSET
	$AnimatedSprite2D.frame = 0
	
	
func set_rolloverbutton():
	state = RolloverButtonState.SET
	$AnimatedSprite2D.frame = 1
