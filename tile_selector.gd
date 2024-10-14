extends Sprite2D

@export var snap_size_x:int #= 24;
@export var snap_size_y:int #= 24;
@export var snap_min_x:int
@export var snap_min_y:int

var mouse_pos:Vector2 = Vector2.ZERO

func _physics_process(delta) -> void:
	update_position_snapped()

func update_position_snapped():
	mouse_pos = Vector2(int(get_global_mouse_position().x / snap_size_x),
						int(get_global_mouse_position().y / snap_size_y))
	
	if(mouse_pos.x >= snap_min_x && mouse_pos.y >= snap_min_y):
		self.show()
		global_position = mouse_pos * snap_size_x
	else:
		self.hide()
