#macro WORLD_GRID obj_world.world_grid;

#macro WORLD_GRID_W obj_world.world_grid_w
#macro WORLD_GRID_H obj_world.world_grid_h
#macro WORLD_W obj_world.world_w
#macro WORLD_H obj_world.world_h

enum WORLD_CELL {
	TILE
}

#macro TILESIZE 16
#macro TILE_OCEAN 4
#macro TILE_FOREST 1
#macro TILE_DESERT 3

enum BIOME {
	OCEAN,
	FOREST,
	DESERT,
	VOLCANO
}

enum SPECIAL {
	CENTER,
	TOP_RIGHT,
	TOP_LEFT,
	BOT_LEFT,
	BOT_RIGHT,
	LENGTH
}

//global.special_positions = [
//	{x: WORLD_W div 2, y: WORLD_H div 2},
//	{x: (WORLD_W div 3) * 2, y: WORLD_H div 3},
//	{x: (WORLD_W div 3), y: (WORLD_H div 3)},
//	{x: WORLD_W div 3, y: (WORLD_H div 3) * 2},
//	{x: (WORLD_W div 3) * 2, y: (WORLD_H div 3) * 2}
//]

