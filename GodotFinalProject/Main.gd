extends Node2D

#Assumes the player is a 1v1 object

#Map dimensions
var map_width := 10
var map_height := 10

@onready var tilemap: TileMap = $TileMap

# Genetic algorithm parameters
var population_size := 15 #Number of individuals(maps) in each generation
var mutation_rate := 0.3 #10% of the time
var generations := 100 #Number of total generations
var population := []

func _ready():
	randomize() #Seed random generator for different values each time
	var generated_individual: Array = create_individual()
	tilemap.update_tilemap(generated_individual)
	generate() #Start the "natural selection" process
	
# Generate a completely random individual (map)
func create_individual() -> Array:
	var individual := []
	for y in range(map_height):
		var row := []
		for x in range(map_width):
			var val = randi() % 6
			if val > 0:
				row.append(0)  # 0 for grass, 1 for dirt
			else:
				row.append(1)
		individual.append(row)
	return individual

# Evaluate the fitness of an individual
func fitness(individual: Array) -> float:
	#Criteria for evaluting fitness:
	var total_fitness: float
	
	#Desnity of walls - 30% strength on end fitness score
	var dirt_count: int = 0
	for row in individual:
		dirt_count += row.count(1)  # Counts the dirt walls
	var dirt_density: float = dirt_count / pow(individual.size(), 2) #Percentage of dirt walls
	var dirt_fitness: float = 1.0 - dirt_density # % of total dirt cells
	
	#Connectivity: Maps with better paths between key points 70% strength on end fitness score
	# Find a random walkable point along the edge of the map
#	var start_point = find_random_edge_point(individual, 0)
#
#	# Find a random walkable point on the opposite edge of the map
#	var end_point = find_random_opposite_edge_point(individual, 0, start_point)
#
#	# Calculate the distance between the two points using A*
#	var distance = find_path(individual, start_point, end_point)
#
#	#Calculate fitness score for connectivity
#	var distance_fitness: float
#	var threshold_distance: float = sqrt(pow(map_width, 2) + pow(map_height, 2)) * 2
#	var max_pos_distance: float = (map_width * map_height) - 1
#	if distance == -1.0:
#		distance_fitness = 0
#	else:
#		distance_fitness = max_pos_distance / distance
#		if distance > threshold_distance: #We are traveling to far (not good)
#			distance_fitness /= 2
#
#	# Return a fitness value based on the distance
#	total_fitness = (dirt_fitness * 0.3) + (distance_fitness * 0.7)
	
	return dirt_fitness
	
# A* pathfinding algorithm for finding distance between two points on the map using a 2D array
func find_path(map: Array, start: Vector2, end: Vector2) -> float:
	var open_set: Array = [start]
	var came_from: Dictionary = {}
	var g_score: Dictionary = {start: 0}
	var f_score: Dictionary = {start: start.distance_to(end)}
	
	while open_set.size() > 0:
		var current: Vector2 = get_lowest_f_score(open_set, f_score)
		if current == end:
			return g_score[current]
			
		open_set.erase(current)
		
		for neighbor in get_neighbors(current, map):
			var tentative_g_score = g_score.get(current, float("inf")) + current.distance_to(neighbor)
			if tentative_g_score < g_score.get(neighbor, float("inf")):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g_score
				f_score[neighbor] = tentative_g_score + neighbor.distance_to(end)
				
				if not open_set.has(neighbor):
					open_set.append(neighbor)
					
	return -1.0  # Path not found

# Helper function to get the neighbor points
func get_neighbors(point: Vector2, map: Array) -> Array:
	var neighbors: Array = []
	var directions: Array = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
	
	for dir in directions:
		var neighbor = point + dir
		if is_valid(neighbor, map):
			neighbors.append(neighbor)
			
	return neighbors

# Helper function to check if a point is valid on the map
func is_valid(point: Vector2, map: Array) -> bool:
	return point.x >= 0 and point.x < map[0].size() and point.y >= 0 and point.y < map.size()

# Helper function to get the point with the lowest f_score
func get_lowest_f_score(open_set: Array, f_score: Dictionary) -> Vector2:
	var lowest_score = float("inf")
	var lowest_point: Vector2
	
	for point in open_set:
		if f_score[point] < lowest_score:
			lowest_score = f_score[point]
			lowest_point = point
			
	return lowest_point

