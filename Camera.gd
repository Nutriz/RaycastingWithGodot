extends Position2D

# CAMERA
export var WIDTH_SCREEN = 50
const HEIGHT_SCREEN = 200
const FOV = 60
var ANGLE_INCR
export var rayLength = 64*6
export var moveSpeed = 200
export var angleSpeed = 100
var rays = []

var pos = Vector2(64*2, 64*2.5)
var ang = 0

func _ready():
	ANGLE_INCR = float(FOV) / float(WIDTH_SCREEN)
	for i in range(WIDTH_SCREEN):
		rays.append(Vector2(0, 0))

func _process(delta):
	var curr_pos = pos
	var curr_ang = ang
	if Input.is_action_pressed("ui_up"):
		pos.x += dCos(ang)*moveSpeed*delta
		pos.y += dSin(ang)*moveSpeed*delta
	if Input.is_action_pressed("ui_down"):
		pos.x -= dCos(ang)*moveSpeed*delta
		pos.y -= dSin(ang)*moveSpeed*delta
	if Input.is_action_pressed("ui_left"):
		ang -= angleSpeed*delta
	if Input.is_action_pressed("ui_right"):
		ang += angleSpeed*delta

	if curr_pos != pos or curr_ang != ang:
		projection()
		update()

func projection():
	for i in range(rays.size()):
		var intersect = intersect(i)
		if intersect:
			rays[i] = intersect
		else:
			rays[i].x = pos.x + rayLength*dCos((ang-FOV/2) + i*ANGLE_INCR)
			rays[i].y = pos.y + rayLength*dSin((ang-FOV/2) + i*ANGLE_INCR)


func intersect(i):
	var fAngle = (ang-FOV/2) + i*ANGLE_INCR
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

	draw_circle(pos, 5, ColorN("green"))


func hasWall(x, y):
	return get_parent().get_node("TileMap").get_cell(x ,y) == 1

func toRadian(degree):
	return (PI/180) * degree

func dCos(degree):
	return cos(toRadian(degree))

func dSin(degree):
	return sin(toRadian(degree))

func _on_Timer_timeout():
	projection()
	update()
