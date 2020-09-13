extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Explosion Test
	# Get viewport
	var viewport_rect_size = get_viewport_rect().size
	# Spawn new explosion
	var explosionScn = preload("res://Objects/Explosion.tscn")
	var explosion = explosionScn.instance()
	explosion.position.x = viewport_rect_size.x / 2
	explosion.position.y = viewport_rect_size.y / 2
	add_child(explosion)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
