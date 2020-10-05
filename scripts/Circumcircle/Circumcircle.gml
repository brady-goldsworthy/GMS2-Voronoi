function Circumcircle(_x, _y, _r) constructor {
	x = _x;
	y = _y;
	r = _r;

	draw = function() {
		
		if obj_world.draw_circumcircle {
			draw_circle_color(x, y, r, c_dkgray, c_dkgray, true);	
		}
		
		if obj_world.draw_circumcenter {
			draw_circle_color(x, y, 3, c_red, c_red, false);	
		}
		
	}

}