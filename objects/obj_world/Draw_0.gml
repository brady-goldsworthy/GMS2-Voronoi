///@description 


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
draw_text(10, 80, "Toggle circumcenter lines: f5");

#endregion