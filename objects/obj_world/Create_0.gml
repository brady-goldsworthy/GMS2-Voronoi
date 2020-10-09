///@description Generating world

randomize();
log_debug("SEED: ", random_get_seed());

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

world_grid_w = 40;
world_grid_h = 40;

//world_w = world_grid_w * TILESIZE;
//world_h = world_grid_h * TILESIZE;

world_w = room_height;
world_h = room_width;

//room_width = world_w;
//room_height = world_h;

#endregion

#region World grid

world_grid = ds_grid_create(WORLD_W, WORLD_H);

init_world_grid();

#endregion

#region Tilemap

tile_layer = -1;
tile_tilemap = -1;

init_tilemap = function() {
	tile_layer = layer_create(10);
	tile_tilemap = layer_tilemap_create(tile_layer, 0, 0, tile_voronoi, WORLD_W, WORLD_H);
}

#endregion

log_debug("\n---------------------");
var _total_start_time = get_timer();

// Generating Points

//Poisson sampling
point_list = generate_poisson_coords(WORLD_W, WORLD_H, 16);

//----or-----

//Pure random sampling
//point_list = generate_random_coords(WORLD_W, WORLD_H, 300);


//Perform Bowyer-Watson triangulation
triangulation = bowyer_watson(point_list);


//Store triangle data in list of triangle objects
triangles = create_triangles(triangulation);


//Store unique edges and vertices from triangles
vertices = ds_list_create();
vertex_lookup = ds_map_create();
edges = ds_list_create();
edge_lookup = ds_map_create();
store_unique_edges_vertices(triangles, vertices, vertex_lookup, edges, edge_lookup);


//Associate these unique vertices and edges
vertex_to_edge_lookup = create_vertex_to_edge_lookup(edges, vertices);

//special_polygons = array_create(SPECIAL.LENGTH, -1);

//Creating Voronoi polygons
polygons = create_polygons(vertices);
store_adjacent_polygons(polygons);

create_landmass_radial(polygons);

var _total_end_time = get_timer();
log_time("Total gen time", _total_end_time - _total_start_time);
log_debug("\n-----------------");

//show_debug_overlay(true);