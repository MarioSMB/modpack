#include "plane.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
void wep_plane_frame(entity this)
{
	this.weapon_nextthink = time + 0.05;
}

void wep_plane_plane52(entity this) { wep_set_anim(this, 52, w_ready); wep_plane_frame(this); }
void wep_plane_plane51(entity this) { wep_set_anim(this, 51, wep_plane_plane52); wep_plane_frame(this); }
void wep_plane_plane50(entity this) { wep_set_anim(this, 50, wep_plane_plane51); wep_plane_frame(this); }
void wep_plane_plane49(entity this) { wep_set_anim(this, 49, wep_plane_plane50); wep_plane_frame(this); }
void wep_plane_plane48(entity this) { wep_set_anim(this, 48, wep_plane_plane49); wep_plane_frame(this); }
void wep_plane_plane47(entity this) { wep_set_anim(this, 47, wep_plane_plane48); wep_plane_frame(this); }
void wep_plane_plane46(entity this) { wep_set_anim(this, 46, wep_plane_plane47); wep_plane_frame(this); }
void wep_plane_plane45(entity this) { wep_set_anim(this, 45, wep_plane_plane46); wep_plane_frame(this); }
void wep_plane_plane44(entity this) { wep_set_anim(this, 44, wep_plane_plane45); wep_plane_frame(this); }
void wep_plane_plane43(entity this) { wep_set_anim(this, 43, wep_plane_plane44); wep_plane_frame(this); }
void wep_plane_plane42(entity this) { wep_set_anim(this, 42, wep_plane_plane43); wep_plane_frame(this); }
void wep_plane_plane41(entity this) { wep_set_anim(this, 41, wep_plane_plane42); wep_plane_frame(this); }
void wep_plane_plane40(entity this) { wep_set_anim(this, 40, wep_plane_plane41); wep_plane_frame(this); }
void wep_plane_plane39(entity this) { wep_set_anim(this, 39, wep_plane_plane40); wep_plane_frame(this); }
void wep_plane_plane38(entity this) { wep_set_anim(this, 38, wep_plane_plane39); wep_plane_frame(this); }
void wep_plane_plane37(entity this) { wep_set_anim(this, 37, wep_plane_plane38); wep_plane_frame(this); }
void wep_plane_plane36(entity this) { wep_set_anim(this, 36, wep_plane_plane37); wep_plane_frame(this); }
void wep_plane_plane35(entity this) { wep_set_anim(this, 35, wep_plane_plane36); wep_plane_frame(this); }
void wep_plane_plane34(entity this) { wep_set_anim(this, 34, wep_plane_plane35); wep_plane_frame(this); }
void wep_plane_plane33(entity this) { wep_set_anim(this, 33, wep_plane_plane34); wep_plane_frame(this); }
void wep_plane_plane32(entity this) { wep_set_anim(this, 32, wep_plane_plane33); wep_plane_frame(this); }
void wep_plane_plane31(entity this) { wep_set_anim(this, 31, wep_plane_plane32); wep_plane_frame(this); }
void wep_plane_plane30(entity this) { wep_set_anim(this, 30, wep_plane_plane31); wep_plane_frame(this); }
void wep_plane_plane29(entity this) { wep_set_anim(this, 29, wep_plane_plane30); wep_plane_frame(this); }
void wep_plane_plane28(entity this) { wep_set_anim(this, 28, wep_plane_plane29); wep_plane_frame(this); }
void wep_plane_plane27(entity this) { wep_set_anim(this, 27, wep_plane_plane28); wep_plane_frame(this); }
void wep_plane_plane26(entity this) { wep_set_anim(this, 26, wep_plane_plane27); wep_plane_frame(this); }
void wep_plane_plane25(entity this) { wep_set_anim(this, 25, wep_plane_plane26); wep_plane_frame(this); }
void wep_plane_plane24(entity this) { wep_set_anim(this, 24, wep_plane_plane25); wep_plane_frame(this); }
void wep_plane_plane23(entity this) { wep_set_anim(this, 23, wep_plane_plane24); wep_plane_frame(this); }
void wep_plane_plane22(entity this) { wep_set_anim(this, 22, wep_plane_plane23); wep_plane_frame(this); }
void wep_plane_plane21(entity this) { wep_set_anim(this, 21, wep_plane_plane22); wep_plane_frame(this); }
void wep_plane_plane20(entity this) { wep_set_anim(this, 20, wep_plane_plane21); wep_plane_frame(this); }
void wep_plane_plane19(entity this) { wep_set_anim(this, 19, wep_plane_plane20); wep_plane_frame(this); }
void wep_plane_plane18(entity this) { wep_set_anim(this, 18, wep_plane_plane19); wep_plane_frame(this); }
void wep_plane_plane17(entity this) { wep_set_anim(this, 17, wep_plane_plane18); wep_plane_frame(this); }
void wep_plane_plane16(entity this) { wep_set_anim(this, 16, wep_plane_plane17); _sound(this.owner, CH_WEAPON_SINGLE, "weapons/paperfolding1.wav", 1, ATTN_NORM);}
void wep_plane_plane15(entity this) { wep_set_anim(this, 15, wep_plane_plane16); wep_plane_frame(this); }
void wep_plane_plane14(entity this) { wep_set_anim(this, 14, wep_plane_plane15); wep_plane_frame(this); }
void wep_plane_plane13(entity this) { wep_set_anim(this, 13, wep_plane_plane14); wep_plane_frame(this); }
void wep_plane_plane12(entity this) { wep_set_anim(this, 12, wep_plane_plane13); wep_plane_frame(this); }
void wep_plane_plane11(entity this) { wep_set_anim(this, 11, wep_plane_plane12); wep_plane_frame(this); }
void wep_plane_plane10(entity this) { wep_set_anim(this, 10, wep_plane_plane11); wep_plane_frame(this); }
void wep_plane_plane9(entity this) { wep_set_anim(this, 9, wep_plane_plane10); wep_plane_frame(this); }
void wep_plane_plane8(entity this) { wep_set_anim(this, 8, wep_plane_plane9); wep_plane_frame(this); }
void wep_plane_plane7(entity this) { wep_set_anim(this, 7, wep_plane_plane8); wep_plane_frame(this); }
void wep_plane_plane6(entity this) { wep_set_anim(this, 6, wep_plane_plane7); wep_plane_frame(this); }
void wep_plane_plane5(entity this) { wep_set_anim(this, 5, wep_plane_plane6); wep_plane_frame(this); }
void wep_plane_plane4(entity this) { wep_set_anim(this, 4, wep_plane_plane5); wep_plane_frame(this); }
void wep_plane_plane3(entity this) { wep_set_anim(this, 3, wep_plane_plane4); wep_plane_frame(this); }
void wep_plane_plane2(entity this) { wep_set_anim(this, 2, wep_plane_plane3); wep_plane_frame(this); }
void wep_plane_plane1(entity this) { wep_set_anim(this, 1, wep_plane_plane2); wep_plane_frame(this); }

