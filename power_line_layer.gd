extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_line_tile(tile_coords, overlay_func, regmap_layer:TileMapLayer, new_line = false) -> void:
	var N_is_line:bool = get_cell_source_id(get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_TOP_SIDE)) >= 0
	var S_is_line:bool = get_cell_source_id(get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)) >= 0
	var E_is_line:bool = get_cell_source_id(	get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)) >= 0
	var W_is_line:bool = get_cell_source_id(	get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_LEFT_SIDE)) >= 0
	
	var tile_is_road:bool = false # may just handle this in region_map.gd and pass here
	var tile_is_pwr_bldg:bool = false # may just handle this in region_map.gd and pass here
	var ploppable_type = -1
	
	# if this is a new power line, always update; otherwise, only update if already a power line
	if(!new_line && get_cell_source_id(tile_coords) < 0):
		return
	
	# check if we need special handling
	tile_is_road = regmap_layer.get_cell_source_id(tile_coords) == regmap_layer.SOURCE_ROAD
	if(regmap_layer.get_cell_source_id(tile_coords) == regmap_layer.SOURCE_PLOPPABLES):
		ploppable_type = regmap_layer.get_cell_tile_data(tile_coords).get_custom_data("tile_type")
		if((ploppable_type == Globals.TYPE_PLANT) || (ploppable_type == Globals.TYPE_SUB_STN)):
			tile_is_pwr_bldg = true
	
	# only allow perpendicular lines if road
	if(tile_is_road): # ADD: ALSO ALLOW IF POWER BUILDING (try adding empty tile to power buildings)
		if(N_is_line && S_is_line):
			if(E_is_line || W_is_line):
				return
		elif(E_is_line && W_is_line):
			if(N_is_line || S_is_line):
				return
		else:
			return
	
	# apply power line tile selection logic -- REFACTOR TO CONST/ENUM ARRAY
	if(tile_is_pwr_bldg):
		if(N_is_line && S_is_line):
			if(E_is_line && W_is_line):
				set_cell(tile_coords, 0, Vector2i(2, 4)) # 4-way intersection
			elif(E_is_line):
				set_cell(tile_coords, 0, Vector2i(2, 6)) # NS-E T-intersection
			elif(W_is_line):
				set_cell(tile_coords, 0, Vector2i(3, 7)) # NS-W T-intersection
			else:
				set_cell(tile_coords, 0, Vector2i(0, 4)) # NS straight
		elif(E_is_line && W_is_line):
			if(N_is_line):
				set_cell(tile_coords, 0, Vector2i(2, 7)) # EW-N T-intersection
			elif(S_is_line):
				set_cell(tile_coords, 0, Vector2i(3, 6)) # EW-S T-intersection
			else:
				set_cell(tile_coords, 0, Vector2i(1, 4)) # EW straight
		elif(N_is_line && !E_is_line && !W_is_line):
			set_cell(tile_coords, 0, Vector2i(0, 5)) # N-center
		elif(S_is_line && !E_is_line && !W_is_line):
			set_cell(tile_coords, 0, Vector2i(1, 5)) # S-center
		elif(E_is_line && !N_is_line && !S_is_line):
			set_cell(tile_coords, 0, Vector2i(2, 5)) # E-center
		elif(W_is_line && !N_is_line && !S_is_line):
			set_cell(tile_coords, 0, Vector2i(3, 5)) # W-center
		elif((S_is_line || E_is_line) && !N_is_line && !W_is_line):
			set_cell(tile_coords, 0, Vector2i(0, 6)) # SE curve
		elif((S_is_line || W_is_line) && !N_is_line && !E_is_line):
			set_cell(tile_coords, 0, Vector2i(1, 6)) # SW curve
		elif((N_is_line || E_is_line) && !S_is_line && !W_is_line):
			set_cell(tile_coords, 0, Vector2i(0, 7)) # NE curve
		elif((N_is_line || W_is_line) && !S_is_line && !E_is_line):
			set_cell(tile_coords, 0, Vector2i(1, 7)) # NW curve
		else:
			set_cell(tile_coords, 0, Vector2i(3, 4)) # blank
	else:
		if(N_is_line && S_is_line):
			if(E_is_line && W_is_line):
				set_cell(tile_coords, 0, Vector2i(2, 0)) # 4-way intersection
			elif(E_is_line):
				set_cell(tile_coords, 0, Vector2i(2, 1)) # NS-E T-intersection
			elif(W_is_line):
				set_cell(tile_coords, 0, Vector2i(3, 2)) # NS-W T-intersection
			else:
				set_cell(tile_coords, 0, Vector2i(0, 0)) # NS straight
		elif(E_is_line && W_is_line):
			if(N_is_line):
				set_cell(tile_coords, 0, Vector2i(2, 2)) # EW-N T-intersection
			elif(S_is_line):
				set_cell(tile_coords, 0, Vector2i(3, 1)) # EW-S T-intersection
			else:
				set_cell(tile_coords, 0, Vector2i(1, 0)) # EW straight
		elif(N_is_line && !E_is_line && !W_is_line):
			set_cell(tile_coords, 0, Vector2i(0, 3)) # N-center
		elif(S_is_line && !E_is_line && !W_is_line):
			set_cell(tile_coords, 0, Vector2i(1, 3)) # S-center
		elif(E_is_line && !N_is_line && !S_is_line):
			set_cell(tile_coords, 0, Vector2i(2, 3)) # E-center
		elif(W_is_line && !N_is_line && !S_is_line):
			set_cell(tile_coords, 0, Vector2i(3, 3)) # W-center
		elif((S_is_line || E_is_line) && !N_is_line && !W_is_line):
			set_cell(tile_coords, 0, Vector2i(0, 1)) # SE curve
		elif((S_is_line || W_is_line) && !N_is_line && !E_is_line):
			set_cell(tile_coords, 0, Vector2i(1, 1)) # SW curve
		elif((N_is_line || E_is_line) && !S_is_line && !W_is_line):
			set_cell(tile_coords, 0, Vector2i(0, 2)) # NE curve
		elif((N_is_line || W_is_line) && !S_is_line && !E_is_line):
			set_cell(tile_coords, 0, Vector2i(1, 2)) # NW curve
		else:
			set_cell(tile_coords, 0, Vector2i(3, 0)) # pylon only
	
	# add construction overlay (temporarily timer-based)
	overlay_func.call(tile_coords, Globals.TYPE_LINES)
