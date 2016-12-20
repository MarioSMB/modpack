STATIC_INIT(qmod_cmds)
{
	localcmd("\nalias ircmsg \"sv_cmd ircmsg ${* ?}\"\n");
	localcmd("\nalias _ircmessage \"ircmsg ${* ?}\"\n");
}

void IRCSay(string msgstr)
{
	if(msgstr == "")
		return;

	string prefix;
	if(substring(msgstr, 0, 3) == "^4*") // actions
		prefix = "\{3}";
	else
		prefix = "\{1}";

	msgstr = strcat(prefix, strreplace("\n", " ", msgstr), "\n"); // newlines only are good for centerprint

	FOREACH_CLIENTSLOT(IS_REAL_CLIENT(it),
	{
		sprint(it, msgstr);
	});
}

void GameCommand(string command)
{
	//float argc = tokenize_console(command);

	// Guide for working with argc arguments by example:
	// argc:   1    - 2      - 3     - 4
	// argv:   0    - 1      - 2     - 3
	// cmd     vote - master - login - password

	string cmdname = strtolower(argv(0));

	if(cmdname == "ircmsg")
	{
		IRCSay(substring(command, strlen(argv(0)) + 1, strlen(command)));
		return;
	}

	if(cmdname == "find")
	{
		FOREACH_ENTITY_CLASS_ORDERED(argv(1), true, LOG_INFOF("%i (%s)\n", it, it.classname));
		return;
	}

	// nothing above caught the command, must be invalid
	LOG_INFO(((command != "") ? strcat("Unknown server command \"", command, "\"") : "No command provided"), ".\n");
}
