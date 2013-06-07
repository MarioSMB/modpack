// campaign cvars:
//   _campaign_index: index of CURRENT map
//   _campaign_name: name of the current campaign
//   g_campaign(name)_index: index of current LAST map (saved)
//   g_campaign_skill: bot skill offset

float campaign_level;
float campaign_won;
string campaign_index_var;
float checkrules_equality;

float CampaignBailout(string s)
{
	cvar = cvar_normal;
	cvar_string = cvar_string_normal;
	cvar_set = cvar_set_normal;
	cvar_set("g_campaign", "0");
	print("^4campaign initialization failed: ", s, "\n");
	if(autocvar__campaign_testrun)
		error("CAMPAIGN FAIL AHAHAHAHAHAHAHAHAH))");
	return 1;
}

string cvar_campaignwrapper_list; // string of format ; var value; var value; var value; 
string cvar_string_campaignwrapper(string theCvar)
{
	float p, q;
	p = strstrofs(cvar_campaignwrapper_list, strcat("; ", theCvar, " "), 0);
	if(p < 0)
		return cvar_defstring(theCvar);
	p += strlen(theCvar) + 3;
	q = strstrofs(cvar_campaignwrapper_list, ";", p);
	if(q < 0)
		return cvar_defstring(theCvar);
	return substring(cvar_campaignwrapper_list, p, q - p);
}
float cvar_campaignwrapper(string theCvar)
{
	return stof(cvar_string_campaignwrapper(theCvar));
}
void cvar_set_campaignwrapper(string theCvar, string theValue)
{
	if(cvar_string_campaignwrapper(theCvar) == theValue)
		return;
	string s;
	s = cvar_campaignwrapper_list;
	cvar_campaignwrapper_list = strzone(strcat("; ", theCvar, " ", theValue, s));
	strunzone(s);
	//print(cvar_campaignwrapper_list, "\n");
}

float Campaign_Invalid()
{
	string thismapname, wantedmapname;
	thismapname = GetMapname();
	wantedmapname = campaign_gametype[0];
	if(MapInfo_CurrentGametype() != MapInfo_Type_FromString(wantedmapname))
		return CampaignBailout("wrong game type!");
	wantedmapname = campaign_mapname[0];
	if(wantedmapname != thismapname)
		return CampaignBailout(strcat("wrong map: ", wantedmapname, " != ", thismapname));
	return 0;
}

void CampaignPreInit()
{
	float baseskill;
	string title;
	if(autocvar_sv_cheats)
	{
		CampaignBailout("JOLLY CHEATS AHAHAHAHAHAHAH))");
		return;
	}
	campaign_level = autocvar__campaign_index;
	campaign_name = strzone(autocvar__campaign_name);
	campaign_index_var = strzone(strcat("g_campaign", campaign_name, "_index"));
	CampaignFile_Load(campaign_level, 2);
	if(campaign_entries < 1)
	{
		CampaignBailout("unknown map");
		return;
	}

	baseskill = autocvar_g_campaign_skill;
	baseskill = baseskill + campaign_botskill[0];
	if(baseskill < 0)
		baseskill = 0;

	cvar_set("sv_public", "0");
	cvar_set("pausable", "1");

	cvar_campaignwrapper_list = strzone(strcat("; ", campaign_mutators[0], "; "));

	cvar = cvar_campaignwrapper;
	cvar_string = cvar_string_campaignwrapper;
	cvar_set = cvar_set_campaignwrapper;

	cvar_set("g_campaign", "1");
	cvar_set("g_dm", "0");
	cvar_set("skill", ftos(baseskill));
	cvar_set("bot_number", ftos(campaign_bots[0]));
	MapInfo_SwitchGameType(MapInfo_Type_FromString(campaign_gametype[0]));

	// copy sv_gravity cvar, as the engine needs it too (sorry, this will mess
	// with the menu a little still...)
	cvar_set_normal("sv_gravity", ftos(autocvar_sv_gravity));

	if(Campaign_Invalid())
		return;

	title = campaign_shortdesc[0];
	title = strzone(strcat("Level ", ftos(campaign_level + 1), ": ", title));
	campaign_message = strzone(strcat(title, "\n^3\n", campaign_longdesc[0], "\n\n^1press jump to enter the game"));
	strunzone(title);
}

