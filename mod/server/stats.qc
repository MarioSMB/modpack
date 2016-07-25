REGISTER_MUTATOR(require_stats, cvar("g_require_stats"));

AUTOCVAR(g_require_stats, int, 0, "Require stats to be enabled to join the server");
AUTOCVAR(g_require_stats_use_whitelist, bool, false, "");
AUTOCVAR(g_require_stats_whitelist, string, "", "");
AUTOCVAR(g_require_stats_blacklist, string, "", "");

bool stats_CheckPlayer(entity this)
{
	return IS_REAL_CLIENT(this) &&
			boolean((this.crypto_idfp == "" || !this.crypto_idfp) || (autocvar_g_require_stats_use_whitelist && !strhasword(autocvar_g_require_stats_whitelist, this.crypto_idfp)) || strhasword(autocvar_g_require_stats_blacklist, this.crypto_idfp));
}

MUTATOR_HOOKFUNCTION(require_stats, ClientConnect)
{
	entity player = M_ARGV(0, entity);

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
	if(autocvar_g_require_stats >= 1) // >=, incase cvar is updated when theyre on?
	{
		entity player = M_ARGV(0, entity);

		if(IS_PLAYER(player) && stats_CheckPlayer(player))
		{
			TRANSMUTE(Observer, player);
			centerprint(player, "No can do, sugar tits... Joining is disabled if you don't have stats enabled");
		}
	}
}
