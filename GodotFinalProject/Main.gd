extends Node2D

#Assumes the player is a 1v1 object

#Map dimensions
var map_width := 40
var map_height := 40

# Genetic algorithm parameters
var population_size := 10
var mutation_rate := 0.1
var generations := 100
var population := []

func _ready():
	var generated_individual: Array = create_individual()
	#Call update_tilemap() with the generated_individual
	
# Generate a completely random individual (map)
func create_individual() -> Array:
	var individual := []
	for y in range(map_height):
		var row := []
		for x in range(map_width):
			row.append(randi() % 2)  # 0 for grass, 1 for dirt
		individual.append(row)
	return individual

# Evaluate the fitness of an individual
func fitness(individual: Array) -> float:
	var dirt_count := 0
	for row in individual:
		dirt_count += row.count(1)
	#basically the percentage of dirt within the map (want to change)
	return float(dirt_count) / float(map_width * map_height)

# Select individuals for reproduction
func selection(population: Array) -> Array:
	# Your selection logic goes here
	return population

# Create new individuals through crossover
func crossover(parent1: Array, parent2: Array) -> Array:
	# Your crossover logic goes here
	return [parent1, parent2]

# Introduce small changes to an individual
func mutate(individual: Array):
	for y in range(map_height):
		for x in range(map_width):
			if randf() < mutation_rate:
				individual[y][x] = randi() % 2

func generate():
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

	# The best individual in the final population represents the solution
	var best_individual: Array = population[0]
	var best_fitness: float = fitness(population[0])

	for individual in population:
		var current_fitness = fitness(individual)
		if current_fitness > best_fitness:
			best_fitness = current_fitness
			best_individual = individual
			
	print("Best Individual: ", best_individual)
