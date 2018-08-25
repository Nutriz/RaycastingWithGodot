extends Position2D

# CAMERA
export var WIDTH_SCREEN = 2
const HEIGHT_SCREEN = 200
const FOV = 60
var ANGLE_INCR
export var rayLength = 64*6
export var moveSpeed = 200
export var angleSpeed = 100
var rays = []

var pos = Vector2(64*2.5, 64*2.5)
var angle = 1

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
		
	var dist_from_next_col = 64-int(curr_pos.x)%64
	var dist_from_next_row = 64-int(curr_pos.y)%64
	$Label.text = str(dist_from_next_col) + " " + str(dist_from_next_row) + "\n" + str(angle) + "°"

func projection():
	for i in range(rays.size()):
		var intersect = intersect(i)
		if intersect:
			rays[i] = intersect
		else:
			rays[i].x = pos.x + rayLength*dCos((angle-FOV/2) + i*ANGLE_INCR)
			rays[i].y = pos.y + rayLength*dSin((angle-FOV/2) + i*ANGLE_INCR)

func optimized_intersect(i):
	# horizontal wall check
	if angle > 180 and angle < 360:
		var next_row_y = int(pos.y/64)*64
		var next_row_x = (pos.y-next_row_y)/dTan(-angle)
		draw_line(pos, Vector2(pos.x+next_row_x, next_row_y), ColorN("green"), 1)
	elif angle < 180 and angle > 0:
		var next_row_y = int(pos.y/64)*64 + 64 #/2
		var next_row_x = (pos.y-next_row_y)/dTan(-angle)
		draw_line(pos, Vector2(pos.x+next_row_x, next_row_y), ColorN("green"), 1)

	# vertical wall check
	if angle > 270 and angle < 360 or angle > 0 and angle < 90:
		var next_col_x = int(pos.x/64)*64 + 64
		var next_col_y = pos.y + (next_col_x-pos.x)*dTan(angle)
		draw_line(pos, Vector2(next_col_x, next_col_y), ColorN("yellow"), 1)
	elif angle > 90 and angle < 270:
		var next_col_x = int(pos.x/64)*64
		var next_col_y = pos.y - (next_col_x-pos.x)*dTan(-angle)
		draw_line(pos, Vector2(next_col_x, next_col_y), ColorN("yellow"), 1)

func intersect(i):
	var fAngle = (angle-FOV/2) + i*ANGLE_INCR
	var dir = Vector2(dCos(fAngle), dSin(fAngle))
	for l in range(rayLength):
		var dx = pos.x + l * dir.x
		var dy = pos.y + l * dir.y
		if hasWall(dx/64, dy/64):
			return Vector2(dx, dy)
	return false


func _draw():
	for r in rays:
		draw_line(pos, r, ColorN("red"), 1)

	# draw player pos
	draw_circle(pos, 5, ColorN("green"))
	

func hasWall(x, y):
	return get_parent().get_node("TileMap").get_cell(x ,y) == 1

func dCos(degree):
	return cos(deg2rad(degree))

func dSin(degree):
	return sin(deg2rad(degree))
	
func dTan(degree):
	return tan(deg2rad(degree))