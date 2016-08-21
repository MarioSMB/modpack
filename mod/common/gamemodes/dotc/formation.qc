void dotc_setformation_broad(entity this)
{
	float x = -floor(this.cnt / 2);
	FOREACH_ENTITY_ENT(owner, this,
	{
		++x;
		it.dotc_formation_ofs_z = 0;
		it.dotc_formation_ofs_y = 0;
		it.dotc_formation_ofs_x = x * formation_offset1;
	});	
}

void dotc_setformation_line(entity this)
{
	float y = 0;
	FOREACH_ENTITY_ENT(owner, this,
	{
		++y;
		it.dotc_formation_ofs_x = 0;
		it.dotc_formation_ofs_z = 0;
		it.dotc_formation_ofs_y = y * formation_offset1;
	});
}

void dotc_setformation_box()
{
	LOG_DEBUG("dotc_setformation_box not implemented.\n");
}

void dotc_setformation_wedge(entity this)
{
	entity drone;
	float x, xo, yo;
		
	drone = findchainentity(owner, this);	
	drone.dotc_formation_ofs_z = 0;
	drone.dotc_formation_ofs_x = 0;
	drone.dotc_formation_ofs_y = 0;
	
	drone = drone.chain;
	if(!drone)
		return;
	
	int line = 1;	
	
	while(drone)
	{
		xo = 0.5 * line * -formation_offset1;
		yo = line *  -formation_offset1;
		for(x = 0; x <= line; ++x)
		{
		
			drone.dotc_formation_ofs_z = 0;
			drone.dotc_formation_ofs_x = xo + x * formation_offset1;
			drone.dotc_formation_ofs_y = yo;
			drone = drone.chain;
		}
		++line;
		
	}
}

void dotc_formation_force(entity sqent)
{
	vector pos;
	entity drone;
	
	drone = findchainentity(squad, sqent);	
	while(drone)
	{		
		pos = sqent.origin + (drone.dotc_formation_ofs_x * v_right) + (drone.dotc_formation_ofs_y * v_forward);
		setorigin(drone, pos);
		drone.pos1 = pos;
		drone.angles = vectoangles(v_forward);
		drone = drone.chain;
	}
}
