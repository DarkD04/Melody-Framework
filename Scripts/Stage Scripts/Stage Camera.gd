extends Camera2D

var target

var camera_pos : Vector2
var target_pos : Vector2

var camera_lag : int = 0
var ground_offset : float = 0
var cam_speed : Vector2 = Vector2.ZERO 
var stop : bool = false

@export_group("Camera Margins")
@export var air_margins : int = 32
@export var left_margin : int = 0
@export var right_margin : int = 16
@export var player_offset : int = 16

func _ready():
	#Get the target object
	target = $"../Player"
	
	#Set the position to the players
	target_pos = target.position
	
	#Set the scrolling speeds
	cam_speed = Vector2(16, 24)


func _physics_process(delta):
	#Execute movement functions
	camera_horizontal_movement()
	camera_vertical_movement()
	
	#Position the camera to the target
	position.x = target_pos.x
	position.y = target_pos.y + 16

func camera_horizontal_movement():
	#Move camera to the right
	if(target.position.x > target_pos.x + left_margin && camera_lag == 0):
		target_pos.x = min(target_pos.x + cam_speed.x, target.position.x - left_margin)
	
	#Move camera to the left
	if(target.position.x < target_pos.x - right_margin && camera_lag == 0):
		target_pos.x = max(target_pos.x - cam_speed.x, target.position.x + right_margin)
		
func camera_vertical_movement():
	#Airborn camera movement
	if(!target.ground):
		#Reset the ground offset
		ground_offset = air_margins
		
		#Move camera to the right
		if(target.position.y > target_pos.y + air_margins):
			target_pos.y = min(target_pos.y + cam_speed.y, target.position.y - air_margins)
		
		#Move camera to the left
		if(target.position.y < target_pos.y - air_margins):
			target_pos.y = max(target_pos.y - cam_speed.y, target.position.y + air_margins)
	else:
		#Ease out ground offset
		ground_offset -= ground_offset / 8.0
		
		#Move camera to the right
		if(target.position.y > target_pos.y + ground_offset):
			target_pos.y = min(target_pos.y + cam_speed.y, target.position.y - ground_offset)
		
		#Move camera to the left
		if(target.position.y < target_pos.y - ground_offset):
			target_pos.y = max(target_pos.y - cam_speed.y, target.position.y + ground_offset)
