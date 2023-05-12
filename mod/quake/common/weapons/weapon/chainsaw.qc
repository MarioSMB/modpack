#include "axe.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC

void player_chainsaw6(entity this) { set_animofs(this, anim_player_shotatt1, 2, player_run); this.weaponentity.m_frame = 10; }
void player_chainsaw5(entity this) { set_animofs(this, anim_player_shotatt1, 1, player_chainsaw6); this.weaponentity.m_frame = 9; W_FireSaw(this); }
void player_chainsaw4(entity this) { set_animofs(this, anim_player_shotatt1, 2, player_chainsaw5); this.weaponentity.m_frame = 8;
	if(!this.button0) {
		player_run(this);
		return;
	}
}
void player_chainsaw3(entity this) { set_animofs(this, anim_player_shotatt1, 1, player_chainsaw4); this.weaponentity.m_frame = 7; W_FireSaw(this); }
void player_chainsaw2(entity this)
{
	set_animofs(this, anim_player_shotatt1, 2, player_chainsaw3); this.weaponentity.m_frame = 6;
	if(!this.button0)
	{
		player_run(this);
		return;
	}
}
void player_chainsaw1(entity this) { set_animofs(this, anim_player_shotatt1, 1, player_chainsaw2); this.weaponentity.m_frame = 5; W_FireSaw(this); }

void W_FireSaw(entity this)
{
	makevectors (this.v_angle);
	vector source = this.origin + this.view_ofs - v_up*6;
	traceline (source, source + v_forward*64, false, this);
	if (trace_fraction == 1.0)
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
		te_gunshot(org);
	}
}

METHOD(Chainsaw, wr_think, void(entity thiswep, entity actor, int fire))
{
	if(fire & 1)
	//if(thiswep.wr_checkammo1(thiswep, actor))
	{
		player_chainsaw1(actor);
		actor.attack_finished = time + 0.55;
		_sound(actor, CH_SHOTS, "weapons/sawatck.wav", 1, ATTN_NORM);
	}

	if(!(fire & 1) && time > actor.chainsaw_sound_time)
	{
		_sound(actor, CH_WEAPON_SINGLE, "weapons/sawidle.wav", 1, ATTN_NORM);
		actor.chainsaw_sound_time = time + 0.1;
	}
}
METHOD(Chainsaw, wr_checkammo1, bool(entity thiswep, entity actor))
{
	// does not use ammo
	return true;
}
METHOD(Chainsaw, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
