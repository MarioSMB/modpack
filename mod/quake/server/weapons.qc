#include "weapons.qh"

#include "combat.qh"
#include "client.qh"
#include "impel/impel.qh"
#include "monsters/ai.qh"

.bool lavaGunFired;

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

/*
=================
HIP_FireLaser
=================
*/
void HIP_FireLaser(entity this, float stat)
{
	if(!this.button0)
	{
		player_run(this);
		return;
	}
	if(this.ammo_cells < 1)
	{
		W_SwitchWeapon(this, W_BestWeapon(this, 0));
		return;
	}
	SuperDamageSound(this);
	this.effects |= EF_MUZZLEFLASH;
	makevectors(this.v_angle);

	float ofs = 6;
	vector out = vec2(v_forward);
	out = normalize(out);
	vector org = this.origin +((12-ofs) * v_up) +(12*out);
//   org = this.origin +(1*v_forward);
	vector dir = qc_aim(this, 1000);
	float aofs = ofs * 0.707;
	if(stat == 0)
	{
		this.currentammo = this.ammo_cells = this.ammo_cells - 1;
		org = org +(aofs*v_right);
		org = org -(aofs*v_up);
		HIP_LaunchLaser(this, org, dir, 0);
		org = org -(2*aofs*v_right);
		HIP_LaunchLaser(this, org, dir, 0);
	}
	else if(stat == 1)
	{
		this.currentammo = this.ammo_cells = this.ammo_cells - 1;
		org = org +(ofs*v_up);
		if(random() < 0.1)
		{
			entity missile = HIP_LaunchLaser(this, org, dir, 1);
			missile.dmg = 25;
		}
		else
			HIP_LaunchLaser(this, org, dir, 0);
	}
	this.punchangle_x = -1;
}

/*
=================
HIP_HammerDamage
=================
*/
void HIP_HammerDamage(vector p1, vector p2, entity from, float damage)
{
	vector f = p2 - p1;
	normalize(f);
	f.x = 0 - f.y;
	f.y = f.x;
	f.z = 0;
	f = f*16;

	entity e1 = NULL, e2 = NULL;

	traceline(p1, p2, false, from);
//JIM
	if(trace_ent.takedamage && !trace_ent.wetsuit_finished )
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage);
		if(IS_PLAYER(from))
		{
			if(IS_PLAYER(trace_ent))
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline(p1 + f, p2 + f, false, from);
//JIM
	if(trace_ent != e1 && trace_ent.takedamage &&
		!trace_ent.wetsuit_finished )
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage);
	}
	e2 = trace_ent;

	traceline(p1 - f, p2 - f, false, from);
//JIM
	if(trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage &&
		!trace_ent.wetsuit_finished )
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage);
	}
}

//void(entity prev, entity owner, float dst) HIP_SpawnMjolnirLightning;
void HIP_LightningThink(entity this)
{
	if(time > this.delay)
	{
		if(this.enemy != NULL)
			this.enemy.struck_by_mjolnir = false;
		delete(this);
		return;
	}
	int oldstate = this.state;
	if(this.state == 0)
	{
		// look in our immediate vicinity
		this.enemy = NULL;
		entity selected = NULL;
		entity head = findradius(this.owner.origin, this.distance);
		while(head)
		{
			if(!(head.flags & FL_NOTARGET) && (IS_MONSTER(head) || IS_PLAYER(head)))
			{
//            if(visible(head) &&(head!=this.owner.owner) &&(head.health>0))
				if((head!=this.owner.owner) &&(head.health>0) && (visible(this, head)))
				{
					float cur_dist = this.distance;
					float head_dist = vlen(head.origin - this.lastvictim.origin);
					if((head_dist < cur_dist) && !head.struck_by_mjolnir)
					{
						selected = head;
						cur_dist = head_dist;
					}
				}
			}
			head = head.chain;
		}
		if(selected != NULL)
		{
			this.state = 1;
			this.enemy = selected;
			this.enemy.struck_by_mjolnir = true;
		}
		else
		{
			makevectors(this.v_angle);
			vector owner_org = this.owner.origin;
			vector end = owner_org + v_forward * 200;
			end = end +(((400 * random()) - 200) * v_right);

			traceline(owner_org, end, true, this);

			te_lightning2(NULL, owner_org, trace_endpos); // should be this, bug in te_lightning

			this.nextthink = time + 0.1;
	//      setthink(this, HIP_DiversionLightningThink);
	//      this.nextthink = time;
	//		this.delay = time + 0.30;
	//		this.origin = this.owner.origin;
	//		getthink(this)(this);
			return;
		}
	}
	vector org = this.lastvictim.origin;
	vector dst = this.enemy.absmin + 0.25 *(this.enemy.absmax - this.enemy.absmin);
	dst = dst +(random() * 0.5 *(this.enemy.absmax - this.enemy.absmin));
	traceline(org, dst, true, this.owner.owner);

	if(trace_fraction != 1.0 || this.enemy.health<=0)
	{
		this.enemy.struck_by_mjolnir = false;
		this.state = 0;
		this.nextthink = time + 0.1;
		return;
	}
	te_lightning2(NULL, org, trace_endpos);
	vector vec = normalize(this.enemy.origin - this.owner.origin);
	float dot = vec * this.owner.movedir;
	float dam =((oldstate == 0) ? 80 : 30);
	entity own = this.owner.owner;
	if(dot > 0.3)
		HIP_HammerDamage(org, trace_endpos, own, dam);
	else
		HIP_HammerDamage(org, trace_endpos, own, dam*0.5);

	this.nextthink = time + 0.2;
}

void HIP_SpawnMjolnirLightning(entity this, entity prev, entity own, float dst)
{
	// spawn actual lightning
	entity light = spawn();
	light.delay = time + 0.8;
	light.state = 0;
	light.lastvictim = prev;
	light.distance = dst;
	light.owner = own;
	light.v_angle = this.angles;
	light.v_angle_x = 0;
	light.v_angle_z = 0;
	light.origin = own.origin;
	setthink(light, HIP_LightningThink);
	light.nextthink = time;
}

void HIP_SpawnMjolnirBase(entity this)
{
	// spawn lightning base
	entity light = spawn();
//   light.origin = this.origin - '0 0 24' +(32*v_forward);
	light.origin = trace_endpos;
	light.flags = 0;
	light.owner = this;
	light.struck_by_mjolnir = true;
	setthink(light, SUB_Remove);
	light.nextthink = time + 1;
	_sound(light, CHAN_AUTO, "hipweap/mjolslap.wav", 1, ATTN_NORM);
	_sound(light, CH_WEAPON_SINGLE, "hipweap/mjolhit.wav", 1, ATTN_NORM);
	makevectors(this.v_angle);
	light.movedir = v_forward;
	HIP_SpawnMjolnirLightning(this, light, light, 350);
	HIP_SpawnMjolnirLightning(this, light, light, 350);
	HIP_SpawnMjolnirLightning(this, light, light, 350);
	HIP_SpawnMjolnirLightning(this, light, light, 350);
}

void HIP_FireMjolnirLightning(entity this)
{
// explode if under water
	if(this.waterlevel > 1)
	{
		int cells = this.ammo_cells;
		this.ammo_cells = 0;
		discharged = true;
		T_RadiusDamage(this, this, 35 * cells, NULL);
		discharged = false;
		W_SetCurrentAmmo(this);
		return;
	}

//   if(this.t_width < time)
//   {
//      _sound(this, CH_WEAPON_SINGLE, "weapons/lhit.wav", 1, ATTN_NORM);
//      this.t_width = time + 0.6;
//   }
//   this.punchangle_x = 12;

	this.currentammo = this.ammo_cells = this.ammo_cells - 15;

	HIP_SpawnMjolnirBase(this);
}

