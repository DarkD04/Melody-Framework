extends State

func physics_update(delta):
	#Stop the player from moving
	if(owner.ground):
		owner.ground_speed = 0
	else:
		#Give player controls while airborne
		owner.player_control()
		
	#If up key is not being held, go back to the original state
	if(!Input.get_action_strength("up")):
		state_machine.change("Normal")
	
	#Play the animation
	owner.sprite.play("Look Up")
	
	#This is temp before i give player the peel out
	owner.player_check_jump()
