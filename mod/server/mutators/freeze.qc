REGISTER_MUTATOR(freeze, cvar("g_freeze") && !IS_GAMETYPE(FREEZETAG) && !IS_GAMETYPE(CA) && !IS_GAMETYPE(CTS) && !IS_GAMETYPE(RACE));

AUTOCVAR(g_freeze, bool, false, _("Enable freeze mutator (similar to freezetag, but for other modes)"));
AUTOCVAR(g_freeze_noauto, bool, false, _("Don't automatically unfreeze the player"));
AUTOCVAR(g_freeze_norespawn, bool, false, _("Don't allow re-spawning instantly by jumping"));
AUTOCVAR(g_freeze_revive_speed, float, 0.2, "");
AUTOCVAR(g_freeze_revive_speed_random, float, 0, "");
AUTOCVAR(g_freeze_revive_minhealth, int, 50, "");
AUTOCVAR(g_freeze_frozen_maxtime, float, 20, "");
AUTOCVAR(g_freeze_respawn_time, float, 1, "");

.int freeze_flag; // used to check if the player is going to respawn or thaw out
const int FROZEN_THAWING = 0; // player is thawing, don't take any action
const int FROZEN_WILLRESPAWN = 1; // waiting for player to release the trigger key
const int FROZEN_RESPAWNING = 2; // player released the key, respawn when we can

.int cvar_cl_freeze;

void freeze_Unfreeze(entity ent)
{
	ent.freeze_flag = FROZEN_THAWING; // thawing is fine, as this is only checked when the player is frozen

	self.freezetag_frozen_time = 0;
	self.freezetag_frozen_timeout = 0;

	Kill_Notification(NOTIF_ONE_ONLY, ent, MSG_CENTER_CPID, CPID_FREEZE);

	Unfreeze(ent);
}


MUTATOR_HOOKFUNCTION(freeze, PlayerSpawn)
{
	freeze_Unfreeze(self);
	return false;
}

MUTATOR_HOOKFUNCTION(freeze, PlayerDies)
{
	if(frag_deathtype == DEATH_HURTTRIGGER.m_id)
		return false;

	calculate_player_respawn_time(frag_target); // player doesn't actually die

	bool can_freeze = false;

	if(frag_target.cvar_cl_freeze)
	if(cvar("g_freeze") == 1)
		can_freeze = true;

	if(cvar("g_freeze") == 2)
		can_freeze = true;

	if(cvar("g_freeze") == 3)
		can_freeze = false; // force off (easier than disabling & restarting, will fix later)
		
	if(ITEM_DAMAGE_NEEDKILL(frag_deathtype))
	{
		if(STAT(FROZEN, frag_target))
			frag_target.freeze_flag = FROZEN_RESPAWNING;
		return true;
	}

	if(can_freeze)
	if(!STAT(FROZEN, frag_target))
	{
		if(!(teamplay && autocvar_g_freeze_noauto))
		if(IS_REAL_CLIENT(frag_target))
			Send_Notification(NOTIF_ONE_ONLY, frag_target, MSG_CENTER, CENTER_FREEZE_THAWING);
		frag_target.health = 1; // "respawn" the player :P

		if(g_instagib)
			frag_target.ammo_cells = start_ammo_cells; // we need more ammo in instagib, otherwise the player will defrost & die again

		if(frag_deathtype == DEATH_TEAMCHANGE.m_id || frag_deathtype == DEATH_AUTOTEAMCHANGE.m_id)
		{
			// let the player die, he will be automatically frozen when he respawns
			if(STAT(FROZEN, frag_target) == 1)
				freeze_Unfreeze(frag_target); // remove ice
			return 1;
		}

		Freeze(frag_target, 0, 1, (teamplay && autocvar_g_freeze_noauto));
		if(autocvar_g_freeze_frozen_maxtime > 0)
			frag_target.freezetag_frozen_timeout = time + autocvar_g_freeze_frozen_maxtime;
		frag_target.freezetag_frozen_time = time;
	}

	return false;
}

