#include "weapons.qh"

#include "combat.qh"
#include "client.qh"
#include "impulse.qh"
#include "rogue/lava_wpn.qh"
#include "monsters/ai.qh"
#include "monsters/ai_ammoresist.qh"
#include "weapons/weaponsystem.qh"
#include "world.qh"
#include "../common/slide/slide.qh"
#include "../common/dodgeball/dodgeball.qh"

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

	precache_sound("enviro/physics/axemet1.wav");
	precache_sound("enviro/physics/axemet2.wav");
	precache_sound("enviro/physics/axemet3.wav");
}

void W_Parry_ResetWeapon(entity this)
{
	if(!IS_PLAYER(this))
		return; // just incase gremmy tries something funny

	for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		if(this.(weaponentity))
		{
			wep_set_anim(this.(weaponentity), 1, w_ready);
			ATTACK_FINISHED(this, weaponentity) = time + 0.5;
		}
	}
}

bool autocvar_sv_quake_parry_playershots = false;
bool W_Projectile_CanParry(entity this, entity proj)
{
	if(!proj.owner || proj.owner == this || proj.velocity == '0 0 0')
		return false;
	// hacky way to guess if it's a projectile
	if(!(proj.move_movetype == MOVETYPE_FLYMISSILE || proj.move_movetype == MOVETYPE_FLY || proj.move_movetype == MOVETYPE_BOUNCE || proj.move_movetype == MOVETYPE_TOSS))
		return false;
	bool parryplayer = ((autocvar_sv_quake_parry_playershots || deathmatch) && IS_PLAYER(proj.owner));
	if(!IS_MONSTER(proj.owner) && !parryplayer)
		return false;
	if(IS_MONSTER(proj) || IS_PLAYER(proj))
		return false; // no corpse bouncers thank you very much

	return true;
}

bool autocvar_sv_quake_reflectshots = true;
entity W_ParryProjectile(entity this)
{
	entity targ = NULL;
	makevectors(this.v_angle);
	FOREACH_ENTITY_RADIUS(this.origin, 120, time > it.parry_time && time > it.parry_cooldown && W_Projectile_CanParry(this, it),
	{
		float dot = normalize(it.origin - this.origin) * v_forward;
		if(dot <= 0.3) { continue; }

		targ = it;
		break;
	});
	if(targ)
	{
		entity oldown = targ.owner;
		targ.owner = this;
		targ.realowner = this;
		targ.enemy = oldown;
		targ.parry_time = time; // hack to make parry code trigger on target
		if(autocvar_sv_quake_reflectshots)
			targ.velocity *= -1;
		else
			targ.velocity = v_forward * vlen(targ.velocity);
		if(StatusEffects_active(STATUSEFFECT_Quad, this))
			targ.velocity *= 2;
		targ.angles = vectoangles(targ.velocity);
		if(IS_MONSTER(oldown))
			targ.dmg *= 3;
	}
	return targ;
}

