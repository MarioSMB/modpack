#include "combat.qh"

bool autocvar_sv_eventlog_console;

/** print(), but only print if the server is not local */
void dedicated_print(string input)
{
	if(server_is_dedicated) print(input);
}

void GameLogEcho(string s)
{
    if(autocvar_sv_eventlog_console)
        dedicated_print(strcat(s, "\n"));
}
