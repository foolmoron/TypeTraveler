extends Node

signal seconds_updated(secs)
signal level_updated(level)
signal era_updated(era)

var audio_bus_index = 0
var audio_buses: Array

func _ready():
	randomize()
	audio_buses = $"../Main/Audios".get_children()
	gameover = false
	seconds = 0
	age_of_universe_secs = date_to_secs(13800000000, 1, 1, 0, 0, 0)
	era = 0
	secs_increment_base = 10
	level = 1
	start_secs = date_to_secs(2022, 9, 15, 12, 0, 0)
	lives = 5
	grace = true

var gameover = false

var grace = true

var seconds = 0
var age_of_universe_secs = date_to_secs(13800000000, 1, 1, 0, 0, 0)

var era = 0
const eras = [
	2022.705,
	2022,
	2000,
	0,
	-10_000,
	-10_000_000,
	-1_000_000_000,
	-20_000_000_000,
]

var secs_increment_base = 10
var level = 1
const max_level = 15

func boost_level():
	level += 1
	emit_signal("level_updated", level)

func drop_level():
	level -= 1
	emit_signal("level_updated", level)

func add_seconds():
	var prev = seconds
	seconds += int(pow(secs_increment_base, level) * rand_range(1.001, 1.004)) # tiny extra rand gives nicer scores at the end
	if seconds < prev:
		seconds = age_of_universe_secs
	seconds = min(seconds, age_of_universe_secs)
	emit_signal("seconds_updated", seconds)

	var years = float(start_secs - seconds) / 31104000
	var new_era = 0
	for i in eras.size():
		if years >= eras[i]:
			new_era = i
			break
	if new_era != era:
		era = new_era
		emit_signal("era_updated", era)


var start_secs = date_to_secs(2022, 9, 15, 12, 0, 0)

func date_to_secs(year: int, month: int, day: int, hour: int, minute: int, sec: int) -> int:
	return sec + minute * 60 + hour * 3600 + (day - 1) * 86400 + (month - 1) * 2592000 + year * 31104000

func secs_to_str(secs: int) -> String:
	secs = start_secs - secs
	if secs > 0:
		var years = secs / 31104000
		secs -= years * 31104000
		var months = secs / 2592000
		secs -= months * 2592000
		var days = secs / 86400
		secs -= days * 86400
		var hours = secs / 3600
		secs -= hours * 3600
		var minutes = secs / 60
		secs -= minutes * 60
		if years >= 2022 and (months + 1) >= 9 and (days + 1) >= 15:
			return "Today %0*d:%0*d:%0*d" % [2, hours, 2, minutes, 2, secs]
		elif years >= 2022 and (months + 1) >= 9 and (days + 1) >= 14:
			return "Yesterday %0*d:%0*d:%0*d" % [2, hours, 2, minutes, 2, secs]
		elif years >= 2000:
			return "%d-%0*d-%0*d" % [years, 2, months + 1, 2, days + 1]
		else:
			return "%d" % [years]
	else:
		var years: float = -secs / 31104000
		if years >= 10_000_000_000:
			var b = years / 1_000_000_000
			return "%.2fbil BC" % [b]
		elif years >= 100_000_000:
			var m = int(years / 1_000_000)
			if m > 1000:
				return "%d,%0*dmil BC" % [m / 1000, 3, m % 1000]
			else:
				return "%dmil BC" % [m]
		elif years >= 100_000:
			var k = int(years / 1_000)
			if k > 1000:
				return "%d,%0*dk BC" % [k / 1000, 3, k % 1000]
			else:
				return "%dk BC" % [k]
		else:
			var y = int(years)
			if y > 1000:
				return "%d,%0*d BC" % [y / 1000, 3, y % 1000]
			else:
				return "%d BC" % [y]

var lives = 5
func report_mistake():
	$"../Main/MistakeAudio".play()
	lives -= 1
	if lives > 0:
		$"../Main/TileContainer/MistakesLabel".text = "MISTAKES LEFT: %s" % [lives]
		$"../Main/TileContainer/MalfunctionAnim".play("Malfunction")
	else:
		var file = File.new()
		if not file.file_exists("user://highscore.dat"):
			file.open("user://highscore.dat", File.WRITE)
			file.store_64(0)
			file.close()
		file.open("user://highscore.dat", File.READ)
		var best = max(file.get_64(), seconds)
		file.close()
		file.open("user://highscore.dat", File.WRITE)
		file.store_64(best)
		file.close()
		$"../Main/TileContainer/Malfunction/Label".text = $"../Main/TileContainer/Malfunction/Label".text.replace("MALFUNCTION", "JOURNEY OVER")
		$"../Main/TileContainer/ScoreLabel".text = "Seconds lasted:\n%s\n\nBest seconds:\n%s\n\n\nPress ENTER to RESTART" % [with_commas(seconds), with_commas(best)]
		$"../Main/TileContainer/MalfunctionAnim".play("GameOver")
		gameover = true

func with_commas(n: int) -> String:
	if n == 0:
		return "0"
	var s = ""
	while n > 0:
		if (n / 1000) > 0:
			s = (",%0*d" % [3, n % 1000]) + s
		else:
			s = str(n % 1000) + s
		n /= 1000
	return s

func _input(evt):
	if gameover and evt is InputEventKey and evt.pressed and evt.scancode == KEY_ENTER:
		_ready()
		var _err = get_tree().reload_current_scene()
		return
