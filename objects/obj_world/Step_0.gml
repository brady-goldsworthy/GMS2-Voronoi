///@description 

switch gen_step {
	case 0:	
	
		log_debug("Generating Seeds");
	
		//Generate Seeds
		repeat(4) {
			var _x = random_range(0, WORLD_W);	
			var _y = random_range(0, WORLD_H);	
			
			//instance_create_layer(_x, _y, "Instances", obj_seed);
		}
		
		
	break;
	
	case 1:
		log_debug("Initializing World Cells");
		
		var _start_time = get_timer(); 
		for (var _i = 0; _i < WORLD_GRID_W; _i++) {
			for (var _j = 0; _j < WORLD_GRID_H; _j++) {
				
				init_world_cell(_i, _j);
				
			}
		}
		
		var _end_time = get_timer();
		log_time("Init World Cells", _end_time - _start_time);
		
	break;
}


gen_step++;

if keyboard_check_pressed(ord("R")) game_restart();
if keyboard_check_pressed(vk_f1) draw_delauney_points = !draw_delauney_points;
if keyboard_check_pressed(vk_f2) draw_delauney_lines = !draw_delauney_lines;
if keyboard_check_pressed(vk_f3) draw_circumcircle = !draw_circumcircle;
if keyboard_check_pressed(vk_f4) draw_circumcenter = !draw_circumcenter;
if keyboard_check_pressed(vk_f5) draw_circumcenter_lines = !draw_circumcenter_lines;
