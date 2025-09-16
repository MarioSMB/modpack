#include "sword.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
void W_FireSword(entity this, .entity weaponentity);

void player_sworda4(entity this) { set_animofs(this, anim_player_axattd1, 4, player_run); }
void player_sworda3(entity this) { set_animofs(this, anim_player_axattd1, 3, player_sworda4); }
void player_sworda2(entity this) { set_animofs(this, anim_player_axattd1, 2, player_sworda3); }
void player_sworda1(entity this) { set_animofs(this, anim_player_axattd1, 1, player_sworda2); }

void wep_sword_sworda4(entity this) { wep_set_anim(this, 3, w_ready); }
void wep_sword_sworda3(entity this) { wep_set_anim(this, 2, wep_sword_sworda4); W_FireSword(this.owner, this.weaponentity_fld); }
void wep_sword_sworda2(entity this) { wep_set_anim(this, 1, wep_sword_sworda3); }
void wep_sword_sworda1(entity this) { wep_set_anim(this, 0, wep_sword_sworda2); W_Parry_Trigger(this.owner, 0); }

void player_swordb4(entity this) { set_animofs(this, anim_player_axattc1, 4, player_run); }
void player_swordb3(entity this) { set_animofs(this, anim_player_axattc1, 3, player_swordb4); }
void player_swordb2(entity this) { set_animofs(this, anim_player_axattc1, 2, player_swordb3); }
void player_swordb1(entity this) { set_animofs(this, anim_player_axattc1, 1, player_swordb2); }

void wep_sword_swordb4(entity this) { wep_set_anim(this, 8, w_ready); }
void wep_sword_swordb3(entity this) { wep_set_anim(this, 7, wep_sword_swordb4); W_FireSword(this.owner, this.weaponentity_fld); }
void wep_sword_swordb2(entity this) { wep_set_anim(this, 6, wep_sword_swordb3); }
void wep_sword_swordb1(entity this) { wep_set_anim(this, 5, wep_sword_swordb2); W_Parry_Trigger(this.owner, 0); }

void W_FireSword(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);
	vector source = W_Shotorg(this, weaponentity);
	int oldsolid = this.dphitcontentsmask;
	this.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	float arange = 120;
	traceline(source, source + v_forward * arange, false, this);
	this.dphitcontentsmask = oldsolid;
	if(trace_fraction == 1.0)
		return;
	
	vector org = trace_endpos - v_forward * 4;

	if(trace_ent && W_Parry(this, trace_ent))
		return;

	float r = random();
	if(trace_ent.takedamage) // yoder mod, Jan 05 2021
	{
		{
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
			else
			{
				_sound(trace_ent, CH_SHOTS, "enviro/physics/trcut.wav", 1, ATTN_NORM);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
			}
		}
		trace_ent.axhitme = true;
		float damage = 60;
		T_Damage(trace_ent, this, this, damage, WEP_SWORD.m_id);
	}
	else
	{	// hit wall
		if(r < 0.3)
			_sound(this, CH_SHOTS, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
		else if(r < 0.6)
			_sound(this, CH_SHOTS, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_SHOTS, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
		te_gunshot(org);
	}
}

PRECACHE(Sword)
{
	precache_model("progs/v_sword.mdl");
	precache_model("progs/g_sword.mdl");

	precache_sound("enviro/physics/trcut.wav");
	precache_sound("enviro/physics/axemet1.wav");
	precache_sound("enviro/physics/axemet2.wav");
	precache_sound("enviro/physics/axemet3.wav");
	precache_sound("monsters/juggers/jbent.wav");
}

METHOD(Sword, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		bool altframe = (random() < 0.5);
		if(!IS_ONGROUND(actor))
			altframe = false;
		if(IS_PLAYER(actor))
		{
			if(altframe)
				player_swordb1(actor);
			else
				player_sworda1(actor);
		}
		sound(actor, CH_WEAPON_SINGLE, SND_SWORD_SWING, 1, ATTN_NORM);
		if(altframe)
			wep_sword_swordb1(actor.(weaponentity));
		else
			wep_sword_sworda1(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 0.6);
	}
}
METHOD(Sword, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Sword, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Sword, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
