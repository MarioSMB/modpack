#include "katana.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
bool autocvar_sv_quake_katana_midair = true;
bool autocvar_sv_quake_katana_projectiles = false;

void player_katana4(entity this) { set_animofs(this, anim_player_axattd1, 4, player_run); }
void player_katana3(entity this) { set_animofs(this, anim_player_axattd1, 3, player_katana4); }
void player_katana2(entity this) { set_animofs(this, anim_player_axattd1, 2, player_katana3); }
void player_katana1(entity this) { set_animofs(this, anim_player_axattd1, 1, player_katana2); }

void W_FireKatana(entity this, .entity weaponentity);
void wep_katana(entity this)
{
	this.m_frame += 1;
	float animlimit = (this.count) ? 7 : 10;
	if(this.m_frame >= animlimit)
	{
		// reset attack delay so player can swing again quickly
		ATTACK_FINISHED(this.owner, this.weaponentity_fld) = time;
		wep_set_anim(this, animlimit, w_ready);
		return;
	}
	this.weapon_think = wep_katana;
	this.weapon_nextthink = time + FRAME_TIME;

	if(this.m_frame == 1)
		W_Parry_Trigger(this.owner, 0);
	else if(this.m_frame >= 4 && this.m_frame < 7 && !this.count)
		W_FireKatana(this.owner, this.weaponentity_fld);
}

entity W_Katana_FindProjectile(entity this, float arange)
{
	entity targ = NULL;
	makevectors(this.v_angle);
	FOREACH_ENTITY_RADIUS(this.origin, arange, time > it.parry_time && time > it.parry_cooldown && W_Projectile_CanParry(this, it),
	{
		float dot = normalize(it.origin - this.origin) * v_forward;
		if(dot <= 0.3) { continue; }

		targ = it;
		break;
	});

	return targ;
}

entity W_Katana_Parry(entity this)
{
	if(this.parry_time < time)
		return NULL;
	if(time < this.parry_cooldown)
		return NULL;
	if(!IS_PLAYER(this))
		return NULL;

	entity targ = W_Katana_FindProjectile(this, 120);

	// delete it next frame so we can target it
	if(targ)
	{
		setthink(targ, SUB_Remove);
		targ.nextthink = time;
		settouch(targ, func_null);
		targ.solid = SOLID_NOT;
		return targ;
	}
	return NULL;
}

void W_FireKatana(entity this, .entity weaponentity)
{
	entity targ = W_Katana_Parry(this);
	if(targ && W_Parry(this, targ))
		return;

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
			else
			{
				_sound(trace_ent, CH_SHOTS, "weapons/katana_swing1.wav", 1, ATTN_NORM);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
			}
		}
		trace_ent.axhitme = true;
		float damage = 80;
		T_Damage(trace_ent, this, this, damage, WEP_KATANA.m_id);
	}
	else
	{	// hit wall
		_sound(this, CH_SHOTS, "player/axhit2.wav", 1, ATTN_NORM);
		te_gunshot(org);
	}

	// hit something, cut anim short
	this.(weaponentity).count = 1;
}

void W_Katana_TryLunge(entity actor)
{
	if(actor.flags & FL_SWIM)
		return;
	if(!IS_ONGROUND(actor) && !autocvar_sv_quake_katana_midair)
		return;
	makevectors(actor.v_angle);
	float pushforward = 400;
	if(!IS_ONGROUND(actor))
		pushforward *= 1.5;
	entity targ = NULL;
	if(autocvar_sv_quake_katana_projectiles)
		targ = W_Katana_FindProjectile(actor, pushforward);
	if(!targ)
	{
		tracebox(actor.origin, '-8 -8 -8', '8 8 8', CENTER_OR_VIEWOFS(actor) + v_forward * pushforward, MOVE_NORMAL, actor);
		targ = trace_ent;
	}
	vector targ_org = (targ.absmin + targ.absmax) * 0.5;
	if((targ.takedamage || (W_Projectile_CanParry(actor, targ) && targ.owner != actor && autocvar_sv_quake_katana_projectiles)) && vdist(actor.origin - targ_org, >, 110))
	{
		setorigin(actor, actor.origin + '0 0 1');
		actor.velocity += normalize(targ_org - actor.origin) * (vlen(actor.origin - targ_org) * 2.5);
		actor.velocity_z += (PHYS_GRAVITY(actor) * PHYS_INPUT_TIMELENGTH);
		UNSET_ONGROUND(actor);
	}
}

PRECACHE(Katana)
{
	precache_model("progs/v_katana.mdl");
	precache_model("progs/g_katana.mdl");

	precache_sound("weapons/katana_swing1.wav");
	precache_sound("weapons/katana_swing2.wav");
}

METHOD(Katana, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_katana1(actor);
		actor.(weaponentity).m_frame = 0;
		actor.(weaponentity).count = 0;
		_sound(actor, CH_WEAPON_SINGLE, "weapons/katana_swing2.wav", 1, ATTN_NORM);
		W_Katana_TryLunge(actor);
		wep_katana(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 1);
	}
}
METHOD(Katana, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Katana, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Katana, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
