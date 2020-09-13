extends Sprite

export var speed = 300
export var rot = 90
var dir = Vector2(1,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.rotation_degrees = rot
	if(rot == 90):
		dir = Vector2(1, 0)
	else:
		dir = Vector2(-1, 0)


func _physics_process(delta):
	self.position += dir*speed*delta
	var vs = get_viewport_rect().size
	if(self.position.x < vs.x*-0.25 or self.position.x > vs.x*1.25):
		if(get_parent().levelActive):
			get_parent().planeCount -= 1
		queue_free()
