#include "sv_prophunt.qh"

.float ph_damage_counter;
.int prev_team;

void PH_count_alive_players()
{
	total_players = 0;
	for (int i = 1; i <= NUM_TEAMS; ++i)
	{
		Team_SetNumberOfAlivePlayers(Team_GetTeamFromIndex(i), 0);
	}
	FOREACH_CLIENT(IS_PLAYER(it) && Entity_HasValidTeam(it),
	{
		++total_players;
		if (IS_DEAD(it))
		{
			continue;
		}
		entity team_ = Entity_GetTeam(it);
		int num_alive = Team_GetNumberOfAlivePlayers(team_);
		++num_alive;
		Team_SetNumberOfAlivePlayers(team_, num_alive);
	});
	FOREACH_CLIENT(IS_REAL_CLIENT(it),
	{
		STAT(REDALIVE, it) = Team_GetNumberOfAlivePlayers(Team_GetTeamFromIndex(1));
		STAT(BLUEALIVE, it) = Team_GetNumberOfAlivePlayers(Team_GetTeamFromIndex(2));
		STAT(YELLOWALIVE, it) = Team_GetNumberOfAlivePlayers(Team_GetTeamFromIndex(3));
		STAT(PINKALIVE, it) = Team_GetNumberOfAlivePlayers(Team_GetTeamFromIndex(4));
	});
}

void nades_Clear(entity player);

void PH_SwitchTeam()
{
	prophunt_propteam = (prophunt_propteam == NUM_TEAM_1) ? NUM_TEAM_2 : NUM_TEAM_1;
}

float autocvar_g_prophunt_round_enddelay = 1;
float PH_CheckWinner()
{
	int winner_team = 0;

	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		// props win!
		winner_team = prophunt_propteam;
	}

	PH_count_alive_players();
	if (!winner_team)
		winner_team = Team_GetWinnerAliveTeam();
	if (!winner_team)
	{
		// Dr. Jaska:
		// reset delay time here only for consistency
		// PH players currently have no known ways to resurrect
		round_handler_ResetEndDelayTime();
		return 0;
	}

	// delay round ending a bit
	if (autocvar_g_prophunt_round_enddelay
		&& round_handler_GetEndTime() > 0
		&& round_handler_GetEndTime() - time > 0) // don't delay past timelimit
	{
		if (round_handler_GetEndDelayTime() == -1)
		{
			round_handler_SetEndDelayTime(min(time + autocvar_g_prophunt_round_enddelay, round_handler_GetEndTime()));
			return 0;
		}
		else if (round_handler_GetEndDelayTime() >= time)
		{
			return 0;
		}
	}

	if(winner_team > 0)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, APP_TEAM_NUM(winner_team, CENTER_ROUND_TEAM_WIN));
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, APP_TEAM_NUM(winner_team, INFO_ROUND_TEAM_WIN));
		TeamScore_AddToTeam(winner_team, ST_PH_ROUNDS, +1);
	}
	else if(winner_team == -1)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_ROUND_TIED);
	}
	else if(winner_team == -2)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_ROUND_OVER);
	}

	allowed_to_spawn = false;
	game_stopped = true;
	PH_SwitchTeam();
	round_handler_Init(5, autocvar_g_prophunt_warmup, autocvar_g_prophunt_round_timelimit);

	FOREACH_CLIENT(IS_PLAYER(it), { nades_Clear(it); });

	return 1;
}

void PH_RoundStart()
{
	allowed_to_spawn = boolean(warmup_stage);

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		it.player_blocked = false;
		it.prev_team = it.team;
	});
}

