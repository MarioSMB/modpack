USING(textLengthUpToWidth_widthFunction_t, float(string s, vector size));
USING(textLengthUpToLength_lenFunction_t, float(string s));

bool isCaretEscaped(string theText, float pos)
{
	int i = 0;
	while(pos - i >= 1 && substring(theText, pos - i - 1, 1) == "^")
		++i;
	return (i & 1);
}

int skipIncompleteTag(string theText, float pos, int len)
{
	int i = 0, ch = 0;
	int tag_start = -1;

	if(substring(theText, pos - 1, 1) == "^")
	{
		if(isCaretEscaped(theText, pos - 1) || pos >= len)
			return 0;

		ch = str2chr(theText, pos);
		if(ch >= '0' && ch <= '9')
			return 1; // ^[0-9] color code found
		else if (ch == 'x')
			tag_start = pos - 1; // ^x tag found
		else
			return 0;
	}
	else
	{
		for(i = 2; pos - i >= 0 && i <= 4; ++i)
		{
			if(substring(theText, pos - i, 2) == "^x")
			{
				tag_start = pos - i; // ^x tag found
				break;
			}
		}
	}

	if(tag_start >= 0)
	{
		if(tag_start + 5 < len)
		if(IS_HEXDIGIT(substring(theText, tag_start + 2, 1)))
		if(IS_HEXDIGIT(substring(theText, tag_start + 3, 1)))
		if(IS_HEXDIGIT(substring(theText, tag_start + 4, 1)))
		{
			if(!isCaretEscaped(theText, tag_start))
				return 5 - (pos - tag_start); // ^xRGB color code found
		}
	}
	return 0;
}

float textLengthUpToWidth(string theText, float maxWidth, vector theSize, textLengthUpToWidth_widthFunction_t w)
{
	// STOP.
	// The following function is SLOW.
	// For your safety and for the protection of those around you...
	// DO NOT CALL THIS AT HOME.
	// No really, don't.
	if(w(theText, theSize) <= maxWidth)
		return strlen(theText); // yeah!

	bool colors = (w("^7", theSize) == 0);

	// binary search for right place to cut string
	int len, left, right, middle;
	left = 0;
	right = len = strlen(theText);
	int ofs = 0;
	do
	{
		middle = floor((left + right) / 2);
		if(colors)
			ofs = skipIncompleteTag(theText, middle, len);
		if(w(substring(theText, 0, middle + ofs), theSize) <= maxWidth)
			left = middle + ofs;
		else
			right = middle;
	}
	while(left < right - 1);

	return left;
}

float textLengthUpToLength(string theText, float maxWidth, textLengthUpToLength_lenFunction_t w)
{
	// STOP.
	// The following function is SLOW.
	// For your safety and for the protection of those around you...
	// DO NOT CALL THIS AT HOME.
	// No really, don't.
	if(w(theText) <= maxWidth)
		return strlen(theText); // yeah!

	bool colors = (w("^7") == 0);

	// binary search for right place to cut string
	int len, left, right, middle;
	left = 0;
	right = len = strlen(theText);
	int ofs = 0;
	do
	{
		middle = floor((left + right) / 2);
		if(colors)
			ofs = skipIncompleteTag(theText, middle, len);
		if(w(substring(theText, 0, middle + ofs)) <= maxWidth)
			left = middle + ofs;
		else
			right = middle;
	}
	while(left < right - 1);

	return left;
}

string find_last_color_code(string s)
{
	int start = strstrofs(s, "^", 0);
	if (start == -1) // no caret found
		return "";
	int len = strlen(s)-1;
	int i;
	for(i = len; i >= start; --i)
	{
		if(substring(s, i, 1) != "^")
			continue;

		int carets = 1;
		while (i-carets >= start && substring(s, i-carets, 1) == "^")
			++carets;

		// check if carets aren't all escaped
		if (carets & 1)
		{
			if(i+1 <= len)
			if(IS_DIGIT(substring(s, i+1, 1)))
				return substring(s, i, 2);

			if(i+4 <= len)
			if(substring(s, i+1, 1) == "x")
			if(IS_HEXDIGIT(substring(s, i + 2, 1)))
			if(IS_HEXDIGIT(substring(s, i + 3, 1)))
			if(IS_HEXDIGIT(substring(s, i + 4, 1)))
				return substring(s, i, 5);
		}
		i -= carets; // this also skips one char before the carets
	}

	return "";
}

