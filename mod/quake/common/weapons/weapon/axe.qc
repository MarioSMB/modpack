#include "axe.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
void player_axe4(entity this) { set_animofs(this, anim_player_axatt1, 4, player_run); }
void player_axe3(entity this) { set_animofs(this, anim_player_axatt1, 3, player_axe4); }
void player_axe2(entity this) { set_animofs(this, anim_player_axatt1, 2, player_axe3); }
void player_axe1(entity this) { set_animofs(this, anim_player_axatt1, 1, player_axe2); }

void player_axeb4(entity this) { set_animofs(this, anim_player_axattb1, 4, player_run); }
void player_axeb3(entity this) { set_animofs(this, anim_player_axattb1, 3, player_axeb4); }
void player_axeb2(entity this) { set_animofs(this, anim_player_axattb1, 2, player_axeb3); }
void player_axeb1(entity this) { set_animofs(this, anim_player_axattb1, 1, player_axeb2); }

void player_axec4(entity this) { set_animofs(this, anim_player_axattc1, 4, player_run); }
void player_axec3(entity this) { set_animofs(this, anim_player_axattc1, 3, player_axec4); }
void player_axec2(entity this) { set_animofs(this, anim_player_axattc1, 2, player_axec3); }
void player_axec1(entity this) { set_animofs(this, anim_player_axattc1, 1, player_axec2); }

void player_axed4(entity this) { set_animofs(this, anim_player_axattd1, 4, player_run); }
void player_axed3(entity this) { set_animofs(this, anim_player_axattd1, 3, player_axed4); }
void player_axed2(entity this) { set_animofs(this, anim_player_axattd1, 2, player_axed3); }
void player_axed1(entity this) { set_animofs(this, anim_player_axattd1, 1, player_axed2); }


void wep_axe_axe4(entity this) { wep_set_anim(this, 4, w_ready); }
void wep_axe_axe3(entity this) { wep_set_anim(this, 3, wep_axe_axe4); W_FireAxe(this.owner, this.weaponentity_fld); }
void wep_axe_axe2(entity this) { wep_set_anim(this, 2, wep_axe_axe3); }
void wep_axe_axe1(entity this) { wep_set_anim(this, 1, wep_axe_axe2); W_Parry_Trigger(this.owner, 0); }

void wep_axe_axeb4(entity this) { wep_set_anim(this, 8, w_ready); }
void wep_axe_axeb3(entity this) { wep_set_anim(this, 7, wep_axe_axeb4); W_FireAxe(this.owner, this.weaponentity_fld); }
void wep_axe_axeb2(entity this) { wep_set_anim(this, 6, wep_axe_axeb3); }
void wep_axe_axeb1(entity this) { wep_set_anim(this, 5, wep_axe_axeb2); W_Parry_Trigger(this.owner, 0); }

void wep_axe_axec4(entity this) { wep_set_anim(this, 4, w_ready); }
void wep_axe_axec3(entity this) { wep_set_anim(this, 3, wep_axe_axec4); W_FireAxe(this.owner, this.weaponentity_fld); }
void wep_axe_axec2(entity this) { wep_set_anim(this, 2, wep_axe_axec3); }
void wep_axe_axec1(entity this) { wep_set_anim(this, 1, wep_axe_axec2); W_Parry_Trigger(this.owner, 0); }

void wep_axe_axed4(entity this) { wep_set_anim(this, 8, w_ready); }
void wep_axe_axed3(entity this) { wep_set_anim(this, 7, wep_axe_axed4); W_FireAxe(this.owner, this.weaponentity_fld); }
void wep_axe_axed2(entity this) { wep_set_anim(this, 6, wep_axe_axed3); }
void wep_axe_axed1(entity this) { wep_set_anim(this, 5, wep_axe_axed2); W_Parry_Trigger(this.owner, 0); }

