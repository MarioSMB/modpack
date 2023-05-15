

float (entity e, float i, float j) inv_get =
{
	if (i == 0)
	{
		if (j == 0)
			return e.inv_0_0;
		else if (j == 1)
			return e.inv_0_1;
		else if (j == 2)
			return e.inv_0_2;
		else if (j == 3)
			return e.inv_0_3;
		else if (j == 4)
			return e.inv_0_4;
		else if (j == 5)
			return e.inv_0_5;
	}
	else if (i == 1)
	{
		if (j == 0)
			return e.inv_1_0;
		else if (j == 1)
			return e.inv_1_1;
		else if (j == 2)
			return e.inv_1_2;
		else if (j == 3)
			return e.inv_1_3;
		else if (j == 4)
			return e.inv_1_4;
		else if (j == 5)
			return e.inv_1_5;
	}
	else if (i == 2)
	{
		if (j == 0)
			return e.inv_2_0;
		else if (j == 1)
			return e.inv_2_1;
		else if (j == 2)
			return e.inv_2_2;
		else if (j == 3)
			return e.inv_2_3;
		else if (j == 4)
			return e.inv_2_4;
		else if (j == 5)
			return e.inv_2_5;
	}
	else if (i == 3)
	{
		if (j == 0)
			return e.inv_3_0;
		else if (j == 1)
			return e.inv_3_1;
		else if (j == 2)
			return e.inv_3_2;
		else if (j == 3)
			return e.inv_3_3;
		else if (j == 4)
			return e.inv_3_4;
		else if (j == 5)
			return e.inv_3_5;
	}
	else if (i == 4)
	{
		if (j == 0)
			return e.inv_4_0;
		else if (j == 1)
			return e.inv_4_1;
		else if (j == 2)
			return e.inv_4_2;
		else if (j == 3)
			return e.inv_4_3;
		else if (j == 4)
			return e.inv_4_4;
		else if (j == 5)
			return e.inv_4_5;
	}
	else if (i == 5)
	{
		if (j == 0)
			return e.inv_5_0;
		else if (j == 1)
			return e.inv_5_1;
		else if (j == 2)
			return e.inv_5_2;
		else if (j == 3)
			return e.inv_5_3;
		else if (j == 4)
			return e.inv_5_4;
		else if (j == 5)
			return e.inv_5_5;
	}
	else if (i == 6)
	{
		if (j == 0)
			return e.inv_6_0;
		else if (j == 1)
			return e.inv_6_1;
		else if (j == 2)
			return e.inv_6_2;
		else if (j == 3)
			return e.inv_6_3;
		else if (j == 4)
			return e.inv_6_4;
		else if (j == 5)
			return e.inv_6_5;
	}
	else if (i == 7)
	{
		if (j == 0)
			return e.inv_7_0;
		else if (j == 1)
			return e.inv_7_1;
		else if (j == 2)
			return e.inv_7_2;
		else if (j == 3)
			return e.inv_7_3;
		else if (j == 4)
			return e.inv_7_4;
		else if (j == 5)
			return e.inv_7_5;
	}
	bprint("inv_get: out of bounds: ");
	bprint(ftos(i));
	bprint(" , ");
	bprint(ftos(j));
	bprint("\n");
	return -1;
};


