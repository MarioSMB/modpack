#include "v1.qh"

METHOD(V1, m_footsteps, bool(Champions this, entity actor))
{
	return V1_Sliding(actor);
}

METHOD(V1, m_friction, float(Champions this, entity actor))
{
	if(V1_Sliding(actor))
		return 0.1;
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
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && actor.waterlevel <= 1 && !(actor.flags & FL_WATERJUMP) && QCC_CanCastAbility(actor))
		return true;
	return false;
}

#ifdef SVQC
METHOD(V1, m_updatestats, void(Champions this, entity actor))
{
	// doesn't play nicely
	STAT(MOVEVARS_AIRCONTROL, actor) = 0;
}

METHOD(V1, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, SND_V1_Start_Random(), ATTN_NORM);

	Inventory_add(WEP_KATANA, actor, ITEM_OWNED);
}

METHOD(V1, m_playerspawn, void(Champions this, entity actor))
{
	Inventory_add(WEP_KATANA, actor, ITEM_OWNED);
}

METHOD(V1, m_killed, void(Champions this, entity targ, entity inflictor, entity attacker, int deathtype))
{
	if(attacker.m_champion == this && IS_MONSTER(targ))
	{
		float toheal = bound(20, ((targ.max_health > 0) ? targ.max_health * 0.5 : 50), 100);
		T_Heal(attacker, toheal, false);
	}
}

METHOD(V1, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_PLAYER_SINGLE, SND_V1_Cannon_Launch, ATTN_NORM);
	actor.v1_cannon = true;
}

METHOD(V1, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.v1_cannon)
	{
		if(V1_Sliding(actor) && actor.jump_flag < -300)
		{
			// easiest place to cancel out fall damage and add our sound
			player_sound(actor, CH_PLAYER_SINGLE, SND_V1_Slide_Impact, ATTN_NORM);
			Send_Effect(EFFECT_SMOKE_RING, actor.origin, '0 0 10', 1);
			if(!deathmatch)
				T_RadiusDamage(actor, actor, 100, DEATH_CRUSH.m_id, actor);
			actor.jump_flag = 0;
			actor.v1_antispam = time + 0.25;
			return true;
		}
		return false;
	}
	stopsound(actor, CH_PLAYER_SINGLE);
	actor.v1_cannon = false;
	return false;
}

METHOD(V1, m_touch, void(Champions this, entity actor, entity toucher))
{
	if(StatusEffects_active(STATUSEFFECT_PowerShield, actor))
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

		player_sound(actor, CH_VOICE, SND_V1_Slide_Slam, ATTN_NORM);

		actor.v1_bash_time = time + 0.5;
	}
}
#endif

vector V1_SlamDirection(entity actor)
{
	float tap_direction_x = 0;
	float tap_direction_y = 0;
	bool dodge_detected = false;
	vector mymovement = actor.movement;

#define X(COND,RESULT)				\
	if (mymovement_##COND) {		\
		tap_direction_##RESULT;		\
		dodge_detected = true;		\
	}
	X(x < 0,	x--);
	X(x > 0,	x++);
	X(y < 0,	y--);
	X(y > 0,	y++);
#undef X

	if(!dodge_detected)
		return '1 0 0'; // fallback to forward

	return vec2(tap_direction_x, tap_direction_y);
}

METHOD(V1, m_physics, bool(Champions this, entity actor, float dt))
{
	if(V1_Sliding(actor) && IS_ONGROUND(actor))
	{
#ifdef SVQC
		if(time > actor.v1_antispam && vdist(actor.velocity, >, PHYS_MAXSPEED(actor) * 0.6))
		{
			vector vangle = PHYS_INPUT_ANGLES(actor);
			makevectors('0 1 0' * vangle.y);
			Send_Effect(EFFECT_V1_SLIDE, actor.origin + v_up * -10 + v_forward * 40, v_forward * -100 + v_up * 50, 10);
			_sound(actor, CH_SHOTS, "player/axhit2.wav", 0.1, ATTN_NORM); // TODO: better channel and stuff
			actor.v1_antispam = time + 0.05;
		}
#endif
		actor.movement_x = 0;
		actor.movement_y = 0;
	}

	if(!IS_ONGROUND(actor) && V1_Sliding(actor) && actor.velocity_z > -300 && actor.velocity_z < 200 && !IS_JUMP_HELD(actor))
	{
#ifdef SVQC
		player_sound(actor, CH_PLAYER_SINGLE, SND_V1_Slide_Slam, ATTN_NORM);
#endif
		vector vang = PHYS_INPUT_ANGLES(actor);
		makevectors('0 1 0' * vang.y);
		if(vdist(vec2(actor.velocity), <, 600))
		{
			float forwardspeed = 400;
			if(STAT(V1_SLAM_DIRECTIONAL))
			{
				vector tap_direction = V1_SlamDirection(actor);
				float sidespeed = forwardspeed * STAT(V1_SLAM_DIRECTIONAL_SIDESCALE);
				actor.velocity += tap_direction.x * forwardspeed * v_forward + tap_direction.y * sidespeed * v_right;
			}
			else
				actor.velocity += v_forward * forwardspeed;
		}
		actor.velocity_z -= 800;
	}
	return false;
}

METHOD(V1, m_playerjump, float(Champions this, entity actor))
{
	if(V1_Sliding(actor) && vdist(actor.velocity, >, PHYS_MAXSPEED(actor) * 0.6))
	{
	#ifdef SVQC
		player_sound(actor, CH_PLAYER_SINGLE, SND_V1_Slide_Jump, ATTN_NORM);
	#endif
		return 2;
	}
	return 1;
}
