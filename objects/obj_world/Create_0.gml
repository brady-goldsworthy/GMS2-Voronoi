///@description Generating world

randomize();

simplex_init();

spr_voronoi = -1;
surf_voronoi = -1;

#region debug vars

draw_delauney_points = false;
draw_delauney_lines = false;
draw_circumcircle = false;
draw_circumcenter = false;
draw_circumcenter_lines  = false;
draw_polygons = true;

#endregion

#region World size def

#macro TILESIZE 16

world_grid_w = 40;
world_grid_h = 40;

#macro WORLD_GRID_W obj_world.world_grid_w
#macro WORLD_GRID_H obj_world.world_grid_h

world_w = world_grid_w * TILESIZE;
world_h = world_grid_h * TILESIZE;

//room_width = world_w;
//room_height = world_h;

#macro WORLD_W obj_world.world_w
#macro WORLD_H obj_world.world_h

#endregion

#region World grid

world_grid = ds_grid_create(WORLD_GRID_W, WORLD_GRID_H);

#macro WORLD_GRID obj_world.world_grid;

enum WORLD_CELL {
	TILE,
	SEED
}

init_world_grid();

#endregion

#region Tilemap

#macro TILE_OCEAN 4
#macro TILE_FOREST 1
#macro TILE_DESERT 3

tile_layer = -1;
tile_tilemap = -1;

init_tilemap = function() {
	tile_layer = layer_create(10);
	tile_tilemap = layer_tilemap_create(tile_layer, 0, 0, tile_voronoi, WORLD_GRID_W, WORLD_GRID_H);
}


//init_tilemap();
#endregion

log_debug("\n---------------------");
var _total_start_time = get_timer();

#region Generating Points

var _start_time = get_timer();

point_list = ds_list_create();

//Generating points using poisson sampling
//poisson_points = poisson_sample(WORLD_W, WORLD_H, 6, 6);
//poisson_points = poisson_sample(WORLD_W, WORLD_H, 8, 8);
//poisson_points = poisson_sample(WORLD_W, WORLD_H, 10, 10);
//poisson_points = poisson_sample(WORLD_W, WORLD_H, 12, 12);
//poisson_points = poisson_sample(WORLD_W, WORLD_H, 16, 16);
poisson_points = poisson_sample(WORLD_W, WORLD_H, 32, 32);
//poisson_points = poisson_sample(WORLD_W, WORLD_H, 128, 128);
for (var _i = 0; _i < ds_grid_width(poisson_points); _i++) {
	for (var _j = 0; _j < ds_grid_height(poisson_points); _j++) {
		var _p = poisson_points[# _i, _j];
		if is_array(_p) {
			var _x = _p[0];	
			var _y = _p[1];
			
			ds_list_add(point_list, _x, _y);
		}
	}
}


//Generating n number of random points
//repeat(15) {
//	//var _x = random_range(0, WORLD_W);	
//	//var _y = random_range(0, WORLD_H);	
//	var _offset = 50;
//	var _x = random_range(_offset, WORLD_W - _offset);	
//	var _y = random_range(_offset, WORLD_H - _offset);	
			
//	ds_list_add(point_list, _x, _y);
//}

var _end_time = get_timer();
log_time("Generating points", _end_time - _start_time);

#endregion

#region Creating triangle using bowyer-watson

var _start_time = get_timer();

triangulation = bowyer_watson(point_list);
triangle_list = ds_list_create();

//Create triangle objects from bowyer watson triangulation data
for (var _i = 0; _i < ds_list_size(triangulation); _i += 9) {
	//      triangulation[| 0 to 5] for triangle points
	//      triangulation[| 6 to 8] for circumcircle data

	//Create vertices
	var _v1 = new Vertex(triangulation[| _i + 0], triangulation[| _i + 1]);
	var _v2 = new Vertex(triangulation[| _i + 2], triangulation[| _i + 3]);
	var _v3 = new Vertex(triangulation[| _i + 4], triangulation[| _i + 5]);
	
	var _cc = new Circumcircle(triangulation[| _i + 6], triangulation[| _i + 7], triangulation[| _i + 8]);
	
	var _triangle = new Triangle(_v1, _v2, _v3, _cc);
	
	ds_list_add(triangle_list, _triangle);
	
}

var _end_time = get_timer();
log_time("Delauney triangulation", _end_time - _start_time);

#endregion

#region Store unique edges and vertices

var _start_time = get_timer();

vertices = ds_list_create();
vertex_lookup = ds_map_create();

edges = ds_list_create();
edge_lookup = ds_map_create();

//Fill lists and lookup maps w/ unique edges/vertices
for (var _i = 0; _i < ds_list_size(triangle_list); _i++) {
	
	var _triangle = triangle_list[|_i];
	
	add_edge_to_lookup_map(_triangle.e1, edges, edge_lookup);
	add_edge_to_lookup_map(_triangle.e2, edges, edge_lookup);
	add_edge_to_lookup_map(_triangle.e3, edges, edge_lookup);
	
	add_vertex_to_lookup_map(_triangle.v1, vertices, vertex_lookup);
	add_vertex_to_lookup_map(_triangle.v2, vertices, vertex_lookup);
	add_vertex_to_lookup_map(_triangle.v3, vertices, vertex_lookup);

}

var _end_time = get_timer();
log_time("Vertex and Edge init", _end_time - _start_time);

#endregion

#region Associate edges and vertices

var _start_time = get_timer();

//Will store list of edges for each vertex
vertex_to_edge_lookup = ds_map_create();

//Create vertex -> edge lookup map
for (var _i = 0; _i < ds_list_size(edges); _i++) {
	var _edge = edges[| _i];

	//First vertex
	var _key = _edge.get_vertex_lookup_key_v1();
	
	var _list = vertex_to_edge_lookup[? _key];
	if is_undefined(_list) {
		_list = ds_list_create();
		
		ds_map_add_list(vertex_to_edge_lookup, _key, _list);
	}
	ds_list_add(_list, _edge); //Store index of edge in list in map

	//Second vertex
	var _key = _edge.get_vertex_lookup_key_v2();
	
	var _list = vertex_to_edge_lookup[? _key];
	if is_undefined(_list) {
		_list = ds_list_create();
		
		ds_map_add_list(vertex_to_edge_lookup, _key, _list);
	}
	ds_list_add(_list, _edge); //Store index of edge in list in map

}

//Loop through vertices and add edges from lookup map
for (var _i = 0; _i < ds_list_size(vertices); _i++) {
	var _vertex = vertices[| _i];
	
	var _key = _vertex.get_vertex_lookup_key();
	
	var _edge_list = vertex_to_edge_lookup[? _key];

	if !is_undefined(_edge_list) {
		var _num_edges = ds_list_size(_edge_list);
		
		//Modified insertion sort to sort edges by direction
		
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
			
			//if _insert_pos != _j {
				_v_edges[_insert_pos] = _edge;	
			//}
			
			//_v_edges[@ _j]	= _edge_list[| _j];
		}
		
		_vertex.edges = _v_edges;
		_vertex.num_edges = _num_edges;
		_vertex.clean_edges();
		
	}
	
}

