extends Node2D


@onready var marker2d: Marker2D = get_node("Marker2D")
@onready var react_timer: Timer = get_node("Timer")

const CENTER_POS = Vector2(300.0,300.0)

var game_state: int = 0 
var is_square_moving: bool = false
var square_height = 64
var square_width = 64
var square_x = 50.0
var square_y = 100.0
var rng = RandomNumberGenerator.new()
var player_score = 0

var time_elapsed: float = 0.0
var is_stopped := false

var square: Rect2


func _ready():
	self.square = Rect2(marker2d.position.x, marker2d.position.y, 64.0, 64.0)
	self.rng = RandomNumberGenerator.new()
	marker2d.position = Vector2(50.0, 100.0)

func _draw():
	match self.game_state:
		0:
			draw_rect(Rect2(0, 30, 600.0, 570.0), Color.DARK_SLATE_GRAY)
		1:
			draw_rect(Rect2(0, 30, 600.0, 570.0), Color.DARK_SLATE_BLUE)
			if !is_square_moving:
				draw_rect(square, Color.SALMON)
		2:
			pass

func _process(delta):
	match self.game_state:
		0:
			pass
		1:
			self.square.position = self.marker2d.position
			queue_redraw()
			if !is_stopped:
				time_elapsed += delta
				$HUD/Label.text = str(time_elapsed).pad_decimals(1)
		2:
			pass

func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if event.is_action_pressed('left_mouse'):
			#print("Mouse Click at: ", event.position)
			if check_mouse_click(event.position.x, event.position.y):
				print("a square was clicked") 
				self.stopwatch_reset()
				$AudioStreamPlayer.play()
				self.move_square()
				self.update_score(20)
				var my_random_number = self.rng.randf_range(0, 100.0)
				print("moving to: ", my_random_number)
   
func check_mouse_click(mx,my) -> bool:
	return square.has_point(Vector2(mx,my))
	#return (mx < marker2d.position.x + 64 and 
			#my < marker2d.position.y + 64)

func move_square() -> void:
	
	
	var size = Vector2(500,500)
	var positionInArea: Vector2
	positionInArea.x = (randi() % int(size.x)) - (size.x/2) + CENTER_POS.x
	positionInArea.y = (randi() % int(size.y)) - (size.y/2) + CENTER_POS.y
	
	
	
	
	var starting_pos = self.marker2d.position
	var end_pos = positionInArea
	var time = 0.2
	
	print("start: ", starting_pos)
	print("end: ", end_pos)
	print("Traveled: ", starting_pos.distance_to(end_pos), " units")
	
	var tween = get_tree().create_tween()
	tween.tween_property(self.marker2d, "position", end_pos, time)
	self.is_square_moving = true
	tween.tween_callback(func(): self.is_square_moving=false)


func _on_Tween_tween_all_completed():
	self.is_square_moving = false
	pass # Replace with function body.

func update_score(num: int) -> void:
	self.player_score += num
	$HUD/LblScore.set_text(str("Score:", player_score)) 


func stopwatch_reset() -> void:
	# possibly save time_elapsed somewhere else before overriding it
	print("time elapsed:", time_elapsed)
	time_elapsed = 0.0
	is_stopped = false

func stopwatch_stop() -> void:
	is_stopped = true
	
func stopwatch_start() -> void:
	is_stopped = false