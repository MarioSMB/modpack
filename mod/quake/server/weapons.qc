#include "weapons.qh"

#include "combat.qh"
#include "client.qh"
#include "impel/impel.qh"
#include "rogue/lava_wpn.qh"
#include "monsters/ai.qh"

/*
*/
void player_run(entity this);
void T_RadiusDamage(entity bomb, entity attacker, float rad, entity ignore);
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
		T_Damage(toucher, this, this.lastvictim, this.dmg);
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
		if(this.flags & FL_ONGROUND)
			this.flags &= ~FL_ONGROUND;
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
	if(this.flags & FL_ONGROUND)
		this.flags &= ~FL_ONGROUND;
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

void W_SwitchWeapon(entity this, float to_wep)
{
	if(this.weapon == to_wep)
		return; // don't mess up the system by switching to it again!

	this.prevweapon = this.weapon;
	this.weapon = to_wep;

	W_SetCurrentAmmo(this);

#if 0
	if(to_wep == WEP_PULSERIFLE.m_id)
	{
		if(this.items & IT_PULSEPOWER2)
			centerprint(this, "[ LEVEL III LASER SYSTEM SELECTED ]\n");
		else if(this.items & IT_PULSEPOWER1)
			centerprint(this, "[ LEVEL II LASER SYSTEM SELECTED ]\n");
		else
			centerprint(this, "[ LEVEL I LASER SYSTEM SELECTED ]\n");
		_sound(this, CHAN_AUTO, "weapons/pulse/install.wav", 1, ATTN_NORM);
		_sound(this, CH_WEAPON_SINGLE, "enviro/pinhead/pinfire.wav", 1, ATTN_NORM);
		stuffcmd(this, "bf\n");
	}
#endif
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
	if(MP_IMPEL)
	{
		float r = random();
		if(targ.takedamage != DAMAGE_AIM || targ.classname == "misc_explobox" || targ.classname == "wall_explode" || targ.classname == "misc_explobox2")
			te_gunshot(org);
		else
		{
			if(targ.monsterdef == MON_SPIDER_DROID || targ.monsterdef == MON_JUGGERNAUT)
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
	else
		particle(org, vel * 0.1, 73, damage * 2);
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

void ClearMultiDamage()
{
	multi_ent = NULL;
	multi_damage = 0;
}

void ApplyMultiDamage(entity this)
{
	if(!multi_ent)
		return;
	T_Damage(multi_ent, this, this, multi_damage);
}

void AddMultiDamage(entity hit, float damage)
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
void TraceAttack(float damage, vector dir)
{
	vector vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	vector org = trace_endpos - dir*4;

	if(trace_ent.takedamage && trace_ent.monsterdef != MON_CHTHON) // yoder mod, Jan 05 2021)
	{
		if(trace_ent.solid != SOLID_BSP) // not on walls (TODO: iscreature field)
			SpawnBlood(org, vel*0.2, damage, trace_ent);
		else
			te_gunshot(org); // secret doors need bumps too!
		AddMultiDamage(trace_ent, damage);
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
void placebullethole(vector pos);
void FireBullets(entity this, int shotcount, vector dir, vector spread)
{
	bool bullet = false; // hipnotic bullet holes

	makevectors(this.v_angle);

	vector src = this.origin + v_forward*10;
	src.z = this.absmin_z + this.size_z * 0.7;

	ClearMultiDamage();
	while(shotcount > 0)
	{
		vector direction = dir + crandom() * spread.x * v_right + crandom() * spread.y * v_up;

		traceline(src, src + direction * 2048, MOVE_NORMAL, this);
		if(trace_fraction != 1.0 && !(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY))
		{
			TraceAttack(4, direction);

			if(MP_HIPNOTIC && !bullet && !trace_ent)
			{
				placebullethole(trace_endpos);
				bullet = true;
			}
		}

		shotcount = shotcount - 1;
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
		T_Damage(toucher, this, this.owner, damg );
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, 120, toucher);

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

void T_MediumPulseTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	float damg;
	if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
		damg = 55 + (random() * 7);
	else
		damg = 40 + (random() * 20);
	if(toucher.takedamage)
	{
		if(toucher.health <= damg && toucher.monsterdef != MON_JUGGERNAUT
			&& toucher.solid != SOLID_BSP && toucher.move_movetype != MOVETYPE_NONE && !IS_PLAYER(toucher))
		{
			T_Damage(toucher, this, this.owner, ((35 + damg) + (random() * 60)));
			toucher.origin_z = toucher.origin_z + 1;
			setorigin(toucher, toucher.origin);
			UNSET_ONGROUND(toucher);
			makevectors(this.v_angle);
			if(toucher.monsterdef == MON_HELL_KNIGHT || toucher.monsterdef == MON_OGRE || toucher.monsterdef == MON_SHAMBLER
				|| toucher.monsterdef == MON_LEGOND || toucher.monsterdef == MON_BLUD || toucher.monsterdef == MON_VORE)
			{
				toucher.velocity = qc_aim(this, 25);
				toucher.velocity = '0 0 25' + this.velocity;
			}
			else
			{
				toucher.velocity = qc_aim(this, 500);
				toucher.velocity = '0 0 150' + this.velocity;
			}
			set_movetype(toucher, MOVETYPE_TOSS);
			toucher.v_angle = this.angles;
		}
		T_Damage(toucher, this, this.owner, damg);
	}
	_sound(this, CH_WEAPON_SINGLE, "enforcer/enfstop.wav", 1, ATTN_NORM);
	BecomePurpleExplosion(this, toucher, damg);
	BecomePurpleExplosion(this, toucher, damg);
	delete(this);
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
	float damg;
	if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
		damg = 55 + random() * 7;
	else
		damg = 35 + random() * 25;
	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this.owner, damg);
		if(toucher.health <= 0 && toucher.monsterdef != MON_JUGGERNAUT && toucher.solid != SOLID_BSP && toucher.move_movetype != MOVETYPE_NONE)
		{
			if(!IS_PLAYER(toucher))
			{
				toucher.origin_z = toucher.origin_z + 1;
				setorigin(toucher, toucher.origin);
			}
			UNSET_ONGROUND(toucher);
			makevectors(this.v_angle);
			// TODO: some kind of "heavy" flag?
			if(toucher.monsterdef == MON_HELL_KNIGHT || toucher.monsterdef == MON_OGRE || toucher.monsterdef == MON_SHAMBLER
				|| toucher.monsterdef == MON_LEGOND || toucher.monsterdef == MON_BLUD || toucher.monsterdef == MON_VORE)
			{
				toucher.velocity = qc_aim(this, 25);
				toucher.velocity = '0 0 25' + this.velocity;
			}
			else
			{
				toucher.velocity = qc_aim(this, 500);
				toucher.velocity = '0 0 150' + this.velocity;
			}
			if(!IS_PLAYER(toucher))
			{
				set_movetype(toucher, MOVETYPE_TOSS);
				toucher.v_angle = this.angles;
			}
		}
	}
	_sound(this, CH_WEAPON_SINGLE, "enforcer/enfstop.wav", 1, ATTN_NORM);
	BecomePurpleExplosion(this, toucher, damg);
	BecomePurpleExplosion(this, toucher, damg);
	delete(this);
}

void T_SmallPulseTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	float damg;
	if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
		damg = 55 + random() * 7;
	else
		damg = 35 + random() * 25;
	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this.owner, damg);
		if(toucher.health <= 0 && toucher.monsterdef != MON_JUGGERNAUT 
					&& toucher.solid != SOLID_BSP && toucher.move_movetype != MOVETYPE_NONE && !IS_PLAYER(toucher))
		{
			toucher.origin_z = toucher.origin_z + 1;
			setorigin(toucher, toucher.origin);
			UNSET_ONGROUND(toucher);
			makevectors(this.v_angle);
			if(toucher.monsterdef == MON_HELL_KNIGHT || toucher.monsterdef == MON_OGRE || toucher.monsterdef == MON_SHAMBLER
				|| toucher.monsterdef == MON_LEGOND || toucher.monsterdef == MON_BLUD || toucher.monsterdef == MON_VORE)
			{
				toucher.velocity = qc_aim(this, 25);
				toucher.velocity = '0 0 25' + this.velocity;
			}
			else
			{
				toucher.velocity = qc_aim(this, 500);
				toucher.velocity = '0 0 150' + this.velocity;
			}
			set_movetype(toucher, MOVETYPE_TOSS);
			toucher.v_angle = this.angles;
			return;
		}
	}
	_sound(this, CH_WEAPON_SINGLE, "enforcer/enfstop.wav", 1, ATTN_NORM);
	BecomePurpleExplosion(this, toucher, damg);
	BecomePurpleExplosion(this, toucher, damg);
	delete(this);
}

