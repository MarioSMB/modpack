#include "multi_grenade.qh"

#ifdef SVQC
void MiniGrenadeExplode(entity this)
{
	if(IS_PLAYER(this.owner))
		T_RadiusDamage(this, this.owner, 90, this.projectiledeathtype, NULL);
	else
		T_RadiusDamage(this, this.owner, 60, this.projectiledeathtype, NULL);

    te_explosion2(this.origin, 230, 5);

	BecomeExplosion(this);
}

void MiniGrenadeLaunch(entity this, float offsetAngle)
{
	entity missile = new(MiniGrenade);
	missile.owner = this.owner;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = this.projectiledeathtype;
		
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

void MultiGrenadeExplode(entity this)
{
	MiniGrenadeLaunch(this, 0);
	MiniGrenadeLaunch(this, 72);
	MiniGrenadeLaunch(this, 144);
	MiniGrenadeLaunch(this, 216);
	MiniGrenadeLaunch(this, 288);

	delete(this);
}

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
	_sound(this, CH_WEAPON_SINGLE, "weapons/bounce.wav", 1, ATTN_NORM);	
	if(this.velocity == '0 0 0')
		this.avelocity = '0 0 0';
}

void W_FireMultiGrenade(entity this)
{
	this.ammo_multi_rockets = this.ammo_multi_rockets - 1;
	
	_sound(this, CH_WEAPON_SINGLE, "weapons/grenade.wav", 1, ATTN_NORM);

	this.punchangle_x = -2;

	entity missile = new(MultiGrenade);
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = WEP_MULTI_GRENADE.m_id;
		
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
	settouch(missile, MultiGrenadeTouch);
	
// set missile duration
	missile.nextthink = time + 1;
	setthink(missile, MultiGrenadeExplode);

	_setmodel(missile, "progs/mervup.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin);
}

METHOD(MultiGrenadeLauncher, wr_think, void(entity thiswep, entity actor, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor))
	{
		wep_generic_rocket1(actor.weaponentity);
		W_FireMultiGrenade(actor);
		actor.attack_finished = time + 0.6;
	}
}
METHOD(MultiGrenadeLauncher, wr_checkammo1, bool(entity thiswep, entity actor))
{
	float ammo_amount = actor.ammo_multi_rockets >= 1;
	return ammo_amount;
}
METHOD(MultiGrenadeLauncher, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
