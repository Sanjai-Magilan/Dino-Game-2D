extends Node

var stump_scene  = preload("res://scene/stump.tscn")
var barrel_scene = preload("res://scene/barrel.tscn")
var rock_scene   = preload("res://scene/rock.tscn")
var stone2_scene = preload("res://scene/stone_2.tscn")
var box_scene    = preload("res://scene/box.tscn")
var bird_scene   = preload("res://scene/bird.tscn")
var obstacle_types := [stump_scene,  barrel_scene,  rock_scene, stone2_scene, box_scene]
var obstacles : Array
var bird_heights := [130, 50]


const DINO_START_POS := Vector2i(59, 161)
const CAM_START_POS := Vector2i(192, 108)
var difficulty
const MAX_DIFF : int = 2
var score : int
const score_mod : int = 100
var speed : float
const START_SPEED : float = 4.0
const MAX_SPEED : int = 25
const SPEED_MOD : int = 5000
var screen_size : Vector2i
var ground_height : int
var game_running : bool
var last_obs
var high_score : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	
	score = 0
	show_score()   
	
	game_running = false
	get_tree().paused = false
	difficulty = 0
	
	#rest obs
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	
	#game reset
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		speed = START_SPEED + score / SPEED_MOD
		generate_obs()
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		
		adjust_difficulty()
		
		$Dino.position.x += speed
		$Camera2D.position.x += speed

		
		score += speed
		show_score()

		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
			
			#remove obs
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else :
		if Input.is_action_just_pressed("ui_up"):
			game_running = true
			$HUD.get_node("StartLabel").hide()


func generate_obs():
	#ground obs
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 30)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs , obs_x, obs_y-170) #change the "-170" according to your screen size or just remove it
		#bird spwan
		if difficulty == MAX_DIFF:
			if(randi() % 2) == 0:
				obs = bird_scene.instantiate()
				var obs_x : int = screen_size.x + score + 200
				var obs_y : int = bird_heights[randi() % bird_heights.size()]
				add_obs(obs, obs_x, obs_y)


func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)


func hit_obs(body):
	if body.name == "Dino": #dino char scene name
		game_over()


func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score/score_mod)


func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / score_mod)


func adjust_difficulty():
	difficulty = score / SPEED_MOD
	if difficulty > MAX_DIFF:
		difficulty = MAX_DIFF


func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()
