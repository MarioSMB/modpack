#include "rocket_launcher.qh"

#ifdef SVQC
entity W_FireRocket(entity this)
{
	W_TakeAmmo(this, ammo_rockets, 1);
	
	_sound(this, CH_WEAPON_SINGLE, "weapons/sgun1.wav", 1, ATTN_NORM);

	this.punchangle_x = -2;

	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
	missile.projectiledeathtype = WEP_ROCKET_LAUNCHER.m_id;
		
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
	vector org = this.origin + '0 0 16'; // v_forward * 8, not used because it goes through mobs!
	setorigin(missile, org);

	return missile;
}

METHOD(RocketLauncher, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		wep_generic_rocket1(actor.(weaponentity));
		entity rocket = W_FireRocket(actor);
		setorigin(rocket, W_Shotorg(actor, weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 0.8);
	}
}
METHOD(RocketLauncher, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_rockets >= 1;
	return ammo_amount;
}
METHOD(RocketLauncher, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(RocketLauncher, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
