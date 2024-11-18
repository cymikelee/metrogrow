extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_hud_tool_selected(tool, position) -> void:
	$RegionMap.selected_tool = tool
	$HUD/SelectedToolRect.set_position(position)
