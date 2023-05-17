#include "vis.qh"

void hide(entity m)
{
	if(m.solid == SOLID_NOT || m.solid == SOLID_BSP)
		return;
		
	if(m.modelindex != 0)
		m.realmodelindex = m.modelindex;
	m.modelindex = 0;
}

void show(entity f)
{
	if(f.solid == SOLID_NOT || f.solid == SOLID_BSP)
		return;

	if(f.realmodelindex)
	{
		f.modelindex = f.realmodelindex;
		if(f.model)
		{
			vector mn = f.mins;
			vector mx = f.maxs;
			_setmodel(f, f.model);
			setsize(f, mn, mx);
		}
	}
}

// TODO: some nasty things to this
void dovis()
{
	entity m = nextent(NULL);
	while(m)
	{
		hide(m);
		m = nextent(m);
	}
	entity e = find(NULL, classname, "player");
	while(e)
	{
		entity f = findradius(e.player.origin, 512);
		while(f)
		{
			show(f);
			f = f.chain;
		}
		e = find(e, classname, "player");
	}
}
