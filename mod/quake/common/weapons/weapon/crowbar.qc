#include "crowbar.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
void player_crowbar4(entity this) { set_animofs(this, anim_player_axatt1, 4, player_run); }
void player_crowbar3(entity this) { set_animofs(this, anim_player_axatt1, 3, player_crowbar4); }
void player_crowbar2(entity this) { set_animofs(this, anim_player_axatt1, 2, player_crowbar3); }
void player_crowbar1(entity this) { set_animofs(this, anim_player_axatt1, 1, player_crowbar2); }

void player_crowbarb4(entity this) { set_animofs(this, anim_player_axattb1, 4, player_run); }
void player_crowbarb3(entity this) { set_animofs(this, anim_player_axattb1, 3, player_crowbarb4); }
void player_crowbarb2(entity this) { set_animofs(this, anim_player_axattb1, 2, player_crowbarb3); }
void player_crowbarb1(entity this) { set_animofs(this, anim_player_axattb1, 1, player_crowbarb2); }

void player_crowbarc4(entity this) { set_animofs(this, anim_player_axattc1, 4, player_run); }
void player_crowbarc3(entity this) { set_animofs(this, anim_player_axattc1, 3, player_crowbarc4); }
void player_crowbarc2(entity this) { set_animofs(this, anim_player_axattc1, 2, player_crowbarc3); }
void player_crowbarc1(entity this) { set_animofs(this, anim_player_axattc1, 1, player_crowbarc2); }

void player_crowbard4(entity this) { set_animofs(this, anim_player_axattd1, 4, player_run); }
void player_crowbard3(entity this) { set_animofs(this, anim_player_axattd1, 3, player_crowbard4); }
void player_crowbard2(entity this) { set_animofs(this, anim_player_axattd1, 2, player_crowbard3); }
void player_crowbard1(entity this) { set_animofs(this, anim_player_axattd1, 1, player_crowbard2); }


void W_FireCrowbar(entity this, .entity weaponentity);
void wep_crowbar_bar4(entity this) { wep_set_anim(this, 4, w_ready); }
void wep_crowbar_bar3(entity this) { wep_set_anim(this, 3, wep_crowbar_bar4); W_FireCrowbar(this.owner, this.weaponentity_fld); }
void wep_crowbar_bar2(entity this) { wep_set_anim(this, 2, wep_crowbar_bar3); }
void wep_crowbar_bar1(entity this) { wep_set_anim(this, 1, wep_crowbar_bar2); }

void wep_crowbar_barb4(entity this) { wep_set_anim(this, 8, w_ready); }
void wep_crowbar_barb3(entity this) { wep_set_anim(this, 7, wep_crowbar_barb4); W_FireCrowbar(this.owner, this.weaponentity_fld); }
void wep_crowbar_barb2(entity this) { wep_set_anim(this, 6, wep_crowbar_barb3); }
void wep_crowbar_barb1(entity this) { wep_set_anim(this, 5, wep_crowbar_barb2); }

void wep_crowbar_barc4(entity this) { wep_set_anim(this, 4, w_ready); }
void wep_crowbar_barc3(entity this) { wep_set_anim(this, 3, wep_crowbar_barc4); W_FireCrowbar(this.owner, this.weaponentity_fld); }
void wep_crowbar_barc2(entity this) { wep_set_anim(this, 2, wep_crowbar_barc3); }
void wep_crowbar_barc1(entity this) { wep_set_anim(this, 1, wep_crowbar_barc2); }

void wep_crowbar_bard4(entity this) { wep_set_anim(this, 8, w_ready); }
void wep_crowbar_bard3(entity this) { wep_set_anim(this, 7, wep_crowbar_bard4); W_FireCrowbar(this.owner, this.weaponentity_fld); }
void wep_crowbar_bard2(entity this) { wep_set_anim(this, 6, wep_crowbar_bard3); }
void wep_crowbar_bard1(entity this) { wep_set_anim(this, 5, wep_crowbar_bard2); }

void W_FireCrowbar(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);
	vector source = W_Shotorg(this, weaponentity);
	int oldsolid = this.dphitcontentsmask;
	this.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	float arange = 110;
	traceline(source, source + v_forward * arange, false, this);
	this.dphitcontentsmask = oldsolid;
	if(trace_fraction == 1.0)
		return;
	
	vector org = trace_endpos - v_forward * 4;

	if(trace_ent.takedamage) // yoder mod, Jan 05 2021
	{
		float damage = 20;

		{
			float r = random();
			if(trace_ent.monsterdef == MON_JUGGERNAUT) // special case: axe attacks produce unique sound against juggernauts TODO: handle melee attacks in monster pain code
			{
				damage *= 2;
				_sound(this, CH_WEAPON_SINGLE, "monsters/juggers/jbent.wav", 1, ATTN_NORM);
			}
			else if(trace_ent.monsterdef && (trace_ent.monsterdef.spawnflags & MON_FLAG_METAL))
			{
				damage *= 2;

				if(r < 0.3)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
				else if(r < 0.6)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
				else
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
			}
			else if(IS_PLAYER(trace_ent) && trace_ent.armorvalue > 0)
			{
				damage *= 1.5;

				if(r < 0.3)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
				else if(r < 0.6)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
				else
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
			}
			else
			{
				_sound(trace_ent, CH_SHOTS, "weapons/cbar_hitbod1.wav", 1, ATTN_NORM);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
			}
		}
		trace_ent.axhitme = true;
		T_Damage(trace_ent, this, this, damage, WEP_CROWBAR.m_id);
	}
	else
	{	// hit wall
		float sndpitch = 100 / bound(0.75, random() * 2, 1.25);
		sound7(this, CH_SHOTS, "weapons/cbar_hit1.wav", 1, ATTN_NORM, sndpitch, 0);
		te_gunshot(org);
	}

	// hit something, cut anim short
	this.(weaponentity).count = 1;
}

PRECACHE(Crowbar)
{
	precache_model("progs/v_crowbar.mdl");
	precache_model("progs/g_crowbar.mdl");

	precache_sound("weapons/cbar_hit1.wav");
	precache_sound("weapons/cbar_hitbod1.wav");
	precache_sound("weapons/cbar_miss1.wav");
}

METHOD(Crowbar, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_crowbar1(actor);
		actor.(weaponentity).m_frame = 0;
		actor.(weaponentity).count = 0;
		_sound(actor, CH_WEAPON_SINGLE, "weapons/cbar_miss1.wav", 1, ATTN_NORM);
		float r = random();
		if(r < 0.25)
		{
			if(IS_PLAYER(actor))
				player_crowbar1(actor);
			wep_crowbar_bar1(actor.(weaponentity));
		}
		else if(r < 0.5)
		{
			if(IS_PLAYER(actor))
				player_crowbarb1(actor);
			wep_crowbar_barb1(actor.(weaponentity));
		}
		else if(r < 0.75)
		{
			if(IS_PLAYER(actor))
				player_crowbarc1(actor);
			wep_crowbar_barc1(actor.(weaponentity));
		}
		else
		{
			if(IS_PLAYER(actor))
				player_crowbard1(actor);
			wep_crowbar_bard1(actor.(weaponentity));
		}

		weapon_prepareattack(thiswep, actor, weaponentity, 0.4);
	}
}
METHOD(Crowbar, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Crowbar, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Crowbar, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
