extends State

func physics_update(delta):
	#Change animation to spindash
	owner.sprite.play("Spindash")
	
	#Set the ground speed to 0
	owner.ground_speed = 0
	
	#Subtract the spindash rev
	owner.spindash_rev = max(0, owner.spindash_rev - (floor(owner.spindash_rev / 0.125) / 256) )
	
	#Change the animation speed
	owner.sprite.speed_scale = 1
		
	#Charge spindash
	if(Input.is_action_just_pressed("action")):
		#Add the rev
		owner.spindash_rev = min(owner.spindash_rev + 2, 8)
		
		#Play the spindash sound
		Audio.play_sound(preload("res://Sound/Player/Spindash.wav"))
		
		#Reset the animation
		owner.sprite.set_frame_and_progress(0,0)
		
		
	#Release the spindash
	if(!Input.get_action_strength("down")):
		#Change state to roll
		state_machine.change("Roll")
		
		#Stop the spindash sound
		Audio.stop_sound(preload("res://Sound/Player/Spindash.wav"))
		
		#Play the spindash release sound
		Audio.play_sound(preload("res://Sound/Player/Release.wav"))
		
		#Lag the camera
		owner.camera.camera_lag = 16
		
		#Set the ground speed
		if(owner.ground):
			owner.ground_speed = (8 + (floor(owner.spindash_rev) / 2)) * owner.direction
		else:
			owner.speed.x = (8 + (floor(owner.spindash_rev) / 2)) * owner.direction
