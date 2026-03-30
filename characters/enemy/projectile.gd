extends Area2D

var speed: float = 600.0
var shooter = null # Holds the Enemy object
var direction: Vector2 = Vector2.LEFT # Default direction

func _ready():
	# Make sure our chain has exactly two connection points to start
	$Line2D.clear_points()
	$Line2D.add_point(Vector2.ZERO) # Point 0: The hook (this object)
	$Line2D.add_point(Vector2.ZERO) # Point 1: The enemy (will update in process)

func _process(delta):
	# Move in the precise direction the enemy calculated!
	position += direction * speed * delta
	# Draw the chain!
	if is_instance_valid(shooter):
		# Point 0 stays glued to the flying hook
		$Line2D.set_point_position(0, Vector2.ZERO)
		
		# Point 1 stretches backwards to the exact global position of the enemy.
		# "to_local" translates the enemy's world coordinates into the chain's coordinates.
		$Line2D.set_point_position(1, to_local(shooter.global_position))
	else:
		# If the enemy dies while the chain is mid-air, the chain breaks and vanishes!
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
