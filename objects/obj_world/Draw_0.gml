///@description Drawing polygons

//If Voronoi drawing sprite doesn't exist, create it
if !sprite_exists(spr_voronoi) {
	
	if !surface_exists(surf_voronoi) {
		surf_voronoi = surface_create(WORLD_W, WORLD_H);
	}
	
	surface_set_target(surf_voronoi);
	
	for (var _i = 0; _i < ds_list_size(polygons); _i++) {
		var _polygon = polygons[| _i];
		_polygon.draw();
	}
	
	surface_reset_target();
	
	spr_voronoi = sprite_create_from_surface(surf_voronoi, 0, 0, WORLD_W, WORLD_H, false, false, 0, 0);
}
else {
	if draw_polygons {
		draw_sprite(spr_voronoi, 0, 0, 0);	
	}
}

for (var _i = 0; _i < ds_list_size(triangle_list); _i++) {
	var _triangle = triangle_list[| _i];
	_triangle.draw();
}


#region Debug text

draw_text(10, 30, "SEED: " + string(random_get_seed()));
draw_text(10, 40, "Toggle delauney points: f1");
draw_text(10, 50, "Toggle delauney lines: f2");
draw_text(10, 60, "Toggle circumcircle: f3");
draw_text(10, 70, "Toggle circumcenter: f4");
draw_text(10, 80, "Toggle polygons: f5");

#endregion