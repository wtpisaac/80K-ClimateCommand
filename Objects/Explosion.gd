extends Node2D

signal explosion_finished(expl)

export var INITIAL_SIZE: float
export var FINAL_SIZE: float
export var TOTAL_SECONDS: float
export var EXPLOSION_COLOR: Color
var current_seconds: float = 0.0
var size: float = 0.0
var hostile: bool = false

var completed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("explosion")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# update clock
	current_seconds += delta
	# update size 
	if(current_seconds < (TOTAL_SECONDS / 2)):
		size += ((FINAL_SIZE - INITIAL_SIZE)/(TOTAL_SECONDS / 2)) * delta
	else:
		size -= ((FINAL_SIZE - INITIAL_SIZE)/(TOTAL_SECONDS / 2)) * delta
	
	# Update graphics
	update()
	
	# Update collider
	$Area2D/CollisionShape2D.shape.set_radius(size)
	
	# Check completion
	if(current_seconds > TOTAL_SECONDS):
		emit_signal("explosion_finished", hostile)
		get_parent().remove_child(self)
		remove_from_group("explosion")
		queue_free()

func _draw():
	if(size < 0):
		pass
	draw_circle(Vector2.ZERO, size, EXPLOSION_COLOR)

