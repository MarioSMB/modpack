nosave var float total_maps = 0;
void() maplist =
{
	local float n;
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	
	self.impulse = total_maps;
	
	if (self.message1)
		n = n + 1;
	if (self.message2)
		n = n + 1;
	if (self.message3)
		n = n + 1;
	if (self.message4)
		n = n + 1;
	if (self.message5)
		n = n + 1;
	if (self.message6)
		n = n + 1;
	if (self.message7)
		n = n + 1;		 
	if (self.message8)
		n = n + 1;
	
	self.m_num = n;
	total_maps = total_maps + n;
};

vector(float n) mapstats =
{
	local entity e;
	e = find(world, classname, "maplist");
	while(e)
	{
		if (n <= (e.impulse + e.m_num))
			if (n > e.impulse)
				return GetSlot(e, n - e.impulse);
	 	e = find(e, classname, "maplist");
	}
	return IV_NULL;
};
float(float fl) getrandmap =
{

	local float f, runaway;
	local vector stats;
	
	while(!(stats_y & fl) || stats_x == world.impulse)
	{
		f = floor(random() * total_maps) + 1;
		stats = mapstats(f);
		runaway = runaway + 1;
		if (runaway > 20)
			return 0;
	}
	return stats_x;
};

string (float n) getmapname =
{
	local entity e;
	if (!n)
		return "nowhere";
		
	e = find(world, classname, "maplist");
	while(e)
	{
		if (e.slot1_x == n)
			return e.message1;
		else if (e.slot2_x == n)
			return e.message2;
		else if (e.slot3_x == n)
			return e.message3;
		else if (e.slot4_x == n)
			return e.message4;
		else if (e.slot5_x == n)
			return e.message5;
		else if (e.slot6_x == n)
			return e.message6;
		else if (e.slot7_x == n)
			return e.message7;
		else if (e.slot8_x == n)
			return e.message8;
	 	e = find(e , classname, "maplist");
	}
	return "somewhere";
};


float (float n) getmapdiff =
{
	local entity e;
	
	e = find(world, classname, "maplist");
	while(e)
	{
		if (e.slot1_x == n)
			return e.slot1_z;
		else if (e.slot2_x == n)
			return e.slot2_z;
		else if (e.slot3_x == n)
			return e.slot3_z;
		else if (e.slot4_x == n)
			return e.slot4_z;
		else if (e.slot5_x == n)
			return e.slot5_z;
		else if (e.slot6_x == n)
			return e.slot6_z;
		else if (e.slot7_x == n)
			return e.slot7_z;
		else if (e.slot8_x == n)
			return e.slot8_z;
	 	e = find(e , classname, "maplist");
	}
	return 0;
};