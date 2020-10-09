global.c_ocean = make_color_rgb(29, 127, 240);
global.c_forest = make_color_rgb(53, 125, 32);
global.c_desert = make_color_rgb(237, 199, 109);
global.c_volcano = make_color_rgb(99, 32, 19);

function Polygon(_seed) constructor {
	seed = _seed;
	//_seed.polygon = self;
	x = seed.x;
	y = seed.y;
	
	d_edges = _seed.edges;
	num_d_edges = array_length(d_edges);
	
	vertices = [];
	num_vertices = 0;
	
	edges = [];
	num_edges = 0;
	
	adj_polygons = [];
	num_polygons = 0;
	
	ocean = true;
	biome = BIOME.OCEAN;
	landmass_fill = false;
	
	color = make_color_rgb(irandom(255),irandom(255),irandom(255));
	
	static add_vertex = function(_vertex) {
		vertices[num_vertices] = _vertex;
		num_vertices++;
	}
	
	static add_edge = function(_edge) {
		edges[num_edges] = _edge;
		num_edges++;
	}
	
	static add_polygon = function(_polygon) {
		adj_polygons[num_polygons] = _polygon;
		num_polygons++;
	}
	
	static fill_adjacent = function(_n, _f) {
		
		if _n <= 0 return;
		
		//Execute function
		_f(self); 
		
		//Call recursively on all surrounding polygons
		for (var _i = 0; _i < num_polygons; _i++) {
			var _p = adj_polygons[_i];
			
			if !is_undefined(_p) and !_p.landmass_fill {
				_p.fill_adjacent(_n - 1, _f);
			}
		}
	}
	
	static draw = function() {
		
		if !obj_world.draw_polygons return;
		
		//var _c = biome == BIOME.OCEAN ? global.c_ocean : global.c_land;
		var _c;
		switch biome {
			case BIOME.OCEAN: _c = global.c_ocean; break;	
			case BIOME.FOREST: _c = global.c_forest; break;	
			case BIOME.DESERT: _c = global.c_desert; break;	
			case BIOME.VOLCANO: _c = global.c_volcano; break;	
		}
		
		//_c = color;
		
		draw_primitive_begin(pr_trianglefan);
		
		for (var _i = 0; _i < num_vertices; _i++) {
			var _v = vertices[_i];
			draw_vertex_color(_v.x, _v.y, _c, 1);
		}
		
		draw_primitive_end();
		
		//seed.draw(c_black);
		
		for (var _i = 0; _i < num_vertices; _i++) {
			var _v = vertices[_i];
			//_v.draw(c_maroon);
		}
		
		for (var _j = 0; _j < num_edges; _j++) {
			var _e = edges[_j];
			//_e.draw(c_black);
		}
	}
	
	static check_special_pos = function() {
		
		//Not currently functional
		
		var _polys = obj_world.special_polygons;
		
		for (var _i = 0; _i < SPECIAL.LENGTH; _i++ ) {
			var _pos = obj_world.special_positions[_i];
			
			var _p = obj_world.special_polygons[_i];
			
			if _p == -1 { 
				obj_world.special_polygons[_i] = self;
				break;
			}
			
			var _p_dist = point_distance(_p.x, _p.y, _pos.x, _pos.y);
			var _self_dist = point_distance(x, y, _pos.x, _pos.y);
			
			if _self_dist < _p_dist {
				obj_world.special_polygons[_i] = self;
			}
			
		}
		
		
		
	}
	
	static store_adjacent_polygons = function() {
		for (var _i = 0; _i < num_d_edges; _i++) {
			var _edge = d_edges[_i];
			
			//Get the other vertex of this edge
			var _p = _edge.v1.is_equal(seed) ? _edge.v2.polygon : _edge.v1.polygon;
			
			if is_undefined(_p) {
				log_debug("Undefined polygon for this delaunay edge");	
			}
			
			add_polygon(_p);
			
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