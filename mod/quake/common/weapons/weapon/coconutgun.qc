#include "coconutgun.qh"

#ifdef SVQC
PRECACHE(CoconutGun)
{
	precache_model("progs/v_coconutgun.mdl");
	precache_model("progs/g_coconutgun.mdl");

	precache_sound("weapons/coconutgun_fire.wav");
	precache_sound("weapons/coconutgun_impact.wav");
	precache_sound("player_goat/bonk.wav");
}

void coconut_touch(entity this, entity toucher)
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
		float damg = ((this.dmg) ? this.dmg : 40);
		spawn_touchblood(this, damg, toucher);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);

		_sound(this, CH_SHOTS, "player_goat/bonk.wav", 1, ATTN_NORM);
	}
	else if(this.noise && this.noise != "")
		_sound(this, CH_SHOTS, this.noise, 1, ATTN_NORM);

	T_RadiusDamage(this, this.owner, 100, this.projectiledeathtype, toucher);

	te_explosion2(this.origin, 100, 5);

	delete(this);
}

void W_FireCoconutGun(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);

	float vol = (this.silencer) ? 0.2 : 1;

	_sound(this, CH_WEAPON_SINGLE, "weapons/coconutgun_fire.wav", vol, ATTN_NORM);
	W_TakeAmmo(this, IT_SHELLS, 1);
	vector org = W_Shotorg(this, weaponentity) + v_up * -4 + v_right * 10;
	vector dir = qc_aim_fromorg(this, org, 800);

	// FIXME gettaginfo(this.(weaponentity), 0) doesn't return the real origin of the weapon
	Send_Effect(EFFECT_BROWN_NOTE, this.origin + this.view_ofs + v_up * -4 + v_right * 20 + v_forward * 14, dir * 50, 1);

	entity missile = launch_spike(this, org, dir);
	missile.velocity = dir * 800;
	missile.dmg = 40;
	missile.classname = "coconut";
	missile.projectiledeathtype = WEP_COCONUTGUN.m_id;
	missile.noise = "weapons/coconutgun_impact.wav";
	setsize(missile, '0 0 0', '0 0 0');
	settouch(missile, coconut_touch);

	CSQCProjectile(missile, true, PROJECTILE_COCONUT, true);

	this.punchangle_x = -3 * autocvar_sv_quake_recoil;
}

METHOD(CoconutGun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		//actor.effects |= EF_MUZZLEFLASH;
		wep_generic_shot1(actor.(weaponentity));
		W_FireCoconutGun(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.5);
	}
}
METHOD(CoconutGun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_shells >= 1;
	return ammo_amount;
}
METHOD(CoconutGun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(CoconutGun, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