bool PH_CheckTeams()
{
	static int prev_missing_teams_mask;
	allowed_to_spawn = true;
	PH_count_alive_players();
	if (Team_GetNumberOfAliveTeams() == 2)
	{
		if(prev_missing_teams_mask > 0)
			Kill_Notification(NOTIF_ALL, NULL, MSG_CENTER, CPID_MISSING_TEAMS);
		prev_missing_teams_mask = -1;
		return true;
	}
	if(total_players == 0)
	{
		if(prev_missing_teams_mask > 0)
			Kill_Notification(NOTIF_ALL, NULL, MSG_CENTER, CPID_MISSING_TEAMS);
		prev_missing_teams_mask = -1;
		return false;
	}
	int missing_teams_mask = 0;
	for (int i = 1; i <= NUM_TEAMS; ++i)
	{
		if (IsTeamAvailable(Team_IndexToTeam(i)) &&
			(Team_GetNumberOfAlivePlayers(Team_GetTeamFromIndex(i)) == 0))
		{
			missing_teams_mask |= Team_IndexToBit(i);
		}
	}
	if(prev_missing_teams_mask != missing_teams_mask)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_MISSING_TEAMS, missing_teams_mask);
		prev_missing_teams_mask = missing_teams_mask;
	}
	return false;
}

bool ph_isEliminated(entity e)
{
	if(INGAME_JOINED(e) && (IS_DEAD(e) || e.frags == FRAGS_PLAYER_OUT_OF_GAME))
		return true;
	if(INGAME_JOINING(e))
		return true;
	return false;
}

/** Returns next available player to spectate if g_prophunt_spectate_enemies == 0 */
entity PH_SpectateNext(entity player, entity start)
{
	if (SAME_TEAM(start, player)) return start;
	// continue from current player
	for (entity e = start; (e = find(e, classname, STR_PLAYER)); )
	{
		if (SAME_TEAM(player, e)) return e;
	}
	// restart from the beginning
	for (entity e = NULL; (e = find(e, classname, STR_PLAYER)); )
	{
		if (SAME_TEAM(player, e)) return e;
	}
	return start;
}

bool ph_IsProp(entity targ)
{
	if(substring(targ.model, -4, 4) == ".obj")
		return false; // damn you engine bug
	switch(targ.classname)
	{
		case "misc_gamemodel":
		case "misc_clientmodel":
		case "misc_breakablemodel":
			if(autocvar_g_prophunt_prop_transform_sandbox_only)
				return false;
		case "object":
			return true;
	}

	return false;
}

void ph_SwitchModel(entity this, entity targ)
{
	if(targ.model == "" || this.model == targ.model)
		return;
	_setmodel(this, targ.model);
	if(autocvar_g_prophunt_prop_copysize)
		setsize(this, targ.mins, targ.maxs);
	else
		setsize(this, PL_MIN_CONST, PL_MAX_CONST);
	SetResourceExplicit(this, RES_HEALTH, max(1, ceil(vlen(targ.mins - targ.maxs) * autocvar_g_prophunt_prop_healthscale)));
	this.scale = targ.scale;
	this.skin = targ.skin;
	this.frame = targ.frame;
}

bool ph_Randomize(entity this)
{
	if(autocvar_g_prophunt_prop_randomize)
	{
		int tries = 0;
		RandomSelection_Init();
		IL_EACH(g_moveables, ph_IsProp(it) && it.model != this.model,
		{
			if(autocvar_g_prophunt_prop_randomize_checksize && tries < autocvar_g_prophunt_prop_randomize_checksize_tries)
			{
				tries += 1;
				tracebox(this.origin, it.mins, it.maxs, this.origin, MOVE_NOMONSTERS, this);
				if(trace_startsolid)
					continue;
			}
			RandomSelection_AddEnt(it, 1, 1);
		});
		if(RandomSelection_chosen_ent)
		{
			ph_SwitchModel(this, RandomSelection_chosen_ent);
			return true;
		}
	}
	return false;
}

