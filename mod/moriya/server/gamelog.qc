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
