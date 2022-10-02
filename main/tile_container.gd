extends Node2D

export var lane_positions = [262, 337, 187, 412, 112, 487, 37, 562]
export(int, 2, 8) var lanes_active = 2
export var spacing_y = 125

export(int, 1, 5) var rand_decks = 3

const keys = [KEY_F, KEY_J]

const next_key_map = {
	KEY_F: [KEY_E, KEY_C],
	KEY_C: [KEY_X, KEY_S],
	KEY_E: [KEY_W, KEY_S],
	KEY_X: [KEY_A],
	KEY_W: [KEY_A, KEY_Q],
	KEY_S: [KEY_Q, KEY_Z],
	KEY_J: [KEY_M, KEY_I],
	KEY_M: [KEY_K, KEY_L],
	KEY_I: [KEY_O, KEY_L],
	KEY_K: [KEY_O, KEY_L],
	KEY_L: [KEY_P],
	KEY_O: [KEY_P],
}

func _ready():
	# init tiles
	for _i in range(8):
		new_tile()
	var next_tile = $Tiles.get_child($Tiles.get_child_count() - 1) as Tile
	next_tile.is_next = true

	# init keys
	for i in range(8):
		var key = get_node("Key" + str(i))
		key.text = OS.get_scancode_string(keys[i]) if  i < keys.size() else ""
		key.modulate.v = 0.33
	get_node("Key" + str(next_tile.lane)).modulate.v = 1
	while keys.size() < lanes_active:
		var prev_key = keys[keys.size() - 2]
		var next_keys = next_key_map[prev_key]
		var next_key = next_keys[randi() % next_keys.size()]
		get_node("Key" + str(keys.size())).text = OS.get_scancode_string(next_key)
		keys.append(next_key)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var _rand_deck: Array = []
func _get_rand():
	if _rand_deck.empty():
		for _i in range(rand_decks):
			for x in range(lanes_active):
				_rand_deck.append(x)
		_rand_deck.shuffle()
	return _rand_deck.pop_back()

const TileScn = preload('res://tile/tile.tscn')

func new_tile():
	var tile = TileScn.instance()
	var spawn_y = -spacing_y * $Tiles.get_children().size()
	var lane = randi() % lanes_active
	tile.position = Vector2(lane_positions[lane], spawn_y)
	tile.lane = lane
	var _err = tile.connect("pressed", self, "_on_Tile_pressed")
	$Tiles.add_child(tile)
	$Tiles.move_child(tile, 0)

var _tilesPressed = 0

func _on_Tile_pressed(pressed_tile: Tile):
	_tilesPressed += 1
	GameManager.add_seconds(int(pow(10, _tilesPressed)))

	$Tiles.remove_child(pressed_tile)

	for i in $Tiles.get_child_count():
		var t =  $Tiles.get_child_count() - 1 - i
		var tile = $Tiles.get_child(t)
		if tile is Tile:
			tile.move_down_to(-i * spacing_y)

	new_tile()

	var next_tile = $Tiles.get_child($Tiles.get_child_count() - 1) as Tile
	next_tile.is_next = true
	get_node("Key" + str(pressed_tile.lane)).modulate.v = 0.33
	get_node("Key" + str(next_tile.lane)).modulate.v = 1

func _input(evt):
	if evt is InputEventKey and evt.pressed:
		var next_tile = $Tiles.get_child($Tiles.get_child_count() - 1) as Tile
		if evt.scancode == keys[next_tile.lane]:
			next_tile._on_Button_pressed()
		elif evt.scancode in keys:
			GameManager.report_mistake()