void ph_ClearModel(entity this, bool ismanual)
{
	string newmdl = FallbackPlayerModel;
	bool found = false;
	if(!ismanual && ph_Randomize(this))
		return;

	if(autocvar_g_prophunt_prop_model != "")
	{
		RandomSelection_Init();
		FOREACH_WORD(autocvar_g_prophunt_prop_model, true,
		{
			if(fexists(it))
			{
				found = true;
				RandomSelection_AddString(it, 1, 1);
			}
		});
		if(found)
		{
			newmdl = RandomSelection_chosen_string;
			precache_model(newmdl);
		}
	}
	_setmodel(this, newmdl);
	setsize(this, PL_MIN_CONST, PL_MAX_CONST);
	SetResourceExplicit(this, RES_HEALTH, max(1, autocvar_g_prophunt_prop_health));
	this.scale = ((q3compat && autocvar_sv_q3compat_changehitbox) || !autocvar_sv_mapformat_is_quake3)
		? 0.8125 // DP model scaling uses 1/16 accuracy and 13/16 is closest to 56/69
		: autocvar_sv_player_scale;
	this.skin = 0;
}

MUTATOR_HOOKFUNCTION(ph, PlayerPowerups)
{
	entity player = M_ARGV(0, entity);

	if(player.team == prophunt_propteam)
		player.effects &= ~EF_FULLBRIGHT; // ignore fullbrightplayers setting
}

MUTATOR_HOOKFUNCTION(ph, ShowChatBubble)
{
	entity player = M_ARGV(0, entity);
	return (player.team == prophunt_propteam);
}

MUTATOR_HOOKFUNCTION(ph, PlayerPreThink)
{
	if (game_stopped)
	{
		return;
	}
	entity player = M_ARGV(0, entity);
	if (!IS_PLAYER(player) || IS_DEAD(player) || STAT(FROZEN, player))
	{
		return;
	}

	if(player.team != prophunt_propteam)
		return;

	if(autocvar_g_prophunt_prop_taunt_delay > 0 && autocvar_g_prophunt_prop_taunt_start > 0 && round_handler_IsRoundStarted() && round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= (round_limit * autocvar_g_prophunt_prop_taunt_start))
	if(time > player.prophunt_lasttaunt)
	{
		bool found = false;
		if(autocvar_g_prophunt_prop_taunt_sound != "")
		{
			RandomSelection_Init();
			FOREACH_WORD(autocvar_g_prophunt_prop_taunt_sound, true,
			{
				if(fexists(strcat("sound/", it)))
				{
					found = true;
					RandomSelection_AddString(it, 1, 1);
				}
			});
			if(found)
			{
				precache_sound(RandomSelection_chosen_string);
				_sound(player, CH_TRIGGER, RandomSelection_chosen_string, VOL_BASEVOICE, ATTEN_MIN);
			}
		}
		if(!found && autocvar_g_prophunt_prop_taunt_sounddir != "")
		{
			int glob = search_begin(strcat("sound/", autocvar_g_prophunt_prop_taunt_sounddir, "/*"), true, true);
			if(glob >= 0)
			{
				RandomSelection_Init();
				for (int i = 0, n = search_getsize(glob); i < n; ++i)
				{
					string file = search_getfilename(glob, i);
					string ext = substring(file, -3, 3);
					// TODO: proper format support? not sure what that would look like!
					if(ext == "wav" || ext == "ogg")
					{
						RandomSelection_AddString(file, 1, 1);
						found = true;
					}
				}
				search_end(glob);
				if(found)
				{
					string foundfile = substring(RandomSelection_chosen_string, 6, -1);
					precache_sound(foundfile);
					_sound(player, CH_TRIGGER, foundfile, VOL_BASEVOICE, ATTEN_MIN);
				}
			}
		}
		if(!found)
			PlayerSound(player, playersound_taunt, CH_VOICE, VOL_BASEVOICE, VOICETYPE_TAUNT);
		player.prophunt_lasttaunt = time + max(1, autocvar_g_prophunt_prop_taunt_delay) + max(0, random() * autocvar_g_prophunt_prop_taunt_delay_random);
	}

	player.last_vehiclecheck = time + 5; // prevent touchies
	player.nextstep = time + 5; // no footsteps

	bool can_transform = true;
	if(autocvar_g_prophunt_prop_limit > 0 && player.prophunt_transforms >= autocvar_g_prophunt_prop_limit)
		can_transform = false;

	if(time < player.prophunt_lasttrace)
		return;
	// TODO: more advanced checking, allow becoming other objects!
	if(PHYS_INPUT_BUTTON_ATCK(player) && can_transform)
	{
		if(autocvar_g_prophunt_prop_transform)
		{
			player.prophunt_lasttrace = time + 0.25;

			entity targ = NULL;
			entity cursorent = CS(player).cursor_trace_ent;
			if(ph_IsProp(cursorent))
				targ = cursorent;
			if(!targ)
			{
				WarpZone_crosshair_trace(player);
				if(ph_IsProp(trace_ent))
					targ = trace_ent;
			}

			if(targ)
			{
				ph_SwitchModel(player, targ);
				player.prophunt_lasttrace = time + autocvar_g_prophunt_prop_transform_delay;
				player.prophunt_transforms += 1;
				if(autocvar_g_prophunt_prop_limit > 0)
					Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_PROPHUNT_TRANSFORMS_REMAINING, autocvar_g_prophunt_prop_limit - player.prophunt_transforms);
			}
		}
		else
		{
			player.prophunt_lasttrace = time + 0.25; // internal cooldown to prevent spam
			if(ph_Randomize(player))
			{
				player.prophunt_lasttrace = time + autocvar_g_prophunt_prop_transform_delay;
				player.prophunt_transforms += 1;
				if(autocvar_g_prophunt_prop_limit > 0)
					Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_PROPHUNT_TRANSFORMS_REMAINING, autocvar_g_prophunt_prop_limit - player.prophunt_transforms);
			}
		}
	}
	else if(PHYS_INPUT_BUTTON_ATCK2(player) && autocvar_g_prophunt_prop_transform_cancel)
	{
		ph_ClearModel(player, true);
		player.prophunt_lasttrace = time + autocvar_g_prophunt_prop_transform_delay;
	}
}

