extends TileMap

func _ready():
	randomize()
	var map: Array = []
	for y in range(40):
		var row: Array = []
		for x in range(40):
			row.append(randi() % 2)
		map.append(row)
	update_tilemap(map)

# Update the TileMap based on the individual's map
func update_tilemap(individual: Array):
	print("Updating tilemap...")
	for y in range(40):
		for x in range(40):
			var tile_index = individual[y][x]
			#Sets grass block
			print("Setting: ", tile_index, " block at x: ", y, " y: ", x)
			match tile_index:
				0: #Grass block
					set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
				1: #Dirt block
					set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0))
				3: #Water block
					break
				4: #Gravel block
					break
				5: #Rock block
					break
				_:
					#Nothing matches
					print("invalid tile index number")