func find_random_edge_point(map: Array, value: int) -> Vector2:
	var edge_points: Array = []
	
	for x in range(map[0].size()):
		if map[0][x] == value:
			edge_points.append(Vector2(x, 0))
		if map[map.size() - 1][x] == value:
			edge_points.append(Vector2(x, map.size() - 1))
			
	for y in range(map.size()):
		if map[y][0] == value:
			edge_points.append(Vector2(0, y))
		if map[y][map[0].size() - 1] == value:
			edge_points.append(Vector2(map[0].size() - 1, y))
			
	return edge_points[randi() % edge_points.size()]
	
func find_random_opposite_edge_point(map: Array, value: int, start_point: Vector2) -> Vector2:
	var opposite_edge_points: Array = []
	
	for x in range(map[0].size()):
		if map[0][x] == value and Vector2(x, 0) != start_point:
			opposite_edge_points.append(Vector2(x, 0))
		if map[map.size() - 1][x] == value and Vector2(x, map.size() - 1) != start_point:
			opposite_edge_points.append(Vector2(x, map.size() - 1))
			
	for y in range(map.size()):
		if map[y][0] == value and Vector2(0, y) != start_point:
			opposite_edge_points.append(Vector2(0, y))
		if map[y][map[0].size() - 1] == value and Vector2(map[0].size() - 1, y) != start_point:
			opposite_edge_points.append(Vector2(map[0].size() - 1, y))
			
	return opposite_edge_points[randi() % opposite_edge_points.size()]
	
# Select individuals for reproduction
func selection(population: Array) -> Array:
	print("Selecting individuals...")
	var selected_population: Array = []
	var total_fitness: float = 0.0
	
	# Calculate the total fitness of the population
	for individual in population:
		total_fitness += fitness(individual)
		
	# Select individuals based on their fitness (roulette wheel selection)
	while selected_population.size() < population_size:
		var random_value: float = randf() * total_fitness
		var cumulative_fitness: float = 0.0
		
		for individual in population:
			cumulative_fitness += fitness(individual)
			if cumulative_fitness >= random_value:
				selected_population.append(individual)
				break
				
	return selected_population

# Create new individuals through crossover
func crossover(parent1: Array, parent2: Array) -> Array:
	print("Crossover...")
	#Strategy 1: We pick a random array subset(region) of the parents that is (region_percentage % of total map) than swap those regions.
	#Thus creating new offsprings
#	var offspring: Array = []
#	var region_percentage: float = 0.15
#
#	# Determine the size of the subset to be swapped (around 15% of the total size)
#	var subset_size: int = int(map_height * map_width * region_percentage)
#
#	# Choose a random starting point for the subset in both parents
#	var start_point_parent1: Vector2 = Vector2(randi() % (map_width - subset_size + 1), randi() % (map_height - subset_size + 1))
#	var start_point_parent2: Vector2 = Vector2(randi() % (map_width - subset_size + 1), randi() % (map_height - subset_size + 1))
#
#	# Create offspring by swapping subsets between parents
#	var child1: Array = parent1.duplicate(true)
#	var child2: Array = parent2.duplicate(true)
#
#	for y in range(start_point_parent1.y, start_point_parent1.y + subset_size):
#		for x in range(start_point_parent1.x, start_point_parent1.x + subset_size):
#			child1[y][x] = parent2[y + start_point_parent2.y][x + start_point_parent2.x].copy()
#
#	for y in range(start_point_parent2.y, start_point_parent2.y + subset_size):
#		for x in range(start_point_parent2.x, start_point_parent2.x + subset_size):
#			child2[y][x] = parent1[y + start_point_parent1.y][x + start_point_parent1.x].copy()
#
#	offspring.append(child1)
#	offspring.append(child2)

