void freeze_Unfreeze(entity ent)
{
	ent.freeze_flag = FROZEN_THAWING; // thawing is fine, as this is only checked when the player is frozen
	
	Kill_Notification(NOTIF_ONE_ONLY, ent, MSG_CENTER_CPID, CPID_FREEZE);
	
	Unfreeze(ent);
}


MUTATOR_HOOKFUNCTION(freeze_PlayerSpawn)
{
	freeze_Unfreeze(self);
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(freeze_PlayerDies)
{
	if(frag_deathtype == DEATH_HURTTRIGGER)
		return FALSE;
		
	SetRespawnDelays(); // player doesn't actually die
	
	float can_freeze = FALSE;
	
	if(frag_target.cvar_cl_freeze)
	if(cvar("g_freeze") == 1)
		can_freeze = TRUE;
		
	if(cvar("g_freeze") == 2)
		can_freeze = TRUE;
		
	if(cvar("g_freeze") == 3)
		can_freeze = FALSE; // force off (easier than disabling & restarting, will fix later)
	
	if(can_freeze)
	if not(frag_target.frozen)
	{
		Send_Notification(NOTIF_ONE_ONLY, frag_target, MSG_CENTER, CENTER_FREEZE_THAWING);
		frag_target.health = 1; // "respawn" the player :P
		Freeze(frag_target, 0, 1, FALSE);
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(freeze_PlayerPreThink)
{
	if(self.deadflag != DEAD_NO || self.classname != STR_PLAYER)
		return FALSE;
		
	float button_pressed;
	if(self.frozen == 1) // Auto revive in freeze mutator
	{
		self.revive_progress = bound(0, self.revive_progress + frametime * autocvar_g_freeze_revive_speed, 1);
		self.health = max(1, self.revive_progress * autocvar_g_balance_health_start);
		
		self.iceblock.alpha = bound(0.2, 1 - self.revive_progress, 1);
		
		if(self.health >= autocvar_g_freeze_revive_minhealth)
			button_pressed = (self.BUTTON_JUMP || self.BUTTON_USE); // we're about to defrost, only detect jumps
		else
			button_pressed = (self.BUTTON_ATCK || self.BUTTON_JUMP || self.BUTTON_ATCK2 || self.BUTTON_HOOK || self.BUTTON_USE);
		
		if(self.freeze_flag == FROZEN_THAWING)
		{
			if(!button_pressed)
				self.freeze_flag = FROZEN_WILLRESPAWN;
		}
		else if(self.freeze_flag == FROZEN_WILLRESPAWN)
		{
			if(button_pressed)
				self.freeze_flag = FROZEN_RESPAWNING;
		}
		else if(self.freeze_flag == FROZEN_RESPAWNING)
		{
			if(time > self.respawn_time)
			{
				self.respawn_time = time + 1; // only retry once a second
				PutClientInServer();
				return 1;
			}
		}

		if(self.revive_progress >= 1)
			freeze_Unfreeze(self);
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(freeze_PlayerDamage)
{
    if(frag_target.frozen == 1 && frag_deathtype != DEATH_HURTTRIGGER)
    {
        frag_damage = 0;
        frag_force = frag_force * autocvar_g_freeze_frozen_force;
    }
    return FALSE;
}

MUTATOR_HOOKFUNCTION(freeze_GetCvars)
{
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_freeze, "cl_freeze");

	return FALSE;
}

MUTATOR_HOOKFUNCTION(freeze_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":Freeze");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(freeze_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Freeze");
	return FALSE;
}

MUTATOR_DEFINITION(mutator_freeze)
{
	MUTATOR_HOOK(PlayerSpawn, freeze_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, freeze_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, freeze_PlayerPreThink, CBC_ORDER_FIRST);
	MUTATOR_HOOK(PlayerDamage_Calculate, freeze_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetCvars, freeze_GetCvars, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, freeze_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, freeze_BuildMutatorsPrettyString, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		precache_model("models/ice/ice.md3");
	}

	return FALSE;
}
