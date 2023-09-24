extends CharacterBody2D

class_name player

var speed:int=200
var shooting:bool=false #used to determine when to switch to shooting sprites
var flipped:bool=false #if the character is flipped
var rotate:int=1
var originalRotation:float=self.rotation_degrees
@onready var animationPlayer =$AnimationPlayer
@onready var collisionshape2D =$CollisionShape2D
@onready var sprite2D =$Sprite2D
@onready var time =$Timer
# Called when the node enters the scene tree for the first time.
func _ready():
	time.stop()


func _process(delta):
	get_input()

func _physics_process(delta):
	move_and_slide()

func get_input()->void:
	var input_direction :Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_direction * speed
	
	#rotate player when moving
	if velocity!=Vector2.ZERO:
		if time.is_stopped():
			rotate*=-1
			self.rotation_degrees=originalRotation+10*rotate
			time.start()
	else:
		self.rotation_degrees=originalRotation
		time.stop()

	if Input.is_action_pressed("mouseLeft"):
		shooting=true
	else:
		shooting=false
		
	#get the direction vector from the character to the cursor
	var direction:Vector2 = (get_global_mouse_position() - global_position).normalized()
	var degrees:float=vectorToDegrees(direction)
	#determine which animation to play based on the angle
	var animation_name:String = get_animation_name(degrees)

	animationPlayer.play(animation_name)

	#flip player
	if degrees>90 and degrees<270:
		if !flipped:
			sprite2D.scale.x=-1
			collisionshape2D.scale.x=-1
			flipped=true
	else:
		if flipped:
			sprite2D.scale.x=1
			collisionshape2D.scale.x=1
			flipped=false

#used for normal movement
func getSprite()->String:
	var sprite:String=""
	if velocity.x!=0:
		sprite+="right"
	elif velocity.y>0:
		sprite+="down"
	elif velocity.y<0:
		sprite+="up"
	if shooting==true:
		sprite+="Shoot"
	else:
		sprite+="Normal"
	return sprite

func get_animation_name(angle_deg)->String:
	#define the animation names and their corresponding angle ranges
	#0 right 45 up 135 right 225 down 315 right 360
	var angles = [0, 45, 135, 225, 315, 360]
	var animations = ["right", "up", "right", "down", "right"]

	var animationName:String = "down" # default animation if angle is outside the ranges
	#find the correct animation based on the angle
	for i in range(angles.size() - 1):
		if angle_deg >= angles[i] and angle_deg < angles[i + 1]:
			animationName = animations[i]

	#if you shoot the Bom will shoot
	if shooting==true:
		animationName+="Shoot"
	else:
		animationName+="Normal"
	return animationName


func vectorToDegrees(vector: Vector2) -> float:
	#calculate the angle in radians using atan2
	var angle_radians = atan2(-vector.y, vector.x)  # negate y-component to match the counterclockwise rotation
	
	#convert radians to degrees using rad2deg
	var angle_degrees = rad_to_deg(angle_radians)
	
	#make sure the angle is in the range [0, 360)
	angle_degrees = fmod(angle_degrees, 360)
	
	#ensure the angle is positive (fmod might return negative values)
	if angle_degrees < 0:
		angle_degrees += 360

	return angle_degrees


func _on_timer_timeout():
	rotate*=-1
	self.rotation_degrees=originalRotation+10*rotate
