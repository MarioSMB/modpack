#include "goat.qh"

// ================
//  JUMPING CASTLE
// ================

#ifdef SVQC
.float yaaay_time;
void jumpingcastle_hitbox_touch(entity this, entity toucher)
{
	if(time < toucher.yaaay_time)
		return;

	toucher.yaaay_time = time + 0.2; // TODO?

	float jheight = 300 * turret_getpower(this.tur_level, 0.25);
	float pushforce = 100 / vlen(toucher.maxs - toucher.mins);

	toucher.velocity = randomvec() * (100 * pushforce);
	toucher.velocity_z = (jheight * pushforce);
	UNSET_ONGROUND(toucher);
	toucher.oldvelocity = toucher.velocity;

	float r = random();
	if(r < 0.33)
		_sound(toucher, CH_VOICE, "turrets/jumpingcastle_bounce1.wav", 1, ATTN_NORM);
	else if(r < 0.66)
		_sound(toucher, CH_VOICE, "turrets/jumpingcastle_bounce2.wav", 1, ATTN_NORM);
	else
		_sound(toucher, CH_VOICE, "turrets/jumpingcastle_bounce3.wav", 1, ATTN_NORM);

	if(IS_MONSTER(toucher) && toucher.health > 0 && gametype == GAMETYPE_TD)
	{
		this.enemy = toucher;
		this.cnt += 1;
	}
}

METHOD(GoatJumpingCastle, tr_precache, void(GoatJumpingCastle thistur))
{
	precache_sound("turrets/jumpingcastle_bounce1.wav");
	precache_sound("turrets/jumpingcastle_bounce2.wav");
	precache_sound("turrets/jumpingcastle_bounce3.wav");
}
METHOD(GoatJumpingCastle, tr_think, void(GoatJumpingCastle thistur, entity actor))
{
	vector emin = actor.absmin, emax = actor.absmax;
	vector extrasize = '16 16 0'; // give it LESS range!
	emin += extrasize;
	emax -= extrasize;

	actor.cnt = 0; // number of jumpees this frame

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY && it.move_movetype != MOVETYPE_NOCLIP,
	{
		if(!IS_MONSTER(it) && !IS_PLAYER(it))
			continue;
		if((it.monsterdef.spawnflags & MONSTER_TYPE_BOSS) || (it.monsterdef.spawnflags & MON_FLAG_STATIONARY))
			continue;
		if((it.monsterdef.spawnflags & MONSTER_TYPE_FLY) || (it.monsterdef.spawnflags & MONSTER_TYPE_SWIM))
			continue;
		jumpingcastle_hitbox_touch(actor, it);
	});

	if(actor.cnt > 0)
	{
		float damage = 10 * actor.cnt;
		T_Damage(actor, actor.enemy, actor.enemy, damage, DEATH_CRUSH.m_id);
	}
}
METHOD(GoatJumpingCastle, tr_setup, void(GoatJumpingCastle this, entity actor))
{
	actor.solid = SOLID_TRIGGER;
	actor.monster_attack = false;

	// does nothing on its own
	actor.damage_flags = TFL_DMG_YES;
	actor.aim_flags = TFL_AIM_NO;
	actor.track_flags = TFL_TRACK_NO;
	actor.firecheck_flags = TFL_FIRECHECK_NO;
	actor.shoot_flags = TFL_SHOOT_NO;
	actor.target_select_flags = TFL_TARGETSELECT_NO;
	actor.target_validate_flags = actor.target_select_flags;
}

spawnfunc(turret_jumpingcastle)
{
	if (!turret_initialize(this, TUR_JUMPING_CASTLE))
		delete(this);
}
#endif // SVQC
#ifdef CSQC
METHOD(GoatJumpingCastle, tr_setup, void(GoatJumpingCastle this, entity actor))
{
	actor.solid = SOLID_TRIGGER;
}
#endif // CSQC

// ========
//  SWINGS
// ========

#ifdef SVQC
.float wheee_time;
void swings_hitbox_touch(entity this, entity toucher)
{
	if(time < toucher.wheee_time)
		return;

	float damage = this.shot_dmg;
	toucher.wheee_time = time + 0.5; // TODO?

	float r = random();
	if(r < 0.8)
		_sound(toucher, CH_VOICE, "turrets/swing_launch.wav", 1, ATTN_NORM);
	else
		_sound(toucher, CH_VOICE, "turrets/weeee.wav", 1, ATTN_NORM);

	if(IS_MONSTER(toucher) && toucher.health > 0 && gametype == GAMETYPE_TD)
	{
		T_Damage(toucher, this, this, damage, DEATH_TRAP.m_id);

		this.enemy = toucher;
		this.cnt += 1;
	}

	// also push enemy away
	if(!(toucher.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(toucher.monsterdef.spawnflags & MON_FLAG_STATIONARY))
	{
		float jforce = 40 * turret_getpower(this.tur_level, 0.25);
		float pushforce = jforce / vlen(toucher.maxs - toucher.mins);

		vector dir = normalize(toucher.origin - this.origin);
		toucher.velocity = dir * (350 * pushforce);
		toucher.velocity_z = (125 * pushforce);
	}
}

METHOD(GoatSwings, tr_precache, void(GoatSwings thistur))
{
	precache_sound("turrets/swing_launch.wav");
	precache_sound("turrets/weeee.wav");
}
METHOD(GoatSwings, tr_think, void(GoatSwings thistur, entity actor))
{
	vector emin = actor.absmin, emax = actor.absmax;
	vector extrasize = '16 16 0'; // give it LESS range!
	emin += extrasize;
	emax -= extrasize;

	actor.cnt = 0; // number of jumpees this frame

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY && it.move_movetype != MOVETYPE_NOCLIP,
	{
		if(!IS_MONSTER(it) && !IS_PLAYER(it))
			continue;
		swings_hitbox_touch(actor, it);
	});

	if(actor.cnt > 0)
	{
		float damage = 5 * actor.cnt;
		T_Damage(actor, actor.enemy, actor.enemy, damage, DEATH_CRUSH.m_id);
	}
}
METHOD(GoatSwings, tr_setup, void(GoatSwings this, entity actor))
{
	actor.solid = SOLID_TRIGGER;
	actor.monster_attack = false;

	// does nothing on its own
	actor.damage_flags = TFL_DMG_YES;
	actor.aim_flags = TFL_AIM_NO;
	actor.track_flags = TFL_TRACK_NO;
	actor.firecheck_flags = TFL_FIRECHECK_NO;
	actor.shoot_flags = TFL_SHOOT_NO;
	actor.target_select_flags = TFL_TARGETSELECT_NO;
	actor.target_validate_flags = actor.target_select_flags;
}

spawnfunc(turret_swings)
{
	if (!turret_initialize(this, TUR_SWINGS))
		delete(this);
}
#endif // SVQC
#ifdef CSQC
METHOD(GoatSwings, tr_setup, void(GoatSwings this, entity actor))
{
	actor.solid = SOLID_TRIGGER;
}
#endif // CSQC
