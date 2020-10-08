function init_world_grid() {
	for (var _i = 0; _i < WORLD_GRID_W; _i++) {
		for (var _j = 0; _j < WORLD_GRID_H; _j++) {
			world_grid[# _i, _j] = init_world_cell();
		}
	}
}

function init_world_cell() {
	var _arr = [];
    
    //Backwards initialization
    _arr[WORLD_CELL.SEED] = -1;
    _arr[WORLD_CELL.TILE] = -1;
	
	return _arr;
}

function set_world_cell_seed(_x, _y) {
	var _cell = world_grid[# _x, _y];
	
	
	
}