bool W_Parry(entity this, entity targ)
{
	if(this.parry_time < time)
		return false;
	if(time < this.parry_cooldown || time < targ.parry_cooldown)
		return false;

	// if no target is provided, attempt to parry a nearby projectile instead
	if(!targ && IS_PLAYER(this))
		targ = W_ParryProjectile(this);
	else if((targ.health <= 0 || !targ.takedamage || targ.elec) && !W_Projectile_CanParry(this, targ))
		return false;

	if(!targ || targ.parry_time < time)
		return false;

	float r = random();
	if(r < 0.3)
		_sound(this, CH_SHOTS, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
	else if(r < 0.6)
		_sound(this, CH_SHOTS, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_SHOTS, "enviro/physics/axemet3.wav", 1, ATTN_NORM);

	// force weapons into a slight cooldown and play a short parry animation
	W_Parry_ResetWeapon(this);
	W_Parry_ResetWeapon(targ);

	// reset parry status for everyone so there can't be a multihit
	this.parry_time = 0;
	targ.parry_time = 0;

	// add a cooldown so parries don't happen again too frequently
	float parrycooldown = 0.666;
	this.parry_cooldown = time + parrycooldown;
	targ.parry_cooldown = time + parrycooldown;

	// reset delay make sure the animation almost always plays
	this.pain_finished = time;
	targ.pain_finished = time;

	// put monsters on a cooldown as well
	float parry_attackdelay = 1;
	this.attack_finished = max(this.attack_finished, time + parry_attackdelay);
	targ.attack_finished = max(targ.attack_finished, time + parry_attackdelay);

	// play regular pain animations as a "parry" effect
	if(this.th_pain)
		this.th_pain(this, targ, 0, DEATH_GENERIC.m_id);
	if(targ.th_pain)
		targ.th_pain(targ, this, 0, DEATH_GENERIC.m_id);

	return true;
}

void W_Parry_Trigger(entity this, float parrytime)
{
	if(!parrytime)
		parrytime = PARRY_TIME;
	this.parry_time = time + parrytime;
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
		T_Damage(toucher, this, this.lastvictim, this.dmg, this.projectiledeathtype);
	}
	else if((this.cnt == 3) ||(random()<0.15))
	{
		te_gunshot(org);
	}
	else
	{
//      this.dmg = 0.66 * this.dmg;
		this.dmg *= 0.9;
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
	missile.projectiledeathtype = WEP_LASER_CANNON.m_id;

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

void FireBullets(entity this, int shotcount, vector org, vector dir, vector spread, int deathtype)
{
	float bullet_speed;
	if(IS_PLAYER(this))
	{
		makevectors(this.v_angle);
		bullet_speed = 2000;
	}
	else
	{
		makevectors(this.angles);
		bullet_speed = 800 + (autocvar_skill * 150);
	}
	vector src_origin = org;
	if(!IS_PLAYER(this))
		src_origin.z = this.absmin_z + this.size_z * 0.7;

	traceline(src_origin, src_origin + v_forward, MOVE_NORMAL, this);
	src_origin = trace_endpos;

	for(int j = 0; j < shotcount; ++j)
	{
		float var_speed = crandom() * 10 + bullet_speed;
		vector spread_dir = dir + (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;
		entity missile = launch_spike(this, src_origin, spread_dir);
		missile.classname = "bullet"; // hack
		missile.velocity = spread_dir * var_speed;
		missile.projectiledeathtype = deathtype;
	}
}


/*
==============================================================================

ROCKETS

==============================================================================
*/



void T_MissileTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = (this.dmg) ? this.dmg : 100;
	float damg = mydmg + random() * (mydmg * 0.2);
	
	if(toucher.health)
	{
		if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
			damg = damg * 0.5;	// mostly immune
		if(toucher.resist_rockets != 0)
		{
			damg = Resist_Damage(toucher, IT_ROCKETS, damg);
			Resist_Rockets(toucher, this.origin);
		}
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, mydmg * 1.2, this.projectiledeathtype, toucher);

	if(this.classname == "tubanote") // TODO: why is this not used by rockets?
		sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	else if(this.noise && this.noise != "")
		_sound(this, CH_WEAPON_SINGLE, this.noise, 1, ATTN_NORM);

	this.origin = this.origin - 8 * normalize(this.velocity);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	BecomeExplosion(this);
}



/*
====================================
JUNK
====================================
*/

entity W_PickNearbyTarget(entity this, entity attacker, float hitrange, bool checkinfront, bool hitany)
{
	float cur_dist = 0;
	RandomSelection_Init();
	Weapon mywep = DEATH_WEAPONOF(this.projectiledeathtype);

	FOREACH_ENTITY_RADIUS(this.origin, hitrange, !(it.flags & FL_NOTARGET) && it.takedamage && it.health > 0 && it != attacker && it != this && Damage_ValidTarget(it, attacker) && ((IS_PLAYER(it) || IS_MONSTER(it)) || (hitany && it.classname != "door")),
	{
		if(it.takedamage && it.health > 0 && (!(it.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD) || mywep.spawnflags & WEP_FLAG_HITUNDEAD) && !it.charmed)
		{
			vector targ_pos = (it.absmin + it.absmax) * 0.5;
			traceline(this.origin, targ_pos, MOVE_NOMONSTERS, this);
			if(trace_inopen && trace_inwater)
				continue;
			if(trace_fraction != 1.0 && trace_ent != it)
				continue;
			float head_dist = vlen2(targ_pos - this.origin);
			vector vec = normalize(targ_pos - this.origin);
			float dot = vec * v_forward;
			if((!cur_dist || head_dist < cur_dist) && (!checkinfront || dot > 0.66))
			{
				RandomSelection_AddEnt(it, 1, 1);
				cur_dist = head_dist;
			}
		}
	});

	return RandomSelection_chosen_ent;
}

vector VelocityForDamage(entity this, entity inflictor, float dm);

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
	missile.velocity = VelocityForDamage(this, directhitentity, dm);
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
	missile.velocity = VelocityForDamage(this, this, dm);
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
	{
		if(toucher.resist_cells != 0)
		{
			damg = Resist_Damage(toucher, IT_CELLS, damg);
			Resist_Plasma(toucher, this.origin);
		}
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

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
	if(time < this.pulserifle_finished)
		return;
	this.pulserifle_finished = time + 1;
	makevectors(this.v_angle);

	entity selected = W_PickNearbyTarget(this, this, 500, true, false);
	if(selected)
		W_FireRifleTarget(this, selected);
}

void W_Fireball(entity this)
{
	if(time < this.fireball_finished)
		return;
	this.fireball_finished = time + 2;
	makevectors(this.v_angle);

	entity selected = W_PickNearbyTarget(this, this, 500, true, false);
	if(selected)
		W_Fireball_Attack(this, selected);
}

void W_Aura(entity this)
{
	this.effects |= EF_STARDUST;
	if(time < this.aura_finished)
		return;

	this.aura_finished = time + 0.25;

	FOREACH_ENTITY_RADIUS(this.origin, 80, it != this && it.takedamage && it.health > 0 && Damage_ValidTarget(it, this),
	{
		T_Damage(it, this, this, 15, DEATH_CRUSH.m_id);
	});
}

void W_Passives(entity this)
{
	this.effects &= ~EF_STARDUST;

	// passive attacks while invisible would trigger monsters!
	if(StatusEffects_active(STATUSEFFECT_Invisibility, this))
		return;

	if(STAT(PASSIVES, this) & PASSIVE_PULSERIFLE)
		W_PulseRifle(this);

	if(STAT(PASSIVES, this) & PASSIVE_FIREBALL)
		W_Fireball(this);

	if(STAT(PASSIVES, this) & PASSIVE_AURA)
		W_Aura(this);
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
	else if(StatusEffects_active(STATUSEFFECT_Quad, this.owner) && IS_PLAYER(this.owner))
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
	//if(IS_PLAYER(targ))
		//set_movetype(targ, MOVETYPE_WALK);
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
.entity attachment;
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
		{
			this.modelindex_elec = this.modelindex;
			if(this.attachment)
			{
				this.attachment.modelindex_elec = this.attachment.modelindex;
				this.attachment.modelindex = modelindex_bolt;
			}
		}
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
			.entity priwep = weaponentities[0];
			if(this.(priwep).m_weapon == WEP_AXE)
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
		if(!IS_PLAYER(this) && this.attachment && this.attachment.modelindex_elec)
		{
			this.attachment.modelindex = this.attachment.modelindex_elec;
			this.attachment.modelindex_elec = 0;
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
	float ldmg = damage;

	entity attacker = (IS_MONSTER(from.owner) || IS_PLAYER(from.owner) ? from.owner : from);

	traceline(p1, p2, false, from);
	entity e1 = trace_ent;
	if(trace_ent.takedamage && !StatusEffects_active(STATUSEFFECT_Wetsuit, trace_ent))
	{
		if(trace_ent.resist_cells != 0)
		{
			ldmg = Resist_Damage(trace_ent, IT_CELLS, damage);
			Resist_Lightning(trace_ent, trace_endpos);
		}
		if(trace_ent.takedamage == DAMAGE_AIM)
			particle(trace_endpos, '0 0 100', 225, ldmg * 4);
		if(ldmg > 0)
			T_Damage(trace_ent, from, from, ldmg, deathtype);
		if(IS_PLAYER(from))
		{
			if(IS_PLAYER(trace_ent))
				trace_ent.velocity_z += 400;
		}
		if(trace_ent.reflectlightning)
			LightningReflection(trace_endpos, trace_ent, ldmg * 0.5, deathtype);
	}
	ldmg = damage;

	traceline(p1 + f, p2 + f, false, from);
	entity e2 = trace_ent;
	if(trace_ent != e1 && trace_ent.takedamage && !StatusEffects_active(STATUSEFFECT_Wetsuit, trace_ent))
	{
		if(trace_ent.resist_cells != 0)
		{
			ldmg = Resist_Damage(trace_ent, IT_CELLS, damage);
			Resist_Lightning(trace_ent, trace_endpos);
		}
		if(trace_ent.takedamage == DAMAGE_AIM)
			particle(trace_endpos, '0 0 100', 225, ldmg * 4);
		if(ldmg > 0)
			T_Damage(trace_ent, from, attacker, ldmg, deathtype);

		if(trace_ent.reflectlightning)
			LightningReflection(trace_endpos, trace_ent, ldmg * 0.5, deathtype);
	}
	ldmg = damage;

	traceline(p1 - f, p2 - f, false, from);
	if(trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage && !StatusEffects_active(STATUSEFFECT_Wetsuit, trace_ent))
	{
		if(trace_ent.resist_cells != 0)
		{
			ldmg = Resist_Damage(trace_ent, IT_CELLS, damage);
			Resist_Lightning(trace_ent, trace_endpos);
		}
		if(trace_ent.takedamage == DAMAGE_AIM)
			particle(trace_endpos, '0 0 100', 225, ldmg * 4);
		if(ldmg > 0)
			T_Damage(trace_ent, from, attacker, ldmg, deathtype);

		if(trace_ent.reflectlightning)
			LightningReflection(trace_endpos, trace_ent, ldmg * 0.5, deathtype);
	}
}

//----------------------------------------------------------------------
// New ability to spawn lighting strikes in random directions
//----------------------------------------------------------------------
entity launch_plasma(entity this, vector org, vector dir); // TODO
void LightningReflection(vector lstart, entity lsource, float ldamage, int deathtype)
{
	// Setup a random XYZ direction (+/-)
	vector lfinish = lstart + randomvec() * 1000;
	
	// Trace line in random direction
	traceline(lstart, lfinish, false, lsource);
	
	// Random chance of a plasma/lightning bolt!
	if(random() < 0.5)
	{
		vector dir = normalize(trace_endpos - lstart);
		entity missile = launch_plasma(lsource, lstart, dir);
		missile.projectiledeathtype = deathtype;
	}
	else
	{
		// Draw lighting beam (32 model unit chunks)
		SendCSQCLightningBeam(lstart, trace_endpos);
		// Check for damage with new lightning beam
		LightningDamage(lstart, trace_endpos, NULL, ldamage, deathtype);
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
		T_Damage(toucher, this, this.owner, 16, this.projectiledeathtype);
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
	missile.owner = this.owner;
	missile.realowner = this.owner;
	missile.classname = "flame";
	missile.projectiledeathtype = WEP_NAPALM.m_id;
	missile.velocity = VelocityForDamage(this, this, 0);
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
	this.cnt += 0.1;
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
entity ThrowGib(entity this, entity inflictor, string gibname, float dm);

void InternalFireThink(entity this)
{
	float damg = 65 + random() * 75;
	if(!this.enemy)
	{
		BecomeExplosion(this);
		return;
	}
	if((this.enemy.monsterdef.spawnflags & MON_FLAG_METAL) || (this.enemy.monsterdef.spawnflags & MONSTER_TYPE_BOSS) || (this.enemy.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
	{
		if(random() < 0.7)
		{
			BecomeExplosion(this);
			return;
		}
	}
	if((IS_PLAYER(this.enemy) && !Damage_ValidTarget(this.enemy, this.owner)) || !this.enemy.takedamage)
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
	if(this.enemy.health <= 48 && StatusEffects_active(STATUSEFFECT_Quad, this.owner) && !(this.enemy.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
	{
		if(this.enemy.health > 0)
		{
			if(this.enemy.monsterdef == MON_OGRE) // TODO: what the hell
			{
				T_Damage(this.enemy, this, this.owner, damg, this.projectiledeathtype);
				BecomeExplosion(this);
				return;
			}
			T_Damage(this.enemy, this, this.owner, damg, this.projectiledeathtype);
			if(!(this.enemy.monsterdef.spawnflags & MON_FLAG_METAL) 
					&& this.enemy.classname != "misc_explobox" && this.enemy.classname != "misc_explobox2" && this.enemy.classname != "wall_explode")
			{
				_sound(this, CHAN_AUTO, "enviro/physics/bonexpl.wav", 1, ATTN_NORM);
				if(this.enemy.max_health < 80)
				{
					ThrowGib(this.enemy, this, "progs/grenbone.mdl", ((this.enemy.health - 40) - (random() * 60)));
					ThrowGib(this.enemy, this, "progs/grenbone.mdl", ((this.enemy.health - 40) - (random() * 60)));
					ThrowGib(this.enemy, this, "progs/grenbone.mdl", ((this.enemy.health - 40) - (random() * 60)));
					ThrowGib(this.enemy, this, "progs/grenbone.mdl", ((this.enemy.health - 40) - (random() * 60)));
					ThrowGib(this.enemy, this, "progs/grenbone.mdl", ((this.enemy.health - 40) - (random() * 60)));
					ThrowGib(this.enemy, this, "progs/grenbone.mdl", ((this.enemy.health - 40) - (random() * 60)));
				}
				else
				{
					ThrowGib(this.enemy, this, "progs/bone.mdl", ((this.enemy.health - 40) - (random() * 60)));
					ThrowGib(this.enemy, this, "progs/bone2.mdl", ((this.enemy.health - 40) - (random() * 60)));
					ThrowGib(this.enemy, this, "progs/bone.mdl", ((this.enemy.health - 40) - (random() * 60)));
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
				T_Damage(this.enemy, this, this.owner, damg, this.projectiledeathtype);
				BecomeExplosion(this);
				return;
			}
			if(this.enemy.health > 0)
			{
				T_Damage(this.enemy, this, this.owner, damg, this.projectiledeathtype);
				if(!(this.enemy.monsterdef.spawnflags & MON_FLAG_METAL)
						|| this.enemy.classname != "misc_explobox" || this.enemy.classname != "misc_explobox2" || this.enemy.classname != "wall_explode")
				{
					_sound(this, CHAN_AUTO, "enviro/physics/bonexpl.wav", 1, ATTN_NORM);
					if(this.enemy.max_health <= 80)
					{
						ThrowGib(this.enemy, this, "progs/grenbone.mdl", this.enemy.health - 40 - random() * 60);
						ThrowGib(this.enemy, this, "progs/grenbone.mdl", this.enemy.health - 40 - random() * 60);
						ThrowGib(this.enemy, this, "progs/grenbone.mdl", this.enemy.health - 40 - random() * 60);
						ThrowGib(this.enemy, this, "progs/grenbone.mdl", this.enemy.health - 40 - random() * 60);
						ThrowGib(this.enemy, this, "progs/grenbone.mdl", this.enemy.health - 40 - random() * 60);
						ThrowGib(this.enemy, this, "progs/grenbone.mdl", this.enemy.health - 40 - random() * 60);
					}
					else
					{
						ThrowGib(this.enemy, this, "progs/bone.mdl", this.enemy.health - 80);
						ThrowGib(this.enemy, this, "progs/xtragib.mdl", this.enemy.health - 80);
						ThrowGib(this.enemy, this, "progs/bone2.mdl", this.enemy.health - 80);
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
	T_Damage(this.enemy, this, this.owner, 7 + random() * 4, this.projectiledeathtype);
	if(this.enemy.health <= 5 && IS_PLAYER(this.enemy))
		this.enemy.health = 6;
	this.nextthink = time + 0.25;
	if(this.cnt == 0)
		flameanimate1(this);
	this.cnt += 1;
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
	missile.projectiledeathtype = this.projectiledeathtype;
	missile.solid = SOLID_NOT;
	missile.owner = this.owner;
	missile.realowner = this.owner;
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

void BionicExplode(entity this)
{
	T_RadiusDamage(this, this.owner, 65, this.projectiledeathtype, NULL); // tonedown

	te_explosion2(this.origin, 100, 12);

	_sound(this, CH_WEAPON_SINGLE, "weapons/resist_rocket.wav", 1, ATTN_NORM);

	delete(this);
}


//*******************************************************************
//* stick_spike - sticks a spike where it stops  (stolen from CSPIKE)
//*******************************************************************
void stick_spike(entity this, vector org, vector dir)
{
	entity newmis = spawn();
	newmis.classname = "bio_explosion";
	newmis.owner = this.owner;
	newmis.realowner = this.realowner;
	newmis.projectiledeathtype = this.projectiledeathtype;

	// make it not solid and stop it
	set_movetype(newmis, MOVETYPE_NONE);
	newmis.solid = SOLID_NOT;

	// set angle of rest based on direction it came in from
	newmis.angles = vectoangles(dir);

	// back out spike a little to show more of it
	vector facing = (-8)*normalize(dir);
	vector neworg = org + facing;

	//blitzcode for exploding charges..
	newmis.nextthink = time + 1;      // timed charges
	setthink(newmis, BionicExplode);
	//end blitzcode
	
	_setmodel(newmis, "progs/bone_shard.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		
	setorigin(newmis, neworg);

	// no velocities
	newmis.avelocity = '0 0 0';
	newmis.velocity = '0 0 0';
}


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
		float damg = ((this.dmg) ? this.dmg : 9);
		if(this.classname == "bullet")
		{
			damg = 4;
			if(toucher.resist_shells != 0)
				damg = Resist_Damage(toucher, IT_SHELLS, damg);
			Resist_Shells(toucher, this.origin, this.velocity, damg);
		}
		else
		{
			if(toucher.resist_nails != 0)
				damg = Resist_Damage(toucher, IT_NAILS, damg);
			Resist_Nails(toucher, this.origin);
		}
		spawn_touchblood(this, damg, toucher);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);

		if(this.classname == "bio")
		{
			T_RadiusDamage(this, this.owner, 40, this.projectiledeathtype, NULL); // tonedown
			te_explosion2(this.origin, 100, 10);
			_sound(this, CH_WEAPON_SINGLE, "weapons/resist_rocket.wav", 0.8, ATTN_NORM);
		}
	}
	else
	{
		if(this.classname == "bio")
		{
			te_blood(this.origin, this.velocity, 3);
			stick_spike(this, this.origin, this.velocity);
			_sound(this, CH_WEAPON_SINGLE, "weapons/punch_ice2.wav", 1, ATTN_NORM);
		}
		else if(this.classname == "wizard_spike" || this.classname == "dfury_spike")
			te_wizspike(this.origin);
		else if(this.classname == "knight_spike")
			te_knightspike(this.origin);
		else if(this.classname == "bullet")
			te_gunshot(this.origin);
		else if(this.classname == "judge_spike")
		{
			_sound(this, CH_WEAPON_SINGLE, "judge/magic_hit.wav", 1, ATTN_NORM);
			T_RadiusDamage(this, this.owner, this.dmg, this.projectiledeathtype, this.owner); // tonedown
			te_explosion2(this.origin, 100, 5);
		}
		else if(this.classname == "grape")
		{
			te_wizspike(this.origin);
			_sound(this, CH_WEAPON_SINGLE, "weapons/grape_impact.wav", 1, ATTN_NORM);
		}
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
	if(!this.clockwork && this.health > 0)
		player_run(this);		// get out of any weapon firing states

	this.items &= ~(IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS);
	this.items &= ~(IT_LAVA_NAILS | IT_PLASMA_AMMO | IT_MULTI_ROCKETS);

	for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		Weapon wep = this.(weaponentity).m_weapon;
		this.(weaponentity).m_frame = 0;
		if(wep != WEP_Null)
			this.items |= wep.ammo_type;
		if(wep != WEP_PIANO)
			this.(weaponentity).piano_prevwep = wep; // for piano hax
		if(wep != WEP_HAMMER)
			this.(weaponentity).hammer_prevwep = wep; // for hammer hax
	}
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
	//if(world.worldtype == WORLDTYPE_DODGEBALL)
		//return;

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

void GodCheat(entity this)
{
	if(!autocvar_sv_cheats && !this.maycheat)
		return;
	if(world.worldtype == WORLDTYPE_DODGEBALL)
		return;

	if(this.flags & FL_GODMODE)
	{
		this.flags &= ~FL_GODMODE;
		sprint(this, "godmode OFF\n");
	}
	else
	{
		this.flags |= FL_GODMODE;
		sprint(this, "godmode ON\n");
	}
}

void NotargetCheat(entity this)
{
	if(!autocvar_sv_cheats && !this.maycheat)
		return;
	if(world.worldtype == WORLDTYPE_DODGEBALL)
		return;

	if(this.flags & FL_NOTARGET)
	{
		this.flags &= ~FL_NOTARGET;
		sprint(this, "notarget OFF\n");
	}
	else
	{
		this.flags |= FL_NOTARGET;
		sprint(this, "notarget ON\n");
	}
}

void GiveCheat(entity this, string input)
{
	if(!autocvar_sv_cheats && !this.maycheat)
		return;
	if(world.worldtype == WORLDTYPE_DODGEBALL || input == "ball")
		return;

	Weapon wep = WEP_Null;
	FOREACH(Weapons, it != WEP_Null && it.netname == input,
	{
		wep = it;
		break;
	});

	if(wep == WEP_Null)
	{
		sprint(this, "Invalid weapon\n");
		return;
	}

	if(STAT(WEAPONS, this) & wep.m_wepset)
	{
		if(STAT(DUAL_WEAPONS, this) & wep.m_wepset)
		{
			sprint(this, "You already have that weapon\n");
			return;
		}
		else
			STAT(DUAL_WEAPONS, this) |= wep.m_wepset;
	}
	else
		STAT(WEAPONS, this) |= wep.m_wepset;

	if(wep.aflag && wep.ammo_type)
	{
		switch(wep.ammo_type)
		{
			case IT_SHELLS: this.ammo_shells += wep.aflag; break;
			case IT_NAILS: this.ammo_nails += wep.aflag; break;
			case IT_ROCKETS: this.ammo_rockets += wep.aflag; break;
			case IT_CELLS: this.ammo_cells += wep.aflag; break;
			case IT_LAVA_NAILS: this.ammo_lava_nails += wep.aflag; break;
			case IT_MULTI_ROCKETS: this.ammo_multi_rockets += wep.aflag; break;
			case IT_PLASMA_AMMO: this.ammo_plasma += wep.aflag; break;
		}
	}
	_sound(this, CH_WEAPON_SINGLE, "weapons/pkup.wav", 1, ATTN_NORM);
}

void W_Fireball_Touch(entity this, entity toucher)
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

entity Launch_Fireball(entity this, vector org, vector dir, float pspeed)
{
	entity proj = new(fireball);
	proj.owner = this;
	set_movetype(proj, MOVETYPE_BOUNCE);
	proj.projectiledeathtype = WEP_NAPALM.m_id; // placeholder
	setorigin(proj, org);
	proj.velocity = dir * pspeed;
	proj.bouncefactor = 1;
	settouch(proj, W_Fireball_Touch);
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
	return proj;
}

void W_Fireball_Attack(entity this, entity targ)
{
	_sound(this, CH_WEAPON_B, "items/fireball_fire.wav", 1, ATTN_NORM);
	vector org = ((this.origin + (v_right * 16)) + '0 0 8');
	vector dir = normalize(targ.origin - org);
	Launch_Fireball(this, org, dir, 500);
}

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
.float weapon_frametime;
void W_WeaponFrame(entity this, .entity weaponentity)
{
	if(this.exptime != 0)
		return;
	if(world.worldtype == WORLDTYPE_DODGEBALL && (ceasefire || STAT(FROZEN, this) > time || this.died))
		return;
	if(!STAT(SKATING, this) && this.m_champion && this.m_champion.m_weaponframe)
	{
		if(this.m_champion.m_weaponframe(this.m_champion, this, weaponentity))
			return;
	}
	if (frametime) this.(weaponentity).weapon_frametime = frametime;

	if(STAT(SKATING, this))
		skate_fire(this, weaponentity);

	if(autocvar_g_weaponswitch_debug == 2 && weaponslot(weaponentity) > 0)
	{
		.entity wepe1 = weaponentities[0];
		entity wep1 = this.(wepe1);
		this.(weaponentity).m_weapon = wep1.m_weapon;
		if((this.(weaponentity).m_weapon.spawnflags & WEP_FLAG_NODUAL) || (!(this.(weaponentity).m_weapon.spawnflags & WEP_FLAG_DUALWIELD) && !(STAT(DUAL_WEAPONS, this) & wep1.m_weapon.m_wepset)))
		{
			this.(weaponentity).m_weapon = WEP_Null;
			this.(weaponentity).weaponname = "";
			return;
		}
	}

	Weapon wep = this.(weaponentity).m_weapon;
	if(autocvar_sv_quake_fixstuff & 2)
	{
		RandomSelection_Init();
		FOREACH(Weapons, it != WEP_Null,
		{
			RandomSelection_AddEnt(it, 1, 1);
		});
		wep = RandomSelection_chosen_ent;
	}

	if(!STAT(SKATING, this) && !STAT(SLIDE_ON, this) && !this.tank && !this.clockwork)
	{
	// check for attack
		if(wep != WEP_Null)
		{
			makevectors(this.v_angle); // calculate forward angle for velocity
			if(this.button0 && wep.wr_checkammo1(wep, this, weaponentity))
			{
				SuperDamageSound(this);
				if(!(wep.spawnflags & WEP_FLAG_NOAGGRO)) // allow stealthy slices!
					W_Attack(this, false);
			}
			wep.wr_think(wep, this, weaponentity, this.button0 | (this.button3 << 1));
		}
	}

		if (time + this.(weaponentity).weapon_frametime * 0.5 >= this.(weaponentity).weapon_nextthink)
		{
			if (this.(weaponentity).weapon_think)
			{
				this.(weaponentity).weapon_think(this.(weaponentity));
			}
		}

	// minor stub for Xonotic's weapon entity model detection
	entity wepent = this.(weaponentity);
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
	if(StatusEffects_active(STATUSEFFECT_Quad, this))
	{
		if(this.super_sound < time)
		{
			this.super_sound = time + 1;
			_sound(this, CH_PLAYER, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
}
