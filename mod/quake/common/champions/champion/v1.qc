#include "v1.qh"

METHOD(V1, m_friction, float(Champions this, entity actor))
{
	if(V1_Sliding(actor))
		return 0;
	return 1;
}

METHOD(V1, m_getmovespeed, float(Champions this, entity actor))
{
	if(V1_Sliding(actor))
		return 2;
	return 1;
}

bool V1_Sliding(entity actor)
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && actor.waterlevel <= 1)
		return true;
	return false;
}

#ifdef SVQC
METHOD(V1, m_activate, void(Champions this, entity actor))
{
	float r = random();
	if(r < 0.25)
		player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
	else if(r < 0.50)
		player_sound(actor, CH_VOICE, "start2.wav", ATTN_NORM);
	else if(r < 0.75)
		player_sound(actor, CH_VOICE, "start3.wav", ATTN_NORM);
	else
		player_sound(actor, CH_VOICE, "start4.wav", ATTN_NORM);

	STAT(WEAPONS, actor) |= WEP_KATANA.m_wepset;
}

METHOD(V1, m_playerspawn, void(Champions this, entity actor))
{
	STAT(WEAPONS, actor) |= WEP_KATANA.m_wepset;
}

METHOD(V1, m_killed, void(Champions this, entity targ, entity inflictor, entity attacker, int deathtype))
{
	if(attacker.m_champion == this && IS_MONSTER(targ))
	{
		float healamount = bound(20, ((targ.max_health > 0) ? targ.max_health * 0.5 : 50), 100);
		T_Heal(attacker, healamount, false);
	}
}

METHOD(V1, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "falling.wav", ATTN_NORM);
	actor.v1_cannon = true;
}

METHOD(V1, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.v1_cannon)
	{
		if(V1_Sliding(actor) && actor.jump_flag < -300)
		{
			player_sound(actor, CH_TRIGGER_SINGLE, "slide_impact.wav", ATTN_NORM);
			Send_Effect(EFFECT_SMOKE_RING, actor.origin, '0 0 10', 1);
			T_RadiusDamage(actor, actor, 100, DEATH_TRAP.m_id, actor);
			actor.jump_flag = 0;
			actor.v1_antispam = time + 0.5;
			return true;
		}
		return false;
	}
	stopsound(actor, CH_TRIGGER_SINGLE);
	actor.v1_cannon = false;
	return false;
}

METHOD(V1, m_touch, void(Champions this, entity actor, entity toucher))
{
	if(StatusEffects_active(STATUSEFFECT_Shield, actor))
		return; // better version
	if(time < actor.v1_bash_time)
		return;
	if(actor.velocity == '0 0 0')
		return;
	if(!V1_Sliding(actor) || !IS_ONGROUND(actor) || vdist(actor.velocity, <, PHYS_MAXSPEED(actor) * 0.6))
		return;

	if(IS_MONSTER(toucher) && !(toucher.monsterdef.spawnflags & MONSTER_TYPE_DECOY))
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
			toucher.velocity = v_forward * (30 * pushforce);
			toucher.velocity_z = (60 * pushforce);
		}

		te_explosion2(toucher.origin, 230, 5);

		float thedamage = 10;
		//if(toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD)
			//thedamage = 120;

		T_Damage(toucher, actor, actor, thedamage, DEATH_SHIELD.m_id);

		player_sound(actor, CH_VOICE, "slide_slam.wav", ATTN_NORM);

		actor.v1_bash_time = time + 0.5;
	}
}
#endif

METHOD(V1, m_physics, bool(Champions this, entity actor, float dt))
{
	if(V1_Sliding(actor) && IS_ONGROUND(actor))
	{
#ifdef SVQC
		if(time > actor.v1_antispam && vdist(actor.velocity, >, PHYS_MAXSPEED(actor) * 0.6))
		{
			makevectors(actor.v_angle);
			Send_Effect(EFFECT_V1_SLIDE, actor.origin + v_forward * 40, v_forward * -400, 1);
			_sound(actor, CH_SHOTS, "player/axhit2.wav", 0.1, ATTN_NORM);
			actor.v1_antispam = time + 0.05;
		}
#endif
		actor.movement_y = 0; // no sideways movement!
	}

	if(!IS_ONGROUND(actor) && V1_Sliding(actor) && actor.velocity_z > -300 && actor.velocity_z < 200 && !IS_JUMP_HELD(actor))
	{
#ifdef SVQC
		player_sound(actor, CH_TRIGGER_SINGLE, "slide_slam.wav", ATTN_NORM);
#endif
		vector vang = PHYS_INPUT_ANGLES(actor);
		makevectors('0 1 0' * vang.y);
		actor.velocity += v_forward * 400;
		actor.velocity_z -= 800;
	}
	return false;
}

METHOD(V1, m_playerjump, float(Champions this, entity actor))
{
	if(V1_Sliding(actor) && vdist(actor.velocity, >, PHYS_MAXSPEED(actor) * 0.6))
	{
	#ifdef SVQC
		player_sound(actor, CH_TRIGGER_SINGLE, "slide_jump.wav", ATTN_NORM);
	#endif
		return 2.25;
	}
	return 1;
}