void (entity e, float i, float j, float val) inv_set =
{
	if (i == 0)
	{
		if (j == 0)
		{
			e.inv_0_0 = val;
			return;
		}
		else if (j == 1)
		{
			e.inv_0_1 = val;
			return;
		}
		else if (j == 2)
		{
			e.inv_0_2 = val;
			return;
		}
		else if (j == 3)
		{
			e.inv_0_3 = val;
			return;
		}
		else if (j == 4)
		{
			e.inv_0_4 = val;
			return;
		}
		else if (j == 5)
		{
			e.inv_0_5 = val;
			return;
		}
	}
	else if (i == 1)
	{
		if (j == 0)
		{
			e.inv_1_0 = val;
			return;
		}
		else if (j == 1)
		{
			e.inv_1_1 = val;
			return;
		}
		else if (j == 2)
		{
			e.inv_1_2 = val;
			return;
		}
		else if (j == 3)
		{
			e.inv_1_3 = val;
			return;
		}
		else if (j == 4)
		{
			e.inv_1_4 = val;
			return;
		}
		else if (j == 5)
		{
			e.inv_1_5 = val;
			return;
		}
	}
	else if (i == 2)
	{
		if (j == 0)
		{
			e.inv_2_0 = val;
			return;
		}
		else if (j == 1)
		{
			e.inv_2_1 = val;
			return;
		}
		else if (j == 2)
		{
			e.inv_2_2 = val;
			return;
		}
		else if (j == 3)
		{
			e.inv_2_3 = val;
			return;
		}
		else if (j == 4)
		{
			e.inv_2_4 = val;
			return;
		}
		else if (j == 5)
		{
			e.inv_2_5 = val;
			return;
		}
	}
	else if (i == 3)
	{
		if (j == 0)
		{
			e.inv_3_0 = val;
			return;
		}
		else if (j == 1)
		{
			e.inv_3_1 = val;
			return;
		}
		else if (j == 2)
		{
			e.inv_3_2 = val;
			return;
		}
		else if (j == 3)
		{
			e.inv_3_3 = val;
			return;
		}
		else if (j == 4)
		{
			e.inv_3_4 = val;
			return;
		}
		else if (j == 5)
		{
			e.inv_3_5 = val;
			return;
		}
	}
	else if (i == 4)
	{
		if (j == 0)
		{
			e.inv_4_0 = val;
			return;
		}
		else if (j == 1)
		{
			e.inv_4_1 = val;
			return;
		}
		else if (j == 2)
		{
			e.inv_4_2 = val;
			return;
		}
		else if (j == 3)
		{
			e.inv_4_3 = val;
			return;
		}
		else if (j == 4)
		{
			e.inv_4_4 = val;
			return;
		}
		else if (j == 5)
		{
			e.inv_4_5 = val;
			return;
		}
	}
	else if (i == 5)
	{
		if (j == 0)
		{
			e.inv_5_0 = val;
			return;
		}
		else if (j == 1)
		{
			e.inv_5_1 = val;
			return;
		}
		else if (j == 2)
		{
			e.inv_5_2 = val;
			return;
		}
		else if (j == 3)
		{
			e.inv_5_3 = val;
			return;
		}
		else if (j == 4)
		{
			e.inv_5_4 = val;
			return;
		}
		else if (j == 5)
		{
			e.inv_5_5 = val;
			return;
		}
	}
	else if (i == 6)
	{
		if (j == 0)
		{
			e.inv_6_0 = val;
			return;
		}
		else if (j == 1)
		{
			e.inv_6_1 = val;
			return;
		}
		else if (j == 2)
		{
			e.inv_6_2 = val;
			return;
		}
		else if (j == 3)
		{
			e.inv_6_3 = val;
			return;
		}
		else if (j == 4)
		{
			e.inv_6_4 = val;
			return;
		}
		else if (j == 5)
		{
			e.inv_6_5 = val;
			return;
		}
	}
	else if (i == 7)
	{
		if (j == 0)
		{
			e.inv_7_0 = val;
			return;
		}
		else if (j == 1)
		{
			e.inv_7_1 = val;
			return;
		}
		else if (j == 2)
		{
			e.inv_7_2 = val;
			return;
		}
		else if (j == 3)
		{
			e.inv_7_3 = val;
			return;
		}
		else if (j == 4)
		{
			e.inv_7_4 = val;
			return;
		}
		else if (j == 5)
		{
			e.inv_7_5 = val;
			return;
		}
	}
	bprint("inv_set: out of bounds: ");
	bprint(ftos(i));
	bprint(" , ");
	bprint(ftos(j));
	bprint("\n");
};


void (entity e, float val) inv_fill =
{
	e.inv_0_0 = e.inv_0_1 = e.inv_0_2 = e.inv_0_3 = e.inv_0_4 = e.inv_0_5 = 
	e.inv_1_0 = e.inv_1_1 = e.inv_1_2 = e.inv_1_3 = e.inv_1_4 = e.inv_1_5 = 
	e.inv_2_0 = e.inv_2_1 = e.inv_2_2 = e.inv_2_3 = e.inv_2_4 = e.inv_2_5 = 
	e.inv_3_0 = e.inv_3_1 = e.inv_3_2 = e.inv_3_3 = e.inv_3_4 = e.inv_3_5 = 
	e.inv_4_0 = e.inv_4_1 = e.inv_4_2 = e.inv_4_3 = e.inv_4_4 = e.inv_4_5 = 
	e.inv_5_0 = e.inv_5_1 = e.inv_5_2 = e.inv_5_3 = e.inv_5_4 = e.inv_5_5 = 
	e.inv_6_0 = e.inv_6_1 = e.inv_6_2 = e.inv_6_3 = e.inv_6_4 = e.inv_6_5 = 
	e.inv_7_0 = e.inv_7_1 = e.inv_7_2 = e.inv_7_3 = e.inv_7_4 = e.inv_7_5 = val;
};