MUTATOR_HOOKFUNCTION(ph, SV_ParseClientCommand, CBC_ORDER_FIRST)
{
	entity player = M_ARGV(0, entity);
	string cmd_name = M_ARGV(1, string);

	if(cmd_name == "g_sandbox")
	{
		if(autocvar_g_prophunt_edit == 0)
			return true;
		if(player.team != prophunt_propteam && autocvar_g_prophunt_edit == 2)
			return true;
	}

	return false;
}

MUTATOR_HOOKFUNCTION(ph, PlayerPhysics_PostUpdateStats)
{
	entity player = M_ARGV(0, entity);
	if(player.team != prophunt_propteam)
		return;

	STAT(PL_MIN, player) = player.mins;
	STAT(PL_MAX, player) = player.maxs;
	STAT(PL_VIEW_OFS, player) = '0 0 1' * (player.maxs_z * 0.9);
	STAT(PL_CROUCH_MIN, player) = player.mins;
	STAT(PL_CROUCH_MAX, player) = player.maxs;
	STAT(PL_CROUCH_VIEW_OFS, player) = STAT(PL_VIEW_OFS, player);
}

MUTATOR_HOOKFUNCTION(ph, FixPlayermodel)
{
	entity player = M_ARGV(2, entity);
	if(player.team != prophunt_propteam)
		return;

	M_ARGV(0, string) = player.model;
	M_ARGV(1, int) = player.skin;
}

