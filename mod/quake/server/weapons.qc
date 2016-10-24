/*
*/
void T_Damage(entity targ, entity inflictor, entity attacker, float damage);
void player_run(entity this);
void T_RadiusDamage(entity bomb, entity attacker, float rad, entity ignore);
void SpawnBlood(vector org, vector vel, float damage);
void SuperDamageSound(entity this);


// called by worldspawn
void W_Precache()
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

/*
================
W_FireAxe
================
*/
void W_FireAxe(entity this)
{
	vector	source;
	vector	org;

	makevectors(this.v_angle);
	source = this.origin + '0 0 16';
	traceline(source, source + v_forward*64, false, this);
	if(trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward*4;

	if(trace_ent.takedamage)
	{
		trace_ent.axhitme = 1;
		SpawnBlood(org, '0 0 0', 20);
		T_Damage(trace_ent, this, this, 20);
	}
	else
	{	// hit wall
		_sound(this, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord(MSG_BROADCAST, org_x);
		WriteCoord(MSG_BROADCAST, org_y);
		WriteCoord(MSG_BROADCAST, org_z);
	}
}


//============================================================================


vector wall_velocity(entity this)
{
	vector	vel;
	
	vel = normalize(this.velocity);
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
	entity missile, mpuff;
	vector	org;

	missile = spawn();
	missile.owner = this;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors(this.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	setthink(missile, SUB_Remove);

	setmodel(missile, "progs/zom_gib.mdl");
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
	particle(org, vel*0.1, 73, damage*2);
}

/*
================
spawn_touchblood
================
*/
void spawn_touchblood(entity this, float damage)
{
	vector vel = wall_velocity(this) * 0.2;
	SpawnBlood(this.origin + vel*0.01, vel, damage);
}


/*
================
SpawnChunk
================
*/
void SpawnChunk(vector org, vector vel)
{
	particle(org, vel*0.02, 0, 10);
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

void ApplyMultiDamage()
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
		ApplyMultiDamage();
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
	vector	vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;

	if(trace_ent.takedamage)
	{
		SpawnBlood(org, vel*0.2, damage);
		AddMultiDamage(trace_ent, damage);
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord(MSG_BROADCAST, org_x);
		WriteCoord(MSG_BROADCAST, org_y);
		WriteCoord(MSG_BROADCAST, org_z);
	}
}

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void FireBullets(entity this, int shotcount, vector dir, vector spread)
{
	vector direction;
	vector	src;
	
	makevectors(this.v_angle);

	src = this.origin + v_forward*10;
	src_z = this.absmin_z + this.size_z * 0.7;

	ClearMultiDamage();
	while(shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		traceline(src, src + direction*2048, false, this);
		if(trace_fraction != 1.0)
			TraceAttack(4, direction);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage();
}

/*
================
W_FireShotgun
================
*/
void W_FireShotgun(entity this)
{
	vector dir;

	_sound(this, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	

	this.punchangle_x = -2;
	
	this.currentammo = this.ammo_shells = this.ammo_shells - 1;
	dir = aim(this, 100000);
	FireBullets(this, 6, dir, '0.04 0.04 0');
}


/*
================
W_FireSuperShotgun
================
*/
void W_FireSuperShotgun(entity this)
{
	vector dir;

	if(this.currentammo == 1)
	{
		W_FireShotgun();
		return;
	}
		
	_sound(this ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	

	this.punchangle_x = -4;
	
	this.currentammo = this.ammo_shells = this.ammo_shells - 2;
	dir = aim(this, 100000);
	FireBullets(this, 14, dir, '0.14 0.08 0');
}


/*
==============================================================================

ROCKETS

==============================================================================
*/

void s_explode1(entity this) { this.frame = 0; setthink(this, s_explode2); this.nextthink = time + FRAME_TIME; }
void s_explode2(entity this) { this.frame = 1; setthink(this, s_explode3); this.nextthink = time + FRAME_TIME; }
void s_explode3(entity this) { this.frame = 2; setthink(this, s_explode4); this.nextthink = time + FRAME_TIME; }
void s_explode4(entity this) { this.frame = 3; setthink(this, s_explode5); this.nextthink = time + FRAME_TIME; }
void s_explode5(entity this) { this.frame = 4; setthink(this, s_explode6); this.nextthink = time + FRAME_TIME; }
void s_explode6(entity this) { this.frame = 5; setthink(this, SUB_Remove); this.nextthink = time + FRAME_TIME; }

void BecomeExplosion(entity this)
{
	this.movetype = MOVETYPE_NONE;
	this.velocity = '0 0 0';
	settouch(this, func_null);
	setmodel(this, "progs/s_explod.spr");
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

//	_sound(this, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	this.origin = this.origin - 8*normalize(this.velocity);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, this.origin_x);
	WriteCoord(MSG_BROADCAST, this.origin_y);
	WriteCoord(MSG_BROADCAST, this.origin_z);

	BecomeExplosion(this);
}



/*
================
W_FireRocket
================
*/
void W_FireRocket(entity this)
{
	this.currentammo = this.ammo_rockets = this.ammo_rockets - 1;
	
	_sound(this, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	this.punchangle_x = -2;

	entity missile = spawn();
	missile.owner = this;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
		
// set missile speed	

	makevectors(this.v_angle);
	missile.velocity = aim(this, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	
	settouch(missile, T_MissileTouch);
	
// set missile duration
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);

	setmodel(missile, "progs/missile.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin + v_forward*8 + '0 0 16');
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
	entity		e1, e2;
	vector		f;
	
	f = p2 - p1;
	normalize(f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = NULL;

	traceline(p1, p2, false, from);
	if(trace_ent.takedamage)
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
	if(trace_ent != e1 && trace_ent.takedamage)
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage);
	}
	e2 = trace_ent;

	traceline(p1 - f, p2 - f, false, from);
	if(trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage);
	}
}


void W_FireLightning(entity this)
{
	if(this.ammo_cells < 1)
	{
		this.weapon = W_BestWeapon(this);
		W_SetCurrentAmmo(this);
		return;
	}

// explode if under water
	if(this.waterlevel > 1)
	{
		int cells = this.ammo_cells;
		this.ammo_cells = 0;
		W_SetCurrentAmmo(this);
		T_RadiusDamage(this, this, 35*cells, world);
		return;
	}

	if(this.t_width < time)
	{
		_sound(this, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		this.t_width = time + 0.6;
	}
	this.punchangle_x = -2;

	this.currentammo = this.ammo_cells = this.ammo_cells - 1;

	vector org = this.origin + '0 0 16';
	
	traceline(org, org + v_forward*600, true, this);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity(MSG_BROADCAST, this);
	WriteCoord(MSG_BROADCAST, org_x);
	WriteCoord(MSG_BROADCAST, org_y);
	WriteCoord(MSG_BROADCAST, org_z);
	WriteCoord(MSG_BROADCAST, trace_endpos_x);
	WriteCoord(MSG_BROADCAST, trace_endpos_y);
	WriteCoord(MSG_BROADCAST, trace_endpos_z);

	LightningDamage(this.origin, trace_endpos + v_forward*4, this, 30);
}


//=============================================================================


void GrenadeExplode()
{
	T_RadiusDamage(this, this.owner, 120, world);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, this.origin_x);
	WriteCoord(MSG_BROADCAST, this.origin_y);
	WriteCoord(MSG_BROADCAST, this.origin_z);

	BecomeExplosion(this);
}

void GrenadeTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner
	if(toucher.takedamage == DAMAGE_AIM)
	{
		GrenadeExplode();
		return;
	}
	_sound(this, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
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
	
	_sound(this, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	this.punchangle_x = -2;

	entity missile = new(grenade);
	missile.owner = this;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
		
// set missile speed	

	makevectors(this.v_angle);

	if(this.v_angle_x)
		missile.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		missile.velocity = aim(this, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);

	settouch(missile, GrenadeTouch);
	
// set missile duration
	missile.nextthink = time + 2.5;
	setthink(missile, GrenadeExplode);

	setmodel(missile, "progs/grenade.mdl");
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
void launch_spike(vector org, vector dir)
{
	newmis = spawn();
	newmis.owner = this;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	settouch(newmis, spike_touch);
	newmis.classname = "spike";
	setthink(newmis, SUB_Remove);
	newmis.nextthink = time + 6;
	setmodel(newmis, "progs/spike.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin(newmis, org);

	newmis.velocity = dir * 1000;
}

void W_FireSuperSpikes()
{
	vector	dir;
	entity	old;
	
	_sound(this, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	this.attack_finished = time + 0.2;
	this.currentammo = this.ammo_nails = this.ammo_nails - 2;
	dir = aim(this, 1000);
	launch_spike(this.origin + '0 0 16', dir);
	settouch(newmis, superspike_touch);
	setmodel(newmis, "progs/s_spike.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);		
	this.punchangle_x = -2;
}

void W_FireSpikes(float ox)
{
	vector	dir;
	entity	old;
	
	makevectors(this.v_angle);
	
	if(this.ammo_nails >= 2 && this.weapon == IT_SUPER_NAILGUN)
	{
		W_FireSuperSpikes();
		return;
	}

	if(this.ammo_nails < 1)
	{
		this.weapon = W_BestWeapon();
		W_SetCurrentAmmo(this);
		return;
	}

	_sound(this, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	this.attack_finished = time + 0.2;
	this.currentammo = this.ammo_nails = this.ammo_nails - 1;
	dir = aim(this, 1000);
	launch_spike(this.origin + '0 0 16' + v_right*ox, dir);

	this.punchangle_x = -2;
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
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		
		if(this.classname == "wizspike")
			WriteByte(MSG_BROADCAST, TE_WIZSPIKE);
		else if(this.classname == "knightspike")
			WriteByte(MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte(MSG_BROADCAST, TE_SPIKE);
		WriteCoord(MSG_BROADCAST, this.origin_x);
		WriteCoord(MSG_BROADCAST, this.origin_y);
		WriteCoord(MSG_BROADCAST, this.origin_z);
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
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord(MSG_BROADCAST, this.origin_x);
		WriteCoord(MSG_BROADCAST, this.origin_y);
		WriteCoord(MSG_BROADCAST, this.origin_z);
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
	player_run(this);		// get out of any weapon firing states

	this.items &= ~(IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS);
	
	switch(this.weapon)
	{
		case IT_AXE:
		{
			this.currentammo = 0;
			this.weaponmodel = "progs/v_axe.mdl";
			this.weaponframe = 0;
			break;
		}
		case IT_SHOTGUN:
		{
			this.currentammo = this.ammo_shells;
			this.weaponmodel = "progs/v_shot.mdl";
			this.weaponframe = 0;
			this.items |= IT_SHELLS;
			break;
		}
		case IT_SUPER_SHOTGUN:
		{
			this.currentammo = this.ammo_shells;
			this.weaponmodel = "progs/v_shot2.mdl";
			this.weaponframe = 0;
			this.items |= IT_SHELLS;
			break;
		}
		case IT_NAILGUN:
		{
			this.currentammo = this.ammo_nails;
			this.weaponmodel = "progs/v_nail.mdl";
			this.weaponframe = 0;
			this.items |= IT_NAILS;
			break;
		}
		case IT_SUPER_NAILGUN:
		{
			this.currentammo = this.ammo_nails;
			this.weaponmodel = "progs/v_nail2.mdl";
			this.weaponframe = 0;
			this.items |= IT_NAILS;
			break;
		}
		case IT_GRENADE_LAUNCHER:
		{
			this.currentammo = this.ammo_rockets;
			this.weaponmodel = "progs/v_rock.mdl";
			this.weaponframe = 0;
			this.items |= IT_ROCKETS;
			break;
		}
		case IT_ROCKET_LAUNCHER:
		{
			this.currentammo = this.ammo_rockets;
			this.weaponmodel = "progs/v_rock2.mdl";
			this.weaponframe = 0;
			this.items |= IT_ROCKETS;
			break;
		}
		case IT_LIGHTNING:
		{
			this.currentammo = this.ammo_cells;
			this.weaponmodel = "progs/v_light.mdl";
			this.weaponframe = 0;
			this.items |= IT_CELLS;
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

int W_BestWeapon(entity this)
{
	int it = this.items;

	if(this.waterlevel <= 1 && this.ammo_cells >= 1 &&(it & IT_LIGHTNING) )
		return IT_LIGHTNING;
	if(this.ammo_nails >= 2 &&(it & IT_SUPER_NAILGUN) )
		return IT_SUPER_NAILGUN;
	if(this.ammo_shells >= 2 &&(it & IT_SUPER_SHOTGUN) )
		return IT_SUPER_SHOTGUN;
	if(this.ammo_nails >= 1 &&(it & IT_NAILGUN) )
		return IT_NAILGUN;
	if(this.ammo_shells >= 1 &&(it & IT_SHOTGUN) )
		return IT_SHOTGUN;
	return IT_AXE;
}

bool W_CheckNoAmmo(entity this)
{
	if(this.currentammo > 0)
		return true;

	if(this.weapon == IT_AXE)
		return true;
	
	this.weapon = W_BestWeapon(this);

	W_SetCurrentAmmo(this);
	
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

void W_Attack(entity this)
{
	if(!W_CheckNoAmmo(this))
		return;

	makevectors	(this.v_angle);			// calculate forward angle for velocity
	this.show_hostile = time + 1;	// wake monsters up

	if(this.weapon == IT_AXE)
	{
		_sound(this, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
		float r = random();
		if(r < 0.25)
			player_axe1(this);
		else if(r<0.5)
			player_axeb1(this);
		else if(r<0.75)
			player_axec1(this);
		else
			player_axed1(this);
		this.attack_finished = time + 0.5;
	}
	else if(this.weapon == IT_SHOTGUN)
	{
		player_shot1(this);
		W_FireShotgun(this);
		this.attack_finished = time + 0.5;
	}
	else if(this.weapon == IT_SUPER_SHOTGUN)
	{
		player_shot1(this);
		W_FireSuperShotgun(this);
		this.attack_finished = time + 0.7;
	}
	else if(this.weapon == IT_NAILGUN)
	{
		player_nail1(this);
	}
	else if(this.weapon == IT_SUPER_NAILGUN)
	{
		player_nail1(this);
	}
	else if(this.weapon == IT_GRENADE_LAUNCHER)
	{
		player_rocket1(this);
		W_FireGrenade(this);
		this.attack_finished = time + 0.6;
	}
	else if(this.weapon == IT_ROCKET_LAUNCHER)
	{
		player_rocket1(this);
		W_FireRocket(this);
		this.attack_finished = time + 0.8;
	}
	else if(this.weapon == IT_LIGHTNING)
	{
		player_light1(this);
		this.attack_finished = time + 0.1;
		_sound(this, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
}

/*
============
W_ChangeWeapon

============
*/
void W_ChangeWeapon(entity this)
{
	int am = 0;
	int fl = 0;
	
	if(this.impulse == 1)
	{
		fl = IT_AXE;
	}
	else if(this.impulse == 2)
	{
		fl = IT_SHOTGUN;
		if(this.ammo_shells < 1)
			am = 1;
	}
	else if(this.impulse == 3)
	{
		fl = IT_SUPER_SHOTGUN;
		if(this.ammo_shells < 2)
			am = 1;
	}		
	else if(this.impulse == 4)
	{
		fl = IT_NAILGUN;
		if(this.ammo_nails < 1)
			am = 1;
	}
	else if(this.impulse == 5)
	{
		fl = IT_SUPER_NAILGUN;
		if(this.ammo_nails < 2)
			am = 1;
	}
	else if(this.impulse == 6)
	{
		fl = IT_GRENADE_LAUNCHER;
		if(this.ammo_rockets < 1)
			am = 1;
	}
	else if(this.impulse == 7)
	{
		fl = IT_ROCKET_LAUNCHER;
		if(this.ammo_rockets < 1)
			am = 1;
	}
	else if(this.impulse == 8)
	{
		fl = IT_LIGHTNING;
		if(this.ammo_cells < 1)
			am = 1;
	}

	this.impulse = 0;
	
	if(!(this.items & fl))
	{	// don't have the weapon or the ammo
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
	this.weapon = fl;		
	W_SetCurrentAmmo(this);
}

/*
============
CheatCommand
============
*/
void CheatCommand(entity this)
{
	if(deathmatch || coop)
		return;

	this.ammo_rockets = 100;
	this.ammo_nails = 200;
	this.ammo_shells = 100;
	this.items |= 
		(IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER |
		IT_KEY1 | IT_KEY2);

	this.ammo_cells = 200;
	this.items |= IT_LIGHTNING;

	this.weapon = IT_ROCKET_LAUNCHER;
	this.impulse = 0;
	W_SetCurrentAmmo(this);
}

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void CycleWeaponCommand(entity this)
{
	int myitems = this.items;
	this.impulse = 0;
	
	while(1)
	{
		int am = 0;

		if(this.weapon == IT_LIGHTNING)
		{
			this.weapon = IT_AXE;
		}
		else if(this.weapon == IT_AXE)
		{
			this.weapon = IT_SHOTGUN;
			if(this.ammo_shells < 1)
				am = 1;
		}
		else if(this.weapon == IT_SHOTGUN)
		{
			this.weapon = IT_SUPER_SHOTGUN;
			if(this.ammo_shells < 2)
				am = 1;
		}		
		else if(this.weapon == IT_SUPER_SHOTGUN)
		{
			this.weapon = IT_NAILGUN;
			if(this.ammo_nails < 1)
				am = 1;
		}
		else if(this.weapon == IT_NAILGUN)
		{
			this.weapon = IT_SUPER_NAILGUN;
			if(this.ammo_nails < 2)
				am = 1;
		}
		else if(this.weapon == IT_SUPER_NAILGUN)
		{
			this.weapon = IT_GRENADE_LAUNCHER;
			if(this.ammo_rockets < 1)
				am = 1;
		}
		else if(this.weapon == IT_GRENADE_LAUNCHER)
		{
			this.weapon = IT_ROCKET_LAUNCHER;
			if(this.ammo_rockets < 1)
				am = 1;
		}
		else if(this.weapon == IT_ROCKET_LAUNCHER)
		{
			this.weapon = IT_LIGHTNING;
			if(this.ammo_cells < 1)
				am = 1;
		}
	
		if((myitems & this.weapon) && am == 0)
		{
			W_SetCurrentAmmo(this);
			return;
		}
	}

}

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void CycleWeaponReverseCommand(entity this)
{
	int myitems = this.items;
	this.impulse = 0;

	while(1)
	{
		int am = 0;

		if(this.weapon == IT_LIGHTNING)
		{
			this.weapon = IT_ROCKET_LAUNCHER;
			if(this.ammo_rockets < 1)
				am = 1;
		}
		else if(this.weapon == IT_ROCKET_LAUNCHER)
		{
			this.weapon = IT_GRENADE_LAUNCHER;
			if(this.ammo_rockets < 1)
				am = 1;
		}
		else if(this.weapon == IT_GRENADE_LAUNCHER)
		{
			this.weapon = IT_SUPER_NAILGUN;
			if(this.ammo_nails < 2)
				am = 1;
		}
		else if(this.weapon == IT_SUPER_NAILGUN)
		{
			this.weapon = IT_NAILGUN;
			if(this.ammo_nails < 1)
				am = 1;
		}
		else if(this.weapon == IT_NAILGUN)
		{
			this.weapon = IT_SUPER_SHOTGUN;
			if(this.ammo_shells < 2)
				am = 1;
		}		
		else if(this.weapon == IT_SUPER_SHOTGUN)
		{
			this.weapon = IT_SHOTGUN;
			if(this.ammo_shells < 1)
				am = 1;
		}
		else if(this.weapon == IT_SHOTGUN)
		{
			this.weapon = IT_AXE;
		}
		else if(this.weapon == IT_AXE)
		{
			this.weapon = IT_LIGHTNING;
			if(this.ammo_cells < 1)
				am = 1;
		}
	
		if((myitems & this.weapon) && am == 0)
		{
			W_SetCurrentAmmo(this);
			return;
		}
	}

}

/*
============
ServerflagsCommand

Just for development
============
*/
void ServerflagsCommand()
{
	serverflags = serverflags * 2 + 1;
}

void QuadCheat()
{
	if(deathmatch || coop)
		return;
	this.super_time = 1;
	this.super_damage_finished = time + 30;
	this.items |= IT_QUAD;
	dprint("quad cheat\n");
}

/*
============
ImpulseCommands

============
*/
void ImpulseCommands()
{
	if(this.impulse >= 1 && this.impulse <= 8)
		W_ChangeWeapon();

	if(this.impulse == 9)
		CheatCommand();
	if(this.impulse == 10)
		CycleWeaponCommand();
	if(this.impulse == 11)
		ServerflagsCommand();
	if(this.impulse == 12)
		CycleWeaponReverseCommand();

	if(this.impulse == 255)
		QuadCheat();
		
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
			_sound(this, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
	return;
}


