extends Node2D
class_name Tile

signal pressed(tile)

export(float, 0.0, 2.0) var move_to_target_time = 0.3
var target_y = 0

export(int, 0, 7) var lane = -1
export var is_next = false
export var is_special = false

func _ready():
	target_y = position.y
	$SpecialAnim.play("10x")

func _process(_delta):
	# particles on move
	$CPUParticles2D.modulate.a = lerp($CPUParticles2D.modulate.a, 1 if $Tween.is_active() else 0, 0.35)

	# dull when not active
	modulate.v = 1.0 if is_next else 0.65

	# special
	$Special.visible = is_special

func set_color(c: Color):
	c.v = 1
	$Container/Sprite.modulate = c
	var prev_v = $Container/Border.modulate.v
	$Container/Border.modulate = c
	$Container/Border.modulate.v = prev_v
	$CPUParticles2D.modulate = c

func move_down_to(y):
	$Tween.interpolate_property(self, "position:y", null, y, move_to_target_time, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$Tween.start()

func _on_Button_pressed():
	if is_next:
		emit_signal("pressed", self)
