extends Node2D

export var spacing = 125


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var tilesPressed = 0

func _on_Tile_pressed(pressed_tile: Tile):
	tilesPressed += 1
	GameManager.add_seconds(int(pow(100, tilesPressed)))

	pressed_tile.get_parent().remove_child(pressed_tile)

	for tile in get_children():
		if tile is Tile:
			tile.move_down_by(spacing)
