extends CharacterBody2D

const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# New Shield Variables
var is_shielding: bool = false
var can_parry: bool = false

func _ready():
	$Shield.hide() # Hide the shield when the game starts

func _physics_process(delta):
	# --- GRAVITY & JUMPING ---
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# --- SHIELD LOGIC ---
	if Input.is_action_just_pressed("shield"):
		is_shielding = true
		can_parry = true # Open the parry window!
		$Shield.show()
		$ParryTimer.start() # Start the 0.2 second countdown
		
	if Input.is_action_just_released("shield"):
		is_shielding = false
		can_parry = false
		$Shield.hide()

	move_and_slide()

# This triggers when the 0.2 second ParryTimer runs out
func _on_parry_timer_timeout():
	can_parry = false # The window closes, but the shield stays up to block

# This triggers when something hits the Shield Area2D
func _on_shield_area_entered(area):
	if not is_shielding:
		return # Do nothing if we aren't holding the shield button
		
	if area.is_in_group("projectile"):
		if can_parry:
			area.parry() # We timed it perfectly! Deflect it!
		else:
			area.queue_free() # We held the button too long. Just destroy the projectile (Block).
