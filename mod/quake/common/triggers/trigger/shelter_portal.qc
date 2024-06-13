#ifdef SVQC

const int SHELTER_FLIPPED = BIT(0);

void trigger_shelter_portal_touch(entity this, entity toucher)
{
	if(toucher.health > 0 || toucher.classname == "grenade")
	{
		vector offs = toucher.origin - this.pos1;
		float dot = offs * this.pos2;
		if(dot >= 0)
			toucher.flags |= FL_INSHELTER;
		else
			toucher.flags &= ~FL_INSHELTER;
	}
}

/*QUAKED trigger_shelter (.5 .5 .5) 
Shelters the player from pushes
*/
spawnfunc(trigger_shelter_portal)
{
	InitTrigger(this);
	settouch(this, trigger_shelter_portal_touch);
	this.pos1 = this.mins + (this.size * 0.5);
	if(this.size_x < this.size_y)
	{
		if(this.size_x < this.size_z)
			this.pos2 = '1 0 0';
		else
			this.pos2 = '0 0 1';
	}
	else
	{
		if(this.size_y < this.size_z)
			this.pos2 = '0 1 0';
		else
			this.pos2 = '0 0 1';
	}

	if(this.spawnflags & SHELTER_FLIPPED)
		this.pos2 *= -1;
}

#endif