void W_FireAxe(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);
	vector source = W_Shotorg(this, weaponentity);
	int oldsolid = this.dphitcontentsmask;
	this.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	float arange = 64;
	if(this.m_champion && this.m_champion.qcc_meleerange)
		arange *= this.m_champion.qcc_meleerange;
	traceline(source, source + v_forward * arange, false, this);
	this.dphitcontentsmask = oldsolid;
	if(trace_fraction == 1.0)
		return;
	
	vector org = trace_endpos - v_forward * 4;

	if(trace_ent && W_Parry(this, trace_ent))
		return;

	if(trace_ent.takedamage) // yoder mod, Jan 05 2021
	{
		{
			float r = random();
			if(trace_ent.monsterdef == MON_JUGGERNAUT) // special case: axe attacks produce unique sound against juggernauts TODO: handle melee attacks in monster pain code
				_sound(this, CH_WEAPON_SINGLE, "monsters/juggers/jbent.wav", 1, ATTN_NORM);
			else if(trace_ent.monsterdef && (trace_ent.monsterdef.spawnflags & MON_FLAG_METAL))
			{
				if(r < 0.3)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
				else if(r < 0.6)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
				else
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
			}
			else if(IS_PLAYER(trace_ent) && trace_ent.armorvalue > 0)
			{
				if(r < 0.3)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
				else if(r < 0.6)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
				else
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
			}
			else if(r < 0.5)
			{
				_sound(trace_ent, CH_SHOTS, "enviro/physics/axecut1.wav", 1, ATTN_NORM);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
			}
			else
			{
				_sound(trace_ent, CH_SHOTS, "enviro/physics/axecut2.wav", 1, ATTN_NORM);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
			}
		}
		trace_ent.axhitme = true;
		T_Damage(trace_ent, this, this, 20, WEP_AXE.m_id);
	}
	else
	{	// hit wall
		_sound(this, CH_SHOTS, "player/axhit2.wav", 1, ATTN_NORM);
		te_gunshot(org);
	}
}

METHOD(Axe, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		float aspeed = 1;
		if(actor.m_champion && actor.m_champion.qcc_meleespeed)
			aspeed *= actor.m_champion.qcc_meleespeed;
		float r = random();
		if(random() < 0.7)
			_sound(actor, CH_WEAPON_SINGLE, "weapons/ax1.wav", 1, ATTN_NORM);
		else
			_sound(actor, CH_WEAPON_SINGLE, "zombie/z_shot1.wav", 1, ATTN_NORM);
		if(autocvar_horde && (serverflags & SIGIL_E3)) // horde rune behavior
		{
			if(actor.axe_hit_chain >= 2 && time < actor.axe_hit_chain_time)
			{
				// vertical CHOP
				if(r < 0.5)
				{
					if(IS_PLAYER(actor))
						player_axe1(actor);
					wep_axe_axe1(actor.(weaponentity));
				}
				else
				{
					if(IS_PLAYER(actor))
						player_axec1(actor);
					wep_axe_axec1(actor.(weaponentity));
				}
				weapon_prepareattack(thiswep, actor, weaponentity, 0.8 * aspeed); // long recover
			}
			else
			{
				// diagonal SWEEP
				if(r < 0.5)
				{
					if(IS_PLAYER(actor))
						player_axeb1(actor);
					wep_axe_axeb1(actor.(weaponentity));
				}
				else
				{
					if(IS_PLAYER(actor))
						player_axed1(actor);
					wep_axe_axed1(actor.(weaponentity));
				}
						
				if(actor.axe_hit_chain > 1)
					weapon_prepareattack(thiswep, actor, weaponentity, 0.6 * aspeed);
				else
					weapon_prepareattack(thiswep, actor, weaponentity, 0.4 * aspeed);
							
			}
		}
		else
		{
			if(r < 0.25)
			{
				if(IS_PLAYER(actor))
					player_axe1(actor);
				wep_axe_axe1(actor.(weaponentity));
			}
			else if(r<0.5)
			{
				if(IS_PLAYER(actor))
					player_axeb1(actor);
				wep_axe_axeb1(actor.(weaponentity));
			}
			else if(r<0.75)
			{
				if(IS_PLAYER(actor))
					player_axec1(actor);
				wep_axe_axec1(actor.(weaponentity));
			}
			else
			{
				if(IS_PLAYER(actor))
					player_axed1(actor);
				wep_axe_axed1(actor.(weaponentity));
			}
			float fire_delay = 0.5;
			if(random() < 0.5)
				fire_delay = 0.4;
			weapon_prepareattack(thiswep, actor, weaponentity, fire_delay * aspeed);
		}
	}
}
METHOD(Axe, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Axe, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Axe, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
