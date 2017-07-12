// multi_weapons

//=============================================================================
// Multi Grenade Code
//=============================================================================
void MultiGrenadeTouch(entity this, entity toucher);

//================================
//================================
void MiniGrenadeExplode(entity this)
{
	if(IS_PLAYER(this.owner))
		T_RadiusDamage(this, this.owner, 90, world);
	else
		T_RadiusDamage(this, this.owner, 60, world);

    te_explosion2(this.origin, 230, 5);

	BecomeExplosion(this);
}

//================================
//================================
void MiniGrenadeLaunch(entity this, float offsetAngle)
{
	entity missile = new(MiniGrenade);
	missile.owner = this.owner;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
		
// set missile speed	
	missile.v_angle = this.v_angle;
	missile.v_angle_y = missile.v_angle_y + offsetAngle;
	makevectors(missile.v_angle);
		
		missile.velocity = v_forward*100 + v_up*400;
		float tempRand =(crandom()*60) - 30;
		missile.velocity = missile.velocity + tempRand * v_forward;
		tempRand =(crandom()*40) - 20;
		missile.velocity = missile.velocity + tempRand * v_right;
		tempRand =(crandom()*60) - 30;
		missile.velocity = missile.velocity + tempRand * v_up;

	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, MultiGrenadeTouch);
	
	_setmodel(missile, "progs/mervup.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin);

// set missile duration
	missile.nextthink = time + 1 +(crandom() * 0.5);
	setthink(missile, MiniGrenadeExplode);
}

//================================
//================================
void MultiGrenadeExplode(entity this)
{
	MiniGrenadeLaunch(this, 0);
	MiniGrenadeLaunch(this, 72);
	MiniGrenadeLaunch(this, 144);
	MiniGrenadeLaunch(this, 216);
	MiniGrenadeLaunch(this, 288);

	delete(this);
}

//================================
//================================
void MultiGrenadeTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner
	if(toucher.takedamage == DAMAGE_AIM)
	{
		if(this.classname == "MiniGrenade")
			MiniGrenadeExplode(this);
		else
		{
			if(IS_PLAYER(this.owner))
				GrenadeExplode(this);
			else
				MiniGrenadeExplode(this);
		}
		return;
	}
	// bounce sound
	_sound(this, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	
	if(this.velocity == '0 0 0')
		this.avelocity = '0 0 0';
}

//================================
//================================
void W_FireMultiGrenade(entity this)
{
	this.currentammo = this.ammo_multi_rockets = this.ammo_multi_rockets - 1;
	
	_sound(this, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	this.punchangle_x = -2;

	entity missile = new(MultiGrenade);
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
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
	settouch(missile, MultiGrenadeTouch);
	
// set missile duration
	missile.nextthink = time + 1;
	setthink(missile, MultiGrenadeExplode);

	_setmodel(missile, "progs/mervup.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin);
}

//=============================================================================
// Multi Rocket Code
//=============================================================================

//================================
//================================
void MultiRocketExplode(entity this, entity directhitentity)
{
//	Stock Single Rocket Damage...
//	damg = 100 + random()*20;

	float damg = 60 + random()*15;

	if(directhitentity.health)
	{
		if(directhitentity.classname == "monster_shambler")
			damg = damg * 0.5;	// mostly immune
		if(directhitentity.classname == "monster_dragon")
			damg = damg * 0.5;	// mostly immune
		T_Damage(directhitentity, this, this.owner, damg );
	}

	// don't do radius damage to the directhitentity, because all the damage
	// was done in the impact
//	Stock single rocket damage.
//	T_RadiusDamage(this, this.owner, 120, directhitentity);

	T_RadiusDamage(this, this.owner, 75, directhitentity);

//	sound(this, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	this.origin = this.origin - 8*normalize(this.velocity);

	te_explosion(this.origin);

	BecomeExplosion(this);
}

void MultiRocketExplode_think(entity this)
{
	MultiRocketExplode(this, NULL);
}

//================================
//================================
void MultiRocketTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	MultiRocketExplode(this, toucher);
}


//================================
//================================
void HomingMissileThink(entity this)
{
	if(this.enemy.health < 1)
	{
		delete(this);
		return;
	}

	vector dir = normalize(this.enemy.origin - this.origin);
	this.velocity = dir * 1000;
	this.nextthink = time + 0.1;
	setthink(this, HomingMissileThink);	
}


//================================
//================================
void HomingMissileAcquire(entity this)
{
	if(this.delay < time)
	{
		MultiRocketExplode(this, NULL);
		return;
	}

	vector oldVelocity = this.velocity;
	makevectors(this.v_angle);
	this.velocity = aim(this, 1000);
	this.velocity = this.velocity * 1000;

	vector aimangle = this.origin + this.velocity;	
	traceline(this.origin, aimangle, false, this );
	if(trace_fraction < 1)
	{
		if(trace_ent.flags & FL_MONSTER)
		{
			this.enemy = trace_ent;
			HomingMissileThink(this);
			return;
		}
	}
	
	this.velocity = oldVelocity;
	this.v_angle = vectoangles( this.velocity );
	this.angles = this.v_angle;
	setthink(this, HomingMissileAcquire);
	this.nextthink = time + 0.2;
}

//================================
//================================
void MultiRocketLaunch(entity this, float offset, float frameNum)
{
	entity missile = new(MultiRocket);
	missile.owner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	missile.classname = "MultiRocket";
	missile.delay = time + 4;
	missile.frame = frameNum;
	settouch(missile, MultiRocketTouch);

	if(deathmatch || coop)
		_setmodel(missile, "progs/rockup_d.mdl");
	else
		_setmodel(missile, "progs/rockup.mdl");

	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin + v_forward*8 + '0 0 16');
	
	vector aimangle;
	if(coop || deathmatch)
	{
		aimangle = this.v_angle;
		aimangle_y = aimangle_y +(offset * 0.66);
		makevectors(aimangle);
		missile.velocity = aim(this, 1000);
		missile.velocity = missile.velocity * 1000;
		missile.angles = vectoangles(missile.velocity);

		setthink(missile, MultiRocketExplode_think);
		missile.nextthink = time + 4;
	}
	else
	{
		makevectors(this.v_angle);
		missile.velocity = v_forward * 1000 - v_right*offset*8;
		missile.angles = vectoangles(missile.velocity);
		missile.v_angle = this.v_angle;	

		aimangle = missile.origin + missile.velocity;
		traceline(missile.origin, aimangle, false, this );
		if(trace_fraction < 1)
		{
			if(trace_ent.flags & FL_MONSTER)
			{
				missile.enemy = trace_ent;
				setthink(missile, HomingMissileThink);
				return;
			}
		}

		setthink(missile, HomingMissileAcquire);
		missile.nextthink = time + 0.1;
	}
}

