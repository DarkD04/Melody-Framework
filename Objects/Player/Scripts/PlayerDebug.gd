extends Control


@onready var player = $"/root/Stage/Player"

func _physics_process(delta):
	$"CanvasLayer/Speed Debug".text = "Ground Speed: " + str(round_place(player.ground_speed, 2)) + "\n" + "X Speed: " + str(round_place(player.speed.x, 2)) + "\n" + "Y Speed: " + str(round_place(player.speed.y, 2)) + "\n" + "Ground Angle: " + str(round_place(player.ground_angle, 2))
	
func round_place(num, places):
	return (round(num*pow(10,places))/pow(10,places))
