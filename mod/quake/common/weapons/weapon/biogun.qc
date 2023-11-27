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

void player_bio1(entity this) { set_animofs(this, anim_player_nailatt1, 1, player_bio2); this.nextthink = time + 0.5; }
void player_bio2(entity this) { set_animofs(this, anim_player_nailatt1, 2, player_run); this.nextthink = time + 0.5; }

void W_Biogun_Attack(entity this)
{
	entity actor = this.owner;
	if(!actor.button0)
	{
		w_ready(this);
		return;
	}

	this.misc_bulletcounter += 1;

	player_bio1(actor);

	this.m_frame += 1;
	if(this.m_frame >= 5)
		this.m_frame = 1;
	wep_set_anim(this, this.m_frame, W_Biogun_Attack);
	SuperDamageSound(actor);
	W_FireBio(actor, ((this.misc_bulletcounter % 2) ? 3 : -3), this.weaponentity_fld);
	ATTACK_FINISHED(actor, this.weaponentity_fld) = time + 0.5;
}

void W_FireBio(entity this, float ox, .entity weaponentity)
{
	makevectors(this.v_angle);

	if(this.ammo_nails < 2)
	{
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
		return;
	}

	float vol = (this.silencer) ? 0.2 : 1;

	_sound(this, CH_WEAPON_SINGLE, "weapons/bio_fire.wav", vol, ATTN_NORM);
	this.ammo_nails -= 2;
	vector dir = qc_aim(this, 1000);
	// NOTE: position fix by Seven and Sajt applied here
	entity missile = launch_spike(this, W_Shotorg(this, weaponentity) + v_up * -12 + v_right * ox, dir);
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
		actor.(weaponentity).misc_bulletcounter = 0;
		W_Biogun_Attack(actor.(weaponentity));
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