void W_FireRifle_SetupShot(entity actor, entity proj, int shotammo, string snd1, string snd2)
{
	if(snd1)
		_sound(actor, CHAN_AUTO, snd1, 1, ATTN_NORM);
	if(snd2)
		_sound(actor, CH_WEAPON_B, snd2, 1, ATTN_NORM);

	if(shotammo)
	{
		actor.ammo_cells = actor.ammo_cells - shotammo;
		if(actor.items & IT_CELLS)
			actor.currentammo = actor.ammo_cells;
	}

	//actor.punchangle_x = -2;
	proj.owner = actor;
	set_movetype(proj, MOVETYPE_FLYMISSILE);
	proj.solid = SOLID_BBOX;
	_setmodel(proj, "progs/pulse.mdl");
	setsize(proj, '0 0 0', '0 0 0');
}

void W_FireRifleM(entity this)
{
	entity missile = new(pulse);
	W_FireRifle_SetupShot(this, missile, 0, string_null, "weapons/pulse/pulshot1.wav");

	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, T_MediumPulseTouch);
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);
	setorigin(missile, this.origin - v_right * 16 + '0 0 8');
}

void W_FireRifleL(entity this)
{
	entity missile = new(pulse);
	W_FireRifle_SetupShot(this, missile, 2, string_null, "weapons/pulse/pulshot1.wav");

	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, T_MediumPulseTouch);
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);
	setorigin(missile, this.origin + v_right * 16 + '0 0 8');
}

void W_FireRifleK(entity this)
{
	entity missile = new(pulse);
	W_FireRifle_SetupShot(this, missile, 2, string_null, "weapons/pulse/pulshot2.wav");

	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, T_MediumPulseTouch);
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);
	setorigin(missile, this.origin - v_right * 32 + '0 0 8');
}

void W_FireRifleJ(entity this)
{
	entity missile = new(pulse);
	W_FireRifle_SetupShot(this, missile, 2, string_null, "weapons/pulse/pulshot1.wav");

	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, T_MediumPulseTouch);
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);
	setorigin(missile, this.origin + v_right * 32 + '0 0 8');
}

void W_FireRifleI(entity this)
{
	entity missile = new(pulse);
	W_FireRifle_SetupShot(this, missile, 0, string_null, "weapons/pulse/pulshot2.wav");

	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, T_MediumPulseTouch);
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);
	setorigin(missile, ((this.origin - (v_right * 48)) + '0 0 8'));
}

void W_FireRifleH(entity this)
{
	entity missile = new(pulse);
	W_FireRifle_SetupShot(this, missile, 2, "weapons/pulse/pulshot1.wav", "weapons/pulse/pulshot2.wav");

	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, T_MediumPulseTouch);
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);
	setorigin(missile, ((this.origin + (v_right * 48)) + '0 0 8'));
}

void W_FireRifleD(entity this)
{
	entity missile = new(pulse);
	W_FireRifle_SetupShot(this, missile, 0, "weapons/pulse/pulshot1.wav", "weapons/pulse/pulshot2.wav");

	missile.enemy = this.enemy;
	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, T_SmallPulseTouch);
	missile.nextthink = (time + 0.3);
	setthink(missile, PulseHome);
	setorigin(missile, ((this.origin + (v_right * 48)) + '0 0 8'));
}

void W_FireRifleC(entity this)
{
	entity missile = new(pulse);
	W_FireRifle_SetupShot(this, missile, 0, "weapons/pulse/pulshot1.wav", "weapons/pulse/pulshot2.wav");

	missile.enemy = this.enemy;
	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, T_SmallPulseTouch);
	missile.nextthink = time + 0.2;
	setthink(missile, PulseHome);
	setorigin(missile, ((this.origin + (v_right * 32)) + '0 0 8'));
}

void W_FireRifleB(entity this)
{
	entity missile = new(pulse);
	W_FireRifle_SetupShot(this, missile, 0, string_null, "weapons/pulse/pulshot2.wav");

	missile.enemy = this.enemy;
	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, T_SmallPulseTouch);
	missile.nextthink = (time + 0.1);
	setthink(missile, PulseHome);
	setorigin(missile, ((this.origin + (v_right * 16)) + '0 0 8'));
}

void W_FireRifleA(entity this)
{
	entity missile = new(pulse);
	W_FireRifle_SetupShot(this, missile, 3, "weapons/pulse/pulshot1.wav", string_null);

	setorigin(missile, ((this.origin + (v_right * 16)) + '0 0 8'));
	vector vtemp = missile.origin + (v_right * 12) + (v_forward * 64);
	makevectors(this.v_angle);
	vector dir = normalize(vtemp - missile.origin);
	missile.velocity = dir * 1000;
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, T_SinglePulseTouch);
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);
}

void W_FireRifle2A(entity this)
{
	entity missile = new(pulse);
	W_FireRifle_SetupShot(this, missile, 0, string_null, string_null);

	setorigin(missile, ((this.origin + (v_right * 16)) + '0 0 8'));
	vector vtemp = missile.origin - (v_right * 12) + (v_forward * 64);
	makevectors(this.v_angle);
	vector dir = normalize((vtemp - missile.origin));
	missile.velocity = dir * 1000;
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, T_SinglePulseTouch);
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);
}

void W_FireRifle3A(entity this)
{
	entity missile = new(pulse);
	W_FireRifle_SetupShot(this, missile, 0, string_null, string_null);

	setorigin(missile, ((this.origin + (v_right * 16)) + '0 0 8'));
	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, T_SinglePulseTouch);
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);
}

