extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	linear_velocity = Vector2(1000, 0).rotated(rotation)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