string getWrappedLine_remaining;
string getWrappedLine(float w, vector theFontSize, textLengthUpToWidth_widthFunction_t tw)
{
	float cantake;
	float take;
	string s;

	s = getWrappedLine_remaining;

	if(w <= 0)
	{
		getWrappedLine_remaining = string_null;
		return s; // the line has no size ANYWAY, nothing would be displayed.
	}

	cantake = textLengthUpToWidth(s, w, theFontSize, tw);
	if(cantake > 0 && cantake < strlen(s))
	{
		take = cantake - 1;
		while(take > 0 && substring(s, take, 1) != " ")
			--take;
		if(take == 0)
		{
			getWrappedLine_remaining = substring(s, cantake, strlen(s) - cantake);
			if(getWrappedLine_remaining == "")
				getWrappedLine_remaining = string_null;
			else if (tw("^7", theFontSize) == 0)
				getWrappedLine_remaining = strcat(find_last_color_code(substring(s, 0, cantake)), getWrappedLine_remaining);
			return substring(s, 0, cantake);
		}
		else
		{
			getWrappedLine_remaining = substring(s, take + 1, strlen(s) - take);
			if(getWrappedLine_remaining == "")
				getWrappedLine_remaining = string_null;
			else if (tw("^7", theFontSize) == 0)
				getWrappedLine_remaining = strcat(find_last_color_code(substring(s, 0, take)), getWrappedLine_remaining);
			return substring(s, 0, take);
		}
	}
	else
	{
		getWrappedLine_remaining = string_null;
		return s;
	}
}

string getWrappedLineLen(float w, textLengthUpToLength_lenFunction_t tw)
{
	float cantake;
	float take;
	string s;

	s = getWrappedLine_remaining;

	if(w <= 0)
	{
		getWrappedLine_remaining = string_null;
		return s; // the line has no size ANYWAY, nothing would be displayed.
	}

	cantake = textLengthUpToLength(s, w, tw);
	if(cantake > 0 && cantake < strlen(s))
	{
		take = cantake - 1;
		while(take > 0 && substring(s, take, 1) != " ")
			--take;
		if(take == 0)
		{
			getWrappedLine_remaining = substring(s, cantake, strlen(s) - cantake);
			if(getWrappedLine_remaining == "")
				getWrappedLine_remaining = string_null;
			else if (tw("^7") == 0)
				getWrappedLine_remaining = strcat(find_last_color_code(substring(s, 0, cantake)), getWrappedLine_remaining);
			return substring(s, 0, cantake);
		}
		else
		{
			getWrappedLine_remaining = substring(s, take + 1, strlen(s) - take);
			if(getWrappedLine_remaining == "")
				getWrappedLine_remaining = string_null;
			else if (tw("^7") == 0)
				getWrappedLine_remaining = strcat(find_last_color_code(substring(s, 0, take)), getWrappedLine_remaining);
			return substring(s, 0, take);
		}
	}
	else
	{
		getWrappedLine_remaining = string_null;
		return s;
	}
}


string formatmessage(entity this, string msg)
{
	float p = 0;
	int n = 7; // max replacements

	string ammoitems = "batteries";
	if(this.items & IT_CELLS) ammoitems = "cells";
	if(this.items & IT_ROCKETS) ammoitems = "rockets";
	if(this.items & IT_NAILS) ammoitems = "nails";
	if(this.items & IT_SHELLS) ammoitems = "shells";

	string wep = "axe";

	traceline(this.cursor_trace_start, this.cursor_trace_start + normalize(this.cursor_trace_endpos - this.cursor_trace_start) * 16384, MOVE_NORMAL, this);
	vector cursor = trace_endpos;
	entity cursor_ent = trace_ent;

	while (1) {
		if (n < 1)
			break; // too many replacements

		n = n - 1;
		float p1 = strstrofs(msg, "%", p); // NOTE: this destroys msg as it's a tempstring!
		float p2 = strstrofs(msg, "\\", p); // NOTE: this destroys msg as it's a tempstring!

		if (p1 < 0)
			p1 = p2;

		if (p2 < 0)
			p2 = p1;

		p = min(p1, p2);

		if (p < 0)
			break;

		string replacement = substring(msg, p, 2);
		string escape = substring(msg, p + 1, 1);

		switch(escape)
		{
			case "%": replacement = "%"; break;
			case "\\":replacement = "\\"; break;
			case "n": replacement = "\n"; break;
			case "a": replacement = ftos(floor(this.armorvalue)); break;
			case "h": replacement = ftos(floor(this.health)); break;
			case "l": replacement = vtos(this.origin); break;
			case "y": replacement = vtos(cursor); break;
			//case "d": replacement = vtos(this.death_origin); break;
			case "w": replacement = wep; break;
			case "W": replacement = ammoitems; break;
			case "x": replacement = ((cursor_ent.netname == "" || !cursor_ent) ? "nothing" : cursor_ent.netname); break;
			case "s": replacement = ftos(vlen(this.velocity - this.velocity_z * '0 0 1')); break;
			case "S": replacement = ftos(vlen(this.velocity)); break;
			//case "t": replacement = seconds_tostring(ceil(max(0, autocvar_timelimit * 60 + game_starttime - time))); break;
			//case "T": replacement = seconds_tostring(floor(time - game_starttime)); break;
		}

		msg = strcat(substring(msg, 0, p), replacement, substring(msg, p+2, strlen(msg) - (p+2)));
		p = p + strlen(replacement);
	}
	return msg;
}

