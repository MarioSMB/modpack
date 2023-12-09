#include "biogun.qh"

#ifdef SVQC
PRECACHE(Biogun)
{
	precache_model("progs/v_biogun.mdl");
	precache_model("progs/g_biogun.mdl");

	precache_model("progs/bone_shard.mdl");
	precache_sound("weapons/bio_fire.wav");
	precache_sound("weapons/punch_ice2.wav");
	precache_sound("weapons/resist_rocket.wav");
}

void biogun_shot1(entity this)
{
	wep_set_anim(this, 1, w_ready);
	.entity weaponentity = this.weaponentity_fld;
	this.weapon_nextthink = time + 0.5;
	this.m_frame = (this.owner.(weaponentity).misc_bulletcounter % 2) ? 1 : 2;
}

void W_FireBio(entity this, float ox, .entity weaponentity)
{
	makevectors(this.v_angle);

	if(this.ammo_nails < 2)
	{
		ATTACK_FINISHED(this, weaponentity) = time + 0.5;
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
		return;
	}

	float vol = (this.silencer) ? 0.2 : 1;

	_sound(this, CH_WEAPON_SINGLE, "weapons/bio_fire.wav", vol, ATTN_NORM);
	W_TakeAmmo(this, ammo_nails, 2);
	vector dir = qc_aim(this, 1000);
	// NOTE: position fix by Seven and Sajt applied here
	entity missile = launch_spike(this, W_Shotorg(this, weaponentity) + v_up * -4 + v_right * ox, dir);
	missile.dmg = 40;
	missile.classname = "bio"; // identifier for spike touch TODO: clean this mess up
	missile.projectiledeathtype = WEP_BIOGUN.m_id;
	_setmodel(missile, "progs/bone_shard.mdl");
	setsize(missile, '0 0 0', '0 0 0');

	this.punchangle_x = -2;
}

METHOD(Biogun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		actor.effects |= EF_MUZZLEFLASH;
		//actor.(weaponentity).misc_bulletcounter = 0;
		actor.(weaponentity).misc_bulletcounter += 1;
		biogun_shot1(actor.(weaponentity));
		W_FireBio(actor, ((actor.(weaponentity).misc_bulletcounter % 2) ? 3 : -3), weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.5);
	}
}
METHOD(Biogun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_nails >= 2;
	return ammo_amount;
}
METHOD(Biogun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
