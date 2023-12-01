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
#endif

#ifdef SVQC
METHOD(Goat, m_touch, void(Goat this, entity actor, entity toucher))
{
	if(actor.powerups & POWERUP_SHIELD)
		return; // better version
	if(time < actor.goat_bash_time)
		return;
	if(actor.velocity == '0 0 0')
		return;
	if(time > STAT(QCC_ABILITYTIME, actor))
		return;

	if(IS_PLAYER(toucher) || (IS_MONSTER(toucher) && !(toucher.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(toucher.monsterdef.spawnflags & MON_FLAG_STATIONARY) && !(toucher.monsterdef.spawnflags & MONSTER_TYPE_DECOY)))
	{
		makevectors(actor.angles);
		vector vec = normalize(toucher.origin - actor.origin);
		float dot = vec * v_forward;
		if(dot < 0.3)
			return;

		float pushforce = 100 / vlen(toucher.maxs - toucher.mins);

		makevectors(actor.angles);
		toucher.velocity = v_forward * (300 * pushforce);
		toucher.velocity_z = (125 * pushforce);

		te_explosion2(toucher.origin, 230, 5);

		T_Damage(toucher, actor, actor, 30, DEATH_SHIELD.m_id);

		player_sound(actor, CH_VOICE, "bonk.wav", ATTN_NORM);

		actor.goat_bash_time = time + 0.5;
	}
}
#endif

METHOD(Goat, m_physics, bool(Goat this, entity actor, float dt))
{
	if(vdist(actor.velocity, <, PHYS_MAXSPEED(actor) * 0.6) && PHYS_INPUT_BUTTON_CROUCH(actor) && IS_ONGROUND(actor))
	{
	#ifdef SVQC
		if(random() < 0.1)
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
