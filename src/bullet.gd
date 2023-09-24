extends CharacterBody2D

@onready var sprite2D =$Sprite2D
@export var animatedSprite:AnimatedSprite2D

var windsize:Rect2 = Rect2(0,0,DisplayServer.window_get_size().x, DisplayServer.window_get_size().y)
var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	self.velocity.y += rng.randf_range(-0.8, 0.8)
	animatedSprite.visible = false
	#self.get_node("hit").play() 
func _physics_process(delta):
	var collisioninfo:KinematicCollision2D = move_and_collide(self.velocity)
	if collisioninfo && collisioninfo.get_collider().name == "bouse":
		sprite2D.visible = false
		animatedSprite.visible = true
		animatedSprite.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#self.position += self.velocity
	if animatedSprite.frame == 4:
		self.queue_free()
