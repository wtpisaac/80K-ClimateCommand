extends AnimatedSprite

signal stormDestroyed()

var velocity: Vector2 = Vector2.ZERO
export var precs: float
export var gravity: float = 0.0
export var stormPoints: int = 250
var intersections: Array = []

var debugTimer = 0
var sounds = 0
var soundsStarted = 0
var soundTimer = 0.2
# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("hostile")

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		self.remove_from_group("hostile")

func _physics_process(delta):
	if(sounds < 3):
		soundTimer += delta
		if(soundTimer > 0.1):
			sounds += 1
			soundTimer = 0.0
			get_parent().play_sound("res://Res/Final/SFX/airplane.wav")
		
	debugTimer += delta
	if(debugTimer > 1):
		debugTimer = 0
		print(intersections)
	var vs = get_viewport_rect().size
	if(self.position.y >= vs.y*1.5):
		self.get_parent().remove_child(self)
		emit_signal("stormDestroyed")
		self.queue_free()
	if(intersections.size() == 0):
		# Accelerate for gravity
		self.velocity.y += gravity*delta
		self.position += velocity*delta
	else:
		velocity = Vector2.ZERO
		for ar in intersections:
			if(not is_instance_valid(ar["a"])):
				continue
			var arpar = ar["a"].get_parent()
			var arparPos = arpar.position
			var radi = ar["s"].radius
			print(radi)
			if(arparPos - Vector2(radi/precs, radi/precs) <= position and arparPos + Vector2(radi/12, radi/12) >= position):
				# eliminate
				emit_signal("stormDestroyed")
				self.queue_free()
func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
	if(area.get_parent().is_in_group("explosion")):
		var explDict = {"a": area, "s": area.shape_owner_get_owner(area.shape_find_owner(area_shape)).shape}
		intersections.push_back(explDict)
	pass # Replace with function body.


func _on_Area2D_area_shape_exited(area_id, area, area_shape, self_shape):
	if(not is_instance_valid(area)):
		return
	if(area.get_parent().is_in_group("explosion")):
		for dict in intersections:
			if(dict["a"] == area):
				intersections.erase(dict)
	pass # Replace with function body.
