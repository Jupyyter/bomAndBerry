extends CanvasLayer
class_name textBoxClass

#the higher the number, the slower the text will appear
const CHAR_READ_RATE = 0.02

@export var textureRect: TextureRect
@export var textbox_container: MarginContainer
@export var start_symbol: Label
@export var end_symbol: Label
@export var label: Label
@export var boxContainer:HBoxContainer

var IndexChosen:int=0
var lastIndexChosen:int=0

enum State { ready, newText, reading, finished }
var current_state: State = State.ready
var text_queue: Array = []
var conv_queue:Array=[]
var tween: Tween
var chooseMode:bool=false
var fastText:bool=false
var inConversation:bool=false

var LabelList2:Array[Label]
var currentStateList2:Array[State]
var LabelList:Array[Label]
var currentStateList:Array[State]

func _ready():

	hide_textbox()


#displays all the queued texts
func _process(delta):
	choosingResponse()
	for lbl in LabelList2:
		match currentStateList2[LabelList2.find(lbl)]:
			State.ready:
				if !text_queue.is_empty():
					currentStateList2[LabelList2.find(lbl)] = State.newText
					current_state= State.newText
			State.newText:
				if !text_queue.is_empty():
					end_symbol.text = ""
					colorReset(lbl)
					displayText(lbl)
				else:
					if !conv_queue.is_empty():
						var next_text:String=conv_queue.pop_front()
						if next_text.begins_with("!-"):
							next_text=next_text.substr(2)
							createConvPage(next_text)
							
						elif next_text.begins_with("#-"):
							next_text=next_text.substr(2)
							createQuestionPage(next_text)
					else:
						currentStateList2[LabelList2.find(lbl)] = State.ready
						current_state= State.ready
			State.reading:
				#ui_end must be set in godot
				if Input.is_action_just_pressed("ui_end") and !chooseMode:
					tween.kill()
					visibleRacio1()
					end_symbol.text = ":)"
					currentStateList2[LabelList2.find(lbl)] = State.finished
					current_state= State.finished
			State.finished:
				#ui_accept must be set in godot
				if Input.is_action_just_pressed("ui_accept") or fastText:
					currentStateList2[LabelList2.find(lbl)] = State.newText
					current_state= State.newText
					chooseMode=false
					fastText=false
					if text_queue.is_empty() and conv_queue.is_empty() and !inConversation:
						#DELETE ALL THE CHILDREN DIEDIEDIEDIEDIE
						#GABRIEL EATING MY MEMORY HAHAHAHAHAHAHAHAAHAHAHAHAHAHAHAAHAHAHAHAHAHAAHAHA
						hide_textbox()



func queue_text(next_text: String)->void:
	if text_queue.is_empty():
		createConvPage(next_text)
	else:
		next_text="!-"+next_text
		conv_queue.push_back(next_text)
func queue_questionResponse(next_text: String)->void:
	if text_queue.is_empty():
		createQuestionPage(next_text)

	else:
		next_text="#-"+next_text
		conv_queue.push_back(next_text)

#display 1 text at a time using tween, changes texture and the color accordingly
func displayText(lbl:Label)->void:
	show_textbox()
	var next_text: String = text_queue.pop_front()
	for i in next_text.count("--")+1:
		var parts:int = next_text.find("--")
		#dealing with the text properties (like colored text)
		if parts != -1 or i!=0:
			var after: String = next_text.substr(parts + 1).strip_edges()
			var before: String= next_text.substr(0, parts).strip_edges()
			next_text=after
			#idk
			if i==0:
					lbl.text = before
					setTexture(null)
			else:
				match before:
					"-red":
						text_box.colorRed(lbl)
					"-fast":
						fastText=true
					_:
						setTexture(before)
						start_symbol.text = ""
			
		elif i==0:
			lbl.text = next_text
			setTexture(null)
	#basically makes the text tween instead of spawning
	lbl.visible_ratio = 0
	currentStateList[LabelList.find(lbl)]  = State.reading
	current_state=State.reading
	currentStateList2=currentStateList.duplicate()
	tween = create_tween()
	tween.tween_property(lbl, "visible_ratio", 1, CHAR_READ_RATE*lbl.text.length())
	tween.connect("finished", finishedTweening )

#guess what it does
func hide_textbox()->void:
	start_symbol.text = ""
	end_symbol.text = ""
	textbox_container.hide()

