#ifdef SVQC

spawnfunc(misc_gib2)
{
	if(!this.mdl || this.mdl == "")
	{
		float rnum = random ();
		if(rnum < 0.25)
			this.mdl = "progs/gib1.mdl";
		else if(rnum < 0.5)
			this.mdl = "progs/gib2.mdl";
		else if(rnum < 0.75)
			this.mdl = "progs/bone2.mdl";
		else
			this.mdl = "progs/bone.mdl";
	}
	precache_model(this.mdl);
	_setmodel(this, this.mdl);
	setsize (this, '0 0 0', '0 0 0');
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_TOSS);
}

spawnfunc(misc_gib)
{
	float r = random();
	if(r < 0.3)
	{
		precache_model("progs/bone2.mdl");
		_setmodel(this, "progs/bone2.mdl");
	}
	else if(r < 0.6)
	{
			precache_model("progs/gib2.mdl");
			_setmodel(this, "progs/gib2.mdl");
	}
	else
	{
		precache_model("progs/bone.mdl");
		_setmodel(this, "progs/bone.mdl");
	}
	setsize(this, '0 0 0', '0 0 0');
	this.solid = SOLID_NOT;
	this.angles_x = (this.angles_x + (random () * 360));
	this.angles_y = (this.angles_y + (random () * 360));
	this.angles_z = (this.angles_z + (random () * 360));
	set_movetype(this, MOVETYPE_TOSS);
	this.origin_z = this.origin_z + 1;
	setorigin(this, this.origin);
	droptofloor(this);
}

#endif
