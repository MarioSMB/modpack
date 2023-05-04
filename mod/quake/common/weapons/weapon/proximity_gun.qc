#include "proximity_gun.qh"

#ifdef SVQC
void ProximityExplode(entity this)
{
	T_RadiusDamage(this, this.owner, 95, NULL);

	te_explosion(this.origin);

	BecomeExplosion(this);
}

void ProximityGrenadeExplode(entity this, entity inflictor, entity attacker)
{
	this.takedamage = DAMAGE_NO;
	this.realowner.NumProximityGrenades -= 1;
	this.deathtype = "exploding";
	this.nextthink = time + 0.1;
	this.owner = this.lastvictim;
	setthink(this, ProximityExplode);
}

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
		if(head != this && head.health > 0 && (IS_PLAYER(head) || IS_MONSTER(head)) && head.classname != this.classname && head != this.realowner)
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

METHOD(ProximityGun, wr_think, void(entity thiswep, entity actor))
{
	player_rocket1(actor);
	W_FireProximityGrenade(actor);
	actor.attack_finished = time + 0.6;
}
METHOD(ProximityGun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
