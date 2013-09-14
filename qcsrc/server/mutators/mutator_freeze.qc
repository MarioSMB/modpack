void freeze_Unfreeze(entity ent)
{
	ent.freeze_flag = FROZEN_THAWING; // thawing is fine, as this is only checked when the player is frozen
	
	self.freezetag_frozen_time = 0;
	self.freezetag_frozen_timeout = 0;
	
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
	
	frag_target.revivals_row = 0;
	
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
		if not(teamplay && autocvar_g_freeze_noauto)
		if(IS_REAL_CLIENT(frag_target))
			Send_Notification(NOTIF_ONE_ONLY, frag_target, MSG_CENTER, CENTER_FREEZE_THAWING);
		frag_target.health = 1; // "respawn" the player :P
		
		if(g_minstagib)
			frag_target.ammo_cells = start_ammo_cells; // we need more ammo in minstagib, otherwise the player will defrost & die again
			
		if(ITEM_DAMAGE_NEEDKILL(frag_deathtype)
			|| frag_deathtype == DEATH_TEAMCHANGE || frag_deathtype == DEATH_AUTOTEAMCHANGE)
		{
			// let the player die, he will be automatically frozen when he respawns
			if(self.frozen == 1)
				freeze_Unfreeze(self); // remove ice
			return 1;
		}
		
		Freeze(frag_target, 0, 1, (teamplay && autocvar_g_freeze_noauto));
		if(autocvar_g_freezetag_frozen_maxtime > 0)
			self.freezetag_frozen_timeout = time + autocvar_g_freezetag_frozen_maxtime;
		self.freezetag_frozen_time = time;
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(freeze_PlayerPreThink)
{
	if(self.deadflag != DEAD_NO || !IS_PLAYER(self) || gameover)
		return FALSE;
		
	if(round_handler_IsActive())
	if(!round_handler_IsRoundStarted())
		return FALSE;
		
	float button_pressed, n;
	
	if(teamplay && autocvar_g_freeze_noauto)
	{
		// copied from freezetag
		if(self.frozen == 1)
		{
			// keep health = 1
			self.pauseregen_finished = time + autocvar_g_balance_pause_health_regen;
		}		

		if(self.frozen == 1)
		{
			button_pressed = (!autocvar_g_freeze_norespawn && (self.BUTTON_JUMP || self.BUTTON_USE)); // only detect jumps
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
				}
				
				return 1; // if we get here, normal revivals have been cancelled
			}
		}
			
		if(self.frozen == 1)
		{
			float frozen_count = 0, nplayers = 0;
			FOR_EACH_PLAYER(other) if(SAME_TEAM(self, other))
			{
				++nplayers;
				if(other.frozen == 1)
					++frozen_count;
			}
			if(nplayers == frozen_count)
			{
				FOR_EACH_PLAYER(other) if(SAME_TEAM(self, other))
				{
					other.freeze_flag = FROZEN_RESPAWNING;
					other.respawn_time = time + autocvar_g_freeze_respawn_time;
					PlayerScore_Add(other, SP_SCORE, -1); // lose score for this
				}
				
				return 1;
			}
		}
		
		entity o;
		o = world;
		if(self.freezetag_frozen_timeout > 0 && time < self.freezetag_frozen_timeout)
			self.iceblock.alpha = ICE_MIN_ALPHA + (ICE_MAX_ALPHA - ICE_MIN_ALPHA) * (self.freezetag_frozen_timeout - time) / (self.freezetag_frozen_timeout - self.freezetag_frozen_time);

		if(self.freezetag_frozen_timeout > 0 && time >= self.freezetag_frozen_timeout)
			n = -1;
		else
		{
			vector revive_extra_size = '1 1 1' * autocvar_g_freezetag_revive_extra_size;
			n = 0;
			FOR_EACH_PLAYER(other) if(self != other)
			{
				if(other.deadflag == DEAD_NO)
				if(other.frozen == 0)
				{
					if(SAME_TEAM(other, self))
					{
						if(boxesoverlap(self.absmin - revive_extra_size, self.absmax + revive_extra_size, other.absmin, other.absmax))
						{
							if(!o)
								o = other;
							if(self.frozen == 1)
								other.reviving = TRUE;
							++n;
						}
					}
				}
			}
		}

		if(n && self.frozen == 1) // OK, there is at least one teammate reviving us
		{
			self.revive_progress = bound(0, self.revive_progress + frametime * max(1/60, autocvar_g_freezetag_revive_speed), 1);
			self.health = max(1, self.revive_progress * autocvar_g_balance_health_start);

			if(self.revive_progress >= 1)
			{
				freeze_Unfreeze(self);

				if(n == -1)
				{
					Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_FREEZETAG_AUTO_REVIVED, autocvar_g_freezetag_frozen_maxtime);
					Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_FREEZETAG_AUTO_REVIVED, self.netname, autocvar_g_freezetag_frozen_maxtime);
					return 1;
				}

				// EVERY team mate nearby gets a point (even if multiple!)
				FOR_EACH_PLAYER(other)
				{
					if(other.reviving)
					{
						PlayerScore_Add(other, SP_SCORE, +1);
						
						if ( autocvar_g_nades_bonus_unfreeze )
						{
							other.revivals_row++;
							if ( other.revivals_row >= autocvar_g_nades_bonus_unfreeze )
							{
								other.revivals_row = 0;
								nades_GiveBonus(other);
							}
						}
					}
				}

				Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_FREEZETAG_REVIVED, o.netname);
				Send_Notification(NOTIF_ONE, o, MSG_CENTER, CENTER_FREEZETAG_REVIVE, self.netname);
				Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_FREEZETAG_REVIVED, self.netname, o.netname);
			}

			FOR_EACH_PLAYER(other)
			{
				if(other.reviving)
				{
					other.revive_progress = self.revive_progress;
					other.reviving = FALSE;
				}
			}
		}
		else if(!n && self.frozen == 1) // only if no teammate is nearby will we reset
		{
			self.revive_progress = bound(0, self.revive_progress - frametime * autocvar_g_freezetag_revive_clearspeed, 1);
			self.health = max(1, self.revive_progress * autocvar_g_balance_health_start);
		}
		else if(!n && !self.frozen)
		{
			self.revive_progress = 0; // thawing nobody
		}
	}
	else if(self.frozen == 1) // auto revive
	{
		float rspeed = autocvar_g_freeze_revive_speed;
		if(autocvar_g_freeze_revive_speed_random)
			rspeed *= (random() * autocvar_g_freeze_revive_speed_random);
		
		self.revive_progress = bound(0, self.revive_progress + frametime * rspeed, 1);
		self.health = max(1, self.revive_progress * autocvar_g_balance_health_start);
		
		if(self.health >= autocvar_g_freeze_revive_minhealth)
			button_pressed = (self.BUTTON_JUMP || self.BUTTON_USE); // we're about to defrost, only detect jumps
		else
			button_pressed = (self.BUTTON_ATCK || self.BUTTON_JUMP || self.BUTTON_ATCK2 || self.BUTTON_HOOK || self.BUTTON_USE);
			
		if(autocvar_g_freeze_norespawn)
			button_pressed = 0; // don't allow re-spawning via jump/attack
		
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
    if(frag_target.frozen == 1 && frag_deathtype != DEATH_HURTTRIGGER && frag_deathtype != DEATH_TEAMCHANGE && frag_deathtype != DEATH_AUTOTEAMCHANGE)
    {
		if(autocvar_g_freeze_revive_falldamage > 0)
		if(frag_deathtype == DEATH_FALL)
		if(frag_damage >= autocvar_g_freeze_revive_falldamage)
		{
			freeze_Unfreeze(frag_target);
			frag_target.health = autocvar_g_freeze_revive_falldamage_health;
			pointparticles(particleeffectnum("iceorglass"), frag_target.origin, '0 0 0', 3);
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_FREEZETAG_REVIVED_FALL, frag_target.netname);
			Send_Notification(NOTIF_ONE, frag_target, MSG_CENTER, CENTER_FREEZETAG_REVIVE_FALL);
		}
	
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