#	var offspring: Array = []
#	var child1: Array = parent1.duplicate(true)
#	var child2: Array = parent2.duplicate(true)
#
#	# Select two random points in each array
#	var point1_parent1: Vector2 = Vector2(randi_range(0, parent1[0].size() - 1), randi_range(0, parent1.size() - 1))
#	var point2_parent1: Vector2 = Vector2(randi_range(0, parent1[0].size() - 1), randi_range(0, parent1.size() - 1))
#
#	var point1_parent2: Vector2 = Vector2(randi_range(0, parent2[0].size() - 1), randi_range(0, parent2.size() - 1))
#	var point2_parent2: Vector2 = Vector2(randi_range(0, parent2[0].size() - 1), randi_range(0, parent2.size() - 1))
#
#	# Swap values at the selected points for child1
#	var temp_value: int = child1[point1_parent1.y][point1_parent1.x]
#	child1[point1_parent1.y][point1_parent1.x] = parent2[point1_parent2.y][point1_parent2.x]
#	parent2[point1_parent2.y][point1_parent2.x] = temp_value
#
#	temp_value = child1[point2_parent1.y][point2_parent1.x]
#	child1[point2_parent1.y][point2_parent1.x] = parent2[point2_parent2.y][point2_parent2.x]
#	parent2[point2_parent2.y][point2_parent2.x] = temp_value
#
#	# Swap values at the selected points for child2
#	temp_value = child2[point1_parent2.y][point1_parent2.x]
#	child2[point1_parent2.y][point1_parent2.x] = parent1[point1_parent1.y][point1_parent1.x]
#	parent1[point1_parent1.y][point1_parent1.x] = temp_value
#
#	temp_value = child2[point2_parent2.y][point2_parent2.x]
#	child2[point2_parent2.y][point2_parent2.x] = parent1[point2_parent1.y][point2_parent1.x]
#	parent1[point2_parent1.y][point2_parent1.x] = temp_value

	var offspring: Array = []
	var child1: Array = parent1.duplicate(true)
	var child2: Array = parent2.duplicate(true)
	
	# Select two random rows in each array
	var row1_parent1: int = randi_range(0, parent1.size() - 1)
	var row2_parent1: int = randi_range(0, parent1.size() - 1)
	
	var row1_parent2: int = randi_range(0, parent2.size() - 1)
	var row2_parent2: int = randi_range(0, parent2.size() - 1)
	
	# Swap entire rows for child1
	child1[row1_parent1] = parent2[row1_parent2].duplicate(true)
	child1[row2_parent1] = parent2[row2_parent2].duplicate(true)
	
	# Swap entire rows for child2
	child2[row1_parent2] = parent1[row1_parent1].duplicate(true)
	child2[row2_parent2] = parent1[row2_parent1].duplicate(true)
	
	offspring.append(child1)
	offspring.append(child2)
	
	return offspring

#Introduce small changes to an individual to maintain diversity
func mutate(individual: Array):
	print("Mutating...")
	#Strategy 1: Random cell changes based on mutate rate
	#Each map cell has a (mutation_rate) % chance to "mutate" into another random value
	for y in range(map_height):
		for x in range(map_width):
			if randf() < mutation_rate:
				individual[y][x] = randi() % 2
	#Strategy 2: Array mirroring
	# Manually mirror the array horizontally
	for i in range(individual.size()):
		individual[i].reverse()

func generate():
	print("Generating...")
	# Initialize the population
	for x in range(population_size):
		population.append(create_individual())

	# Main loop for the genetic algorithm
	for generation in range(generations):
		# Evaluate the fitness of each individual in the population
		var fitness_scores := []
		for individual in population:
			fitness_scores.append(fitness(individual))

		# Select individuals for reproduction
		var selected_population := selection(population)

		# Create new individuals through crossover
		var offspring := []
		for i in range(0, population_size, 2):
			var parent1: Array = selected_population[randi() % selected_population.size()]
			var parent2: Array = selected_population[randi() % selected_population.size()]
			offspring += crossover(parent1, parent2)

		# Apply mutation to the offspring
		for individual in offspring:
			if randf() < mutation_rate:
				mutate(individual)

		# Replace the old population with the combined population of parents and offspring
		population = selected_population + offspring

		# Print the best individual's fitness in this generation
		var best_fitness: float = fitness_scores.max()
		print("Generation ", generation + 1, ", Best Fitness: ", best_fitness)
		tilemap.update_tilemap(population[0])
		await get_tree().create_timer(0.3).timeout

	# The best individual in the final population represents the solution
	var best_individual: Array = population[0]
	var best_fitness: float = fitness(population[0])

	for individual in population:
		var current_fitness = fitness(individual)
		if current_fitness > best_fitness:
			best_fitness = current_fitness
			best_individual = individual
			
	print("Best Individual: ", best_individual)