MUTATOR_HOOKFUNCTION(freeze, PlayerPreThink)
{
	if(IS_DEAD(self) || !IS_PLAYER(self) || gameover)
		return false;

	if(round_handler_IsActive())
	if(!round_handler_IsRoundStarted())
		return false;

	bool button_pressed = false;
	int n;

	if(teamplay && autocvar_g_freeze_noauto)
	{
		// copied from freezetag
		if(STAT(FROZEN, self) == 1)
		{
			// keep health = 1
			self.pauseregen_finished = time + autocvar_g_balance_pause_health_regen;
		}

		if(STAT(FROZEN, self) == 1)
		{
			button_pressed = (!autocvar_g_freeze_norespawn && (self.BUTTON_JUMP || self.BUTTON_USE)); // only detect jumps
			if(IS_GAMETYPE(LMS) || IS_GAMETYPE(CA)) { self.freeze_flag = FROZEN_RESPAWNING; } // these modes require player to die
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
					if(self.nade)
						toss_nade(self, '0 0 100', max(self.nade.wait, time + 0.05));
					PutClientInServer();
				}

				return 1; // if we get here, normal revivals have been cancelled
			}
		}

		if(STAT(FROZEN, self) == 1)
		{
			int frozen_count = 0, nplayers = 0;
			FOREACH_CLIENT(IS_PLAYER(it) && SAME_TEAM(it, self), LAMBDA(
				++nplayers;
				if(STAT(FROZEN, it) == 1)
					++frozen_count;
			));
			if(nplayers == frozen_count)
			{
				FOREACH_CLIENT(IS_PLAYER(it) && SAME_TEAM(it, self), LAMBDA(
					it.freeze_flag = FROZEN_RESPAWNING;
					it.respawn_time = time + autocvar_g_freeze_respawn_time;
					PlayerScore_Add(it, SP_SCORE, -1); // lose score for this
				));

				return 1;
			}
		}

		entity o;
		o = world;
		//if(self.freezetag_frozen_timeout > 0 && time < self.freezetag_frozen_timeout)
		//if(self.iceblock)
			//self.iceblock.alpha = ICE_MIN_ALPHA + (ICE_MAX_ALPHA - ICE_MIN_ALPHA) * (self.freezetag_frozen_timeout - time) / (self.freezetag_frozen_timeout - self.freezetag_frozen_time);

		if(self.freezetag_frozen_timeout > 0 && time >= self.freezetag_frozen_timeout)
			n = -1;
		else
		{
			vector revive_extra_size = '1 1 1' * autocvar_g_freezetag_revive_extra_size;
			n = 0;
			FOREACH_CLIENT(IS_PLAYER(it) && it != self && !IS_DEAD(it) && !STAT(FROZEN, it) && SAME_TEAM(it, self), LAMBDA(
				if(boxesoverlap(self.absmin - revive_extra_size, self.absmax + revive_extra_size, it.absmin, it.absmax))
				{
					if(!o)
						o = it;
					if(STAT(FROZEN, self) == 1)
						it.reviving = true;
					++n;
				}
			));
		}

		if(n && STAT(FROZEN, self) == 1) // OK, there is at least one teammate reviving us
		{
			self.revive_progress = bound(0, self.revive_progress + frametime * max(1/60, autocvar_g_freezetag_revive_speed), 1);
			self.health = max(1, self.revive_progress * start_health);

			if(self.revive_progress >= 1)
			{
				freeze_Unfreeze(self);

				if(n == -1)
				{
					Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_FREEZETAG_AUTO_REVIVED, autocvar_g_freeze_frozen_maxtime);
					Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_FREEZETAG_AUTO_REVIVED, self.netname, autocvar_g_freeze_frozen_maxtime);
					return 1;
				}

				// EVERY team mate nearby gets a point (even if multiple!)
				FOREACH_CLIENT(IS_PLAYER(it) && it.reviving, LAMBDA(
					PlayerScore_Add(other, SP_SCORE, +1);
					nades_GiveBonus(other,autocvar_g_nades_bonus_score_low);
				));

				Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_FREEZETAG_REVIVED, o.netname);
				Send_Notification(NOTIF_ONE, o, MSG_CENTER, CENTER_FREEZETAG_REVIVE, self.netname);
				Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_FREEZETAG_REVIVED, self.netname, o.netname);
			}

			FOREACH_CLIENT(IS_PLAYER(it) && it.reviving, LAMBDA(
				other.revive_progress = self.revive_progress;
				other.reviving = false;
			));
		}
		else if(!n && STAT(FROZEN, self) == 1) // only if no teammate is nearby will we reset
		{
			self.revive_progress = bound(0, self.revive_progress - frametime * autocvar_g_freezetag_revive_clearspeed, 1);
			self.health = max(1, self.revive_progress * start_health);
		}
		else if(!n && !STAT(FROZEN, self))
		{
			self.revive_progress = 0; // thawing nobody
		}
	}
	else if(STAT(FROZEN, self) == 1) // auto revive
	{
		float rspeed = autocvar_g_freeze_revive_speed;
		if(autocvar_g_freeze_revive_speed_random)
			rspeed *= (random() * autocvar_g_freeze_revive_speed_random);

		self.revive_progress = bound(0, self.revive_progress + frametime * rspeed, 1);
		self.health = max(1, self.revive_progress * start_health);

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
				if(self.nade)
					toss_nade(self, '0 0 100', max(self.nade.wait, time + 0.05));
				PutClientInServer();
				return 1;
			}
		}

		if(self.revive_progress >= 1)
			freeze_Unfreeze(self);
	}

	return false;
}

MUTATOR_HOOKFUNCTION(freeze, GetCvars)
{
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_freeze, "cl_freeze");
	return false;
}

MUTATOR_HOOKFUNCTION(freeze, BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":Freeze");
	return false;
}

MUTATOR_HOOKFUNCTION(freeze, BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Freeze");
	return false;
}
