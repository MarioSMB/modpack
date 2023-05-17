#include "invmap.qh"

float inv_get(entity e, float i, float j)
{
	if(i == 0)
	{
		if(j == 0)
			return e.inv_0_0;
		else if(j == 1)
			return e.inv_0_1;
		else if(j == 2)
			return e.inv_0_2;
		else if(j == 3)
			return e.inv_0_3;
		else if(j == 4)
			return e.inv_0_4;
		else if(j == 5)
			return e.inv_0_5;
	}
	else if(i == 1)
	{
		if(j == 0)
			return e.inv_1_0;
		else if(j == 1)
			return e.inv_1_1;
		else if(j == 2)
			return e.inv_1_2;
		else if(j == 3)
			return e.inv_1_3;
		else if(j == 4)
			return e.inv_1_4;
		else if(j == 5)
			return e.inv_1_5;
	}
	else if(i == 2)
	{
		if(j == 0)
			return e.inv_2_0;
		else if(j == 1)
			return e.inv_2_1;
		else if(j == 2)
			return e.inv_2_2;
		else if(j == 3)
			return e.inv_2_3;
		else if(j == 4)
			return e.inv_2_4;
		else if(j == 5)
			return e.inv_2_5;
	}
	else if(i == 3)
	{
		if(j == 0)
			return e.inv_3_0;
		else if(j == 1)
			return e.inv_3_1;
		else if(j == 2)
			return e.inv_3_2;
		else if(j == 3)
			return e.inv_3_3;
		else if(j == 4)
			return e.inv_3_4;
		else if(j == 5)
			return e.inv_3_5;
	}
	else if(i == 4)
	{
		if(j == 0)
			return e.inv_4_0;
		else if(j == 1)
			return e.inv_4_1;
		else if(j == 2)
			return e.inv_4_2;
		else if(j == 3)
			return e.inv_4_3;
		else if(j == 4)
			return e.inv_4_4;
		else if(j == 5)
			return e.inv_4_5;
	}
	else if(i == 5)
	{
		if(j == 0)
			return e.inv_5_0;
		else if(j == 1)
			return e.inv_5_1;
		else if(j == 2)
			return e.inv_5_2;
		else if(j == 3)
			return e.inv_5_3;
		else if(j == 4)
			return e.inv_5_4;
		else if(j == 5)
			return e.inv_5_5;
	}
	else if(i == 6)
	{
		if(j == 0)
			return e.inv_6_0;
		else if(j == 1)
			return e.inv_6_1;
		else if(j == 2)
			return e.inv_6_2;
		else if(j == 3)
			return e.inv_6_3;
		else if(j == 4)
			return e.inv_6_4;
		else if(j == 5)
			return e.inv_6_5;
	}
	else if(i == 7)
	{
		if(j == 0)
			return e.inv_7_0;
		else if(j == 1)
			return e.inv_7_1;
		else if(j == 2)
			return e.inv_7_2;
		else if(j == 3)
			return e.inv_7_3;
		else if(j == 4)
			return e.inv_7_4;
		else if(j == 5)
			return e.inv_7_5;
	}
	bprintf("inv_get: out of bounds: %d , %d\n", i, j);
	return -1;
}

