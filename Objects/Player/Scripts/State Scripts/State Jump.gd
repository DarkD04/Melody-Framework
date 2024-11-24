extends State

func physics_update(delta):
	#Update the animation
	owner.sprite.play("Roll")
	
	#If player is not holding any inputs, cut off the jump
	#TODO: Make jump variables customizable, and make input presses as part of the player entity, it might seem stupid
	#but trust me, it's useful
	if(owner.speed.y < -4 && owner.jump_flag && !Input.is_action_pressed("action")):
		#Disable the jump flag
		owner.jump_flag = false
		
		#Limit the vertical speed
		owner.speed.y = -4
		
	#If the player is on the ground change back to normal state
	if(owner.ground):
		state_machine.change("Normal")
	
	#Give player controls
	owner.player_control()
	
	#Check for if player can roll
	owner.player_check_roll()
	
	#Give player ability to change directions
	owner.player_direction()
