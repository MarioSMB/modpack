#include "axe.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
void W_FireAxe(entity this)
{
	makevectors(this.v_angle);
	vector source = this.origin + '0 0 16';
	traceline(source, source + v_forward*64, false, this);
	if(trace_fraction == 1.0)
		return;
	
	vector org = trace_endpos - v_forward * 4;

	if(trace_ent.takedamage && trace_ent.monsterdef != MON_CHTHON) // yoder mod, Jan 05 2021
	{
		if(MP_IMPEL)
		{
			float r = random();
			if(trace_ent.monsterdef == MON_JUGGERNAUT)
				_sound(this, CH_WEAPON_SINGLE, "monsters/juggers/jbent.wav", 1, ATTN_NORM);
			else if(trace_ent.monsterdef && (trace_ent.monsterdef.spawnflags & MON_FLAG_METAL))
			{
				if(r < 0.3)
					_sound(trace_ent, CHAN_ITEM, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
				else if(r < 0.6)
					_sound(trace_ent, CHAN_ITEM, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
				else
					_sound(trace_ent, CHAN_ITEM, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
			}
			else if(IS_PLAYER(trace_ent) && trace_ent.armorvalue > 0)
			{
				if(r < 0.3)
					_sound(trace_ent, CHAN_ITEM, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
				else if(r < 0.6)
					_sound(trace_ent, CHAN_ITEM, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
				else
					_sound(trace_ent, CHAN_ITEM, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
			}
			else if(r < 0.5)
			{
				_sound(trace_ent, CHAN_ITEM, "enviro/physics/axecut1.wav", 1, ATTN_NORM);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
			}
			else
			{
				_sound(trace_ent, CHAN_ITEM, "enviro/physics/axecut2.wav", 1, ATTN_NORM);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
			}
		}
		trace_ent.axhitme = true;
		if(!MP_IMPEL)
			SpawnBlood(org, '0 0 0', 20, trace_ent);
		T_Damage(trace_ent, this, this, 20, WEP_AXE.m_id);
	}
	else
	{	// hit wall
		_sound(this, CH_WEAPON_SINGLE, "player/axhit2.wav", 1, ATTN_NORM);
		te_gunshot(org);
	}
}

METHOD(Axe, wr_think, void(entity thiswep, entity actor))
{
	float r = random();
	if(!MP_IMPEL || random() < 0.7)
		_sound(actor, CH_WEAPON_SINGLE, "weapons/ax1.wav", 1, ATTN_NORM);
	else
		_sound(actor, CH_WEAPON_SINGLE, "zombie/z_shot1.wav", 1, ATTN_NORM);
	if(MP_MG && autocvar_horde && (serverflags & SIGIL_E3)) // horde rune behavior
	{
		if(actor.axe_hit_chain >= 2 && time < actor.axe_hit_chain_time)
		{
			// vertical CHOP
			if(r < 0.5)
				player_axe1(actor);
			else
				player_axec1(actor);
			actor.attack_finished = time + RuneApplyHell(0.8, actor); // long recover
		}
		else
		{
			// diagonal SWEEP
			if(r < 0.5)
				player_axeb1(actor);
			else
				player_axed1(actor);
					
			if(actor.axe_hit_chain > 1)
				actor.attack_finished = time + RuneApplyHell(0.6, actor);
			else
				actor.attack_finished = time + RuneApplyHell(0.4, actor);
						
		}
	}
	else
	{
		if(r < 0.25)
			player_axe1(actor);
		else if(r<0.5)
			player_axeb1(actor);
		else if(r<0.75)
			player_axec1(actor);
		else
			player_axed1(actor);
		float fire_delay = 0.5;
		if(MP_IMPEL && random() < 0.5)
			fire_delay = 0.4;
		actor.attack_finished = time + RuneApplyHell(fire_delay, actor);
	}
}
METHOD(Axe, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
