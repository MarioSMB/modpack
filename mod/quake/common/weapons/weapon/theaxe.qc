#include "theaxe.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
PRECACHE(TheAxe)
{
	precache_model("progs/v_theaxe.mdl");
	precache_model("progs/g_theaxe.mdl");

	precache_sound("weapons/theaxe_fire.wav");

	precache_sound("hammer/charge_full_guitar.wav");
	precache_sound("hammer/hammer_clang2_guitar.wav");
	precache_sound("weapons/kabong.wav");
	precache_sound("weapons/theaxe_pickup.wav");

	precache_sound("break/wood_i4.wav");
	precache_sound("break/wood_i3.wav");
}

void player_axe1(entity this);
void player_axeb1(entity this);
void player_axec1(entity this);
void player_axed1(entity this);


void wep_theaxe_axe4(entity this) { wep_set_anim(this, 4, w_ready); }
void wep_theaxe_axe3(entity this) { wep_set_anim(this, 3, wep_theaxe_axe4); W_FireTheAxe(this.owner, this.weaponentity_fld); }
void wep_theaxe_axe2(entity this) { wep_set_anim(this, 2, wep_theaxe_axe3); }
void wep_theaxe_axe1(entity this) { wep_set_anim(this, 1, wep_theaxe_axe2); W_Parry_Trigger(this.owner, 0); }

void wep_theaxe_axeb4(entity this) { wep_set_anim(this, 8, w_ready); }
void wep_theaxe_axeb3(entity this) { wep_set_anim(this, 7, wep_theaxe_axeb4); W_FireTheAxe(this.owner, this.weaponentity_fld); }
void wep_theaxe_axeb2(entity this) { wep_set_anim(this, 6, wep_theaxe_axeb3); }
void wep_theaxe_axeb1(entity this) { wep_set_anim(this, 5, wep_theaxe_axeb2); W_Parry_Trigger(this.owner, 0); }

void wep_theaxe_axec4(entity this) { wep_set_anim(this, 4, w_ready); }
void wep_theaxe_axec3(entity this) { wep_set_anim(this, 3, wep_theaxe_axec4); W_FireTheAxe(this.owner, this.weaponentity_fld); }
void wep_theaxe_axec2(entity this) { wep_set_anim(this, 2, wep_theaxe_axec3); }
void wep_theaxe_axec1(entity this) { wep_set_anim(this, 1, wep_theaxe_axec2); W_Parry_Trigger(this.owner, 0); }

void wep_theaxe_axed4(entity this) { wep_set_anim(this, 8, w_ready); }
void wep_theaxe_axed3(entity this) { wep_set_anim(this, 7, wep_theaxe_axed4); W_FireTheAxe(this.owner, this.weaponentity_fld); }
void wep_theaxe_axed2(entity this) { wep_set_anim(this, 6, wep_theaxe_axed3); }
void wep_theaxe_axed1(entity this) { wep_set_anim(this, 5, wep_theaxe_axed2); W_Parry_Trigger(this.owner, 0); }

entity plantera_spike_attack(entity this, vector org, vector dir);
void W_FireTheAxe(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);
	vector source = W_Shotorg(this, weaponentity);

	vector dir = v_forward;
	entity missile = plantera_spike_attack(this, source + v_right * 8, dir);
	missile.projectiledeathtype = WEP_THEAXE.m_id;
	missile.velocity = dir * 400;
	missile.velocity_z += 200;

	int oldsolid = this.dphitcontentsmask;
	this.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	float arange = 100;
	if(this.m_champion && this.m_champion.qcc_meleerange)
		arange *= this.m_champion.qcc_meleerange;
	traceline(source, source + v_forward * arange, false, this);
	this.dphitcontentsmask = oldsolid;
	if(trace_fraction == 1.0)
		return;
	
	vector org = trace_endpos - v_forward * 4;

	if(trace_ent && W_Parry(this, trace_ent))
		return;

	float damage = 69;

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
			else if(trace_ent.health <= damage)
			{
				_sound(trace_ent, CH_SHOTS, "weapons/kabong.wav", 1, ATTN_NORM);
				SpawnBlood(org, '0 0 0', damage, trace_ent);
				SpawnBlood(org, '0 0 0', damage, trace_ent);
				SpawnBlood(org, '0 0 0', damage, trace_ent);
			}
			else
			{
				_sound(trace_ent, CH_SHOTS, "hammer/hammer_clang2_guitar.wav", 1, ATTN_NORM);
				SpawnBlood(org, '0 0 0', damage, trace_ent);
			}
		}
		trace_ent.axhitme = true;
		T_Damage(trace_ent, this, this, damage, WEP_THEAXE.m_id);
	}
	else
	{	// hit wall
		_sound(this, CH_SHOTS, "hammer/charge_full_guitar.wav", 1, ATTN_NORM);
		te_gunshot(org);
	}
}

METHOD(TheAxe, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		float aspeed = 1;
		if(actor.m_champion && actor.m_champion.qcc_meleespeed)
			aspeed *= actor.m_champion.qcc_meleespeed;

		float rp = W_Music_PitchFromAngles(actor.v_angle_x, bound(0.8, random() * 2, 1.3));
		rp *= 1.5; // TODO: per-instrument offsets
		sound7(actor, CH_WEAPON_SINGLE, "weapons/theaxe_fire.wav", 1, ATTN_NORM, rp, 0);

		float r = random();
		if(r < 0.25)
		{
			if(IS_PLAYER(actor))
				player_axe1(actor);
			wep_theaxe_axe1(actor.(weaponentity));
		}
		else if(r<0.5)
		{
			if(IS_PLAYER(actor))
				player_axeb1(actor);
			wep_theaxe_axeb1(actor.(weaponentity));
		}
		else if(r<0.75)
		{
			if(IS_PLAYER(actor))
				player_axec1(actor);
			wep_theaxe_axec1(actor.(weaponentity));
		}
		else
		{
			if(IS_PLAYER(actor))
				player_axed1(actor);
			wep_theaxe_axed1(actor.(weaponentity));
		}
		// no variation with the axe?
		float fire_delay = 0.5;
		weapon_prepareattack(thiswep, actor, weaponentity, fire_delay * aspeed);
	}
}
METHOD(TheAxe, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(TheAxe, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(TheAxe, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