void W_FireRifleTarget(entity this)
{
	//this.punchangle_x = -2;
	this.ammo_cells = this.ammo_cells - 4;
	W_SetCurrentAmmo(this);
	entity missile = spawn();
	missile.owner = this;
	this.enemy = missile;
	set_movetype(missile, MOVETYPE_NOCLIP);
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	missile.nextthink = time + 3;
	setthink(missile, SUB_Remove);
	_setmodel(missile, "progs/null.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, (this.origin + (v_forward * 8)));
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
	else if(targ.classname == "missile")
		return '0 0 0';
	else if(targ.monsterdef == MON_SHAMBLER && targ.health > 16)
		return '0 0 0';
	else if(targ.monsterdef == MON_BLUD && targ.health > 16)
		return '0 0 0';
	else if((targ.monsterdef == MON_LEGOND))
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
	else if(targ.monsterdef == MON_OGRE)
	{
		v.x = 200 * crandom();
		v.y = 200 * crandom();
		v.z = 150 + 50 * random();
	}
	else if(targ.monsterdef == MON_HELL_KNIGHT)
	{
		v.x = 200 * crandom();
		v.y = 200 * crandom();
		v.z = 150 + 50 * random();
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
			if(this.weapon == WEP_AXE.m_id)
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
			T_RadiusDamage(this, this.owner, 120, NULL);
		else
			T_RadiusDamage(this, this.enemy, 120, NULL);
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

void ThrowMe(entity this, entity targ, float dm)
{
	if(targ.move_movetype == MOVETYPE_PUSH)
		return;
	if(targ.classname == "door")
		return;
	if(targ.move_movetype == MOVETYPE_NONE)
		return;
	if(targ.monsterdef == MON_SCRAG)
		return;
	if(targ.monsterdef == MON_GRENLING)
		return;
	if(targ.monsterdef == MON_JUGGERNAUT)
		return;
	if(targ.monsterdef == MON_LEGOND)
		return;
	if(targ.health <= 5 && IS_PLAYER(targ))
		targ.health = 6;
	targ.velocity = VelocityForJump(this, targ, dm);
	UNSET_ONGROUND(targ);
	targ.avelocity = crandom() * '0 600 0';
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
void LightningDamage(vector p1, vector p2, entity from, float damage)
{
	vector f = p2 - p1;
	normalize(f);
	f = vec3(0 - f.y, f.x, 0) * 16;

	traceline(p1, p2, false, from);
	if(trace_ent.takedamage && !trace_ent.wetsuit_finished)
	{
		if(MP_IMPEL)
		{
			if(trace_ent.takedamage == DAMAGE_AIM)
			{
				if(trace_ent.monsterdef != MON_JUGGERNAUT)
					particle(trace_endpos, '0 0 100', 225, damage*4);
				else
					particle(trace_endpos, '0 0 100', 225, damage * 4);
			}
		}
		else
			particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage);
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
		if(MP_IMPEL)
		{
			if(trace_ent.takedamage == DAMAGE_AIM)
			{
				if(trace_ent.monsterdef != MON_JUGGERNAUT)
					particle(trace_endpos, '0 0 100', 225, damage*4);
				else
					particle(trace_endpos, '0 0 100', 225, damage * 4);
			}
		}
		else
			particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage);
	}
	entity e2 = trace_ent;

	traceline(p1 - f, p2 - f, false, from);
	if(trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage && !trace_ent.wetsuit_finished)
	{
		if(MP_IMPEL)
		{
			if(trace_ent.takedamage == DAMAGE_AIM)
			{
				if(trace_ent.monsterdef != MON_JUGGERNAUT)
					particle(trace_endpos, '0 0 100', 225, damage*4);
				else
					particle(trace_endpos, '0 0 100', 225, damage * 4);
			}
		}
		else
			particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage);
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

void MakeFlame(entity this, entity toucher)
{
	if(toucher.takedamage)
	{
		T_Damage (toucher, this, this.owner.owner, 16);
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
	if(toucher.monsterdef == MON_OGRE || toucher.monsterdef == MON_HELL_KNIGHT)
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
	if(this.enemy.monsterdef == MON_JUGGERNAUT)
	{
		if(random() < 0.7)
		{
			BecomeExplosion(this);
			return;
		}
	}
	if(this.enemy.monsterdef == MON_LEGOND)
	{
		BecomeExplosion(this);
		return;
	}
	if(this.enemy.monsterdef == MON_SHAMBLER)
	{
		BecomeExplosion(this);
		return;
	}
	if(this.enemy.monsterdef == MON_FIEND)
	{
		BecomeExplosion(this);
		return;
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
			if(this.enemy.monsterdef == MON_OGRE)
			{
				T_Damage(this.enemy, this, this.owner.owner, damg);
				BecomeExplosion(this);
				return;
			}
			T_Damage (this.enemy, this, this.owner.owner, damg);
			if(this.enemy.monsterdef != MON_JUGGERNAUT && this.enemy.monsterdef != MON_SPIDER_DROID 
					&& this.enemy.classname != "misc_explobox" && this.enemy.classname != "misc_explobox2" && this.enemy.classname != "wall_explode")
			{
				_sound(this, CHAN_AUTO, "enviro/physics/bonexpl.wav", 1, ATTN_NORM);
				if(this.enemy.monsterdef == MON_GRENLING || this.enemy.monsterdef == MON_SCRAG || this.enemy.monsterdef == MON_ROTTWEILER)
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
			if(this.enemy.monsterdef == MON_OGRE && (this.enemy.health - damg) > -80)
			{
				T_Damage(this.enemy, this, this.owner.owner, damg);
				BecomeExplosion(this);
				return;
			}
			if(this.enemy.health > 0)
			{
				T_Damage(this.enemy, this, this.owner.owner, damg);
				if(this.enemy.monsterdef != MON_JUGGERNAUT || this.enemy.monsterdef != MON_SPIDER_DROID
						|| this.enemy.classname != "misc_explobox" || this.enemy.classname != "misc_explobox2" || this.enemy.classname != "wall_explode")
				{
					_sound(this, CHAN_AUTO, "enviro/physics/bonexpl.wav", 1, ATTN_NORM);
					if(this.enemy.monsterdef == MON_GRENLING || this.enemy.monsterdef == MON_SCRAG || this.enemy.monsterdef == MON_ROTTWEILER)
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
				T_Damage(this.enemy, this, this.owner, damg);
				BecomeExplosion(this);
				return;
			}
		}
	}
	T_Damage(this.enemy, this, this.owner.owner, 7 + random() * 4);
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
	if(this.enemy.monsterdef != MON_ZOMBIE && this.enemy.monsterdef != MON_JUGGERNAUT)
		setorigin(this, this.enemy.origin);
	if(this.enemy.monsterdef == MON_ZOMBIE)
		setorigin(this, this.enemy.origin - v_up * 16);
	if(this.enemy.monsterdef == MON_JUGGERNAUT)
		setorigin(this, this.enemy.origin + v_up * 32);
	setthink(this, InternalFireThink);
}

void SpawnInternalFire(entity this, entity targ)
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
	if(targ.monsterdef == MON_OGRE || targ.monsterdef == MON_HELL_KNIGHT)
		_setmodel(missile, "progs/flameo2.mdl");
	else
		_setmodel(missile, "progs/flameo.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	if(targ.monsterdef != MON_ZOMBIE && targ.monsterdef != MON_JUGGERNAUT)
		setorigin(missile, targ.origin);
	if(targ.monsterdef == MON_ZOMBIE)
		setorigin(missile, targ.origin - v_up * 16);
	if(targ.monsterdef == MON_JUGGERNAUT)
		setorigin(missile, targ.origin - v_up * 32);
}

void BecomeBombExplosion(entity this)
{
	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	SpawnFireSpark(this);
	SpawnFireSpark(this);
	SpawnFireSpark(this);
	delete(this);
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
	if(toucher.takedamage && toucher.monsterdef != MON_CHTHON) // yoder mod, jan 05 2021
	{
		spawn_touchblood(this, 9, toucher);
		T_Damage(toucher, this, this.owner, 9);
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
	if(MP_IMPEL && this.exptime != 0)
		return;
	player_run(this);		// get out of any weapon firing states

	this.items &= ~(IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS);
	this.items &= ~(IT_LAVA_NAILS | IT_PLASMA_AMMO | IT_MULTI_ROCKETS);
	this.weaponframe = 0;
	
	switch(this.weapon)
	{
		case WEP_NAPALM.m_id:
		{
			this.currentammo = this.ammo_rockets;
			this.weaponmodel = "progs/v_srock.mdl";
			this.items |= IT_ROCKETS;
			break;
		}
		case WEP_LIGHTME.m_id:
		{
			this.currentammo = this.ammo_cells;
			this.weaponmodel = "progs/v_light2.mdl";
			this.items |= IT_CELLS;
			break;
		}
		case WEP_SPEAR.m_id:
		{
			this.currentammo = this.ammo_rockets;
			this.weaponmodel = "progs/v_implr.mdl";
			this.items |= IT_ROCKETS;
			break;
		}
		case WEP_AXE.m_id:
		{
			this.currentammo = 0;
			this.weaponmodel = "progs/v_axe.mdl";
			break;
		}
		case WEP_GRAPPLE.m_id:
		{
			this.currentammo = 0;
			this.weaponmodel = "progs/v_grpple.mdl";
			break;
		}
		case WEP_SHOTGUN.m_id:
		{
			this.currentammo = this.ammo_shells;
			this.weaponmodel = "progs/v_shot.mdl";
			this.items |= IT_SHELLS;
			break;
		}
		case WEP_SUPER_SHOTGUN.m_id:
		{
			this.currentammo = this.ammo_shells;
			this.weaponmodel = "progs/v_shot2.mdl";
			this.items |= IT_SHELLS;
			break;
		}
		case WEP_LAVA_NAILGUN.m_id:
		{
			this.currentammo = this.ammo_lava_nails;
			this.weaponmodel = "progs/v_lava.mdl";
			this.items |= IT_LAVA_NAILS;
			break;
		}
		case WEP_LAVA_SUPER_NAILGUN.m_id:
		{
			this.currentammo = this.ammo_lava_nails;
			this.weaponmodel = "progs/v_lava2.mdl";
			this.items |= IT_LAVA_NAILS;
			break;
		}
		case WEP_MULTI_GRENADE.m_id:
		{
			this.currentammo = this.ammo_multi_rockets;
			this.weaponmodel = "progs/v_multi.mdl";
			this.items |= IT_MULTI_ROCKETS;
			break;
		}
		case WEP_MULTI_ROCKET.m_id:
		{
			this.currentammo = this.ammo_multi_rockets;
			this.weaponmodel = "progs/v_multi2.mdl";
			this.items |= IT_MULTI_ROCKETS;
			break;
		}
		case WEP_PLASMA_GUN.m_id:
		{
			this.currentammo = this.ammo_plasma;
			this.weaponmodel = "progs/v_plasma.mdl";
			this.items |= IT_PLASMA_AMMO;
			break;
		}
		case WEP_NAILGUN.m_id:
		{
			this.currentammo = this.ammo_nails;
			this.weaponmodel = "progs/v_nail.mdl";
			this.items |= IT_NAILS;
			break;
		}
		case WEP_SUPER_NAILGUN.m_id:
		{
			this.currentammo = this.ammo_nails;
			this.weaponmodel = "progs/v_nail2.mdl";
			this.items |= IT_NAILS;
			break;
		}
		case WEP_GRENADE_LAUNCHER.m_id:
		{
			this.currentammo = this.ammo_rockets;
			this.weaponmodel = "progs/v_rock.mdl";
			this.items |= IT_ROCKETS;
			break;
		}
		case WEP_ROCKET_LAUNCHER.m_id:
		{
			this.currentammo = this.ammo_rockets;
			this.weaponmodel = "progs/v_rock2.mdl";
			this.items |= IT_ROCKETS;
			break;
		}
		case WEP_LIGHTNING.m_id:
		{
			this.currentammo = this.ammo_cells;
			this.weaponmodel = "progs/v_light.mdl";
			this.items |= IT_CELLS;
			break;
		}
		case WEP_LASER_CANNON.m_id:
		{
			this.currentammo = this.ammo_cells;
			this.weaponmodel = "progs/v_laserg.mdl";
			this.items |= IT_CELLS;
			break;
		}
		case WEP_MJOLNIR.m_id:
		{
			this.currentammo = this.ammo_cells;
			this.weaponmodel = "progs/v_hammer.mdl";
			this.items |= IT_CELLS;
			break;
		}
		case WEP_PROXIMITY_GUN.m_id:
		{
			this.currentammo = this.ammo_rockets;
			this.weaponmodel = "progs/v_prox.mdl";
			this.items |= IT_ROCKETS;
			break;
		}
		default:
		{
			this.currentammo = 0;
			this.weaponmodel = "";
			break;
		}
	}
}

int W_BestWeapon(entity this, int except)
{
	WepSet itm = STAT(WEAPONS, this);

	// TODO: missing impel weapons!

	// pgm - fix for sandy. will not change to plasma gun
	
//	if(this.waterlevel <= 1 && this.ammo_plasma >= 1 && (it & WEP_PLASMA_GUN))
//		return WEP_PLASMA_GUN.m_id;
//	else 
	if(this.waterlevel <= 1 && this.ammo_cells >= 1 && (itm & WEPSET(LIGHTNING)) && except != WEP_LIGHTNING.m_id)
		return WEP_LIGHTNING.m_id;
	else if(this.ammo_lava_nails >= 2 && (itm & WEPSET(LAVA_SUPER_NAILGUN)) && except != WEP_LAVA_SUPER_NAILGUN.m_id)
		return WEP_LAVA_SUPER_NAILGUN.m_id;
	else if(this.ammo_cells >= 1 && (itm & WEPSET(LASER_CANNON)) && except != WEP_LASER_CANNON.m_id)
		return WEP_LASER_CANNON.m_id;
	else if(this.ammo_nails >= 2 && (itm & WEPSET(SUPER_NAILGUN)) && except != WEP_SUPER_NAILGUN.m_id)
		return WEP_SUPER_NAILGUN.m_id;
	else if(this.ammo_lava_nails >= 1 && (itm & WEPSET(LAVA_NAILGUN)) && except != WEP_LAVA_NAILGUN.m_id)
		return WEP_LAVA_NAILGUN.m_id;
	else if(this.ammo_shells >= 2 && (itm & WEPSET(SUPER_SHOTGUN)) && except != WEP_SUPER_SHOTGUN.m_id)
		return WEP_SUPER_SHOTGUN.m_id;
	else if(this.ammo_nails >= 1 && (itm & WEPSET(NAILGUN)) && except != WEP_NAILGUN.m_id)
		return WEP_NAILGUN.m_id;
	else if(this.ammo_shells >= 1 && (itm & WEPSET(SHOTGUN)) && except != WEP_SHOTGUN.m_id)
		return WEP_SHOTGUN.m_id;
	else if(itm & WEPSET(MJOLNIR))
		return WEP_MJOLNIR.m_id;
	return WEP_AXE.m_id; // just fall back if all else fails
}

bool W_WantsToChangeWeapon(entity this, int old, int new)
{
	return !(old == new);
}

bool NoAmmo(entity this, bool doswitch)
{
	if(!MP_IMPEL || !doswitch)
		return false;
	W_SwitchWeapon(this, W_BestWeapon(this, 0));
	return false;
}

bool W_CheckNoAmmo(entity this, int forwep, bool doswitch)
{
	if(forwep)
	{
		switch(forwep)
		{
			case WEP_LIGHTNING.m_id: return (this.ammo_cells >= 1);
			case WEP_SUPER_NAILGUN.m_id: return (this.ammo_nails >= 2);
			case WEP_SUPER_SHOTGUN.m_id: return (this.ammo_shells >= 2);
			case WEP_NAILGUN.m_id: return (this.ammo_nails >= 1);
			case WEP_SHOTGUN.m_id: return (this.ammo_shells >= 1);
			case WEP_LAVA_SUPER_NAILGUN.m_id: return (this.ammo_lava_nails >= 2);
			case WEP_LAVA_NAILGUN.m_id: return (this.ammo_lava_nails >= 1);
			case WEP_PLASMA_GUN.m_id: return (this.ammo_plasma >= 1);
			case WEP_MULTI_GRENADE.m_id: return (this.ammo_multi_rockets >= 1);
			case WEP_MULTI_ROCKET.m_id: return (this.ammo_multi_rockets >= 1);
			case WEP_ROCKET_LAUNCHER.m_id: return (this.ammo_rockets >= 1);
			case WEP_GRENADE_LAUNCHER.m_id: return (this.ammo_rockets >= 1);
			case WEP_PROXIMITY_GUN.m_id: return (this.ammo_rockets >= 1);
			case WEP_LIGHTME.m_id: return (this.ammo_cells >= 1);
			case WEP_SPEAR.m_id: return (this.ammo_rockets >= 1);
			case WEP_NAPALM.m_id: return (this.ammo_rockets >= 1);
			case WEP_AXE.m_id: case WEP_MJOLNIR.m_id: case WEP_GRAPPLE.m_id:
			default: return true; // axe and hammer don't use ammo, fallback
		}
	}

	if(MP_IMPEL && this.currentammo < 1 && this.weapon == WEP_SPEAR.m_id)
		return NoAmmo(this, doswitch);

	if(this.currentammo > 0)
		return true;

	if(this.weapon == WEP_AXE.m_id || this.weapon == WEP_GRAPPLE.m_id || this.weapon == WEP_MJOLNIR.m_id)
		return true;

	if(!MP_IMPEL && doswitch)
		W_SwitchWeapon(this, W_BestWeapon(this, 0));
	
// drop the weapon down
	return NoAmmo(this, doswitch);
}

/*
============
W_Attack

An attack impulse can be triggered now
============
*/


void RuneApplyBlackNoise(entity who);
float RuneApplyHell(float tvalue, entity who);

void W_Attack(entity this, bool offhand)
{
	if(MP_IMPEL && this.exptime != 0)
		return;
	if(offhand)
	{
		if((this.items & IT_PULSEPOWER2) && this.ammo_cells < 4)
			return;
		else if((this.items & IT_PULSEPOWER1) && this.ammo_cells < 3)
			return;
		else if(this.ammo_cells < 2)
			return;
	}
	else if(!W_CheckNoAmmo(this, 0, true))
		return;

	makevectors(this.v_angle);			// calculate forward angle for velocity
	this.show_hostile = time + 1;	// wake monsters up

	if(offhand)
	{
		if(this.items & IT_PULSERIFLE)
		{
			if(this.items & IT_PULSEPOWER2)
			{
				if(this.ammo_cells < 4)
				{
					//W_SwitchWeapon(this, W_BestWeapon(this, 0));
					return;
				}
				//player_rifle1(this);
				if(this.rifle_cnt == 2)
				{
					W_FireRifleL(this);
					W_FireRifleM(this);
					this.attack2_finished = time + 0.4;
					this.rifle_cnt = 0;
				}
				else if(this.rifle_cnt == 1)
				{
					W_FireRifleJ(this);
					W_FireRifleK(this);
					this.attack2_finished = time + 0.1;
					this.rifle_cnt = 2;
				}
				else if(this.rifle_cnt == 0)
				{
					W_FireRifleH(this);
					W_FireRifleI(this);
					this.attack2_finished = time + 0.1;
					this.rifle_cnt = 1;
				}
			}
			else if(this.items & IT_PULSEPOWER1)
			{
				if(this.ammo_cells < 3)
				{
					//W_SwitchWeapon(this, W_BestWeapon(this, 0));
					return;
				}
				//player_rifle1(this);
				W_FireRifleTarget(this);
				W_FireRifleD(this);
				W_FireRifleC(this);
				W_FireRifleB(this);
				this.attack2_finished = time + 0.6;
			}
			else if(this.ammo_cells < 2)
			{
				//W_SwitchWeapon(this, W_BestWeapon(this, 0));
				return;
			}
			//player_rifle1(this);
			W_FireRifleA(this);
			W_FireRifle2A(this);
			W_FireRifle3A(this);
			this.attack2_finished = time + 0.7;
			return;
		}

		return;
	}

	RuneApplyBlackNoise(this); // make rune noise

	Weapon wep = REGISTRY_GET(Weapons, this.weapon);
	if(wep != WEP_Null)
		wep.wr_think(wep, this);
}

/*
============
W_ChangeWeapon

============
*/
void W_ChangeWeapon(entity this, int imp)
{
	bool am = false;
	Weapon fl = REGISTRY_GET(Weapons, this.weapon);

	switch(imp)
	{
		case 1:
		{
			if(this.weapon == WEP_AXE.m_id && teamplay >= TEAM_CTF)
				fl = WEP_GRAPPLE;
			else
				fl = WEP_AXE;
			break;
		}
		case 22:
		{
			if(deathmatch && teamplay >= TEAM_CTF)
				fl = WEP_GRAPPLE;
			break;
		}
		case 2:
		{
			fl = WEP_SHOTGUN;
			if(this.ammo_shells < 1)
				am = true;
			break;
		}
		case 3:
		{
			fl = WEP_SUPER_SHOTGUN;
			if(this.ammo_shells < 2)
				am = true;
			break;
		}		
		case 4:
		{
			if((STAT(WEAPONS, this) & WEPSET(LAVA_NAILGUN)) && (this.weapon == WEP_NAILGUN.m_id || this.ammo_nails < 1))
			{
				fl = WEP_LAVA_NAILGUN;
				if(this.ammo_lava_nails < 1)
					am = true;
			}
			else
			{
				fl = WEP_NAILGUN;
				if(this.ammo_nails < 1)
					am = true;
			}
			break;
		}
		case 5:
		{
			if((STAT(WEAPONS, this) & WEPSET(LAVA_SUPER_NAILGUN)) && (this.weapon == WEP_SUPER_NAILGUN.m_id || this.ammo_nails < 2))
			{
				fl = WEP_LAVA_SUPER_NAILGUN;
				if(this.ammo_lava_nails < 2)
					am = true;
			}
			else
			{
				fl = WEP_SUPER_NAILGUN;
				if(this.ammo_nails < 2)
					am = true;
			}
			break;
		}
		case 6:
		{
			if((STAT(WEAPONS, this) & WEPSET(MULTI_GRENADE)) && (this.weapon == WEP_GRENADE_LAUNCHER.m_id || this.ammo_rockets < 1))
			{
				fl = WEP_MULTI_GRENADE;
				if(this.ammo_multi_rockets < 1)
					am = true;
				break; // prefer multi grenade
			}
			if((STAT(WEAPONS, this) & WEPSET(PROXIMITY_GUN)) && ((this.weapon == WEP_GRENADE_LAUNCHER.m_id && !(STAT(WEAPONS, this) & WEPSET(MULTI_GRENADE))) || this.weapon == WEP_MULTI_GRENADE.m_id || !(STAT(WEAPONS, this) & WEPSET(GRENADE_LAUNCHER))))
				fl = WEP_PROXIMITY_GUN;
			else if((STAT(WEAPONS, this) & WEPSET(NAPALM)) && 
					((this.weapon == WEP_GRENADE_LAUNCHER.m_id && !(STAT(WEAPONS, this) & WEPSET(PROXIMITY_GUN)) && !(STAT(WEAPONS, this) & WEPSET(MULTI_GRENADE))) || this.weapon == WEP_PROXIMITY_GUN.m_id || !(STAT(WEAPONS, this) & WEPSET(GRENADE_LAUNCHER))))
				fl = WEP_NAPALM;
			else
				fl = WEP_GRENADE_LAUNCHER;
			if(this.ammo_rockets < 1)
				am = true;
			break;
		}
		case 7:
		{
			if((STAT(WEAPONS, this) & WEPSET(MULTI_ROCKET)) && (this.weapon == WEP_ROCKET_LAUNCHER.m_id || this.ammo_rockets < 1 || !(STAT(WEAPONS, this) & WEPSET(ROCKET_LAUNCHER))))
			{
				fl = WEP_MULTI_ROCKET;
				if(this.ammo_multi_rockets < 1)
					am = true;
			}
			else
			{
				if((STAT(WEAPONS, this) & WEPSET(SPEAR)) && ((this.weapon == WEP_ROCKET_LAUNCHER.m_id && !(STAT(WEAPONS, this) & WEPSET(MULTI_ROCKET))) || this.weapon == WEP_MULTI_ROCKET.m_id || !(STAT(WEAPONS, this) & WEPSET(ROCKET_LAUNCHER))))
					fl = WEP_SPEAR;
				else
					fl = WEP_ROCKET_LAUNCHER;
				if(this.ammo_rockets < 1)
					am = true;
			}
			break;
		}
		case 8:
		{
			if((STAT(WEAPONS, this) & WEPSET(PLASMA_GUN)) && (this.weapon == WEP_LIGHTNING.m_id || this.ammo_cells < 1))
			{
				fl = WEP_PLASMA_GUN;
				if(this.ammo_plasma < 1)
					am = true;
			}
			else
			{
				float needed_cells = 1;
				if((STAT(WEAPONS, this) & WEPSET(LIGHTME)) && ((this.weapon == WEP_LIGHTNING.m_id && !(STAT(WEAPONS, this) & WEPSET(PLASMA_GUN))) || this.weapon == WEP_PLASMA_GUN.m_id || !(STAT(WEAPONS, this) & WEPSET(LIGHTNING))))
				{
					fl = WEP_LIGHTME;
					needed_cells = 2;
				}
				else
					fl = WEP_LIGHTNING;
				if(this.ammo_cells < needed_cells)
					am = true;
			}
			break;
		}
		case 9:
		{
			fl = WEP_LASER_CANNON;
			if(this.ammo_cells < 1)
				am = true;
			break;
		}
		case 14:
		{
		#if 0
			if((STAT(WEAPONS, this) & WEPSET(PULSERIFLE)) && this.weapon != WEP_PULSERIFLE.m_id)
			{
				fl = WEP_PULSERIFLE;
				float needed_cells = 2;
				if(this.items & IT_PULSEPOWER2)
					needed_cells = 4;
				else if(this.items & IT_PULSEPOWER1)
					needed_cells = 3;
				if(this.ammo_cells < needed_cells)
					am = true;
			}
			else
		#endif
			if((STAT(WEAPONS, this) & WEPSET(MJOLNIR)) || !(deathmatch && teamplay >= TEAM_CTF))
				fl = WEP_MJOLNIR;
			else
				fl = WEP_GRAPPLE;
			break;
		}
		case 50:
		{
			fl = WEP_PROXIMITY_GUN;
			if(this.ammo_rockets < 1)
				am = true;
			break;
		}
		case 60:
		{
			fl = WEP_LAVA_NAILGUN;
			if(this.ammo_lava_nails < 1)
				am = true;
			break;
		}
		case 61:
		{
			fl = WEP_LAVA_SUPER_NAILGUN;
			if(this.ammo_lava_nails < 1)
				am = true;
			break;
		}
		case 62:
		{
			fl = WEP_MULTI_GRENADE;
			if(this.ammo_multi_rockets < 1)
				am = true;
			break;
		}
		case 63:
		{
			fl = WEP_MULTI_ROCKET;
			if(this.ammo_multi_rockets < 1)
				am = true;
			break;
		}
		case 64:
		{
			fl = WEP_PLASMA_GUN;
			if(this.ammo_plasma < 1)
				am = true;
			break;
		}
		case 65:
		{
			fl = WEP_LIGHTME;
			if(this.ammo_cells < 1)
				am = true;
			break;
		}
	#if 0
		case 66:
		{
			fl = WEP_PULSERIFLE;
			if(this.items & IT_PULSEPOWER2)
			{
				if(this.ammo_cells < 4)
					am = true;
			}
			else if(this.items & IT_PULSEPOWER1)
			{
				if(this.ammo_cells < 3)
					am = true;
			}
			else if(this.ammo_cells < 2)
				am = true;
			break;
		}
	#endif
		case 67:
		{
			fl = WEP_SPEAR;
			if(this.ammo_rockets < 1)
				am = true;
			break;
		}
		case 68:
		{
			fl = WEP_NAPALM;
			if(this.ammo_rockets < 1)
				am = true;
			break;
		}
	}
	
	if(!(STAT(WEAPONS, this) & fl.m_wepset))
	{	// don't have the weapon
		Send_Notification(NOTIF_ONE, this, MSG_CENTER, CENTER_NO_WEAPON);
		return;
	}
	
	if(am)
	{	// don't have the ammo
		Send_Notification(NOTIF_ONE, this, MSG_CENTER, CENTER_NO_AMMO);
		return;
	}

//
// set weapon, set ammo
//
	W_SwitchWeapon(this, fl.m_id);
}

/*
============
CheatCommand
============
*/
.bool maycheat;
void CheatCommand(entity this)
{
	if(!this.maycheat)
		return; // no more singleplayer functionality, unless they're smart enough to enable this!

	this.ammo_rockets = 100;
	this.ammo_nails = 200;
	this.ammo_shells = 100;
	this.ammo_cells = 200;
	// TODO: use WEP_FLAG_MUTATORBLOCKED to tell if a weapon isn't available from a mission pack?
	// may not be needed if weapons become available in all packs anyway!
	FOREACH(Weapons, it != WEP_Null,
	{
		if(!MP_HIPNOTIC && (it.spawnflags & WEP_FLAG_HIPNOTIC))
			continue;
		if(!MP_ROGUE && (it.spawnflags & WEP_FLAG_ROGUE))
			continue;
		if(!MP_IMPEL && (it.spawnflags & WEP_FLAG_IMPEL))
			continue;
		STAT(WEAPONS, this) |= it.m_wepset;
	});
	//this.items |= (IT_KEY1 | IT_KEY2); // breaks levels

	// mal: also give full armor...
	this.armortype = 0.8;
	this.armorvalue = 200;
	this.items &= ~(IT_ARMOR1 | IT_ARMOR2);
	this.items |= IT_ARMOR3;

	if(MP_ROGUE)
	{
		this.ammo_lava_nails = 200;
		this.ammo_multi_rockets = 100;
		this.ammo_plasma = 100;
	}
	if(MP_IMPEL)
		this.items |= (IT_PULSERIFLE | IT_PULSEPOWER1 | IT_PULSEPOWER2);

	W_SwitchWeapon(this, WEP_ROCKET_LAUNCHER.m_id);
	this.impulse = 0;
	if(MP_IMPEL)
		_sound(this, CH_WEAPON_SINGLE, "weapons/pkup.wav", 1, ATTN_NORM);
}

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void CycleWeaponCommand(entity this)
{
	this.impulse = 0;
	float oldwep = this.weapon;
	
	while(1)
	{
		bool am = false;

		switch(this.weapon)
		{
			case WEP_MJOLNIR.m_id:
			{
				this.weapon = WEP_AXE.m_id;
				break;
			}
			case WEP_PLASMA_GUN.m_id:
			{
				this.weapon = WEP_LIGHTME.m_id;
				if(this.ammo_cells < 1)
					am = true;
				break;
			}
			case WEP_AXE.m_id:
			{
				if(deathmatch && teamplay >= TEAM_CTF)
					this.weapon = WEP_GRAPPLE.m_id;
				else
				{
					this.weapon = WEP_SHOTGUN.m_id;
					if(this.ammo_shells < 1)
						am = true;
				}
				break;
			}
			case WEP_GRAPPLE.m_id:
			{
				this.weapon = WEP_SHOTGUN.m_id;
				if(this.ammo_shells < 1)
					am = true;
				break;
			}
			case WEP_SHOTGUN.m_id:
			{
				this.weapon = WEP_SUPER_SHOTGUN.m_id;
				if(this.ammo_shells < 2)
					am = true;
				break;
			}		
			case WEP_SUPER_SHOTGUN.m_id:
			{
				this.weapon = WEP_NAILGUN.m_id;
				if(this.ammo_nails < 1)
					am = true;
				break;
			}
			case WEP_NAILGUN.m_id:
			{
				this.weapon = WEP_LAVA_NAILGUN.m_id;
				if(this.ammo_lava_nails < 1)
					am = true;
				break;
			}
			case WEP_LAVA_NAILGUN.m_id:
			{
				this.weapon = WEP_SUPER_NAILGUN.m_id;
				if(this.ammo_nails < 2)
					am = true;
				break;
			}
			case WEP_SUPER_NAILGUN.m_id:
			{
				this.weapon = WEP_LAVA_SUPER_NAILGUN.m_id;
				if(this.ammo_lava_nails < 2)
					am = true;
				break;
			}
			case WEP_LAVA_SUPER_NAILGUN.m_id:
			{
				this.weapon = WEP_GRENADE_LAUNCHER.m_id;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_GRENADE_LAUNCHER.m_id:
			{
				this.weapon = WEP_NAPALM.m_id;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_MULTI_GRENADE.m_id:
			{
				this.weapon = WEP_ROCKET_LAUNCHER.m_id;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_NAPALM.m_id:
			{
				this.weapon = WEP_PROXIMITY_GUN.m_id;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_PROXIMITY_GUN.m_id:
			{
				this.weapon = WEP_MULTI_GRENADE.m_id;
				if(this.ammo_multi_rockets < 1)
					am = true;
				break;
			}
			case WEP_ROCKET_LAUNCHER.m_id:
			{
				this.weapon = WEP_MULTI_ROCKET.m_id;
				if(this.ammo_multi_rockets < 1)
					am = true;
				break;
			}
			case WEP_MULTI_ROCKET.m_id:
			{
				this.weapon = WEP_SPEAR.m_id;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_SPEAR.m_id:
			{
				this.weapon = WEP_LIGHTNING.m_id;
				if(this.ammo_cells < 1)
					am = true;
				break;
			}
			case WEP_LIGHTNING.m_id:
			{
				this.weapon = WEP_LASER_CANNON.m_id;
				if(this.ammo_cells < 1)
					am = true;
				break;
			}
			case WEP_LASER_CANNON.m_id:
			{
				this.weapon = WEP_PLASMA_GUN.m_id;
				if(this.ammo_plasma < 1)
					am = true;
				break;
			}
			case WEP_LIGHTME.m_id:
			{
				this.weapon = WEP_MJOLNIR.m_id;
				break;
			}
		}

		Weapon newwep = REGISTRY_GET(Weapons, this.weapon);
		if(((STAT(WEAPONS, this) & newwep.m_wepset) || newwep == WEP_AXE) && !am)
		{
			this.prevweapon = oldwep;
			W_SetCurrentAmmo(this);
		#if 0
			if(this.weapon == WEP_PULSERIFLE.m_id)
			{
				if(this.items & IT_PULSEPOWER2)
					centerprint(this, "[ LEVEL III LASER SYSTEM SELECTED ]\n");
				else if(this.items & IT_PULSEPOWER1)
					centerprint(this, "[ LEVEL II LASER SYSTEM SELECTED ]\n");
				else
					centerprint(this, "[ LEVEL I LASER SYSTEM SELECTED ]\n");
				_sound(this, CHAN_AUTO, "weapons/pulse/install.wav", 1, ATTN_NORM);
				_sound(this, CH_WEAPON_SINGLE, "enviro/pinhead/pinfire.wav", 1, ATTN_NORM);
				stuffcmd(this, "bf\n");
			}
		#endif
			return;
		}
	}

	// TODO: can't get here!
	this.weapon = oldwep; // didn't save the switch
}

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void CycleWeaponReverseCommand(entity this)
{
	this.impulse = 0;
	int oldwep = this.weapon;
	bool am = false;

	while(1)
	{
		am = false;

		switch(this.weapon)
		{
			case WEP_LIGHTME.m_id:
			{
				this.weapon = WEP_PLASMA_GUN.m_id;
				if(this.ammo_plasma < 1)
					am = true;
				break;
			}
			case WEP_MJOLNIR.m_id:
			{
				this.weapon = WEP_LIGHTME.m_id;
				if(this.ammo_cells < 1)
					am = true;
				break;
			}
			case WEP_LASER_CANNON.m_id:
			{
				this.weapon = WEP_LIGHTNING.m_id;
				if(this.ammo_cells < 1)
					am = true;
				break;
			}
			case WEP_PLASMA_GUN.m_id:
			{
				this.weapon = WEP_LASER_CANNON.m_id;
				if(this.ammo_cells < 1)
					am = true;
				break;
			}
			case WEP_SPEAR.m_id:
			{
				this.weapon = WEP_MULTI_ROCKET.m_id;
				if(this.ammo_multi_rockets < 1)
					am = true;
				break;
			}
			case WEP_LIGHTNING.m_id:
			{
				this.weapon = WEP_SPEAR.m_id;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_MULTI_ROCKET.m_id:
			{
				this.weapon = WEP_ROCKET_LAUNCHER.m_id;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_ROCKET_LAUNCHER.m_id:
			{
				this.weapon = WEP_MULTI_GRENADE.m_id;
				if(this.ammo_multi_rockets < 1)
					am = true;
				break;
			}
			case WEP_MULTI_GRENADE.m_id:
			{
				this.weapon = WEP_PROXIMITY_GUN.m_id;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_NAPALM.m_id:
			{
				this.weapon = WEP_GRENADE_LAUNCHER.m_id;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_PROXIMITY_GUN.m_id:
			{
				this.weapon = WEP_NAPALM.m_id;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_GRENADE_LAUNCHER.m_id:
			{
				this.weapon = WEP_LAVA_SUPER_NAILGUN.m_id;
				if(this.ammo_lava_nails < 2)
					am = true;
				break;
			}
			case WEP_LAVA_SUPER_NAILGUN.m_id:
			{
				this.weapon = WEP_SUPER_NAILGUN.m_id;
				if(this.ammo_nails < 2)
					am = true;
				break;
			}
			case WEP_SUPER_NAILGUN.m_id:
			{
				this.weapon = WEP_LAVA_NAILGUN.m_id;
				if(this.ammo_lava_nails < 2)
					am = true;
				break;
			}
			case WEP_LAVA_NAILGUN.m_id:
			{
				this.weapon = WEP_NAILGUN.m_id;
				if(this.ammo_nails < 1)
					am = true;
				break;
			}
			case WEP_NAILGUN.m_id:
			{
				this.weapon = WEP_SUPER_SHOTGUN.m_id;
				if(this.ammo_shells < 2)
					am = true;
				break;
			}		
			case WEP_SUPER_SHOTGUN.m_id:
			{
				this.weapon = WEP_SHOTGUN.m_id;
				if(this.ammo_shells < 1)
					am = true;
				break;
			}
			case WEP_SHOTGUN.m_id:
			{
				if(deathmatch && teamplay >= TEAM_CTF)
					this.weapon = WEP_GRAPPLE.m_id;
				else
					this.weapon = WEP_AXE.m_id;
				break;
			}
			case WEP_GRAPPLE.m_id:
			{
				this.weapon = WEP_AXE.m_id;
				break;
			}
			case WEP_AXE.m_id:
			{
				this.weapon = WEP_MJOLNIR.m_id;
				break;
			}
		}

		Weapon newwep = REGISTRY_GET(Weapons, this.weapon);
		if(((STAT(WEAPONS, this) & newwep.m_wepset) || newwep == WEP_AXE) && !am)
		{
			this.prevweapon = oldwep;
			W_SetCurrentAmmo(this);
		#if 0
			if(this.weapon == WEP_PULSERIFLE.m_id)
			{
				if(this.items & IT_PULSEPOWER2)
					centerprint(this, "[ LEVEL III LASER SYSTEM SELECTED ]\n");
				else if(this.items & IT_PULSEPOWER1)
					centerprint(this, "[ LEVEL II LASER SYSTEM SELECTED ]\n");
				else
					centerprint(this, "[ LEVEL I LASER SYSTEM SELECTED ]\n");
				_sound(this, CHAN_AUTO, "weapons/pulse/install.wav", 1, ATTN_NORM);
				_sound(this, CH_WEAPON_SINGLE, "enviro/pinhead/pinfire.wav", 1, ATTN_NORM);
				stuffcmd(this, "bf\n");
			}
		#endif
			return;
		}
	}

	this.weapon = oldwep; // we didn't save the switch
}

void QuadCheat(entity this)
{
	if(!this.maycheat)
		return;

	this.super_time = 1;
	this.super_damage_finished = time + 30;
	this.powerups |= POWERUP_QUAD;
	bprint("quad cheat\n");
}

void W_LastWeapon(entity this)
{
	Weapon oldwep = REGISTRY_GET(Weapons, this.prevweapon);
	if((STAT(WEAPONS, this) & oldwep.m_wepset) && this.prevweapon != this.weapon && W_CheckNoAmmo(this, this.prevweapon, false))
		W_SwitchWeapon(this, this.prevweapon);
	else
		W_SwitchWeapon(this, W_BestWeapon(this, this.weapon));
}

int W_GetWeaponImpulse(int imp)
{
	FOREACH(Weapons, it != WEP_Null && it.cnt == imp,
	{
		return it.impulse;
	});

	return imp;
}

/*
============
ImpulseCommands

============
*/
void TossBackpack(entity this);
void TossWeapon(entity this);
void TeamFlagStatusReport(entity this);
void ImpulseCommands(entity this)
{
	bool valid_wep_impulse = (this.impulse >= 1 && (this.impulse <= 9 || (this.impulse >= 230 && this.impulse <= 253) || this.impulse == 50 || this.impulse == 14) || (this.impulse >= 60 && this.impulse <= 68));

	if(valid_wep_impulse)
	{
		int imp = this.impulse;
		if(imp >= 230 && imp <= 253)
			imp = W_GetWeaponImpulse(imp);
		W_ChangeWeapon(this, imp);
	}

	switch(this.impulse)
	{
		case 10:
		case 15: // TODO
		case 18: // TODO
			CycleWeaponCommand(this);
			break;
		case 11:
			W_LastWeapon(this);
			break;
		case 12:
		case 16: // TODO
		case 19: // TODO
			CycleWeaponReverseCommand(this);
			break;
		case 13:
			W_SwitchWeapon(this, W_BestWeapon(this, 0));
			break;
		case 99: // hehe
			CheatCommand(this);
			break;
		case 255:
			QuadCheat(this);
			break;
	}

	switch(this.impulse)
	{
		case 20:
			TossBackpack(this);
			break;
		case 17:
		case 21:
			TossWeapon(this);
			break;
		case 22:
			if(deathmatch && teamplay >= TEAM_CTF)
				W_ChangeWeapon(this, this.impulse);
			break;
		case 23:
			TeamFlagStatusReport(this);
			break;
	}

	this.impulse = 0;
}

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void W_WeaponFrame(entity this)
{
	if(!(time < this.attack_finished))
	{
		if(this.lavaGunFired)
		{
			if(this.weapon == WEP_LAVA_NAILGUN.m_id || this.weapon == WEP_LAVA_SUPER_NAILGUN.m_id)
				_sound(this, CH_WEAPON_SINGLE, "lavagun/snail.wav", 1, ATTN_NORM);
			this.lavaGunFired = false;
		}

		if(this.impulse) // fix imported from rogue, lowers resource usage a tiny bit
			ImpulseCommands(this);
		
	// check for attack
		if(this.button0)
		{
			SuperDamageSound(this);
			W_Attack(this, false);
		}
	}

	if(!(time < this.attack2_finished) && (this.items & IT_PULSERIFLE))
	{
		// offhand attack (pulse rifle)
		if(this.button3)
		{
			SuperDamageSound(this);
			W_Attack(this, true);
		}
	}
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