var _end_time = get_timer();
log_time("Associating Vertices and edges", _end_time - _start_time);

#endregion

#region Creating Polygons

var _start_time = get_timer();

enum SPECIAL {
	CENTER,
	TOP_RIGHT,
	TOP_LEFT,
	BOT_LEFT,
	BOT_RIGHT,
	LENGTH
}

special_positions = [
	{x: WORLD_W div 2, y: WORLD_H div 2},
	{x: (WORLD_W div 3) * 2, y: WORLD_H div 3},
	{x: (WORLD_W div 3), y: (WORLD_H div 3)},
	{x: WORLD_W div 3, y: (WORLD_H div 3) * 2},
	{x: (WORLD_W div 3) * 2, y: (WORLD_H div 3) * 2}
]

enum BIOME {
	OCEAN,
	FOREST,
	DESERT,
	VOLCANO
}

special_polygons = array_create(SPECIAL.LENGTH, -1);

polygons = ds_list_create();

//For each delauney vertex, create a voronoi object 
for (var _i = 0; _i < ds_list_size(vertices); _i++) {
	var _v = vertices[| _i];
	
	var _p = new Polygon(_v);
	_v.polygon = _p;
	ds_list_add(polygons, _p);
}

num_polygons = ds_list_size(polygons);

var _end_time = get_timer();
log_time("Creating Polygons", _end_time - _start_time);

#endregion

#region Landmass

//var _center_x = WORLD_W div 2;
//var _center_y = WORLD_H div 2;
//var _coast_dist = 300;
//for (var _i = 0; _i < num_polygons; _i++) {

//	var _p = polygons[| _i];
	
//	var _coast_dist = 200 + (sin(abs(_center_x - _p.seed.x) * 0.1) * 15);
	
//	if point_distance(_center_x, _center_y, _p.seed.x, _p.seed.y) > _coast_dist {
//		_p.ocean = true;
//	}
//}

for (var _i = 0; _i < num_polygons; _i++) {

	var _p = polygons[| _i];
	
	_p.store_adjacent_polygons();
}

var _n = 6;

var _center_p = special_polygons[SPECIAL.CENTER];

_center_p.fill_adjacent(_n, function(_p) {
	if _p.biome == BIOME.OCEAN _p.biome = BIOME.FOREST;
});

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


//for (var _i = 0; _i < SPECIAL.LENGTH; _i++) {
	
//}



#endregion

#region Converting to Tiles

var _start_time = get_timer();

for (var _i = 0; _i < WORLD_GRID_W; _i++) {
	for (var _j = 0; _j < WORLD_GRID_H; _j++) {
		var _x = (_i * TILESIZE) + (TILESIZE / 2);	
		var _y = (_j * TILESIZE) + (TILESIZE / 2);	
	
		
	
	}
}

var _end_time = get_timer();
log_time("Generating points", _end_time - _start_time);

#endregion

var _total_end_time = get_timer();
log_time("Total gen time", _total_end_time - _total_start_time);
log_debug("\n-----------------");

show_debug_overlay(true);