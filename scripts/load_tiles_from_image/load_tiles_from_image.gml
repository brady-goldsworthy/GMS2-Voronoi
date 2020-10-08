function fill_world_grid_from_image(_spr, _w, _h, _grid) {
	//=== Create Surface ===//
	var _surf = surface_create(_w, _h);
	surface_set_target(_surf);
	draw_clear_alpha(0, 0);		
	draw_sprite(_spr, -1, 0, 0);
	surface_reset_target();

	//=== Surface to Buffer ===//
	_buff=buffer_create(4 * _w * _h, buffer_fixed, 1);
	buffer_get_surface(_buff, _surf, 0, 0, 0);
	surface_free(_surf);// we don't need the surface anymore

	//=== Extracting Color Info ===//
	// this is an example for a single pixel, you can of course loop all pixels, or access only specific ones!
	// Pixel coordinates [x,y] start at [0,0] and should not exceed [_w-1,_h-1]

	for (var _x = 0; _x < _w; _x++) {
		for (var _y = 0; _y < _h; _y++) {
			
			var _cx = get_world_cell_center_x(_x);
			var _cy = get_world_cell_center_y(_y);
			
			pixel = buffer_peek(_buff, 4 * (_cx + _cy * _w), buffer_u32);	// extracts info in ABGR Format
			a = (pixel >> 24) & $ff;	// Alpha [0-255]	
			r = pixel & $ff;			// Red [0-255]	
			g = (pixel >> 8) & $ff;		// Green [0-255]	
			b = (pixel >> 16) & $ff;	// Blue [0-255]	
		
			var _col = make_color_rgb(r, g, b)
		
			switch _col {
				case global.c_ocean: _grid[# _x, _y][WORLD_CELL.TILE] = TILE_OCEAN; break;
				case global.c_forest: _grid[# _x, _y][WORLD_CELL.TILE] = TILE_FOREST; break;
				default: _grid[# _x, _y][WORLD_CELL.TILE] = 0;
			}
			
		}
	}

	// === Cleanup ===//
	buffer_delete(_buff); 
}