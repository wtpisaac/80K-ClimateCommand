extends Line2D

export var color: Color = Color.blue
var anchorPos = Vector2(0,0)
var freePos = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.clear_points()
	self.visible = false
	self.default_color = color

func anchor(pos: Vector2):
	self.anchorPos = pos
	self.position = pos
	self.add_point(Vector2.ZERO)
	self.add_point(Vector2.ZERO)
	
func display():
	self.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !self.visible:
		pass
	var correctedPos = Vector2(freePos.x - self.position.x, freePos.y - self.position.y)
	self.set_point_position(self.get_point_count() - 1, correctedPos)

func needsPosUpdate(newPos: Vector2):
	self.freePos = newPos

func trailheadDestroyed():
	self.queue_free()
