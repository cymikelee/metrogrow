extends TileMapLayer

@export var construction_scene: PackedScene

enum { SOURCE_ROAD, SOURCE_ZONES, SOURCE_PLOPPABLES }

var selected_tool = Globals.TYPE_ROAD

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var cur_source:TileSetAtlasSource
	
	$TileSelector.snap_size_x = self.tile_set.tile_size.x
	$TileSelector.snap_size_y = self.tile_set.tile_size.y
	$TileSelector.snap_min_x = self.position.x / self.tile_set.tile_size.x
	$TileSelector.snap_min_y = self.position.y / self.tile_set.tile_size.y
	
	# Figured out how to add these in TileSet editor -- shouldn't be needed
	#cur_source = tile_set.get_source(SOURCE_ROAD)
	#for i in cur_source.get_tiles_count():
		#var cur_data = cur_source.get_tile_data(cur_source.get_tile_id(i), 0)
		#cur_data.set_custom_data("tile_type", Globals.TYPE_ROAD)
	#
	#cur_source = tile_set.get_source(SOURCE_ZONES)
	#cur_source.set("0:0/0/tile_type", Globals.TYPE_IND_ZONE)
	#cur_source.set("1:0/0/tile_type", Globals.TYPE_IND_ZONE)
	#cur_source.set("0:1/0/tile_type", Globals.TYPE_RES_ZONE)
	#cur_source.set("1:1/0/tile_type", Globals.TYPE_RES_ZONE)
	#cur_source.set("0:2/0/tile_type", Globals.TYPE_COM_ZONE)
	#cur_source.set("1:2/0/tile_type", Globals.TYPE_COM_ZONE)
	#cur_source.set("0:3/0/tile_type", Globals.TYPE_MIX_ZONE)
	#cur_source.set("1:3/0/tile_type", Globals.TYPE_MIX_ZONE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _add_construction_overlay(tile_coords, tile_type) -> void:
	var construction_tile:ColorRect = construction_scene.instantiate()
	construction_tile.set_position(
		map_to_local(tile_coords) -
		Vector2(self.tile_set.tile_size.x / 2, self.tile_set.tile_size.y / 2)
	)
	match tile_type:
		Globals.TYPE_RES_ZONE, Globals.TYPE_COM_ZONE, Globals.TYPE_IND_ZONE, Globals.TYPE_MIX_ZONE:
			construction_tile.build_started.connect(Callable(_select_zone_tile).bind(tile_coords, tile_type))
	add_child(construction_tile)

func _update_road_tile(tile_coords, new_road = false) -> void:
	var N_is_road:bool = get_cell_source_id(get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_TOP_SIDE)) == SOURCE_ROAD
	var S_is_road:bool = get_cell_source_id(get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)) == SOURCE_ROAD
	var E_is_road:bool = get_cell_source_id(get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)) == SOURCE_ROAD
	var W_is_road:bool = get_cell_source_id(get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_LEFT_SIDE)) == SOURCE_ROAD
	
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
	_add_construction_overlay(tile_coords, Globals.TYPE_ROAD)

func _select_zone_tile(tile_coords, zone_type) -> void:
	match zone_type:
		Globals.TYPE_RES_ZONE:
			set_cell(tile_coords, SOURCE_ZONES, Vector2i(1, 0))
		Globals.TYPE_COM_ZONE:
			set_cell(tile_coords, SOURCE_ZONES, Vector2i(1, 1))
		Globals.TYPE_IND_ZONE:
			set_cell(tile_coords, SOURCE_ZONES, Vector2i(1, 2))
		Globals.TYPE_MIX_ZONE:
			set_cell(tile_coords, SOURCE_ZONES, Vector2i(1, 3))

func _physics_process(delta) -> void:
	if(Input.is_action_just_pressed("mb_left")):
		var tile_coords:Vector2i = (
			local_to_map($TileSelector.mouse_pos * self.tile_set.tile_size.x) -
			Vector2i(position.x / self.tile_set.tile_size.x, position.y / self.tile_set.tile_size.y)
		)
		var cur_source = get_cell_source_id(tile_coords)
		var coords_N = get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_TOP_SIDE)
		var coords_S = get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
		var coords_E = get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)
		var coords_W = get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_LEFT_SIDE)
		
		# update selected cell
		if(selected_tool == Globals.TYPE_DOZER):
			set_cell(tile_coords, -1)
			if(cur_source == SOURCE_ROAD):
				_update_road_tile(coords_N)
				_update_road_tile(coords_S)
				_update_road_tile(coords_E)
				_update_road_tile(coords_W)
		elif(cur_source == -1):
			match selected_tool:
				Globals.TYPE_ROAD:
					# update selected cell
					_update_road_tile(tile_coords, true)
					# update neighboring cells
					_update_road_tile(coords_N)
					_update_road_tile(coords_S)
					_update_road_tile(coords_E)
					_update_road_tile(coords_W)
				Globals.TYPE_RES_ZONE:
					set_cell(tile_coords, SOURCE_ZONES, Vector2i(0, 0))
				Globals.TYPE_COM_ZONE:
					set_cell(tile_coords, SOURCE_ZONES, Vector2i(0, 1))
				Globals.TYPE_IND_ZONE:
					set_cell(tile_coords, SOURCE_ZONES, Vector2i(0, 2))
				Globals.TYPE_MIX_ZONE:
					set_cell(tile_coords, SOURCE_ZONES, Vector2i(0, 3))
				Globals.TYPE_PLANT:
					set_cell(tile_coords, SOURCE_PLOPPABLES, Vector2i(0, 0))
				Globals.TYPE_POLICE:
					set_cell(tile_coords, SOURCE_PLOPPABLES, Vector2i(0, 1))
				Globals.TYPE_FIRE:
					set_cell(tile_coords, SOURCE_PLOPPABLES, Vector2i(0, 2))
				Globals.TYPE_HOSPITAL:
					set_cell(tile_coords, SOURCE_PLOPPABLES, Vector2i(0, 3))
				Globals.TYPE_SCHOOL:
					set_cell(tile_coords, SOURCE_PLOPPABLES, Vector2i(0, 4))
				Globals.TYPE_PARK:
					set_cell(tile_coords, SOURCE_PLOPPABLES, Vector2i(0, 5))
			if(selected_tool != Globals.TYPE_ROAD):
				_add_construction_overlay(tile_coords, selected_tool)
	
