MUTATOR_HOOKFUNCTION(effects_WeaponRateFactor)
{
	if(StatusEffect_Timed(self, STATUS_EFFECT_COLD))
		weapon_rate *= 1.3;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(effects_PlayerPhysics)
{
	if(StatusEffect_Timed(self, STATUS_EFFECT_COLD))
	{
		self.stat_sv_maxspeed *= 0.7;
		self.stat_sv_airspeedlimit_nonqw *= 0.7;
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(effects_PlayerSpawn)
{
	ResetStatusEffects(self);

	if(time < game_starttime)
		StatusEffect(self, STATUS_EFFECT_SPAWNSHIELD) += game_starttime - time;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(effects_PlayerDamage)
{
	if(IS_PLAYER(frag_attacker) && StatusEffect_Timed(frag_target, STATUS_EFFECT_SPAWNSHIELD))
		frag_damage = 0;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(effects_PlayerPowerups)
{
	if(self.deadflag || gameover || !IS_PLAYER(self) || time < game_starttime)
		return FALSE;

	if (self.waterlevel != WATERLEVEL_SUBMERGED)
	{
		if(self.air_finished < time)
			PlayerSound(playersound_gasp, CH_PLAYER, VOICETYPE_PLAYERSOUND);
	
		StatusEffect(self, STATUS_EFFECT_DROWNING) = 0;
		self.air_finished = time + autocvar_g_balance_contents_drowndelay;
	}
	else if(self.air_finished < time && time >= self.status_effects_delay)
	{
		StatusEffect(self, STATUS_EFFECT_DROWNING) = 1;
		Damage(self, self, self.status_effect_inflictor, 1, DEATH_EFFECT_DROWN, self.origin, '0 0 0');
		self.status_effects_delay = time + autocvar_g_status_effects_delay;
	}

	if(self.watertype == CONTENT_LAVA)
		StatusEffect(self, STATUS_EFFECT_BURNING) = time + 3;

	if(self.frozen)
		StatusEffect(self, STATUS_EFFECT_COLD) = time + 6;

	if(self.waterlevel >= WATERLEVEL_SWIMMING || self.frozen)
		StatusEffect(self, STATUS_EFFECT_BURNING) = 0;

	if(StatusEffect_Timed(self, STATUS_EFFECT_BURNING))
	{
		Damage(self, self, self.status_effect_inflictor, 1, DEATH_EFFECT_BURN, self.origin, '0 0 0');
		self.effects |= EF_FLAME;
		self.status_effects_delay = time + autocvar_g_status_effects_delay;
	}

	if(StatusEffect_Timed(self, STATUS_EFFECT_SPAWNSHIELD))
		self.effects |= (EF_ADDITIVE | EF_FULLBRIGHT);

	return FALSE;
}

MUTATOR_DEFINITION(mutator_status_effects)
{
	MUTATOR_HOOK(WeaponRateFactor, effects_WeaponRateFactor, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPhysics, effects_PlayerPhysics, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, effects_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, effects_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPowerups, effects_PlayerPowerups, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		StatusEffects_AddStats();
	}

	return FALSE;
}
