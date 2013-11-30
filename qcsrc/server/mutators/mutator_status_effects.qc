MUTATOR_HOOKFUNCTION(effects_PlayerThink)
{
	// check to enable the status effects
	if(!IS_PLAYER(self) || gameover || self.deadflag)
		return FALSE;
		
	if (self.waterlevel != WATERLEVEL_SUBMERGED)
	{
		if(self.air_finished < time)
			PlayerSound(playersound_gasp, CH_PLAYER, VOICETYPE_PLAYERSOUND);
			
		StatusEffect(self, STATUS_EFFECT_DROWNING) = 0;
		self.air_finished = time + autocvar_g_balance_contents_drowndelay;
	}
	else if(self.air_finished < time)
		StatusEffect(self, STATUS_EFFECT_DROWNING) = 1;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(effects_PlayerPowerups)
{
	// apply the effects
	if(self.deadflag || gameover || !IS_PLAYER(self))
		return FALSE;
		
	if(StatusEffect(self, STATUS_EFFECT_DROWNING) == 1 && time >= self.status_effects_delay)
	{
		Damage(self, self, self.status_effect_inflictor, 1, DEATH_EFFECT_DROWN, self.origin, '0 0 0');
		self.status_effects_delay = time + 0.1;
	}

	if(self.waterlevel >= WATERLEVEL_SWIMMING || self.frozen)
		StatusEffect(self, STATUS_EFFECT_BURNING) = 0;

	if(StatusEffect_Timed(self, STATUS_EFFECT_BURNING))
	{
		Damage(self, self, self.status_effect_inflictor, 1, DEATH_EFFECT_BURN, self.origin, '0 0 0');
		self.effects |= EF_FLAME;
		self.status_effects_delay = time + 0.1;
	}

	return FALSE;
}

void status_effects_Initialize()
{
	StatusEffects_AddStats();
}

MUTATOR_DEFINITION(mutator_status_effects)
{
	MUTATOR_HOOK(PlayerPreThink, effects_PlayerThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPowerups, effects_PlayerPowerups, CBC_ORDER_ANY);
	
	MUTATOR_ONADD
	{
		status_effects_Initialize();
	}

	return FALSE;
}
