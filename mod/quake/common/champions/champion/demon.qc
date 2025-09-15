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

void demon_melee(entity this, float side)
{
	makevectors(this.v_angle);
	.entity weaponentity = weaponentities[0]; // TODO?
	vector source = W_Shotorg(this, weaponentity);
	int oldsolid = this.dphitcontentsmask;
	this.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	traceline(source, source + v_forward * 100, false, this);
	this.dphitcontentsmask = oldsolid;
	if(trace_fraction == 1.0)
		return;
	if(!trace_ent.takedamage)
		return;
		
    _sound(this, CH_WEAPON_SINGLE, "demon/dhit2.wav", 1, ATTN_NORM);
	float ldmg = 30 + 5*random();
	trace_ent.axhitme = true;
	T_Damage(trace_ent, this, this, ldmg, DEATH_MONSTER_FIEND.m_id);	

	SpawnMeatSpray(this, this.origin + v_forward*16, side * v_right);
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
	_sound(actor, CH_VOICE, "demon/sight2.wav", 1, ATTN_NORM);
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
		_sound(actor, CH_VOICE, "demon/sight2.wav", 1, ATTN_NORM);
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
	_sound(actor, CH_TRIGGER_SINGLE, "demon/ddeath.wav", 1, ATTN_NORM);
	actor.demon_cannon = true;
}

METHOD(Demon, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.demon_cannon)
		return false;
	_sound(actor, CH_TRIGGER_SINGLE, "demon/dland2.wav", 1, ATTN_NORM);
	actor.demon_cannon = false;
	return false;
}
#endif

METHOD(Demon, m_playerjump, float(Champions this, entity actor))
{
	if(vdist(actor.velocity, <, PHYS_MAXSPEED(actor) * 0.8))
	{
	#ifdef SVQC
		_sound(actor, CH_WEAPON_SINGLE, "demon/djump.wav", 1, ATTN_NORM);
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
