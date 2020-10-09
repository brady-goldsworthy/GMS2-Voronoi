///@description Toggle drawing debug info

if !layer_exists(tile_layer) and sprite_exists(spr_voronoi) {
	init_tilemap();
	
	fill_world_grid_from_image(spr_voronoi, WORLD_W, WORLD_H, world_grid);
	
	fill_tilemap();
	
	view_enabled = true;
	view_visible[0] = true;
	camera_set_view_size(view_camera[0], WORLD_W * TILESIZE, WORLD_H * TILESIZE);
}

#region Debug controls

if keyboard_check_pressed(ord("R")) game_restart();
if keyboard_check_pressed(vk_f1) draw_delauney_points = !draw_delauney_points;
if keyboard_check_pressed(vk_f2) draw_delauney_lines = !draw_delauney_lines;
if keyboard_check_pressed(vk_f3) draw_circumcircle = !draw_circumcircle;
if keyboard_check_pressed(vk_f4) draw_circumcenter = !draw_circumcenter;
if keyboard_check_pressed(vk_f5) draw_polygons = !draw_polygons;

#endregion