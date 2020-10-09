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

	for (var _grid_x = 0; _grid_x < WORLD_W; _grid_x++) {
		for (var _grid_y = 0; _grid_y < WORLD_H; _grid_y++) {
			
			var _x = _grid_x;
			var _y = _grid_y;
			//var _x = (_grid_x * TILESIZE) + (TILESIZE / 2);
			//var _y = (_grid_y * TILESIZE) + (TILESIZE / 2);
			
			pixel = buffer_peek(_buff, 4 * (_x + _y * _w), buffer_u32);	// extracts info in ABGR Format
			//pixel = buffer_peek(_buff, 4 * (_x + _y), buffer_u32);	// extracts info in ABGR Format
			a = (pixel >> 24) & $ff;	// Alpha [0-255]	
			r = pixel & $ff;			// Red [0-255]	
			g = (pixel >> 8) & $ff;		// Green [0-255]	
			b = (pixel >> 16) & $ff;	// Blue [0-255]	
		
			var _col = make_color_rgb(r, g, b)
		
			switch _col {
				case global.c_forest: _grid[# _grid_x, _grid_y][WORLD_CELL.TILE] = TILE_FOREST; break;
				default: _grid[# _grid_x, _grid_y][WORLD_CELL.TILE] = TILE_OCEAN;
			}
			//_grid_y++;
		}
		//_grid_x++;
	}

	// === Cleanup ===//
	buffer_delete(_buff); 
}