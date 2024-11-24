extends State

func physics_update(delta):
	#Friction to replicate slow ducking
	if(owner.ground):
		owner.ground_speed -= min(abs(owner.ground_speed), owner.friction_speed) * sign(owner.ground_speed)
	else:
		#Give player controls while airborn
		owner.player_control()
	
	#Play animation
	owner.sprite.play("Look Down")
	
	#Make player spindash if action button is pressed
	if(Input.is_action_just_pressed("action") && owner.ground):
		#Reset spindash rev
		owner.spindash_rev = 0
		
		#Play the spindash sound
		Audio.play_sound(preload("res://Sound/Player/Spindash.wav"))
		
		#Change state to spindash
		state_machine.change("Spindash")
	
	#If down key is not being held, go back to the original state
	if(!Input.get_action_strength("down")):
		state_machine.change("Normal")
	
