extends CharacterBody2D

const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_shielding: bool = false
var can_parry: bool = false

var start_x: float = 0.0
var block_penalty_speed: float = 100.0
var recovery_speed: float = 50.0

# --- NEW: Action States ---
var is_grappling: bool = false
var target_enemy = null

var is_dashing: bool = false
var dash_timer: float = 0.0

func _ready():
	add_to_group("player") # Now the enemy can find you!
	$Shield.hide()
	start_x = position.x 

func _physics_process(delta):
	# STATE 1: SLINGSHOT TOWARDS ENEMY
	if is_grappling:
		if is_instance_valid(target_enemy):
			# Calculate the exact angle to the enemy and fly there at 1500 speed!
			var direction = global_position.direction_to(target_enemy.global_position)
			velocity = direction * 1500
			move_and_slide()
			
			# If we get extremely close to the enemy (within 50 pixels), EXPLODE!
			if global_position.distance_to(target_enemy.global_position) < 50:
				trigger_explosion()
		else:
			is_grappling = false # Enemy died before we got there
		return # Skip the rest of the movement code while grappling

	# STATE 2: THE EXPLOSIVE BOOST
	if is_dashing:
		velocity.x = 1000 # Rocket straight forward
		velocity.y = 0    # Defy gravity
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		move_and_slide()
		return

	# STATE 3: NORMAL GRAVITY & DRIFT
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("shield"):
		is_shielding = true
		can_parry = true 
		$Shield.show()
		$ParryTimer.start() 
		
	if Input.is_action_just_released("shield"):
		is_shielding = false
		can_parry = false
		$Shield.hide()

	if is_shielding and not can_parry:
		velocity.x = -block_penalty_speed
	elif not is_shielding and position.x < start_x:
		velocity.x = recovery_speed
	else:
		velocity.x = 0
		position.x = start_x

	move_and_slide()
	
	if position.x < -400:
		die()

func die():
	get_tree().reload_current_scene()

func _on_parry_timer_timeout():
	can_parry = false 

func _on_shield_area_entered(area):
	if not is_shielding: return 
		
	if area.is_in_group("projectile"):
		if can_parry:
			# PERFECT PARRY! Lock on to the shooter and pull yourself!
			if is_instance_valid(area.shooter):
				target_enemy = area.shooter
				is_grappling = true
		area.queue_free() # Destroy the chain whether we parried it or just blocked it

# --- THE SCREEN WIPE EXPLOSION ---
func trigger_explosion():
	is_grappling = false
	is_dashing = true
	dash_timer = 0.3 # Boost straight forward for 0.3 seconds
	
	
	
	# Destroy EVERY enemy currently on the screen
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.queue_free()
		
	# Destroy EVERY other chain currently in the air
	var chains = get_tree().get_nodes_in_group("projectile")
	for chain in chains:
		chain.queue_free()
