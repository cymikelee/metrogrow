extends CanvasLayer

signal tool_selected(tool: int, position: Vector2i)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func update_selected_tool(tool, position):
	tool_selected.emit(tool, position)
