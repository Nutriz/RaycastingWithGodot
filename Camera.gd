extends Position2D

# CAMERA
const WIDTH_SCREEN = 320
const HEIGHT_SCREEN = 200
const FOV = 60
var ANGLE_INCR = 60/320
const rayLength = 500
var m_intersections = Vector2()
const m_speedMove = 200
const m_speedAngle = 200
var rays = []

var pos = Vector2()
var ang = 0

func _ready():
	ANGLE_INCR = float(60) / float(320)
	for i in range(WIDTH_SCREEN):
		rays.append(Vector2(0, 0))

func _process(delta):
	var curr_pos = pos
	var curr_ang = ang
	if Input.is_action_pressed("ui_up"):
		pos.x += dCos(ang)*m_speedMove*delta
		pos.y += dSin(ang)*m_speedMove*delta
	if Input.is_action_pressed("ui_down"):
		pos.x -= dCos(ang)*m_speedMove*delta
		pos.y -= dSin(ang)*m_speedMove*delta
	if Input.is_action_pressed("ui_left"):
		ang -= m_speedAngle*delta
	if Input.is_action_pressed("ui_right"):
		ang += m_speedAngle*delta

	if curr_pos != pos or curr_ang != ang:
		projection()
		update()

func projection():
	for i in range(rays.size()):
		rays[i].x = pos.x + rayLength*dCos((ang-FOV/2) + i*ANGLE_INCR)
		if intersect(i):
			rays[i] = m_intersections
		rays[i].y = pos.y + rayLength*dSin((ang-FOV/2) + i*ANGLE_INCR)

func intersect(i):
	var fAngle = (ang-FOV/2) + i*ANGLE_INCR
	var dir = Vector2(dCos(fAngle), dSin(fAngle))
	for i in range(rays.size()):
		var dx = pos.x + 1 * dir.x
		var dy = pos.y + 1 * dir.y

		if hasWall(dx, dy):
			m_intersections.x = dx
			m_intersections.y = dy
			return true
	return false


func _draw():
	for r in rays:
		draw_line(pos, r, ColorN("red"))

	var first = Vector2(pos.x + 150*dCos(ang-FOV/2), pos.y + 150*dSin(ang-FOV/2))
	var midle = Vector2(pos.x + 150*dCos(ang), pos.y + 150*dSin(ang))
	var last = Vector2(pos.x + 150*dCos(ang + FOV/2), pos.y + 150*dSin(ang + FOV/2))

	draw_line(pos, first, ColorN("blue"))
	draw_line(pos, midle, ColorN("blue"))
	draw_line(pos, last, ColorN("blue"))
	draw_circle(pos, 5, ColorN("green"))


func hasWall(x, y):
	return get_parent().get_node("TileMap").get_cell(0 ,0) == 1

func toRadian(degree):
	return (PI/180) * degree

func dCos(degree):
	return cos(toRadian(degree))

func dSin(degree):
	return sin(toRadian(degree))