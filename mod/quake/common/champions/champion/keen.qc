#include "keen.qh"

#ifdef SVQC
METHOD(Keen, m_activate, void(Keen this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
	STAT(WEAPONS, actor) |= WEP_POGO.m_wepset;
}
METHOD(Keen, m_clear, void(Keen this, entity actor))
{
	STAT(WEAPONS, actor) &= ~WEP_POGO.m_wepset;
}
#endif

#ifdef GAMEQC
METHOD(Keen, m_touch, void(Keen this, entity actor, entity toucher))
{
	if(STAT(POWERUPS, this) & POWERUP_JUMPBOOTS)
		return; // better version
#ifdef SVQC
	.entity weaponentity = weaponentities[0];
	if(actor.(weaponentity).m_weapon != WEP_POGO)
		return;

	if(IS_PLAYER(toucher) || IS_MONSTER(toucher))
#elif defined(CSQC)
	if(viewmodels[0].activeweapon != WEP_POGO)
		return;

	if(IS_PLAYER(toucher))
#endif
	{
		if(tracebox_hits_box(actor.origin, actor.mins, actor.maxs, actor.origin - ('0 0 1' * (actor.maxs_z + 5)), toucher.origin + toucher.mins, toucher.origin + toucher.maxs))
		{
			setorigin(actor, actor.origin + '0 0 2'); // make sure onground doesn't catch us later

			float mjumpheight = 150;
			if(PHYS_INPUT_BUTTON_JUMP(actor))
			{
				mjumpheight = 400;
				SET_JUMP_HELD(actor);
			}

			UNSET_ONGROUND(actor);
			actor.velocity_z = mjumpheight;
	#ifdef SVQC
			actor.oldvelocity_z = actor.velocity_z;

			//animdecide_setaction(actor, ANIMACTION_JUMP, true);

			float thedamage = 70;
			T_Damage(toucher, actor, actor, thedamage, DEATH_CRUSH.m_id);
			player_sound(actor, CH_VOICE, "jumpatk.wav", ATTN_NORM);
	#endif
			return;
		}
	}
}
#endif

METHOD(Keen, m_playerjump, float(Keen this, entity actor))
{
#ifdef CSQC
	if(viewmodels[0].activeweapon == WEP_POGO)
		return 0;
#endif
#ifdef SVQC
	.entity weaponentity = weaponentities[0];
	if(actor.(weaponentity).m_weapon == WEP_POGO)
		return 0;
#endif
	if(vdist(actor.velocity, <, PHYS_MAXSPEED(actor) * 0.6))
		return 2.5;
	return 1;
}

METHOD(Keen, m_physics, bool(Keen this, entity actor, float dt))
{
#ifdef CSQC
	if(viewmodels[0].activeweapon != WEP_POGO)
		return false;
#endif
#ifdef SVQC
	.entity weaponentity = weaponentities[0];
	if(actor.(weaponentity).m_weapon != WEP_POGO)
		return false;
#endif
	if(actor.waterlevel > 0)
		return false;
	if(IS_ONGROUND(actor))
	{
		if(PHYS_INPUT_BUTTON_JUMP(actor))
			actor.velocity_z += 540;
		else
			actor.velocity_z += 270;
	#ifdef SVQC
		player_sound(actor, CH_VOICE, "pogo.wav", ATTN_NORM);
	#endif
		UNSET_ONGROUND(actor);
	}
	else
	{
		makevectors(PHYS_WORLD_ANGLES(actor));
		vector vel = vec2(actor.velocity);
		float spd = vlen(vel);
		if(spd < 320)
			spd += 5;
		vel = v_forward * spd;
		actor.velocity_x = vel.x;
		actor.velocity_y = vel.y;
	}
	// fix for waterjump
	if(time > actor.teleport_time || actor.waterlevel == 0)
	{
		actor.flags &= ~FL_WATERJUMP;
		actor.teleport_time = 0;
	}
	return true;
}
