#ifdef SVQC

void barrel_explode(entity this)
{
	// did say this.owner
	T_RadiusDamage(this, this.enemy, 160, DEATH_TRAP.m_id, NULL);
	sound(this, CH_TRIGGER_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	particle(this.origin, '0 0 0', 75, 255);

	// yoder add, 27/09/2020 to make barrels fire targets on explode
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
	this.enemy = attacker;
	this.classname = "explo_box";
	this.takedamage = DAMAGE_NO;
	setthink(this, barrel_explode);
	this.nextthink = time + 0.15;
}

void barrel_detonate_use(entity this, entity actor, entity trigger)
{
	this.enemy = actor;
	this.classname = "explo_box";
	this.takedamage = DAMAGE_NO;
	setthink(this, barrel_explode);
	this.nextthink = time + 0.1;
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
	this.use = barrel_detonate_use;
	this.takedamage = DAMAGE_AIM;
	this.killstring = " blew up";

	if(this.classname != "func_explobox")
	{
		this.origin_z = this.origin_z + 2;
		float oldz = this.origin_z;
		DropToFloor_QC_DelayedInit(this);
		if(oldz - this.origin_z > 250)
		{
			LOG_DEBUG("Exploding box fell out of the level at ", vtos(this.origin), "\n");
			delete(this);
			return;
		}
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

/*QUAKED func_explobox (.8 .2 0) ? TARBABY PUFF - - - - - START_INVIS
Build your own exploding box!

Keyvalues:
"health"	defaults to 18. -1 will make it immune to damage (trigger only)
"dmg"		damage to explode with, defaults to 150 if unset. -1 will force 0.
"target"	fires targets when it explodes
"targetname"	will explode when triggered
"wait"		will respawn after 'wait' seconds
"count"		will only respawn 'count' times
*/
/*FGD
@SolidClass base(Explobox, FuncInvis) = func_explobox : "Customizable exploding container. 
Explodes when triggered or shot. Fires targets when it explodes." 
[
	dmg(integer) : "Explosion damage (-1 will force 0)" : 150
]
*/
spawnfunc(func_explobox)
{
	this.mdl = this.model;
	barrel_spawn(this);
}


void func_explode_detonate(entity this)
{
	//vector pos = this.mins + (this.size * 0.5);
	//pos.z -= 32;
	//setmodel(this, MDL_Null);
	//setsize(this, '0 0 0', '0 0 0');
	//setorigin(this, pos);

	barrel_explode(this);
}

void func_explode_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.enemy = attacker;
	this.takedamage = DAMAGE_NO;
	setthink(this, func_explode_detonate);
	this.nextthink = time + 0.15;
}


/*QUAKED func_explode (0 .5 .8) (0 0 0) (32 32 64)
Custom exploding box
*/

spawnfunc(func_explode)
{
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_BSP;
	precache_model(this.model);
	_setmodel(this, this.model);

	this.health = 20;
	this.th_die = func_explode_die;
	this.takedamage = DAMAGE_AIM;
}

#endif
