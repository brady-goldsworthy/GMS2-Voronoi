function Edge(_v1, _v2) constructor{
	v1 = _v1;
	v2 = _v2;
	
	static get_center = function() {
		var _x = (v1.x + v2.x) / 2;
		var _y = (v1.y + v2.y) / 2;
		
		return {x: _x, y: _y};
	}
	
	static draw = function() {
		draw_line(v1.x, v1.y, v2.x, v2.y);	
	}
	
	static is_equal = function(_edge) {
		return (v1.is_equal(_edge.v1) and v2.is_equal(_edge.v2));
	}
	
	static get_edge_lookup_key = function() {
		return string(v1.x) + "," + string(v1.y) + "->" + string(v2.x) + "," + string(v2.y);	
	}
	
	static get_edge_lookup_alt_key = function() {
		return string(v2.x) + "," + string(v2.y) + "->" + string(v1.x) + "," + string(v1.y);	
	}
	
	static get_vertex_lookup_key_v1 = function() {
		return string(v1.x) + "," + string(v1.y);	
	}
	
	static get_vertex_lookup_key_v2 = function() {
		return string(v2.x) + "," + string(v2.y);	
	}

}