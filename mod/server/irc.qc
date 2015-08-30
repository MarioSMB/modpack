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
	if(cmd_name == "ircmsg")
	{
		IRCSay(substring(cmd_string, strlen(argv(0))+1, strlen(cmd_string)));
		return true;
	}
	return false;
}
