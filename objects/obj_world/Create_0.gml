///@description 

randomize();

draw_delauney_points = false;
draw_delauney_lines = false;
draw_circumcircle = false;
draw_circumcenter = false;
draw_circumcenter_lines  = false;
draw_polygons = true;

#macro TILESIZE 16

world_grid_w = 20;
world_grid_h = 20;

#macro WORLD_GRID_W obj_world.world_grid_w
#macro WORLD_GRID_H obj_world.world_grid_h

world_w = world_grid_w * TILESIZE;
world_h = world_grid_h * TILESIZE;

#macro WORLD_W obj_world.world_w
#macro WORLD_H obj_world.world_h

gen_step = 0;

world_grid = ds_grid_create(WORLD_GRID_W, WORLD_GRID_H);

#macro WORLD_GRID obj_world.world_grid;

enum WORLD_CELL {
	TILE,
	SEED
}

#region Tilemap

init_tilemap = function() {
	tile_layer = layer_create(10);
	tile_tilemap = layer_tilemap_create(tile_layer, 0, 0, tile_voronoi, WORLD_GRID_W, WORLD_GRID_H);
}


init_tilemap();
#endregion

point_list = ds_list_create();

//Generating points using poisson sampling
poisson_points = poisson_sample(room_width, room_height, 16, 16);
//poisson_points = poisson_sample(room_width, room_height, 32,32);
//poisson_points = poisson_sample(room_width, room_height, 128, 128);
//for (var _i = 0; _i < ds_grid_width(poisson_points); _i++) {
//	for (var _j = 0; _j < ds_grid_height(poisson_points); _j++) {
//		var _p = poisson_points[# _i, _j];
//		if is_array(_p) {
//			var _x = _p[0];	
//			var _y = _p[1];
			
//			ds_list_add(point_list, _x, _y);
//		}
//	}
//}


//Generating n number of random points
repeat(15) {
	//var _x = random_range(0, WORLD_W);	
	//var _y = random_range(0, WORLD_H);	
	var _offset = 50;
	var _x = random_range(_offset, room_width - _offset);	
	var _y = random_range(_offset, room_height - _offset);	
			
	ds_list_add(point_list, _x, _y);
}

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
		//Convert edge list to array
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
		
	}
	
}

polygons = ds_list_create();

//For each delauney vertex, create a voronoi object 
for (var _i = 0; _i < ds_list_size(vertices); _i++) {
	var _v = vertices[| _i];
	
	var _p = new Polygon(_v);
	ds_list_add(polygons, _p);
}




show_debug_overlay(true);