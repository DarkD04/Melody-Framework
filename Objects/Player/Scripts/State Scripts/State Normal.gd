extends State

func physics_update(_delta):
	#Get the input presses
	var movement = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	#Update player animations on the ground
	if(owner.ground):
		#Change animation to standing if player is not moving
		if(abs(owner.ground_speed) == 0):
			owner.sprite.play("Stand")
		
		#Change animation to walking if ground speed is between 0 and 6
		if(abs(owner.ground_speed) > 0 && abs(owner.ground_speed) < 6):
			owner.sprite.speed_scale = 0.6 + abs(owner.ground_speed / 4.0)
			owner.sprite.play("Walk")
		
		#Change animation to running if ground speed is above 6
		if(abs(owner.ground_speed) >= 6 && owner.sprite.animation != "Running"):
			owner.sprite.speed_scale = 0.6 + abs(owner.ground_speed / 4.0)
			owner.sprite.play("Running")
	
	#Check for looking up
	if(Input.get_action_strength("up") && owner.ground && owner.ground_speed == 0):
		state_machine.change("Look Up")
		
	#Check for looking up
	if(Input.get_action_strength("down") && owner.ground && abs(owner.ground_speed) < 0.5):
		state_machine.change("Look Down")
	
	#Trigger skidding event
	if(owner.ground && abs(owner.ground_speed) > 4 && movement == -sign(owner.ground_speed) && owner.ground_mode == 0):
		#Change state to skidding
		state_machine.change("Skidding")
		
		#Reset the skid timer
		owner.skid_timer = 0
		
		#Play the skidding sound
		Audio.play_sound(preload("res://Sound/Player/Skidding.wav"))
	
	#Give player controls
	owner.player_control()
	
	#Give player ability to change directions
	owner.player_direction()
	
	#Check for if player can jump
	owner.player_check_jump()
	
	#Check for if player can roll
	owner.player_check_roll()
