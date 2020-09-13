extends Sprite

const HEALTHY_TEXTURE: StreamTexture = preload("res://Res/Final/airport.png")
const DESTROYED_TEXTURE: StreamTexture = preload("res://Res/Final/dead airport.png")
const ENABLED_ICON: StreamTexture = preload("res://Res/Final/icon.png")
const DISABLED_ICON: StreamTexture = preload("res://Res/Final/disabledicon.png")
export var cooldown_secs = 1.0
var airplanes: int = 10
var healthy: bool = true
var cooldown: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _physics_process(delta):
	if(cooldown > 0.0):
		cooldown -= delta
		$Icon.texture = DISABLED_ICON
	else:
		if(healthy and airplanes > 0):
			$Icon.texture = ENABLED_ICON
	
func resetAirport():
	healthy = true
	airplanes = 10
	cooldown = 0.0
	texture = HEALTHY_TEXTURE
	$Label.text = str(airplanes)
	$Icon.texture = ENABLED_ICON

func planeFired():
	airplanes -= 1
	cooldown = cooldown_secs
	$Label.text = str(airplanes)
	if(airplanes <= 0):
		disable()

func disable():
	$Icon.texture = DISABLED_ICON

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.get_parent().is_in_group("hostile") || area.get_parent().is_in_group("explosion"):
		self.texture = DESTROYED_TEXTURE
		$Icon.texture = DISABLED_ICON
		self.healthy = false
		get_parent().play_sound("res://Res/Final/SFX/destroyed.wav")
	pass # Replace with function body.
