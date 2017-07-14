#ifdef SVQC

void barrel_explode(entity this, entity attacker)
{
	this.takedamage = DAMAGE_NO;
	this.classname = "explo_box";
	// did say this.owner
	T_RadiusDamage(this, this, 160, NULL);
	_sound(this, CH_TRIGGER_SINGLE, "weapons/r_exp3.wav", 1, ATTN_NORM);
	particle(this.origin, '0 0 0', 75, 255);

	setSendEntity(this, func_null); // some things are gonna happen to this barrel that the ChildrenS of QuakeC shouldn't see

	this.origin_z = this.origin_z + 32;
	BecomeExplosion(this);
}

void barrel_spawn(entity this)
{
	this.solid = SOLID_BBOX;
	precache_model(this.model);
	_setmodel(this, this.model);
	precache_sound("weapons/r_exp3.wav");
	if(!this.health)
		this.health = 20;
	this.th_die = barrel_explode;
	this.takedamage = DAMAGE_AIM;

	this.origin_z = this.origin_z + 2;
	float oldz = this.origin_z;
	WITHSELF(this, builtin_droptofloor());
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
	this.model = "maps/b_explob.bsp";
	barrel_spawn(this);
}



/*QUAKED misc_explobox2(0 .5 .8)(0 0 0)(32 32 64)
Smaller exploding box, REGISTERED ONLY
*/

spawnfunc(misc_explobox2)
{
	this.model = "maps/b_exbox2.bsp";
	barrel_spawn(this);
}

#endif
