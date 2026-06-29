#include "taco.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
void player_axeb1(entity this);
void W_ConsumeTaco(entity this, .entity weaponentity);

float autocvar_sv_quake_taco_healing = 5;
float autocvar_sv_quake_taco_time = 10;

void wep_taco_taco11(entity this) { wep_set_anim(this, 11, w_ready); }
void wep_taco_taco10(entity this) { wep_set_anim(this, 10, wep_taco_taco11); }
void wep_taco_taco9(entity this) { wep_set_anim(this, 9, wep_taco_taco10); W_ConsumeTaco(this.owner, this.weaponentity_fld); }
void wep_taco_taco8(entity this) { wep_set_anim(this, 8, wep_taco_taco9); }
void wep_taco_taco7(entity this) { wep_set_anim(this, 7, wep_taco_taco8); }
void wep_taco_taco6(entity this) { wep_set_anim(this, 6, wep_taco_taco7); }
void wep_taco_taco5(entity this) { wep_set_anim(this, 5, wep_taco_taco6); }
void wep_taco_taco4(entity this) { wep_set_anim(this, 4, wep_taco_taco5); }
void wep_taco_taco3(entity this) { wep_set_anim(this, 3, wep_taco_taco4); }
void wep_taco_taco2(entity this) { wep_set_anim(this, 2, wep_taco_taco3); }
void wep_taco_taco1(entity this) { wep_set_anim(this, 1, wep_taco_taco2); }

void W_ConsumeTaco(entity this, .entity weaponentity)
{
	if(this.tank)
		return;
	if(this.m_transform)
		return;
	
	if(!T_Heal(this, autocvar_sv_quake_taco_healing, true))
		return;

	this.healthrot_nextcheck = time + 2;

	//particle(this.origin, '0 0 0', 26, 32);
	Send_Effect(EFFECT_QCC_MUSHROOM, this.origin, '0 0 0', 1);

	if(this.m_champion == CHAMPION_CrazyDave)
		CrazyDave_reset(this);

	StatusEffects_apply(STATUSEFFECT_TacoPower, this, time + autocvar_sv_quake_taco_time, 0);

	// holy taco cure!
	if(StatusEffects_active(STATUSEFFECT_Poisoned, this))
		StatusEffects_remove(STATUSEFFECT_Poisoned, this, STATUSEFFECT_REMOVE_NORMAL);
}

PRECACHE(Taco)
{
	precache_model("progs/v_taco.mdl");
	precache_model("progs/g_taco.mdl");

	precache_sound("player_crazydave/talk12.wav");
}

METHOD(Taco, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_axeb1(actor);
		_sound(actor, CH_WEAPON_SINGLE, "player_crazydave/talk12.wav", 1, ATTN_NORM);
		wep_taco_taco1(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 2);
	}
}
METHOD(Taco, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Taco, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Taco, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