string GetMapname();
void CampaignPostInit()
{
	// now some sanity checks
	if(Campaign_Invalid())
		return;
	if(autocvar__campaign_testrun)
	{
		cvar_set("fraglimit", "0");
		cvar_set("timelimit", "0.01");
		cvar_set_normal("fraglimit", "0");
		cvar_set_normal("timelimit", "0.01");
	}
	else
	{
		cvar_set("fraglimit", ftos(campaign_fraglimit[0]));
		cvar_set("timelimit", ftos(campaign_timelimit[0]));
		cvar_set_normal("fraglimit", ftos(campaign_fraglimit[0]));
		cvar_set_normal("timelimit", ftos(campaign_timelimit[0]));
	}
}

void CampaignSaveCvar(string cvarname, float value)
{
	float fh;
	float len;
	string contents;
	string l;

	registercvar(cvarname, ftos(value));
	cvar_set_normal(cvarname, ftos(value));
	// note: cvarname must be remembered

	fh = fopen("campaign.cfg", FILE_READ);
	contents = "";
	if(fh >= 0)
	{
		while((l = fgets(fh)))
		{
			len = tokenize_console(l);
			if(len != 3)
				continue;
			if(argv(0) != "set")
				continue;
			if(argv(1) == cvarname)
				continue;
			contents = strcat(contents, "set ", argv(1), " ", argv(2), "\n");
		}
		fclose(fh);
	}
	contents = strcat(contents, "set ", cvarname,  " ", ftos(value), "\n");
	fh = fopen("campaign.cfg", FILE_WRITE);
	if(fh >= 0)
	{
		fputs(fh, contents);
	}
	else
	{
		error("Cannot write to campaign file");
	}
}

void CampaignPreIntermission()
{
	entity head;
	float won;
	float lost;
	string savevar;

	won = lost = 0;

	head = findchain(classname, "player");
	while(head)
	{
		if(IS_REAL_CLIENT(head))
		{
			if(head.winning)
				won = won + 1;
			else
				lost = lost + 1;
		}
		head = head.chain;
	}

	if(autocvar__campaign_testrun)
	{
		campaign_won = 1;
		bprint("Campaign test run, advancing level.\n");
	}
	else if(won == 1 && lost == 0 && checkrules_equality == 0)
	{
		if(autocvar_timelimit != 0 && autocvar_fraglimit != 0 && time > autocvar_timelimit * 60) // checks if the timelimit has expired.
		{
			campaign_won = 0;
			bprint("Time's up! The current level has been LOST.\n");
			// sound!
		}
		else
		{
			campaign_won = 1;
			bprint("The current level has been WON.\n");
			// sound!
		}
	}
	else if(autocvar_timelimit != 0 && time > autocvar_timelimit * 60)
	{
		campaign_won = 0;
		bprint("Time's up! The current level has been LOST.\n");
		// sound!
	}
	else
	{
		campaign_won = 0;
		bprint("The current level has been LOST.\n");
		// sound!
	}

	if(campaign_won && cheatcount_total == 0 && !autocvar__campaign_testrun)
	{
		if(campaign_level == cvar_normal(campaign_index_var))
		{
			if(campaign_entries < 2)
			{
				// I have won
				savevar = strcat("g_campaign", campaign_name, "_won");
				CampaignSaveCvar(savevar, 1);
				// advance level (for menu to show it right)
				CampaignSaveCvar(campaign_index_var, campaign_level + 1);
			}
			else
			{
				// advance level
				CampaignSaveCvar(campaign_index_var, campaign_level + 1);
			}
		}
	}
}

void CampaignPostIntermission()
{
	// NOTE: campaign_won is 0 or 1, that is, points to the next level

	if(campaign_won && campaign_entries < 2)
	{
		// last map won!
		print("^2test run: campaign looks GOOD\n");
		localcmd("togglemenu 1\n");
		CampaignFile_Unload();
		return;
	}

	CampaignSetup(campaign_won);
	CampaignFile_Unload();
	strunzone(campaign_message);
	strunzone(campaign_index_var);
	strunzone(campaign_name);
	campaign_name = "";
}



void CampaignLevelWarp(float n)
{
	if(n < 0)
		n = campaign_level + 1;
	CampaignFile_Unload();
	CampaignFile_Load(n, 1);
	if(campaign_entries)
		CampaignSetup(0);
	else
		error("Sorry, cheater. You are NOT WELCOME.");
	CampaignFile_Unload();
}

