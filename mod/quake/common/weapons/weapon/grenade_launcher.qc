#include "grenade_launcher.qh"

#ifdef SVQC
void GrenadeExplode(entity this)
{
	T_RadiusDamage(this, this.owner, 120, this.projectiledeathtype, NULL);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

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

void W_FireGrenade(entity this, .entity weaponentity)
{
	W_TakeAmmo(this, ammo_rockets, 1);
	
	_sound(this, CH_WEAPON_SINGLE, "weapons/grenade.wav", 1, ATTN_NORM);

	this.punchangle_x = -2;

	entity missile = new(grenade);
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = WEP_GRENADE_LAUNCHER.m_id;
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
	setorigin(missile, W_Shotorg(this, weaponentity));
}

METHOD(GrenadeLauncher, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		wep_generic_rocket1(actor.(weaponentity));
		W_FireGrenade(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.6);
	}
}
METHOD(GrenadeLauncher, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_rockets >= 1;
	return ammo_amount;
}
METHOD(GrenadeLauncher, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
