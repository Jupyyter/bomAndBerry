extends Node

var playerAnimation:String=""
var levelStart:bool=true
var knifeTaken:bool=false
var nearRat:bool=false
var nearCat:bool=false
var flapjackCry:bool=false
var nearFlapjack2:bool=false
var convState:Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getPlayer()->player:
	#be sure to add a group named "player" on player :)
	return get_tree().get_nodes_in_group("player")[0]

func getCurrentScene()->Node:
	return get_tree().current_scene

func removeNode(node:Node,delete:bool=false):
	if !delete:
		node.get_parent().remove_child(node)
	else:
		node.queue_free()
