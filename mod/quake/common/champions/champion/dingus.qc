#include "dingus.qh"

#ifdef SVQC
METHOD(Dingus, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
}

METHOD(Dingus, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "death2.wav", ATTN_NORM);
	actor.dingus_cannon = true;
}

METHOD(Dingus, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.dingus_cannon)
		return false;
	stopsound(actor, CH_TRIGGER_SINGLE);
	actor.dingus_cannon = false;
	return false;
}

METHOD(Dingus, m_condition, bool(Champions this, entity actor))
{
	if(autocvar_sv_allow_customplayermodels_dingus == "")
		return true;
	return !PlayerInList(actor, autocvar_sv_allow_customplayermodels_dingus);
}

METHOD(Dingus, m_touch, void(Champions this, entity actor, entity toucher))
{
	if(StatusEffects_active(STATUSEFFECT_Shield, actor))
		return; // better version
	if(time < actor.dingus_bash_delay)
		return;
	if(actor.velocity == '0 0 0')
		return;

	if((IS_PLAYER(toucher) && !autocvar_g_friendlyfire_virtual) || (IS_MONSTER(toucher) && !(toucher.monsterdef.spawnflags & MONSTER_TYPE_DECOY)))
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
			toucher.velocity = v_forward * (20 * pushforce);
			toucher.velocity_z = (50 * pushforce);
		}

		float thedamage = 15;
		if(toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD)
			thedamage = 120;

		T_Damage(toucher, actor, actor, thedamage, DEATH_CRUSH.m_id);
		player_sound(actor, CH_VOICE, "oops.wav", ATTN_NORM);

		actor.dingus_bash_delay = time + 0.5;
	}
}
#endif
