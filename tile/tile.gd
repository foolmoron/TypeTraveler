extends Node2D
class_name Tile

signal pressed(tile)

export(float, 0.0, 2.0) var move_to_target_time = 0.3
var target_y = 0

export(int, 0, 7) var lane = -1
export var is_next = false

func _ready():
	target_y = position.y

func _process(_delta):
	# particles on move
	$CPUParticles2D.modulate.a = lerp($CPUParticles2D.modulate.a, 1 if $Tween.is_active() else 0, 0.35)

	# dull when not active
	modulate.v = 1.0 if is_next else 0.65

func move_down_to(y):
	$Tween.interpolate_property(self, "position:y", null, y, move_to_target_time, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$Tween.start()

func _on_Button_pressed():
	if is_next:
		emit_signal("pressed", self)