void inv_set(entity e, float i, float j, float val)
{
	if(i == 0)
	{
		if(j == 0)
		{
			e.inv_0_0 = val;
			return;
		}
		else if(j == 1)
		{
			e.inv_0_1 = val;
			return;
		}
		else if(j == 2)
		{
			e.inv_0_2 = val;
			return;
		}
		else if(j == 3)
		{
			e.inv_0_3 = val;
			return;
		}
		else if(j == 4)
		{
			e.inv_0_4 = val;
			return;
		}
		else if(j == 5)
		{
			e.inv_0_5 = val;
			return;
		}
	}
	else if(i == 1)
	{
		if(j == 0)
		{
			e.inv_1_0 = val;
			return;
		}
		else if(j == 1)
		{
			e.inv_1_1 = val;
			return;
		}
		else if(j == 2)
		{
			e.inv_1_2 = val;
			return;
		}
		else if(j == 3)
		{
			e.inv_1_3 = val;
			return;
		}
		else if(j == 4)
		{
			e.inv_1_4 = val;
			return;
		}
		else if(j == 5)
		{
			e.inv_1_5 = val;
			return;
		}
	}
	else if(i == 2)
	{
		if(j == 0)
		{
			e.inv_2_0 = val;
			return;
		}
		else if(j == 1)
		{
			e.inv_2_1 = val;
			return;
		}
		else if(j == 2)
		{
			e.inv_2_2 = val;
			return;
		}
		else if(j == 3)
		{
			e.inv_2_3 = val;
			return;
		}
		else if(j == 4)
		{
			e.inv_2_4 = val;
			return;
		}
		else if(j == 5)
		{
			e.inv_2_5 = val;
			return;
		}
	}
	else if(i == 3)
	{
		if(j == 0)
		{
			e.inv_3_0 = val;
			return;
		}
		else if(j == 1)
		{
			e.inv_3_1 = val;
			return;
		}
		else if(j == 2)
		{
			e.inv_3_2 = val;
			return;
		}
		else if(j == 3)
		{
			e.inv_3_3 = val;
			return;
		}
		else if(j == 4)
		{
			e.inv_3_4 = val;
			return;
		}
		else if(j == 5)
		{
			e.inv_3_5 = val;
			return;
		}
	}
	else if(i == 4)
	{
		if(j == 0)
		{
			e.inv_4_0 = val;
			return;
		}
		else if(j == 1)
		{
			e.inv_4_1 = val;
			return;
		}
		else if(j == 2)
		{
			e.inv_4_2 = val;
			return;
		}
		else if(j == 3)
		{
			e.inv_4_3 = val;
			return;
		}
		else if(j == 4)
		{
			e.inv_4_4 = val;
			return;
		}
		else if(j == 5)
		{
			e.inv_4_5 = val;
			return;
		}
	}
	else if(i == 5)
	{
		if(j == 0)
		{
			e.inv_5_0 = val;
			return;
		}
		else if(j == 1)
		{
			e.inv_5_1 = val;
			return;
		}
		else if(j == 2)
		{
			e.inv_5_2 = val;
			return;
		}
		else if(j == 3)
		{
			e.inv_5_3 = val;
			return;
		}
		else if(j == 4)
		{
			e.inv_5_4 = val;
			return;
		}
		else if(j == 5)
		{
			e.inv_5_5 = val;
			return;
		}
	}
	else if(i == 6)
	{
		if(j == 0)
		{
			e.inv_6_0 = val;
			return;
		}
		else if(j == 1)
		{
			e.inv_6_1 = val;
			return;
		}
		else if(j == 2)
		{
			e.inv_6_2 = val;
			return;
		}
		else if(j == 3)
		{
			e.inv_6_3 = val;
			return;
		}
		else if(j == 4)
		{
			e.inv_6_4 = val;
			return;
		}
		else if(j == 5)
		{
			e.inv_6_5 = val;
			return;
		}
	}
	else if(i == 7)
	{
		if(j == 0)
		{
			e.inv_7_0 = val;
			return;
		}
		else if(j == 1)
		{
			e.inv_7_1 = val;
			return;
		}
		else if(j == 2)
		{
			e.inv_7_2 = val;
			return;
		}
		else if(j == 3)
		{
			e.inv_7_3 = val;
			return;
		}
		else if(j == 4)
		{
			e.inv_7_4 = val;
			return;
		}
		else if(j == 5)
		{
			e.inv_7_5 = val;
			return;
		}
	}
	bprintf("inv_set: out of bounds: %d , %d\n", i, j);
}


void inv_fill(entity e, float val)
{
	e.inv_0_0 = e.inv_0_1 = e.inv_0_2 = e.inv_0_3 = e.inv_0_4 = e.inv_0_5 = 
	e.inv_1_0 = e.inv_1_1 = e.inv_1_2 = e.inv_1_3 = e.inv_1_4 = e.inv_1_5 = 
	e.inv_2_0 = e.inv_2_1 = e.inv_2_2 = e.inv_2_3 = e.inv_2_4 = e.inv_2_5 = 
	e.inv_3_0 = e.inv_3_1 = e.inv_3_2 = e.inv_3_3 = e.inv_3_4 = e.inv_3_5 = 
	e.inv_4_0 = e.inv_4_1 = e.inv_4_2 = e.inv_4_3 = e.inv_4_4 = e.inv_4_5 = 
	e.inv_5_0 = e.inv_5_1 = e.inv_5_2 = e.inv_5_3 = e.inv_5_4 = e.inv_5_5 = 
	e.inv_6_0 = e.inv_6_1 = e.inv_6_2 = e.inv_6_3 = e.inv_6_4 = e.inv_6_5 = 
	e.inv_7_0 = e.inv_7_1 = e.inv_7_2 = e.inv_7_3 = e.inv_7_4 = e.inv_7_5 = val;
}

