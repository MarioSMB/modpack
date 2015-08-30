STATIC_INIT(mod_cmds)
{
	localcmd("alias ircmsg \"sv_cmd ircmsg ${* ?}\"");
	localcmd("alias _ircmessage \"ircmsg ${* ?}\"");

	localcmd("alias chlevel \"sv_cmd chlevel ${* ?}\"");
}

void IRCSay(string msgstr)
{
	if(msgstr == "")
		return;

	msgstr = strcat("\{1}", strreplace("\n", " ", msgstr), "\n"); // newlines only are good for centerprint

	entity head;
	FOR_EACH_CLIENTSLOT(head)
	{
		if(!intermission_running)
		if((autocvar_g_chat_nospectators == 1) || (autocvar_g_chat_nospectators == 2 && !(warmup_stage || gameover)))
		if(IS_PLAYER(head))
			continue;
		if(IS_REAL_CLIENT(head))
			sprint(head, msgstr);
	}
}

MUTATOR_HOOKFUNCTION(mutator_mod, SV_ParseServerCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	if(cmd_name == "chlevel")
	{
		string m = MapInfo_FixName(argv(1));
		localcmd(strcat("\nchangelevel ", m, "\n"));
		print("Switching to ", m, "\n");
		return true;
	}

	if(cmd_name == "ircmsg")
	{
		IRCSay(substring(cmd_string, strlen(argv(0))+1, strlen(cmd_string)));
		return true;
	}
	return false;
}
