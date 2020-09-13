extends Sprite

signal desertified(farm)

var healthy: bool = true

const HEALTHY_TEXTURE: StreamTexture = preload("res://Res/Final/alive farm.png")
const DESERTIFIED_TEXTURE: StreamTexture = preload("res://Res/Final/dead farm.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
	if healthy:
		if(area.get_parent().is_in_group("explosion") || area.get_parent().is_in_group("hostile")):
			self.texture = DESERTIFIED_TEXTURE
			self.healthy = false
			get_parent().play_sound("res://Res/Final/SFX/destroyed.wav")
			emit_signal("desertified", self)