float inv_nextsquare(entity e, vector start, vector sz)
{
	inv_loc.x = inv_loc.x + 1;

	if(inv_loc.x >= start.x + sz.x)
	{
		inv_loc.x = start.x;
		inv_loc.y = inv_loc.y + 1;
		if(inv_loc.y >= start.y + sz.y)
			error("Not enough data squares!");
	}
	float f = inv_get(e, inv_loc.x, inv_loc.y);
	if(inv_rebuild)
		inv_set(e, inv_loc.x, inv_loc.y, f | INV_SLAVE);
	return f;
}

void inv_setnextsquare(entity e, vector start, vector sz, float f)
{
	inv_loc.x = inv_loc.x + 1;

	if(inv_loc.x >= start.x + sz.x)
	{
		inv_loc.x = start.x;
		inv_loc.y = inv_loc.y + 1;
		if(inv_loc.y >= start.y + sz.y)
			error("Not enough data squares!");
	}
	bprint(strcat("Slave square: ", vtos(inv_loc), " Value: ", ftos(f), "\n"));
	
	inv_set(e, inv_loc.x, inv_loc.y, f | INV_SLAVE);
}

void inv_filldummies(entity e, vector start, vector sz)
{
	inv_loc.x = inv_loc.x + 1;

	for( ;inv_loc.x < start.x + sz.x; inv_loc.x = inv_loc.x + 1)
	{
		for( ;inv_loc.y < start.y + sz.y; inv_loc.y = inv_loc.y + 1)
		{
			inv_set(e, inv_loc.x, inv_loc.y, INV_SLAVE);
			bprint(strcat("Dummy square: ", vtos(inv_loc), "\n"));

		}
	}
}

bool inv_getitem(entity e, float itx, float ity)
{
	// Set the progressive square checker to the right place
	vector v = inv_loc;
	inv_loc.x = itx;
	inv_loc.y = ity;
	vector start = inv_loc;
	
	float n = inv_get(e, itx, ity);
	
	stat_it = stat_suf = stat_id = stat_pref = stat_dur = 0;
	
	if(n & INV_SLAVE)
		return false;
	stat_it = n & 127;
	if(!stat_it)
		return false;
	if(inv_rebuild)
	{
		inv_set(e, itx, ity, n | INV_MASTER);
	}	
	if(n & INV_MICRO)
	{
		stat_it = IT_LESSER_HEAL + (n & 112) / 16;
		stat_dur = n & 15;
		stat_size = '1 1 16';
	}
	else
	{
		stat_size = it_itemsize(stat_it);
		if(stat_size.z & ID_AUX)
		{
			stat_it = stat_it * 128 + (inv_nextsquare(e, start, stat_size) & 255);
			stat_size = it_itemsize(stat_it);
		}
		if(stat_size.z & ID_DUR)
			stat_dur = inv_nextsquare(e, start, stat_size) & 255;
		if(stat_size.z & ID_PREF)
		{
		
			stat_pref = inv_nextsquare(e, start, stat_size);
			stat_id = (stat_pref & 128) == 128;
			stat_pref = stat_pref & 127;
		}
		if(stat_size.z & ID_SUF)
		{
			stat_suf = inv_nextsquare(e, start, stat_size) & 255;
		}
		if(inv_rebuild)
			inv_filldummies(e, start, stat_size);

	}
	inv_loc = v;
	return true;
}

void inv_createmap(entity e, vector sz)
{
	inv_rebuild = true;
	for(int dx = 0; dx < sz.x; dx = dx + 1)
	{
		for(int dy = 0; dy < sz.y; dy = dy + 1)
		{
			inv_getitem(e, dx, dy);
		}
	}
	inv_rebuild = false;
}