//================================
//================================
void W_FireMultiRocket(entity this)
{
	this.currentammo = this.ammo_multi_rockets = this.ammo_multi_rockets - 1;
	
	_sound(this, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	this.punchangle_x = -2;
	
	MultiRocketLaunch(this, -10, 2);
	MultiRocketLaunch(this, -5, 3);
	MultiRocketLaunch(this, 5, 0);
	MultiRocketLaunch(this, 10, 1);
}

//=============================================================================
// Plasma Gun Code
//=============================================================================
void PlasmaDamage(vector p1, vector p2, entity from, float damage)
{
	vector f = p2 - p1;
	normalize(f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	entity e1 = NULL, e2 = NULL;

	traceline(p1, p2, false, from);
	if(trace_ent.takedamage)
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from.owner, damage);
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
		T_Damage(trace_ent, from, from.owner, damage);
	}
	e2 = trace_ent;

	traceline(p1 - f, p2 - f, false, from);
	if(trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from.owner, damage);
	}
}

//================================
//================================
void PlasmaDischarge(entity this, entity current, float doDamage)
{
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity(MSG_BROADCAST, current);
	WriteCoord(MSG_BROADCAST, current.origin_x);
	WriteCoord(MSG_BROADCAST, current.origin_y);
	WriteCoord(MSG_BROADCAST, current.origin_z);
	WriteCoord(MSG_BROADCAST, this.origin_x);
	WriteCoord(MSG_BROADCAST, this.origin_y);
	WriteCoord(MSG_BROADCAST, this.origin_z);

	_sound(this, CHAN_VOICE, "weapons/lhit.wav", 1, ATTN_NORM);
	if(doDamage == 1)
        PlasmaDamage(this.origin, current.origin, this, 50);
}

//================================
//================================
void PlasmaGroundOut(entity this)
{
	int monstersHit = 0;
	entity current = findradius(this.origin, 320);
	entity start = current;
	while(monstersHit < 5)
	{
		if((current.flags & FL_MONSTER) || IS_PLAYER(current))
		{
			if( current != this.owner )
			{
				traceline( this.origin, current.origin, true, world );
				if(trace_fraction == 1)
				{
					monstersHit = monstersHit + 1;
					PlasmaDischarge(this, current, 1);
				}
			}
		}
		current = current.chain;
		if(start == current || !current)
			return;
	}
}

//================================
//================================
void PlasmaTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float damg = 80 + random()*20;
	_sound(this, CHAN_WEAPON, "plasma/explode.wav", 1, ATTN_NORM);
	
	if(toucher.health)
	{
		if(toucher.classname == "monster_shambler")
			damg = damg * 0.5;	// mostly immune
		T_Damage(toucher, this, this.owner, damg );
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, 70, toucher);

	te_explosion2(this.origin, 244, 3);

	PlasmaGroundOut(this);
	delete(this);
}

//================================
//================================
void PlasmaLaunch(entity this)
{
	this.velocity = normalize(this.velocity);
	this.velocity = this.velocity * 1250;

	this.nextthink = time + 5;
	setthink(this, SUB_Remove);
}

void launch_plasma(entity this, vector org, vector dir)
{
	entity missile = new(plasma);
	missile.owner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	
// set missile speed	
	missile.velocity = dir * 0.01;
	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, PlasmaTouch);
	
	_setmodel(missile, "progs/plasma.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, org);

	_sound(missile, CHAN_WEAPON, "plasma/flight.wav", 1, ATTN_NORM);
	if(!deathmatch && !coop)
		missile.effects = EF_BRIGHTLIGHT;
	
// set missile duration
	setthink(missile, PlasmaLaunch);
	missile.nextthink = time + 0.1;
}

//================================
//================================
void W_FirePlasma(entity this)
{
	if(this.ammo_plasma < 1)
	{
		W_SwitchWeapon(this, W_BestWeapon(this, 0));
		return;
	}

// explode if under water
	if(this.waterlevel > 1)
	{
		int cells = this.ammo_plasma;
		this.ammo_plasma = 0;
		W_SetCurrentAmmo(this);
		T_RadiusDamage(this, this, 35*cells, world);
		return;
	}
	this.currentammo = this.ammo_plasma = this.ammo_plasma - 1;
	_sound(this, CHAN_WEAPON, "plasma/fire.wav", 0.5, ATTN_NORM);
	this.punchangle_x = -2;

	makevectors(this.v_angle);
	vector dir = aim(this, 1000);
	launch_plasma(this, this.origin + v_forward*24 + '0 0 16', dir);
}
