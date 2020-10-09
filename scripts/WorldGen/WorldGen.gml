function init_world_grid() {
	for (var _i = 0; _i < WORLD_W; _i++) {
		for (var _j = 0; _j < WORLD_H; _j++) {
			world_grid[# _i, _j] = init_world_cell();
		}
	}
}

function init_world_cell() {
	var _arr = [];
    
    //Backwards initialization
    _arr[WORLD_CELL.TILE] = -1;
	
	return _arr;
}

function generate_random_coords(_w, _h, _n) {
	
	var _start_time = get_timer();
	
	var _points = ds_list_create();
	
	//Return a list with n number of random points
	repeat(_n) {
		var _x = random_range(0, _w);	
		var _y = random_range(0, _h);	
			
		ds_list_add(_points, _x, _y);
	}
	
	var _end_time = get_timer();
	log_time("Generating random points", _end_time - _start_time);
	
	return _points;
}

function create_triangles(_triangulation) {
	
	//Return a list of triangle objects given a list of bowyer watson _triangulation data
	
	var _start_time = get_timer();
	
	var _triangles = ds_list_create();
	
	for (var _i = 0; _i < ds_list_size(_triangulation); _i += 9) {
		//      _triangulation[| 0 to 5] for triangle points
		//      _triangulation[| 6 to 8] for circumcircle data

		//Create vertices
		var _v1 = new Vertex(_triangulation[| _i + 0], _triangulation[| _i + 1]);
		var _v2 = new Vertex(_triangulation[| _i + 2], _triangulation[| _i + 3]);
		var _v3 = new Vertex(_triangulation[| _i + 4], _triangulation[| _i + 5]);
	
		var _cc = new Circumcircle(_triangulation[| _i + 6], _triangulation[| _i + 7], _triangulation[| _i + 8]);
	
		var _t = new Triangle(_v1, _v2, _v3, _cc);
	
		ds_list_add(_triangles, _t);
	}
	
	var _end_time = get_timer();
	log_time("Creating triangles", _end_time - _start_time);
	
	return _triangles;
}

function store_unique_edges_vertices(_t_list, _v_list, _v_lookup, _e_list, _e_lookup) {
	
	var _start_time = get_timer();
	
	//Fill lists and lookup maps w/ unique edges/vertices
	for (var _i = 0; _i < ds_list_size(_t_list); _i++) {
	
		var _t = _t_list[|_i];
	
		add_edge_to_lookup_map(_t.e1, _e_list, _e_lookup);
		add_edge_to_lookup_map(_t.e2, _e_list, _e_lookup);
		add_edge_to_lookup_map(_t.e3, _e_list, _e_lookup);
	
		add_vertex_to_lookup_map(_t.v1, _v_list, _v_lookup);
		add_vertex_to_lookup_map(_t.v2, _v_list, _v_lookup);
		add_vertex_to_lookup_map(_t.v3, _v_list, _v_lookup);
	}
	
	var _end_time = get_timer();
	log_time("Vertex and Edge init", _end_time - _start_time);
}

function create_vertex_to_edge_lookup(_e_list, _v_list) {
	
	var _start_time = get_timer();
	
	//Will store list of edges for each vertex
	var _lookup = ds_map_create();

	//lookup[key] = list of edges

	var _num_edges = ds_list_size(_e_list);

	//Create vertex -> edge lookup map
	for (var _i = 0; _i < _num_edges; _i++) {
		var _edge = _e_list[| _i];

		//First vertex
		var _key = _edge.get_vertex_lookup_key_v1();
	
		var _list = _lookup[? _key];
		if is_undefined(_list) {
			_list = ds_list_create();
		
			ds_map_add_list(_lookup, _key, _list);
		}
		ds_list_add(_list, _edge); //Store edge in list in map

		//Second vertex
		var _key = _edge.get_vertex_lookup_key_v2();
	
		var _list = _lookup[? _key];
		if is_undefined(_list) {
			_list = ds_list_create();
		
			ds_map_add_list(_lookup, _key, _list);
		}
		ds_list_add(_list, _edge); //Store edge in list in map

	}

	var _num_vertices = ds_list_size(_v_list);

	//Loop through vertices and store edges from lookup map in vertex object
	for (var _i = 0; _i < ds_list_size(_v_list); _i++) {
		var _vertex = _v_list[| _i];
	
		var _key = _vertex.get_vertex_lookup_key();
	
		var _edge_list = _lookup[? _key];

		//If this vertex has edges
		if !is_undefined(_edge_list) {
			var _num_edges = ds_list_size(_edge_list);
		
			/*
				Modified insertion sort to sort edges by direction from 0 -> 360
				This can definitely be optimized/cleaned up waaay more
				Buuuuuuuuuuuuut it works
			*/
		
			var _v_edges = array_create(_num_edges, undefined);
			for (var _j = 0; _j < _num_edges; _j++) {
			
				var _edge = _edge_list[| _j];
				var _dir = _edge.get_dir_from_vertex(_vertex);
			
				var _insert_pos = _j;
			
				while (_insert_pos > 0 and !is_undefined(_v_edges[_insert_pos]) and _v_edges[_insert_pos].get_dir_from_vertex(_vertex) > _dir) {
				
					//Swap these entries
					_v_edges[_insert_pos] = _v_edges[_insert_pos - 1];
				
					_insert_pos--;
				}
			
				_v_edges[_insert_pos] = _edge;
			}
		
			_vertex.edges = _v_edges;
			_vertex.num_edges = _num_edges;
			_vertex.clean_edges();
		}
	}
	
	var _end_time = get_timer();
	log_time("Associating Vertices and edges", _end_time - _start_time);
	
}

function create_polygons(_v_list) {
	
	var _start_time = get_timer();
	
	var _polygons = ds_list_create();
	
	//For each delauney vertex, create a voronoi polygon 
	for (var _i = 0; _i < ds_list_size(_v_list); _i++) {
		var _v = _v_list[| _i];
	
		var _p = new Polygon(_v);
		_v.polygon = _p; //Associate this vertex with the polygon
		
		ds_list_add(_polygons, _p);
	}
	
	var _end_time = get_timer();
	log_time("Creating Polygons", _end_time - _start_time);
	
	return _polygons;
}

function store_adjacent_polygons(_p_list) {
	
	var _num_polygons = ds_list_size(_p_list);
	for (var _i = 0; _i < _num_polygons; _i++) {
		var _p = _p_list[| _i];
	
		_p.store_adjacent_polygons();
	}
}

function create_landmass_radial(_p_list) {
	
	var _cx = WORLD_W / 2, _cy = WORLD_H / 2;
	
	//Play around with amp and freq
	var _s_amp = 150, _s_freq = 0.65;
	var _c_amp = 15, _c_freq = 9;

	var _num_polygons = ds_list_size(_p_list);

	for (var _i = 0; _i < _num_polygons; _i++) {

		var _p = polygons[| _i];

		var _dist = point_distance(_p.x, _p.y, _cx, _cy);
		var _dir = point_direction(_p.x, _p.y, _cx, _cy);
	
		var _max_dist = 220 + min((dsin(_dir * _s_freq) * _s_amp), _s_amp / 2) + (dcos(_dir * _c_freq) * _c_amp);
	
		if _dist < _max_dist _p.biome = BIOME.FOREST;
	
	}
}

function create_landmass_fill() {
	//var _n = 15;

	//var _center_p = special_polygons[SPECIAL.CENTER];

	//_center_p.fill_adjacent(_n, function(_p) {
	//	if _p.biome == BIOME.OCEAN _p.biome = BIOME.FOREST;
	//	_p.landmass_fill = true;
	//});

	//var _top_r_p = special_polygons[SPECIAL.TOP_RIGHT];

	//_top_r_p.fill_adjacent(_n, function(_p) {
	//	if _p.biome == BIOME.OCEAN _p.biome = BIOME.DESERT;
	//});

	//var _top_l_p = special_polygons[SPECIAL.TOP_LEFT];

	//_top_l_p.fill_adjacent(_n, function(_p) {
	//	if _p.biome == BIOME.OCEAN _p.biome = BIOME.VOLCANO;
	//});

	//var _bot_r_p = special_polygons[SPECIAL.BOT_RIGHT];

	//_bot_r_p.fill_adjacent(_n, function(_p) {
	//	if _p.biome == BIOME.OCEAN _p.biome = BIOME.VOLCANO;
	//});

	//var _bot_l_p = special_polygons[SPECIAL.BOT_LEFT];

	//_bot_l_p.fill_adjacent(_n, function(_p) {
	//	if _p.biome == BIOME.OCEAN _p.biome = BIOME.DESERT;
	//});
}
