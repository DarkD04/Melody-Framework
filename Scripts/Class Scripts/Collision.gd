extends Node2D
class_name Collision


#Ground collision modes
enum mode
{
	CMODE_GROUND,
	CMODE_RWALL,
	CMODE_CEILING,
	CMODE_LWALL
}

#Sensors that we are going to be using
enum sensor_type
{
	BOTTOM_L, BOTTOM_R, 		#Ground rays
	CEIL_L, CEIL_R, 			#Ceiling rays
	WALL_L, WALL_R				#Wall rays
}

var sensor = []
var sensor_position = []
var sensor_height = []

var collision_width = 9
var collision_height = 19
var collision_wall_w = 10
var collision_wall_h = 4

var ground_angle = 0
var ground_mode = mode.CMODE_GROUND

var mode_change_delay = 0
var delay_sub = 0

func _init():
	for i in sensor_type.size():
		var sensors = RayCast2D.new()
		sensors.name = "Sensor" + str(i)
		sensors.hit_from_inside = false
		sensors.exclude_parent = true
		add_child(sensors)
		sensor.append(get_node("Sensor" + str(i)))

func ray_process():
	#Reset wall height
	var wall_h = 0
	
	#Move vertical wall radius when on flat ground
	if(ground_angle == 0):
		wall_h = collision_wall_h
		
	
	sensor_position = [
		Vector2(-collision_width, 0), Vector2(collision_width, 0),
		Vector2(-collision_width, 0), Vector2(collision_width, 0),
		Vector2(-0, wall_h), Vector2(0, wall_h)
	]
	
	sensor_height = [
		Vector2(0, collision_height + 14), Vector2(0, collision_height + 14),
		Vector2(0, -collision_height - 14), Vector2(0, -collision_height - 14),
		Vector2(-collision_wall_w - 14, 0), Vector2(collision_wall_w + 14, 0)
	]
	
	mode_change_delay = max(mode_change_delay - 1, 0)
	
	#Update rays
	for i in sensor_type.size():
		#Update rays
		sensor[i].force_raycast_update()
		
		#Get the position and arrays then rotate them
		var s_position = sensor_position[i].rotated(deg_to_rad(90 * -ground_mode))
		var s_height = sensor_height[i].rotated(deg_to_rad(90 * -ground_mode))
		
		#Position the rays
		sensor[i].position = Vector2(round(s_position.x), round(s_position.y))
		sensor[i].target_position = Vector2(round(s_height.x), round(s_height.y))
	

func get_distance(s):
	#Declare local variables
	var origin_position
	var collision_point 
	var distance
	var normal
	
	#Get the position or ray's starting and end point
	origin_position = sensor[s].global_position
	collision_point = sensor[s].get_collision_point()
	
	#Get the distance
	distance = origin_position.distance_to(collision_point)

	#Return the result
	return distance

func get_height(s):
	var distance
	var normal
	
	distance = get_distance(s) - collision_height
	normal = sensor[s].get_collision_normal()
	
	return normal * distance

func find_sensor(sensor_a, sensor_b):
	var col_a = sensor[sensor_a].is_colliding()
	var col_b = sensor[sensor_b].is_colliding()
	
	var distance_a = get_distance(sensor_a)
	var distance_b = get_distance(sensor_b)
	
	var output = sensor_a
	
	if !col_a and col_b:
		output = sensor_b
		
	if col_a and col_b:
		if distance_b < distance_a:
			output = sensor_b
		else:
			output = sensor_a
	return output 
		
func sensor_get_angle(ray):
	var angle
	var output
	
	angle = sensor[ray].get_collision_normal().angle_to(Vector2.UP)
	
	if angle < 0:
		output = angle + (2*PI)
	else:
		output = angle
		
	return round(rad_to_deg(output))
	
func collision_set_mode():
	var delay = max(0 - delay_sub, 0)
	if(mode_change_delay == 0):
		if ground_angle >= 0 and ground_angle <= 45 || ground_angle >= 315 and ground_angle <= 360:
			mode_change_delay = delay
			ground_mode = mode.CMODE_GROUND
			
		if ground_angle >= 46 and ground_angle <= 134:
			mode_change_delay = delay
			ground_mode = mode.CMODE_RWALL
			
		if ground_angle >= 135 and ground_angle <= 225:
			mode_change_delay = delay
			ground_mode = mode.CMODE_CEILING
			
		if ground_angle >= 226 and ground_angle <= 314:
			mode_change_delay = delay
			ground_mode = mode.CMODE_LWALL
			
	ray_process()
