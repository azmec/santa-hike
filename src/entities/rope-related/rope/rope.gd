extends Line2D

const SEGMENT = preload("res://src/entities/rope-related/segment-resource/segment-resource.gd")
const COLLISIONSHAPE = preload("res://src/entities/rope-related/rope-collider/rope-collider.tscn")
const GRAVITY = 20 
const FRICTION = 2

var total_rope_segments: float = 25.0
var rope_segment_length: float = 4.0
var max_length: float = 0.0
var collision_points: Array = []
var segments: Array = []

onready var timer: Timer = $Timer

func _ready():
	for unit in total_rope_segments:
		var position: Vector2 = Vector2(0, unit)
		self.add_point(position)
		var new_segment = SEGMENT.new()
		segments.append(new_segment)
		var new_collision_shape = COLLISIONSHAPE.instance()
		collision_points.append(new_collision_shape)
		new_segment.old_position = position
		new_segment.new_position = position
		self.add_child(new_collision_shape)
		new_collision_shape.set_index(unit)
		new_collision_shape.global_position = self.points[unit]
		self.points[unit] = new_segment.new_position
		self.points[0].y = self.points[0].y - rope_segment_length	

func _process(delta: float) -> void:
	self.points[0] = get_global_mouse_position()
	# PERFORMING THE SIMULATION
	#_simulate(delta)
	# CONSTRAINING THE SIMULATION
	for i in range(0, 100):
		_apply_constraints()

	#print(get_simulated_rope_length())

# returns the total simulated length of the rope; the ideal is the total amount of segments 
# multiplied by their length (25 segments * a length of 4 = a length of 100)
func get_simulated_rope_length() -> float:
	var length: float = 0
	for i in range(self.points.size() - 1):
		var first_point: Vector2 = self.points[i]
		var second_point: Vector2 = self.points[i + 1]
		var distance: float = first_point.distance_to(second_point)
		length += distance
	return length

func _simulate(delta: float) -> void:
	for i in range(self.segments.size()):
		var segment = self.segments[i]
		var velocity: Vector2 = segment.new_position - segment.old_position
		velocity.x = lerp(velocity.x, 0, FRICTION * delta)
		segment.new_position = segment.new_position + velocity
		#segment.new_position.y = segment.new_position.y + GRAVITY * delta
		if collision_points[i].is_colliding():
			segment.new_position = segment.old_position
		self.points[i] = segment.new_position
	
func _apply_constraints() -> void:
	for i in range(self.segments.size() - 1):
		var first_segment = self.segments[i]
		var second_segment = self.segments[i + 1]
		collision_points[i].position = first_segment.new_position
		var distance_between_points: float = first_segment.new_position.distance_to(second_segment.new_position)
		var error: float = abs(distance_between_points - rope_segment_length)

		var new_direction: Vector2 = Vector2.ZERO
		if distance_between_points > rope_segment_length:
			new_direction = (first_segment.new_position - second_segment.new_position).normalized()
		else:
			new_direction = (second_segment.new_position - first_segment.new_position).normalized()
		
		var distance_to_travel: Vector2 = new_direction * error
		if i != 0:
			first_segment.new_position = first_segment.new_position - distance_to_travel * 0.5
			second_segment.new_position = second_segment.new_position + distance_to_travel * 0.5
			self.points[i] = first_segment.new_position
			self.points[i + 1] = second_segment.new_position
		else:
			second_segment.new_position = second_segment.new_position + distance_to_travel
			self.points[i + 1] = second_segment.new_position




