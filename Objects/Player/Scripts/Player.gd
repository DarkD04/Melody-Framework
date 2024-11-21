extends Collision

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

var visual_angle = 0
var visual_angle_rad = 0

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):	
	#Calculate steps
	steps = 1 + floor(abs(speed.x) / 9) + floor(abs(speed.y) / 9)
	
	#Player's logic in steps
	for i in steps:
		ray_process()
		position += speed / steps
		
		if ground:
			speed.x = ground_speed * cos(deg_to_rad(ground_angle))
			speed.y = ground_speed * -sin(deg_to_rad(ground_angle))
			
		#Debug for fast accelearting 
		ground_speed += (1 / steps) * direction * Input.get_action_strength("debug1")
		
		#Unorganized function execution
		player_wall_collision()
		player_ground_collision()
		player_ceiling_collision()
		collision_set_mode()
	
	#Add gravity
	if !ground:
		speed.y += gravity / steps
	
	
	#THIS IS TEMP
	if(ground):
		if(abs(ground_speed) > 0 && abs(ground_speed) < 6):
			$PlayerSprite.speed_scale = 0.6 + abs(ground_speed / 6.0)
			$PlayerSprite.play("Walk")
			
		if(abs(ground_speed) == 0):
			$PlayerSprite.play("Stand")
		
		if(abs(ground_speed) >= 6 && $PlayerSprite.animation != "Running"):
			$PlayerSprite.speed_scale = 0.6 + abs(ground_speed / 4.0)
			$PlayerSprite.play("Running")
	
	player_viuals()
	player_control()
	player_direction()
	player_wall_stopper()
	
	#TEMP JUMP
	if(Input.is_action_just_pressed("action") && ground):
		$PlayerSprite.play("Roll")
		speed.y -= 6.5 * cos(deg_to_rad(ground_angle));	
		speed.x -= 6.5 * sin(deg_to_rad(ground_angle));	
		visual_angle = 0
		ground_mode = 0
		ground_angle = 0
		ground = false
		

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
			
	#Visual direction change
	$PlayerSprite.flip_h = false
	
	#Make player face left
	if(direction == -1):
		$PlayerSprite.flip_h = true

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
	if(sensor[sensor_type.WALL_L].is_colliding() && dist_l <= 0 && spd < 0):
		if(ground):
			ground_speed = 0
		else:
			speed.x = 0
	
	#Distance of right wall ray
	dist_l = get_distance(sensor_type.WALL_R) - 10

	#Stop player's movement
	if(sensor[sensor_type.WALL_R].is_colliding() && dist_l <= 0 && spd > 0):
		if(ground):
			ground_speed = 0
		else:
			speed.x = 0
		
func player_viuals():
	$PlayerSprite.rotation = -deg_to_rad(visual_angle)
	
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
		visual_angle = move_toward(visual_angle, 0, float(2.8125))
		visual_angle_rad = 0
