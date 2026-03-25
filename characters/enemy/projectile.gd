extends Area2D

var speed: float = 400.0

func _process(delta):
	# Move left constantly
	position.x -= speed * delta

# This deletes the projectile when it leaves the screen
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
