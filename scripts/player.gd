extends CharacterBody2D
class_name Player

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D

var _stateMachine

var SPEED = 80.0
const JUMP_VELOCITY = -400.0
var lastDirection = Vector2.LEFT
@export var friction = 0.2
@export var acc = 0.2
@export var bulletNode: PackedScene

@export_category("Objects")
@export var _animationTree: AnimationTree = null

func _ready():
	_stateMachine = _animationTree["parameters/playback"]

var isRunning = false
var isDashing = false
var canDash=true
var canAttack=true
var isAttacking=false
func _physics_process(delta: float) -> void:
	
	if isDashing || isAttacking:
		move_and_slide()
	else:
		move()
		attack()
		dash()
		animate()
		move_and_slide()

func shoot():
	var bullet = bulletNode.instantiate()
	
	bullet.position = global_position
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	get_tree().current_scene.call_deferred("add_child", bullet)

#func _input(event):
	#if event.is_action("shoot"):
		#shoot()
	#if event.is_action("dash"):
		#dash()
	#if event.is_action("attack") && !isAttacking:
		#attack()
		#
func move():
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		lastDirection = direction
		_animationTree["parameters/idle/blend_position"] = direction  
		_animationTree["parameters/walk/blend_position"] = direction
		_animationTree["parameters/run/blend_position"] = direction
		_animationTree["parameters/dash/blend_position"] = direction
		_animationTree["parameters/attack/blend_position"] = direction
		
		
		
		velocity.x = lerp(velocity.x, direction.normalized().x*SPEED, acc)
		velocity.y = lerp(velocity.y, direction.normalized().y*SPEED, acc)
	else:
		velocity.x = lerp(velocity.x, direction.normalized().x*SPEED, friction)
		velocity.y = lerp(velocity.y, direction.normalized().y*SPEED, friction)


	if Input.is_action_pressed("run"):
		isRunning = true
	if Input.is_action_just_released("run"):
		isRunning = false
	if isRunning:
		SPEED=200.0
	else:
		SPEED=80.0
		

func animate():
	
	if isDashing:
		_stateMachine.travel("dash")
		return
	
	if isAttacking:
		_stateMachine.travel("attack")
		return
	
	if velocity.length()>1:
		if isRunning && !isDashing:
			_stateMachine.travel("run")
		elif !isRunning && !isDashing:
			_stateMachine.travel("walk")	
		return
	_stateMachine.travel("idle")
	
func dash():
	if Input.is_action_just_pressed("dash"):
		if isDashing || !canDash:
			return
		isDashing=true
		canDash=false
		var dashDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if dashDirection==Vector2.ZERO:
			dashDirection=lastDirection
		velocity = dashDirection.normalized()*500
		
		await get_tree().create_timer(0.3).timeout
		isDashing=false
		
		await get_tree().create_timer(0.8).timeout
		canDash=true
	
func attack():
	if Input.is_action_just_pressed("attack") && !isAttacking:
		if !canAttack:
			return
			
		isAttacking=true
		canAttack=false
		var attackDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if attackDirection==Vector2.ZERO:
			attackDirection=lastDirection
		velocity = attackDirection.normalized()*100
	
		if isRunning:
			isRunning=false
		await get_tree().create_timer(0.3).timeout
		isAttacking=false
		await get_tree().create_timer(0.2).timeout
		canAttack=true
	


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage()
		camera.screenShake(3, 0.3)
	pass # Replace with function body.
