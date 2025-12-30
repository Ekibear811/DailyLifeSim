extends Node2D

@onready var player: CharacterBody2D
@onready var camera: Camera2D

func _ready():
	# Großer grauer Boden
	var background = ColorRect.new()
	background.color = Color(0.3, 0.3, 0.3, 1)
	background.size = Vector2(10000, 10000)
	background.position = Vector2(-5000, -5000)
	add_child(background)
	
	# Spieler als CharacterBody2D (für echte 2D-Bewegung)
	player = CharacterBody2D.new()
	player.position = Vector2(0, 0)
	add_child(player)
	
	# Weißes Quadrat als Sprite-Platzhalter
	var sprite = ColorRect.new()
	sprite.color = Color(1, 1, 1, 1)
	sprite.size = Vector2(64, 64)
	sprite.position = Vector2(-32, -32)
	player.add_child(sprite)
	
	# Collision für später (z.B. Wände)
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(64, 64)
	collision.shape = shape
	player.add_child(collision)
	
	# Kamera folgt Spieler
	camera = Camera2D.new()
	camera.enabled = true
	camera.zoom = Vector2(0.8, 0.8)
	player.add_child(camera)

const SPEED = 400

func _physics_process(delta):
	var velocity = Vector2.ZERO
	
	# Bewegung mit WASD oder Pfeiltasten
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	
	velocity = velocity.normalized() * SPEED
	player.velocity = velocity
	player.move_and_slide()
	
	# Debug in Console (unten im Editor)
	print("Velocity: ", velocity.length())