float (entity e, vector start, vector sz) inv_nextsquare =
{
	local float f;
	
	inv_loc_x = inv_loc_x + 1;

	if (inv_loc_x >= start_x + sz_x)
	{
		inv_loc_x = start_x;
		inv_loc_y = inv_loc_y + 1;
		if (inv_loc_y >= start_y + sz_y)
			error("Not enough data squares!");
	}
	f = inv_get(e, inv_loc_x, inv_loc_y);
	if (inv_rebuild)
		inv_set(e, inv_loc_x, inv_loc_y, f | INV_SLAVE);
	return f;
};

void (entity e, vector start, vector sz, float f) inv_setnextsquare =
{
	inv_loc_x = inv_loc_x + 1;

	if (inv_loc_x >= start_x + sz_x)
	{
		inv_loc_x = start_x;
		inv_loc_y = inv_loc_y + 1;
		if (inv_loc_y >= start_y + sz_y)
			error("Not enough data squares!");
	}
	bprint("Slave square: ", vtos(inv_loc), " Value: ");
	bprint(ftos(f), "\n");
	
	inv_set(e, inv_loc_x, inv_loc_y, f | INV_SLAVE);
};

void (entity e, vector start, vector sz) inv_filldummies =
{
	inv_loc_x = inv_loc_x + 1;

	for(;inv_loc_x < start_x + sz_x; inv_loc_x = inv_loc_x + 1)
	{
		for (;inv_loc_y < start_y + sz_y; inv_loc_y = inv_loc_y + 1)
		{
			inv_set(e, inv_loc_x, inv_loc_y, INV_SLAVE);
			bprint("Dummy square: ", vtos(inv_loc), "\n");

		}
	}
};

float(entity e, float x, float y) inv_getitem =
{
	local float n;
	local vector v, start;
	

	// Set the progressive square checker to the right place
	v = inv_loc;
	inv_loc_x = x;
	inv_loc_y = y;
	start = inv_loc;
	
	n = inv_get(e, x, y);
	
	stat_it = stat_suf = stat_id = stat_pref = stat_dur = 0;
	
	if (n & INV_SLAVE)
		return FALSE;
	stat_it = n & 127;
	if (!stat_it)
		return FALSE;
	if (inv_rebuild)
	{
		inv_set(e, x, y, n | INV_MASTER);
	}	
	if (n & INV_MICRO)
	{
		stat_it = IT_LESSER_HEAL + (n & 112) / 16;
		stat_dur = n & 15;
		stat_size = '1 1 16';
	}
	else
	{
		stat_size = it_itemsize(stat_it);
		if (stat_size_z & ID_AUX)
		{
			stat_it = stat_it * 128 + (inv_nextsquare(e, start, stat_size) & 255);
			stat_size = it_itemsize(stat_it);
		}
		if (stat_size_z & ID_DUR)
			stat_dur = inv_nextsquare(e, start, stat_size) & 255;
		if (stat_size_z & ID_PREF)
		{
		
			stat_pref = inv_nextsquare(e, start, stat_size);
			stat_id = (stat_pref & 128) == 128;
			stat_pref = stat_pref & 127;
		}
		if (stat_size_z & ID_SUF)
		{
			stat_suf = inv_nextsquare(e, start, stat_size) & 255;
		}
		if (inv_rebuild)
			inv_filldummies(e, start, stat_size);

	}
	inv_loc = v;
	return TRUE;
};
void(entity e, vector sz) inv_createmap =
{
	local float x, y;
	inv_rebuild = 1;
	for (x = 0; x < sz_x; x = x + 1)
	{
		for(y = 0; y < sz_y; y = y + 1)
		{
			inv_getitem(e, x, y);
		}
	}
	inv_rebuild = 0;
};
void(entity e) inv_firstitem =
{
	inv_loc = '0 0 0';
	
};

