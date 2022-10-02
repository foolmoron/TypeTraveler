extends Node2D
class_name Tile

signal pressed(tile)

export(float, 0.0, 2.0) var move_to_target_time = 0.3
var target_y = 0

export(int, 0, 7) var lane = -1
export var is_next = false
export var is_special = false
export var era = -1

const era_colors = [
	Color.deepskyblue,
	Color.hotpink,
	Color.mediumspringgreen,
	Color.olive,
	Color.goldenrod,
	Color.firebrick,
	Color.floralwhite,
	Color.indigo,
]

var era_sounds = [
	[
		null,
		null,
		null,
		load("res://sounds/beg4.wav"),
		load("res://sounds/beg5.wav"),
		null,
		null,
		null,
	],
	[
		null,
		null,
		load("res://sounds/mod3.wav"),
		load("res://sounds/mod4.wav"),
		load("res://sounds/mod5.wav"),
		null,
		null,
		null,
	],
	[
		null,
		null,
		load("res://sounds/info3.wav"),
		load("res://sounds/info4.wav"),
		load("res://sounds/info5.wav"),
		load("res://sounds/info6.wav"),
		null,
		null,
	],
	[
		null,
		load("res://sounds/agri2.wav"),
		load("res://sounds/agri3.wav"),
		load("res://sounds/agri4.wav"),
		load("res://sounds/agri5.wav"),
		load("res://sounds/agri6.wav"),
		null,
		null,
	],
	[
		null,
		load("res://sounds/anc2.wav"),
		load("res://sounds/anc3.wav"),
		load("res://sounds/anc4.wav"),
		load("res://sounds/anc5.wav"),
		load("res://sounds/anc6.wav"),
		load("res://sounds/anc7.wav"),
		null,
	],
	[
		load("res://sounds/pre1.wav"),
		load("res://sounds/pre2.wav"),
		load("res://sounds/pre3.wav"),
		load("res://sounds/pre4.wav"),
		load("res://sounds/pre5.wav"),
		load("res://sounds/pre6.wav"),
		load("res://sounds/pre7.wav"),
		null,
	],
	[
		load("res://sounds/gen1.wav"),
		load("res://sounds/gen2.wav"),
		load("res://sounds/gen3.wav"),
		load("res://sounds/gen4.wav"),
		load("res://sounds/gen5.wav"),
		load("res://sounds/gen6.wav"),
		load("res://sounds/gen7.wav"),
		load("res://sounds/gen8.wav"),
	],
	[
		load("res://sounds/time1.wav"),
		load("res://sounds/time2.wav"),
		load("res://sounds/time3.wav"),
		load("res://sounds/time4.wav"),
		load("res://sounds/time5.wav"),
		load("res://sounds/time6.wav"),
		load("res://sounds/time7.wav"),
		load("res://sounds/time8.wav"),
	],
]

func _ready():
	target_y = position.y
	$SpecialAnim.play("10x")

	# era
	era = GameManager.era
	var c = era_colors[era]
	c.v = 1
	VisualServer.set_default_clear_color(with_v(c, 0.13))
	$Container/Sprite.modulate = c
	$Container/Border.modulate = with_v(c, $Container/Border.modulate.v)
	$CPUParticles2D.modulate = c

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
		GameManager.grace = false
		var index = {
			6:0,
			4:1,
			2:2,
			0:3,
			1:4,
			3:5,
			5:6,
			7:7,
		}[lane]
		var sound = era_sounds[era][index]
		GameManager.play_sound(sound)

