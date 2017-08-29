REGISTER_MUTATOR(freeze, cvar("g_freeze") && !IS_GAMETYPE(FREEZETAG) && !IS_GAMETYPE(CA) && !IS_GAMETYPE(CTS) && !IS_GAMETYPE(RACE) && teamplay);

AUTOCVAR_NOREF(g_freeze, bool, false, _("Enable freeze mutator (similar to freezetag, but for other modes)"));
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

REPLICATE(cvar_cl_freeze, bool, "cl_freeze");

void freeze_Unfreeze(entity ent)
{
	ent.freeze_flag = FROZEN_THAWING; // thawing is fine, as this is only checked when the player is frozen

	ent.freezetag_frozen_time = 0;
	ent.freezetag_frozen_timeout = 0;

	Kill_Notification(NOTIF_ONE_ONLY, ent, MSG_CENTER, CPID_FREEZE);

	Unfreeze(ent);
}


MUTATOR_HOOKFUNCTION(freeze, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	freeze_Unfreeze(player);
}

MUTATOR_HOOKFUNCTION(freeze, PlayerDies)
{
	entity frag_target = M_ARGV(2, entity);
	float frag_deathtype = M_ARGV(3, float);

	if(frag_deathtype == DEATH_HURTTRIGGER.m_id)
		return;

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
			return true;
		}

		Freeze(frag_target, 0, 1, (teamplay && autocvar_g_freeze_noauto));
		if(autocvar_g_freeze_frozen_maxtime > 0)
			frag_target.freezetag_frozen_timeout = time + autocvar_g_freeze_frozen_maxtime;
		frag_target.freezetag_frozen_time = time;
	}
}

