function get_world_cell_center_x(_grid_x) {
	return (_grid_x * TILESIZE) + (TILESIZE div 2);
}

function get_world_cell_center_y(_grid_y) {
	return (_grid_y * TILESIZE) + (TILESIZE div 2);
}

function fill_tilemap() {
	for (var _i = 0; _i < WORLD_W; _i++) {
		for (var _j = 0; _j < WORLD_H; _j++) {
		
			var _cell = world_grid[# _i, _j];
			
			var _tile = _cell[WORLD_CELL.TILE];
		
			tilemap_set(tile_tilemap, _tile, _i, _j);
		}
	}
}