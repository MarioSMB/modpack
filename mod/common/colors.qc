#ifdef GAMEQC

string mod_translate_clean(string s)
{
	if(ColorTranslateMode & 1)
		return strdecolorize(s);

	if(s == "" || !s)
		return s;

	s = strreplace("^x664", "^7", s);
	s = strreplace("^x665", "^3", s);
	s = strreplace("^x666", "^1", s);
	s = strreplace("^x667", "^2", s);
	s = strreplace("^x668", "^4", s);
	s = strreplace("^x669", "^0", s);
	return s;
}

#ifdef SVQC
string mod_playername(entity p, bool team_colorize)
{
    if (team_colorize && teamplay && !intermission_running && IS_PLAYER(p))
    {
        string t = Team_ColorCode(p.team);
        return strcat(t, strdecolorize(p.netname));
    }
    else
        return mod_translate_clean(p.netname);
}

#if 0
MUTATOR_HOOKFUNCTION(mutator_mod, PreFormatMessage)
{
	string themessage = M_ARGV(1, string);
	themessage = mod_translate_clean(themessage);
	M_ARGV(1, string) = themessage;
}
#endif
#elif defined(CSQC)
AUTOCVAR(cl_stripfancystuff, bool, false, "Turn off the fancy blinking colorful names");

vector mod_get_num_color(int num)
{
	vector color;
	float thenum = 0;
	switch(num)
	{
		case 1: color = vec3(sin(2 * M_PI * time), 1, sin(2 * M_PI * time)); thenum = 200; break;
		default:
		case 2: color = '1 0 0'; thenum = 1; break;
		case 3: color = '0 0 1'; thenum = 1; break;
		case 4: color = vec3(1, 1, sin(2 * M_PI * time)); thenum = 200; break;
		case 5: color = vec3(sin(2 * M_PI * time), sin(2 * M_PI * time), sin(2 * M_PI * time)); thenum = 200; break;
		case 6: color = '1 1 1'; thenum = 1; break;
	}

	float blinkingamt = (1 - thenum/200/0.25);
	if(blinkingamt > 0)
	{
		color.x = color.x - color.x * blinkingamt * sin(2*M_PI*time);
		color.y = color.y - color.y * blinkingamt * sin(2*M_PI*time);
		color.z = color.z - color.z * blinkingamt * sin(2*M_PI*time);
	}
	return color;
}

string mod_translate(string s)
{
	if(autocvar_cl_stripfancystuff)
		return mod_translate_clean(s);

	if(ColorTranslateMode & 1)
		return strdecolorize(s);

	if(s == "" || !s)
		return s;

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
			int fc4 = stoi(nc4);
			if(nc1 == "x" && nc2 == "6" && nc3 == "6" && (fc4 >= 4 && fc4 <= 9)) // so far so good
			{
				switch(fc4)
				{
					case 4: fancy = 6; break;
					case 5: fancy = 4; break;
					default:
					case 6: fancy = 2; break;
					case 7: fancy = 1; break;
					case 8: fancy = 3; break;
					case 9: fancy = 5; break;
				}
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
			vector thecolor = mod_get_num_color(fancy);
			thecolor.x = bound(0, thecolor.x, 1);
			thecolor.y = bound(0, thecolor.y, 1);
			thecolor.z = bound(0, thecolor.z, 1);
			theword = strcat(theword, rgb_to_hexcolor(thecolor), strdecolorize(realch));
		}
		else
			theword = strcat(theword, realch);
	});

	return theword;
}

void mod_parse_print(string strMessage)
{
	if (autocvar_developer_csqcentities) LOG_INFOF("CSQC_Parse_Print(\"%s\")", strMessage);
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
#endif

STATIC_INIT_LATE(mod_functions_override)
{
#ifdef CSQC
	ColorTranslateRGB = mod_translate;
	CSQC_Parse_Print = mod_parse_print;
	CCR = mod_ccr;
	Scoreboard_GetName = mod_scoreboard_getname;
#elif defined(SVQC)
	playername = mod_playername;
#endif
}

#endif
