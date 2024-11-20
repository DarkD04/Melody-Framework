extends Node

#Variable that will be taking you to the starting scene
@export var starting_scene : PackedScene = null;

# Called when the node enters the scene tree for the first time.
func _ready():
	#Check if the scene exists
	if starting_scene != null:
		#Get the directory of the starting scene
		var s = starting_scene.get_path();
		
		#Move to the starting scene
		get_tree().change_scene_to_file(s)
		
		#Display a debug message
		print("Your starting scene root is" + s)
	else:
		#If there's no starting scene move
		print("There is no starting scene!")
	pass 
