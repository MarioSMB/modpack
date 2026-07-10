#include "galena.qh"

// =======
//  TOTEM
// =======

#ifdef SVQC
METHOD(GalenaTotem, tr_attack, void(GalenaTotem this, entity actor))
{
	entity targ = actor.enemy;

	bool didweak = false;
	float efftime = 3;
	float curtime = StatusEffects_gettime(STATUSEFFECT_Weakness, targ);
	if((time + efftime) > curtime)
	{
		didweak = true;
		StatusEffects_apply(STATUSEFFECT_Weakness, targ, time + efftime, 0);
	}

	if(didweak)
		actor.lip += 1;
}
METHOD(GalenaTotem, tr_think, void(GalenaTotem this, entity actor))
{
	if(actor.lip > 0 && time >= actor.attack2_finished)
	{
		actor.attack2_finished = time + 0.25; // so we don't die instantly
		T_Damage(actor, NULL, NULL, 1, DEATH_GENERIC.m_id);
		actor.lip = 0;
	}
}
METHOD(GalenaTotem, tr_setup, void(GalenaTotem this, entity actor))
{
	actor.monster_attack = false;

	actor.solid = SOLID_TRIGGER;

	actor.shoot_flags = TFL_SHOOT_HITALLVALID;
	actor.aim_flags = TFL_AIM_NO;
	actor.track_flags = TFL_TRACK_NO;
	actor.firecheck_flags = TFL_FIRECHECK_DEAD | TFL_FIRECHECK_DISTANCES;
}
#endif // SVQC
#ifdef CSQC
METHOD(GalenaTotem, tr_think, void(GalenaTotem this, entity actor))
{
	if(vdist(view_origin - actor.origin, >=, 1024))
		return; // reduce lag!

	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	vector extrasize = '1 1 1' * myrange;
	vector mymin = actor.absmin - extrasize;
	vector mymax = actor.absmax + extrasize;

	if(!SpawnParticles_list_full(strcat("cl_particle_", EFFECT_TOTEM_GLOW.eent_eff_name), mymin, mymax, actor.velocity, actor.velocity, bound(0, frametime, 0.1), false, 0))
		boxparticles(particleeffectnum(EFFECT_TOTEM_GLOW), actor, mymin, mymax, actor.velocity, actor.velocity, bound(0, frametime, 0.1), 0);
}
METHOD(GalenaTotem, tr_drawselected, void(GalenaTotem this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 4';

	Draw_Circle(org, myrange);
}
METHOD(GalenaTotem, tr_setup, void(GalenaTotem this, entity actor))
{
	actor.solid = SOLID_TRIGGER;
}
#endif // CSQC

// ==============
//  ANGEL STATUE
// ==============

#ifdef SVQC
bool angel_heal(entity this, entity toucher)
{	
	if(toucher.tank)
		return false;
	if(toucher.clockwork)
		return false;
	if(toucher.m_transform)
		return false;
	//if(time < toucher.worldtree_healtime)
		//return false;
	
	float healing = toucher.max_health * 0.5;

	if(!T_Heal(toucher, max(1, floor(healing)), IS_PLAYER(toucher)))
		return false;

	toucher.healthrot_nextcheck = time + 2;

	if(IS_TURRET(toucher))
		toucher.SendFlags |= TNSF_STATUS;

	//particle(toucher.origin, '0 0 0', 26, 32);
	Send_Effect(EFFECT_RUNE_HEAL, (toucher.absmin + toucher.absmax) * 0.5, '0 0 0', 1);
	
	//this.model = string_null;
	//this.solid = SOLID_NOT;
	//delete(this);
	return true;
}

METHOD(GalenaAngelStatue, tr_precache, void(GalenaAngelStatue thistur))
{
	precache_sound("items/revival.wav");
}
METHOD(GalenaAngelStatue, tr_think, void(GalenaAngelStatue this, entity actor))
{
	actor.attack_finished = time + 1; // prevent animations from resetting

	if(time < actor.attack2_finished)
		return;

	int newframe = AANIM_IDLE;
	if(actor.frame != newframe)
		actor.SendFlags |= TNSF_ANIM;
	actor.frame = newframe;

	if(time < actor.idle_finished)
		return;

	actor.idle_finished = time + 0.1; // slight delay to reduce lag

	// pick a random nearby target each time we attack
	// make sure it matches drawn values!
	float myrange = actor.target_range;
	//float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	//float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	
	bool found_target = false;
	FOREACH_ENTITY_RADIUS(actor.origin + actor.view_ofs, myrange, it != actor && IS_TURRET(it) && it.turretdef != TUR_ANGEL_STATUE && it.health > 0,
	{
		if(it.exptime != 0)
			continue;
		if(it.health > (it.max_health * 0.2))
			continue;

		found_target = true;
		break;
	});

	if(found_target)
	{
		FOREACH_ENTITY_RADIUS(actor.origin + actor.view_ofs, myrange, it != actor && it.turretdef != TUR_ANGEL_STATUE && (IS_PLAYER(it) || IS_TURRET(it)) && it.health > 0,
		{
			if(it.exptime != 0)
				continue;
			if(IS_PLAYER(it) && it.health > 250)
				continue;
			if(IS_TURRET(it) && it.health >= it.max_health)
				continue;

			angel_heal(actor, it);
		});

		actor.attack2_finished = time + 5; // make angel visible for a while!
		turrets_setframe_force(actor, AANIM_APPEAR, false, true);

		Send_Effect(EFFECT_ANGEL_HEALING, actor.origin + '0 0 92', '0 0 0', 1);
		_sound(actor, CH_TRIGGER_SINGLE, "items/revival.wav", 1, 0.5);

		T_Damage(actor, NULL, NULL, actor.max_health * 0.10, DEATH_GENERIC.m_id);
	}
}
METHOD(GalenaAngelStatue, tr_setup, void(GalenaAngelStatue this, entity actor))
{
	actor.view_ofs = '0 0 48';

	actor.attack_finished = time + 1;

	// does nothing on its own
	actor.damage_flags = TFL_DMG_YES;
	actor.aim_flags = TFL_AIM_NO;
	actor.track_flags = TFL_TRACK_NO;
	actor.firecheck_flags = TFL_FIRECHECK_NO;
	actor.shoot_flags = TFL_SHOOT_NO;
	actor.target_select_flags = TFL_TARGETSELECT_NO;
	actor.target_validate_flags = actor.target_select_flags;
}
#endif // SVQC
#ifdef CSQC
METHOD(GalenaAngelStatue, tr_drawselected, void(GalenaAngelStatue this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	//float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	//float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	vector org = actor.origin + '0 0 4';
	makevectors(actor.angles);

	if(actor.classname == "buildtool_dropmark" && actor.tur_head)
		actor.tur_head.drawmask = 0;

	Draw_Circle(org, myrange);
}
METHOD(GalenaAngelStatue, tr_setup, void(GalenaAngelStatue this, entity actor))
{
	actor.tur_head.effects |= EF_NOSELFSHADOW;
	actor.tur_head.effects |= EF_NOSHADOW;
	//actor.tur_head.effects |= EF_FULLBRIGHT;
	actor.tur_head.effects |= EF_DIMLIGHT;
	actor.tur_head.effects |= EF_ADDITIVE;
}
METHOD(GalenaAngelStatue, tr_think, void(GalenaAngelStatue this, entity actor))
{
	entity head = actor.tur_head;
	head.origin_z = 70 + sin(2 * M_PI * time);

	head.drawmask = (actor.frame == 0) ? 0 : MASK_NORMAL;
}
#endif // CSQC
