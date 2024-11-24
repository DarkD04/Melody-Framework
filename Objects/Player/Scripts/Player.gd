extends Collision

#TODO: Organize these variables, this fucking sucks LOL
var speed = Vector2(0, 0)
var ground_speed = 0;
var ground = false;
var x_accel = 0.046875
var friction_speed = 0.046875
var gravity = 0.21875
var top_speed = 6
var steps = 1
var control_lock = 0
var direction = 1
var jump_flag = false
var spindash_rev = 0
var skid_timer = 0

#List of player hitbox sizes
var player_hitbox_size = [
	[9, 19, 10]			#In order: Collision Width, Collision Height, Wall Collision Width
]

#List of player hitbox sizes for rolling action
var player_rolling_hitbox_size = [
	[7, 15]			#In order: Collision Width, Collision Height
]

var state

var visual_angle = 0
var visual_angle_rad = 0

@onready var sprite = $"PlayerSprite"
@onready var state_machine = $"StatesMachine"
@onready var camera = $/root/Stage/Camera

#TODO: Make an entity system out of this, and make player use it!!

func _physics_process(delta):	
	#Calculate steps
	steps = 1 + floor(abs(speed.x) / 9) + floor(abs(speed.y) / 9)
	
	#Player's logic in steps
	for i in steps:
		ray_process()
		position += speed / steps
		
		#Change speeds to ground speed
		if ground:
			speed.x = ground_speed * cos(deg_to_rad(ground_angle))
			speed.y = ground_speed * -sin(deg_to_rad(ground_angle))
			
		#Debug for fast accelearting 
		ground_speed += (1 / steps) * direction * Input.get_action_strength("debug1")
		
		#Handle player's wall collision
		player_wall_collision()
		
		#Handle player's landing routine and ground collision
		player_ground_collision()
		
		#Handle player's ceiling collision and ceiling landing routine
		player_ceiling_collision()
		
		#Handle player's visual rotation
		player_viuals()
		
		#Handle player's ground mode changes
		collision_set_mode()
	
	#Add gravity
	if !ground:
		speed.y += gravity
		
	#Detach and control lock event
	if(abs(ground_speed) <= 2.5):
		#Detach the player if too slow
		if(ground_angle >= 90 && ground_angle <= 270):
			ground_angle = 0
			ground_mode = 0
			ground = false
			
		#Do the control lock if the player is too slow
		if(ground_angle >= 45 && ground_angle <= 315):
			control_lock = 30
			
	state = state_machine.state
	player_update_hitbox()
	
	#Visual direction change
	$PlayerSprite.flip_h = false
	
	#Make player face left
	if(direction == -1):
		$PlayerSprite.flip_h = true
		
	player_wall_stopper()

func player_wall_collision():
	#Process the ray events
	ray_process()
	
	#Left wall collision
	var dist_l = get_distance(sensor_type.WALL_L) - 10
	var normal = sensor[sensor_type.WALL_L].get_collision_normal()
	var dist = dist_l * normal
	
	#Push the player out of the wall
	if(sensor[sensor_type.WALL_L].is_colliding() && dist_l <= 0):
		position -= dist 
	
	#Right wall collision
	dist_l = get_distance(sensor_type.WALL_R) - 10
	normal = sensor[sensor_type.WALL_R].get_collision_normal()
	dist = dist_l * normal
	
	#Push the player out of the wall
	if(sensor[sensor_type.WALL_R].is_colliding() && dist_l <= 0):
		position -= dist 

