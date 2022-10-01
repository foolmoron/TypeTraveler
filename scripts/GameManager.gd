extends Node

signal seconds_updated(secs)

var seconds = 0

func add_seconds(secs: int):
	seconds += secs
	emit_signal("seconds_updated", seconds)

var start_secs = date_to_secs(2022, 9, 15, 0, 0, 0)

func date_to_secs(year: int, month: int, day: int, hour: int, minute: int, sec: int) -> int:
	return sec + minute * 60 + hour * 3600 + day * 86400 + month * 2592000 + year * 31104000

func secs_to_str(secs: int) -> String:
	secs = start_secs - secs
	if secs > 0:
		var years = secs / 31104000
		if years >= 2000:
			secs -= years * 31104000
			var months = secs / 2592000
			secs -= months * 2592000
			var days = secs / 86400
			secs -= days * 86400
			var hours = secs / 3600
			secs -= hours * 3600
			var minutes = secs / 60
			secs -= minutes * 60
			return "%d-%0*d-%0*d %0*d:%0*d:%0*d" % [years, 2, months, 2, days, 2, hours, 2, minutes, 2, secs]
		else:
			return "%d AD" % [years]
	else:
		var years = -secs / 31104000
		if years >= 10_000_000_000:
			var k = years / 10_000_000_000
			return "%dbil BC" % [k]
		elif years >= 10_000_000:
			var k = years / 10_000_000
			return "%dmil BC" % [k]
		elif years >= 10_000:
			var k = years / 1_000
			return "%dk BC" % [k]
		else:
			return "%d BC" % [years]
