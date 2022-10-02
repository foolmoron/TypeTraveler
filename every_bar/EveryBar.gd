extends Control

export(float, 0.0, 20.0) var time_left_initial = 12.0
export(float, 0.0, 20.0) var time_left_final = 5.0
var time_left = 0.0
var max_time_left = 0.0

func _ready():
	var _err = GameManager.connect("level_updated", self, "_on_GameManager_level_updated")
	_on_GameManager_level_updated(GameManager.level)


func _process(delta):
	if not GameManager.gameover and GameManager.level > 1:
		time_left -= delta

	var time_left_perc = time_left / max_time_left
	$Color.rect_scale.x = time_left_perc

	if time_left_perc <= 0.4:
		if not $FlashAnim.is_playing():
			$FlashAnim.play("FlashBar")
	else:
		$FlashAnim.play("RESET")

	if time_left_perc < 0:
		GameManager.drop_level()


const level_texts = [
	"N/A",
	"Every 10 seconds",
	"Every 100 seconds (1.7 mins)",
	"Every 1000 seconds (16.7 mins)",
	"Every 10k seconds (2.8 hours)",
	"Every 100k seconds (1.2 days)",
	"Every 1000k seconds (11.6 days)",
	"Every 10mil seconds (116 days)",
	"Every 100mil seconds (3.2 years)",
	"Every 1000mil seconds (32 years)",
	"Every 10bil seconds (317 years)",
	"Every 100bil seconds (3171 years)",
	"Every 1000bil seconds (32k years)",
	"Every 10tril seconds (317k years)",
	"Every 100tril seconds (3171k years)",
	"Every 1000tril seconds (32m years)",
]

func _on_GameManager_level_updated(level):
	$Label.text = level_texts[level]
	max_time_left = lerp(time_left_initial, time_left_final,  float(GameManager.level) / GameManager.max_level)
	time_left = max_time_left