func player_ceiling_collision():
	#Process the ray events
	ray_process()
	
	#Find the active ray
	var w = find_sensor(sensor_type.CEIL_L, sensor_type.CEIL_R)
	
	#Get the collision height of the active ray
	var dist = get_distance(w) - collision_height
	
	#Ceiling collision check
	if(sensor[w].is_colliding() && dist <= 0 && !ground):
		#Push the player out of the ceiling
		position.y -= dist
		
		#Ceiling landing routine
		if(speed.y < -2.5):
			#Get the angle of ray that is colliding with the ceiling
			var ceil_angle = sensor_get_angle(w)
			
			#If player is in the angle range, ground the player to the ceiling
			if(ceil_angle <= 135 || ceil_angle >= 225):
				#Move ceiling angle to the ground angle
				ground_angle = ceil_angle
				
				#Landing speed on the ceiling
				ground_speed = speed.y * -sign(sin(deg_to_rad(ground_angle)))
				
				#Ground the player
				ground = true
		
		#Stop the player from accelearting up in the ceiling
		if(speed.y < 0):
			speed.y = 0

func player_ground_collision():
	#Process the ray events
	ray_process()
	
	#Find the active ray
	var w = find_sensor(sensor_type.BOTTOM_L, sensor_type.BOTTOM_R)
	
	#Get the collision height of the active ray
	var dist = get_height(w)
	
	#Detach off the ground
	if(!sensor[sensor_type.BOTTOM_L].is_colliding() && !sensor[sensor_type.BOTTOM_R].is_colliding()):
		#Disable the ground flag
		ground = false
		
		#Reset the angle
		ground_mode = 0
		ground_angle = 0
		
	if(!ground):
		if(sensor[w].is_colliding() && dist.y >= 0 && speed.y >= 0):
			#Set the ground angle
			ground_angle = sensor_get_angle(w)
			
			#Landing on flat surfaces
			ground_speed = speed.x
			
			#If player is falling at specific speed
			if(abs(speed.x) <= abs(speed.y)):
				#Land on half steep surfaces
				if(ground_angle >= 24 && ground_angle <= 336):
					ground_speed = (speed.y * 0.5) * -sign(sin(deg_to_rad(ground_angle)))
				
				#Land on full steep surfaces
				if(ground_angle >= 24 && ground_angle <= 336):
					ground_speed = speed.y * -sign(sin(deg_to_rad(ground_angle)))
			else:
				#Transfer x speed to ground speed
				ground_speed = speed.x

			#Position the player on the ground
			position -= dist
			
			#Ground the player
			ground = true
	else:
		#Set the ground angle of the active ray
		ground_angle = sensor_get_angle(w)
		
		#Push player on the ground
		position -= dist

#TODO: This kinda sucks because it's ported from physics guide, will redo it later
func player_control():
	#Subtract the control lock timer
	control_lock = max(control_lock - 1, 0)
		
	#Get the input presses
	var movement = Input.get_action_strength("right") - Input.get_action_strength("left")

	#Grounded player movement
	if(ground):
		#Slope influence
		if(abs(ground_speed) > 0.125 || control_lock > 0):
			ground_speed -= 0.125 * sin(deg_to_rad(ground_angle))
			
		#Move to the left
		if(movement == -1 && control_lock == 0):
			#Movement quirk
			if(ground_speed > 0):
				ground_speed -= 0.5
			elif(ground_speed > -top_speed):
				ground_speed -= x_accel
				
		#Move to the right
		if(movement == 1 && control_lock == 0):
			#Movement quirk
			if(ground_speed < 0):
				ground_speed += 0.5
			elif(ground_speed < top_speed):
				ground_speed += x_accel
				
		#Decelarete when not holding any inputs
		if(movement == 0 && control_lock == 0):
			ground_speed -= min(abs(ground_speed), friction_speed) * sign(ground_speed)
		
		#TODO: Port the control quirk improvement
	#Airborn controls
	else:
		#Airdrag physics:
		if(speed.y > -4 && speed.y < 0):
			speed.x -= speed.x / 32
			
		#Move to the left
		if(movement == -1 && speed.x >= -top_speed):
			speed.x -= x_accel * 2
			
		#Move to the right
		if(movement == 1 && speed.x <= top_speed):
			speed.x += x_accel * 2
		

func player_direction():
	#Get the input presses
	var movement = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	#Turn player's direction based on the input presses
	if(ground):
		if(control_lock == 0 && movement == sign(ground_speed) && movement != 0):
			direction = movement
	else:
		if(movement != 0):
			direction = movement
			

