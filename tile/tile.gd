extends Node2D
class_name Tile

signal pressed(tile)

export(float, 0.0, 2.0) var move_to_target_time = 0.3
var target_y = 0

func _ready():
	target_y = position.y

# func _process(delta):
# 	pass

func move_down_by(amount):
	$Tween.interpolate_property(self, "position:y", null, position.y + amount, move_to_target_time, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$Tween.start()

func _on_Button_pressed():
	emit_signal("pressed", self)
