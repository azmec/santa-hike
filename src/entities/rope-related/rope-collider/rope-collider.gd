extends Area2D

var _colliding_body = null
var _is_colliding: bool = false
var _index: int = 0 

func _ready():
	self.connect("body_entered", self, "_on_body_entered")
	self.connect("body_exited", self, "_on_body_exited")

func is_colliding() -> bool:
	return _is_colliding

func get_colliding_body():
	return _colliding_body 

func set_index(new_index: int) -> void:
	self._index = new_index

func get_index() -> int:
	return self._index

func _on_body_entered(body) -> void:
	_is_colliding = true
	_colliding_body = body
	print(is_colliding())

func _on_body_exited(_body) -> void:
	_is_colliding = false
	_colliding_body = null
	print(is_colliding())