#guess what it does
func show_textbox()->void:
	start_symbol.text = "*"
	textbox_container.show()

func isOn()->bool:
	return textbox_container.visible

func finishedTweening()->void:  #connedcted with tween's finished signal
	end_symbol.text = ":)"
	if current_state==State.reading: # this is "if" absolutely needed in case a label finished tweening but the others don't and you press "ui_accept"
		for lbl in LabelList2:
			currentStateList[LabelList.find(lbl)] = State.finished
			currentStateList2[LabelList2.find(lbl)] = State.finished
			current_state=State.finished

#character speaking or something
func enableImage()->void:
	textureRect.visible = true

#character no longer speaking or something
func disableImage()->void:
	textureRect.visible = false

#what character is speaking
func setTexture(texture)->void:
	if texture == null:
		textureRect.texture = null
	else:
		textureRect.texture = load("res://images/" + texture + ".png")

func colorRed(lbl:Label)->void:
	#lbl.add_theme_color_override("font_color",Color(180,0,0))
	lbl.add_theme_color_override("font_color",Color(180,0,0))

func colorReset(lbl:Label)->void:
	#lbl.add_theme_color_override("font_color",Color.WHITE)
	lbl.add_theme_color_override("font_color",Color.WHITE)

#create new label :)
func initializeNewLabel()->void:

	var lblInstance=label.duplicate()
	lblInstance.show()
	LabelList.push_back(lblInstance)
	boxContainer.add_child(lblInstance)
	boxContainer.move_child(lblInstance,boxContainer.get_child_count()-2)
	LabelList2=LabelList.duplicate()

	var stateInstance:State=State.ready
	currentStateList.push_back(stateInstance)
	currentStateList2=currentStateList.duplicate()

#when choosing a response or an action
func choosingResponse()->int:
	if(!chooseMode):
		return 0
	
	if Input.is_action_just_pressed("ui_right"):
		IndexChosen+=1
	if Input.is_action_just_pressed("ui_left"):
		IndexChosen-=1
	if IndexChosen > LabelList2.size()-1:
		IndexChosen=LabelList2.size()-1
	elif IndexChosen < 0:
		IndexChosen=0
	if !LabelList2[IndexChosen].has_theme_stylebox_override ("normal"):
		LabelList2[IndexChosen].add_theme_stylebox_override("normal",createStyleBox())
	elif IndexChosen!=lastIndexChosen:
		LabelList2[lastIndexChosen].remove_theme_stylebox_override("normal")
		lastIndexChosen=IndexChosen
	return IndexChosen

#returns a reference to an object within the array
func findThingInArray(lbl: Node, arr: Array) -> Node:
	for labell in arr:
		if labell == lbl:
			return labell
	return null

#returns a reference to the child of the node
func findThingInNode(child:Node,nod2:Node)->Node:
	for thing in nod2.get_children():
		if thing==child:
			return child
	return null

#returns a styleBox
func createStyleBox()->StyleBoxFlat:
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(183, 196, 67)
	style_box.border_color = Color("B7C443")
	style_box.draw_center=false
	style_box.set_border_width_all(2)
	style_box.set_content_margin_all(0)
	style_box.set_expand_margin_all(4)
	return style_box

#kill all the labels
func resetLabels()->void:
	for lbl in LabelList2:
		findThingInNode(lbl,boxContainer).queue_free()
		currentStateList.erase(currentStateList[LabelList.find(lbl)])
		LabelList.erase(lbl)
	currentStateList2.clear()
	LabelList2.clear()

#creates 1 label and queues queue_texts based on the number of lines
func createConvPage(next_text:String)->void:
	var lines:PackedStringArray = next_text.split("\n")
	resetLabels()
	initializeNewLabel()
	for line in lines:
		text_queue.push_back(line)
#creates n labels and n queue _texts based on tbe number of lines and 
func createQuestionPage(next_text:String)->void:
	resetLabels()
	IndexChosen=0
	lastIndexChosen=0
	chooseMode=true
	var lines:PackedStringArray = next_text.split("\n")
	for line in lines:
		text_queue.push_back(line)
		initializeNewLabel()

#set all labels visible ratio to 1
func visibleRacio1():
	for lbl in LabelList2:
		lbl.visible_ratio=1