MUTATOR_HOOKFUNCTION(ph, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	INGAME_STATUS_SET(player, INGAME_STATUS_JOINED);
	if (time <= game_starttime) // reset on game restart, not on round start
		player.ph_damage_counter = 0;
	if (!warmup_stage)
		eliminatedPlayers.SendFlags |= 1;

	player.prophunt_transforms = 0;

	if(player.team == prophunt_propteam)
	{
		Send_Notification(NOTIF_ONE_ONLY, player, MSG_CENTER, CENTER_PROPHUNT_PROP);
		SetResource(player, RES_HEALTH, max(1, autocvar_g_prophunt_prop_health));
		SetResource(player, RES_ARMOR, 0);
		SetResource(player, RES_SHELLS, 0);
		SetResource(player, RES_BULLETS, 0);
		SetResource(player, RES_ROCKETS, 0);
		SetResource(player, RES_CELLS, 0);
		SetResource(player, RES_FUEL, 0);
		player.player_blocked = false;

		ph_ClearModel(player, false);
	}
	else
	{
		Send_Notification(NOTIF_ONE_ONLY, player, MSG_CENTER, CENTER_PROPHUNT_HUNTER);
		player.player_blocked = !round_handler_IsRoundStarted();
	}

	player.colormod = '1 1 1'; // override brightness
}

MUTATOR_HOOKFUNCTION(ph, ForbidSpawn)
{
	entity player = M_ARGV(0, entity);

	// spectators / observers that weren't playing can join; they are
	// immediately forced to observe in the PutClientInServer hook
	// this way they are put in a team and can play in the next round
	if (!allowed_to_spawn && INGAME(player))
		return true;
	return false;
}

MUTATOR_HOOKFUNCTION(ph, Sandbox_DragAllowed)
{
	return (autocvar_g_prophunt_edit > 0);
}

MUTATOR_HOOKFUNCTION(ph, Sandbox_SaveAllowed)
{
	return (autocvar_g_prophunt_edit > 0);
}

MUTATOR_HOOKFUNCTION(ph, PutClientInServer)
{
	entity player = M_ARGV(0, entity);

	if (!allowed_to_spawn && IS_PLAYER(player)) // this is true even when player is trying to join
	{
		TRANSMUTE(Observer, player);
		if (CS(player).jointime != time && !INGAME(player)) // not when connecting
		{
			INGAME_STATUS_SET(player, INGAME_STATUS_JOINING);
			Send_Notification(NOTIF_ONE_ONLY, player, MSG_INFO, INFO_CA_JOIN_LATE);
		}
	}

	if (!warmup_stage)
		eliminatedPlayers.SendFlags |= 1;
}

MUTATOR_HOOKFUNCTION(ph, reset_map_players)
{
	g_prophunt_spectate_enemies = autocvar_g_prophunt_spectate_enemies;
	observe_blocked_if_eliminated = (g_prophunt_spectate_enemies == -1);
	// we can avoid sending observe_blocked_if_eliminated to all clients here (with ClientData_Touch)
	// since it will get sent whenever the client spectates someone anyway

	FOREACH_CLIENT(true, {
		CS(it).killcount = 0;
		if (INGAME(it) || IS_BOT_CLIENT(it))
		{
			TRANSMUTE(Player, it);
			INGAME_STATUS_SET(it, INGAME_STATUS_JOINED);
			PutClientInServer(it);
			it.player_blocked = (it.team != prophunt_propteam);
		}
		it.prev_team = 0;
	});
	return true;
}

MUTATOR_HOOKFUNCTION(ph, reset_map_global)
{
	allowed_to_spawn = true;
	return true;
}

MUTATOR_HOOKFUNCTION(ph, MatchEnd_BeforeScores)
{
	MatchEnd_RestoreSpectatorAndTeamStatus(prev_team);
	return true;
}

MUTATOR_HOOKFUNCTION(ph, TeamBalance_CheckAllowedTeams, CBC_ORDER_EXCLUSIVE)
{
	M_ARGV(0, float) = BITS(2);
	return true;
}

entity ph_LastPlayerForTeam(entity this)
{
	entity last_pl = NULL;
	FOREACH_CLIENT(IS_PLAYER(it) && it != this, {
		if (!IS_DEAD(it) && SAME_TEAM(this, it))
		{
			if (!last_pl)
				last_pl = it;
			else
				return NULL;
		}
	});
	return last_pl;
}

