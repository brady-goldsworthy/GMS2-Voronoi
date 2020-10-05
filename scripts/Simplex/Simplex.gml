
/// simplex_init();
/// @description Initializes global Simplex Noise constants.
function simplex_init() {


#region Simplex Constants
#macro SIMPLEX_F2 0.36602540378
#macro SIMPLEX_G2 0.21132486540

	enum ESimplexNoise {
		Frequency,
		Amplitude,
		Lacunarity,
		Persistence,
		Octaves
	};
#endregion
#region Setup Permutation Table

	/* Temp Table */
	var p = simplex_table();

	/* Permutation Tables */
	for (var i = 0; i < 512; ++i) {
		global.__simplex_perm[i] = p[i & 255];
		global.__simplex_perm_mod12[i] = global.__simplex_perm[i] % 12;
	}

#endregion
#region Setup Gradients

	global.__simplex_grad3 = [
		[1, 1, 0], [-1, 1, 0], [1, -1, 0], [-1, -1, 0],
		[1, 0, 1], [-1, 0, 1], [1, 0, -1], [-1, 0, -1],
		[0, 1, 1], [0, -1, 1], [0, 1, -1], [0, -1, -1]
	];

#endregion


}


/// @function simplex_table();
function simplex_table() {

	// Create Permutation List & Shuffle
	var _list = ds_list_create();
	for(var i = 0.0; i < 256.0; ++i)
		ds_list_add(_list, i);
	ds_list_shuffle(_list);

	// Store List Values In Array
	var _array = array_create(256.0);
	for(var i = 0.0; i < 256.0; ++i)
	{
		_array[i] = _list[| i];
	}

	// Destroy The Data & Return the Array
	ds_list_destroy(_list);
	return _array;


}

/// @function simplex_get(x, y);
/// @description Gets the 2D simplex noise value at the specified position.
/// @params x The X position.
/// @params y The Y position.
function simplex_get(argument0, argument1) {

	// Permutation Data
	var perm	   = global.__simplex_perm,
		perm_mod12 = global.__simplex_perm_mod12,
		grad3	   = global.__simplex_grad3;

	/* Noise contributions from the three corners */
	var s  = (argument0 + argument1) * SIMPLEX_F2,
		i  = floor(argument0 + s),
		j  = floor(argument1 + s),
		t  = (i + j) * SIMPLEX_G2,
		x0 = argument0 - (i - t),
		y0 = argument1 - (j - t);

	/* Offsets for second (middle) corner of simplex in (i, j) coords */
	var i1, j1;

	if (x0 > y0) {
		i1 = 1;
		j1 = 0;
	} else {
		i1 = 0;
		j1 = 1;
	}

	/* Offsets for middle corner in (x, y) unskewed coords */
	var x1 = x0 - i1 + SIMPLEX_G2;
	var y1 = y0 - j1 + SIMPLEX_G2;

	/* Offsets for last corner in (x, y) unskewed coords */
	var x2 = x0 - 1.0 + 2.0 * SIMPLEX_G2;
	var y2 = y0 - 1.0 + 2.0 * SIMPLEX_G2;

	/* Work out the hashed gradient indices of the three simplex corners */
	var ii = i & 255;
	var jj = j & 255;
	var gi0 = perm_mod12[ii + perm[jj]];
	var gi1 = perm_mod12[ii + i1 + perm[jj + j1]];
	var gi2 = perm_mod12[ii + 1 + perm[jj + 1]];

	/* Calculate the contribution from the three corners */
	var n0, n1, n2;
	var t0 = 0.5 - x0 * x0 - y0 * y0;

	if (t0 < 0) {
		n0 = 0.0;
	} else {
		var g = grad3[gi0];
	
	    t0 *= t0;
	    n0 = t0 * t0 * (g[0] * x0 + g[1] * y0);
	}

	var t1 = 0.5 - x1 * x1 - y1 * y1;

	if (t1 < 0) {
		n1 = 0.0;
	} else {
		var g = grad3[gi1];
	
	    t1 *= t1;
	    n1 = t1 * t1 * (g[0] * x1 + g[1] * y1);
	}

	var t2 = 0.5 - x2 * x2 - y2 * y2;

	if (t2 < 0) {
		n2 = 0.0;
	} else {
		var g = grad3[gi2];
	
	    t2 *= t2;
	    n2 = t2 * t2 * (g[0] * x2 + g[1] * y2);
	}

	/* Add contributions from each corner to get the final noise value. The result is scaled to return values in the interval [-1,1]. */
	return 70.0 * (n0 + n1 + n2);


}
