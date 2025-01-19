extends Node2D

@export var construction_scene: PackedScene

enum { SOURCE_ROAD, SOURCE_ZONES, SOURCE_PLOPPABLES }

var selected_tool = Globals.TYPE_ROAD

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TileSelector.snap_size_x = $RegionMapLayer.tile_set.tile_size.x
	$TileSelector.snap_size_y = $RegionMapLayer.tile_set.tile_size.y
	$TileSelector.snap_min_x = $RegionMapLayer.position.x / $RegionMapLayer.tile_set.tile_size.x
	$TileSelector.snap_min_y = $RegionMapLayer.position.y / $RegionMapLayer.tile_set.tile_size.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _add_construction_overlay(tile_coords, tile_type) -> void:
	var construction_tile:ColorRect = construction_scene.instantiate()
	construction_tile.set_build_time(Globals.BUILD_TIMES[tile_type])
	construction_tile.set_position(
		$RegionMapLayer.map_to_local(tile_coords) -
		Vector2($RegionMapLayer.tile_set.tile_size.x / 2, $RegionMapLayer.tile_set.tile_size.y / 2)
	)
	match tile_type:
		Globals.TYPE_RES_ZONE, Globals.TYPE_COM_ZONE, Globals.TYPE_IND_ZONE, Globals.TYPE_MIX_ZONE:
			construction_tile.build_started.connect(
				Callable($RegionMapLayer.select_zone_tile).bind(tile_coords, tile_type)
			)
	add_child(construction_tile)


func _physics_process(delta) -> void:
	if(Input.is_action_just_pressed("mb_left")):
		var tile_coords:Vector2i = (
			$RegionMapLayer.local_to_map(
				$TileSelector.mouse_pos * $RegionMapLayer.tile_set.tile_size.x) -
				Vector2i(
					position.x / $RegionMapLayer.tile_set.tile_size.x,
					position.y / $RegionMapLayer.tile_set.tile_size.y
				)
		)
		var cur_source = $RegionMapLayer.get_cell_source_id(tile_coords)
		var coords_N = $RegionMapLayer.get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_TOP_SIDE)
		var coords_S = $RegionMapLayer.get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
		var coords_E = $RegionMapLayer.get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)
		var coords_W = $RegionMapLayer.get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_LEFT_SIDE)
		
		# update selected cell
		if(selected_tool == Globals.TYPE_DOZER):
			$RegionMapLayer.set_cell(tile_coords, -1)
			if(cur_source == SOURCE_ROAD):
				$RegionMapLayer.update_road_tile(coords_N, _add_construction_overlay)
				$RegionMapLayer.update_road_tile(coords_S, _add_construction_overlay)
				$RegionMapLayer.update_road_tile(coords_E, _add_construction_overlay)
				$RegionMapLayer.update_road_tile(coords_W, _add_construction_overlay)
		elif(selected_tool == Globals.TYPE_LINES):
			# update selected cell
			$PowerLineLayer.update_line_tile(tile_coords, _add_construction_overlay, $RegionMapLayer, true)
			# update neighboring cells
			$PowerLineLayer.update_line_tile(coords_N, _add_construction_overlay, $RegionMapLayer)
			$PowerLineLayer.update_line_tile(coords_S, _add_construction_overlay, $RegionMapLayer)
			$PowerLineLayer.update_line_tile(coords_E, _add_construction_overlay, $RegionMapLayer)
			$PowerLineLayer.update_line_tile(coords_W, _add_construction_overlay, $RegionMapLayer)
		elif((cur_source == SOURCE_ROAD) && (selected_tool == Globals.TYPE_BUS_STOP)):
			match $RegionMapLayer.get_cell_atlas_coords(tile_coords): # no overlay ~ instant build
				Vector2i(0, 0):
					$BusStopLayer.set_cell(tile_coords, 0, Vector2i(0, 0)) # vertical
				Vector2i(1, 0):
					$BusStopLayer.set_cell(tile_coords, 0, Vector2i(1, 0)) # horizontal
		elif(cur_source == -1):
			match selected_tool:
				Globals.TYPE_ROAD:
					# update selected cell
					$RegionMapLayer.update_road_tile(tile_coords, _add_construction_overlay, true)
					# update neighboring cells
					$RegionMapLayer.update_road_tile(coords_N, _add_construction_overlay)
					$RegionMapLayer.update_road_tile(coords_S, _add_construction_overlay)
					$RegionMapLayer.update_road_tile(coords_E, _add_construction_overlay)
					$RegionMapLayer.update_road_tile(coords_W, _add_construction_overlay)
				Globals.TYPE_RES_ZONE:
					$RegionMapLayer.set_cell(tile_coords, SOURCE_ZONES, Vector2i(0, 0))
				Globals.TYPE_COM_ZONE:
					$RegionMapLayer.set_cell(tile_coords, SOURCE_ZONES, Vector2i(0, 1))
				Globals.TYPE_IND_ZONE:
					$RegionMapLayer.set_cell(tile_coords, SOURCE_ZONES, Vector2i(0, 2))
				Globals.TYPE_MIX_ZONE:
					$RegionMapLayer.set_cell(tile_coords, SOURCE_ZONES, Vector2i(0, 3))
				Globals.TYPE_PLANT:
					$RegionMapLayer.set_cell(tile_coords, SOURCE_PLOPPABLES, Vector2i(0, 0))
					$PowerLineLayer.update_line_tile(tile_coords, _add_construction_overlay, $RegionMapLayer, true)
					$PowerLineLayer.update_line_tile(coords_N, _add_construction_overlay, $RegionMapLayer)
					$PowerLineLayer.update_line_tile(coords_S, _add_construction_overlay, $RegionMapLayer)
					$PowerLineLayer.update_line_tile(coords_E, _add_construction_overlay, $RegionMapLayer)
					$PowerLineLayer.update_line_tile(coords_W, _add_construction_overlay, $RegionMapLayer)
				Globals.TYPE_SUB_STN:
					$RegionMapLayer.set_cell(tile_coords, SOURCE_PLOPPABLES, Vector2i(0, 1))
					$PowerLineLayer.update_line_tile(tile_coords, _add_construction_overlay, $RegionMapLayer, true)
					$PowerLineLayer.update_line_tile(coords_N, _add_construction_overlay, $RegionMapLayer)
					$PowerLineLayer.update_line_tile(coords_S, _add_construction_overlay, $RegionMapLayer)
					$PowerLineLayer.update_line_tile(coords_E, _add_construction_overlay, $RegionMapLayer)
					$PowerLineLayer.update_line_tile(coords_W, _add_construction_overlay, $RegionMapLayer)
				Globals.TYPE_PARK:
					$RegionMapLayer.set_cell(tile_coords, SOURCE_PLOPPABLES, Vector2i(0, 2))
				Globals.TYPE_POLICE:
					$RegionMapLayer.set_cell(tile_coords, SOURCE_PLOPPABLES, Vector2i(0, 3))
				Globals.TYPE_FIRE:
					$RegionMapLayer.set_cell(tile_coords, SOURCE_PLOPPABLES, Vector2i(0, 4))
				Globals.TYPE_HOSPITAL:
					$RegionMapLayer.set_cell(tile_coords, SOURCE_PLOPPABLES, Vector2i(0, 5))
				Globals.TYPE_SCHOOL:
					$RegionMapLayer.set_cell(tile_coords, SOURCE_PLOPPABLES, Vector2i(0, 5))
			if(selected_tool != Globals.TYPE_ROAD):
				_add_construction_overlay(tile_coords, selected_tool)
