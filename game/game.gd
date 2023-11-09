extends Node2D


@onready var react_timer: Timer = get_node("Timer")
@onready var game_time_left: Timer = get_node("GameTime")

@onready var fish_sound: AudioStreamPlayer = get_node("AudioStreamPlayer")

@onready var lbl_score: Label = get_node("HUD/LblScore")

var real_square: Square
var fake_square: Square

const CENTER_POS = Vector2(300.0,300.0)
const SPAWN_AREA = Vector2(450,450)
const GAME_TIME: int = 20

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





func _ready():
	for l in $HUD.get_children():
		l.add_theme_color_override("font_color", Color("fafdff"))
		
	PlayerData.reset_data()

	self.game_time_left.connect("timeout", gameover)
	self.rng = RandomNumberGenerator.new()
	self._set_mode()
	self._start_game()


func _start_game():
	self.real_square = preload("res://game/square.tscn").instantiate()
	self.add_child(self.real_square)
	self.real_square.name = "RealSquare"
	self.real_square.connect("was_clicked", real_clicked)
	self.real_square.set_color(Color("10d275"))

	self.fake_square = preload("res://game/square.tscn").instantiate()
	self.add_child(self.fake_square)
	self.fake_square.name = "FakeSquare"
	self.fake_square.connect("was_clicked", fake_clicked)
	self.fake_square.set_color(Color("7f0622"))
	self.fake_square.position = Vector2(-100,-100)


	self.move_square(self.real_square, 0.0)
	self.game_time_left.start(GAME_TIME)

	self.real_square.show()
	self.fake_square.show()


func _process(delta):
	if !is_stopped:
		time_elapsed += delta

func _set_mode() -> void:
	var _mode = PlayerData.game_mode
	var _mode_txt: String
	
	match _mode:
		PlayerData.GAME_MODES.EASY:
			_mode_txt = "Easy Mode"
		PlayerData.GAME_MODES.NORMAL:
			_mode_txt = "Normal Mode"
		PlayerData.GAME_MODES.HARD:
			_mode_txt = "Hard Mode"
	
	$HUD/LblMode.text = _mode_txt

func move_square(sq: Square, time: float) -> void:
	var starting_pos = sq.position
	var end_pos = self.get_position_in_area()

	print("Traveled: ", roundf(starting_pos.distance_to(end_pos)), " units")

	var tween = get_tree().create_tween()
	tween.tween_property(sq, "position", end_pos, time)
	sq.is_moving = true
	
	if PlayerData.game_mode == PlayerData.GAME_MODES.NORMAL:
		sq.hide()
	
	if sq != null:
		tween.call_deferred("tween_callback", sq.reset)


func update_score(num: int) -> void:
	self.player_score += num
	self.lbl_score.set_text(str("Score:", player_score))


func get_position_in_area() -> Vector2:
	var position_in_area: Vector2
	position_in_area.x = (randi() % int(SPAWN_AREA.x)) - (SPAWN_AREA.x/2) + CENTER_POS.x
	position_in_area.y = (randi() % int(SPAWN_AREA.y)) - (SPAWN_AREA.y/2) + CENTER_POS.y

	return position_in_area


func stopwatch_reset() -> void:
	print("time elapsed:", snappedf(time_elapsed,0.01))
	PlayerData.reaction_times.append(snappedf(time_elapsed,0.01))
	time_elapsed = 0.0
	is_stopped = false

func stopwatch_stop() -> void:
	is_stopped = true

func stopwatch_start() -> void:
	is_stopped = false

func real_clicked() -> void:
	print('real square clicked')
	self.stopwatch_reset()
	self.fish_sound.play()
	self.move_square(self.real_square, 0.2)
	self.update_score(1)

func fake_clicked() -> void:
	print('fake square clicked')

func gameover() -> void:
	get_tree().change_scene_to_file("res://game/screen/gameover_screen.tscn")



func _on_background_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index==1:
		PlayerData.player_clicked()
		print("missed click")
		PlayerData.misses += 1
