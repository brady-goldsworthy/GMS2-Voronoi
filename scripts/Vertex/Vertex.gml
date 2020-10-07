#region Object constructor

function Vertex(_x, _y) constructor {
	x = _x;
	y = _y;
	
	edges = [];
	num_edges = 0;
	
	static draw = function(_c) {
		draw_circle_color(x, y, 3, _c, _c, false);	
	}
	
	static is_equal = function(_v) {
		return (x = _v.x and y = _v.y);
	}
	
	static get_vertex_lookup_key = function() {
		return string(x) + "," + string(y);	
	}
}

#endregion

#region Util Functions

function add_vertex_to_lookup_map(_vertex, _vertex_list, _lookup_map) {
	
	//Pull this vertex's key
	var _key = _vertex.get_vertex_lookup_key();
	
	//Check if this vertex has already been added
	if !ds_map_exists(_lookup_map, _key) {
		
		//This vertex hasn't been added yet, let's add it to vertex list and lookup map
		
		ds_list_add(_vertex_list, _vertex); //Adding edge to edge list
		ds_map_add(_lookup_map, _key, _vertex); //Adding Index of this edge in edges list
	}
}

#endregion