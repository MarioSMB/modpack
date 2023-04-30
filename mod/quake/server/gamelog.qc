#include "gamelog.qh"

#include "world.qh"

string GameLog_ProcessIP(string s)
{
	if(!autocvar_sv_eventlog_ipv6_delimiter)
		return s;
	return strreplace(":", "_", s);
}

void GameLogEcho(string s)
{
	if (autocvar_sv_eventlog_files)
	{
		if (!logfile_open)
		{
			logfile_open = true;
			int matches = autocvar_sv_eventlog_files_counter + 1;
			cvar_set("sv_eventlog_files_counter", itos(matches));
			string fn = ftos(matches);
			if (strlen(fn) < 8)
				fn = strcat(substring("00000000", 0, 8 - strlen(fn)), fn);
			fn = strcat(autocvar_sv_eventlog_files_nameprefix, fn, autocvar_sv_eventlog_files_namesuffix);
			logfile = fopen(fn, FILE_APPEND);
			fputs(logfile, ":logversion:3\n");
		}
		if (logfile >= 0)
		{
			if (autocvar_sv_eventlog_files_timestamps)
				fputs(logfile, strcat(":time:", strftime(true, "%Y-%m-%d %H:%M:%S", "\n", s, "\n")));
			else
				fputs(logfile, strcat(s, "\n"));
		}
	}
	if (autocvar_sv_eventlog_console)
	{
		dedicated_print(strcat(s, "\n"));
	}
}

#if 0
void GameLogInit()
{
	GameLogEcho(strcat(":gamestart:", GetGametype(), "_", GetMapname(), ":", matchid));
	string s = ":gameinfo:mutators:LIST";

	MUTATOR_CALLHOOK(BuildMutatorsString, s);
	s = M_ARGV(0, string);

	// initialiation stuff, not good in the mutator system
	if(!autocvar_g_use_ammunition)
		s = strcat(s, ":no_use_ammunition");

	// initialiation stuff, not good in the mutator system
	if(autocvar_g_pickup_items == 0)
		s = strcat(s, ":no_pickup_items");
	if(autocvar_g_pickup_items > 0)
		s = strcat(s, ":pickup_items");

	// initialiation stuff, not good in the mutator system
	if(autocvar_g_weaponarena != "0")
		s = strcat(s, ":", autocvar_g_weaponarena, " arena");

	// TODO to mutator system
	if(autocvar_g_norecoil)
		s = strcat(s, ":norecoil");

	GameLogEcho(s);
	GameLogEcho(":gameinfo:end");
}

#endif
void GameLogClose()
{
	if (logfile_open && logfile >= 0)
	{
		fclose(logfile);
		logfile = -1;
	}
}
