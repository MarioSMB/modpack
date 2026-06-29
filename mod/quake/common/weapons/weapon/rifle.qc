#include "rifle.qh"

#ifdef SVQC
PRECACHE(Rifle)
{
	precache_model("progs/v_rifle.mdl");
	precache_model("progs/g_rifle.mdl");

	precache_sound("weapons/rifle_fire.wav");
}

bool disc_shouldbehead(entity this, entity toucher);
void rifle_bullet_touch(entity this, entity toucher)
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
		float damg = 64;
		if(this.origin_z >= toucher.origin_z + 20 && disc_shouldbehead(this, toucher))
			damg *= 2; // HEADSHOT
		spawn_touchblood(this, damg, toucher);
		if(toucher.resist_nails != 0)
			damg = Resist_Damage(toucher, IT_NAILS, damg);
		Resist_Nails(toucher, this.origin);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}
	else
		te_superspike(this.origin);

	delete(this);
}

void W_FireRifle(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);

	_sound(this, CH_WEAPON_SINGLE, "weapons/rifle_fire.wav", 1, ATTN_NORM);
	W_TakeAmmo(this, IT_NAILS, 2);
	vector org = W_Shotorg(this, weaponentity) + v_right * 6 + v_up * 6;
	vector dir = qc_aim_fromorg(this, org, 5000);
	entity newmis = launch_spike(this, org, dir);
	newmis.velocity = dir * 5000;
	newmis.projectiledeathtype = WEP_RIFLE.m_id;
	newmis.classname = "rifle_bullet";
	settouch(newmis, rifle_bullet_touch);
	//_setmodel(newmis, "progs/s_spike.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	CSQCProjectile(newmis, true, PROJECTILE_SUPER_SPIKE, true);

	this.punchangle_x = -3 * autocvar_sv_quake_recoil;
}

METHOD(Rifle, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		actor.effects |= EF_MUZZLEFLASH;
		W_FireRifle(actor, weaponentity);
		wep_generic_shot1(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 1);
	}
}
METHOD(Rifle, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_nails >= 2;
	return ammo_amount;
}
METHOD(Rifle, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Rifle, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}

METHOD(Rifle, wr_zoom, bool(entity thiswep, entity actor))
{
	return PHYS_INPUT_BUTTON_ATCK2(actor);
}
#endif

#ifdef CSQC
METHOD(Rifle, wr_zoom, bool(entity thiswep, entity actor))
{
	if (button_zoom || zoomscript_caught || PHYS_INPUT_BUTTON_ATCK2(actor))
		return true;
	else // no weapon specific image for this weapon
		return false;
}

METHOD(Rifle, wr_zoomdir, bool(entity thiswep))
{
	return PHYS_INPUT_BUTTON_ATCK2(NULL);
}
#endif
