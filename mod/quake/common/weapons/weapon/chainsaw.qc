#include "axe.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC

void player_chainsaw6(entity this) { set_animofs(this, anim_player_shotatt1, 2, player_run); }
void player_chainsaw5(entity this) { set_animofs(this, anim_player_shotatt1, 1, player_chainsaw6); }
void player_chainsaw4(entity this) { set_animofs(this, anim_player_shotatt1, 2, player_chainsaw5); }
void player_chainsaw3(entity this) { set_animofs(this, anim_player_shotatt1, 1, player_chainsaw4); }
void player_chainsaw2(entity this) { set_animofs(this, anim_player_shotatt1, 2, player_chainsaw3); }
void player_chainsaw1(entity this) { set_animofs(this, anim_player_shotatt1, 1, player_chainsaw2); }

void wep_chainsaw_chainsaw6(entity this) { wep_set_anim(this, 10, w_ready); }
void wep_chainsaw_chainsaw5(entity this) { wep_set_anim(this, 9, wep_chainsaw_chainsaw6); W_FireSaw(this.owner, this.weaponentity_fld); }
void wep_chainsaw_chainsaw4(entity this)
{
	wep_set_anim(this, 8, wep_chainsaw_chainsaw5);
	if(!this.owner.button0)
	{
		w_ready(this);
		return;
	}
}
void wep_chainsaw_chainsaw3(entity this) { wep_set_anim(this, 7, wep_chainsaw_chainsaw4); W_FireSaw(this.owner, this.weaponentity_fld); }
void wep_chainsaw_chainsaw2(entity this)
{
	wep_set_anim(this, 6, wep_chainsaw_chainsaw3);
	if(!this.owner.button0)
	{
		w_ready(this);
		return;
	}
}
void wep_chainsaw_chainsaw1(entity this) { wep_set_anim(this, 5, wep_chainsaw_chainsaw2); W_FireSaw(this.owner, this.weaponentity_fld); }

void W_FireSaw(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);
	vector source = W_Shotorg(this, weaponentity) - v_up * 6;
	int oldsolid = this.dphitcontentsmask;
	this.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	traceline(source, source + v_forward*64, MOVE_NORMAL, this);
	this.dphitcontentsmask = oldsolid;
	if(trace_fraction == 1.0)
		return;
	
	vector org = trace_endpos - v_forward*4;
	
	entity ent = trace_ent;
	
	if(ent.takedamage)
	{
		ent.axhitme = 2;
		SpawnBlood(trace_endpos, '0 0 5', 20, ent);

		if(IS_MONSTER(ent) || IS_PLAYER(ent))
		{ // only spawns gibs for monsters and players
			if(!(ent.monsterdef.spawnflags & MON_FLAG_METAL)) 
				SpawnMeatSpray(this, this.origin + v_forward*16, ((random()*300) - 150) * v_right + (100 * v_forward));
			else
				SpawnBitSpray(this, this.origin + v_forward*16, ((random()*300) - 150) * v_right + (100 * v_forward));
		}

		if(deathmatch == 0)
			T_Damage(ent, this, this, 24, WEP_CHAINSAW.m_id);
		else
			T_Damage(ent, this, this, 30, WEP_CHAINSAW.m_id);
		
		ent.velocity = ent.velocity * 0.5;
		_sound(this, CH_WEAPON_SINGLE, "weapons/sawguts.wav", 1, ATTN_NORM);
		this.punchangle_x = -8;
	}
	else
	{	// hit wall
		_sound(this, CH_WEAPON_SINGLE, "player/axhit2.wav", 1, ATTN_NORM);
		te_superspike(org);
	}
}

METHOD(Chainsaw, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_chainsaw1(actor);
		wep_chainsaw_chainsaw1(actor.(weaponentity));
		ATTACK_FINISHED(actor, weaponentity) = time + 0.55;
		_sound(actor, CH_SHOTS, "weapons/sawatck.wav", 1, ATTN_NORM);
	}

	if(!(fire & 1) && time > actor.chainsaw_sound_time)
	{
		_sound(actor, CH_WEAPON_SINGLE, "weapons/sawidle.wav", 1, ATTN_NORM);
		actor.chainsaw_sound_time = time + 0.1;
	}
}
METHOD(Chainsaw, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Chainsaw, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