void inv_firstitem(entity e)
{
	inv_loc = '0 0 0';
}

bool inv_nextitem(entity e, vector sz)
{
	do
	{
		inv_getitem(e, inv_loc.x, inv_loc.y);
		inv_loc.x = inv_loc.x + 1;
		if(inv_loc.x >= sz.x)
		{
			inv_loc.y = inv_loc.y + 1;
			inv_loc.x = 0;
			if(inv_loc.y >= sz.y)
				return false;
		}	
	}
	while(stat_it == 0);
	return true;
}

bool inv_checkitem(entity e, vector org, vector sz)
{
	vector v = '0 0 0';
	if(org.x + stat_size.x > sz.x)
		return false;
	if(org.y + stat_size.y > sz.y)
		return false;
	
	for(v.x = org.x; v.x < (org.x + stat_size.x); v.x = v.x + 1)
	{
		for(v.y = org.y; v.y < (org.y + stat_size.y); v.y = v.y + 1)
		{
			if(inv_get(e, v.x, v.y))
				return false;
		}
	}
	return true;
}

bool boxcollision(vector box1, vector b1max, vector box2, vector b2max)
{
	if(b1max.x < box2.x)
		return false;
	if(box1.x > b2max.x)
		return false;
	if(b1max.y < box2.y)
		return false;
	if(box1.y > b2max.y)
		return false;
	return true;
}

vector inv_itemsinarea(entity e, vector org, vector sz)
{
	vector original = stat_size;
	vector best = '0 0 1';
	vector v = '0 0 0';
	for(v.x = 0; v.x < sz.x; v.x += 1)
	{
		for(v.y = 0; v.y < sz.y; v.y += 1)
		{
			if(inv_getitem(e, v.x, v.y))
			{
				if(boxcollision(org, org + original, v, v+stat_size))
				{
					if(!best)
						best = v;
					else
						return '0 0 2'; // when we hit 2 we no longer care
				}
			}
		}
	}
	return best;
}

void inv_placeitem(entity e, float locx, float locy)
{
	// Set the progressive square checker to the right place
	vector v = inv_loc;
	inv_loc.x = locx;
	inv_loc.y = locy;
	vector start = inv_loc;
	bprintf("Master square: %s Value: %d\n", vtos(inv_loc), stat_it);
	if(!stat_it)
		return;
			
	if(stat_size.z & ID_MICRO)
	{
		float n = (stat_it - IT_LESSER_HEAL) * 16 + (stat_dur & 15) | INV_MICRO;
		inv_set(e, locx, locy, n | INV_MASTER);

		return;
	}
	else
	{
		
		if(stat_size.z & ID_AUX)
		{
			inv_set(e, locx, locy, ((stat_it / 128) & 127) | INV_MASTER);
			inv_setnextsquare(e, start, stat_size, stat_it & 255);
		}
		else
			inv_set(e, locx, locy, (stat_it & 127) | INV_MASTER);
		if(stat_size.z & ID_DUR)
			inv_setnextsquare(e, start, stat_size, stat_dur & 255);
		if(stat_size.z & ID_PREF)
			inv_setnextsquare(e, start, stat_size, stat_pref + 128 * (stat_id != 0));
		if(stat_size.z & ID_SUF)
			inv_setnextsquare(e, start, stat_size, stat_suf & 255);
		inv_filldummies(e, start, stat_size);
	}
	inv_loc = v;
	
}

void inv_clearitem(entity e, vector org)
{
	vector v = '0 0 0';
	for(v.x = org.x; v.x < (org.x + stat_size.x); v.x += 1)
	{
		for(v.y = org.y; v.y < (org.y + stat_size.y); v.y = v.y + 1)
		{
			inv_set(e, v.x, v.y, 0);
		}
	}
}

bool inv_autoplace(entity e, vector itslot, vector sz)
{
	vector v = '0 0 0';
	it_simplestat(e, itslot);
	if(!stat_it)
		return true;
	for(v.x = 0; v.x < sz.x; v.x = v.x + 1)
	{
		for(v.y = 0; v.y < sz.y; v.y = v.y + 1)
		{
			if(inv_checkitem(e, v, sz))
			{
				inv_placeitem(e, v.x, v.y);
				return true;
			}
		}
	}
	return false;
}
