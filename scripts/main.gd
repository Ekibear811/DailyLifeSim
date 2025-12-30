extends Node2D

# === Globale Variablen ===
var player: CharacterBody2D
var camera: Camera2D
var background: ColorRect

# HUD-Elemente
var time_label: Label
var message_label: Label
var task_list_label: Label

# Tageszeit-System
var game_time: float = 480.0          # Start um 08:00 Uhr
const TIME_SCALE = 60.0               # 1 echte Sekunde = 1 Spielminute

# Energie-System
var energy: float = 100.0
const ENERGY_DRAIN_PER_MINUTE = 2.0   # Energie sinkt langsam

# Tasks
var tasks = [
	{
		"name": "Kaffee kochen",
		"position": Vector2(300, 200),
		"color": Color(0.2, 0.6, 1.0),
		"completed": false,
		"reward_energy": 30,
		"reward_text": "+30 Energie! Du bist hellwach!"
	},
	{
		"name": "Briefkasten leeren",
		"position": Vector2(-400, -100),
		"color": Color(1.0, 0.8, 0.2),
		"completed": false,
		"reward_energy": 15,
		"reward_text": "+15 Energie! Post erledigt."
	},
	{
		"name": "Pflanzen gießen",
		"position": Vector2(100, -300),
		"color": Color(0.2, 1.0, 0.3),
		"completed": false,
		"reward_energy": 20,
		"reward_text": "+20 Energie! Natur zufrieden."
	},
	{
		"name": "Kurz meditieren",
		"position": Vector2(-200, 400),
		"color": Color(0.8, 0.3, 1.0),
		"completed": false,
		"reward_energy": 40,
		"reward_text": "+40 Energie! Innere Ruhe gefunden."
	}
]

var task_objects = []

const SPEED = 400

# === _ready() – Alles aufbauen ===
func _ready():
	# Großer Hintergrund
	background = ColorRect.new()
	background.color = Color(0.3, 0.3, 0.3, 1)
	background.size = Vector2(10000, 10000)
	background.position = Vector2(-5000, -5000)
	add_child(background)
	
	# Spieler (weißes Quadrat)
	player = CharacterBody2D.new()
	player.position = Vector2(0, 0)
	add_child(player)
	
	var player_sprite = ColorRect.new()
	player_sprite.color = Color(1, 1, 1, 1)
	player_sprite.size = Vector2(64, 64)
	player_sprite.position = Vector2(-32, -32)
	player.add_child(player_sprite)
	
	var player_collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(64, 64)
	player_collision.shape = shape
	player.add_child(player_collision)
	
	# Kamera folgt Spieler
	camera = Camera2D.new()
	camera.enabled = true
	camera.zoom = Vector2(0.8, 0.8)
	player.add_child(camera)
	
	# HUD (CanvasLayer)
	var hud = CanvasLayer.new()
	add_child(hud)
	
	# Uhr
	time_label = Label.new()
	time_label.text = get_time_string()
	time_label.add_theme_font_size_override("font_size", 36)
	time_label.add_theme_color_override("font_color", Color(1, 1, 1))
	time_label.position = Vector2(20, 20)
	hud.add_child(time_label)
	
	# Nachrichten (z. B. Belohnung)
	message_label = Label.new()
	message_label.text = ""
	message_label.add_theme_font_size_override("font_size", 42)
	message_label.add_theme_color_override("font_color", Color(1, 1, 0.6))
	message_label.position = Vector2(20, 70)
	message_label.modulate.a = 0
	hud.add_child(message_label)
	
	# Task-Liste
	task_list_label = Label.new()
	task_list_label.text = get_task_list_text()
	task_list_label.add_theme_font_size_override("font_size", 28)
	task_list_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1))
	task_list_label.position = Vector2(20, 130)
	hud.add_child(task_list_label)
	
	# Task-Objekte erstellen
	create_task_objects()

# === Task-Objekte visuell erstellen ===
func create_task_objects():
	for task in tasks:
		var obj = ColorRect.new()
		obj.color = task.color
		obj.size = Vector2(80, 80)
		obj.position = task.position - Vector2(40, 40)
		add_child(obj)
		task_objects.append(obj)

# === Bewegung + Interaktion ===
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

# === Task prüfen ===
func check_tasks():
	for i in range(tasks.size()):
		var task = tasks[i]
		if task.completed:
			continue
		
		var dist = player.position.distance_to(task.position)
		if dist < 100:
			task.completed = true
			task_objects[i].color = Color(0.5, 0.5, 0.5)  # Grau = erledigt
			energy += task.reward_energy
			energy = min(energy, 100)  # Max 100
			show_message(task.reward_text)
			update_task_list()
			break

# === Nachricht anzeigen (3 Sekunden) ===
func show_message(text: String):
	message_label.text = text
	message_label.modulate.a = 1.0
	await get_tree().create_timer(3.0).timeout
	message_label.modulate.a = 0.0

# === Task-Liste aktualisieren ===
func update_task_list():
	task_list_label.text = get_task_list_text()

func get_task_list_text() -> String:
	var text = "Offene Aufgaben:\n"
	var open_count = 0
	for task in tasks:
		if not task.completed:
			text += "- " + task.name + "\n"
			open_count += 1
	if open_count == 0:
		text += "Alle erledigt! Guter Tag!"
	return text

# === Zeit + Tag/Nacht + Energie ===
func _process(delta):
	# Zeit läuft
	game_time += delta * TIME_SCALE
	if game_time >= 1440:
		game_time -= 1440
		# Tagesabschluss (optional erweitern)
		show_message("Neuer Tag beginnt! Energie zurückgesetzt.")
		energy = 100.0
	
	# Energie sinkt langsam
	energy -= ENERGY_DRAIN_PER_MINUTE * delta * (TIME_SCALE / 60.0)
	energy = max(energy, 0)
	
	# HUD aktualisieren
	time_label.text = get_time_string() + " | Energie: " + str(int(energy))
	
	# Tag/Nacht
	var hour = int(game_time / 60)
	if hour >= 6 and hour < 18:
		background.color = Color(0.5, 0.5, 0.6, 1)  # Tag
	else:
		background.color = Color(0.1, 0.1, 0.15, 1)  # Nacht
	
	update_task_list()

# === Uhr-String ===
func get_time_string() -> String:
	var hours = int(game_time / 60)
	var minutes = int(game_time) % 60
	return "%02d:%02d" % [hours, minutes]