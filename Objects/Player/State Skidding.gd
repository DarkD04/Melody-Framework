extends State

func physics_update(delta):
	#Reset the animation speed
	owner.sprite.speed_scale = 1
	
	#Change the animation
	if(owner.sprite.animation != "Skid Turn"):
		owner.sprite.play("Skid")
	
	#Get the input presses
	var movement = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	#If input is being held then decelerate
	if(movement == -sign(owner.ground_speed)):
		owner.ground_speed = move_toward(owner.ground_speed, -0.5 * owner.direction, 0.5)
	else:
		#Otherwise, add skid timer that stops the player from skidding
		owner.skid_timer += 1
	
	#If speed is in the oposite direction, play the skid turn
	if(owner.ground_speed < 0 && owner.direction == 1 || owner.ground_speed > 0 && owner.direction == -1):
		owner.sprite.play("Skid Turn")
	
	#Either if skid timer is over 20 frames or if player detaches, change state back to normal
	if(owner.skid_timer > 20 || !owner.ground):
		state_machine.change("Normal")
		
		#If airborne, force the walking animation
		if(!owner.ground):
			owner.sprite.play("Walk")

func animation_finished():
	#If skid turn animation has finished, force state back to normal and flip the player
	if(owner.sprite.animation == "Skid Turn"):
		#Flip the player
		owner.direction *= -1
		
		#Change back the state
		state_machine.change("Normal")
