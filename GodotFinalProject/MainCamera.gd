extends Camera2D

var speed = 200

func _process(delta):
	var movement = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		movement.x += 1
	if Input.is_action_pressed("ui_left"):
		movement.x -= 1
	if Input.is_action_pressed("ui_down"):
		movement.y += 1
	if Input.is_action_pressed("ui_up"):
		movement.y -= 1

	# Normalize the movement vector to ensure consistent speed in all directions
	movement = movement.normalized()

	# Move the camera
	position += movement * speed * delta
