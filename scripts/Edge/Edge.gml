#region Object constructor

function Edge(_v1, _v2, _t) constructor{
	v1 = _v1;
	v2 = _v2;
	
	t1 = _t;
	t2 = undefined;
	
	//dir = point_direction(v1.x, v1.y, v2.x, v2.y);
	
	static get_center = function() {
		var _x = (v1.x + v2.x) / 2;
		var _y = (v1.y + v2.y) / 2;
		
		return {x: _x, y: _y};
	}
	
	static draw = function(_c) {
		draw_line_color(v1.x, v1.y, v2.x, v2.y, _c, _c);	
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
	
	static get_dir_from_vertex = function(_v) {
		
		//Direction is dependent on which vertex we start from
		if _v.is_equal(v1) {
			return point_direction(v1.x, v1.y, v2.x, v2.y);
		}
		
		return point_direction(v2.x, v2.y, v1.x, v1.y);
	}

}

#endregion

#region Util functions

function add_edge_to_lookup_map(_edge, _edge_list, _lookup_map) {
	
	//Pull lookup keys from edge object
	var _key = _edge.get_edge_lookup_key();
	var _alt_key = _edge.get_edge_lookup_alt_key();
	
	//Check if this edge key already exists in the lookup map
	if !ds_map_exists(_lookup_map, _key) and !ds_map_exists(_lookup_map, _alt_key) {
		
		//This edge hasn't been added yet, let's add it to edge list and lookup map
		
		ds_list_add(_edge_list, _edge); //Adding edge to edge list
		ds_map_add(_lookup_map, _key, _edge); //Adding this key/edge to lookup map
	}
	else {
		//This edge exists in lookup, let's update that edge's triangle associations
		
		var _existing_edge = _lookup_map[? _key];
		
		//Use alt key if needed
		if is_undefined(_existing_edge) _existing_edge = _lookup_map[? _alt_key];
		
		//Setting existing edge's second triangle to this edge's triangle
		//Basically combining these edges into one
		_existing_edge.t2 = _edge.t1;
	}
}

#endregion