void HIP_FireMjolnir(entity this)
{
	this.attack_finished = time + 0.4;
	vector source = this.origin + '0 0 16';

	makevectors(this.v_angle);
	traceline(source, source + v_forward*32, false, this);
	if(trace_fraction == 1.0 &&(this.ammo_cells >= 15))
	{
		source = source + v_forward*32;
		traceline(source , source - v_up*50, false, this);
//      dprint("fraction = ");
//      dprint(ftos(trace_fraction));
//      dprint("\n");
		if(trace_fraction > 0.3 && trace_fraction< 1.0)
		{
			HIP_FireMjolnirLightning(this);
			this.attack_finished = time + 1.5;
			return;
		}
	}
	vector org = trace_endpos - v_forward*4;

	if(trace_ent.takedamage)
	{
		float damage = 50;
		if(trace_ent.monsterdef && (trace_ent.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
			damage = 70;
		trace_ent.axhitme = true;
		SpawnBlood(org, v_forward, damage, trace_ent);
		T_Damage(trace_ent, this, this, damage);
	}
	else
	{  // hit wall
		if(trace_fraction != 1.0)
		{
//         _sound(this, CH_WEAPON_SINGLE, "player/axhit2.wav", 1, ATTN_NORM);
			_sound(this, CH_WEAPON_SINGLE, "hipweap/mjoltink.wav", 1, ATTN_NORM);
			te_gunshot(org);
		}
		else
		{
			_sound(this, CH_WEAPON_SINGLE, "knight/sword1.wav", 1, ATTN_NORM);
		}
	}
	this.attack_finished = time + 0.4;
}

void W_SwitchWeapon(entity this, float to_wep)
{
	if(this.weapon == to_wep || to_wep == WEP_PULSERIFLE)
		return; // don't mess up the system by switching to it again!

	this.prevweapon = this.weapon;
	this.weapon = to_wep;

	W_SetCurrentAmmo(this);

#if 0
	if(to_wep == WEP_PULSERIFLE)
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

/*
================
W_FireAxe
================
*/
void W_FireAxe(entity this)
{
	makevectors(this.v_angle);
	vector source = this.origin + '0 0 16';
	traceline(source, source + v_forward*64, false, this);
	if(trace_fraction == 1.0)
		return;
	
	vector org = trace_endpos - v_forward * 4;

	if(trace_ent.takedamage && trace_ent.monsterdef != MON_CHTHON) // yoder mod, Jan 05 2021
	{
		if(MP_IMPEL)
		{
			float r = random();
			if(trace_ent.monsterdef == MON_JUGGERNAUT)
				_sound(this, CH_WEAPON_SINGLE, "monsters/juggers/jbent.wav", 1, ATTN_NORM);
			else if(trace_ent.monsterdef && (trace_ent.monsterdef.spawnflags & MON_FLAG_METAL))
			{
				if(r < 0.3)
					_sound(trace_ent, CHAN_ITEM, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
				else if(r < 0.6)
					_sound(trace_ent, CHAN_ITEM, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
				else
					_sound(trace_ent, CHAN_ITEM, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
			}
			else if(IS_PLAYER(trace_ent) && trace_ent.armorvalue > 0)
			{
				if(r < 0.3)
					_sound(trace_ent, CHAN_ITEM, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
				else if(r < 0.6)
					_sound(trace_ent, CHAN_ITEM, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
				else
					_sound(trace_ent, CHAN_ITEM, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
			}
			else if(r < 0.5)
			{
				_sound(trace_ent, CHAN_ITEM, "enviro/physics/axecut1.wav", 1, ATTN_NORM);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
			}
			else
			{
				_sound(trace_ent, CHAN_ITEM, "enviro/physics/axecut2.wav", 1, ATTN_NORM);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
			}
		}
		trace_ent.axhitme = true;
		if(!MP_IMPEL)
			SpawnBlood(org, '0 0 0', 20, trace_ent);
		T_Damage(trace_ent, this, this, 20);
	}
	else
	{	// hit wall
		_sound(this, CH_WEAPON_SINGLE, "player/axhit2.wav", 1, ATTN_NORM);
		te_gunshot(org);
	}
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
		if(trace_fraction != 1.0)
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
================
W_FireShotgun
================
*/
void W_FireShotgun(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "weapons/guncock.wav", 1, ATTN_NORM);	

	this.punchangle_x = -2;

	this.currentammo = this.ammo_shells = this.ammo_shells - 1;
	vector dir = qc_aim(this, 100000);
	FireBullets(this, 6, dir, '0.04 0.04 0');
}


/*
================
W_FireSuperShotgun
================
*/
void W_FireSuperShotgun(entity this)
{
	if(this.currentammo == 1)
	{
		W_FireShotgun(this);
		return;
	}
		
	_sound(this ,CH_WEAPON_SINGLE, "weapons/shotgn2.wav", 1, ATTN_NORM);	

	this.punchangle_x = -4;

	this.currentammo = this.ammo_shells = this.ammo_shells - 2;
	vector dir = qc_aim(this, 100000);
	FireBullets(this, 14, dir, '0.14 0.08 0');
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
	_setmodel(this, "progs/s_explod.spr");
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

	te_explosion(this.origin);

	BecomeExplosion(this);
}



/*
================
W_FireRocket
================
*/
entity W_FireRocket(entity this)
{
	this.currentammo = this.ammo_rockets = this.ammo_rockets - 1;
	
	_sound(this, CH_WEAPON_SINGLE, "weapons/sgun1.wav", 1, ATTN_NORM);

	this.punchangle_x = -2;

	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
		
// set missile speed	

	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	
	settouch(missile, T_MissileTouch);
	
// set missile duration
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);

	_setmodel(missile, "progs/missile.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin + v_forward*8 + '0 0 16');

	return missile;
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
			if(this.weapon == WEP_AXE)
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

void rebound(entity this)
{
	this.owner = this.owner;
	_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lghit.wav", 1, ATTN_NORM);
	this.velocity = normalize(this.velocity);
	this.velocity = this.velocity * 1000;
	set_movetype(this, MOVETYPE_FLYMISSILE);
	this.angles = vectoangles(this.velocity);
	setthink(this, SUB_Remove);
	this.nextthink = time + 0.4;
	spawn_touchspark(this, 1);
	this.bounced = this.bounced + 1;
	if(this.bounced == 5)
	{
		delete(this);
		return;
	}
	if(!(this.flags & FL_INWATER))
	{
		if(this.watertype == CONTENT_WATER)
		{
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgdis1.wav", 1, ATTN_NORM);
			SpawnDischarge(this, 200);
			SpawnDischarge(this, 200);
			SpawnDischarge(this, 200);
			T_RadiusDamage(this, this.owner, 200, NULL);
			delete(this);
			return;
		}
		if(this.watertype == CONTENT_SLIME)
		{
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgdis2.wav", 1, ATTN_NORM);
			SpawnDischarge(this, 150);
			SpawnDischarge(this, 150);
			T_RadiusDamage(this, this.owner, 150, NULL);
			delete(this);
			return;
		}
		if(this.watertype == CONTENT_LAVA)
		{
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgdis3.wav", 1, ATTN_NORM);
			SpawnDischarge(this, 100);
			SpawnDischarge(this, 100);
			T_RadiusDamage(this, this.owner, 100, NULL);
			delete(this);
			return;
		}
	}
	this.owner = other;
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

void LightningTouch(entity this, entity toucher)
{
	if(toucher.solid == SOLID_TRIGGER)
		return;
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	if(toucher.takedamage && toucher.monsterdef != MON_JUGGERNAUT)
	{
		if(toucher.takedamage == DAMAGE_AIM)
			spawn_extrablood(this, toucher, 1000); // TODO: toucher?
		float damg = 16;
		if(this.owner.super_damage_finished > time && toucher.health <= (damg * 4))
		{
			if(toucher.move_movetype == MOVETYPE_PUSH)
			{
				T_Damage(toucher, this, this.owner, damg);
				return;
			}
			if(toucher.classname == "door")
			{
				T_Damage(toucher, this, this.owner, damg);
				return;
			}
			if(toucher.move_movetype == MOVETYPE_NONE)
			{
				T_Damage(toucher, this, this.owner, damg);
				return;
			}
			ThrowMe(this, toucher, damg);
			if(!IS_PLAYER(toucher))
				toucher.owner = this.owner;
			else
				toucher.enemy = this.owner;
			delete(this);
			toucher.takedamage = DAMAGE_NO;
			setthink(toucher, gibhim);
			toucher.nextthink = time;
			return;
		}
		if(toucher.health <= damg)
		{
			if(toucher.move_movetype == MOVETYPE_PUSH)
			{
				T_Damage(toucher, this, this.owner, damg);
				return;
			}
			if(toucher.classname == "door")
			{
				T_Damage(toucher, this, this.owner, damg);
				return;
			}
			if(toucher.move_movetype == MOVETYPE_NONE)
			{
				T_Damage(toucher, this, this.owner, damg);
				return;
			}
			ThrowMe(this, toucher, damg);
			if(!IS_PLAYER(toucher))
				toucher.owner = this.owner;
			else
				toucher.enemy = this.owner;
			delete(this);
			toucher.takedamage = DAMAGE_NO;
			setthink(toucher, gibhim);
			toucher.nextthink = time;
			return;
		}
		else
		{
			T_Damage(toucher, this, this.owner, damg);
			if(toucher.takedamage == DAMAGE_AIM)
				SpawnMeatBounce(this, toucher, damg);
			ThrowMe(this, toucher, damg);
			delete(this);
		}
	}
	else
	{
		set_movetype(this, MOVETYPE_BOUNCE);
		setthink(this, rebound);
		this.ltime = this.nextthink;
		this.nextthink = time + 0.1;
		return;
	}
}

void W_FireSuperLightning(entity this)
{
	float r = random();
	if(this.waterlevel > 1)
	{
		float cells = this.ammo_cells;
		this.ammo_cells = 0;
		W_SetCurrentAmmo(this);
		T_RadiusDamage(this, this, 35 * cells, NULL);
		return;
	}
	this.currentammo = this.ammo_cells = this.ammo_cells - 1;
	this.punchangle_x = -2;
	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	missile.classname = "lightme";
	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 2000);
	missile.velocity = missile.velocity * 2000;
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, LightningTouch);
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);
	if(this.lightningmodel == 1)
	{
		if(r <= 0.3)
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgstart2.wav", 1, ATTN_NORM);
		else if(r <= 0.6)
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgstart3.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_WEAPON_SINGLE, "weapons/light2/lgstart1.wav", 1, ATTN_NORM);
		_setmodel(missile, "progs/bolt2.mdl");
		this.lightningmodel = 0;
	}
	else if(this.lightningmodel == 0)
	{
		_setmodel(missile, "progs/bolt.mdl");
		this.lightningmodel = 1;
	}
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, this.origin + '0 0 0' - v_forward * 0); // lol what
}

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


void W_FireLightning(entity this)
{
	if(this.ammo_cells < 1)
	{
		W_SwitchWeapon(this, W_BestWeapon(this, 0));
		return;
	}

// explode if under water
	if(this.waterlevel > 1)
	{
		int cells = this.ammo_cells;
		this.ammo_cells = 0;
		W_SetCurrentAmmo(this);
		discharged = true;
		T_RadiusDamage(this, this, 35 * cells, NULL);
		discharged = false;
		return;
	}

	makevectors(this.v_angle);

	if(this.t_width < time)
	{
		_sound(this, CH_WEAPON_SINGLE, "weapons/lhit.wav", 1, ATTN_NORM);
		this.t_width = time + 0.6;
	}
	this.punchangle_x = -2;

	this.currentammo = this.ammo_cells = this.ammo_cells - 1;

	vector org = this.origin + '0 0 16';

	traceline(org, org + v_forward*600, MOVE_NOMONSTERS, this);

	te_lightning2(NULL, org, trace_endpos);

	LightningDamage(org, trace_endpos + v_forward*4, this, 30);
}


//=============================================================================


bool inside_nradius;

void NapalmFlameThink(entity this)
{
	if(!(this.flags & FL_INWATER) && this.cnt == 0)
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
	if(inside_nradius)
	{
		error("NapalmFlameThink: recursive");
		return;
	}
	inside_nradius = true;
	entity head = findradius(this.origin, 55);
	while(head)
	{
		if(head.takedamage)
			T_Damage(head, this, this.owner.owner, 2 + (random() * 4));
		head = head.chain;
	}
	inside_nradius = false;
	this.nextthink = time + 0.35;
	this.cnt = this.cnt + 1;
	if(this.cnt >= 10 + random() * 5)
	{
		this.cnt = 0;
		BecomeExplosion(this);
		return;
	}
	setthink(this, NapalmFlameThink);
}

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

void napalmrebound(entity this)
{
	if(!(this.flags & FL_INWATER))
	{
		if(this.watertype == CONTENT_WATER)
		{
			sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
			BecomeExplosion(this);
			return;
		}
		if(this.watertype == CONTENT_SLIME)
		{
			sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
			BecomeExplosion(this);
			return;
		}
		if(this.watertype == CONTENT_LAVA)
		{
			sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
			BecomeExplosion(this);
			return;
		}
	}
	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	SpawnFireSpark(this);
	SpawnFireSpark(this);
	SpawnFireSpark(this);
	BecomeExplosion(this);
}

void NapalmTouch(entity this, entity toucher)
{
	if(toucher.takedamage && toucher.takedamage == DAMAGE_AIM && toucher.monsterdef != MON_SPIDER_DROID && toucher.monsterdef != MON_ZOMBIE
			&& toucher.monsterdef != MON_SHAMBLER && toucher.monsterdef != MON_VORE)
	{
		SpawnInternalFire(this, toucher);
	}
	setorigin(this, this.origin - 8 * normalize(this.velocity));
	setthink(this, napalmrebound);
	this.ltime = this.nextthink;
	this.nextthink = time;
}

void W_FireNapalm(entity this)
{
	this.currentammo = this.ammo_rockets = this.ammo_rockets - 1;
	_sound(this, CH_WEAPON_SINGLE, "weapons/grenade.wav", 1, ATTN_NORM);
	this.punchangle_x = -2;
	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	missile.classname = "flame";
	missile.takedamage = DAMAGE_NO;
	makevectors(this.v_angle);
	if(this.v_angle_x)
		missile.velocity = v_forward * 800 + v_up * 250 + crandom() * v_right * 10 + crandom() * v_up * 10;
	else
	{
		missile.velocity = qc_aim(this, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}
	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, NapalmTouch);
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);
	_setmodel(missile, "progs/nbomb.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, this.origin + v_right * 6);
}

//=============================================================================


void GrenadeExplode(entity this)
{
	T_RadiusDamage(this, this.owner, 120, NULL);

	te_explosion(this.origin);

	BecomeExplosion(this);
}

void GrenadeTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner
	if(toucher.takedamage == DAMAGE_AIM)
	{
		GrenadeExplode(this);
		return;
	}
	if(this.attack_finished < time)
		_sound(this, CH_WEAPON_SINGLE, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	this.attack_finished = time + 0.1;
	if(this.velocity == '0 0 0')
		this.avelocity = '0 0 0';
}

/*
================
W_FireGrenade
================
*/
void W_FireGrenade(entity this)
{
	this.currentammo = this.ammo_rockets = this.ammo_rockets - 1;
	
	_sound(this, CH_WEAPON_SINGLE, "weapons/grenade.wav", 1, ATTN_NORM);

	this.punchangle_x = -2;

	entity missile = new(grenade);
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
		
// set missile speed	

	makevectors(this.v_angle);

	if(this.v_angle_x)
		missile.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		missile.velocity = qc_aim(this, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);

	settouch(missile, GrenadeTouch);
	
// set missile duration
	missile.nextthink = time + 2.5;
	setthink(missile, GrenadeExplode);

	_setmodel(missile, "progs/grenade.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin);
}


//=============================================================================

void spike_touch(entity this, entity toucher);
void superspike_touch(entity this, entity toucher);


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

void W_FireSuperSpikes(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "weapons/spike2.wav", 1, ATTN_NORM);
	this.attack_finished = time + 0.2;
	this.currentammo = this.ammo_nails = this.ammo_nails - 2;
	vector dir = qc_aim(this, 1000);
	entity newmis = launch_spike(this, this.origin + '0 0 16', dir);
	if(MP_IMPEL)
		newmis.classname = "superspike";
	else
		newmis.classname = "super_spike";
	settouch(newmis, superspike_touch);
	_setmodel(newmis, "progs/s_spike.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		
	this.punchangle_x = -2;
}

void W_FireSpikes(entity this, float ox)
{
	makevectors(this.v_angle);
	
	if(this.ammo_nails >= 2 && this.weapon == WEP_SUPER_NAILGUN)
	{
		W_FireSuperSpikes(this);
		return;
	}
	if(this.ammo_nails < 1)
	{
		W_SwitchWeapon(this, W_BestWeapon(this, 0));
		return;
	}

	if(MP_IMPEL && this.silencer)
		_sound(this, CH_WEAPON_SINGLE, "weapons/rocketli.wav", 0.2, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "weapons/rocket1i.wav", 1, ATTN_NORM);
	this.attack_finished = time + 0.2;
	this.currentammo = this.ammo_nails = this.ammo_nails - 1;
	vector dir = qc_aim(this, 1000);
	// NOTE: position fix by Seven and Sajt applied here
	launch_spike(this, this.origin + this.view_ofs + v_up * -8 + v_right * ox, dir);

	this.punchangle_x = -2;
}

void ProximityExplode(entity this)
{
	T_RadiusDamage(this, this.owner, 95, NULL);

	te_explosion(this.origin);

	BecomeExplosion(this);
}

//MED 10/31/96
/*
================
ProximityGrenadeExplode
================
*/
void ProximityGrenadeExplode(entity this, entity inflictor, entity attacker)
{
	this.takedamage = DAMAGE_NO;
	this.realowner.NumProximityGrenades -= 1;
	this.deathtype = "exploding";
	this.nextthink = time + 0.1;
	this.owner = this.lastvictim;
	setthink(this, ProximityExplode);
}

/*
================
ProximityGrenadeTouch
================
*/
void ProximityGrenadeTouch(entity this, entity toucher)
{
	if(toucher == this)
		return;
	if(toucher.classname == this.classname)
		return;
	set_movetype(this, MOVETYPE_TOSS);
	if(this.state == 1)
		return;
	if(vdist(toucher.velocity, >, 0) || toucher.takedamage == DAMAGE_AIM)
	{
		ProximityGrenadeExplode(this, NULL, NULL);
		getthink(this)(this);
		return;
	}
	_sound(this, CH_WEAPON_SINGLE, "weapons/bounce.wav", 1, ATTN_NORM); // bounce sound
	set_movetype(this, MOVETYPE_NONE);
	setsize(this, '-8 -8 -8', '8 8 8');
	this.state = 1;
	this.spawnmaster = toucher;
}

/*
================
ProximityBomb
================
*/
void ProximityBomb(entity this)
{
	if((time > this.delay) || (this.realowner.NumProximityGrenades > 15) || vdist(this.spawnmaster.velocity, >, 0) )
	{
		ProximityGrenadeExplode(this, NULL, NULL);
		getthink(this)(this);
		return;
	}
	this.owner = NULL;
	this.takedamage = DAMAGE_YES;
	entity head = findradius(this.origin, 140);
	bool blowup = false;

	while(head)
	{
		if(head != this && head.health > 0 && (IS_CLIENT(head) || IS_MONSTER(head)) && head.classname != this.classname)
			blowup = true;
		if((head.classname == this.classname) && (head.state == 0))
			blowup = true;
		traceline(this.origin, head.origin, MOVE_NOMONSTERS, this);
		if(trace_fraction != 1.0)
			blowup = false;
		if(blowup)
		{
			_sound(this, CH_WEAPON_SINGLE, "hipweap/proxwarn.wav", 1, ATTN_NORM);
			ProximityGrenadeExplode(this, NULL, NULL);
			this.nextthink = time + 0.5;
			return;
		}
		head = head.chain;
	}
	this.nextthink = time + 0.25;
}

/*
================
W_FireProximityGrenade
================
*/
void W_FireProximityGrenade(entity this)
{
	this.NumProximityGrenades += 1;
	this.currentammo = this.ammo_rockets = this.ammo_rockets - 1;

	_sound(this, CH_WEAPON_SINGLE, "hipweap/proxbomb.wav", 1, ATTN_NORM);

	this.punchangle_x = -2;

	entity missile = spawn();
	missile.owner = missile.realowner = this;
	missile.lastvictim = this;
	set_movetype(missile, MOVETYPE_TOSS);
	missile.solid = SOLID_BBOX;
	missile.classname = "proximity_grenade";
	missile.takedamage = DAMAGE_NO;
	missile.health = 5;
	missile.state = 0;

// set missile speed

	makevectors(this.v_angle);

	if(this.v_angle_x)
		missile.velocity = v_forward * 600 + v_up * 200 + crandom() * v_right * 10 + crandom() * v_up * 10;
	else
	{
		missile.velocity = qc_aim(this, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '100 600 100';

	missile.angles = vectoangles(missile.velocity);

	settouch(missile, ProximityGrenadeTouch);

// set missile duration
	missile.nextthink = time + 2;
	missile.delay = time + 15 +(10*random());
	setthink(missile, ProximityBomb);
	missile.th_die = ProximityGrenadeExplode;

	_setmodel(missile, "progs/proxbomb.mdl");
	setorigin(missile, this.origin);
	setsize(missile, '-1 -1 -1', '1 1 1');
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

void superspike_touch(entity this, entity toucher)
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
		spawn_touchblood(this, 18, toucher);
		T_Damage(toucher, this, this.owner, 18);
	}
	else
		te_superspike(this.origin);

	delete(this);

}

// impel weapon code

void T_SpearTouch(entity this, entity toucher);
void SpearThink(entity this);
void Spear_Bounce_Think(entity this);
void SpearExplosion(entity this);
void SpearDig(entity this);

void W_FireSpear(entity this)
{
	this.currentammo = this.ammo_rockets = this.ammo_rockets - 1;
	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	missile.classname = "spear";
	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 2000);
	missile.velocity = missile.velocity * 2000;
	missile.angles = vectoangles(missile.velocity);
	missile.movedir = missile.velocity;
	missile.avelocity_z = crandom() * 500;
	missile.count = 0;
	settouch(missile, T_SpearTouch);
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);
	_setmodel(missile, "progs/impaler.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, this.origin + (v_forward * 8) + '0 0 16');
	if(IS_ONGROUND(this))
	{
		UNSET_ONGROUND(this);
		setorigin(this, this.origin + '0 0 1');
	}
	this.velocity = this.velocity - (v_forward * (600 - this.armorvalue)) + '0 0 50';
	this.punchangle_x = -10;
}

void T_SpearTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	float knockback;
	float r = random();
	if(toucher.takedamage && (IS_CLIENT(toucher) || IS_MONSTER(toucher)))
	{
		_setmodel(this, "progs/impstuck.mdl");
		if(IS_CLIENT(toucher))
			knockback = 400 - (toucher.armorvalue * 3);
		else if(toucher.monsterdef == MON_ROTTWEILER)
			knockback = 550;
		else if(toucher.monsterdef == MON_ZOMBIE)
			knockback = 250;
		else if(toucher.monsterdef == MON_GRUNT)
			knockback = 450;
		else if(toucher.monsterdef == MON_KNIGHT || toucher.monsterdef == MON_DARK_KNIGHT)
			knockback = 250;
		else if(toucher.monsterdef == MON_ENFORCER || toucher.monsterdef == MON_LIGHTNING_ENFORCER)
			knockback = 300;
		else if(toucher.monsterdef == MON_OGRE)
			knockback = 100;
		else if(toucher.monsterdef == MON_HELL_KNIGHT)
			knockback = 150;
		else if(toucher.monsterdef == MON_GRENLING)
			knockback = 550;
		else if(toucher.monsterdef == MON_VORE)
			knockback = 100;
		else
			knockback = 0;
		if(knockback > 10)
		{
			if(IS_ONGROUND(toucher))
			{
				UNSET_ONGROUND(toucher);
				setorigin(toucher, toucher.origin + '0 0 1');
			}
			makevectors(this.angles);
			toucher.velocity = toucher.velocity + v_forward * knockback;
			toucher.velocity_z = toucher.velocity_z + knockback / 2;
		}
	}
	if(toucher.takedamage 
		&& (toucher.monsterdef == MON_JUGGERNAUT
			|| toucher.monsterdef == MON_CHTHON || toucher.monsterdef == MON_SHUB || toucher.monsterdef == MON_LEGOND 
			|| toucher.monsterdef == MON_KNIGHT || toucher.monsterdef == MON_DARK_KNIGHT || toucher.monsterdef == MON_HELL_KNIGHT || toucher.monsterdef == MON_SHAMBLER) 
			|| (IS_PLAYER(toucher) && toucher.armorvalue > 1))
	{
		_setmodel(this, "progs/impdef.mdl");
		T_Damage(toucher, this, this.owner, 50);
		if(r < 0.4)
			_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impdef1.wav", 1, ATTN_NORM);
		else if(r < 0.7)
			_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impdef2.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impdef3.wav", 1, ATTN_NORM);
		if(toucher.health > 0)
			T_Damage(toucher, this, this.owner, 50);
		set_movetype(this, MOVETYPE_BOUNCE);
		this.velocity = this.velocity * 0.35;
		this.avelocity = '300 300 300';
		this.solid = SOLID_NOT;
		setsize(this, '0 0 0', '0 0 0');
		setthink(this, Spear_Bounce_Think);
		this.nextthink = time + 0.5;
		this.count = time + 3;
	}
	else if(((toucher.monsterdef == MON_GRUNT || toucher.monsterdef == MON_SCRAG || toucher.monsterdef == MON_ROTTWEILER) && random() < 0.5) || toucher.monsterdef == MON_ROTFISH)
	{
		T_Damage (toucher, this, this.owner, 5000);
		entity missile = spawn();
		missile.owner = this.owner;
		set_movetype(missile, MOVETYPE_FLYMISSILE);
		missile.solid = SOLID_BBOX;
		missile.classname = "spear";
		makevectors(this.angles);
		missile.velocity = this.movedir;
		missile.angles = vectoangles(missile.velocity);
		missile.movedir = missile.velocity;
		missile.avelocity_z = crandom() * 500;
		missile.count = 0;
		settouch(missile, T_SpearTouch);
		toucher.nextthink = time + 4;
		setthink(toucher, SUB_Remove);
		_setmodel(missile, "progs/impstuck.mdl");
		setsize(missile, '0 0 0', '0 0 0');
		setorigin(missile, this.origin + v_forward);
		delete(this);
	}
	else if(toucher.takedamage && (IS_CLIENT(toucher) || IS_MONSTER(toucher)) && toucher.armorvalue == 0 && 
		(IS_PLAYER(toucher) || toucher.monsterdef == MON_ENFORCER || toucher.monsterdef == MON_LIGHTNING_ENFORCER 
		|| toucher.monsterdef == MON_OGRE || toucher.monsterdef == MON_FIEND 
		|| toucher.monsterdef == MON_BLUD || toucher.monsterdef == MON_GRENLING
		|| toucher.monsterdef == MON_GRUNT || toucher.monsterdef == MON_ROTTWEILER || toucher.monsterdef == MON_SCRAG || toucher.classname == "wall_explode"))
	{
		_setmodel(this, "progs/impstuck.mdl");
		_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impale.wav", 1, ATTN_NORM);
		if(IS_PLAYER(toucher) || toucher.monsterdef == MON_ENFORCER || toucher.monsterdef == MON_LIGHTNING_ENFORCER)
		{
			BecomeBloodSpurt(this, 25);
			T_Damage(toucher, this, this.owner, 25);
			BecomeBloodSpurt(this, 25);
		}
		if(!(toucher.monsterdef == MON_GRENLING || toucher.monsterdef == MON_GRUNT 
				|| toucher.monsterdef == MON_ROTTWEILER || toucher.monsterdef == MON_SCRAG || toucher.monsterdef == MON_ROTFISH))
		{
			BecomeBloodSpurt(this, 25);
			T_Damage(toucher, this, this.owner, 25);
			BecomeBloodSpurt(this, 25);
		}
		this.enemy = toucher;
		this.cnt = this.enemy.health;
		set_movetype(this, MOVETYPE_NONE);
		this.solid = SOLID_NOT;
		setorigin(this, this.origin + normalize(this.velocity) * 30);
		this.v_angle = this.angles - this.enemy.angles;
		this.mangle = this.origin - this.enemy.origin;
		this.mangle_x = this.mangle_x * 0.05;
		this.mangle_y = this.mangle_y * 0.05;
		this.mangle_z = this.mangle_z * 0.1 + 10;
		setthink(this, SpearThink);
		this.nextthink = time + 0.1;
		if(toucher.monsterdef == MON_GRENLING || toucher.monsterdef == MON_GRUNT 
			|| toucher.monsterdef == MON_ROTTWEILER || toucher.monsterdef == MON_SCRAG || toucher.monsterdef == MON_ROTFISH)
		{
			T_Damage (toucher, this, this.owner, 5000);
			BecomeBloodSpurt(this, 5000);
		}
	}
	else if(toucher.takedamage)
	{
		_setmodel(this, "progs/impdef.mdl");
		_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impale.wav", 1, ATTN_NORM);
		T_Damage (toucher, this, this.owner, 50);
		BecomePurpleExplosion(this, toucher, 50);
		if(r < 0.4)
			_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impdef1.wav", 1, ATTN_NORM);
		else if(r < 0.7)
			_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impdef2.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impdef3.wav", 1, ATTN_NORM);
		BecomePurpleExplosion(this, toucher, 50);
		set_movetype(this, MOVETYPE_BOUNCE);
		this.velocity = this.velocity * 0.05;
		this.avelocity = '300 300 300';
		this.solid = SOLID_NOT;
		setsize(this, '0 0 0', '0 0 0');
		setthink(this, Spear_Bounce_Think);
		this.nextthink = time + 0.5;
		this.count = time + 3;
	}
	else if(toucher.solid == SOLID_BSP || toucher.move_movetype == MOVETYPE_PUSH || IS_CLIENT(toucher) || IS_MONSTER(toucher))
	{
		_setmodel(this, "progs/impwall.mdl");
		BecomePurpleExplosion(this, toucher, 50);
		_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impwall.wav", 1, ATTN_NORM);
		BecomePurpleExplosion(this, toucher, 50);
		set_movetype(this, MOVETYPE_BOUNCE);
		this.velocity = this.velocity * 0.35;
		this.avelocity = '300 300 300';
		this.solid = SOLID_NOT;
		setsize(this, '0 0 0', '0 0 0');
		setthink(this, Spear_Bounce_Think);
		this.nextthink = time + 0.5;
		this.count = time + 3;
	}
	else
	{
		_setmodel(this, "progs/impwall.mdl");
		_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impwall.wav", 1, ATTN_NORM);
		BecomePurpleExplosion(this, toucher, 50);
		makevectors(this.angles);
		setorigin(this, this.origin + normalize(this.velocity) * -4);
		set_movetype(this, MOVETYPE_NONE);
		this.solid = SOLID_NOT;
		this.nextthink = time + 0.1;
		setthink(this, SpearDig);
	}
}

void SpearDig3(entity this)
{
	float r = random();
	this.nextthink = time + r + 1;
	setthink(this, SpearExplosion);
	BecomePurpleExplosion(this, NULL, 0);
	if(r < 0.3)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft1.wav", 1, ATTN_NORM);
	else if(r < 0.6)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft2.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft3.wav", 1, ATTN_NORM);
	BecomePurpleExplosion(this, NULL, 0);
}

void SpearDig2(entity this)
{
	float r = random();
	this.nextthink = time + r;
	setthink(this, SpearDig3);
	BecomePurpleExplosion(this, NULL, 0);
	if(r < 0.3)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft1.wav", 1, ATTN_NORM);
	else if(r < 0.6)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft2.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft3.wav", 1, ATTN_NORM);
	BecomePurpleExplosion(this, NULL, 0);
}

void SpearDig(entity this)
{
	float r = random();
	this.nextthink = time + r;
	setthink(this, SpearDig2);
	BecomePurpleExplosion(this, NULL, 0);
	if(r < 0.3)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft1.wav", 1, ATTN_NORM);
	if(r < 0.6)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft2.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft3.wav", 1, ATTN_NORM);
	BecomePurpleExplosion(this, NULL, 0);
}
void ThrowHead(entity this, string gibname, float dm);

void ImpaledGibs(entity this)
{
	ThrowHead(this, "progs/gib3.mdl", this.health);
	ThrowGib(this, "progs/gib2.mdl", this.health);
	ThrowGib(this, "progs/gib2.mdl", this.health);
	ThrowGib(this, "progs/gib1.mdl", this.health);
	ThrowGib(this, "progs/rawbone.mdl", this.health);
	ThrowGib(this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, "progs/rawbone2.mdl", this.health);
	if(IS_PLAYER(this))
		this.impaled = false;
}

void ImpaledExplosion(entity this)
{
	if(this.enemy.health <= 0)
	{
		T_RadiusDamage(this, this.owner, 60, NULL);
		BecomeBloodSpurt(this, 60);
		this.enemy.health = this.enemy.health - 60 - random() * 100;
		setorigin(this, this.origin - 8 * normalize(this.velocity));
		setthink(this.enemy, ImpaledGibs);
		this.enemy.nextthink = time;
		_sound(this.enemy, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		BecomeBloodSpurt(this, 60);
		_sound(this.enemy, CHAN_BODY, "weapons/impaler/impex.wav", 1, ATTN_NORM);
	}
	te_explosion(this.origin);
	BecomeExplosion(this);
}

void SpearExplosion(entity this)
{
	T_RadiusDamage(this, this.owner, 60, NULL);
	setorigin(this, this.origin - 16 * normalize(this.velocity));
	te_explosion(this.origin);
	BecomeExplosion(this);
}

void SpearGo3(entity this)
{
	float r = random();
	BecomeBloodSpurt(this, 0);
	this.nextthink = time + r + 1;
	BecomeBloodSpurt(this, 0);
	setthink(this, ImpaledExplosion);
	BecomePurpleExplosion(this, NULL, 0);
	if(r < 0.3)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft1.wav", 1, ATTN_NORM);
	else if((r < 0.6))
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft2.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft3.wav", 1, ATTN_NORM);
	BecomePurpleExplosion(this, NULL, 0);
}

void SpearGo2(entity this)
{
	float r = random();
	BecomeBloodSpurt(this, 0);
	this.nextthink = time + 1 + r;
	BecomeBloodSpurt(this, 0);
	setthink(this, SpearGo3);
	BecomePurpleExplosion(this, NULL, 0);
	if(r < 0.3)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft1.wav", 1, ATTN_NORM);
	else if(r < 0.6)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft2.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft3.wav", 1, ATTN_NORM);
	BecomePurpleExplosion(this, NULL, 0);
}

void SpearGo(entity this)
{
	float r = random();
	BecomeBloodSpurt(this, 0);
	this.nextthink = time + 1 + r;
	BecomeBloodSpurt(this, 0);
	setthink(this, SpearGo2);
	BecomePurpleExplosion(this, NULL, 0);
	if(r < 0.3)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft1.wav", 1, ATTN_NORM);
	else if(r < 0.6)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft2.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft3.wav", 1, ATTN_NORM);
	BecomePurpleExplosion(this, NULL, 0);
}

void SpearThink(entity this)
{
	setorigin(this, this.enemy.origin + this.mangle);
	this.angles = this.enemy.angles + this.v_angle;
	if(IS_CLIENT(this.enemy) || this.enemy.monsterdef == MON_ENFORCER || IS_PLAYER(this.enemy) || this.enemy.monsterdef == MON_LIGHTNING_ENFORCER)
	{
		if(!(this.flags & FL_NOTARGET))
		{
			makevectors(this.angles);
			traceline(this.origin + v_forward * 20, this.origin, true, this);
			if(trace_startsolid)
			{
				this.classname = "impaler";
				this.enemy.health = 1;
				BecomeBloodSpurt(this, 15);
				T_Damage(this.enemy, this, this.owner, 15);
				BecomeBloodSpurt(this, 15);
				entity fork = spawn();
				fork.solid = SOLID_NOT;
				setorigin(fork, this.origin - v_forward * 10);
				fork.nextthink = time;
				setthink(fork, func_null);
				this.solid = SOLID_NOT;
				this.nextthink = time + 0.1;
				setthink(this, SpearGo);
				return;
			}
		}
	}
	if(IS_ONGROUND(this.enemy) && !(this.flags & FL_NOTARGET))
	{
		this.flags = FL_NOTARGET;
		BecomeBloodSpurt(this, 37);
		T_Damage(this.enemy, this, this.owner, 37);
		BecomeBloodSpurt(this, 37);
	}
	if(this.enemy.health <= 0 || this.enemy.health > this.cnt || random() < 0.01)
	{
		set_movetype(this, MOVETYPE_BOUNCE);
		this.velocity = this.velocity * 0.05;
		this.avelocity = '300 300 300';
		this.solid = SOLID_NOT;
		setsize(this, '0 0 0', '0 0 0');
		setthink(this, Spear_Bounce_Think);
		this.nextthink = time + 0.5;
		this.count = time + 3;
		return;
	}
	this.cnt = this.enemy.health;
	this.count = this.count + 1;
	if((random() * 10) < this.count)
	{
		SpawnBlood(this.origin, '0 0 0', this.count, this.enemy);
		BecomeBloodSpurt(this, this.count / 2);
		T_Damage(this.enemy, this, this.owner, this.count / 2);
		if(this.enemy.health <= 5 && IS_PLAYER(this.enemy))
			T_Damage(this.enemy, this, this.owner, 5);
		BecomeBloodSpurt(this, this.count / 2);
		this.count = 0;
	}
	this.nextthink = time + 0.1;
}

void Spear_Bounce_Think(entity this)
{
	if(this.velocity == '0 0 0' || this.count < time)
		delete(this);
	else
		this.nextthink = time + 0.1;
}
void DeathSound(entity this);

void impale(entity this)
{
	if(this.monsterdef == MON_ENFORCER || this.monsterdef == MON_LIGHTNING_ENFORCER)
	{
		_sound(this, CHAN_BODY, "player/udeath.wav", 1, ATTN_NORM);
		BecomeBloodSpurt(this, 0);
		_sound(this, CHAN_ITEM, "weapons/impaler/mimpale.wav", 1, ATTN_NORM);
		BecomeBloodSpurt(this, 0);
		set_movetype(this, MOVETYPE_NONE);
		this.solid = SOLID_NOT;
		setthink(this, func_null);
		this.ammo_shells = 5;
		DropBackpack(this);
		if(random() < 0.2)
			this.frame = 83;
		else if(random() < 0.4)
			this.frame = 79;
		else if(random() < 0.6)
			this.frame = 80;
		else if(random() < 0.8)
			this.frame = 78;
		else
			this.frame = 84;
	}
	else
	{
		if(this.classname == "player")
		{
			this.impaled = true;
			this.powerups &= ~POWERUP_INVISIBILITY;
			this.invisible_finished = 0;
			this.invincible_finished = 0;
			this.super_damage_finished = 0;
			this.radsuit_finished = 0;
			this.modelindex = this.modelindex_player;
			if(deathmatch || coop)
				DropBackpack(this);
			this.weaponmodel = string_null;
			this.view_ofs = '0 0 -4';
			this.nextthink = -1;
			this.deadflag = DEAD_DEAD;
			this.solid = SOLID_NOT;
			UNSET_ONGROUND(this);
			set_movetype(this, MOVETYPE_NONE);
			BecomeBloodSpurt(this, 0);
			DeathSound(this);
			BecomeBloodSpurt(this, 0);
			_sound(this, CHAN_ITEM, "weapons/impaler/pimpale.wav", 1, ATTN_NORM);
			BecomeBloodSpurt(this, 0);
			this.angles_x = this.angles_z = 0;
			if(this.weapon == WEP_AXE)
			{
				if(random() < 0.3)
					this.frame = 31;
				else if(random() < 0.6)
					this.frame = 35;
				else
					this.frame = 42;
			}
			else if(random() < 0.3)
				this.frame = 61;
			else if(random() < 0.6)
				this.frame = 71;
			else
				this.frame = 87;
		}
	}
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
		case WEP_NAPALM:
		{
			this.currentammo = this.ammo_rockets;
			this.weaponmodel = "progs/v_srock.mdl";
			this.items |= IT_ROCKETS;
			break;
		}
		case WEP_LIGHTME:
		{
			this.currentammo = this.ammo_cells;
			this.weaponmodel = "progs/v_light2.mdl";
			this.items |= IT_CELLS;
			break;
		}
		case WEP_SPEAR:
		{
			this.currentammo = this.ammo_rockets;
			this.weaponmodel = "progs/v_implr.mdl";
			this.items |= IT_ROCKETS;
			break;
		}
	#if 0
		case WEP_PULSERIFLE:
		{
			this.currentammo = this.ammo_cells;
			this.weaponmodel = "progs/null.mdl"; // TODO?!
			this.items |= IT_CELLS;
			break;
		}
	#endif
		case WEP_AXE:
		{
			this.currentammo = 0;
			this.weaponmodel = "progs/v_axe.mdl";
			break;
		}
		case WEP_GRAPPLE:
		{
			this.currentammo = 0;
			this.weaponmodel = "progs/v_grpple.mdl";
			break;
		}
		case WEP_SHOTGUN:
		{
			this.currentammo = this.ammo_shells;
			this.weaponmodel = "progs/v_shot.mdl";
			this.items |= IT_SHELLS;
			break;
		}
		case WEP_SUPER_SHOTGUN:
		{
			this.currentammo = this.ammo_shells;
			this.weaponmodel = "progs/v_shot2.mdl";
			this.items |= IT_SHELLS;
			break;
		}
		case WEP_LAVA_NAILGUN:
		{
			this.currentammo = this.ammo_lava_nails;
			this.weaponmodel = "progs/v_lava.mdl";
			this.items |= IT_LAVA_NAILS;
			break;
		}
		case WEP_LAVA_SUPER_NAILGUN:
		{
			this.currentammo = this.ammo_lava_nails;
			this.weaponmodel = "progs/v_lava2.mdl";
			this.items |= IT_LAVA_NAILS;
			break;
		}
		case WEP_MULTI_GRENADE:
		{
			this.currentammo = this.ammo_multi_rockets;
			this.weaponmodel = "progs/v_multi.mdl";
			this.items |= IT_MULTI_ROCKETS;
			break;
		}
		case WEP_MULTI_ROCKET:
		{
			this.currentammo = this.ammo_multi_rockets;
			this.weaponmodel = "progs/v_multi2.mdl";
			this.items |= IT_MULTI_ROCKETS;
			break;
		}
		case WEP_PLASMA_GUN:
		{
			this.currentammo = this.ammo_plasma;
			this.weaponmodel = "progs/v_plasma.mdl";
			this.items |= IT_PLASMA_AMMO;
			break;
		}
		case WEP_NAILGUN:
		{
			this.currentammo = this.ammo_nails;
			this.weaponmodel = "progs/v_nail.mdl";
			this.items |= IT_NAILS;
			break;
		}
		case WEP_SUPER_NAILGUN:
		{
			this.currentammo = this.ammo_nails;
			this.weaponmodel = "progs/v_nail2.mdl";
			this.items |= IT_NAILS;
			break;
		}
		case WEP_GRENADE_LAUNCHER:
		{
			this.currentammo = this.ammo_rockets;
			this.weaponmodel = "progs/v_rock.mdl";
			this.items |= IT_ROCKETS;
			break;
		}
		case WEP_ROCKET_LAUNCHER:
		{
			this.currentammo = this.ammo_rockets;
			this.weaponmodel = "progs/v_rock2.mdl";
			this.items |= IT_ROCKETS;
			break;
		}
		case WEP_LIGHTNING:
		{
			this.currentammo = this.ammo_cells;
			this.weaponmodel = "progs/v_light.mdl";
			this.items |= IT_CELLS;
			break;
		}
		case WEP_LASER_CANNON:
		{
			this.currentammo = this.ammo_cells;
			this.weaponmodel = "progs/v_laserg.mdl";
			this.items |= IT_CELLS;
			break;
		}
		case WEP_MJOLNIR:
		{
			this.currentammo = this.ammo_cells;
			this.weaponmodel = "progs/v_hammer.mdl";
			this.items |= IT_CELLS;
			break;
		}
		case WEP_PROXIMITY_GUN:
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
	int itm = this.weapons;

	// TODO: missing impel weapons!

	// pgm - fix for sandy. will not change to plasma gun
	
//	if(this.waterlevel <= 1 && this.ammo_plasma >= 1 && (it & WEP_PLASMA_GUN))
//		return WEP_PLASMA_GUN;
//	else 
	if(this.waterlevel <= 1 && this.ammo_cells >= 1 && (itm & WEP_LIGHTNING) && except != WEP_LIGHTNING)
		return WEP_LIGHTNING;
	else if(this.ammo_lava_nails >= 2 && (itm & WEP_LAVA_SUPER_NAILGUN) && except != WEP_LAVA_SUPER_NAILGUN)
		return WEP_LAVA_SUPER_NAILGUN;
	else if(this.ammo_cells >= 1 && (itm & WEP_LASER_CANNON) && except != WEP_LASER_CANNON)
		return WEP_LASER_CANNON;
	else if(this.ammo_nails >= 2 && (itm & WEP_SUPER_NAILGUN) && except != WEP_SUPER_NAILGUN)
		return WEP_SUPER_NAILGUN;
	else if(this.ammo_lava_nails >= 1 && (itm & WEP_LAVA_NAILGUN) && except != WEP_LAVA_NAILGUN)
		return WEP_LAVA_NAILGUN;
	else if(this.ammo_shells >= 2 && (itm & WEP_SUPER_SHOTGUN) && except != WEP_SUPER_SHOTGUN)
		return WEP_SUPER_SHOTGUN;
	else if(this.ammo_nails >= 1 && (itm & WEP_NAILGUN) && except != WEP_NAILGUN)
		return WEP_NAILGUN;
	else if(this.ammo_shells >= 1 && (itm & WEP_SHOTGUN) && except != WEP_SHOTGUN)
		return WEP_SHOTGUN;
	else if(itm & WEP_MJOLNIR)
		return WEP_MJOLNIR;
	return WEP_AXE; // just fall back if all else fails
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
			case WEP_LIGHTNING: return (this.ammo_cells >= 1);
			case WEP_SUPER_NAILGUN: return (this.ammo_nails >= 2);
			case WEP_SUPER_SHOTGUN: return (this.ammo_shells >= 2);
			case WEP_NAILGUN: return (this.ammo_nails >= 1);
			case WEP_SHOTGUN: return (this.ammo_shells >= 1);
			case WEP_LAVA_SUPER_NAILGUN: return (this.ammo_lava_nails >= 2);
			case WEP_LAVA_NAILGUN: return (this.ammo_lava_nails >= 1);
			case WEP_PLASMA_GUN: return (this.ammo_plasma >= 1);
			case WEP_MULTI_GRENADE: return (this.ammo_multi_rockets >= 1);
			case WEP_MULTI_ROCKET: return (this.ammo_multi_rockets >= 1);
			case WEP_ROCKET_LAUNCHER: return (this.ammo_rockets >= 1);
			case WEP_GRENADE_LAUNCHER: return (this.ammo_rockets >= 1);
			case WEP_PROXIMITY_GUN: return (this.ammo_rockets >= 1);
			case WEP_LIGHTME: return (this.ammo_cells >= 1);
			case WEP_SPEAR: return (this.ammo_rockets >= 1);
			case WEP_NAPALM: return (this.ammo_rockets >= 1);
			case WEP_PULSERIFLE:
			{
				if(this.items & IT_PULSEPOWER2)
					return (this.ammo_cells >= 4);
				else if(this.items & IT_PULSEPOWER1)
					return (this.ammo_cells >= 3);
				else
					return (this.ammo_cells >= 2);
			}
			case WEP_AXE: case WEP_MJOLNIR: case WEP_GRAPPLE:
			default: return true; // axe and hammer don't use ammo, fallback
		}
	}

	if(MP_IMPEL && this.currentammo < 1 && this.weapon == WEP_SPEAR)
		return NoAmmo(this, doswitch);

	if(this.currentammo > 0)
		return true;

	if(this.weapon == WEP_AXE || this.weapon == WEP_GRAPPLE || this.weapon == WEP_MJOLNIR)
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
void player_axe1(entity this);
void player_axeb1(entity this);
void player_axec1(entity this);
void player_axed1(entity this);
void player_shot1(entity this);
void player_nail1(entity this);
void player_light1(entity this);
void player_rocket1(entity this);
void player_lava_nail1(entity this);
void player_plasma1(entity this); //ooppee addon
//ZOID--
void player_grapple1(entity this);
void player_grapple3(entity this);
//--ZOID

//MED
void player_laser1(entity this);
void player_hammer1(entity this);
void player_mjolnir1(entity this);

void W_FireMultiGrenade(entity this);
void W_FireMultiRocket(entity this);
void W_FirePlasma(entity this); //ooppee addon

// impel
void player_superlight1(entity this);
void player_rifle1(entity this);
void player_shotimp1(entity this);

void RuneApplyBlackNoise(entity who);
float RuneApplyHell(float tvalue, entity who);

void W_Attack(entity this, bool offhand)
{
	if(MP_IMPEL && this.exptime != 0)
		return;
	if(!W_CheckNoAmmo(this, ((offhand) ? WEP_PULSERIFLE : 0), !offhand))
		return;

	makevectors	(this.v_angle);			// calculate forward angle for velocity
	this.show_hostile = time + 1;	// wake monsters up

	if(offhand)
	{
		if(this.weapons & WEP_PULSERIFLE)
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
	float r = random();

	switch(this.weapon)
	{
		case WEP_AXE:
		{
			if(!MP_IMPEL || random() < 0.7)
				_sound(this, CH_WEAPON_SINGLE, "weapons/ax1.wav", 1, ATTN_NORM);
			else
				_sound(this, CH_WEAPON_SINGLE, "zombie/z_shot1.wav", 1, ATTN_NORM);
			if(MP_MG && autocvar_horde && (serverflags & SIGIL_E3)) // horde rune behavior
			{
				if(this.axe_hit_chain >= 2 && time < this.axe_hit_chain_time)
				{
					// vertical CHOP
					if(r < 0.5)
						player_axe1(this);
					else
						player_axec1(this);
					this.attack_finished = time + RuneApplyHell(0.8, this); // long recover
				}
				else
				{
					// diagonal SWEEP
					if(r < 0.5)
						player_axeb1(this);
					else
						player_axed1(this);
					
					if(this.axe_hit_chain > 1)
						this.attack_finished = time + RuneApplyHell(0.6, this);
					else
						this.attack_finished = time + RuneApplyHell(0.4, this);
						
				}
			}
			else
			{
				if(r < 0.25)
					player_axe1(this);
				else if(r<0.5)
					player_axeb1(this);
				else if(r<0.75)
					player_axec1(this);
				else
					player_axed1(this);
				float fire_delay = 0.5;
				if(MP_IMPEL && random() < 0.5)
					fire_delay = 0.4;
				this.attack_finished = time + RuneApplyHell(fire_delay, this);
			}
			break;
		}
		case WEP_GRAPPLE:
		{
			if(!this.hook_out)
				player_grapple1(this);
			else
				player_grapple3(this);
			this.attack_finished = time + 0.1;
			break;
		}
		case WEP_SHOTGUN:
		{
			player_shot1(this);
			W_FireShotgun(this);
			this.attack_finished = time + RuneApplyHell(0.5, this);
			break;
		}
		case WEP_SUPER_SHOTGUN:
		{
			player_shot1(this);
			W_FireSuperShotgun(this);
			this.attack_finished = time + RuneApplyHell(0.7, this);
			break;
		}
		case WEP_LAVA_NAILGUN:
		{
			this.lavaGunFired = true;
			player_lava_nail1(this);
			break;
		}
		case WEP_LAVA_SUPER_NAILGUN:
		{
			this.lavaGunFired = true;
			player_lava_nail1(this);
			break;
		}
		case WEP_MULTI_GRENADE:
		{
			player_rocket1(this);
			W_FireMultiGrenade(this);
			this.attack_finished = time + RuneApplyHell(0.6, this);
			break;
		}
		case WEP_MULTI_ROCKET:
		{
			player_rocket1(this);
			W_FireMultiRocket(this);
			this.attack_finished = time + RuneApplyHell(0.8, this);
			break;
		}
		case WEP_PLASMA_GUN:
		{
			// player_light1 determines choice of W_FireLightning 
			//      or W_FirePlasma, but same lighting and frames...
			//this.attack_finished = time + RuneApplyHell(1.0, this);//ooppee edited line out
			//player_light1(this);//ooppee edited line out
			player_plasma1(this); //ooppee added
			W_FirePlasma(this); //ooppee added
			this.attack_finished = time + RuneApplyHell(1.0, this); //ooppee added (same as above code but needs to be executed AFTER)
			break;
		}
		case WEP_NAILGUN:
		{
			player_nail1(this);
			break;
		}
		case WEP_SUPER_NAILGUN:
		{
			player_nail1(this);
			break;
		}
		case WEP_GRENADE_LAUNCHER:
		{
			player_rocket1(this);
			W_FireGrenade(this);
			this.attack_finished = time + RuneApplyHell(0.6, this);
			break;
		}
		case WEP_ROCKET_LAUNCHER:
		{
			player_rocket1(this);
			W_FireRocket(this);
			this.attack_finished = time + RuneApplyHell(0.8, this);
			break;
		}
		case WEP_LIGHTNING:
		{
			player_light1(this);
			this.attack_finished = time + 0.1;
			_sound(this, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
			break;
		}
		case WEP_LASER_CANNON:
		{
			player_laser1(this);
			break;
		}
		case WEP_MJOLNIR:
		{
			if(this.ammo_cells < 30)
				player_hammer1(this);
			else
				player_mjolnir1(this);
			this.attack_finished = time + 0.8;
			break;
		}
		case WEP_PROXIMITY_GUN:
		{
			player_rocket1(this);
			W_FireProximityGrenade(this);
			this.attack_finished = time + 0.6;
			break;
		}
		case WEP_NAPALM:
		{
			if(this.cnt < 3)
			{
				player_rocket1(this);
				W_FireNapalm(this);
				this.attack_finished = time + 0.6;
				this.cnt += 1;
			}
			else
			{
				_sound(this, CH_WEAPON_SINGLE, "weapons/pkup.wav", 1, ATTN_NORM);
				this.attack_finished = time + 0.9;
				this.cnt = 0;
			}
			break;
		}
		case WEP_LIGHTME:
		{
			player_superlight1(this);
			if(this.ammo_cells < 1)
			{
				this.ammo_cells = 0;
				W_SetCurrentAmmo(this);
			}
			break;
		}
		case WEP_SPEAR:
		{
			player_shotimp1(this);
			this.attack_finished = time + 1;
			break;
		}
	}
}

/*
============
W_ChangeWeapon

============
*/
void W_ChangeWeapon(entity this, int imp)
{
	bool am = false;
	int fl = this.weapon;

	switch(imp)
	{
		case 1:
		{
			if(this.weapon == WEP_AXE && teamplay >= TEAM_CTF)
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
			if((this.weapons & WEP_LAVA_NAILGUN) && (this.weapon == WEP_NAILGUN || this.ammo_nails < 1))
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
			if((this.weapons & WEP_LAVA_SUPER_NAILGUN) && (this.weapon == WEP_SUPER_NAILGUN || this.ammo_nails < 2))
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
			if((this.weapons & WEP_MULTI_GRENADE) && (this.weapon == WEP_GRENADE_LAUNCHER || this.ammo_rockets < 1))
			{
				fl = WEP_MULTI_GRENADE;
				if(this.ammo_multi_rockets < 1)
					am = true;
				break; // prefer multi grenade
			}
			if((this.weapons & WEP_PROXIMITY_GUN) && ((this.weapon == WEP_GRENADE_LAUNCHER && !(this.weapons & WEP_MULTI_GRENADE)) || this.weapon == WEP_MULTI_GRENADE || !(this.weapons & WEP_GRENADE_LAUNCHER)))
				fl = WEP_PROXIMITY_GUN;
			else if((this.weapons & WEP_NAPALM) && 
					((this.weapon == WEP_GRENADE_LAUNCHER && !(this.weapons & WEP_PROXIMITY_GUN) && !(this.weapons & WEP_MULTI_GRENADE)) || this.weapon == WEP_PROXIMITY_GUN || !(this.weapons & WEP_GRENADE_LAUNCHER)))
				fl = WEP_NAPALM;
			else
				fl = WEP_GRENADE_LAUNCHER;
			if(this.ammo_rockets < 1)
				am = true;
			break;
		}
		case 7:
		{
			if((this.weapons & WEP_MULTI_ROCKET) && (this.weapon == WEP_ROCKET_LAUNCHER || this.ammo_rockets < 1 || !(this.weapons & WEP_ROCKET_LAUNCHER)))
			{
				fl = WEP_MULTI_ROCKET;
				if(this.ammo_multi_rockets < 1)
					am = true;
			}
			else
			{
				if((this.weapons & WEP_SPEAR) && ((this.weapon == WEP_ROCKET_LAUNCHER && !(this.weapons & WEP_MULTI_ROCKET)) || this.weapon == WEP_MULTI_ROCKET || !(this.weapons & WEP_ROCKET_LAUNCHER)))
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
			if((this.weapons & WEP_PLASMA_GUN) && (this.weapon == WEP_LIGHTNING || this.ammo_cells < 1))
			{
				fl = WEP_PLASMA_GUN;
				if(this.ammo_plasma < 1)
					am = true;
			}
			else
			{
				float needed_cells = 1;
				if((this.weapons & WEP_LIGHTME) && ((this.weapon == WEP_LIGHTNING && !(this.weapons & WEP_PLASMA_GUN)) || this.weapon == WEP_PLASMA_GUN || !(this.weapons & WEP_LIGHTNING)))
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
			if((this.weapons & WEP_PULSERIFLE) && this.weapon != WEP_PULSERIFLE)
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
			if((this.weapons & WEP_MJOLNIR) || !(deathmatch && teamplay >= TEAM_CTF))
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
	
	if(!(this.weapons & fl))
	{	// don't have the weapon
		sprint(this, "no weapon.\n");
		return;
	}
	
	if(am)
	{	// don't have the ammo
		sprint(this, "not enough ammo.\n");
		return;
	}

//
// set weapon, set ammo
//
	W_SwitchWeapon(this, fl);
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
	this.weapons |= 
		(WEP_AXE |
		WEP_SHOTGUN |
		WEP_SUPER_SHOTGUN |
		WEP_NAILGUN |
		WEP_SUPER_NAILGUN |
		WEP_GRENADE_LAUNCHER |
		WEP_ROCKET_LAUNCHER);
	//this.items |= (IT_KEY1 | IT_KEY2); // breaks levels

	// mal: also give full armor...
	this.armortype = 0.8;
	this.armorvalue = 200;
	this.items &= ~(IT_ARMOR1 | IT_ARMOR2);
	this.items |= IT_ARMOR3;

	this.weapons |= WEP_LIGHTNING;
	if(MP_HIPNOTIC)
		this.weapons |= (WEP_LASER_CANNON | WEP_MJOLNIR | WEP_PROXIMITY_GUN);
	if(MP_ROGUE)
	{
		this.weapons |= (WEP_LAVA_NAILGUN | WEP_LAVA_SUPER_NAILGUN | WEP_MULTI_GRENADE | WEP_MULTI_ROCKET | WEP_PLASMA_GUN);
		this.ammo_lava_nails = 200;
		this.ammo_multi_rockets = 100;
		this.ammo_plasma = 100;
	}
	if(MP_IMPEL)
		this.weapons |= (WEP_LIGHTME | WEP_NAPALM | WEP_PULSERIFLE | WEP_SPEAR);

	if(MP_IMPEL)
		W_SwitchWeapon(this, WEP_GRENADE_LAUNCHER);
	else
		W_SwitchWeapon(this, WEP_ROCKET_LAUNCHER);
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
			case WEP_MJOLNIR:
			{
				this.weapon = WEP_AXE;
				break;
			}
			case WEP_PLASMA_GUN:
			{
				this.weapon = WEP_LIGHTME;
				if(this.ammo_cells < 1)
					am = true;
				break;
			}
			case WEP_AXE:
			{
				if(deathmatch && teamplay >= TEAM_CTF)
					this.weapon = WEP_GRAPPLE;
				else
				{
					this.weapon = WEP_SHOTGUN;
					if(this.ammo_shells < 1)
						am = true;
				}
				break;
			}
			case WEP_GRAPPLE:
			{
				this.weapon = WEP_SHOTGUN;
				if(this.ammo_shells < 1)
					am = true;
				break;
			}
			case WEP_SHOTGUN:
			{
				this.weapon = WEP_SUPER_SHOTGUN;
				if(this.ammo_shells < 2)
					am = true;
				break;
			}		
			case WEP_SUPER_SHOTGUN:
			{
				this.weapon = WEP_NAILGUN;
				if(this.ammo_nails < 1)
					am = true;
				break;
			}
			case WEP_NAILGUN:
			{
				this.weapon = WEP_LAVA_NAILGUN;
				if(this.ammo_lava_nails < 1)
					am = true;
				break;
			}
			case WEP_LAVA_NAILGUN:
			{
				this.weapon = WEP_SUPER_NAILGUN;
				if(this.ammo_nails < 2)
					am = true;
				break;
			}
			case WEP_SUPER_NAILGUN:
			{
				this.weapon = WEP_LAVA_SUPER_NAILGUN;
				if(this.ammo_lava_nails < 2)
					am = true;
				break;
			}
			case WEP_LAVA_SUPER_NAILGUN:
			{
				this.weapon = WEP_GRENADE_LAUNCHER;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_GRENADE_LAUNCHER:
			{
				this.weapon = WEP_NAPALM;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_MULTI_GRENADE:
			{
				this.weapon = WEP_ROCKET_LAUNCHER;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_NAPALM:
			{
				this.weapon = WEP_PROXIMITY_GUN;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_PROXIMITY_GUN:
			{
				this.weapon = WEP_MULTI_GRENADE;
				if(this.ammo_multi_rockets < 1)
					am = true;
				break;
			}
			case WEP_ROCKET_LAUNCHER:
			{
				this.weapon = WEP_MULTI_ROCKET;
				if(this.ammo_multi_rockets < 1)
					am = true;
				break;
			}
			case WEP_MULTI_ROCKET:
			{
				this.weapon = WEP_SPEAR;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_SPEAR:
			{
				this.weapon = WEP_LIGHTNING;
				if(this.ammo_cells < 1)
					am = true;
				break;
			}
			case WEP_LIGHTNING:
			{
				this.weapon = WEP_LASER_CANNON;
				if(this.ammo_cells < 1)
					am = true;
				break;
			}
			case WEP_LASER_CANNON:
			{
				this.weapon = WEP_PLASMA_GUN;
				if(this.ammo_plasma < 1)
					am = true;
				break;
			}
			case WEP_LIGHTME:
			{
			#if 0
				this.weapon = WEP_PULSERIFLE;
			#else
				this.weapon = WEP_MJOLNIR;
			#endif
			#if 0
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
			#endif
				break;
			}
		#if 0
			case WEP_PULSERIFLE:
			{
				this.weapon = WEP_MJOLNIR;
				break;
			}
		#endif
		}
	
		if((this.weapons & this.weapon) && !am)
		{
			this.prevweapon = oldwep;
			W_SetCurrentAmmo(this);
		#if 0
			if(this.weapon == WEP_PULSERIFLE)
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
	int myitems = this.weapons;
	this.impulse = 0;
	int oldwep = this.weapon;

	while(1)
	{
		bool am = false;

		switch(this.weapon)
		{
			case WEP_LIGHTME:
			{
				this.weapon = WEP_PLASMA_GUN;
				if(this.ammo_plasma < 1)
					am = true;
				break;
			}
		#if 0
			case WEP_PULSERIFLE:
			{
				this.weapon = WEP_LIGHTME;
				if(this.ammo_cells < 1)
					am = true;
				break;
			}
		#endif
			case WEP_MJOLNIR:
			{
			#if 0
				this.weapon = WEP_PULSERIFLE;
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
			#else
				this.weapon = WEP_LIGHTME;
				if(this.ammo_cells < 1)
					am = true;
			#endif
				break;
			}
			case WEP_LASER_CANNON:
			{
				this.weapon = WEP_LIGHTNING;
				if(this.ammo_cells < 1)
					am = true;
				break;
			}
			case WEP_PLASMA_GUN:
			{
				this.weapon = WEP_LASER_CANNON;
				if(this.ammo_cells < 1)
					am = true;
				break;
			}
			case WEP_SPEAR:
			{
				this.weapon = WEP_MULTI_ROCKET;
				if(this.ammo_multi_rockets < 1)
					am = true;
				break;
			}
			case WEP_LIGHTNING:
			{
				this.weapon = WEP_SPEAR;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_MULTI_ROCKET:
			{
				this.weapon = WEP_ROCKET_LAUNCHER;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_ROCKET_LAUNCHER:
			{
				this.weapon = WEP_MULTI_GRENADE;
				if(this.ammo_multi_rockets < 1)
					am = true;
				break;
			}
			case WEP_MULTI_GRENADE:
			{
				this.weapon = WEP_PROXIMITY_GUN;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_NAPALM:
			{
				this.weapon = WEP_GRENADE_LAUNCHER;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_PROXIMITY_GUN:
			{
				this.weapon = WEP_NAPALM;
				if(this.ammo_rockets < 1)
					am = true;
				break;
			}
			case WEP_GRENADE_LAUNCHER:
			{
				this.weapon = WEP_LAVA_SUPER_NAILGUN;
				if(this.ammo_lava_nails < 2)
					am = true;
				break;
			}
			case WEP_LAVA_SUPER_NAILGUN:
			{
				this.weapon = WEP_SUPER_NAILGUN;
				if(this.ammo_nails < 2)
					am = true;
				break;
			}
			case WEP_SUPER_NAILGUN:
			{
				this.weapon = WEP_LAVA_NAILGUN;
				if(this.ammo_lava_nails < 2)
					am = true;
				break;
			}
			case WEP_LAVA_NAILGUN:
			{
				this.weapon = WEP_NAILGUN;
				if(this.ammo_nails < 1)
					am = true;
				break;
			}
			case WEP_NAILGUN:
			{
				this.weapon = WEP_SUPER_SHOTGUN;
				if(this.ammo_shells < 2)
					am = true;
				break;
			}		
			case WEP_SUPER_SHOTGUN:
			{
				this.weapon = WEP_SHOTGUN;
				if(this.ammo_shells < 1)
					am = true;
				break;
			}
			case WEP_SHOTGUN:
			{
				if(deathmatch && teamplay >= TEAM_CTF)
					this.weapon = WEP_GRAPPLE;
				else
					this.weapon = WEP_AXE;
				break;
			}
			case WEP_GRAPPLE:
			{
				this.weapon = WEP_AXE;
				break;
			}
			case WEP_AXE:
			{
				this.weapon = WEP_MJOLNIR;
				break;
			}
		}
	
		if((myitems & this.weapon) && am == false)
		{
			this.prevweapon = oldwep;
			W_SetCurrentAmmo(this);
		#if 0
			if(this.weapon == WEP_PULSERIFLE)
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
	if((this.weapons & this.prevweapon) && this.prevweapon != this.weapon && W_CheckNoAmmo(this, this.prevweapon, false))
		W_SwitchWeapon(this, this.prevweapon);
	else
		W_SwitchWeapon(this, W_BestWeapon(this, this.weapon));
}

int W_GetWeaponImpulse(int imp)
{
	switch(imp)
	{
		default: // default to axe
		case 230: return 1; // blaster -> axe
		case 244: return 14; // tuba -> mjolnir
		case 231: return 2; // shotgun -> shotgun
		case 248: return 67; // shockwave -> spear
		case 232: return 4; // machinegun -> nailgun
		case 233: return 6; // mortar -> grenade launcher
		case 235: return 62; // electro -> multi grenade
		case 234: return 50; // minelayer -> proximity gun
		case 249: return 8; // arc -> lightning gun
		case 238: return 5; // hagar -> super nailgun
		case 243: return 9; // hlac -> lava super nailgun
		case 245: return 61; // rifle -> lava super nailgun
		case 247: return 60; // seeker -> lava nailgun
		case 236: return 3; // crylink -> super shotgun
		case 239: return 7; // devastator -> rocket launcher
		case 246: return 63; // fireball -> multi rocket
		case 242: return 22; // hook -> hook
		//case 240: return 66; // porto -> pulse rifle
		case 237: return 64; // vortex -> plasma gun
		case 241: return 65; // vaporizer -> lg-2 prototype
		case 250: return 68; // napalm (no replacement!)
	}
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
			if(this.weapon == WEP_LAVA_NAILGUN || this.weapon == WEP_LAVA_SUPER_NAILGUN)
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

	if(!(time < this.attack2_finished))
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
