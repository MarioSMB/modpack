#include "breakable.qh"

#ifdef SVQC

/*
===============================================================================
func_breakable
===============================================================================
*/

void make_breakable_debris(entity this)
{
	int i = 0;
	while (i < this.cnt)
	{
		entity debris = spawn();
		debris.origin_x = (this.maxs_x - this.mins_x)*random() + this.mins_x;
		debris.origin_y = (this.maxs_y - this.mins_y)*random() + this.mins_y;
		debris.origin_z = (this.maxs_z - this.mins_z)*random() + this.mins_z;
		debris.solid = SOLID_NOT;
		_setmodel(debris, this.mdl);
		setsize(debris, '0 0 0', '0 0 0');
		debris.velocity = VelocityForDamage(this, this, this.health * 2);
		set_movetype(debris, MOVETYPE_BOUNCE);
		debris.avelocity_x = random()*600;
		debris.avelocity_y = random()*600;
		debris.avelocity_z = random()*600;
		SUB_SetFade(debris, time + 10 + random() * 10, 0.5);
		debris.ltime = time;
		//debris.nextthink = time + 3;
		debris.flags = 0;

		if(this.style == BREAKABLE_REDMETAL)
		{
			debris.skin = 1;
			if(random() > 0.333)
				debris.frame = 1; //larger
			else
				debris.frame = 2; //smaller
		}
		else if(this.style == BREAKABLE_CONCRETE)
		{
			debris.skin = 2;
			if(random() > 0.333)
				debris.frame = 1; //larger
			else
				debris.frame = 2; //smaller
		}
		else if(this.style == BREAKABLE_GLASS)
		{
			debris.alpha = 0.6;
			debris.frame = 1;
		}
		else if(this.style == BREAKABLE_GREENMETAL)
		{
			debris.skin = 0;
			if(random() > 0.333)
				debris.frame = 1; //larger
			else
				debris.frame = 2; //smaller
		}
		if(this.alpha2)
			debris.alpha = this.alpha2;

		i += 1;
	}
	
}

void func_breakable_break(entity this, entity actor, entity trigger)
{
	if(this.noise1 && this.noise1 != "")
		_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_NONE);
	this.origin = (this.absmin + this.absmax) * 0.5;
	setorigin(this, this.origin);	
	make_breakable_debris(this);

	if(this.switchshadstyle)
		lightstyle(this.switchshadstyle, "m");

	SUB_UseTargets(this, actor, trigger);
	delete(this);
}

void func_breakable_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	func_breakable_break(this, attacker, inflictor);
}


/*QUAKED func_breakable (0 .5 .8) ? NO_MONSTERS
A visible object that can be destroyed by shooting it. If it has a targetname, it will not be directly damageable.

NO_MONSTERS: object ignores damage from monsters

"health" Default 20

"cnt" number of pieces of debris to spawn. default 6.

"style" The style of the debris:
0 = green metal (default)
1 = red metal
2 = concrete
3 = glass
*/
spawnfunc(func_breakable)
{
	this.solid = SOLID_BSP;
	set_movetype(this, MOVETYPE_PUSH);
	_setmodel(this, this.model);

	if(this.style == BREAKABLE_REDMETAL)
	{
		if(!this.noise1 || this.noise1 == "")
			this.noise1 = "misc/metal_impact.wav";
		if(!this.mdl || this.mdl == "")
			this.mdl = "progs/debris.mdl";
		this.cnt = zeroconvertdefault(this.cnt, 6);
	}
	else if(this.style == BREAKABLE_CONCRETE)
	{
		if(!this.noise1 || this.noise1 == "")
			this.noise1 = "misc/conc_impact.wav";
		if(!this.mdl || this.mdl == "")
			this.mdl = "progs/debris.mdl";
		this.cnt = zeroconvertdefault(this.cnt, 6);
	}
	else if(this.style == BREAKABLE_GLASS)
	{
		if(!this.mdl || this.mdl == "")
			this.mdl = "maps/glass01.bsp";
		if(!this.noise1 || this.noise1 == "")
			this.noise1 = "misc/glass_impact.wav";
		this.cnt = zeroconvertdefault(this.cnt, 15);
	}
	else if(this.style == BREAKABLE_GREENMETAL)
	{
		if(!this.noise1 || this.noise1 == "")
			this.noise1 = "misc/metal_impact.wav";
		if(!this.mdl || this.mdl == "")
			this.mdl = "progs/debris.mdl";
		this.cnt = zeroconvertdefault(this.cnt, 6);
	}
	else if(this.style == BREAKABLE_WOOD)
	{
		if(!this.noise1 || this.noise1 == "")
			this.noise1 = "misc/wood_impact.wav";
		if(!this.mdl || this.mdl == "")
			this.mdl = "maps/wood07.bsp";
		this.cnt = zeroconvertdefault(this.cnt, 6);
	}
	else
	{
		if(!this.noise1 || this.noise1 == "")
			this.noise1 = "misc/null.wav";
		if(!this.mdl || this.mdl == "")
			this.mdl = "progs/misc_empty.mdl";
		this.cnt = zeroconvertdefault(this.cnt, 6);
	}

	if(this.noise1 && this.noise1 != "")
		precache_sound(this.noise1);
	if(this.mdl && this.mdl != "")
		precache_model(this.mdl);
	if(this.health <= 0)
		this.health = 20;

	this.use = func_breakable_break;

	if((!this.targetname || this.targetname == "") || (this.targetname && this.targetname != "" && (this.spawnflags & BREAKABLE_ALWAYS_SHOOTABLE)))
	{
		this.takedamage = DAMAGE_YES;
		this.th_die = func_breakable_die;
	}

	if(this.switchshadstyle)
		lightstyle(this.switchshadstyle, "a");
}

#endif
