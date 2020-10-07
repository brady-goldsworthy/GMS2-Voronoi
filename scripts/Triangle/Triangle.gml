function Triangle(_v1, _v2, _v3, _c_circle) constructor {
	v1 = _v1;
	v2 = _v2;
	v3 = _v3;
	
	//Create edges
	e1 = new Edge(_v1, _v2, self);
	e2 = new Edge(_v2, _v3, self);
	e3 = new Edge(_v3, _v1, self);	
	
	c_circle = _c_circle;
	
	draw = function() {
		
		//Draw vertices
		if obj_world.draw_delauney_points {
			v1.draw(c_white);
			v2.draw(c_white);
			v3.draw(c_white);
		}
		
		//Draw edges
		if obj_world.draw_delauney_lines {
			e1.draw(c_white);
			e2.draw(c_white);
			e3.draw(c_white);
		}
		
		c_circle.draw();
		
	}
}