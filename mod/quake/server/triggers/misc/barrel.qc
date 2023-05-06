#ifdef SVQC

void barrel_explode(entity this)
{
	// did say this.owner
	T_RadiusDamage(this, this.enemy, 160, DEATH_TRAP.m_id, NULL);
	sound(this, CH_TRIGGER_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	particle(this.origin, '0 0 0', 75, 255);

	// yoder add, 27/09/2020 to make barrels fire targets on explode
	if(MP_MG)
		SUB_UseTargets(this, this.enemy, NULL);

	setmodel(this, MDL_Null);
	setsize(this, '0 0 0', '0 0 0');
	setorigin(this, this.origin + '0 0 32');
	setthink(this, BecomeExplosion);
	this.nextthink = time;

	CSQCMODEL_AUTOUPDATE(this);
}

void barrel_detonate(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.classname = "explo_box";
	this.takedamage = DAMAGE_NO;
	setthink(this, barrel_explode);
	if(MP_MG)
		this.nextthink = time + 0.15;
	else
		this.nextthink = time + 0.3; // enhanced uses .ltime but that doesn't translate well to time!
}

void barrel_spawn(entity this)
{
	if(!this.mdl || this.mdl == "")
		this.mdl = "maps/b_explob.bsp";

	this.solid = SOLID_BSP;
	set_movetype(this, MOVETYPE_NONE); // enhanced uses MOVETYPE_PUSH, doesn't use regular thinking
	precache_model(this.mdl);
	_setmodel(this, this.mdl);
	if(!this.health)
		this.health = 20;
	this.th_die = barrel_detonate;
	this.takedamage = DAMAGE_AIM;
	this.killstring = " blew up";

	this.origin_z = this.origin_z + 2;
	float oldz = this.origin_z;
	droptofloor(this);
	if(oldz - this.origin_z > 250)
	{
		LOG_DEBUG("Exploding box fell out of the level at ", vtos(this.origin), "\n");
		delete(this);
		return;
	}

	CSQCMODEL_AUTOINIT(this);
}


/*QUAKED misc_explobox(0 .5 .8)(0 0 0)(32 32 64)
TESTING THING
*/

spawnfunc(misc_explobox)
{
	this.mdl = "maps/b_explob.bsp";
	barrel_spawn(this);
}



/*QUAKED misc_explobox2(0 .5 .8)(0 0 0)(32 32 64)
Smaller exploding box, REGISTERED ONLY
*/

spawnfunc(misc_explobox2)
{
	this.mdl = "maps/b_exbox2.bsp";
	barrel_spawn(this);
}


void func_explode_detonate(entity this)
{
	vector pos = this.mins + (this.size * 0.5);
	pos.z -= 32;
	setmodel(this, MDL_Null);
	setorigin(this, pos);

	barrel_explode(this);
}

void func_explode_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.takedamage = DAMAGE_NO;
	setthink(this, func_explode_detonate);
	this.nextthink = time + 0.15;
}


/*QUAKED func_explode (0 .5 .8) (0 0 0) (32 32 64)
Custom exploding box
*/

spawnfunc(func_explode)
{
	if(!MP_MG) { delete(this); return; }
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_BSP;
	_setmodel(this, this.model);

	this.health = 20;
	this.th_die = func_explode_die;
	this.takedamage = DAMAGE_AIM;
}

#endif
