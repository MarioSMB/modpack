.float walltype;

void DebrisBounceSound(entity this, entity toucher)
{
	float r = random();
	if(r < 0.4)
	{
		if(this.walltype == 2)
			_sound(this, CHAN_AUTO, "enviro/physics/glassbit.wav", 1, ATTN_NORM);
		else
			_sound(this, CHAN_AUTO, "enviro/physics/piece1.wav", 1, ATTN_NORM);
	}
	else if(r < 0.7)
	{
		if(this.walltype == 2)
			_sound(this, CHAN_AUTO, "enviro/physics/glassbit.wav", 1, ATTN_NORM);
		else
			_sound(this, CHAN_AUTO, "enviro/physics/piece2.wav", 1, ATTN_NORM);
	}
	else if(r < 0.9)
	{
		if(this.walltype == 2)
			_sound(this, CHAN_AUTO, "enviro/physics/glassbit.wav", 1, ATTN_NORM);
		else
			_sound(this, CHAN_AUTO, "enviro/physics/piece3.wav", 1, ATTN_NORM);
	}
	else
	{
		delete(this);
		return;
	}
	if(this.velocity == '0 0 0')
		this.avelocity = '0 0 0';
}

void throw_debris(entity this)
{
	entity targ = find(NULL, targetname, this.target);
	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	settouch(missile, DebrisBounceSound);
	makevectors(this.angles);
	missile.velocity = VelocityForDamage(this, 0);
	missile.avelocity = '300 100 200';
	if(targ.classname == "light")
		missile.nextthink = ((time + 4) + (random () * 4));
	else
		missile.nextthink = ((time + 10) + (random () * 10));
	setthink(missile, SUB_Remove);
	if(!this.walltype)
	{
		_setmodel(missile, "progs/rubble.mdl");
		this.walltype = 0;
	}
	if(this.walltype == 0)
	{
		_setmodel(missile, "progs/rubble.mdl");
		missile.skin = 0;
	}
	else if(this.walltype == 1)
	{
		_setmodel(missile, "progs/rubble.mdl");
		missile.skin = 1;
	}
	else if(this.walltype == 2)
	{
		_setmodel(missile, "progs/glass.mdl");
		if(random () < 0.5)
			missile.skin = 2;
		else if((random () < 0.5))
			missile.skin = 1;
		else
			missile.skin = 0;
	}
	else if(this.walltype == 3)
	{
		_setmodel(missile, "progs/rubble.mdl");
		missile.skin = 3;
	}
	else if(this.walltype == 4)
	{
		_setmodel(missile, "progs/rubble.mdl");
		missile.skin = 4;
	}
	else if(this.walltype == 5)
	{
		_setmodel(missile, "progs/rubble.mdl");
		missile.skin = 5;
	}
	else if(this.walltype == 6)
	{
		_setmodel(missile, "progs/rubble.mdl");
		missile.skin = 6;
	}
	else if(this.walltype == 7)
	{
		_setmodel(missile, "progs/rubble.mdl");
		missile.skin = 7;
	}
	else if(this.walltype == 8)
	{
		_setmodel(missile, "progs/rubble.mdl");
		missile.skin = 8;
	}
	else if(this.walltype == 9)
	{
		_setmodel(missile, "progs/rubble.mdl");
		missile.skin = 9;
	}
	if(targ.classname == "light")
		_setmodel(missile, "progs/sglass.mdl");
	if(random() < 0.25 || missile.model != "progs/rubble.mdl")
		missile.frame = 0;
	else if(random () < 0.5)
		missile.frame = 1;
	else if(random () < 0.75)
		missile.frame = 2;
	else if(random () <= 1)
		missile.frame = 3;
	missile.origin_x = (this.absmin_x + (this.size_x * random()));
	missile.origin_y = (this.absmin_y + (this.size_y * random()));
	missile.origin_z = (this.absmin_z + (this.size_z * random()));
	setorigin(missile, missile.origin);
	setsize(missile, '0 0 0', '0 0 0');
}

void wall_die(entity this, entity inflictor, entity attacker)
{
	entity targ = find(NULL, targetname, this.target);
	if(targ.classname == "light")
	{
		lightstyle (targ.style, "a");
		this.style = 1;
	}
	if(this.walltype == 0)
		sound(this, CHAN_AUTO, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	else if(this.walltype == 1)
		_sound(this, CHAN_AUTO, "enviro/physics/wallexpl.wav", 1, ATTN_NORM);
	else if(this.walltype == 2)
	{
		_sound(this, CHAN_AUTO, "enviro/physics/glass.wav", 1, ATTN_NORM);
		_sound(this, CHAN_AUTO, "enviro/physics/glass.wav", 1, ATTN_NORM);
		_sound(this, CHAN_AUTO, "enviro/physics/glassbit.wav", 1, ATTN_NORM);
	}
	else if(this.walltype == 3)
		sound(this, CHAN_AUTO, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	else if(this.walltype == 4)
		sound(this, CHAN_AUTO, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	else if(this.walltype == 5)
		sound(this, CHAN_AUTO, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	else if(this.walltype == 6)
		sound(this, CHAN_AUTO, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	else if(this.walltype == 7)
		sound(this, CHAN_AUTO, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	else if(this.walltype == 8)
		sound(this, CHAN_AUTO, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	else if(this.walltype == 9)
		sound(this, CHAN_AUTO, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);

	if(this.style == 1)
	{
		throw_debris(this);
		throw_debris(this);
		throw_debris(this);
		throw_debris(this);
		throw_debris(this);
		throw_debris(this);
		throw_debris(this);
	}
	else if(this.style == 2)
	{
		throw_debris(this);
		throw_debris(this);
		throw_debris(this);
		throw_debris(this);
		throw_debris(this);
		throw_debris(this);
		throw_debris(this);
		throw_debris(this);
		throw_debris(this);
		throw_debris(this);
	}
	else
	{
		throw_debris(this);
		throw_debris(this);
		throw_debris(this);
		throw_debris(this);
		throw_debris(this);
	}
	SUB_UseTargets(this, NULL, NULL);
	delete(this);
}

void wall_diethink(entity this)
{
	wall_die(this, NULL, NULL);
}

void wall_dieuse(entity this, entity actor, entity trigger)
{
	wall_die(this, NULL, NULL);
}

void wall_touch(entity this, entity toucher)
{
	if(this.cnt == 1)
		return;
	if(!IS_PLAYER(toucher))
		return;
	setthink(this, wall_diethink);
	this.nextthink = this.ltime + 0.1;
	this.cnt = 1;
}

spawnfunc(wall_explode)
{
	if(!MP_IMPEL) { delete(this); return; }

	precache_model2("progs/sglass.mdl");
	precache_model2("progs/glass.mdl");
	precache_model2("progs/rubble.mdl");
	precache_sound2("enviro/physics/glass.wav");
	precache_sound2("enviro/physics/glassbit.wav");
	precache_sound2("enviro/physics/wallexpl.wav");
	precache_sound2("enviro/physics/piece1.wav");
	precache_sound2("enviro/physics/piece2.wav");
	precache_sound2("enviro/physics/piece3.wav");
	this.mangle = this.angles;
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_PUSH);
	_setmodel(this, this.model);
	this.solid = SOLID_BSP;
	this.classname = "wall_explode";
	setorigin(this, this.origin);
	if(this.targetname && this.targetname != "")
	{
		this.use = wall_dieuse;
		this.takedamage = DAMAGE_NO;
		return;
	}
	if(!this.health)
		settouch(this, wall_touch);
	else
	{
		this.takedamage = DAMAGE_YES;
		this.th_die = wall_die;
	}
}