PRECACHE(Plane)
{
	//precache_model("progs/g_paperplane.mdl");
	precache_model("progs/v_paperplane.mdl");

	precache_model("progs/paperplane.mdl");

	precache_sound("weapons/paperfolding1.wav");
	precache_sound("weapons/momwoosh1.wav");
	precache_sound("weapons/momwoosh2.wav");
	precache_sound("weapons/momwoosh3.wav");
	precache_sound("weapons/momwoosh4.wav");
}

void PlaneScrewUp(entity this)
{
	if(time >= this.wait)
	{
		delete(this);
		return;
	}

	makevectors(this.angles);
	this.velocity = ((this.velocity + ((v_right * 60.000) * crandom())) + ((v_up * 60.000) * crandom()));
	//this.velocity = ((this.velocity + ((v_right * 121.000) * crandom ())) + ((v_up * 121.000) * crandom ()));
	this.nextthink = time + 0.1; // screw up fast //0.08
	setthink(this, PlaneScrewUp);
}

void T_PaperPlaneTouch(entity this, entity toucher)
{
	this.velocity_z = -100;    //plane upward speed=500
	this.velocity_x = -100 + (random() * 20);    //plane x and y velocitys..	    // plane.velocity_x = -100 + (random() * 200);
	this.velocity_y = -100 + (random() * 20);    //are randomish
	this.avelocity = '300 300 300';    //plane rotating velocity
	this.angles = vectoangles(this.velocity);
	this.nextthink = time + 30; // stay for 30 seconds then remove
	setthink(this, SUB_Remove);

	if(toucher.takedamage && vdist(this.velocity, >, 0))
		T_Damage(toucher, this, this.owner, 30, this.projectiledeathtype); 
}

void W_Plane_Fire(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);

	vector org = W_Shotorg(this, weaponentity) - '0 0 16';
	vector dir = qc_aim(this, 1000);

	entity missile = spawn();
	missile.flags = FL_PROJECTILE;
	missile.classname = "paperplane";
	missile.owner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_CORPSE;
	missile.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	missile.velocity = dir * 500;
	missile.angles = vectoangles(missile.velocity);
	missile.weaponentity_fld = weaponentity;
	missile.projectiledeathtype = WEP_PLANE.m_id;
	missile.clipgroup = this.clipgroup;
	setthink(missile, PlaneScrewUp);
	missile.nextthink = time + 0.1;
	settouch(missile, T_PaperPlaneTouch);
	missile.wait = time + 30;

	_setmodel(missile, "progs/paperplane.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, org);

	float r = random();
	if(r < 0.25)
		_sound(this, CH_WEAPON_SINGLE, "weapons/momwoosh1.wav", 1, ATTN_NORM);
	else if (r < 0.5)
		_sound(this, CH_WEAPON_SINGLE, "weapons/momwoosh2.wav", 1, ATTN_NORM);
	else if (r < 0.75)
		_sound(this, CH_WEAPON_SINGLE, "weapons/momwoosh3.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "weapons/momwoosh4.wav", 1, ATTN_NORM);
}

METHOD(Plane, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_plane_plane1(actor.(weaponentity));
		W_Plane_Fire(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 2);
	}
}
METHOD(Plane, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Plane, wr_suicidemessage, Notification(entity thiswep))
{
	return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Plane, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
