extends CanvasLayer

signal tool_selected(tool: int, position: Vector2i)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TextureButtonDozer.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_DOZER, $TextureButtonDozer.position))
	$TextureButtonPlant.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_PLANT, $TextureButtonPlant.position))
	$TextureButtonLines.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_LINES, $TextureButtonLines.position))
	$TextureButtonSubStn.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_SUB_STN, $TextureButtonSubStn.position))
	$TextureButtonRoad.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_ROAD, $TextureButtonRoad.position))
	$TextureButtonBusStop.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_BUS_STOP, $TextureButtonBusStop.position))
	$TextureButtonResZone.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_RES_ZONE, $TextureButtonResZone.position))
	$TextureButtonComZone.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_COM_ZONE, $TextureButtonComZone.position))
	$TextureButtonIndZone.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_IND_ZONE, $TextureButtonIndZone.position))
	$TextureButtonMixZone.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_MIX_ZONE, $TextureButtonMixZone.position))
	$TextureButtonHospital.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_HOSPITAL, $TextureButtonHospital.position))
	$TextureButtonSchool.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_SCHOOL, $TextureButtonSchool.position))
	$TextureButtonPolice.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_POLICE, $TextureButtonPolice.position))
	$TextureButtonFire.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_FIRE, $TextureButtonFire.position))
	$TextureButtonPark.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_PARK, $TextureButtonPark.position))
	#$TextureButtonDock.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_DOCK, $TextureButtonDock.position))
	#$TextureButtonAirport.pressed.connect(Callable(update_selected_tool).bind(Globals.TYPE_AIRPORT, $TextureButtonAirport.position))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_selected_tool(tool, position) -> void:
	tool_selected.emit(tool, position)
