extends KinematicBody2D

enum {
	IDLE,
	WALK,
	JUMP,
	FALL
}

const MAX_SPEED: int = 100
const ACCELERATION: int = 100
const FRICTION: int = 50
const AIR_FRICTION: int = 10
const JUMP_STRENGTH: int = 120
const GRAVITY: int = 300
# This is the length of time the game will assume the player is "grouned" after
# they walk off a ledge
const COYOTE_TIME: float = 0.1
# This is the length of time the game will "remember" a jump input while in the air or ground
const JUMP_TIME: float = 0.1

var velocity: Vector2 = Vector2(0, 0)
var state: int = 0
var current_jumps: int = 1
var max_jumps: int = 1
var x_input: int = 0

onready var sprite: Sprite = $Sprite
onready var coyoteTimer: Timer = $CoyoteTimer
onready var jumpTimer: Timer = $JumpTimer

func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	x_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if is_on_floor():
		coyoteTimer.start(COYOTE_TIME)
		current_jumps = max_jumps
	if Input.is_action_just_pressed("jump"):
		jumpTimer.start(JUMP_TIME)
	
	match state:
		IDLE:
			velocity.x = lerp(velocity.x, 0, FRICTION * delta)
			if x_input != 0:
				state = WALK
			if not jumpTimer.is_stopped() and current_jumps > 0:
				jumpTimer.stop()
				velocity.y = -JUMP_STRENGTH
				current_jumps = current_jumps - 1
				state = JUMP
			if not is_on_floor() and coyoteTimer.is_stopped():
				state = FALL
		WALK:
			velocity.x += x_input * ACCELERATION * delta
			velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
			if x_input == 0:
				state = IDLE
			if not jumpTimer.is_stopped() and current_jumps > 0:
				jumpTimer.stop()
				velocity.y = -JUMP_STRENGTH
				current_jumps = current_jumps - 1
				state = JUMP
			if not is_on_floor() and coyoteTimer.is_stopped():
				state = FALL
		JUMP:
			velocity.x += x_input * ACCELERATION * delta
			velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
			if x_input == 0:
				velocity.x = lerp(velocity.x, 0, AIR_FRICTION * delta)
			if Input.is_action_just_released("jump") and velocity.y < -JUMP_STRENGTH / 2:
				velocity.y = -JUMP_STRENGTH / 2
			if velocity.y > -JUMP_STRENGTH / 2:
				state = FALL
			if not jumpTimer.is_stopped() and current_jumps > 0:
				jumpTimer.stop()
				velocity.y = -JUMP_STRENGTH
				current_jumps = current_jumps - 1
		FALL:
			velocity.x += x_input * ACCELERATION * delta
			velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
			if x_input == 0:
				velocity.x = lerp(velocity.x, 0, AIR_FRICTION * delta)
			if not jumpTimer.is_stopped() and current_jumps > 0:
				jumpTimer.stop()
				velocity.y = -JUMP_STRENGTH
				current_jumps = current_jumps - 1
				state = JUMP
			if is_on_floor():
				if x_input != 0:
					state = WALK 
				else:
					state = IDLE

	if x_input != 0:
		sprite.flip_h = x_input < 0
	velocity.y = velocity.y + GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)