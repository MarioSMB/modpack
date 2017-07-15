REGISTER_MUTATOR(require_stats, cvar("g_require_stats"));

AUTOCVAR(g_require_stats, int, 0, "Require stats to be enabled to join the server");
AUTOCVAR(g_require_stats_use_whitelist, bool, false, "");
AUTOCVAR(g_require_stats_verify, bool, false, "Verify that client stats ID is signed, for additional security");
AUTOCVAR(g_require_stats_checkempty, bool, true, "Prevent clients from joining if they have no stats ID at all");
AUTOCVAR(g_require_stats_whitelist, string, "", "");
AUTOCVAR(g_require_stats_blacklist, string, "", "");
AUTOCVAR(g_require_stats_checkelo, bool, false, "Allow checking the player's elo score");
AUTOCVAR(g_require_stats_elo_limit_global, int, 0, "Global elo limit (note: gametype specific limits override this)");

.float last_elocheck;
.bool elo_overlimit;
.bool elo_bypass;

bool stats_CheckPlayer(entity this)
{
	return boolean(
		(autocvar_g_require_stats_checkempty && (this.crypto_idfp == "" || !this.crypto_idfp))
	||  (autocvar_g_require_stats_use_whitelist && !PlayerInIDList(this, autocvar_g_require_stats_whitelist))
	||  PlayerInIDList(this, autocvar_g_require_stats_blacklist)
	||  (autocvar_g_require_stats_verify && !this.crypto_idfp_signed)
		);
}

STATIC_INIT_LATE(elo_setvars)
{
	localcmd("\nalias elobypass \"sv_cmd elobypass ${* ?}\"\n");
}

MUTATOR_HOOKFUNCTION(require_stats, SV_ParseServerCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	string cmd_name = M_ARGV(0, string);
	int cmd_argc = M_ARGV(1, int);

	if(cmd_name == "elobypass")
	{
		if(argv(1) == "")
		{
			FOREACH_CLIENT(IS_REAL_CLIENT(it),
			{
				it.elo_bypass = true;
			});
			LOG_INFO("Allowing all players to bypass elo checks for this match.\n");
			return true;
		}
		else if(argv(1) == "off")
		{
			FOREACH_CLIENT(IS_REAL_CLIENT(it),
			{
				it.elo_bypass = false;
			});
			LOG_INFO("Turning off elo bypassing for all players.\n");
			return true;
		}

		entity client = GetIndexedEntity(cmd_argc, 1);
		bool accepted = VerifyClientEntity(client, true, false);

		if (accepted > 0)
		{
			client.elo_bypass = true;
			LOG_INFO(strcat("Player ", GetCallerName(client), " is now allowed to join for this match, regardless of their elo.\n"));
		}
		else
		{
			LOG_INFO("elo bypass failed: ", GetClientErrorString(accepted, argv(1)), ".\n");
		}
		return true;
	}
}

MUTATOR_HOOKFUNCTION(require_stats, PlayerPreThink)
{
	if(autocvar_g_require_stats < 1)
		return; // allow toggling mid match (also disables elo checker)

	if(!autocvar_g_require_stats_checkelo || autocvar_g_playerstats_playerbasic_uri == "")
		return;

	entity player = M_ARGV(0, entity);
	if(player.elo_overlimit || player.elo_bypass)
		return; // once we know they have too much elo, we don't need to check at all
	if(time < player.last_elocheck)
		return;
	player.last_elocheck = time + 1; // we don't need to check too often

	float my_elo = PlayerScore_Add(player, SP_ELO, 0);
	if(my_elo <= 0) // no elo or not loaded
		return; // try to return before checking the gametype (slow)

	int tmp_playercount = 0;
	FOREACH_CLIENT(IS_PLAYER(it) && IS_REAL_CLIENT(it),
	{
		++tmp_playercount;
	});
	if(tmp_playercount <= 2)
		return; // don't enforce elo limits when there's not enough players

	int elo_limit = 0;
	if(autocvar_g_require_stats_elo_limit_global > 0)
		elo_limit = autocvar_g_require_stats_elo_limit_global;

	string current_type = PlayerStats_GetGametype();
	string thevar = strcat("g_require_stats_elo_limit_", current_type);
	if(cvar_type(thevar) & CVAR_TYPEFLAG_EXISTS)
		elo_limit = cvar(thevar); // override default limit

	if(elo_limit <= 0)
		return;

	if(my_elo > elo_limit)
	{
		if(!autocvar_sv_spectate)
		{
			bprintf("Player %s has too much elo! Spectating isn't allowed, so they will be kicked.\n", playername(player, false));
			dropclient(player);
			return;
		}
		player.elo_overlimit = true;

		bprintf("Player %s has too much elo! They will be forced to spectate.\n", playername(player, false));
		if(IS_PLAYER(player))
			ClientKill_TeamChange(player, -2);
	}
}

MUTATOR_HOOKFUNCTION(require_stats, ClientConnect)
{
	entity player = M_ARGV(0, entity);

	if(!IS_REAL_CLIENT(player))
		return; // don't check bots

	if(autocvar_g_require_stats >= 2)
	if(stats_CheckPlayer(player))
	{
		sprint(player, "This server requires stats to be enabled. You have been kicked.\n");
		dropclient(player);
		return;
	}

	if(autocvar_g_require_stats >= 1)
	if(stats_CheckPlayer(player))
	{
		player.muted = true;
		player.version_mismatch = true;
	}
}

MUTATOR_HOOKFUNCTION(require_stats, PutClientInServer)
{
	if(autocvar_g_require_stats < 1)
		return; // allow toggling mid match (also disables elo checker)

	entity player = M_ARGV(0, entity);

	if(!IS_REAL_CLIENT(player))
		return; // don't check bots

	if(IS_PLAYER(player) && stats_CheckPlayer(player))
	{
		TRANSMUTE(Observer, player);
		centerprint(player, "No can do, sugar tits... Joining is disabled if you don't have stats enabled");
		return;
	}

	if(!player.elo_bypass && player.elo_overlimit && IS_PLAYER(player))
	{
		int tmp_playercount = 0;
		FOREACH_CLIENT(IS_PLAYER(it) && IS_REAL_CLIENT(it),
		{
			++tmp_playercount;
		});
		if(tmp_playercount <= 2)
			return; // don't enforce elo limits when there's not enough players
		TRANSMUTE(Observer, player);
		centerprint(player, "Sorry, you are too good to play here");
		return;
	}
}
