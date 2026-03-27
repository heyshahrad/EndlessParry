extends CharacterBody2D

const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Shield Variables
var is_shielding: bool = false
var can_parry: bool = false

# --- NEW: Drift and Penalty Variables ---
var start_x: float = 0.0
var block_penalty_speed: float = 200.0 # How fast you get pushed left
var recovery_speed: float = 50.0       # How fast you run back to the right

func _ready():
	$Shield.hide()
	# Remember exactly where the player starts on the screen!
	start_x = position.x 

func _physics_process(delta):
	# --- GRAVITY & JUMPING ---
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# --- SHIELD INPUT ---
	if Input.is_action_just_pressed("shield"):
		is_shielding = true
		can_parry = true 
		$Shield.show()
		$ParryTimer.start() 
		
	if Input.is_action_just_released("shield"):
		is_shielding = false
		can_parry = false
		$Shield.hide()

	# --- NEW: THE DRIFT MECHANIC ---
	if is_shielding and not can_parry:
		# The parry window missed, and they are just holding block. Push them left!
		velocity.x = -block_penalty_speed
	elif not is_shielding and position.x < start_x:
		# Shield is down, and they are behind their starting spot. Run right!
		velocity.x = recovery_speed
	else:
		# They are safely at the start line. Stop moving on the X axis.
		velocity.x = 0
		position.x = start_x # This snaps them exactly to the start so they don't jitter

	move_and_slide()
	
	# --- NEW: THE DEATH ZONE ---
	# If the player is pushed completely off the left side of the screen (past 0)
	if position.x < -400:
		die()

# --- NEW: GAME OVER FUNCTION ---
func die():
	# For now, dying just instantly restarts the current level
	get_tree().reload_current_scene()

func _on_parry_timer_timeout():
	can_parry = false 

func _on_shield_area_entered(area):
	if not is_shielding:
		return 
		
	if area.is_in_group("projectile"):
		if can_parry:
			area.parry() 
		else:
			area.queue_free()
