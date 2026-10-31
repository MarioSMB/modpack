#include "meowmere.qh"

#include "../../monsters/_mod.qh"

#ifdef CSQC
METHOD(Cat, m_tick, void(Cat this, entity actor))
{
	// big and spammy, fade in!
	actor.alphamod = (time - actor.spawntime) * 5;
}
#endif

#ifdef SVQC
void W_FireMeowmere(entity this, .entity weaponentity);

void player_meowmerea4(entity this) { set_animofs(this, anim_player_axattd1, 4, player_run); }
void player_meowmerea3(entity this) { set_animofs(this, anim_player_axattd1, 3, player_meowmerea4); }
void player_meowmerea2(entity this) { set_animofs(this, anim_player_axattd1, 2, player_meowmerea3); }
void player_meowmerea1(entity this) { set_animofs(this, anim_player_axattd1, 1, player_meowmerea2); }

void wep_meowmere_sworda4(entity this) { wep_set_anim(this, 3, w_ready); }
void wep_meowmere_sworda3(entity this) { wep_set_anim(this, 3, wep_meowmere_sworda4); W_FireMeowmere(this.owner, this.weaponentity_fld); }
void wep_meowmere_sworda2(entity this) { wep_set_anim(this, 2, wep_meowmere_sworda3); }
void wep_meowmere_sworda1(entity this) { wep_set_anim(this, 1, wep_meowmere_sworda2); W_Parry_Trigger(this.owner, 0); }

void player_meowmereb4(entity this) { set_animofs(this, anim_player_axattc1, 4, player_run); }
void player_meowmereb3(entity this) { set_animofs(this, anim_player_axattc1, 3, player_meowmereb4); }
void player_meowmereb2(entity this) { set_animofs(this, anim_player_axattc1, 2, player_meowmereb3); }
void player_meowmereb1(entity this) { set_animofs(this, anim_player_axattc1, 1, player_meowmereb2); }

void wep_meowmere_swordb4(entity this) { wep_set_anim(this, 8, w_ready); }
void wep_meowmere_swordb3(entity this) { wep_set_anim(this, 7, wep_meowmere_swordb4); W_FireMeowmere(this.owner, this.weaponentity_fld); }
void wep_meowmere_swordb2(entity this) { wep_set_anim(this, 6, wep_meowmere_swordb3); }
void wep_meowmere_swordb1(entity this) { wep_set_anim(this, 5, wep_meowmere_swordb2); W_Parry_Trigger(this.owner, 0); }

METHOD(Cat, pr_bounce, void(Cat this, entity actor, entity toucher, bool is_touch))
{
	if(!deathmatch)
		T_RadiusDamage(actor, actor.owner, 50, actor.projectiledeathtype, actor.owner);
}

void W_Cat_Fire(entity this, vector org, .entity weaponentity)
{
	// assumes v_ angles are setup

	Projectile ptype = PROJECTILE_CAT;
	//vector org = W_Shotorg(this, weaponentity) + v_right * 8;
	org += v_right * 8;
	vector dir = qc_aim_fromorg(this, org, ptype.m_speed);

	Projectile_Create(ptype, this, org, dir, WEP_MEOWMERE.m_id);
}

void W_FireMeowmere(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);
	vector source = W_Shotorg(this, weaponentity);
	int oldsolid = this.dphitcontentsmask;
	this.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	float arange = 120;
	traceline(source, source + v_forward * arange, false, this);
	this.dphitcontentsmask = oldsolid;
	if(trace_fraction == 1.0)
	{
		W_Cat_Fire(this, source, weaponentity);
		return;
	}
	
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
		float damage = 80;
		T_Damage(trace_ent, this, this, damage, WEP_MEOWMERE.m_id);
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

	W_Cat_Fire(this, source, weaponentity);
}

PRECACHE(Meowmere)
{
	precache_model("progs/v_meowmere.mdl");
	precache_model("progs/g_meowmere.mdl");

	precache_sound("enviro/physics/trcut.wav");
	precache_sound("enviro/physics/axemet1.wav");
	precache_sound("enviro/physics/axemet2.wav");
	precache_sound("enviro/physics/axemet3.wav");
	precache_sound("monsters/juggers/jbent.wav");
}

METHOD(Meowmere, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_meowmereb1(actor);
		sound(actor, CH_WEAPON_SINGLE, SND_MEOWMERE_SWING, 1, ATTN_NORM);
		wep_meowmere_sworda1(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 0.5);
	}
}
METHOD(Meowmere, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Meowmere, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Meowmere, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
