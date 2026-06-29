#include "crazydave.qh"

#ifdef SVQC
void CrazyDave_reset(entity this)
{
	this.crazydave_crazy_time = time + autocvar_sv_quake_crazydave_crazytime + (random() * autocvar_sv_quake_crazydave_crazytime);
}

void CrazyDave_Aggro(entity this)
{
	// force attention away from other players TODO: on a cooldown!
	FOREACH_ENTITY_RADIUS(this.origin, autocvar_sv_quake_crazydave_range, true,
	{
		if(IS_MONSTER(it) && it.health > 0 && it.enemy && !it.charmed && !(it.effects & EF_NODRAW) && !it.is_frozen && !it.elec && it.enemy != this && !wasfreed(it.enemy))
		{
			//if(gametype == GAMETYPE_TD)
				//continue;
			//if(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS)
				//continue;
			// low chance to aggro monsters each frame
			if(!checkpvs(this.origin, it))
				continue;
			it.aggro_time = time;
			if(IS_PLAYER(it.enemy))
				it.oldenemy = it.enemy;
			it.enemy = this;
			FoundTarget(it);
		}
	});

	this.show_hostile = time + 1; // wake monsters up
}

METHOD(CrazyDave, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		player_sound(actor, CH_PLAYER_SINGLE, "awooga.wav", ATTN_NORM);
		CrazyDave_Aggro(actor);
		STAT(QCC_ABILITYTIME, actor) = time + 5;
		CrazyDave_reset(actor);
	}

	if(time > actor.crazydave_crazy_time)
	{
		CrazyDave_reset(actor);
		float rsound = bound(1, rint(random() * 12), 11);
		string s = strcat("talk", ftos(rsound), ".wav");
		player_sound(actor, CH_VOICE, s, ATTN_NORM);
	}
}

METHOD(CrazyDave, m_takedamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(targ.m_champion == this)
	{
		if(deathmatch)
			return (StatusEffects_active(STATUSEFFECT_TacoPower, targ)) ? 0.6 : 0.75;
		return (StatusEffects_active(STATUSEFFECT_TacoPower, targ)) ? 0.3 : 0.5;
	}
	return 1;
}

METHOD(CrazyDave, m_activate, void(Champions this, entity actor))
{
	int r = bound(1, rint(random() * 7), 7);
	player_sound(actor, CH_VOICE, strcat("start", itos(r), ".wav"), ATTN_NORM);
	CrazyDave_reset(actor);

	Inventory_add(WEP_TACO, actor, ITEM_OWNED);
}

METHOD(CrazyDave, m_playerspawn, void(Champions this, entity actor))
{
	Inventory_add(WEP_TACO, actor, ITEM_OWNED);
}

METHOD(CrazyDave, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "cannon_launch.wav", ATTN_NORM);
	actor.crazydave_cannon = true;
	CrazyDave_reset(actor);
}

METHOD(CrazyDave, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.crazydave_cannon)
		return false;
	player_sound(actor, CH_TRIGGER_SINGLE, "cannon_land.wav", ATTN_NORM);
	actor.crazydave_cannon = false;
	CrazyDave_reset(actor);
	return false;
}
#endif
