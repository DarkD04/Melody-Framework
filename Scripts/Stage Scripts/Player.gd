extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Icon.position.x = 64.0 + 32 * sin($Icon.rotation)
	$Icon.position.y = 90.0 + 64 * cos($Icon.rotation * 0.8)
	
	$Icon.scale.x = 1 + 0.4 * sin($Icon.rotation * 0.85)
	$Icon.scale.y = $Icon.scale.x
	
	$Icon.rotation += deg_to_rad(4.0)
	pass
