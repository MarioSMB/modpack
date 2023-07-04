#include "explosions.qh"

/*======================================================================
 PROJECTILE Explosion and Blood functions
 
======================================================================*/
PRECACHE(Explosions)
{
	precache_model("progs/proj_smoke.mdl");
	precache_model("progs/proj_flesh.mdl");
}


// Classic ID rocket/grenade explosion
void s_explode6(entity this) { set_anim(this, 5, SUB_Remove); }
void s_explode5(entity this) { set_anim(this, 4, s_explode6); }
void s_explode4(entity this) { set_anim(this, 3, s_explode5); }
void s_explode3(entity this) { set_anim(this, 2, s_explode4); }
void s_explode2(entity this) { set_anim(this, 1, s_explode3); }
void s_explode1(entity this) { set_anim(this, 0, s_explode2); }

//----------------------------------------------------------------------
void SpawnExplosion(int sprite_type, vector org, string expl_sound)
{
	if(sprite_type == EXPLODE_SMALL)
		__pointparticles(_particleeffectnum("TE_EXPLOSION"), org, '0 0 0', 1);
	else if(sprite_type == EXPLODE_MED)
		__pointparticles(_particleeffectnum("TE_EXPLOSION"), org, '0 0 0', 1);
	else if(sprite_type == EXPLODE_BIG)
		__pointparticles(_particleeffectnum("TE_EXPLOSION"), org, '0 0 0', 1);
	else if(sprite_type == EXPLODE_PLASMA_SMALL)
		__pointparticles(_particleeffectnum("TE_TEI_PLASMAHIT"), org, '0 0 0', 1);
	else if(sprite_type == EXPLODE_PLASMA_MED || sprite_type == EXPLODE_PLASMA_BIG)
		__pointparticles(_particleeffectnum("electro_combo"), org, '0 0 0', 1);
	else if(sprite_type == EXPLODE_POISON_SMALL)
		__pointparticles(_particleeffectnum("arc_bolt_explode"), org, '0 0 0', 1);
	else if(sprite_type == EXPLODE_POISON_MED || sprite_type == EXPLODE_POISON_BIG)
		__pointparticles(_particleeffectnum("explosion_medium"), org, '0 0 0', 1);
	else if(sprite_type == EXPLODE_ELECT_SMALL || sprite_type == EXPLODE_ELECT_MED || sprite_type == EXPLODE_ELECT_BIG)
		__pointparticles(_particleeffectnum("electro_ballexplode"), org, '0 0 0', 1);
	// This must be pre-cached by entity using it!
	// This is not cached in worldspawn as its rarely used
	else if(sprite_type == EXPLODE_ICE_BIG)
		__pointparticles(_particleeffectnum("electro_ballexplode"), org, '0 0 0', 1);
	else if(sprite_type == EXPLODE_BURST_SMOKE)
		__pointparticles(_particleeffectnum("grenade_explode"), org, '0 0 0', 1);
	else if(sprite_type == EXPLODE_BURST_FLAME)
		__pointparticles(_particleeffectnum("explosion_small"), org, '0 0 0', 1);
	else if(sprite_type == EXPLODE_BURST_POISON)
		__pointparticles(_particleeffectnum("arc_bolt_explode"), org, '0 0 0', 1);
	else
		return;

	// Always spawn a temporary entity
	// Need one for sprite and/or explosion sound
	entity newmis = spawn();
	set_movetype(newmis, MOVETYPE_NONE);
	newmis.solid = SOLID_NOT;
	setorigin(newmis, org);

	// No sprite required but need entity for sound to play
	// Allow for sound to finish and just remove
	setsize(newmis, '0 0 0', '0 0 0');
	setthink(newmis, SUB_Remove);
	newmis.nextthink = time + 4;

	// Play any explosion sounds on temporary entity
	if(expl_sound && expl_sound != "")
		_sound(newmis, CH_WEAPON_SINGLE, expl_sound, 1, ATTN_NORM);
}

//----------------------------------------------------------------------
// Should not be used anymore, this is the old ID system
// Use SpawnExplosion instead, copes with DP effects better
//----------------------------------------------------------------------
void BecomeExplosion(entity this)
{
	settouch(this, func_null);
	this.velocity = '0 0 0';
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_NOT;
	_setmodel(this, "");
	setsize(this, '0 0 0', '0 0 0');
	SpawnExplosion(EXPLODE_SMALL, this.origin, this.noise);
	this.nextthink = time + 0.6;
	setthink(this, SUB_Remove);
}

//----------------------------------------------------------------------
void SpawnProjectileSmoke(vector org, float velrnd, float upbase, float uprnd)
{
	entity newmis = spawn();
	set_movetype(newmis, MOVETYPE_TOSS);
	newmis.solid = SOLID_NOT;
	_setmodel(newmis, "progs/proj_smoke.mdl");
	setorigin(newmis, org);
	setsize(newmis, '0 0 0', '0 0 0');
	if(velrnd > 0) newmis.velocity = randomvec() * velrnd;
	else newmis.velocity = '0 0 0';
	newmis.velocity_z = upbase + random()*uprnd;
	newmis.nextthink = time + 1 + random()*3;
	setthink(newmis, SUB_Remove);
}

