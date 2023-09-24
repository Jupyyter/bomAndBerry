extends CharacterBody2D

var windsize = Rect2(0,0,DisplayServer.window_get_size().x, DisplayServer.window_get_size().y)
var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	self.velocity.y += rng.randf_range(-0.8, 0.8)

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position += self.velocity
	if !windsize.has_point(self.position):
		self.queue_free()
