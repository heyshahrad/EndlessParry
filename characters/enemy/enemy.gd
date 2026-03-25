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

func _process(delta):
	# Keep track of how long the game has been running
	time_passed += delta
	
	# The Sine wave magic! 
	# We take the starting position, and add a smooth waving number to it.
	position.y = start_y + sin(time_passed * float_speed) * float_amplitude
	
# This triggers every time the ShootTimer reaches 0
func _on_shoot_timer_timeout():
	# 1. Create a new copy of the projectile
	var proj = projectile_scene.instantiate()	
	# 2. Move the new projectile to exactly where the SpawnPoint is
	proj.global_position = $SpawnPoint.global_position
	
	# 3. Add the projectile to the main game world so it actually appears
	get_tree().current_scene.add_child(proj)