void ph_LastPlayerForTeam_Notify(entity this)
{
	if (!warmup_stage && round_handler_IsActive() && round_handler_IsRoundStarted())
	{
		entity pl = ph_LastPlayerForTeam(this);
		if (pl)
			Send_Notification(NOTIF_ONE, pl, MSG_CENTER, CENTER_ALONE);
	}
}

MUTATOR_HOOKFUNCTION(ph, PlayerDies)
{
	entity frag_target = M_ARGV(2, entity);

	ph_LastPlayerForTeam_Notify(frag_target);
	if (!allowed_to_spawn)
	{
		frag_target.respawn_flags = RESPAWN_SILENT;
		// prevent unwanted sudden rejoin as spectator and movement of spectator camera
		frag_target.respawn_time = time + 2;
	}
	frag_target.respawn_flags |= RESPAWN_FORCE;
	if (!warmup_stage)
		eliminatedPlayers.SendFlags |= 1;
	return true;
}


MUTATOR_HOOKFUNCTION(ph, ClientDisconnect)
{
	entity player = M_ARGV(0, entity);

	if (IS_PLAYER(player) && !IS_DEAD(player))
		ph_LastPlayerForTeam_Notify(player);
	return true;
}

MUTATOR_HOOKFUNCTION(ph, MakePlayerObserver)
{
	entity player = M_ARGV(0, entity);

	player.player_blocked = false;

	bool is_forced = M_ARGV(1, bool);
	if (is_forced && INGAME(player))
		INGAME_STATUS_CLEAR(player);

	if (IS_PLAYER(player) && !IS_DEAD(player))
		ph_LastPlayerForTeam_Notify(player);
	if (player.killindicator_teamchange == -2) // player wants to spectate
	{
		entcs_update_players(player);
		INGAME_STATUS_CLEAR(player);
	}
	if (INGAME(player))
	{
		player.frags = FRAGS_PLAYER_OUT_OF_GAME;
		player.would_spectate = observe_blocked_if_eliminated; // if blocked from observing force to spectate now
	}
	if (!warmup_stage)
		eliminatedPlayers.SendFlags |= 1;
	if (!INGAME(player))
		return false;  // allow team reset
	return true;  // prevent team reset
}

MUTATOR_HOOKFUNCTION(ph, ForbidThrowCurrentWeapon)
{
	return true;
}

MUTATOR_HOOKFUNCTION(ph, ForbidWeaponUse)
{
	entity player = M_ARGV(0, entity);
	return (player.team == prophunt_propteam);
}

MUTATOR_HOOKFUNCTION(ph, GiveFragsForKill, CBC_ORDER_FIRST)
{
	M_ARGV(2, float) = 0; // score will be given to the winner team when the round ends
	return true;
}

MUTATOR_HOOKFUNCTION(ph, SetStartItems)
{
	start_items       &= ~(IT_UNLIMITED_AMMO | IT_UNLIMITED_SUPERWEAPONS);
	if(!cvar("g_use_ammunition"))
		start_items |= IT_UNLIMITED_AMMO;

	start_health       = warmup_start_health       = autocvar_g_prophunt_start_health;
	start_armorvalue   = warmup_start_armorvalue   = autocvar_g_prophunt_start_armor;
	start_ammo_shells  = warmup_start_ammo_shells  = autocvar_g_prophunt_start_ammo_shells;
	start_ammo_nails   = warmup_start_ammo_nails   = autocvar_g_prophunt_start_ammo_nails;
	start_ammo_rockets = warmup_start_ammo_rockets = autocvar_g_prophunt_start_ammo_rockets;
	start_ammo_cells   = warmup_start_ammo_cells   = autocvar_g_prophunt_start_ammo_cells;
	start_ammo_fuel    = warmup_start_ammo_fuel    = autocvar_g_prophunt_start_ammo_fuel;
}

