extends Label

func _ready():
	var _err = GameManager.connect("seconds_updated", self, "_on_GameManager_seconds_updated")
	_on_GameManager_seconds_updated(GameManager.seconds)

func _on_GameManager_seconds_updated(secs):
	text = GameManager.secs_to_str(secs)
