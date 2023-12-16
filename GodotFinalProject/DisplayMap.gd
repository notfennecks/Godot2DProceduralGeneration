extends TileMap

func _ready():
	pass

# Update the TileMap based on the individual's map
func update_tilemap(individual: Array):
	print("Updating tilemap...")
	for y in range(individual.size()):
		for x in range(individual[0].size()):
			var tile_index = individual[y][x]
			#print("Setting: ", tile_index, " block at x: ", x, " y: ", y) #Solely used for debugging set_cell()
			match tile_index:
				0: #Grass block (walkable)
					set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
				1: #Dirt block (wall)
					set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0))
				3: #Water block (walkable: slowed movement)
					break
				4: #Gravel block (walkable: show main paths)
					break
				5: #Rock block (wall: decoration)
					break
				_:
					#Nothing matches
					print("invalid tile index number")
