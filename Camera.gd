extends Position2D

# CAMERA
export var WIDTH_SCREEN = 320
const HEIGHT_SCREEN = 200
const FOV = 60
var ANGLE_INCR
export var rayLength = 64*10
export var moveSpeed = 200
export var angleSpeed = 100
var rays = []

var pos = Vector2(64*2.5, 64*2.5)
var angle = 0

func _ready():
	ANGLE_INCR = float(FOV) / float(WIDTH_SCREEN)
	for i in range(WIDTH_SCREEN):
		rays.append(Vector2(0, 0))

func _process(delta):
	var curr_pos = pos
	var curr_ang = angle
	if Input.is_action_pressed("ui_up"):
		pos.x += dCos(angle)*moveSpeed*delta
		pos.y += dSin(angle)*moveSpeed*delta
	if Input.is_action_pressed("ui_down"):
		pos.x -= dCos(angle)*moveSpeed*delta
		pos.y -= dSin(angle)*moveSpeed*delta
	if Input.is_action_pressed("ui_left"):
		angle -= angleSpeed*delta
	if Input.is_action_pressed("ui_right"):
		angle += angleSpeed*delta
		
	if angle > 360:
		angle = 0
		
	if angle < 0:
		angle = 360

	if curr_pos != pos or curr_ang != angle:
		projection()
		update()
		
	$Label.text = str(angle) + "°"

func projection():
	for i in range(rays.size()):
		var intersect = optimized_intersect(i)
		if intersect:
			rays[i] = intersect
		else:
			rays[i].x = pos.x + rayLength*dCos((angle-FOV/2) + i*ANGLE_INCR)
			rays[i].y = pos.y + rayLength*dSin((angle-FOV/2) + i*ANGLE_INCR)

func optimized_intersect(i):
	for grid_step in range(rayLength/64):
		
		var curr_angle = (angle-FOV/2) + i*ANGLE_INCR
		var h_length = null
		var v_length = null
		
		var next_row_x
		var next_row_y
		var next_col_x
		var next_col_y
		
		# horizontal wall check
		if curr_angle > 180 and curr_angle < 360:
			next_row_y = int(pos.y/64)*64 - (grid_step*64)
			next_row_x = pos.x + (pos.y-next_row_y)/dTan(-curr_angle)
			if has_wall(int(next_row_x/64), int(next_row_y/64)-1):
				h_length = pos.distance_squared_to(Vector2(next_row_x, next_row_y))
		elif curr_angle < 180 and curr_angle > 0:
			next_row_y = int(pos.y/64)*64 + (64+(64*grid_step))
			next_row_x = pos.x + (pos.y-next_row_y)/dTan(-curr_angle)
			if has_wall(int(next_row_x/64), int(next_row_y/64)):
				h_length = pos.distance_squared_to(Vector2(next_row_x, next_row_y))
	
#		# vertical wall check
		if curr_angle > 270 and curr_angle < 360 or curr_angle > 0 and curr_angle < 90:
			next_col_x = int(pos.x/64)*64 + 64 + (64*grid_step)
			next_col_y = pos.y + (next_col_x-pos.x)*dTan(curr_angle)
			if has_wall(int(next_col_x/64), int(next_col_y/64)):
				v_length = pos.distance_squared_to(Vector2(next_col_x, next_col_y))
		elif curr_angle > 90 and curr_angle < 270:
			next_col_x = int(pos.x/64)*64 - (64*grid_step)
			next_col_y = pos.y - (next_col_x-pos.x)*dTan(-curr_angle)
			if has_wall(int(next_col_x/64)-1, int(next_col_y/64)):
				v_length = pos.distance_squared_to(Vector2(next_col_x, next_col_y))
				
		if h_length != null and v_length != null:
			if h_length < v_length:
				return Vector2(next_row_x, next_row_y)
			else:
				return Vector2(next_col_x, next_col_y)
				
		if h_length != null:
			return Vector2(next_row_x, next_row_y)
				
		if v_length != null:
			return Vector2(next_col_x, next_col_y)
		
	return false


func intersect(i):
	var fAngle = (angle-FOV/2) + i*ANGLE_INCR
	var dir = Vector2(dCos(fAngle), dSin(fAngle))
	for l in range(rayLength):
		var dx = pos.x + l * dir.x
		var dy = pos.y + l * dir.y
		if has_wall(dx/64, dy/64):
			return Vector2(dx, dy)
	return false


func _draw():
	for r in rays:
		draw_line(pos, r, ColorN("red"), 1)

	# draw player pos
	draw_circle(pos, 5, ColorN("green"))
	
#	for grid_step in range(rayLength/256):
#		# horizontal wall check
#		var hit_wall = false
#		var next_row_x
#		var next_row_y
#		if angle > 180 and angle < 360:
#			next_row_y = int(pos.y/64)*64 - (grid_step*64)
#			next_row_x = pos.x + (pos.y-next_row_y)/dTan(-angle)
#			draw_circle(Vector2(next_row_x, next_row_y), 2, ColorN("green"))
#			printt(int(next_row_x/64), int(next_row_y/64))
#			if has_wall(int(next_row_x/64), int(next_row_y/64)-1):
#				draw_circle(Vector2(next_row_x, next_row_y), 2, ColorN("red"))
#				hit_wall = true
#		if angle < 180 and angle > 0:
#			next_row_y = int(pos.y/64)*64 + 64+(64*grid_step)
#			next_row_x = pos.x + (pos.y-next_row_y)/dTan(-angle)
#			draw_circle(Vector2(next_row_x, next_row_y), 2, ColorN("green"))
#			printt(int(next_row_x/64), int(next_row_y/64))
#			if has_wall(int(next_row_x/64), int(next_row_y/64)):
#				draw_circle(Vector2(next_row_x, next_row_y), 2, ColorN("red"))
#				hit_wall = true
#				print("WALL")
				
#		if hit_wall:
#			print("WALL HIT " + str(next_row_x/64) + " " + str(next_row_y/64))
#			return
		# vertical wall check
#		if angle > 270 and angle < 360 or angle > 0 and angle < 90:
#			var next_col_x = int(pos.x/64)*64 + 64 + (64*grid_step)
#			var next_col_y = pos.y + (next_col_x-pos.x)*dTan(angle)
#			draw_circle(Vector2(next_col_x, next_col_y), 2, ColorN("green"))
#			if has_wall(int(next_col_x/64), int(next_col_y/64)):
#				draw_circle(Vector2(next_col_x, next_col_y), 2, ColorN("red"))
#		elif angle > 90 and angle < 270:
#			var next_col_x = int(pos.x/64)*64 - (64*grid_step)
#			var next_col_y = pos.y - (next_col_x-pos.x)*dTan(-angle)
#			draw_circle(Vector2(next_col_x, next_col_y), 2, ColorN("green"))
#			if has_wall(int(next_col_x/64)-1, int(next_col_y/64)):
#				draw_circle(Vector2(next_col_x, next_col_y), 2, ColorN("red"))


func has_wall(x, y):
	return get_parent().get_node("TileMap").get_cell(x ,y) == 1

func dCos(degree):
	return cos(deg2rad(degree))

func dSin(degree):
	return sin(deg2rad(degree))
	
func dTan(degree):
	return tan(deg2rad(degree))

func _on_Button_pressed():
	projection()
	update()