MUTATOR_HOOKFUNCTION(freeze, PlayerPreThink)
{
	entity player = M_ARGV(0, entity);

	if(IS_DEAD(player) || !IS_PLAYER(player) || game_stopped)
		return;

	if(round_handler_IsActive())
	if(!round_handler_IsRoundStarted())
		return;

	bool button_pressed = false;
	int n;

	if(teamplay && autocvar_g_freeze_noauto)
	{
		// copied from freezetag
		if(STAT(FROZEN, player) == 1)
		{
			// keep health = 1
			player.pauseregen_finished = time + autocvar_g_balance_pause_health_regen;
		}

		if(STAT(FROZEN, player) == 1)
		{
			button_pressed = (!autocvar_g_freeze_norespawn && (PHYS_INPUT_BUTTON_JUMP(player) || PHYS_INPUT_BUTTON_USE(player))); // only detect jumps
			if(IS_GAMETYPE(LMS) || IS_GAMETYPE(CA)) { player.freeze_flag = FROZEN_RESPAWNING; } // these modes require player to die
			if(player.freeze_flag == FROZEN_THAWING)
			{
				if(!button_pressed)
					player.freeze_flag = FROZEN_WILLRESPAWN;
			}
			else if(player.freeze_flag == FROZEN_WILLRESPAWN)
			{
				if(button_pressed)
					player.freeze_flag = FROZEN_RESPAWNING;
			}
			else if(player.freeze_flag == FROZEN_RESPAWNING)
			{
				if(time > player.respawn_time)
				{
					player.respawn_time = time + 1; // only retry once a second
					if(player.nade)
						toss_nade(player, true, '0 0 100', max(player.nade.wait, time + 0.05));
					PutClientInServer(player);
				}

				return true; // if we get here, normal revivals have been cancelled
			}
		}

		if(STAT(FROZEN, player) == 1)
		{
			int frozen_count = 0, nplayers = 0;
			FOREACH_CLIENT(IS_PLAYER(it) && SAME_TEAM(it, player), LAMBDA(
				++nplayers;
				if(STAT(FROZEN, it) == 1)
					++frozen_count;
			));
			if(nplayers == frozen_count)
			{
				FOREACH_CLIENT(IS_PLAYER(it) && SAME_TEAM(it, player), LAMBDA(
					it.freeze_flag = FROZEN_RESPAWNING;
					it.respawn_time = time + autocvar_g_freeze_respawn_time;
					GameRules_scoring_add(it, SCORE, -1); // lose score for this
				));

				return true;
			}
		}

		entity o;
		o = NULL;
		//if(player.freezetag_frozen_timeout > 0 && time < player.freezetag_frozen_timeout)
		//if(player.iceblock)
			//player.iceblock.alpha = ICE_MIN_ALPHA + (ICE_MAX_ALPHA - ICE_MIN_ALPHA) * (player.freezetag_frozen_timeout - time) / (player.freezetag_frozen_timeout - player.freezetag_frozen_time);

		if(player.freezetag_frozen_timeout > 0 && time >= player.freezetag_frozen_timeout)
			n = -1;
		else
		{
			vector revive_extra_size = '1 1 1' * autocvar_g_freezetag_revive_extra_size;
			n = 0;
			FOREACH_CLIENT(IS_PLAYER(it) && it != player && !IS_DEAD(it) && !STAT(FROZEN, it) && SAME_TEAM(it, player), LAMBDA(
				if(boxesoverlap(player.absmin - revive_extra_size, player.absmax + revive_extra_size, it.absmin, it.absmax))
				{
					if(!o)
						o = it;
					if(STAT(FROZEN, player) == 1)
						it.reviving = true;
					++n;
				}
			));
		}

		if(n && STAT(FROZEN, player) == 1) // OK, there is at least one teammate reviving us
		{
			player.revive_progress = bound(0, player.revive_progress + frametime * max(1/60, autocvar_g_freezetag_revive_speed), 1);
			player.health = max(1, player.revive_progress * start_health);

			if(player.revive_progress >= 1)
			{
				freeze_Unfreeze(player);

				if(n == -1)
				{
					Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_FREEZETAG_AUTO_REVIVED, autocvar_g_freeze_frozen_maxtime);
					Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_FREEZETAG_AUTO_REVIVED, player.netname, autocvar_g_freeze_frozen_maxtime);
					return true;
				}

				// EVERY team mate nearby gets a point (even if multiple!)
				FOREACH_CLIENT(IS_PLAYER(it) && it.reviving, LAMBDA(
					GameRules_scoring_add(it, SCORE, +1);
					nades_GiveBonus(it,autocvar_g_nades_bonus_score_low);
				));

				Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_FREEZETAG_REVIVED, o.netname);
				Send_Notification(NOTIF_ONE, o, MSG_CENTER, CENTER_FREEZETAG_REVIVE, player.netname);
				Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_FREEZETAG_REVIVED, player.netname, o.netname);
			}

			FOREACH_CLIENT(IS_PLAYER(it) && it.reviving, LAMBDA(
				it.revive_progress = player.revive_progress;
				it.reviving = false;
			));
		}
		else if(!n && STAT(FROZEN, player) == 1) // only if no teammate is nearby will we reset
		{
			player.revive_progress = bound(0, player.revive_progress - frametime * autocvar_g_freezetag_revive_clearspeed, 1);
			player.health = max(1, player.revive_progress * start_health);
		}
		else if(!n && !STAT(FROZEN, player))
		{
			player.revive_progress = 0; // thawing nobody
		}
	}
	else if(STAT(FROZEN, player) == 1) // auto revive
	{
		float rspeed = autocvar_g_freeze_revive_speed;
		if(autocvar_g_freeze_revive_speed_random)
			rspeed *= (random() * autocvar_g_freeze_revive_speed_random);

		player.revive_progress = bound(0, player.revive_progress + frametime * rspeed, 1);
		player.health = max(1, player.revive_progress * start_health);

		if(player.health >= autocvar_g_freeze_revive_minhealth)
			button_pressed = (PHYS_INPUT_BUTTON_JUMP(player) || PHYS_INPUT_BUTTON_USE(player)); // we're about to defrost, only detect jumps
		else
			button_pressed = (PHYS_INPUT_BUTTON_ATCK(player) || PHYS_INPUT_BUTTON_JUMP(player) || PHYS_INPUT_BUTTON_ATCK2(player) || PHYS_INPUT_BUTTON_HOOK(player) || PHYS_INPUT_BUTTON_USE(player));

		if(autocvar_g_freeze_norespawn)
			button_pressed = 0; // don't allow re-spawning via jump/attack

		if(player.freeze_flag == FROZEN_THAWING)
		{
			if(!button_pressed)
				player.freeze_flag = FROZEN_WILLRESPAWN;
		}
		else if(player.freeze_flag == FROZEN_WILLRESPAWN)
		{
			if(button_pressed)
				player.freeze_flag = FROZEN_RESPAWNING;
		}
		else if(player.freeze_flag == FROZEN_RESPAWNING)
		{
			if(time > player.respawn_time)
			{
				player.respawn_time = time + 1; // only retry once a second
				if(player.nade)
					toss_nade(player, true, '0 0 100', max(player.nade.wait, time + 0.05));
				PutClientInServer(player);
				return true;
			}
		}

		if(player.revive_progress >= 1)
			freeze_Unfreeze(player);
	}
}

MUTATOR_HOOKFUNCTION(freeze, BuildMutatorsString)
{
	M_ARGV(0, string) = strcat(M_ARGV(0, string), ":Freeze");
}

MUTATOR_HOOKFUNCTION(freeze, BuildMutatorsPrettyString)
{
	M_ARGV(0, string) = strcat(M_ARGV(0, string), ", Freeze");
}