MUTATOR_HOOKFUNCTION(ph, Damage_Calculate)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	float frag_deathtype = M_ARGV(3, float);
	float frag_damage = M_ARGV(4, float);
	float frag_mirrordamage = M_ARGV(5, float);

	if (IS_PLAYER(frag_target))
	if (!IS_DEAD(frag_target))
	if (frag_target == frag_attacker || SAME_TEAM(frag_target, frag_attacker) || frag_deathtype == DEATH_FALL.m_id || (frag_deathtype == DEATH_DROWN.m_id && frag_target.team == prophunt_propteam))
		frag_damage = 0;

	if (frag_damage > 0 && frag_target.team != prophunt_propteam && frag_attacker.team != prophunt_propteam && ph_IsProp(frag_target))
		frag_mirrordamage = frag_damage * autocvar_g_prophunt_mirrordamage;
	else
		frag_mirrordamage = 0;

	M_ARGV(4, float) = frag_damage;
	M_ARGV(5, float) = frag_mirrordamage;
}

MUTATOR_HOOKFUNCTION(ph, OnEntityPreSpawn)
{
	entity ent = M_ARGV(0, entity);

	if(ph_IsProp(ent))
	{
		ent.takedamage = DAMAGE_AIM; // so they can be targeted
		// force full quality so as to not out players disguised
		ent.lodtarget1 = "";
		ent.lodtarget2 = "";
		ent.lodmodel1 = "";
		ent.lodmodel2 = "";
	}
}

MUTATOR_HOOKFUNCTION(ph, FilterItem)
{
	return true;
}

MUTATOR_HOOKFUNCTION(ph, PlayerDamage_SplitHealthArmor)
{
	if (time < game_starttime || (round_handler_IsActive() && !round_handler_IsRoundStarted()))
		return;

	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	float frag_deathtype = M_ARGV(6, float);
	float frag_damage = M_ARGV(7, float);
	float damage_take = bound(0, M_ARGV(4, float), GetResource(frag_target, RES_HEALTH));
	float damage_save = bound(0, M_ARGV(5, float), GetResource(frag_target, RES_ARMOR));

	float excess = max(0, frag_damage - damage_take - damage_save);

	if(IS_PLAYER(frag_target) && frag_target.team == prophunt_propteam)
		frag_target.pain_finished = time + 0.5; // no sounds

	if (autocvar_g_prophunt_damage2score <= 0 || frag_damage - excess == 0) return;

	entity scorer = NULL;
	float scorer_damage = 0;

	if (IS_PLAYER(frag_attacker))
	{
		if (DIFF_TEAM(frag_target, frag_attacker))
			scorer_damage = frag_damage - excess;
		else // friendly fire
			scorer_damage = -(frag_damage - excess);

		scorer = frag_attacker;
	}
	else
	{
		//handle (environmental hazard) suiciding, check first if player has a registered attacker who most likely pushed them there to avoid punishing pushed players as pushers are already rewarded
		//deathtypes:
		//kill = suicide, drown = drown in water/liquid, hurttrigger = out of the map void or hurt triggers inside maps like electric sparks
		//camp = campcheck, lava = lava, slime = slime
		//team change / rebalance suicides are currently not included
		if (frag_deathtype == DEATH_KILL.m_id ||
			frag_deathtype == DEATH_DROWN.m_id ||
			frag_deathtype == DEATH_HURTTRIGGER.m_id ||
			frag_deathtype == DEATH_CAMP.m_id ||
			frag_deathtype == DEATH_LAVA.m_id ||
			frag_deathtype == DEATH_SLIME.m_id ||
			frag_deathtype == DEATH_SWAMP.m_id)
		{
			scorer_damage = -(frag_damage - excess);
			scorer = frag_target;
		}
	}

	if (scorer)
		GameRules_scoring_add_float2int(scorer, SCORE, scorer_damage, ph_damage_counter, autocvar_g_prophunt_damage2score);
}

