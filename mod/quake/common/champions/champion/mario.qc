#include "mario.qh"

#ifdef SVQC
METHOD(Mario, m_activate, void(Mario this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
}

METHOD(Mario, m_condition, bool(Mario this, entity actor))
{
	if(autocvar_sv_allow_customplayermodels_speciallist == "")
		return true;
	return !PlayerInList(actor, autocvar_sv_allow_customplayermodels_speciallist);
}
#endif

#ifdef GAMEQC
METHOD(Mario, m_touch, void(Mario this, entity actor, entity toucher))
{
	if(STAT(POWERUPS, this) & POWERUP_JUMPBOOTS)
		return; // better version
#ifdef SVQC
	if(IS_PLAYER(toucher) || IS_MONSTER(toucher))
#elif defined(CSQC)
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

			float thedamage = 50;
			if(toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD)
				thedamage = 120;
			T_Damage(toucher, actor, actor, thedamage, DEATH_CRUSH.m_id);
			sound(actor, CH_TRIGGER_SINGLE, SND_Mario_Crush, 1, ATTN_NORM);
	#endif
			return;
		}
	}
}
#endif