float(entity e, vector sz) inv_nextitem = 
{
	do
	{
		inv_getitem(e, inv_loc_x, inv_loc_y);
		inv_loc_x = inv_loc_x + 1;
		if (inv_loc_x >= sz_x)
		{
			inv_loc_y = inv_loc_y + 1;
			inv_loc_x = 0;
			if (inv_loc_y >= sz_y)
				return FALSE;
		}	
	}
	while (stat_it == 0);
	return TRUE;
};

float(entity e, vector org, vector sz) inv_checkitem =
{
	local vector v;
	if (org_x + stat_size_x > sz_x)
		return FALSE;
	if (org_y + stat_size_y > sz_y)
		return FALSE;
	
	for (v_x = org_x; v_x < (org_x + stat_size_x); v_x = v_x + 1)
	{
		for(v_y = org_y; v_y < (org_y + stat_size_y); v_y = v_y + 1)
		{
			if (inv_get(e, v_x, v_y))
				return FALSE;
		}
	}
	return TRUE;
};
float(vector box1, vector b1max, vector box2, vector b2max) boxcollision =
{
	if (b1max_x < box2_x)
		return FALSE;
	if (box1_x > b2max_x)
		return FALSE;
	if (b1max_y < box2_y)
		return FALSE;
	if (box1_y > b2max_y)
		return FALSE;
	return TRUE;

};

vector(entity e, vector org, vector sz) inv_itemsinarea =
{
	local vector v, best, original;
	original = stat_size;
	best = '0 0 1';
	for (v_x = 0; v_x < sz_x; v_x = v_x + 1)
	{
		for (v_y = 0; v_y < sz_y; v_y = v_y + 1)
		{
			if (inv_getitem(e, v_x, v_y))
			{
				if (boxcollision(org, org + original, v, v+stat_size))
				{
					if (!best)
						best = v;
					else
						return '0 0 2';// when we hit 2 we no longer care
				}
			}
		}
	}
	return best;
};
void(entity e, float x, float y) inv_placeitem =
{
	local float n;
	local vector v, start;
	

	// Set the progressive square checker to the right place
	v = inv_loc;
	inv_loc_x = x;
	inv_loc_y = y;
	start = inv_loc;
	bprint("Master square: ", vtos(inv_loc), " Value: ");
	bprint(ftos(stat_it), "\n");
	if (!stat_it)
		return;
			
	if (stat_size_z & ID_MICRO)
	{

		n = (stat_it - IT_LESSER_HEAL) * 16 + (stat_dur & 15) | INV_MICRO;
		inv_set(e, x, y, n | INV_MASTER);

		return;
	}
	else
	{
		
		if (stat_size_z & ID_AUX)
		{
			inv_set(e, x, y, ((stat_it / 128) & 127) | INV_MASTER);
			inv_setnextsquare(e, start, stat_size, stat_it & 255);
		}
		else
			inv_set(e, x, y, (stat_it & 127) | INV_MASTER);
		if (stat_size_z & ID_DUR)
			inv_setnextsquare(e, start, stat_size, stat_dur & 255);
		if (stat_size_z & ID_PREF)
			inv_setnextsquare(e, start, stat_size, stat_pref + 128 * (stat_id != 0));
		if (stat_size_z & ID_SUF)
			inv_setnextsquare(e, start, stat_size, stat_suf & 255);
		inv_filldummies(e, start, stat_size);
	}
	inv_loc = v;
	
};
void(entity e, vector org) inv_clearitem =
{
	local vector v;
	for (v_x = org_x; v_x < (org_x + stat_size_x); v_x = v_x + 1)
	{
		for(v_y = org_y; v_y < (org_y + stat_size_y); v_y = v_y + 1)
		{
			inv_set(e, v_x, v_y, 0);
		}
	}
};

float (entity e, vector it, vector sz) inv_autoplace =
{
	local vector v;
	it_simplestat(it);
	if (!stat_it)
		return TRUE;
	for (v_x = 0; v_x < sz_x; v_x = v_x + 1)
	{
		for (v_y = 0; v_y < sz_y; v_y = v_y + 1)
		{
			if (inv_checkitem(e, v, sz))
			{
				inv_placeitem(e, v_x, v_y);
				return TRUE;
			}
		}
	}
	return FALSE;
};