func player_wall_stopper():
	#Process the ray events
	ray_process()
	
	#Get the player's speed
	var spd = ground_speed
	
	#Get player's speed while airborn
	if(!ground):
		spd = speed.x
	
	#Distance of left wall ray
	var dist_l = get_distance(sensor_type.WALL_L) - 10
	
	#Push the player out of the wall
	if(sensor[sensor_type.WALL_L].is_colliding() && dist_l <= 1 && spd < 0):
		if(ground):
			ground_speed = 0
		else:
			speed.x = 0
	
	#Distance of right wall ray
	dist_l = get_distance(sensor_type.WALL_R) - 10

	#Stop player's movement
	if(sensor[sensor_type.WALL_R].is_colliding() && dist_l <= 1 && spd > 0):
		if(ground):
			ground_speed = 0
		else:
			speed.x = 0
		
func player_viuals():
	#Rotate the player sprite
	sprite.rotation = -deg_to_rad(visual_angle)
	
	#On ground visal angle event
	if(ground):
		var target_vangle = 0
		
		#Rotate the player on slopes
		if(ground_angle >= 33.75 && ground_angle < 333.50):
			target_vangle = ground_angle
		
		#Rotate the player skin
		if(abs(ground_speed) < 6):
			visual_angle_rad = lerp_angle(visual_angle_rad, deg_to_rad(target_vangle), 0.25)
		else:
			visual_angle_rad = lerp_angle(visual_angle_rad, deg_to_rad(target_vangle), 0.5)
		
		#Convernt to degrees
		visual_angle = rad_to_deg(visual_angle_rad)
	else:
		#Rotate angle back to 0
		visual_angle = wrapf(visual_angle, -180, 180)
		visual_angle = move_toward(visual_angle, 0, float(2.8125 / steps))
		visual_angle_rad = 0
		
	#If player doesn't play specific animations then disable animation angle
	if(sprite.animation != "Walk" && sprite.animation != "Running"):
		visual_angle = 0

func player_check_jump():	
	if(Input.is_action_just_pressed("action") && ground):
		#Play the rolling animation
		$PlayerSprite.play("Roll")
		
		#Play the jump sound
		Audio.play_sound(preload("res://Sound/Player/Jump.wav"))
		
		#Change player's state to jumping
		state_machine.change("Jump")
		
		#Jump off the player
		speed.y -= 6.5 * cos(deg_to_rad(ground_angle));	
		speed.x -= 6.5 * sin(deg_to_rad(ground_angle));	
		
		#Change the jump flag, this allows for cutting off your jump speed
		jump_flag = true
		
		#Change the animation speed
		sprite.speed_scale = 0.6 + abs(ground_speed / 4.0)
		
		#Reset visual angle
		visual_angle = 0
		
		#Reset angle and angle mode
		ground_mode = 0
		ground_angle = 0
		
		#Disable grounded flag
		ground = false

func player_check_roll():
	if(ground && abs(ground_speed) > 0.5 && Input.is_action_pressed("down")):
		#Change the player state
		state_machine.change("Roll")
		
		#Play the rolling sound
		Audio.play_sound(preload("res://Sound/Player/Roll.ogg"))

func player_update_hitbox():
	#Get the previous hitbox height
	var hitbox_h_prev = collision_height
	
	#Update hitbox size
	collision_width = player_hitbox_size[0][0]
	collision_height = player_hitbox_size[0][1]
	collision_wall_w = player_hitbox_size[0][2]
	
	#Change the hitbox size when rolling animation is playing
	if(state_machine.state.name == "Roll" || state_machine.state.name == "Jump"):
		collision_width = player_rolling_hitbox_size[0][0]
		collision_height = player_rolling_hitbox_size[0][1]
		
	#Shift player's position when hitbox sizes change
	position.x += (hitbox_h_prev - collision_height) * sin(deg_to_rad(90 * ground_mode))
	position.y += (hitbox_h_prev - collision_height) * cos(deg_to_rad(90 * ground_mode))
