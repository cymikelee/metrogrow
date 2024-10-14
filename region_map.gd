extends TileMap

enum {TOOL_DOZER, TOOL_ROAD}
var selected_tool = TOOL_ROAD

# Called when the node enters the scene tree for the first time.
func _ready():
	$TileSelector.snap_size_x = self.tile_set.tile_size.x
	$TileSelector.snap_size_y = self.tile_set.tile_size.y
	$TileSelector.snap_min_x = self.position.x / self.tile_set.tile_size.x
	$TileSelector.snap_min_y = self.position.y / self.tile_set.tile_size.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _update_map_cell(tile_coords):
	var tile_N = get_cell_source_id(0, get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_TOP_SIDE))
	var tile_S = get_cell_source_id(0, get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE))
	var tile_E = get_cell_source_id(0, get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_RIGHT_SIDE))
	var tile_W = get_cell_source_id(0, get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_LEFT_SIDE))
	
	if(tile_N >= 0 && tile_S >= 0):
		if(tile_E >= 0 && tile_W >= 0):
			set_cell(0, tile_coords, 0, Vector2i(2, 0)) # 4-way intersection
		elif(tile_E >= 0):
			set_cell(0, tile_coords, 0, Vector2i(2, 1)) # NS-E T-intersection
		elif(tile_W >= 0):
			set_cell(0, tile_coords, 0, Vector2i(3, 2)) # NS-W T-intersection
		else:
			set_cell(0, tile_coords, 0, Vector2i(0, 0)) # NS straight
	elif(tile_E >= 0 && tile_W >= 0):
		if(tile_N >= 0):
			set_cell(0, tile_coords, 0, Vector2i(2, 2)) # EW-N T-intersection
		elif(tile_S >= 0):
			set_cell(0, tile_coords, 0, Vector2i(3, 1)) # EW-S T-intersection
		else:
			set_cell(0, tile_coords, 0, Vector2i(1, 0)) # EW straight
	elif((tile_N >= 0 || tile_S >= 0) && (tile_E == -1) && (tile_W == -1)):
		set_cell(0, tile_coords, 0, Vector2i(0, 0)) # NS straight
	elif((tile_E >= 0 || tile_W >= 0) && (tile_N == -1) && (tile_S == -1)):
		set_cell(0, tile_coords, 0, Vector2i(1, 0)) # EW straight
	elif((tile_S >= 0 || tile_E >= 0) && (tile_N == -1) && (tile_W == -1)):
		set_cell(0, tile_coords, 0, Vector2i(0, 1)) # SE curve
	elif((tile_S >= 0 || tile_W >= 0) && (tile_N == -1) && (tile_E == -1)):
		set_cell(0, tile_coords, 0, Vector2i(1, 1)) # SW curve
	elif((tile_N >= 0 || tile_E >= 0) && (tile_S == -1) && (tile_W == -1)):
		set_cell(0, tile_coords, 0, Vector2i(0, 2)) # NE curve
	elif((tile_N >= 0 || tile_W >= 0) && (tile_S == -1) && (tile_E == -1)):
		set_cell(0, tile_coords, 0, Vector2i(1, 2)) # NW curve
	else:
		set_cell(0, tile_coords, 0, Vector2i(3, 0)) # blank

func _physics_process(delta) -> void:
	if(Input.is_action_just_pressed("mb_left")):
		var tile_coords:Vector2i = (
			local_to_map($TileSelector.mouse_pos * self.tile_set.tile_size.x) -
			Vector2i(position.x / self.tile_set.tile_size.x, position.y / self.tile_set.tile_size.y)
		)
		
		var coords_N = get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_TOP_SIDE)
		var coords_S = get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
		var coords_E = get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)
		var coords_W = get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_LEFT_SIDE)
		
		# update selected cell
		if(selected_tool == TOOL_DOZER):
			set_cell(0, tile_coords, -1)
		elif(selected_tool == TOOL_ROAD):
			if(get_cell_source_id(0, tile_coords) == -1):
				# update selected cell
				_update_map_cell(tile_coords)
			
		# update neighboring cells
		if(get_cell_source_id(0, coords_N) >= 0):
			_update_map_cell(coords_N)
		if(get_cell_source_id(0, coords_S) >= 0):
			_update_map_cell(coords_S)
		if(get_cell_source_id(0, coords_E) >= 0):
			_update_map_cell(coords_E)
		if(get_cell_source_id(0, coords_W) >= 0):
			_update_map_cell(coords_W)
			
