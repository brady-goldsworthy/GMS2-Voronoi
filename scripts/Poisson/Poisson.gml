function generate_poisson_coords(_w, _h, _r) {
	
	var _start_time = get_timer();
	
	//Creates a poisson sample grid
	//Loops through it and returns a list of coords
	var _poisson_grid = poisson_sample(_w, _h, _r);
	
	var _points = ds_list_create();
	for (var _i = 0; _i < ds_grid_width(_poisson_grid); _i++) {
		for (var _j = 0; _j < ds_grid_height(_poisson_grid); _j++) {
			var _p = _poisson_grid[# _i, _j];
			if is_array(_p) {
				var _x = _p[0];	
				var _y = _p[1];
			
				ds_list_add(_points, _x, _y);
			}
		}
	}
	
	ds_grid_destroy(_poisson_grid);
	
	var _end_time = get_timer();
	log_time("Generating Poisson points", _end_time - _start_time);
	
	return _points;
}

function poisson_sample(_w, _h, _r) {
	var _k = 10;
	var _cellW = _r/sqrt(2);

	var _cols = floor(_w/_cellW);
	var _rows = floor(_h/_cellW);

	var _grid = ds_grid_create(_cols, _rows);
	var _active = ds_list_create();

	var _x = _w/2;
	var _y = _h/2;
	var _xInd = floor(_x/_cellW);
	var _yInd = floor(_y/_cellW);
	_grid[# _xInd, _yInd] = [_x, _y];
	ds_list_add(_active, [_x, _y]);

	while (ds_list_size(_active) > 0) {
	    var _index = irandom(ds_list_size(_active)-1);
	    var _pos = _active[| _index];
    
	    var _found = false;
	    for (var _n = 0; _n < _k; _n++) {
			
	        var _angle = random(360);
	        var _dist = random_range(_r, _r*2);
	        _x = _pos[0] + lengthdir_x(_dist, _angle);
	        _y = _pos[1] + lengthdir_y(_dist, _angle);
	        _xInd = floor(_x/_cellW);
	        _yInd = floor(_y/_cellW);

	        if (_xInd >= 0 && _yInd >= 0 && _xInd < _cols && _yInd < _rows) {
	            if (!is_array(_grid[# _xInd, _yInd])) {
	                var _ok = true;
	                for (var _i = -1; _i <= 1; _i++) {
	                    for (var _j = -1; _j <= 1; _j++) {
	                        var _xCheck = _xInd + _i;
	                        var _yCheck = _yInd + _j;
	                        if (_xCheck >= 0 && _yCheck >= 0 && _xCheck < _cols && _yCheck < _rows) {
	                            var _point = _grid[# _xCheck, _yCheck];
	                            if (is_array(_point)) {
	                                if (point_distance(_point[0], _point[1], _x, _y) < _r) {
	                                    _ok = false;
	                                }
	                            }
	                        }
	                    }
	                }
                
	                if (_ok) {
	                    _grid[# _xInd, _yInd] = [_x, _y];
	                    ds_list_add(_active, [_x, _y]);
	                    _found = true;
	                }
	            }
	        }
	    }
    
	    if (!_found) {
	        ds_list_delete(_active, _index);
	    }
	}

	return _grid;
}
