extends Area2D

# Variables to control the floating effect
var start_y: float = 0.0
var time_passed: float = 0.0


# How far up and down it moves (in pixels)
var float_amplitude: float = 50.0 
# How fast it moves up and down
var float_speed: float = 2.5 
# Tell the enemy exactly where to find the projectile scene
# (Double check that this path matches your folder structure!)
var projectile_scene = preload("res://characters/enemy/projectile.tscn")

func _ready():
	# Remember where we placed the enemy in the level before it starts moving
	start_y = position.y
	add_to_group("enemy") # Crucial for the explosion to find them later!

func _process(delta):
	# Keep track of how long the game has been running
	time_passed += delta
	
	# The Sine wave
	# We take the starting position, and add a smooth waving number to it.
	position.y = start_y + sin(time_passed * float_speed) * float_amplitude
	
# This triggers every time the ShootTimer reaches 0
func _on_shoot_timer_timeout():
	# 1. Look for the player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return # If the player is dead/missing, don't shoot!
		
	var player = players[0] # Grab the actual player node
	
	# 2. Create the chain
	var proj = projectile_scene.instantiate()
	proj.global_position = $SpawnPoint.global_position
	proj.shooter = self 
	
	# 3. Calculate the exact direction to the player
	var exact_direction = proj.global_position.direction_to(player.global_position)
	proj.direction = exact_direction
	
	# Optional: Rotate the tip of the hook to point at the player
	proj.rotation = exact_direction.angle()
	
	# 4. Fire!
	get_tree().current_scene.add_child(proj)