//----------------------------------------------------------------------
void SpawnVelocitySmoke(vector org, vector veldir, float velbase, float velrnd)
{
	entity newmis = spawn();
	set_movetype(newmis, MOVETYPE_TOSS);
	newmis.solid = SOLID_NOT;
	_setmodel(newmis, "progs/proj_smoke.mdl");
	setorigin(newmis, org);
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.velocity = veldir * (velbase + (random()*velrnd));
	newmis.nextthink = time + 1 + random()*3;
	setthink(newmis, SUB_Remove);
}

#if 0
//----------------------------------------------------------------------
void ProjectileType(entity source, entity targ)
{
	// Projectile types (Poison/Robot/Stone/Blood)
	if(source.poisonous)
	{
		_setmodel(targ, "progs/proj_fleshp.mdl");
		//targ.gibtype = GIBTYPE_POISON;
	}
	else if(source.classgroup == CG_ROBOT || source.classgroup == CG_STONE)
	{
		_setmodel(targ, "progs/proj_smoke.mdl");
		//targ.gibtype = GIBTYPE_STONE;
	}
	else
	{
		_setmodel(targ, "progs/proj_flesh.mdl");
		//targ.gibtype = GIBTYPE_BLOOD;
	}
	// Finally add DP particle trails
	// TODO
	//DPP_blood_trail(targ);
}
#endif

//----------------------------------------------------------------------
// Mainly used to show resistance to an ammo type
// Also used by boils for their idle gibs
//----------------------------------------------------------------------
void SpawnProjectileMeat(entity source, vector org, float velrnd, float upbase, float uprnd)
{
	entity newmis = spawn();
	newmis.classname = "item_gib";
	set_movetype(newmis, MOVETYPE_BOUNCE);
	newmis.solid = SOLID_NOT;
	// Projectile types (Poison/Robot/Stone/Blood)
	//ProjectileType(source, newmis);
	_setmodel(newmis, "progs/proj_flesh.mdl");
	setorigin(newmis, org);
	setsize(newmis, '0 0 0', '0 0 0');		
	newmis.velocity = randomvec() * velrnd;
	newmis.velocity_z = upbase, random()*uprnd;
	newmis.avelocity = randomvec() * 180;
	newmis.nextthink = time + 1 + random()*3;
	setthink(newmis, SUB_Remove);
}

//----------------------------------------------------------------------
// SpawnBlood (All blood particles through this function)
//----------------------------------------------------------------------
void SpawnBlood(vector org, vector vel, float damage, entity targ)
{
	float r = random();
	if(targ.takedamage != DAMAGE_AIM || targ.solid == SOLID_BSP)
		te_gunshot(org);
	else
	{
		if(targ.monsterdef && (targ.monsterdef.spawnflags & MON_FLAG_METAL))
			particle(org, vel * 0.1, 5, damage * 2);
		else
		{
			r = random();
			if(r < 0.7)
				particle(org, vel * 0.1, 73, damage * 2);
			else
			{
				particle(org, vel * 0.1, 79, damage * 1);
				particle(org, vel * 0.25, 74, damage * 5);
				particle(org, vel * 0.15, 69, damage * 2);
			}
		}
	}
}

/*
================
spawn_touchblood
================
*/
void spawn_touchblood(entity this, float damage, entity targ)
{
	vector vel = wall_velocity(this) * 0.2;
	SpawnBlood(this.origin + vel * 0.01, vel, damage, targ);
}

//======================================================================
// SpawnMeatSpray
// Changed to remove dependance on 'this' for missile origin
// Changed parameters to add source and destination of attack
// Changed velocity to side so it is calculated correctly from angles
//======================================================================
void SpawnMeatSpray(entity this, vector org, vector vel)
{
	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_NOT;

	fixedmakevectors(this.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	setthink(missile, SUB_Remove);

	_setmodel(missile, "progs/zom_gib.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, org);
}

/*
================
SpawnBitSpray
================
*/
void SpawnBitSpray(entity this, vector org, vector vel)
{
	vector mvel = vel;
	mvel.z += 250 + 50 * random();

	entity bit = new(gib);
	set_movetype(bit, MOVETYPE_BOUNCE);
	bit.owner = this;
	bit.solid = SOLID_BBOX;
	bit.angles = vectoangles(mvel);
	setthink(bit, SUB_Remove);
	bit.nextthink = time + 6;
	bit.velocity = mvel;
	setorigin(bit, org);

	bit.avelocity = '500 300 300';

	_setmodel(bit, "progs/bit.mdl");
	setsize(bit, '0 0 0', '0 0 0');
}
