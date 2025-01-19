extends TileMapLayer

enum { SOURCE_ROAD, SOURCE_ZONES, SOURCE_PLOPPABLES }

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_road_tile(tile_coords, overlay_func, new_road = false) -> void:
	var N_is_road:bool = get_cell_source_id(
		get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_TOP_SIDE)
	) == SOURCE_ROAD
	var S_is_road:bool = get_cell_source_id(
		get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
	) == SOURCE_ROAD
	var E_is_road:bool = get_cell_source_id(
		get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)
	) == SOURCE_ROAD
	var W_is_road:bool = get_cell_source_id(
		get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_LEFT_SIDE)
	) == SOURCE_ROAD
	
	# if this is a new road, always update; otherwise, only update if already a road
	if(!new_road && get_cell_source_id(tile_coords) != SOURCE_ROAD):
		return
	
	# apply road tile selection logic
	if(N_is_road && S_is_road):
		if(E_is_road && W_is_road):
			set_cell(tile_coords, SOURCE_ROAD, Vector2i(2, 0)) # 4-way intersection
		elif(E_is_road):
			set_cell(tile_coords, SOURCE_ROAD, Vector2i(2, 1)) # NS-E T-intersection
		elif(W_is_road):
			set_cell(tile_coords, SOURCE_ROAD, Vector2i(3, 2)) # NS-W T-intersection
		else:
			set_cell(tile_coords, SOURCE_ROAD, Vector2i(0, 0)) # NS straight
	elif(E_is_road && W_is_road):
		if(N_is_road):
			set_cell(tile_coords, SOURCE_ROAD, Vector2i(2, 2)) # EW-N T-intersection
		elif(S_is_road):
			set_cell(tile_coords, SOURCE_ROAD, Vector2i(3, 1)) # EW-S T-intersection
		else:
			set_cell(tile_coords, 0, Vector2i(1, 0)) # EW straight
	elif((N_is_road || S_is_road) && !E_is_road && !W_is_road):
		set_cell(tile_coords, SOURCE_ROAD, Vector2i(0, 0)) # NS straight
	elif((E_is_road || W_is_road) && !N_is_road && !S_is_road):
		set_cell(tile_coords, SOURCE_ROAD, Vector2i(1, 0)) # EW straight
	elif((S_is_road || E_is_road) && !N_is_road && !W_is_road):
		set_cell(tile_coords, SOURCE_ROAD, Vector2i(0, 1)) # SE curve
	elif((S_is_road || W_is_road) && !N_is_road && !E_is_road):
		set_cell(tile_coords, SOURCE_ROAD, Vector2i(1, 1)) # SW curve
	elif((N_is_road || E_is_road) && !S_is_road && !W_is_road):
		set_cell(tile_coords, SOURCE_ROAD, Vector2i(0, 2)) # NE curve
	elif((N_is_road || W_is_road) && !S_is_road && !E_is_road):
		set_cell(tile_coords, SOURCE_ROAD, Vector2i(1, 2)) # NW curve
	else:
		set_cell(tile_coords, SOURCE_ROAD, Vector2i(3, 0)) # blank
	
	# add construction overlay (temporarily timer-based)
	overlay_func.call(tile_coords, Globals.TYPE_ROAD)

func select_zone_tile(tile_coords, zone_type) -> void:
	match zone_type:
		Globals.TYPE_RES_ZONE:
			set_cell(tile_coords, SOURCE_ZONES, Vector2i(1, 0))
		Globals.TYPE_COM_ZONE:
			set_cell(tile_coords, SOURCE_ZONES, Vector2i(1, 1))
		Globals.TYPE_IND_ZONE:
			set_cell(tile_coords, SOURCE_ZONES, Vector2i(1, 2))
		Globals.TYPE_MIX_ZONE:
			set_cell(tile_coords, SOURCE_ZONES, Vector2i(1, 3))
