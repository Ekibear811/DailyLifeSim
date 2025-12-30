extends Node2D

var player: CharacterBody2D
var camera: Camera2D
var time_label: Label
var message_label: Label
var background: ColorRect

# Tageszeit in Minuten
var game_time: float = 480.0  # Start um 08:00

const TIME_SCALE = 60.0  # 1 Sekunde = 1 Spielminute

# Tasks
var tasks = [
	{
		"name": "Kaffee kochen",
		"position": Vector2(300, 200),
		"color": Color(0.2, 0.6, 1.0),  # Blau
		"completed": false,
		"reward_text": "+ Energie! Du fühlst dich wach!"
	},
	{
		"name": "Briefkasten leeren",
		"position": Vector2(-400, -100),
		"color": Color(1.0, 0.8, 0.2),  # Gelb
		"completed": false,
		"reward_text": "+ Post erledigt! Keine Rechnungen übersehen."
	}
]

var task_objects = []  # Speichert die visuellen Quadrate

func _ready():
	# Hintergrund
	background = ColorRect.new()
	background.color = Color(0.3, 0.3, 0.3, 1)
	background.size = Vector2(10000, 10000)
	background.position = Vector2(-5000, -5000)
	add_child(background)
	
	# Spieler
	player = CharacterBody2D.new()
	player.position = Vector2(0, 0)
	add_child(player)
	
	var sprite = ColorRect.new()
	sprite.color = Color(1, 1, 1, 1)
	sprite.size = Vector2(64, 64)
	sprite.position = Vector2(-32, -32)
	player.add_child(sprite)
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(64, 64)
	collision.shape = shape
	player.add_child(collision)
	
	# Kamera
	camera = Camera2D.new()
	camera.enabled = true
	camera.zoom = Vector2(0.8, 0.8)
	player.add_child(camera)
	
	# HUD
	var hud = CanvasLayer.new()
	add_child(hud)
	
	time_label = Label.new()
	time_label.text = get_time_string()
	time_label.add_theme_font_size_override("font_size", 36)
	time_label.add_theme_color_override("font_color", Color(1, 1, 1))
	time_label.position = Vector2(20, 20)
	hud.add_child(time_label)
	
	message_label = Label.new()
	message_label.text = ""
	message_label.add_theme_font_size_override("font_size", 42)
	message_label.add_theme_color_override("font_color", Color(1, 1, 0.5))
	message_label.position = Vector2(20, 70)
	message_label.modulate.a = 0  # Unsichtbar am Anfang
	hud.add_child(message_label)
	
	# Task-Objekte erstellen
	for task in tasks:
		var obj = ColorRect.new()
		obj.color = task.color
		obj.size = Vector2(80, 80)
		obj.position = task.position - Vector2(40, 40)
		add_child(obj)
		task_objects.append(obj)

const SPEED = 400

func _physics_process(delta):
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y += 1
	
	velocity = velocity.normalized() * SPEED
	player.velocity = velocity
	player.move_and_slide()
	
	# Interaktion mit E
	if Input.is_action_just_pressed("interact"):
		check_tasks()

func check_tasks():
	for i in range(tasks.size()):
		var task = tasks[i]
		if task.completed:
			continue
		
		var dist = player.position.distance_to(task.position)
		if dist < 100:  # Nah genug
			task.completed = true
			task_objects[i].color = Color(0.5, 0.5, 0.5)  # Grau = erledigt
			show_message(task.reward_text)
			break

func show_message(text: String):
	message_label.text = text
	message_label.modulate.a = 1.0
	await get_tree().create_timer(3.0).timeout
	message_label.modulate.a = 0.0

func _process(delta):
	game_time += delta * TIME_SCALE
	if game_time >= 1440:
		game_time -= 1440
	
	time_label.text = get_time_string()
	
	var hour = int(game_time / 60)
	if hour >= 6 and hour < 18:
		background.color = Color(0.5, 0.5, 0.6, 1)
	else:
		background.color = Color(0.1, 0.1, 0.15, 1)

func get_time_string() -> String:
	var hours = int(game_time / 60)
	var minutes = int(game_time) % 60
	return "%02d:%02d" % [hours, minutes]
