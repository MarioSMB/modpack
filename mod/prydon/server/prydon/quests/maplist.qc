#include "maplist.qh"

#include "../subs/reqs.qh"

void maplist(entity this)
{
	int n = 0;
	if(CheckStory(this))
	{
		delete(this);
		return;
	}
	
	this.impulse = total_maps;
	
	if(this.message1)
		n += 1;
	if(this.message2)
		n += 1;
	if(this.message3)
		n += 1;
	if(this.message4)
		n += 1;
	if(this.message5)
		n += 1;
	if(this.message6)
		n += 1;
	if(this.message7)
		n += 1;		 
	if(this.message8)
		n += 1;
	
	this.m_num = n;
	total_maps += n;
}

vector mapstats(float n)
{
	entity e = find(NULL, classname, "maplist");
	while(e)
	{
		if(n <= (e.impulse + e.m_num))
			if(n > e.impulse)
				return GetSlot(e, n - e.impulse);
	 	e = find(e, classname, "maplist");
	}
	return IV_NULL;
}

float getrandmap(float fl)
{
	vector thestats = '0 0 0';
	int runaway = 0;

	while(!(thestats.y & fl) || thestats.x == world.impulse)
	{
		float f = floor(random() * total_maps) + 1;
		thestats = mapstats(f);
		runaway += 1;
		if(runaway > 20)
			return 0;
	}
	return thestats.x;
}

string getmapname(float n)
{
	if(!n)
		return "nowhere";
		
	entity e = find(NULL, classname, "maplist");
	while(e)
	{
		if(e.slot1_x == n)
			return e.message1;
		else if(e.slot2_x == n)
			return e.message2;
		else if(e.slot3_x == n)
			return e.message3;
		else if(e.slot4_x == n)
			return e.message4;
		else if(e.slot5_x == n)
			return e.message5;
		else if(e.slot6_x == n)
			return e.message6;
		else if(e.slot7_x == n)
			return e.message7;
		else if(e.slot8_x == n)
			return e.message8;
	 	e = find(e, classname, "maplist");
	}
	return "somewhere";
}

float getmapdiff(float n)
{
	entity e = find(NULL, classname, "maplist");
	while(e)
	{
		if(e.slot1_x == n)
			return e.slot1_z;
		else if(e.slot2_x == n)
			return e.slot2_z;
		else if(e.slot3_x == n)
			return e.slot3_z;
		else if(e.slot4_x == n)
			return e.slot4_z;
		else if(e.slot5_x == n)
			return e.slot5_z;
		else if(e.slot6_x == n)
			return e.slot6_z;
		else if(e.slot7_x == n)
			return e.slot7_z;
		else if(e.slot8_x == n)
			return e.slot8_z;
	 	e = find(e, classname, "maplist");
	}
	return 0;
}
