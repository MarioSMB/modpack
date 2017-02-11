STATIC_INIT(mod_cvars)
{
	localcmd("set hud_panel_minigamemenu 1\n");
}

AUTOCVAR(cl_stripfancystuff, bool, false, "Turn off the fancy blinking colorful names");

string mod_translate(string s)
{
	if(ColorTranslateMode & 1)
		return strdecolorize(s);

	if(s == "" || !s)
		return s;

	if(autocvar_cl_stripfancystuff)
		return s;

#if 1
	string theword = "";
	int fancy = 0;
	FOREACH_CHAR(s, true,
	{
		string realch = chr2str(it);
		if(realch == "^")
		{
			string nc1 = chr2str(str2chr(iter_s, iter_i));
			string nc2 = chr2str(str2chr(iter_s, iter_i + 1));
			string nc3 = chr2str(str2chr(iter_s, iter_i + 2));
			string nc4 = chr2str(str2chr(iter_s, iter_i + 3));
			if(nc1 == "x" && nc2 == "6" && nc3 == "6" && (nc4 == "6" || nc4 == "7")) // so far so good
			{
				fancy = ((nc4 == "7") ? 2 : 1);
				int pos = iter_i + 4; // skip the color code
				STRING_ITERATOR_LOAD(iter, pos);
				continue;
			}
			else
			{
				fancy = 0;
				// not a valid hax, but also a color, add normally and continue!
				theword = strcat(theword, realch);
				continue;
			}
		}
		else if(fancy)
		{
			vector thecolor = HUD_Get_Num_Color(((fancy == 2) ? 200 : 1), 100);
			thecolor.x = bound(0, thecolor.x, 1);
			thecolor.y = bound(0, thecolor.y, 1);
			thecolor.z = bound(0, thecolor.z, 1);
			theword = strcat(theword, rgb_to_hexcolor(thecolor), strdecolorize(realch));
		}
		else
			theword = strcat(theword, realch);
	});
#else
	int argc = tokenize_console(s); // unfortunately
	bool fancy = false;
	string theword = "";
	for(int j = 0; j < argc; ++j)
	{
		string c = substring(s, j, 1);

		if(fancy)
		{
			if(c == "^")
				fancy = false;
			else
			{
				vector thecolor = HUD_Get_Num_Color(1, 100);
				thecolor.x = bound(0, thecolor.x, 1);
				thecolor.y = bound(0, thecolor.y, 1);
				thecolor.z = bound(0, thecolor.z, 1);
				theword = strcat(theword, rgb_to_hexcolor(thecolor), strdecolorize(c));
				continue;
			}
		}
		else if(c == "^")
		{
			if(substring(s, j, 5) == "^x666")
			{
				fancy = true;
				j += 3;
				continue; // skip the color code?
			}
		}

		theword = strcat(theword, c);
	}
#endif

	return theword;
}

STATIC_INIT_LATE(mod_cvars_override)
{
	localcmd("\nset hud_panel_quickmenu_file quickmenu.txt\n");

	localcmd("\nalias ignore \"cmd ignore ${* ?}\"\n");
	localcmd("\nalias unignore \"cmd unignore ${* ?}\"\n");

	ColorTranslateRGB = mod_translate;
}

REGISTER_MUTATOR(mutator_mod, true);

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsString)
{
    M_ARGV(0, string) = strcat(M_ARGV(0, string), ":mod");
}
