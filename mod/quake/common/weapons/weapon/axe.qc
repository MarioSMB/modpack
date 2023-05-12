#include "axe.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
void player_axe4(entity this) { set_animofs(this, anim_player_axatt1, 4, player_run); this.weaponentity.m_frame = 4; }
void player_axe3(entity this) { set_animofs(this, anim_player_axatt1, 3, player_axe4); this.weaponentity.m_frame = 3; W_FireAxe(this); }
void player_axe2(entity this) { set_animofs(this, anim_player_axatt1, 2, player_axe3); this.weaponentity.m_frame = 2; }
void player_axe1(entity this) { set_animofs(this, anim_player_axatt1, 1, player_axe2); this.weaponentity.m_frame = 1; }

void player_axeb4(entity this) { set_animofs(this, anim_player_axattb1, 4, player_run); this.weaponentity.m_frame = 8; }
void player_axeb3(entity this) { set_animofs(this, anim_player_axattb1, 3, player_axeb4); this.weaponentity.m_frame = 7; W_FireAxe(this); }
void player_axeb2(entity this) { set_animofs(this, anim_player_axattb1, 2, player_axeb3); this.weaponentity.m_frame = 6; }
void player_axeb1(entity this) { set_animofs(this, anim_player_axattb1, 1, player_axeb2); this.weaponentity.m_frame = 5; }

void player_axec4(entity this) { set_animofs(this, anim_player_axattc1, 4, player_run); this.weaponentity.m_frame = 4; }
void player_axec3(entity this) { set_animofs(this, anim_player_axattc1, 3, player_axec4); this.weaponentity.m_frame = 3; W_FireAxe(this); }
void player_axec2(entity this) { set_animofs(this, anim_player_axattc1, 2, player_axec3); this.weaponentity.m_frame = 2; }
void player_axec1(entity this) { set_animofs(this, anim_player_axattc1, 1, player_axec2); this.weaponentity.m_frame = 1; }

void player_axed4(entity this) { set_animofs(this, anim_player_axattd1, 4, player_run); this.weaponentity.m_frame = 8; }
void player_axed3(entity this) { set_animofs(this, anim_player_axattd1, 3, player_axed4); this.weaponentity.m_frame = 7; W_FireAxe(this); }
void player_axed2(entity this) { set_animofs(this, anim_player_axattd1, 2, player_axed3); this.weaponentity.m_frame = 6; }
void player_axed1(entity this) { set_animofs(this, anim_player_axattd1, 1, player_axed2); this.weaponentity.m_frame = 5; }

void W_FireAxe(entity this)
{
	makevectors(this.v_angle);
	vector source = this.origin + '0 0 16';
	traceline(source, source + v_forward*64, false, this);
	if(trace_fraction == 1.0)
		return;
	
	vector org = trace_endpos - v_forward * 4;

	if(trace_ent.takedamage) // yoder mod, Jan 05 2021
	{
		{
			float r = random();
			if(trace_ent.monsterdef == MON_JUGGERNAUT) // special case: axe attacks produce unique sound against juggernauts TODO: handle melee attacks in monster pain code
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
		T_Damage(trace_ent, this, this, 20, WEP_AXE.m_id);
	}
	else
	{	// hit wall
		_sound(this, CH_WEAPON_SINGLE, "player/axhit2.wav", 1, ATTN_NORM);
		te_gunshot(org);
	}
}

METHOD(Axe, wr_think, void(entity thiswep, entity actor, int fire))
{
	if(fire & 1)
	//if(thiswep.wr_checkammo1(thiswep, actor))
	{
		// TODO: decouple axe attacks from the player animations
		float r = random();
		if(random() < 0.7)
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
				actor.attack_finished = time + 0.8; // long recover
			}
			else
			{
				// diagonal SWEEP
				if(r < 0.5)
					player_axeb1(actor);
				else
					player_axed1(actor);
						
				if(actor.axe_hit_chain > 1)
					actor.attack_finished = time + 0.6;
				else
					actor.attack_finished = time + 0.4;
							
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
			if(random() < 0.5)
				fire_delay = 0.4;
			actor.attack_finished = time + fire_delay;
		}
	}
}
METHOD(Axe, wr_checkammo1, bool(entity thiswep, entity actor))
{
	// does not use ammo
	return true;
}
METHOD(Axe, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
