#include "weapons.qh"

#include "bulletholes.qh"
#include "combat.qh"
#include "client.qh"
#include "impel/impel.qh"
#include "impulse.qh"
#include "rogue/lava_wpn.qh"
#include "monsters/ai.qh"

/*
*/
void player_run(entity this);
void SuperDamageSound(entity this);

// called by worldspawn
PRECACHE(Weapons)
{
	precache_sound("weapons/rocket1i.wav");	// spike gun
	precache_sound("weapons/sgun1.wav");
	precache_sound("weapons/guncock.wav");	// player shotgun
	precache_sound("weapons/ric1.wav");	// ricochet(used in c code)
	precache_sound("weapons/ric2.wav");	// ricochet(used in c code)
	precache_sound("weapons/ric3.wav");	// ricochet(used in c code)
	precache_sound("weapons/spike2.wav");	// super spikes
	precache_sound("weapons/tink1.wav");	// spikes tink(used in c code)
	precache_sound("weapons/grenade.wav");	// grenade launcher
	precache_sound("weapons/bounce.wav");		// grenade bounce
	precache_sound("weapons/shotgn2.wav");	// super shotgun
}

/*
================
HIPNOTIC WEAPONS
================
*/
void HIP_LaserTouch(entity this, entity toucher)
{
	this.owner = NULL;
	this.cnt = this.cnt + 1;
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	vector oldvel = normalize(this.old_velocity);
	vector spot1 = this.origin -(16*oldvel);
	vector spot2 = this.origin +(16*oldvel);
	traceline(spot1, spot2, false, this);  // see through other monsters
	this.origin = trace_endpos;

	vector org = this.origin;

	if(toucher.health)
	{
		if(this.lastvictim == toucher)
			this.dmg = this.dmg / 2;
		spawn_touchblood(this, this.dmg, toucher);
		T_Damage(toucher, this, this.lastvictim, this.dmg, WEP_LASER_CANNON.m_id);
	}
	else if((this.cnt == 3) ||(random()<0.15))
	{
		te_gunshot(org);
	}
	else
	{
//      this.dmg = 0.66 * this.dmg;
		this.dmg = 0.9 * this.dmg;
//      this.speed = 0.95 * this.speed;
		this.velocity = oldvel + (2 * trace_plane_normal);
		this.velocity = normalize(this.velocity);
		this.velocity = this.speed * this.velocity;
		this.old_velocity = this.velocity;
		UNSET_ONGROUND(this);
		//float r = random();
		_sound(this, CH_WEAPON_SINGLE, "hipweap/laserric.wav", 1, ATTN_STATIC);
/*
		if(r<0.33)
		_sound(this, CH_WEAPON_SINGLE, "weapons/ric1.wav", 1, ATTN_STATIC);
		else if(r<0.66)
		_sound(this, CH_WEAPON_SINGLE, "weapons/ric2.wav", 1, ATTN_STATIC);
		else
		_sound(this, CH_WEAPON_SINGLE, "weapons/ric3.wav", 1, ATTN_STATIC);
*/
		return;
		}
	_sound(this, CH_WEAPON_SINGLE, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	delete(this);

}
void HIP_LaserThink(entity this)
{
	if(time > this.attack_finished)
	{
		delete(this);
		return;
	}
	UNSET_ONGROUND(this);
	this.velocity = this.old_velocity;
	this.angles = vectoangles(this.velocity);
	this.nextthink = time + 0.1;
}

entity HIP_LaunchLaser(entity this, vector org, vector vec, float light)
{
//   _sound(this ,CH_WEAPON_SINGLE, "weapons/shotgn2.wav", 1, ATTN_NORM);
	_sound(this, CH_WEAPON_SINGLE, "hipweap/laserg.wav", 1, ATTN_NORM);

	vec = normalize(vec);

	entity missile = new(hiplaser);
	missile.owner = this;
	missile.lastvictim = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	if(light)
		missile.effects = EF_DIMLIGHT;

	_setmodel(missile, "progs/lasrspik.mdl");
	setsize(missile, '0 0 0', '0 0 0');

	setorigin(missile, org);

	missile.speed = 1000;
	missile.dmg = 18;
	missile.velocity = vec * missile.speed;
	missile.old_velocity = missile.velocity;
	missile.angles = vectoangles(missile.velocity);
	missile.avelocity = '0 0 400';

	missile.nextthink = time;
	missile.attack_finished = time + 5;
	setthink(missile, HIP_LaserThink);
	settouch(missile, HIP_LaserTouch);
	missile.count = 0;

	return missile;
}


//============================================================================


vector wall_velocity(entity this)
{
	vector vel = normalize(this.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
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

/*
================
SpawnMeatSpray
================
*/
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
SpawnBlood
================
*/
void SpawnBlood(vector org, vector vel, float damage, entity targ)
{
	float r = random();
	if(targ.takedamage != DAMAGE_AIM || targ.classname == "misc_explobox" || targ.classname == "wall_explode" || targ.classname == "misc_explobox2")
		te_gunshot(org);
	else
	{
		if(targ.monsterdef.spawnflags & MON_FLAG_METAL)
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


/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity	multi_ent;
float	multi_damage;
int multi_deathtype;

void ClearMultiDamage()
{
	multi_ent = NULL;
	multi_damage = 0;
	multi_deathtype = 0;
}

void ApplyMultiDamage(entity this)
{
	if(!multi_ent)
		return;
	T_Damage(multi_ent, this, this, multi_damage, multi_deathtype);
}

void AddMultiDamage(entity hit, float damage, int deathtype)
{
	if(!hit)
		return;
	
	if(hit != multi_ent)
	{
		ApplyMultiDamage(hit);
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
}

/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
TraceAttack
================
*/
void TraceAttack(float damage, vector dir, int deathtype)
{
	vector vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	vector org = trace_endpos - dir*4;

	if(trace_ent.takedamage) // yoder mod, Jan 05 2021)
	{
		if(trace_ent.solid != SOLID_BSP) // not on walls (TODO: iscreature field)
			SpawnBlood(org, vel*0.2, damage, trace_ent);
		else
			te_gunshot(org); // secret doors need bumps too!
		AddMultiDamage(trace_ent, damage, deathtype);
	}
	else
		te_gunshot(org);
}

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void FireBullets(entity this, int shotcount, vector dir, vector spread, int deathtype)
{
	bool bullet = false; // hipnotic bullet holes

	makevectors(this.v_angle);

	vector src = this.origin + v_forward*10;
	src.z = this.absmin_z + this.size_z * 0.7;

	ClearMultiDamage();
	multi_deathtype = deathtype;
	while(shotcount > 0)
	{
		vector direction = dir + crandom() * spread.x * v_right + crandom() * spread.y * v_up;

		traceline(src, src + direction * 2048, MOVE_NORMAL, this);
		if(trace_fraction != 1.0 && !(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY))
		{
			TraceAttack(4, direction, deathtype);

			if(!bullet && !trace_ent)
			{
				placebullethole(trace_endpos);
				bullet = true;
			}
		}

		shotcount -= 1;
	}
	ApplyMultiDamage(this);
}


/*
==============================================================================

ROCKETS

==============================================================================
*/

void s_explode6(entity this) { set_anim(this, 5, SUB_Remove); }
void s_explode5(entity this) { set_anim(this, 4, s_explode6); }
void s_explode4(entity this) { set_anim(this, 3, s_explode5); }
void s_explode3(entity this) { set_anim(this, 2, s_explode4); }
void s_explode2(entity this) { set_anim(this, 1, s_explode3); }
void s_explode1(entity this) { set_anim(this, 0, s_explode2); }

void BecomeExplosion(entity this)
{
	set_movetype(this, MOVETYPE_NONE);
	this.velocity = '0 0 0';
	settouch(this, func_null);
	setmodel(this, MDL_EXPLOSION);
	setsize(this, '0 0 0', '0 0 0');
	sound(this, CH_SHOTS, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	this.solid = SOLID_NOT;
	s_explode1(this);
}

void T_MissileTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float damg = 100 + random()*20;
	
	if(toucher.health)
	{
		if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
			damg = damg * 0.5;	// mostly immune
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, 120, this.projectiledeathtype, toucher);

//	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	this.origin = this.origin - 8 * normalize(this.velocity);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	BecomeExplosion(this);
}



/*
====================================
JUNK
====================================
*/

vector VelocityForDamage(entity this, float dm);

void PulseHome(entity this)
{
	vector vtemp = this.enemy.origin + '0 0 10';
	vector dir = normalize(vtemp - this.origin);
	this.velocity = dir * 800;
	if(!this.enemy)
	{
		this.nextthink = time + 5;
		setthink(this, SUB_Remove);
	}
	else
	{
		this.nextthink = time + 0.2;
		setthink(this, PulseHome);
	}
}

void missile_touchremove(entity this, entity toucher)
{
	delete(this);
}

void BecomePurpleExplosion(entity this, entity directhitentity, float dm)
{
	entity missile = spawn();
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	missile.velocity = VelocityForDamage(this, dm);
	missile.avelocity_x = random() * 300;
	missile.avelocity_y = random() * 300;
	missile.avelocity_z = random() * 300;
	settouch(missile, missile_touchremove);
	missile.nextthink = time + 3;
	setthink(missile, SUB_Remove);
	if(IS_PLAYER(directhitentity) || IS_MONSTER(directhitentity))
		_setmodel(missile, "progs/blpulse.mdl");
	else
		_setmodel(missile, "progs/wlpulse.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, this.origin - v_forward * 8);
}

void BecomeBloodSpurt(entity this, float dm)
{
	entity missile = spawn();
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	missile.velocity = VelocityForDamage(this, dm);
	missile.avelocity_x = random() * 300;
	missile.avelocity_y = random() * 300;
	missile.avelocity_z = random() * 300;
	settouch(missile, missile_touchremove);
	missile.nextthink = time + 3;
	setthink(missile, SUB_Remove);
	_setmodel(missile, "progs/blpulse.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, this.origin - v_forward * 8);
}

void T_SinglePulseTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	float damg = 20 + random() * 7;
	if(toucher.takedamage)
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);

	_sound(this, CH_SHOTS, "enforcer/enfstop.wav", 1, ATTN_NORM);
	BecomePurpleExplosion(this, toucher, damg);
	delete(this);
}

void W_FireRifle_SetupShot(entity actor, entity proj, int shotammo, string snd1, string snd2)
{
	if(snd1)
		_sound(actor, CH_SHOTS, snd1, 0.5, ATTN_NORM);
	if(snd2)
		_sound(actor, CH_WEAPON_B, snd2, 0.5, ATTN_NORM);

	proj.owner = actor;
	set_movetype(proj, MOVETYPE_FLYMISSILE);
	proj.solid = SOLID_BBOX;
	_setmodel(proj, "progs/pulse.mdl");
	setsize(proj, '0 0 0', '0 0 0');
}

void W_FireRifleTarget(entity this, entity targ)
{
	entity missile = new(pulse);
	W_FireRifle_SetupShot(this, missile, 0, string_null, "weapons/pulse/pulshot1.wav");

	setorigin(missile, ((this.origin + (v_right * 16)) + '0 0 8'));
	vector dir = normalize(targ.origin - missile.origin);
	missile.velocity = dir * 1000;
	missile.angles = vectoangles(missile.velocity);
	missile.projectiledeathtype = DEATH_PULSERIFLE.m_id;
	settouch(missile, T_SinglePulseTouch);
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);
}

void W_PulseRifle(entity this)
{
	entity selected = NULL;
	if(this.search_time < time)
	{
		makevectors(this.v_angle);
		float cur_dist = 0;
		entity head = findradius(this.origin, 500);
		while(head)
		{
			if(!(head.flags & FL_NOTARGET) && IS_MONSTER(head))
			{
				if(head.takedamage && head.health > 0 && !(head.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD) && visible(this, head))
				{
					float head_dist = vlen2(head.origin - this.origin);
					vector vec = normalize(head.origin - this.origin);
					float dot = vec * v_forward;
					if((!cur_dist || head_dist < cur_dist) && dot > 0.3)
					{
						selected = head;
						cur_dist = head_dist;
					}
				}
			}
			head = head.chain;
		}
		this.search_time = time + 1;
	}

	if(selected)
		W_FireRifleTarget(this, selected);
}

void ExtraBlood(entity targ, vector org, vector vel, float damage)
{
	if(targ.classname == "wall_explode")
	{
		SpawnBlood(org, vel, damage, targ);
		return;
	}
	particle(org, '0 0 100', 225, damage * 4);
}

void spawn_extrablood(entity this, entity targ, float damage)
{
	vector vel = wall_velocity(this) * 0.2;
	ExtraBlood(targ, this.origin + vel * 0.01, vel, damage);
}

void SpawnSpark(vector org, vector vel, float damage)
{
	particle(org, vel * 0.1, 47, damage * 2);
}

void spawn_touchspark(entity this, float damage)
{
	vector vel = wall_velocity(this) * 0.2;
	SpawnSpark(this.origin + vel * 0.01, vel, damage);
}

vector VelocityForJump(entity this, entity targ, float dm)
{
	vector v;

	if(targ.classname == "spark")
		return '0 0 0';
	else if(targ.classname == "missile" || targ.classname == "vore_ball")
		return '0 0 0';
	else if(((targ.monsterdef.spawnflags & MONSTER_TYPE_BOSS) || (targ.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT)) && targ.health > 16)
		return '0 0 0';
	if(targ.classname == "missile")
	{
		v.x = 50 * crandom();
		v.y = 50 * crandom();
		v.z = 50 + 50 * random();
	}
	else if(this.owner.super_damage_finished > time && IS_PLAYER(this.owner))
	{
		v.x = 1000 * crandom();
		v.y = 1000 * crandom();
		v.z = 2000 + 1000 * random();
	}
	else
	{
		v.x = 200 * crandom();
		v.y = 200 * crandom();
		v.z = 300 + 100 * random();
	}
	if(IS_PLAYER(targ))
		set_movetype(targ, MOVETYPE_WALK);
	v = v * 0.7;
	return v;
}

void SpawnMeatBounce(entity this, entity targ, float dm)
{
	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_NOT;
	makevectors(this.angles);
	missile.velocity = VelocityForJump(this, targ, dm);
	missile.avelocity = '3000 1000 2000';
	missile.nextthink = time + 1;
	setthink(missile, SUB_Remove);
	_setmodel(missile, "progs/zom_gib.mdl");
	setorigin(missile, targ.origin);
	setsize(missile, '0 0 0', '0 0 0');
}

void SpawnDischarge(entity this, float dm)
{
	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_NOT;
	makevectors(this.angles);
	missile.velocity = VelocityForJump(this, missile, dm);
	missile.avelocity = '3000 1000 2000';
	missile.nextthink = time + 0.2;
	setthink(missile, SUB_Remove);
	_setmodel(missile, "progs/bolt.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, this.origin);
}

.float modelindex_elec;
void gibhim(entity this)
{
	float r;

	if(!this.elec)
	{
		this.effects = EF_MUZZLEFLASH;
		r = random();
		if(r < 0.3)
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgdis1.wav", 1, ATTN_NORM);
		else if(r < 0.6)
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgdis2.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgdis3.wav", 1, ATTN_NORM);
		if(!IS_PLAYER(this))
			this.modelindex_elec = this.modelindex;
		this.modelindex = modelindex_bolt;
		this.frame = 0;
		this.elec = true;
		this.exptime = this.exptime + 0.1;
		spawn_touchspark(this, 10);
	}
	else if(this.elec)
	{
		if(IS_PLAYER(this))
		{
			r = random();
			this.modelindex = this.modelindex_player;
			//_setmodel(this, "progs/player.mdl");
			if(this.weaponentity.m_weapon == WEP_AXE)
			{
				if(r < 0.3)
					this.frame = 31;
				else if(r < 0.6)
					this.frame = 35;
				else
					this.frame = 42;
			}
			else if(r < 0.3)
				this.frame = 61;
			else if(r < 0.6)
				this.frame = 71;
			else
				this.frame = 87;
		}
		else if(this.modelindex_elec)
		{
			this.modelindex = this.modelindex_elec;
			this.modelindex_elec = 0;
		}
		this.effects = EF_DIMLIGHT;
		this.elec = false;
		this.exptime = this.exptime + 0.1;
	}
	if(this.exptime >= 1.6)
	{
		this.effects &= ~EF_DIMLIGHT;
		this.effects &= ~EF_MUZZLEFLASH;
		this.takedamage = DAMAGE_AIM;
		set_movetype(this, MOVETYPE_STEP);
		if(!IS_PLAYER(this))
			T_RadiusDamage(this, this.owner, 120, WEP_LIGHTME.m_id, NULL);
		else
			T_RadiusDamage(this, this.enemy, 120, WEP_LIGHTME.m_id, NULL);
		SpawnDischarge(this, 120);
		SpawnDischarge(this, 120);
		SpawnDischarge(this, 120);
		r = random();
		if(r < 0.3)
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgdis1.wav", 1, ATTN_NORM);
		else if(r < 0.6)
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgdis2.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgdis3.wav", 1, ATTN_NORM);
		this.exptime = 0;
		return;
	}
	this.nextthink = time + 0.1;
	setthink(this, gibhim);
}


/*
===============================================================================

LIGHTNING

===============================================================================
*/



/*
=================
LightningDamage
=================
*/
void LightningDamage(vector p1, vector p2, entity from, float damage, int deathtype)
{
	vector f = p2 - p1;
	normalize(f);
	f = vec3(0 - f.y, f.x, 0) * 16;

	traceline(p1, p2, false, from);
	if(trace_ent.takedamage && !trace_ent.wetsuit_finished)
	{
		if(trace_ent.takedamage == DAMAGE_AIM)
			particle(trace_endpos, '0 0 100', 225, damage * 4);
		T_Damage(trace_ent, from, from, damage, deathtype);
		if(IS_PLAYER(from))
		{
			if(IS_PLAYER(trace_ent))
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	entity e1 = trace_ent;

	traceline(p1 + f, p2 + f, false, from);
	if(trace_ent != e1 && trace_ent.takedamage && !trace_ent.wetsuit_finished)
	{
		if(trace_ent.takedamage == DAMAGE_AIM)
			particle(trace_endpos, '0 0 100', 225, damage * 4);
		T_Damage(trace_ent, from, from, damage, deathtype);
	}
	entity e2 = trace_ent;

	traceline(p1 - f, p2 - f, false, from);
	if(trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage && !trace_ent.wetsuit_finished)
	{
		if(trace_ent.takedamage == DAMAGE_AIM)
			particle(trace_endpos, '0 0 100', 225, damage * 4);
		T_Damage(trace_ent, from, from, damage, deathtype);
	}
}


//=============================================================================


// TODO: additional frame information unknown!
// NOTE: decompiled code alternates between first 2 frames, this is changed to use the frames available in the model
//$frame flame1 flame2 flame3 flame4 flame5 flame6
//$frame flameb1 flameb2 flameb3 flameb4 flameb5 flameb6 flameb7 flameb8 flameb9 flameb10
//$frame flameb11

const int anim_flame1 = 0;
const int anim_flame2 = 1;
const int anim_flame3 = 2;
const int anim_flame4 = 3;
const int anim_flame5 = 4;
const int anim_flame6 = 5;

const int anim_flameb1 = 0;
const int anim_flameb2 = 1;
const int anim_flameb3 = 2;
const int anim_flameb4 = 3;
const int anim_flameb5 = 4;
const int anim_flameb6 = 5;
const int anim_flameb7 = 6;
const int anim_flameb8 = 7;
const int anim_flameb9 = 8;
const int anim_flameb10 = 9;
const int anim_flameb11 = 10;

void flameanimate1(entity this);
void flameanimate6(entity this) { set_anim(this, anim_flame6, flameanimate1); }
void flameanimate5(entity this) { set_anim(this, anim_flame5, flameanimate6); }
void flameanimate4(entity this) { set_anim(this, anim_flame4, flameanimate5); }
void flameanimate3(entity this) { set_anim(this, anim_flame3, flameanimate4); }
void flameanimate2(entity this) { set_anim(this, anim_flame2, flameanimate3); }
void flameanimate1(entity this) { set_anim(this, anim_flame1, flameanimate2); }

void flamebanimate1(entity this);
void flamebanimate11(entity this) { set_anim(this, anim_flameb11, flamebanimate1); }
void flamebanimate10(entity this) { set_anim(this, anim_flameb10, flamebanimate11); }
void flamebanimate9(entity this) { set_anim(this, anim_flameb9, flamebanimate10); }
void flamebanimate8(entity this) { set_anim(this, anim_flameb8, flamebanimate9); }
void flamebanimate7(entity this) { set_anim(this, anim_flameb7, flamebanimate8); }
void flamebanimate6(entity this) { set_anim(this, anim_flameb6, flamebanimate7); }
void flamebanimate5(entity this) { set_anim(this, anim_flameb5, flamebanimate6); }
void flamebanimate4(entity this) { set_anim(this, anim_flameb4, flamebanimate5); }
void flamebanimate3(entity this) { set_anim(this, anim_flameb3, flamebanimate4); }
void flamebanimate2(entity this) { set_anim(this, anim_flameb2, flamebanimate3); }
void flamebanimate1(entity this) { set_anim(this, anim_flameb1, flamebanimate2); }

void NapalmFlameThink(entity this);
void MakeFlame(entity this, entity toucher)
{
	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this.owner.owner, 16, this.projectiledeathtype);
		BecomeExplosion(this);
		return;
	}
	if(toucher.classname == "door")
	{
		BecomeExplosion(this);
		return;
	}
	if(toucher.move_movetype != MOVETYPE_PUSH)
	{
		BecomeExplosion(this);
		return;
	}
	if(toucher.takedamage && toucher.health <= 0)
	{
		BecomeExplosion(this);
		return;
	}
	if(random() < 0.5)
		_setmodel(this, "progs/flameo2.mdl");
	else
		_setmodel(this, "progs/flameo.mdl");
	setsize(this, '0 0 0', '0 0 0');
	this.v_angle = '0 0 0';
	set_movetype(this, MOVETYPE_NONE);
	if(random() > 0.6 && this.cnt == 0)
		flameanimate1(this);
	else
		flamebanimate1(this);
	this.nextthink = time + 0.1;
	setthink(this, NapalmFlameThink);
	this.effects |= EF_DIMLIGHT;
	this.cnt = 0;
}

void SpawnFireSpark(entity this)
{
	entity missile = spawn();
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	missile.owner = this;
	missile.classname = "flame";
	missile.projectiledeathtype = WEP_NAPALM.m_id;
	missile.velocity = VelocityForDamage(this, 0);
	missile.velocity_z = missile.velocity_z + 100 + 50 * random();
	settouch(missile, MakeFlame);
	_setmodel(missile, "progs/firesprk.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, this.origin);
}

void NapalmCheckEnemyDead(entity this)
{
	if(!this.enemy)
	{
		BecomeExplosion(this);
		return;
	}
	if(this.enemy.velocity == '0 0 0')
	{
		this.nextthink = time + 10 + random() * 5;
		setthink(this, BecomeExplosion);
		return;
	}
	setorigin(this, this.enemy.origin);
	this.cnt = this.cnt + 0.1;
	if(this.cnt > 5)
	{
		BecomeExplosion(this);
		return;
	}
	this.nextthink = time + 0.1;
	setthink(this, NapalmCheckEnemyDead);
}

void SpawnInternalFire2(entity this)
{
	setorigin(this, this.enemy.origin);
	this.nextthink = time + 0.1;
	setthink(this, NapalmCheckEnemyDead);
}
void ThrowGib(entity this, string gibname, float dm);

void InternalFireThink(entity this)
{
	float damg = 65 + random() * 75;
	if((this.enemy.monsterdef.spawnflags & MON_FLAG_METAL) || (this.enemy.monsterdef.spawnflags & MONSTER_TYPE_BOSS) || (this.enemy.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
	{
		if(random() < 0.7)
		{
			BecomeExplosion(this);
			return;
		}
	}
	if(this.enemy.classname == "misc_explobox")
	{
		BecomeExplosion(this);
		return;
	}
	if(this.enemy.classname == "misc_explobox2")
	{
		BecomeExplosion(this);
		return;
	}
	if(this.enemy.classname == "wall_explode")
	{
		BecomeExplosion(this);
		return;
	}
	if(this.enemy.health <= 0)
	{
		BecomeExplosion(this);
		return;
	}
	if(!this.enemy)
	{
		BecomeExplosion(this);
		return;
	}
	if(!(this.flags & FL_INWATER))
	{
		if(this.watertype == CONTENT_WATER)
		{
			BecomeExplosion(this);
			return;
		}
		if(this.watertype == CONTENT_SLIME)
		{
			BecomeExplosion(this);
			return;
		}
		if(this.watertype == CONTENT_LAVA)
		{
			BecomeExplosion(this);
			return;
		}
	}
	if(!(this.enemy.flags & FL_INWATER))
	{
		if(this.enemy.watertype == CONTENT_WATER)
		{
			BecomeExplosion(this);
			return;
		}
		if(this.enemy.watertype == CONTENT_SLIME)
		{
			BecomeExplosion(this);
			return;
		}
		if(this.enemy.watertype == CONTENT_LAVA)
		{
			BecomeExplosion(this);
			return;
		}
	}
	if(this.enemy.health <= 48 && this.owner.owner.super_damage_finished > time && !(this.enemy.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
	{
		if(this.enemy.health > 0)
		{
			if(this.enemy.monsterdef == MON_OGRE) // TODO: what the hell
			{
				T_Damage(this.enemy, this, this.owner.owner, damg, this.projectiledeathtype);
				BecomeExplosion(this);
				return;
			}
			T_Damage (this.enemy, this, this.owner.owner, damg, this.projectiledeathtype);
			if(!(this.enemy.monsterdef.spawnflags & MON_FLAG_METAL) 
					&& this.enemy.classname != "misc_explobox" && this.enemy.classname != "misc_explobox2" && this.enemy.classname != "wall_explode")
			{
				_sound(this, CHAN_AUTO, "enviro/physics/bonexpl.wav", 1, ATTN_NORM);
				if(this.enemy.max_health < 80)
				{
					ThrowGib(this, "progs/grenbone.mdl", ((this.enemy.health - 40) - (random() * 60)));
					ThrowGib(this, "progs/grenbone.mdl", ((this.enemy.health - 40) - (random() * 60)));
					ThrowGib(this, "progs/grenbone.mdl", ((this.enemy.health - 40) - (random() * 60)));
					ThrowGib(this, "progs/grenbone.mdl", ((this.enemy.health - 40) - (random() * 60)));
					ThrowGib(this, "progs/grenbone.mdl", ((this.enemy.health - 40) - (random() * 60)));
					ThrowGib(this, "progs/grenbone.mdl", ((this.enemy.health - 40) - (random() * 60)));
				}
				else
				{
					ThrowGib(this, "progs/bone.mdl", ((this.enemy.health - 40) - (random() * 60)));
					ThrowGib(this, "progs/bone2.mdl", ((this.enemy.health - 40) - (random() * 60)));
					ThrowGib(this, "progs/bone.mdl", ((this.enemy.health - 40) - (random() * 60)));
				}
			}
			else
			{
				if(this.enemy.classname == "wall_explode")
					_sound(this, CHAN_AUTO, "enviro/physics/wallexpl.wav", 1, ATTN_NORM);
				else
					sound(this, CHAN_AUTO, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
			}
			this.cnt = 0;
			SpawnInternalFire2(this);
			return;
		}
	}
	else
	{
		if(this.enemy.health <= 8 && !(this.enemy.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
		{
			if(this.enemy.monsterdef == MON_OGRE && (this.enemy.health - damg) > -80) // TODO
			{
				T_Damage(this.enemy, this, this.owner.owner, damg, this.projectiledeathtype);
				BecomeExplosion(this);
				return;
			}
			if(this.enemy.health > 0)
			{
				T_Damage(this.enemy, this, this.owner.owner, damg, this.projectiledeathtype);
				if(!(this.enemy.monsterdef.spawnflags & MON_FLAG_METAL)
						|| this.enemy.classname != "misc_explobox" || this.enemy.classname != "misc_explobox2" || this.enemy.classname != "wall_explode")
				{
					_sound(this, CHAN_AUTO, "enviro/physics/bonexpl.wav", 1, ATTN_NORM);
					if(this.enemy.max_health <= 80)
					{
						ThrowGib(this, "progs/grenbone.mdl", this.enemy.health - 40 - random() * 60);
						ThrowGib(this, "progs/grenbone.mdl", this.enemy.health - 40 - random() * 60);
						ThrowGib(this, "progs/grenbone.mdl", this.enemy.health - 40 - random() * 60);
						ThrowGib(this, "progs/grenbone.mdl", this.enemy.health - 40 - random() * 60);
						ThrowGib(this, "progs/grenbone.mdl", this.enemy.health - 40 - random() * 60);
						ThrowGib(this, "progs/grenbone.mdl", this.enemy.health - 40 - random() * 60);
					}
					else
					{
						ThrowGib(this, "progs/bone.mdl", this.enemy.health - 80);
						ThrowGib(this, "progs/xtragib.mdl", this.enemy.health - 80);
						ThrowGib(this, "progs/bone2.mdl", this.enemy.health - 80);
					}
				}
				else if(this.enemy.classname == "wall_explode")
					_sound(this, CHAN_AUTO, "enviro/physics/wallexpl.wav", 1, ATTN_NORM);
				else
					sound(this, CHAN_AUTO, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
				SpawnInternalFire2(this);
				return;
			}
			else if(!(this.enemy.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
			{
				T_Damage(this.enemy, this, this.owner, damg, this.projectiledeathtype);
				BecomeExplosion(this);
				return;
			}
		}
	}
	T_Damage(this.enemy, this, this.owner.owner, 7 + random() * 4, this.projectiledeathtype);
	if(this.enemy.health <= 5 && IS_PLAYER(this.enemy))
		this.enemy.health = 6;
	this.nextthink = time + 0.25;
	if(this.cnt == 0)
		flameanimate1(this);
	this.cnt = this.cnt + 1;
	if(this.cnt >= 18)
	{
		BecomeExplosion(this);
		return;
	}
	setorigin(this, this.enemy.origin);
	setthink(this, InternalFireThink);
}

entity SpawnInternalFire(entity this, entity targ)
{
	entity missile = spawn();
	set_movetype(missile, MOVETYPE_NONE);
	missile.solid = SOLID_NOT;
	missile.owner = this;
	missile.enemy = targ;
	missile.effects = EF_DIMLIGHT;
	missile.nextthink = time + 0.3;
	setthink(missile, InternalFireThink);
	missile.classname = "flame";
	if(random() < 0.5)
		_setmodel(missile, "progs/flameo2.mdl");
	else
		_setmodel(missile, "progs/flameo.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, targ.origin);

	return missile;
}

//=============================================================================



//=============================================================================


/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
entity launch_spike(entity this, vector org, vector dir)
{
	entity newmis = spawn();
	newmis.owner = this;
	set_movetype(newmis, MOVETYPE_FLYMISSILE);
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	settouch(newmis, spike_touch);
	newmis.classname = "spike";
	setthink(newmis, SUB_Remove);
	newmis.nextthink = time + 6;
	_setmodel(newmis, "progs/spike.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		
	setorigin(newmis, org);

	newmis.velocity = dir * 1000;

	return newmis;
}

void spike_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
// hit something that bleeds
	if(toucher.takedamage) // yoder mod, jan 05 2021
	{
		spawn_touchblood(this, 9, toucher);
		T_Damage(toucher, this, this.owner, 9, this.projectiledeathtype);
	}
	else
	{
		if(this.classname == "wizard_spike")
			te_wizspike(this.origin);
		else if(this.classname == "knight_spike")
			te_knightspike(this.origin);
		else
			te_spike(this.origin);
	}

	delete(this);

}


/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void W_SetCurrentAmmo(entity this)
{
	if(this.exptime != 0)
		return;
	player_run(this);		// get out of any weapon firing states

	this.items &= ~(IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS);
	this.items &= ~(IT_LAVA_NAILS | IT_PLASMA_AMMO | IT_MULTI_ROCKETS);
	this.weaponentity.m_frame = 0;

	Weapon wep = this.weaponentity.m_weapon;
	if(wep != WEP_Null)
		this.items |= wep.ammo_type;

	if(wep != WEP_PIANO)
		this.weaponentity.piano_prevwep = this.weaponentity.m_weapon; // for piano
}

/*
============
W_Attack

An attack impulse can be triggered now
============
*/

void W_Attack(entity this, bool offhand)
{
	this.show_hostile = time + 1;	// wake monsters up
}

/*
============
CheatCommand
============
*/
void NoclipCheat(entity this)
{
	if(!autocvar_sv_cheats && !this.maycheat)
		return;

	if(this.move_movetype == MOVETYPE_WALK)
	{
		set_movetype(this, MOVETYPE_NOCLIP);
		sprint(this, "noclip ON\n");
	}
	else
	{
		set_movetype(this, MOVETYPE_WALK);
		sprint(this, "noclip OFF\n");
	}
}

void W_FireFlower_Touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;
	tracebox(this.origin + '0 0 1', this.mins + '0 0 1', this.maxs - '0 0 1', this.origin - '0 0 10', MOVE_NOMONSTERS, this);
	if(trace_startsolid || !(trace_fraction < 1) || toucher.takedamage)
	{
		T_RadiusDamage(this, this.owner, 70, this.projectiledeathtype, this.owner);
		te_explosion2(this.origin, 228, 5);
		delete(this);
	}
}

void W_FireFlower_Attack(entity this)
{
	_sound(this, CH_WEAPON_B, "items/mario_attack.wav", 1, ATTN_NORM);
	entity proj = new(fireball);
	proj.owner = this;
	set_movetype(proj, MOVETYPE_BOUNCE);
	proj.projectiledeathtype = WEP_NAPALM.m_id; // placeholder
	setorigin(proj, this.origin + '0 0 16' + v_right * 15);
	proj.velocity = v_forward * 500;
	proj.bouncefactor = 1;
	settouch(proj, W_FireFlower_Touch);
	setmodel(proj, MDL_LAVABALL);
	setsize(proj, '-4 -4 -4', '4 4 4');
	proj.solid = SOLID_CORPSE;
	proj.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	//proj.solid = SOLID_BBOX;
	proj.angles = vectoangles(proj.velocity);
	proj.enemy = this.enemy;
	//proj.effects = EF_FLAME;
	setthink(proj, SUB_Remove);
	proj.nextthink = time + 10;
}

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void W_WeaponFrame(entity this)
{
	if(this.exptime != 0)
		return;

	if(!(time < this.attack_finished))
	{
		if(this.impulse) // fix imported from rogue, lowers resource usage a tiny bit
			ImpulseCommands(this);

		Weapon wep = this.weaponentity.m_weapon;
		makevectors(this.v_angle); // calculate forward angle for velocity
		
	// check for attack
		if(wep != WEP_Null)
		{
			if(this.button0 && wep.wr_checkammo1(wep, this))
			{
				SuperDamageSound(this);
				W_Attack(this, false);
			}
			wep.wr_think(wep, this, this.button0);
		}
	}

	if(!(time < this.attack2_finished) && this.button3)
	{
		makevectors(this.v_angle); // calculate forward angle for velocity
		if((this.powerups & POWERUP_FIREFLOWER))
		{
			W_FireFlower_Attack(this);
			this.attack2_finished = time + 0.75;
		}
	}

	// TODO: split into a separate entity attached to the player?
	if(this.items & IT_PULSERIFLE)
		W_PulseRifle(this);

	// minor stub for Xonotic's weapon entity model detection
	entity wepent = this.weaponentity;
	if(!wepent) return;
	wepent.weaponname = wepent.m_weapon.mdl;
}

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void SuperDamageSound(entity this)
{
	if(this.super_damage_finished > time)
	{
		if(this.super_sound < time)
		{
			this.super_sound = time + 1;
			_sound(this, CH_PLAYER, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
}
