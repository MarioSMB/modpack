#include "bongos.qh"

#ifdef SVQC
PRECACHE(Bongos)
{
	precache_model("progs/v_bongos.mdl");
	precache_model("progs/g_bongos.mdl");

	precache_model("progs/piano_musicnote_white.mdl");
	precache_model("progs/x9_burst_6sided_brightyellow.mdl");
}

.float bongos_smoketime;

void W_FireBongos(entity this, .entity weaponentity)
{
	this.punchangle_x = -2;
	W_TakeMana(this, 5);

	//vector org = gettaginfo(this.(weaponentity), 0);
	vector org = this.origin + this.view_ofs;
	vector offset = org + v_up * -8 + v_forward * 14;
	if(time > this.(weaponentity).bongos_smoketime)
	{
		// FIXME gettaginfo(this.(weaponentity), 0) doesn't return the real origin of the weapon
		Send_Effect(EFFECT_SMOKE_RING, offset, v_forward * 50, 1);
		this.(weaponentity).bongos_smoketime = time + 0.2;
	}

	T_RadiusDamage(this, this, 100, WEP_BONGOS.m_id, this);

	float r = W_Music_PitchFromAngles(this.v_angle_x, bound(0.8, random() * 2, 1.3));
	r *= 1; // TODO: per-instrument offsets
	sound7(this, CH_WEAPON_SINGLE, SND(BONGOS_FIRE), 1, ATTN_NORM, r, 0);

	// visual note
	entity musicnote = new(musicnote);
	makevectors(this.v_angle);
	setorigin(musicnote, this.origin + v_forward * 25 + v_right * ((random() > 0.5) ? 12 : -12));
	_setmodel(musicnote, "progs/piano_musicnote_white.mdl");
	musicnote.colormod = '0.9 0.6 0.4';
	musicnote.scale = 0.75;
	setsize(musicnote, '0 0 0', '0 0 0');
	musicnote.angles = '0 1 0' * this.angles_y;
	set_movetype(musicnote, MOVETYPE_NOCLIP);
	SUB_SetFade(musicnote, time + 0.1, 0.5);
	musicnote.velocity = '0 0 200';
}

METHOD(Bongos, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity) && STAT(MANA, actor) >= 5)
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_generic_shot1(actor.(weaponentity));
		W_FireBongos(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.25);
	}
}
METHOD(Bongos, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // doesn't use ammo in the traditional sense
}
METHOD(Bongos, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Bongos, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
