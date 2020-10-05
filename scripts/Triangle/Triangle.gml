function Triangle(_v1, _v2, _v3, _c_circle) constructor {
	v1 = _v1;
	v2 = _v2;
	v3 = _v3;
	
	//Create edges
	e1 = new Edge(_v1, _v2);
	e2 = new Edge(_v2, _v3);
	e3 = new Edge(_v3, _v1);
	
	c_circle = _c_circle;
	
	draw = function() {
		
		//Draw vertices
		if obj_world.draw_delauney_points {
			v1.draw();
			v2.draw();
			v3.draw();
		}
		
		//Draw edges
		if obj_world.draw_delauney_lines {
			e1.draw();
			e2.draw();
			e3.draw();
		}
		
		c_circle.draw();
		
	}
}