extends Node2D
class_name Target

enum TargetState { RAISED, LOWERED }

var state = TargetState.RAISED

@export var score_value = 500

signal target_is_hit

@export var is_stand_alone = false
			
func lower_target():
	if state == TargetState.LOWERED:
		return
	
	state = TargetState.LOWERED
	$AnimatedSprite2D.frame = 1
	
	$AudioStreamPlayer2D.play()

func raise_target():
	state = TargetState.RAISED
	$AnimatedSprite2D.frame = 0
