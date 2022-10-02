extends Node

signal seconds_updated(secs)

func _ready():
	randomize()

var seconds = 0
var secs_increment = 10
var age_of_universe_secs = date_to_secs(13800000000, 1, 1, 0, 0, 0)

func boost_increment():
	secs_increment *= 10

func add_seconds():
	var prev = seconds
	seconds += secs_increment
	if seconds < prev:
		seconds = age_of_universe_secs
	seconds = min(seconds, age_of_universe_secs)
	emit_signal("seconds_updated", seconds)

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
			return "Today @ %0*d:%0*d:%0*d" % [2, hours, 2, minutes, 2, secs]
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

export(int, 1, 20) var lives = 5
func report_mistake():
	lives -= 1
	print("Player made mistake! Lives left: %s" % [lives])
