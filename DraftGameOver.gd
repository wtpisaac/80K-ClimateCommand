extends Node2D


var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	score = Global.score
	$YearLabel.bbcode_text = "[center]You survived " + str(score) + " years of climate change."


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_Button_pressed():
	var menuScn = load("res://Enter.tscn")
	var menu = menuScn.instance()
	get_node("/root").add_child(menu)
	get_tree().current_scene = menu 
	get_node("/root").remove_child(self)
