#include "shield.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
.bool shield_held;

PRECACHE(Shield)
{
	precache_model("progs/v_shield.mdl");
	precache_model("progs/g_shield.mdl");
}

void wep_shield_hold(entity this);
void wep_shield_shield4(entity this) { wep_set_anim(this, 6, w_ready); this.weapon_nextthink = time + 0.05; }
void wep_shield_shield3(entity this) { wep_set_anim(this, 3, wep_shield_hold); this.weapon_nextthink = time + 0.05; W_Parry(this.owner, NULL); }
void wep_shield_shield2(entity this) { wep_set_anim(this, 2, wep_shield_shield3); this.weapon_nextthink = time + 0.05; W_Parry_Trigger(this.owner, 0); }
void wep_shield_shield1(entity this) { wep_set_anim(this, 1, wep_shield_shield2); this.weapon_nextthink = time + 0.05; }

void wep_shield_hold(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;
	if(actor.health < 1 || intermission_running)
		return;

	ATTACK_FINISHED(actor, weaponentity) = time + 1;
	if(PHYS_INPUT_BUTTON_ATCK2(actor))
		wep_set_anim(this, 4, wep_shield_hold);
	else
	{
		ATTACK_FINISHED(actor, weaponentity) = time + 0.2;
		wep_set_anim(this, 5, wep_shield_shield4);
	}
}

METHOD(Shield, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 2)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		_sound(actor, CH_WEAPON_B, "weapons/ax1.wav", 1, ATTN_NORM);
		wep_shield_shield1(actor.(weaponentity));
		float fire_delay = 0.6;
		weapon_prepareattack(thiswep, actor, weaponentity, fire_delay);
	}
}
METHOD(Shield, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Shield, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Shield, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
