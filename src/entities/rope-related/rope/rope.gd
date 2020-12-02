extends Line2D

const SEGMENT = preload("res://src/entities/rope-related/segment-resource/segment-resource.gd")
const COLLISIONSHAPE = preload("res://src/entities/rope-related/rope-collider/rope-collider.tscn")
const GRAVITY = 20 
const FRICTION = 2

var total_rope_segments: float = 25.0
var rope_segment_length: float = 4.0
var max_length: float = 0.0
var old_points: PoolVector2Array = []
var collision_points: Array = []

onready var timer: Timer = $Timer

func _ready():
	for unit in total_rope_segments:
		add_point(Vector2(0, unit))
		var new_shape = COLLISIONSHAPE.instance()
		self.add_child(new_shape)
		new_shape.set_index(unit)
		new_shape.global_position = self.points[unit]
		collision_points.append(new_shape)
		self.points[0].y -= rope_segment_length
	old_points = self.points
	#print(self.points)

func _process(delta: float) -> void:
	self.points[0] = get_parent().get_child(0).global_position
	# PERFORMING THE SIMULATION
	_simulate(delta)
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
	for i in range(total_rope_segments + 1):
		var first_segment_currently: Vector2 = self.points[i]
		var first_segment_previously: Vector2 = self.old_points[i] 
		var velocity: Vector2 = first_segment_currently - first_segment_previously

		self.old_points[i] = first_segment_currently
		velocity.x = lerp(velocity.x, 0, FRICTION * delta)
		first_segment_currently += velocity
		first_segment_currently.y += GRAVITY * delta
		if collision_points[i - 1].is_colliding():
			first_segment_currently = first_segment_previously
		self.points[i] = first_segment_currently
	
func _apply_constraints() -> void:
	for i in range(self.points.size() - 1):
		var first_segment: Vector2 = self.points[i]
		var second_segment: Vector2 = points[i + 1]
		collision_points[i].position = first_segment
		var distance_between_points: float = first_segment.distance_to(second_segment)
		# "error" is the difference or "extra length" between the above recorded distance
		# between two distinct points and our purported "segment length"
		# e.g. (A) if our segment length is 5, and the distance between two points is 10, we have
		# an error of 5; (B) if our segment if 5, and the the distance between two points is 3, we
		# have an error of 2
		var error: float = abs(distance_between_points - rope_segment_length)

		var new_direction: Vector2 = Vector2.ZERO
		# case (A), the distance is greater than the given length, so we need a factor to move
		# it IN by
		if distance_between_points > rope_segment_length:
			new_direction = (first_segment - second_segment).normalized()
		# case (B), the distance is less than the given length, so we need a factor to move it
		# OUT by
		else:
			new_direction = (second_segment - first_segment).normalized()
		
		# we now have a direction, so we multiply it by the error, yielding the point, *relative to
		# a given point*, we need to move to
		var distance_to_travel: Vector2 = new_direction * error		
		# if it is NOT the first point of the rope, the "working end"	
		if i != 0:
			var first_current_position = first_segment
			# we cut it in half, because we need to move both points to produce the required 
			# segment length; in case (A) it would be 2.5, in case (B) it would be 1.5
			first_current_position -= distance_to_travel * 0.5 
			self.points[i] = first_current_position
			var second_current_position = second_segment
			second_current_position += distance_to_travel * 0.5
			self.points[i + 1] = second_current_position
		else:
			var second_current_position = second_segment
			second_current_position += distance_to_travel
			self.points[i + 1] = second_current_position
		



