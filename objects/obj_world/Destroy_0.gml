///@description Cleanup

//Triangles
ds_list_destroy(triangulation);
ds_list_destroy(triangle_list);

//Vertices
ds_list_destroy(vertices);
ds_map_destroy(vertex_lookup);
ds_map_destroy(vertex_to_edge_lookup);

//Edges
ds_list_destroy(edges);
ds_map_destroy(edge_lookup);

//World Grid
ds_grid_destroy(world_grid);
