extends Area2D

@export var layer = 0

func _on_body_entered(body):
	if body is Collision:
		#Switch collider's collision planes
		match layer:
			#Collision plane A
			0:
				body.UpdateLoopSolidCol(true, 0)
				body.UpdateLoopSolidCol(false, 1)
				
			#Collision plane B
			1:
				body.UpdateLoopSolidCol(true, 1)
				body.UpdateLoopSolidCol(false, 0)
				
			#From collision plane A to collision plane B
			2:
				if(body.ground_speed >= 0):
					body.UpdateLoopSolidCol(true, 1)
					body.UpdateLoopSolidCol(false, 0)
				else:
					body.UpdateLoopSolidCol(true, 0)
					body.UpdateLoopSolidCol(false, 1)
					
			#From collision plane B to collision plane A
			3:
				if(body.ground_speed <= 0):
					body.UpdateLoopSolidCol(true, 0)
					body.UpdateLoopSolidCol(false, 1)
				else:
					body.UpdateLoopSolidCol(true, 1)
					body.UpdateLoopSolidCol(false, 0)
