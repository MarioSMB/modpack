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

string mod_translate_clean(string s)
{
	if(ColorTranslateMode & 1)
		return strdecolorize(s);

	if(s == "" || !s)
		return s;

	s = strreplace("^x666", "^1", s);
	s = strreplace("^x667", "^2", s);
	return s;
}

void mod_parse_print(string strMessage)
{
	if (autocvar_developer_csqcentities) LOG_INFOF("CSQC_Parse_Print(\"%s\")\n", strMessage);
	print(mod_translate_clean(strMessage));
}

string mod_ccr(string input)
{
	// See the autocvar declarations in util.qh for default values

	// foreground/normal colors
	input = strreplace("^F1", strcat("^", autocvar_hud_colorset_foreground_1), input);
	input = strreplace("^F2", strcat("^", autocvar_hud_colorset_foreground_2), input);
	input = strreplace("^F3", strcat("^", autocvar_hud_colorset_foreground_3), input);
	input = strreplace("^F4", strcat("^", autocvar_hud_colorset_foreground_4), input);

	// "kill" colors
	input = strreplace("^K1", strcat("^", autocvar_hud_colorset_kill_1), input);
	input = strreplace("^K2", strcat("^", autocvar_hud_colorset_kill_2), input);
	input = strreplace("^K3", strcat("^", autocvar_hud_colorset_kill_3), input);

	// background colors
	input = strreplace("^BG", strcat("^", autocvar_hud_colorset_background), input);
	input = strreplace("^N", "^7", input);  // "none"-- reset to white...
	input = mod_translate_clean(input);
	return input;
}

STATIC_INIT_LATE(mod_cvars_override)
{
	localcmd("\nset hud_panel_quickmenu_file quickmenu.txt\n");

	localcmd("\nalias ignore \"cmd ignore ${* ?}\"\n");
	localcmd("\nalias unignore \"cmd unignore ${* ?}\"\n");

	ColorTranslateRGB = mod_translate;
	CSQC_Parse_Print = mod_parse_print;
	CCR = mod_ccr;
}

REGISTER_MUTATOR(mutator_mod, true);

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsString)
{
    M_ARGV(0, string) = strcat(M_ARGV(0, string), ":mod");
}
