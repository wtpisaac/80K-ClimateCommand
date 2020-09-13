extends Node2D

signal positionUpdate(newPos)
signal projectileDestroyed()
signal sunlightDestroyed(points)

export var initialPosition: Vector2 = Vector2.ZERO
export var finalPosition: Vector2 = Vector2.ZERO
export var speed: float = 0.0
export var sunlightPoints = 100

var prevDistance: float

var direction: Vector2 = Vector2.ZERO

export var color: Color

var seconds: float = 0.0
var didCollide: bool = false
var collisionSpawned: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.initialPosition = self.position
	self.direction = (finalPosition - initialPosition).normalized()
	self.prevDistance = self.position.distance_to(finalPosition)
	$AuxSprite.look_at(finalPosition)
	$AuxSprite.rotation_degrees += 90
	# Create trail and add to parent scene
	var trailScn = preload("res://Objects/Trail.tscn")
	var missileTrail = trailScn.instance()
	missileTrail.color = self.color
	missileTrail.freePos = self.position
	self.connect("positionUpdate", missileTrail, "needsPosUpdate")
	self.connect("projectileDestroyed", missileTrail, "trailheadDestroyed")
	self.get_parent().add_child(missileTrail)
	missileTrail.anchor(self.position)
	missileTrail.display()
	
# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var vs = get_viewport_rect().size
	if(position.x < 0-vs.x*0.25 or position.x > vs.x + vs.x*0.25):
		queue_free()
	if(position.y > vs.y *1.25):
		queue_free()
	if(!didCollide):
		self.position += direction * speed * delta
		emit_signal("positionUpdate", self.position)
		var newDistance = self.position.distance_to(finalPosition)
		if(newDistance > prevDistance):
			didCollide = true
		prevDistance = newDistance
	if(didCollide && !collisionSpawned):
		collisionSpawned = true
		# Hide
		self.visible = false
		
		# Create leaving plane if not hostile
		if not is_in_group("hostile"):
			var leavingPlaneScn = preload("res://Objects/LeavingPlane.tscn")
			var leavingPlane = leavingPlaneScn.instance()
			leavingPlane.position = position
			if($AuxSprite.rotation_degrees >= 0):
				leavingPlane.rot = 90
			else:
				leavingPlane.rot = -90
			get_parent().add_child(leavingPlane)
		
		# Create new explosion at coordinates
		var missileExplosionScn = preload("res://Objects/Explosion.tscn")
		var missileExplosion = missileExplosionScn.instance()
		missileExplosion.EXPLOSION_COLOR = self.color
		missileExplosion.position = self.position
		missileExplosion.connect("explosion_finished", self, "_on_Explosion_explosion_finished")
		if is_in_group("hostile"):
			missileExplosion.add_to_group("hostile")
			missileExplosion.hostile = true
		else:
			get_parent().play_sound("res://Res/Final/SFX/smoke.wav")
		self.get_parent().add_child(missileExplosion)

func _on_Explosion_explosion_finished(wasHostile):
	emit_signal("projectileDestroyed")
	if(!wasHostile):
		emit_signal("sunlightDestroyed", sunlightPoints)
	queue_free()
	
func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.get_parent().is_in_group("land"):
		self.didCollide = true
	if area.get_parent().is_in_group("explosion") and self.is_in_group("hostile"):
		_on_Explosion_explosion_finished(area.get_parent().hostile)
	pass # Replace with function body.
	
func _draw():
	draw_circle(Vector2.ZERO, 2.0, self.color)
