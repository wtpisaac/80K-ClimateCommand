extends AudioStreamPlayer

export var path = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	stream = load(path)
	play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!playing):
		queue_free()
