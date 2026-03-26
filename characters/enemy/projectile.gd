extends Area2D

var speed: float = 400.0
var direction: int = -1 # -1 moves left, 1 moves right
var is_parried: bool = false

func _process(delta):
	# Move in the direction constantly
	position.x += speed * direction * delta
	
	

# The player's shield will trigger this function
func parry():
	direction = 1 # Flip direction to right
	speed = 600.0 # Make it fly back faster!
	is_parried = true
	$ColorRect.color = Color.CYAN # Change its color to show it was deflected
	
	
	
# This deletes the projectile when it leaves the screen
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
