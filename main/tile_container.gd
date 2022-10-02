extends Node2D

export var lane_positions = [262, 337, 187, 412, 112, 487, 37, 562]
export(int, 2, 8) var lanes_active = 2
export var spacing_y = 125

export(int, 1, 5) var rand_decks = 3

export(int, 1, 30) var special_freq = 10
var _tiles_since_special = 0

export var frozen = false

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

const era_texts = [
	"Journey Beginnings",
	"Modern Era",
	"Information Era",
	"Agri-Industrial Era",
	"Ancient Era",
	"Prehistoric Era",
	"Genesis",
	"Cradle of Time",
]

func _ready():
	# init era
	var _err = GameManager.connect("era_updated", self, "_on_GameManager_era_updated")
	get_node("../EraLabel").text = era_texts[0]

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
	do_keys()

func do_keys():
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

	_tiles_since_special += 1
	if _tiles_since_special >= special_freq && GameManager.level < GameManager.max_level:
		_tiles_since_special = 0
		tile.is_special = true

	return tile

func _on_Tile_pressed(pressed_tile: Tile):
	if frozen:
		return

	if pressed_tile.is_special:
		GameManager.boost_level()
	else:
		GameManager.add_seconds()
	remove_tile(pressed_tile)

func remove_tile(tile: Tile):
	$Tiles.remove_child(tile)

	for i in $Tiles.get_child_count():
		var t = $Tiles.get_child($Tiles.get_child_count() - 1 - i)
		if t is Tile:
			t.move_down_to(-i * spacing_y)

	new_tile()

	var next_tile = $Tiles.get_child($Tiles.get_child_count() - 1) as Tile
	next_tile.is_next = true
	get_node("Key" + str(tile.lane)).modulate.v = 0.33
	get_node("Key" + str(next_tile.lane)).modulate.v = 1

func _input(evt):
	if frozen:
		return

	if evt is InputEventKey and evt.pressed:
		var next_tile = $Tiles.get_child($Tiles.get_child_count() - 1) as Tile
		if evt.scancode == keys[next_tile.lane]:
			next_tile._on_Button_pressed()
		elif evt.scancode in keys:
			GameManager.report_mistake()

func _on_GameManager_era_updated(era):
	lanes_active = 2 + era
	get_node("../EraLabel").text = era_texts[era]
	do_keys()