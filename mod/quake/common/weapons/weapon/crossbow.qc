#include "crossbow.qh"

#ifdef SVQC
PRECACHE(Crossbow)
{
	precache_model("progs/v_crossbow.mdl");
	precache_model("progs/g_crossbow.mdl");

	precache_model("progs/proj_impalespike.mdl");
	precache_sound("weapons/penfire.wav");

	precache_sound("weapons/pierce1.wav");
	precache_sound("weapons/pierce2.wav");
	precache_sound("weapons/pierce3.wav");
	precache_sound("weapons/stick1.wav");
}

void crossbow_bolt_stick(entity this, vector org, vector dir)
{
	entity newmis = spawn();
	newmis.classname = "crossbow_bolt_stick";
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

	newmis.nextthink = time + 3;
	setthink(newmis, SUB_Remove);
	//end blitzcode
	
	_setmodel(newmis, "progs/proj_impalespike.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		
	setorigin(newmis, neworg);

	// no velocities
	newmis.avelocity = '0 0 0';
	newmis.velocity = '0 0 0';
}

void crossbow_bolt_touch(entity this, entity toucher)
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
	if(toucher && toucher.solid != SOLID_BSP) // yoder mod, jan 05 2021
	{
		// handled by hack
	}
	else
	{
		crossbow_bolt_stick(this, this.origin, this.velocity);
		te_spike(this.origin);
		_sound(this, CH_WEAPON_SINGLE, "weapons/stick1.wav", 1, ATTN_NORM);
		delete(this);
		return;
	}

	//delete(this);
}

void crossbow_bolt_think(entity this)
{
	if(time > this.count)
	{
		delete(this);
		return;
	}

	// hack to ensure the projectile keeps going even if it hits a target
	this.nextthink = time;
	//this.velocity = this.pos2 * this.speed;

	FOREACH_ENTITY_RADIUS(this.origin, this.cnt, it.takedamage && it != this.owner,
	{
		float damg = ((this.dmg) ? this.dmg : 25);
		if(it.resist_nails != 0)
			damg = Resist_Damage(it, IT_NAILS, damg);
		Resist_Nails(it, this.origin);
		spawn_touchblood(this, damg, it);
		T_Damage(it, this, this.owner, damg, this.projectiledeathtype);

		float r = random();
		if(r > 0.66)
			_sound(this, CH_WEAPON_SINGLE, "weapons/pierce1.wav", 0.8, ATTN_NORM);
		else if(r > 0.33)
			_sound(this, CH_WEAPON_SINGLE, "weapons/pierce2.wav", 0.8, ATTN_NORM);
		else
			_sound(this, CH_WEAPON_SINGLE, "weapons/pierce3.wav", 0.8, ATTN_NORM);
	});
}

void W_FireCrossbow(entity this, float ox, .entity weaponentity)
{
	makevectors(this.v_angle);

	if(this.ammo_nails < 1)
	{
		ATTACK_FINISHED(this, weaponentity) = time + 1;
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
		return;
	}

	float vol = (this.silencer) ? 0.2 : 1;

	_sound(this, CH_WEAPON_SINGLE, "weapons/penfire.wav", vol, ATTN_NORM);
	W_TakeAmmo(this, ammo_nails, 1);
	vector dir = qc_aim(this, 1000);
	// NOTE: position fix by Seven and Sajt applied here
	entity missile = launch_spike(this, W_Shotorg(this, weaponentity) + v_right * ox + v_up * -4, dir);
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_TRIGGER;
	missile.dphitcontentsmask = DPCONTENTS_SOLID;
	missile.speed = 1000;
	missile.pos2 = dir;
	missile.count = time + 6;
	missile.cnt = 32;
	settouch(missile, crossbow_bolt_touch);
	missile.dmg = 25;
	missile.classname = "crossbow_bolt"; // identifier for spike touch TODO: clean this mess up
	missile.projectiledeathtype = WEP_CROSSBOW.m_id;
	_setmodel(missile, "progs/proj_impalespike.mdl");
	setsize(missile, '0 0 0', '0 0 0');

	setthink(missile, crossbow_bolt_think);
	missile.nextthink = time;

	this.punchangle_x = -2;
}

METHOD(Crossbow, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_generic_shot1(actor.(weaponentity));
		W_FireCrossbow(actor, ((weaponslot(weaponentity) > 0) ? 5 : -5), weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 1);
	}
}
METHOD(Crossbow, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_nails >= 1;
	return ammo_amount;
}
METHOD(Crossbow, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Crossbow, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
