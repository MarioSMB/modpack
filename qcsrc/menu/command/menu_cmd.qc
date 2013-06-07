string _dumptree_space;
void _dumptree_open(entity pass, entity me)
{
	string s;
	s = me.toString(me);
	if(s == "")
		s = me.classname;
	else
		s = strcat(me.classname, ": ", s);
	print(_dumptree_space, etos(me), " (", s, ")");
	if(me.firstChild)
	{
		print(" {\n");
		_dumptree_space = strcat(_dumptree_space, "  ");
	}
	else
		print("\n");
}
void _dumptree_close(entity pass, entity me)
{
	if(me.firstChild)
	{
		_dumptree_space = substring(_dumptree_space, 0, strlen(_dumptree_space) - 2);
		print(_dumptree_space, "}\n");
	}
}

void GameCommand(string theCommand)
{
	float argc;
	argc = tokenize_console(theCommand);

	if(argv(0) == "help" || argc == 0)
	{
		print(_("Usage: menu_cmd command..., where possible commands are:\n"));
		print(_("  sync - reloads all cvars on the current menu page\n"));
		print(_("  directmenu ITEM - select a menu item as main item\n"));

		print("\nGeneric commands shared by all programs:\n");
		GenericCommand_macro_help();

		return;
	}

	if(GenericCommand(theCommand))
		return;

	if(argv(0) == "sync")
	{
		m_sync();
		return;
	}

	if(argv(0) == "directmenu" || argv(0) == "directpanelhudmenu")
	{
		string filter = string_null;
		if(argv(0) == "directpanelhudmenu")
			filter = strzone("HUD");

		if(argc == 1)
		{
			print(_("Available options:\n"));
			float i;
			entity e;
			string s;

			for(i = 0, e = world; (e = nextent(e)); )
				if(e.classname != "vtbl" && e.name != "")
				{
					s = e.name;
					if(filter)
					{
						if(substring(s, 0, strlen(filter)) != filter)
							continue;
						s = substring(s, strlen(filter), strlen(s) - strlen(filter));
					}
					print(strcat(" ", s ,"\n"));
					++i;
				}
		}
		else if(argc == 2 && !isdemo()) // don't allow this command in demos
			m_goto(strcat(filter, argv(1))); // switch to a menu item
		if(filter)
			strunzone(filter);
		return;
	}

	if(argv(0) == "skinselect")
	{
		m_goto("skinselector");
		return;
	}

	if(argv(0) == "languageselect")
	{
		m_goto("languageselector");
		return;
	}

	if(argv(0) == "videosettings")
	{
		m_goto("videosettings");
		return;
	}

	if(argv(0) == "dumptree")
	{
		_dumptree_space = "";
		depthfirst(main, parent, firstChild, nextSibling, _dumptree_open, _dumptree_close, NULL);
		return;
	}

	print(_("Invalid command. For a list of supported commands, try menu_cmd help.\n"));
}