MUTATOR_HOOKFUNCTION(ph, CalculateRespawnTime)
{
	// no respawn calculations needed, player is forced to spectate anyway
	return true;
}

MUTATOR_HOOKFUNCTION(ph, PlayerRegen)
{
	// no regeneration in PH
	return true;
}

MUTATOR_HOOKFUNCTION(ph, PlayerWeaponSelect)
{
	entity player = M_ARGV(0, entity);

	if(player.team != prophunt_propteam)
		return;

	STAT(WEAPONS, player) = '0 0 0';

	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		entity thiswep = player.(weaponentity);

		thiswep.m_switchweapon = WEP_Null;
	}
}

MUTATOR_HOOKFUNCTION(ph, VehicleInit)
{
	return true;
}

MUTATOR_HOOKFUNCTION(ph, ForbidRandomStartWeapons)
{
	return true;
}

MUTATOR_HOOKFUNCTION(ph, SpectateSet)
{
	entity client = M_ARGV(0, entity);
	entity targ = M_ARGV(1, entity);

	if (g_prophunt_spectate_enemies != 1 && INGAME(client))
	if (DIFF_TEAM(targ, client))
		return true;
}

MUTATOR_HOOKFUNCTION(ph, SpectateNext)
{
	entity client = M_ARGV(0, entity);

	if (g_prophunt_spectate_enemies != 1 && INGAME(client)
		&& Team_GetNumberOfAlivePlayers(Entity_GetTeam(client)))
	{
		entity targ = M_ARGV(1, entity);
		M_ARGV(1, entity) = PH_SpectateNext(client, targ);
		return true;
	}
}

MUTATOR_HOOKFUNCTION(ph, SpectatePrev)
{
	entity client = M_ARGV(0, entity);
	entity targ = M_ARGV(1, entity);
	entity first = M_ARGV(2, entity);

	if (g_prophunt_spectate_enemies != 1 && INGAME(client)
		&& Team_GetNumberOfAlivePlayers(Entity_GetTeam(client)))
	{
		do { targ = targ.chain; }
		while(targ && DIFF_TEAM(targ, client));

		if (!targ)
		{
			for (targ = first; targ && DIFF_TEAM(targ, client); targ = targ.chain);

			if (targ == client.enemy)
				return MUT_SPECPREV_RETURN;
		}
	}
	else
		return MUT_SPECPREV_CONTINUE;

	M_ARGV(1, entity) = targ;

	return MUT_SPECPREV_FOUND;
}

MUTATOR_HOOKFUNCTION(ph, Bot_FixCount, CBC_ORDER_EXCLUSIVE)
{
	FOREACH_CLIENT(IS_REAL_CLIENT(it), {
		if (IS_PLAYER(it) || INGAME_JOINED(it))
			++M_ARGV(0, int);
		++M_ARGV(1, int);
	});
	return true;
}

MUTATOR_HOOKFUNCTION(ph, ClientCommand_Spectate)
{
	entity player = M_ARGV(0, entity);

	if (INGAME(player))
	{
		// they're going to spec, we can do other checks
		if (autocvar_sv_spectate && (IS_SPEC(player) || IS_OBSERVER(player)))
			Send_Notification(NOTIF_ONE_ONLY, player, MSG_INFO, INFO_CA_LEAVE);
		return MUT_SPECCMD_FORCE;
	}

	return MUT_SPECCMD_CONTINUE;
}

MUTATOR_HOOKFUNCTION(ph, SetWeaponArena)
{
	if (M_ARGV(0, string) == "0" || M_ARGV(0, string) == "")
		M_ARGV(0, string) = autocvar_g_prophunt_weaponarena;
}

MUTATOR_HOOKFUNCTION(ph, SV_ParseServerCommand)
{
	string cmd_name = M_ARGV(0, string);
	if (cmd_name == "shuffleteams")
		shuffleteams_on_reset_map = !allowed_to_spawn;
	return false;
}
