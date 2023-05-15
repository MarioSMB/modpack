.float realmodelindex;

void(entity m) hide =
{
	if (m.solid == SOLID_NOT || m.solid == SOLID_BSP)
		return;
		
	if (m.modelindex != 0)
		m.realmodelindex = m.modelindex;
	m.modelindex = 0;
};

void(entity f) show =
{
	local vector mn, mx;
	
	if (f.solid == SOLID_NOT || f.solid == SOLID_BSP)
		return;
		
	if (f.realmodelindex)
	{
		f.modelindex = f.realmodelindex;
		
		if (f.model)
		{
			mn = f.mins;
			mx = f.maxs;
			setmodel(f, f.model);
			setsize(f, mn, mx);

		}

	}
};

void() dovis =
{
	local entity e, m, f;

	m = nextent(world);
	while(m)
	{
		hide(m);
		m = nextent(m);
	}
	e = find(world, classname, "player");
	while(e)
	{
		f = findradius(e.player.origin, 512);
		while(f)
		{
			show(f);
			f = f.chain;
		}
		e = find(e, classname, "player");
	}
};