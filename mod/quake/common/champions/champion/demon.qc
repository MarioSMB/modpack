#include "demon.qh"

#ifdef SVQC
void demon_jump4(entity this);
void demon_jump12(entity this) { set_animofs(this, anim_demon_leap, 12, player_run); }
void demon_jump11(entity this) { set_animofs(this, anim_demon_leap, 11, demon_jump12); }
void demon_jump10(entity this)
{
	set_animofs(this, anim_demon_leap, 10, demon_jump4);
	if(this.exptime != 0)
		return;
	// physics says we're on ground
	if(IS_ONGROUND(this))
	{
		setthink(this, player_run);
		return;
	}
	// still jumping
	setthink(this, demon_jump10);
}
void demon_jump9(entity this) { set_animofs(this, anim_demon_leap, 9, demon_jump10); }
void demon_jump8(entity this) { set_animofs(this, anim_demon_leap, 8, demon_jump9); }
void demon_jump7(entity this) { set_animofs(this, anim_demon_leap, 7, demon_jump8); }
void demon_jump6(entity this) { set_animofs(this, anim_demon_leap, 6, demon_jump7); }
void demon_jump5(entity this) { set_animofs(this, anim_demon_leap, 5, demon_jump6); }
void demon_jump4(entity this) { set_animofs(this, anim_demon_leap, 4, demon_jump5); }

void hitdemon(entity this, entity hitent, vector org, vector dir)
{
	if(hitent.takedamage) 
	{
		float damage = 60 + (5 * random()) + (5 * random()) + (5 * random());
		if(IS_PLAYER(hitent))
			damage *= 0.5;

		SpawnMeatSpray(this, org, dir);

		hitent.axhitme = true;
		T_Damage(hitent, this, this, damage, DEATH_MONSTER_FIEND.m_id);
		
		//johnfitz -- make clank sound when hitting brushmodels
		if(hitent.solid == SOLID_BSP || hitent.movetype == MOVETYPE_PUSH || hitent.movetype == MOVETYPE_NONE)
			sound(hitent, CH_SHOTS, SND_Demon_Hit, 0.5, ATTN_NORM);
		else
			sound(hitent, CH_SHOTS, SND_Demon_Hit, 1, ATTN_NORM);	
	}
	else
	{	// hit wall
		FX_Wrench(org, dir, true);
		sound(hitent, CH_SHOTS, SND_Demon_Hit_Wall, 1, ATTN_NORM);	
	}
}

void demon_melee(entity this, float side)
{
	float lag = (IS_PLAYER(this)) ? antilag_getlag(this) : 0;
	if(lag)
		antilag_takeback_all(this, lag);

	entity hitent1 = NULL, hitent2 = NULL;
	vector hitpos1 = '0 0 0', hitpos2 = '0 0 0';
	float shortest_hit1 = 1000;
	float shortest_hit2 = 1000;
	int oldsolid = this.dphitcontentsmask;
	this.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;

	float rscale = 1;
	if(this.m_champion && this.m_champion.qcc_meleerange)
		rscale *= this.m_champion.qcc_meleerange;

	makevectors(this.v_angle);
	vector source = this.origin + this.view_ofs - v_up*0;

	traceline(source, source + v_forward * (75 * rscale) - v_right * (40 * rscale), false, this);
	if(trace_fraction < 1)
	{
		shortest_hit1 = vlen(trace_endpos - source);
		hitent1 = trace_ent;
		hitpos1 = trace_endpos;
 	}

	traceline(source, source + v_forward * (85 * rscale) - v_right * (20 * rscale), false, this);
	if(trace_fraction < 1)
	{
		if(trace_ent == hitent1 && vdist(trace_endpos - source, <, shortest_hit1))
		{
			shortest_hit1 = vlen(trace_endpos - source);
			hitent1 = trace_ent;
			hitpos1 = trace_endpos;
		}
		if(trace_ent != hitent1 && vdist(trace_endpos - source, <, shortest_hit2))
		{
			shortest_hit2 = vlen(trace_endpos - source);
			hitent2 = trace_ent;
			hitpos2 = trace_endpos;
		}
	}

	traceline(source, source + v_forward * (102 * rscale), false, this);
	if(trace_fraction < 1)
	{
		if(trace_ent == hitent1 && vdist(trace_endpos - source, <, shortest_hit1))
		{
			shortest_hit1 = vlen(trace_endpos - source);
			hitent1 = trace_ent;
			hitpos1 = trace_endpos;
		}
		if(trace_ent != hitent1 && vdist(trace_endpos - source, <, shortest_hit2))
		{
			shortest_hit2 = vlen(trace_endpos - source);
			hitent2 = trace_ent;
			hitpos2 = trace_endpos;
		}
	}

	traceline(source, source + v_forward * (86 * rscale) + v_right * (20 * rscale), false, this);
	if(trace_fraction < 1)
	{
		if(trace_ent == hitent1 && vdist(trace_endpos - source, <, shortest_hit1))
		{
			shortest_hit1 = vlen(trace_endpos - source);
			hitent1 = trace_ent;
			hitpos1 = trace_endpos;
		}
		if(trace_ent != hitent1 && vdist(trace_endpos - source, <, shortest_hit2))
		{
			shortest_hit2 = vlen(trace_endpos - source);
			hitent2 = trace_ent;
			hitpos2 = trace_endpos;
		}
	}

	traceline(source, source + v_forward * (75 * rscale) + v_right * (40 * rscale), false, this);
	if(trace_fraction < 1)
	{
		if(trace_ent == hitent1 && vdist(trace_endpos - source, <, shortest_hit1))
		{
			shortest_hit1 = vlen(trace_endpos - source);
			hitent1 = trace_ent;
			hitpos1 = trace_endpos;
		}
		if(trace_ent != hitent1 && vdist(trace_endpos - source, <, shortest_hit2))
		{
			shortest_hit2 = vlen(trace_endpos - source);
			hitent2 = trace_ent;
			hitpos2 = trace_endpos;
		}
	}

	this.dphitcontentsmask = oldsolid;

	if(shortest_hit1 == 1000 && shortest_hit2 == 1000)
	{
		if(lag)
			antilag_restore_all(this);
		return;
	}

	this.show_hostile = time + 1; // hit something, so alert monsters
	
	vector dir = v_right * side - v_up*5; // direction for blood particles

	if(shortest_hit1 < 1000)
		hitdemon(this, hitent1, hitpos1 - v_forward*4, dir);
	if(shortest_hit2 < 1000 && hitent1 != hitent2)
		hitdemon(this, hitent2, hitpos2 - v_forward*4, dir);

	if(lag)
		antilag_restore_all(this);
}