//flood fields
//.float nickspamtime; // time of last nick change
//.float nickspamcount;
.float floodcontrol_chat;
.float floodcontrol_chattell;

float autocvar_g_chat_flood_spl_tell;
float autocvar_g_chat_flood_burst_tell;
float autocvar_g_chat_flood_lmax_tell;

float autocvar_g_chat_flood_spl;
float autocvar_g_chat_flood_burst;
float autocvar_g_chat_flood_lmax;

.bool muted;

bool autocvar_g_chat_flood_notify_flooder;

string mod_translate_clean(string s)
{
	if(s == "" || !s)
		return s;

	s = strreplace("^x665", "^3", s);
	s = strreplace("^x666", "^1", s);
	s = strreplace("^x667", "^2", s);
	s = strreplace("^x668", "^4", s);
	s = strreplace("^x669", "^0", s);
	return s;
}

/**
 * message "": do not say, just test flood control
 * return value:
 *   1 = accept
 *   0 = reject
 *  -1 = fake accept
 */
int Say(entity source, int teamsay, entity privatesay, string msgin, bool floodcontrol)
{
	if (!privatesay && substring(msgin, 0, 1) == " ")
        msgin = substring(msgin, 1, -1); // work around DP say bug (say_team does not have this!)

	msgin = formatmessage(source, msgin);
	msgin = mod_translate_clean(msgin);

    string colorstr;
	if (!IS_PLAYER(source))
		colorstr = "^0"; // black for spectators
	else
		colorstr = "";

    if (!source)
		colorstr = "";

	/*
	 * using bprint solves this... me stupid
	// how can we prevent the message from appearing in a listen server?
	// for now, just give "say" back and only handle say_team
	if(!teamsay)
	{
		clientcommand(source, strcat("say ", msgin));
		return;
	}
	*/

    string namestr = "";
    if (source)
        namestr = mod_translate_clean(source.netname);

    string colorprefix = (strdecolorize(namestr) == namestr) ? "^3" : "^7";

    string msgstr, cmsgstr;
    string privatemsgprefix = string_null;
    int privatemsgprefixlen = 0;
	if (msgin == "") {
        msgstr = cmsgstr = "";
	} else {
		if(privatesay)
		{
			msgstr = strcat("\{1}\{13}* ", colorprefix, namestr, "^3 tells you: ^7");
			privatemsgprefixlen = strlen(msgstr);
			msgstr = strcat(msgstr, msgin);
			cmsgstr = strcat(colorstr, colorprefix, namestr, "^3 tells you:\n^7", msgin);
			privatemsgprefix = strcat("\{1}\{13}* ^3You tell ", privatesay.netname, ": ^7");
		}
		else
		{
			if(strstrofs(msgin, "/me", 0) >= 0)
			{
				//msgin = strreplace("/me", "", msgin);
				//msgin = substring(msgin, 3, strlen(msgin));
				msgin = strreplace("/me", strcat(colorprefix, namestr), msgin);
				msgstr = strcat("\{1}^4* ", "^7", msgin);
			}
			else {
                msgstr = "\{1}";
                msgstr = strcat(msgstr, (namestr != "") ? strcat(colorprefix, namestr, "^7: ") : "^7");
                msgstr = strcat(msgstr, msgin);
            }
			cmsgstr = "";
		}
		msgstr = strcat(strreplace("\n", " ", msgstr), "\n"); // newlines only are good for centerprint
	}

	string fullmsgstr = msgstr;
	string fullcmsgstr = cmsgstr;

	// FLOOD CONTROL
	int flood = 0;
	var .float flood_field = floodcontrol_chat;
	if(floodcontrol)
	{
		float flood_spl;
		float flood_burst;
		float flood_lmax;
		float lines;
		if(privatesay)
		{
			flood_spl = autocvar_g_chat_flood_spl_tell;
			flood_burst = autocvar_g_chat_flood_burst_tell;
			flood_lmax = autocvar_g_chat_flood_lmax_tell;
			flood_field = floodcontrol_chattell;
		}
		else
		{
			flood_spl = autocvar_g_chat_flood_spl;
			flood_burst = autocvar_g_chat_flood_burst;
			flood_lmax = autocvar_g_chat_flood_lmax;
			flood_field = floodcontrol_chat;
		}
		flood_burst = max(0, flood_burst - 1);
		// to match explanation in default.cfg, a value of 3 must allow three-line bursts and not four!

		// do flood control for the default line size
		if(msgstr != "")
		{
			getWrappedLine_remaining = msgstr;
			msgstr = "";
			lines = 0;
			while(getWrappedLine_remaining && (!flood_lmax || lines <= flood_lmax))
			{
				msgstr = strcat(msgstr, " ", getWrappedLineLen(82.4289758859709, strlennocol)); // perl averagewidth.pl < gfx/vera-sans.width
				++lines;
			}
			msgstr = substring(msgstr, 1, strlen(msgstr) - 1);

			if(getWrappedLine_remaining != "")
			{
				msgstr = strcat(msgstr, "\n");
				flood = 2;
			}

			if (time >= source.(flood_field))
			{
				source.(flood_field) = max(time - flood_burst * flood_spl, source.(flood_field)) + lines * flood_spl;
			}
			else
			{
				flood = 1;
				msgstr = fullmsgstr;
			}
		}
		else
		{
			if (time >= source.(flood_field))
				source.(flood_field) = max(time - flood_burst * flood_spl, source.(flood_field)) + flood_spl;
			else
				flood = 1;
		}
	}

    string sourcemsgstr, sourcecmsgstr;
	if(flood == 2) // cannot happen for empty msgstr
	{
		if(autocvar_g_chat_flood_notify_flooder)
		{
			sourcemsgstr = strcat(msgstr, "\n^3FLOOD CONTROL: ^7message too long, trimmed\n");
			sourcecmsgstr = "";
		}
		else
		{
			sourcemsgstr = fullmsgstr;
			sourcecmsgstr = fullcmsgstr;
		}
		cmsgstr = "";
	}
	else
	{
		sourcemsgstr = msgstr;
		sourcecmsgstr = cmsgstr;
	}

	if(flood)
		LOG_INFO("NOTE: ", source.netname, "^7 is flooding.\n");

	// build sourcemsgstr by cutting off a prefix and replacing it by the other one
	if(privatesay)
		sourcemsgstr = strcat(privatemsgprefix, substring(sourcemsgstr, privatemsgprefixlen, -1));

    int ret;
	if(source.muted)
	{
		// always fake the message
		ret = -1;
	}
	else if(flood == 1)
	{
		if (autocvar_g_chat_flood_notify_flooder)
		{
			sprint(source, strcat("^3FLOOD CONTROL: ^7wait ^1", ftos(source.(flood_field) - time), "^3 seconds\n"));
			ret = 0;
		}
		else
			ret = -1;
	}
	else
	{
		ret = 1;
	}

	if(sourcemsgstr != "" && ret != 0)
	{
		if(ret < 0) // faked message, because the player is muted
		{
			sprint(source, sourcemsgstr);
			if(sourcecmsgstr != "" && !privatesay)
				centerprint(source, sourcecmsgstr);
		}
		else if(privatesay) // private message, between 2 people only
		{
			sprint(source, sourcemsgstr);
			//if (!autocvar_g_chat_tellprivacy) { dedicated_print(msgstr); } // send to server console too if "tellprivacy" is disabled
			sprint(privatesay, msgstr);
			if(cmsgstr != "")
				centerprint(privatesay, cmsgstr);
		}
		else
		{
            if (source) {
                sprint(source, sourcemsgstr);
                dedicated_print(msgstr); // send to server console too
            }
            FOREACH_CLIENT(IS_REAL_CLIENT(it) && it != source, sprint(it, msgstr));
        }
	}

	return ret;
}
