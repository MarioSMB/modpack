#include "goat.qh"

#ifdef SVQC
METHOD(Goat, m_activate, void(Goat this, entity actor))
{
	_sound(actor, CH_WEAPON_SINGLE, "goatling/death1.wav", 1, ATTN_NORM);
}

METHOD(Goat, m_condition, bool(Goat this, entity actor))
{
	if(autocvar_sv_allow_customplayermodels_goatlist == "")
		return true;
	return !PlayerInList(actor, autocvar_sv_allow_customplayermodels_goatlist);
}

METHOD(Goat, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "death2.wav", ATTN_NORM);
	actor.goat_cannon = true;
}

METHOD(Goat, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.goat_cannon)
		return false;
	_sound(actor, CH_TRIGGER_SINGLE, "goatling/idle6.wav", 1, ATTN_NORM);
	actor.goat_cannon = false;
	actor.jump_flag = 0;
	return true;
}
#endif

#ifdef SVQC
METHOD(Goat, m_playerthink, void(Champions this, entity actor))
{
	if(random() < actor.cvar_cl_quake_goatstuff && vdist(actor.velocity, >, 250))
	{
		entity musicnote = new(musicnote);
		makevectors(actor.v_angle);
		setorigin(musicnote, actor.origin + v_forward * -45);
		_setmodel(musicnote, "progs/piano_musicnote_white.mdl");
		musicnote.scale = 0.75;
		musicnote.effects = EF_FULLBRIGHT;
		setsize(musicnote, '0 0 0', '0 0 0');
		musicnote.angles = '0 1 0' * actor.angles_y;
		if(time > actor.goat_brown_time && random() < 0.125)
		{
			musicnote.colormod = '0.5 0.25 0';
			_sound(actor, CH_TRIGGER_SINGLE, "goatling/idle6.wav", 1, ATTN_NORM);
			actor.goat_brown_time = time + 3;
			set_movetype(musicnote, MOVETYPE_BOUNCE);
		}
		else
		{
			musicnote.colormod = '0 1 0';
			set_movetype(musicnote, MOVETYPE_FLY);
		}
		SUB_SetFade(musicnote, time + 0.1, 0.5);
		musicnote.velocity = '0 0 150' + v_forward * -100;
	}
}

METHOD(Goat, m_touch, void(Goat this, entity actor, entity toucher))
{
	if(StatusEffects_active(STATUSEFFECT_Shield, actor))
		return; // better version
	if(time < actor.goat_bash_time)
		return;
	if(actor.velocity == '0 0 0')
		return;
	if(time > STAT(QCC_ABILITYTIME, actor))
		return;

	if(IS_PLAYER(toucher) || (IS_MONSTER(toucher) && !(toucher.monsterdef.spawnflags & MONSTER_TYPE_DECOY)))
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
			toucher.velocity = v_forward * (300 * pushforce);
			toucher.velocity_z = (125 * pushforce);
		}

		te_explosion2(toucher.origin, 230, 5);

		float thedamage = 30;
		if(toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD)
			thedamage = 120;

		T_Damage(toucher, actor, actor, thedamage, DEATH_SHIELD.m_id);

		player_sound(actor, CH_VOICE, "bonk.wav", ATTN_NORM);

		actor.goat_bash_time = time + 0.5;
	}
}
#endif

METHOD(Goat, m_physics, bool(Goat this, entity actor, float dt))
{
	if(vdist(actor.velocity, <, PHYS_MAXSPEED(actor) * 0.6) && PHYS_INPUT_BUTTON_CROUCH(actor) && IS_ONGROUND(actor) && !QCC_HasSpellbook(actor))
	{
	#ifdef SVQC
		if(autocvar_sv_quake_fixstuff || random() < 0.1)
			player_sound(actor, CH_WEAPON_SINGLE, "death2.wav", ATTN_NORM);
		else
			_sound(actor, CH_WEAPON_SINGLE, SND(Goat_Pain_Random()), 1, ATTN_NORM);
		STAT(QCC_ABILITYTIME, actor) = time + 1;
	#endif
		fixedmakevectors(actor.angles);
		actor.velocity += v_forward * 700;
		actor.velocity_z += 100;
		UNSET_ONGROUND(actor);
	}
	return false;
}
