///@description 

randomize();

draw_delauney_points = true;
draw_delauney_lines = true;
draw_circumcircle = true;
draw_circumcenter = true;
draw_circumcenter_lines  = true;

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
//ds_list_add(point_list, 0, 0, 0, room_height, room_width, 0, room_width, room_height);
//ds_list_add(point_list, 0, room_height div 2, room_width div 2, 0, room_width, room_height div 2, room_width div 2, room_height);


poisson_points = poisson_sample(room_width, room_height, 128, 128);

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


//repeat(4) {
//	//var _x = random_range(0, WORLD_W);	
//	//var _y = random_range(0, WORLD_H);	
//	var _offset = 50;
//	var _x = random_range(_offset, room_width - _offset);	
//	var _y = random_range(_offset, room_height - _offset);	
			
//	ds_list_add(point_list, _x, _y);
//}

triangulation = bowyer_watson(point_list);
triangle_list = ds_list_create();

//Create triangle objects from bowyer watson triangulation data
for (var _i = 0; _i < ds_list_size(triangulation); _i += 9) {
	//      triangulation[| 0 to 5] for triangle points
	//      triangulation[| 6 to 8] for circumcircle data

	//Create vertices
	var _v1 = new Vertex(triangulation[|_i + 0], triangulation[|_i + 1]);
	var _v2 = new Vertex(triangulation[|_i + 2], triangulation[|_i + 3]);
	var _v3 = new Vertex(triangulation[|_i + 4], triangulation[|_i + 5]);
	
	var _cc = new Circumcircle(triangulation[|_i + 6], triangulation[|_i + 7], triangulation[|_i + 8]);
	
	var _triangle = new Triangle(_v1, _v2, _v3, _cc);
	
	ds_list_add(triangle_list, _triangle);
	
}

add_edge_to_lookup_map = function(_edge) {
	var _key = _edge.get_edge_lookup_key();
	var _alt_key = _edge.get_edge_lookup_alt_key();
	
	if !ds_map_exists(edge_lookup, _key) and !ds_map_exists(edge_lookup, _alt_key) {
		//This edge hasn't been added yet, let's add it to edge list and lookup map
		ds_list_add(edges, _edge); //Adding edge to edge list
		ds_map_add(edge_lookup, _key, ds_list_size(edges) - 1); //Adding Index of this edge in edges list
	}
}

vertices = ds_list_create();

edges = ds_list_create();
edge_lookup = ds_map_create();

//Find unique edges and create edge lookup map
//Create vertex list
for (var _i = 0; _i < ds_list_size(triangle_list); _i++) {
	
	var _triangle = triangle_list[|_i];
	
	add_edge_to_lookup_map(_triangle.e1);
	add_edge_to_lookup_map(_triangle.e2);
	add_edge_to_lookup_map(_triangle.e3);

	ds_list_add(vertices, _triangle.v1);
	ds_list_add(vertices, _triangle.v2);
	ds_list_add(vertices, _triangle.v3);
	
}

//Will store list of edges for each vertex
edge_to_vertex_lookup = ds_map_create();

//Create vertex -> edge lookup map
for (var _i = 0; _i < ds_list_size(edges); _i++) {
	var _edge = edges[| _i];

	//First vertex
	var _key = _edge.get_vertex_lookup_key_v1();
	
	var _list = edge_to_vertex_lookup[? _key];
	if is_undefined(_list) {
		_list = ds_list_create();
		
		ds_map_add_list(edge_to_vertex_lookup, _key, _new_list);
	}
	ds_list_add(_list, _i); //Store index of edge in list in map

	//Second vertex
	var _key = _edge.get_vertex_lookup_key_v2();
	
	var _list = edge_to_vertex_lookup[? _key];
	if is_undefined(_list) {
		_list = ds_list_create();
		
		ds_map_add_list(edge_to_vertex_lookup, _key, _new_list);
	}
	ds_list_add(_list, _i); //Store index of edge in list in map

}



circumcenter_points = ds_list_create();

for (var _i = 0; _i < ds_list_size(triangulation); _i += 9) {
	ds_list_add(circumcenter_points, triangulation[| _i + 6], triangulation[| _i + 7]);
}



show_debug_overlay(true);