function Vertex(_x, _y) constructor {
	x = _x;
	y = _y;
	
	draw = function() {
		draw_circle_color(x, y, 3, c_white, c_white, false);	
	}
	
	is_equal = function(_v) {
		return (x = _v.x and y = _v.y);
	}
}