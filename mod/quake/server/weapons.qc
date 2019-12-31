#include "combat.qh"

//#include "ai.qh"
bool visible(entity this, entity targ);

.bool lavaGunFired;

/*
*/
void player_run(entity this);
void T_RadiusDamage(entity bomb, entity attacker, float rad, entity ignore);
void SpawnBlood(vector org, vector vel, float damage);
void SuperDamageSound(entity this);

// called by worldspawn
PRECACHE(Weapons)
{
	precache_sound("weapons/r_exp3.wav");	// new rocket explosion
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

//MED 10/18/96
void spawn_touchblood(entity this, float damage);
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
		spawn_touchblood(this, this.dmg);
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
	this.effects = this.effects | EF_MUZZLEFLASH;
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
			if(!(head.flags & FL_MONSTER) && (IS_MONSTER(head) || IS_CLIENT(head)))
			{
//            if(visible(head) &&(head!=this.owner.owner) &&(head.health>0))
				if((visible(this, head)) &&(head!=this.owner.owner) &&(head.health>0))
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
	//      this.think = HIP_DiversionLightningThink;
	//      this.nextthink = time;
	//		this.delay = time + 0.30;
	//		this.origin = this.owner.origin;
	//		this.think();
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
		if(trace_ent.classname == "monster_zombie")
			damage = 70;
		trace_ent.axhitme = true;
		SpawnBlood(org, v_forward, damage);
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
	if(this.weapon == to_wep)
		return; // don't mess up the system by switching to it again!

	this.prevweapon = this.weapon;
	this.weapon = to_wep;

	W_SetCurrentAmmo(this);
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

	if(trace_ent.takedamage)
	{
		trace_ent.axhitme = true;
		SpawnBlood(org, '0 0 0', 20);
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

	makevectors(this.angles);

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
void SpawnBlood(vector org, vector vel, float damage)
{
	particle(org, vel * 0.1, 73, damage * 2);
}

/*
================
spawn_touchblood
================
*/
void spawn_touchblood(entity this, float damage)
{
	vector vel = wall_velocity(this) * 0.2;
	SpawnBlood(this.origin + vel * 0.01, vel, damage);
}


/*
================
SpawnChunk
================
*/
void SpawnChunk(vector org, vector vel)
{
	particle(org, vel * 0.02, 0, 10);
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

	if(trace_ent.takedamage)
	{
		if(trace_ent.solid != SOLID_BSP) // not on walls (TODO: iscreature field)
			SpawnBlood(org, vel*0.2, damage);
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
	_sound(this, CH_SHOTS, "weapons/r_exp3.wav", 1, ATTN_NORM);
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
		if(toucher.classname == "monster_shambler")
			damg = damg * 0.5;	// mostly immune
		T_Damage(toucher, this, this.owner, damg );
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, 120, toucher);

//	_sound(this, CH_WEAPON_SINGLE, "weapons/r_exp3.wav", 1, ATTN_NORM);
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
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage);
	}
	entity e2 = trace_ent;

	traceline(p1 - f, p2 - f, false, from);
	if(trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage && !trace_ent.wetsuit_finished)
	{
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
	_sound(this, CH_WEAPON_SINGLE, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
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
.int NumProximityGrenades;
.entity realowner; // not lost between attacks
/*
================
ProximityGrenadeExplode
================
*/
void ProximityGrenadeExplode(entity this, entity attacker)
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
		ProximityGrenadeExplode(this, NULL);
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
		ProximityGrenadeExplode(this, NULL);
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
			ProximityGrenadeExplode(this, NULL);
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
	if(toucher.takedamage)
	{
		spawn_touchblood(this, 9);
		T_Damage(toucher, this, this.owner, 9);
	}
	else
	{
		if(this.classname == "wizspike")
			te_wizspike(this.origin);
		else if(this.classname == "knightspike")
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
	if(toucher.takedamage)
	{
		spawn_touchblood(this, 18);
		T_Damage(toucher, this, this.owner, 18);
	}
	else
		te_superspike(this.origin);

	delete(this);

}


/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void W_SetCurrentAmmo(entity this)
{
	player_run(this);		// get out of any weapon firing states

	this.items &= ~(IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS);
	this.items &= ~(IT_LAVA_NAILS | IT_PLASMA_AMMO | IT_MULTI_ROCKETS);
	
	switch(this.weapon)
	{
		case WEP_AXE:
		{
			this.currentammo = 0;
			this.weaponmodel = "progs/v_axe.mdl";
			this.weaponframe = 0;
			break;
		}
		case WEP_GRAPPLE:
		{
			this.currentammo = 0;
			this.weaponmodel = "progs/v_grpple.mdl";
			this.weaponframe = 0;
			break;
		}
		case WEP_SHOTGUN:
		{
			this.currentammo = this.ammo_shells;
			this.weaponmodel = "progs/v_shot.mdl";
			this.weaponframe = 0;
			this.items |= IT_SHELLS;
			break;
		}
		case WEP_SUPER_SHOTGUN:
		{
			this.currentammo = this.ammo_shells;
			this.weaponmodel = "progs/v_shot2.mdl";
			this.weaponframe = 0;
			this.items |= IT_SHELLS;
			break;
		}
		case WEP_LAVA_NAILGUN:
		{
			this.currentammo = this.ammo_lava_nails;
			this.weaponmodel = "progs/v_lava.mdl";
			this.weaponframe = 0;
			this.items |= IT_LAVA_NAILS;
			break;
		}
		case WEP_LAVA_SUPER_NAILGUN:
		{
			this.currentammo = this.ammo_lava_nails;
			this.weaponmodel = "progs/v_lava2.mdl";
			this.weaponframe = 0;
			this.items |= IT_LAVA_NAILS;
			break;
		}
		case WEP_MULTI_GRENADE:
		{
			this.currentammo = this.ammo_multi_rockets;
			this.weaponmodel = "progs/v_multi.mdl";
			this.weaponframe = 0;
			this.items |= IT_MULTI_ROCKETS;
			break;
		}
		case WEP_MULTI_ROCKET:
		{
			this.currentammo = this.ammo_multi_rockets;
			this.weaponmodel = "progs/v_multi2.mdl";
			this.weaponframe = 0;
			this.items |= IT_MULTI_ROCKETS;
			break;
		}
		case WEP_PLASMA_GUN:
		{
			this.currentammo = this.ammo_plasma;
			this.weaponmodel = "progs/v_plasma.mdl";
			this.weaponframe = 0;
			this.items |= IT_PLASMA_AMMO;
			break;
		}
		case WEP_NAILGUN:
		{
			this.currentammo = this.ammo_nails;
			this.weaponmodel = "progs/v_nail.mdl";
			this.weaponframe = 0;
			this.items |= IT_NAILS;
			break;
		}
		case WEP_SUPER_NAILGUN:
		{
			this.currentammo = this.ammo_nails;
			this.weaponmodel = "progs/v_nail2.mdl";
			this.weaponframe = 0;
			this.items |= IT_NAILS;
			break;
		}
		case WEP_GRENADE_LAUNCHER:
		{
			this.currentammo = this.ammo_rockets;
			this.weaponmodel = "progs/v_rock.mdl";
			this.weaponframe = 0;
			this.items |= IT_ROCKETS;
			break;
		}
		case WEP_ROCKET_LAUNCHER:
		{
			this.currentammo = this.ammo_rockets;
			this.weaponmodel = "progs/v_rock2.mdl";
			this.weaponframe = 0;
			this.items |= IT_ROCKETS;
			break;
		}
		case WEP_LIGHTNING:
		{
			this.currentammo = this.ammo_cells;
			this.weaponmodel = "progs/v_light.mdl";
			this.weaponframe = 0;
			this.items |= IT_CELLS;
			break;
		}
		case WEP_LASER_CANNON:
		{
			this.currentammo = this.ammo_cells;
			this.weaponmodel = "progs/v_laserg.mdl";
			this.weaponframe = 0;
			this.items |= IT_CELLS;
			break;
		}
		case WEP_MJOLNIR:
		{
			this.currentammo = this.ammo_cells;
			this.weaponmodel = "progs/v_hammer.mdl";
			this.weaponframe = 0;
			this.items |= IT_CELLS;
			break;
		}
		case WEP_PROXIMITY_GUN:
		{
			this.currentammo = this.ammo_rockets;
			this.weaponmodel = "progs/v_prox.mdl";
			this.weaponframe = 0;
			this.items |= IT_ROCKETS;
			break;
		}
		default:
		{
			this.currentammo = 0;
			this.weaponmodel = "";
			this.weaponframe = 0;
			break;
		}
	}
}

int W_BestWeapon(entity this, int except)
{
	int itm = this.weapons;

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

bool W_CheckNoAmmo(entity this, int forwep)
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
			case WEP_AXE: case WEP_MJOLNIR: case WEP_GRAPPLE:
			default: return true; // axe and hammer don't use ammo, fallback
		}
	}

	if(this.currentammo > 0)
		return true;

	if(this.weapon == WEP_AXE || this.weapon == WEP_GRAPPLE || this.weapon == WEP_MJOLNIR)
		return true;
	
	W_SwitchWeapon(this, W_BestWeapon(this, 0));
	
// drop the weapon down
	return false;
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

void RuneApplyBlackNoise(entity who);
float RuneApplyHell(float tvalue, entity who);

void W_Attack(entity this)
{
	if(!W_CheckNoAmmo(this, 0))
		return;

	makevectors	(this.v_angle);			// calculate forward angle for velocity
	this.show_hostile = time + 1;	// wake monsters up

	RuneApplyBlackNoise(this); // make rune noise

	switch(this.weapon)
	{
		case WEP_AXE:
		{
			_sound(this, CH_WEAPON_SINGLE, "weapons/ax1.wav", 1, ATTN_NORM);
			float r = random();
			if(r < 0.25)
				player_axe1(this);
			else if(r<0.5)
				player_axeb1(this);
			else if(r<0.75)
				player_axec1(this);
			else
				player_axed1(this);
			this.attack_finished = time + RuneApplyHell(0.5, this);
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
	int fl = 0;

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
			if((this.weapons & WEP_PROXIMITY_GUN) && ((this.weapon == WEP_GRENADE_LAUNCHER && !(this.weapons & WEP_MULTI_GRENADE)) || this.weapon == WEP_MULTI_GRENADE))
				fl = WEP_PROXIMITY_GUN;
			else
				fl = WEP_GRENADE_LAUNCHER;
			if(this.ammo_rockets < 1)
				am = true;
			break;
		}
		case 7:
		{
			if((this.weapons & WEP_MULTI_ROCKET) && (this.weapon == WEP_ROCKET_LAUNCHER || this.ammo_rockets < 1))
			{
				fl = WEP_MULTI_ROCKET;
				if(this.ammo_multi_rockets < 1)
					am = true;
			}
			else
			{
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
				fl = WEP_LIGHTNING;
				if(this.ammo_cells < 1)
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
	this.items |= (IT_KEY1 | IT_KEY2);

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

	W_SwitchWeapon(this, WEP_ROCKET_LAUNCHER);
	this.impulse = 0;
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
				this.weapon = WEP_LASER_CANNON;
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
				this.weapon = WEP_PROXIMITY_GUN;
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
				this.weapon = WEP_MJOLNIR;
				break;
			}
		}
	
		if((this.weapons & this.weapon) && am == false)
		{
			this.prevweapon = oldwep;
			W_SetCurrentAmmo(this);
			return;
		}
	}

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
			case WEP_MJOLNIR:
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
			case WEP_PLASMA_GUN:
			{
				this.weapon = WEP_LIGHTNING;
				if(this.ammo_cells < 1)
					am = true;
				break;
			}
			case WEP_LIGHTNING:
			{
				this.weapon = WEP_MULTI_ROCKET;
				if(this.ammo_multi_rockets < 1)
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
			case WEP_PROXIMITY_GUN:
			{
				this.weapon = WEP_GRENADE_LAUNCHER;
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
	this.items |= IT_QUAD;
	bprint("quad cheat\n");
}

void W_LastWeapon(entity this)
{
	if ((this.weapons & this.prevweapon) && this.prevweapon != this.weapon && W_CheckNoAmmo(this, this.prevweapon))
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
		case 231: case 248: return 2; // shotgun, shockwave -> shotgun
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
		case 242: case 240: return 22; // hook, porto -> hook
		case 237: case 241: return 64; // vortex, vaporizer -> plasma gun
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
	bool valid_wep_impulse = (this.impulse >= 1 && (this.impulse <= 9 || (this.impulse >= 230 && this.impulse <= 253) || this.impulse == 50 || this.impulse == 14) || (this.impulse >= 60 && this.impulse <= 64));

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
	if(time < this.attack_finished)
		return;

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
		W_Attack(this);
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
