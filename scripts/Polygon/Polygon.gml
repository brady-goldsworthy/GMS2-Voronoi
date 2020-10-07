function Polygon(_seed) constructor {
	seed = _seed;
	
	d_edges = _seed.edges;
	num_d_edges = array_length(d_edges);
	
	vertices = [];
	num_vertices = 0;
	
	edges = [];
	num_edges = 0;
	
	color = make_color_rgb(irandom(255),irandom(255),irandom(255));
	
	static add_vertex = function(_vertex) {
		vertices[num_vertices] = _vertex;
		num_vertices++;
	}
	
	static add_edge = function(_edge) {
		edges[num_edges] = _edge;
		num_edges++;
	}
	
	static draw = function() {
		
		if !obj_world.draw_polygons return;
		
		draw_primitive_begin(pr_trianglefan);
		
		for (var _i = 0; _i < num_vertices; _i++) {
			var _v = vertices[_i];
			draw_vertex_color(_v.x, _v.y, color, 1);
		}
		
		draw_primitive_end();
		
		//seed.draw(c_black);
		
		for (var _i = 0; _i < num_vertices; _i++) {
			var _v = vertices[_i];
			//_v.draw(c_maroon);
		}
		
		for (var _j = 0; _j < num_edges; _j++) {
			var _e = edges[_j];
			//_e.draw(c_white);
		}
	}
	
	//Loop through sorted edges and create polygon edges by connect triangle circumcenters
	for(var _i = 0; _i < num_d_edges; _i++) {
		var _edge = d_edges[_i];
		
		if !is_undefined(_edge.t2) {
			var _c_center1 = _edge.t1.c_circle.get_circumcenter();
			var _v1 = new Vertex(_c_center1.x, _c_center1.y);
			
			var _c_center2 = _edge.t2.c_circle.get_circumcenter();
			var _v2 = new Vertex(_c_center2.x, _c_center2.y);
			
			var _edge = new Edge(_v1, _v2, undefined);
			
			add_vertex(_v1);
			add_vertex(_v2);
			add_edge(_edge);
		}
		
	}
	
}