#include "pan.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
PRECACHE(Pan)
{
	precache_model("progs/v_fryingpan.mdl");
	precache_model("progs/g_fryingpan.mdl");

	precache_sound("weapons/fryingpan_wack.wav");
	precache_sound("weapons/ax1.wav");
	precache_sound("cook/dpong.wav");
	precache_sound("knight/sword1.wav");
	precache_sound("cook/ping1.wav");
	precache_sound("cook/ping2.wav");
	precache_sound("cook/pong1.wav");
}

void player_pan4(entity this) { set_animofs(this, anim_player_axatt1, 4, player_run); }
void player_pan3(entity this) { set_animofs(this, anim_player_axatt1, 3, player_pan4); }
void player_pan2(entity this) { set_animofs(this, anim_player_axatt1, 2, player_pan3); }
void player_pan1(entity this) { set_animofs(this, anim_player_axatt1, 1, player_pan2); }


void wep_pan_pan4(entity this) { wep_set_anim(this, 4, w_ready); }
void wep_pan_pan3(entity this) { wep_set_anim(this, 3, wep_pan_pan4); W_FirePan(this.owner, this.weaponentity_fld); }
void wep_pan_pan2(entity this) { wep_set_anim(this, 2, wep_pan_pan3); W_Parry_Trigger(this.owner, 0); }
void wep_pan_pan1(entity this) { wep_set_anim(this, 1, wep_pan_pan2); }

void edie_SpikeTouch(entity this, entity toucher); // TODO
bool Pan_CheckDamage(entity targ, entity inflictor, entity attacker)
{
	if(!Damage_ValidTarget(targ, attacker))
		return false;
	if((!IS_PLAYER(targ) && targ.monsterdef != MON_GREMLIN) || targ.health <= 0 || StatusEffects_active(STATUSEFFECT_Invulnerability, targ))
		return false;
	if(random() > 0.35)
		return false; // low chance to trigger!
	// TODO: once we have proper projectile system check specifically for bullet type damage here
	if(gettouch(inflictor) != spike_touch && gettouch(inflictor) != edie_SpikeTouch)
		return false;

	bool have_pan = false;
	for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		if(targ.(weaponentity).m_weapon == WEP_PAN)
		{
			have_pan = true;
			break;
		}
	}

	if(have_pan)
	{
		string sample = "";
		float r = random();
		if(r < 0.33)
			sample = "cook/ping1.wav";
		else if(r < 0.66)
			sample = "cook/ping2.wav";
		else
			sample = "cook/pong1.wav";
		_sound(targ, CH_SHOTS, sample, 0.25, ATTN_NORM);
		return true;
	}

	return false;
}

void W_FirePan(entity this, .entity weaponentity)
{
	if(W_Parry(this, NULL))
		return;
	
	makevectors(this.v_angle);
	vector source = W_Shotorg(this, weaponentity);
	int oldsolid = this.dphitcontentsmask;
	this.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	traceline(source, source + v_forward*120, false, this);
	this.dphitcontentsmask = oldsolid;
	//if(trace_fraction == 1.0)
		//return;

	if(trace_fraction == 1.0)
		return;

	if(trace_ent && W_Parry(this, trace_ent))
		return;
	
	vector org = trace_endpos - v_forward * 4;

	if(trace_ent.takedamage) // yoder mod, Jan 05 2021
	{
		{
			float r = random();
			if(trace_ent.monsterdef == MON_JUGGERNAUT) // special case: attacks produce unique sound against juggernauts TODO: handle melee attacks in monster pain code
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
			else if(trace_ent.health <= 45)
			{
				_sound(trace_ent, CH_SHOTS, "cook/dpong.wav", 1, ATTN_NORM);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
			}
			else
			{
				float r = bound(0.5, random() * 2, 1.5);
				sound7(trace_ent, CH_SHOTS, "weapons/fryingpan_wack.wav", 1, ATTN_NORM, 100 / r, 0);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
			}
		}
		trace_ent.axhitme = true;
		T_Damage(trace_ent, this, this, 45, WEP_PAN.m_id);
	}
	else
	{	// hit wall
		string sample = "";
		float r = random();
		if(r < 0.33)
			sample = "cook/ping1.wav";
		else if(r < 0.66)
			sample = "cook/ping2.wav";
		else
			sample = "cook/pong1.wav";
		soundat(NULL, org, CH_SHOTS, sample, 1, ATTEN_NORM);
		te_gunshot(org);
	}
}

METHOD(Pan, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		_sound(actor, CH_WEAPON_SINGLE, "weapons/ax1.wav", 1, ATTN_NORM);
		if(IS_PLAYER(actor))
			player_pan1(actor);
		wep_pan_pan1(actor.(weaponentity));
		float fire_delay = 0.6;
		weapon_prepareattack(thiswep, actor, weaponentity, fire_delay);
	}
}
METHOD(Pan, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Pan, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
