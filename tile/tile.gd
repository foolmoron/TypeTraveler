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

	# disable button when not active
	$Container/Button.mouse_filter = Control.MOUSE_FILTER_STOP if is_next else Control.MOUSE_FILTER_IGNORE

	# special
	$Special.visible = is_special

func with_v(c: Color, v):
	c.v = v
	return c

func set_color(c: Color):
	c.v = 1
	VisualServer.set_default_clear_color(with_v(c, 0.13))
	$Container/Sprite.modulate = c
	$Container/Border.modulate = with_v(c, $Container/Border.modulate.v)
	$CPUParticles2D.modulate = c

func move_down_to(y):
	$Tween.interpolate_property(self, "position:y", null, y, move_to_target_time, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$Tween.start()

func _on_Button_pressed():
	if is_next:
		emit_signal("pressed", self)
