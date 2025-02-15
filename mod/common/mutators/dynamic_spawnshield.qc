//FEATURE: Dynamic Spawnshield mutator, copied from The Regulars, adjusts spawn shield length to benefit those getting spawnkilled

#ifdef GAMEQC
// how many times player spawnkilled someone
REGISTER_SP(SPWN_KILLS);
// how many times player has been spawnkilled
REGISTER_SP(SPWN_KILLED);
#endif

#ifdef SVQC
AUTOCVAR(g_spawnshielddynamic, float, 0, "enable Dynamic Spawnshield mutator, set to 0.6 for a sensible value");
AUTOCVAR(sv_spawnkill_time, float, 1.6, "time after spawn which considers to be spawnkill");

REGISTER_MUTATOR(dynamic_spawnshield, autocvar_g_spawnshielddynamic > 0);

.int spawnkilled_series;
.int spawnkill_series;

ACCUMULATE void ScoreRules_basics(int teams, float sprio, float stprio, float score_enabled)
{
	if(autocvar_g_spawnshielddynamic > 0 && !INDEPENDENT_PLAYERS)
	{
		ScoreInfo_SetLabel_PlayerScore(SP_SPWN_KILLS, "spawnkills", 0);
		ScoreInfo_SetLabel_PlayerScore(SP_SPWN_KILLED, "spawnkilled", 0);
	}
}

float CalculateSpawnShield(entity this)
{
	if(autocvar_g_spawnshielddynamic > 0 && this.spawnkilled_series > 0)
	{
		int spawnkilled = this.spawnkilled_series - 1;
		// partial sum for series: sum(2 ^ -i)
		float val = pow(2, -spawnkilled) * (pow(2, spawnkilled + 1) - 1);
		return autocvar_g_spawnshieldtime + val * autocvar_g_spawnshielddynamic;
	}
	else
		return autocvar_g_spawnshieldtime;
}

MUTATOR_HOOKFUNCTION(dynamic_spawnshield, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);
	float shieldtime = StatusEffects_gettime(STATUSEFFECT_SpawnShield, player) - time;
	shieldtime = max(shieldtime, CalculateSpawnShield(player));

	StatusEffects_apply(STATUSEFFECT_SpawnShield, player, time + shieldtime, 0);
}

void CheckSpawnkill(entity this, entity attacker)
{
	if(autocvar_g_spawnshielddynamic <= 0 || autocvar_sv_spawnkill_time <= 0)
		return;
	if(this == attacker)
	{
		this.spawnkilled_series = 0;
		this.spawnkill_series = 0;
		return;
	}
	if((time - this.alivetime) < autocvar_sv_spawnkill_time)
	{
		PlayerScore_Add(this, SP_SPWN_KILLED, 1);
		PlayerScore_Add(attacker, SP_SPWN_KILLS, 1);
		this.spawnkilled_series++;
		attacker.spawnkill_series++;
	}
	else
		this.spawnkilled_series = 0;

	this.spawnkill_series = 0;
}

// NOTE: needs to be done in PlayerDamaged so we have access to .alivetime
MUTATOR_HOOKFUNCTION(dynamic_spawnshield, PlayerDamaged, CBC_ORDER_LAST)
{
	entity frag_attacker = M_ARGV(0, entity);
	entity frag_target = M_ARGV(1, entity);

	if(GetResource(frag_target, RES_HEALTH) < 1 && frag_target.alivetime)
		CheckSpawnkill(frag_target, frag_attacker);
}
#endif