void demon_melee15(entity this) { set_animofs(this, anim_demon_attacka, 15, player_run); }
void demon_melee14(entity this) { set_animofs(this, anim_demon_attacka, 14, demon_melee15); }
void demon_melee13(entity this) { set_animofs(this, anim_demon_attacka, 13, demon_melee14); }
void demon_melee12(entity this) { set_animofs(this, anim_demon_attacka, 12, demon_melee13); }
void demon_melee11(entity this)
{
	set_animofs(this, anim_demon_attacka, 11, demon_melee12);
	demon_melee(this, -200);
}
void demon_melee10(entity this) { set_animofs(this, anim_demon_attacka, 10, demon_melee11); }
void demon_melee9(entity this) { set_animofs(this, anim_demon_attacka, 9, demon_melee10); }
void demon_melee8(entity this) { set_animofs(this, anim_demon_attacka, 8, demon_melee9); }
void demon_melee7(entity this) { set_animofs(this, anim_demon_attacka, 7, demon_melee8); }
void demon_melee6(entity this) { set_animofs(this, anim_demon_attacka, 6, demon_melee7); }
void demon_melee5(entity this)
{
	set_animofs(this, anim_demon_attacka, 5, demon_melee6);
	demon_melee(this, 200);
}
void demon_melee4(entity this) { set_animofs(this, anim_demon_attacka, 4, demon_melee5); }
void demon_melee3(entity this) { set_animofs(this, anim_demon_attacka, 3, demon_melee4); }
void demon_melee2(entity this) { set_animofs(this, anim_demon_attacka, 2, demon_melee3); }
void demon_melee1(entity this) { set_animofs(this, anim_demon_attacka, 1, demon_melee2); }

METHOD(Demon, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, SND_Demon_Start, ATTN_NORM);
}

METHOD(Demon, m_weaponframe, bool(Champions this, entity actor, .entity weaponentity))
{
	// no regular weapon use!
	return true;
}

METHOD(Demon, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_ATCK(actor) && IS_ONGROUND(actor) && time > actor.demon_melee_time && !actor.tank && !STAT(CANNON, actor))
	{
		player_sound(actor, CH_VOICE, SND_Demon_Start, ATTN_NORM);
		actor.demon_melee_time = time + 1.5;
		demon_melee1(actor);
	}
}

METHOD(Demon, m_touch, void(Champions this, entity actor, entity toucher))
{
	if(StatusEffects_active(STATUSEFFECT_PowerShield, actor))
		return; // better version
	if(time < actor.demon_bash_delay)
		return;
	if(actor.velocity == '0 0 0')
		return;
	if(time > actor.demon_bash_time)
		return;

	if(toucher.takedamage && Damage_ValidTarget(toucher, actor))
	{
		makevectors(actor.angles);
		vector vec = normalize(toucher.origin - actor.origin);
		float dot = vec * v_forward;
		if(dot < 0.3)
			return;

		if(!(toucher.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(toucher.monsterdef.spawnflags & MON_FLAG_STATIONARY))
		{
			float pushforce = 100 / vlen(toucher.maxs - toucher.mins);

			makevectors(actor.angles);
			toucher.velocity = v_forward * (50 * pushforce);
			toucher.velocity_z = (125 * pushforce);
		}

		te_explosion2(toucher.origin, 230, 5);

		float thedamage = 70;
		if(toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD)
			thedamage = 120;

		T_Damage(toucher, actor, actor, thedamage, DEATH_SHIELD.m_id);

		actor.demon_bash_delay = time + 0.5;
	}
}

METHOD(Demon, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_PLAYER_SINGLE, SND_Demon_Death, ATTN_NORM);
	actor.demon_cannon = true;
}

METHOD(Demon, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.demon_cannon)
		return false;
	player_sound(actor, CH_PLAYER_SINGLE, SND_Demon_Land, ATTN_NORM);
	actor.demon_cannon = false;
	return false;
}
#endif

METHOD(Demon, m_playerjump, float(Champions this, entity actor))
{
	if(vdist(actor.velocity, <, PHYS_MAXSPEED(actor) * 0.8))
	{
	#ifdef SVQC
		player_sound(actor, CH_PLAYER_SINGLE, SND_Demon_Jump, ATTN_NORM);
		actor.demon_bash_time = time + 1;
		demon_jump4(actor);
	#endif
		vector vang = PHYS_INPUT_ANGLES(actor);
		makevectors('0 1 0' * vang.y);
		actor.velocity += v_forward * 600;
		actor.velocity_z += 300;
		UNSET_ONGROUND(actor);
	}
	return 0;
}

#ifdef CSQC
METHOD(Demon, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/demon_face";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}
#endif
