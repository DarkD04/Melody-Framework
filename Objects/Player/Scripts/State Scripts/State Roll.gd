extends State

func physics_update(delta):
	#Play rolling animation
	owner.sprite.play("Roll")
	
	#Change the animation speed
	owner.sprite.speed_scale = 0.6 + abs(owner.ground_speed / 4.0)
	
	#TODO: Make physics variables not hard coded!
	#Rolling influence on slopes
	if(sign(owner.ground_speed) == sign(sin(deg_to_rad(owner.ground_angle)))):
		#Up-slope rolling influence
		owner.ground_speed -= 0.078125 * sin(deg_to_rad(owner.ground_angle))
	else:
		#Down-slope rolling influence
		owner.ground_speed -= 0.3125 * sin(deg_to_rad(owner.ground_angle))
	
	#Rolling friction
	owner.ground_speed = move_toward(owner.ground_speed, 0, 0.046875 / 2)
	
	#Get the input presses
	var movement = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	#Turning to different direction
	if(movement == - sign(owner.ground_speed)):
		owner.ground_speed -= 0.125 * -movement
		
	#Stop rolling on the ground
	if(owner.ground_angle < 40 || owner.ground_angle > 320):
		if(owner.ground_speed == 0):
			state_machine.change("Normal")
			
	#If player is airborn, force state to jump state
	if(!owner.ground):
		#Change state to jumping
		state_machine.change("Jump")
		
		#Disable the jump flag
		owner.jump_flag = false
		#TODO:Add another flag that checks if player came from roll state
	
	#Give player ability to change directions
	owner.player_direction()
	
	#Check for if player can jump
	owner.player_check_jump()
