#include "chat_grabber.qh"

ERASEABLE
void PrintToChatAll(string text)
{
	text = strcat("\{1}^7", text, "\n");
	bprint(text);
}

string NearestLocation(vector p)
{
    string ret = "somewhere";
    return ret;
}

string PlayerHealth(entity this)
{
	float myhealth = floor(this.health);
	if(myhealth == -666)
		return "spectating";
	else if(myhealth == -2342 || (myhealth == 2342 && intermission_running))
		return "observing";
	else if(myhealth <= 0 || this.deadflag != DEAD_NO || this.died)
		return "dead";
	return ftos(myhealth);
}

string WeaponNameFromWeaponentity(entity this, .entity weaponentity)
{
	entity wepent = this.(weaponentity);
	if(!wepent || !IS_PLAYER(this))
		return "N/A";
	else if(wepent.m_weapon != WEP_Null)
		return wepent.m_weapon.m_name;
	return "none"; //REGISTRY_GET(Weapons, wepent.cnt).m_name;
}

string formatmessage(entity this, string msg)
{
	float p = 0;
	int n = 7; // max replacements

	chat_grabber_PreFormatMessage(this, msg);

	string ammoitems = "batteries";
	if(this.items & IT_LAVA_NAILS) ammoitems = "lava nails";
	else if(this.items & IT_PLASMA_AMMO) ammoitems = "plasma";
	else if(this.items & IT_MULTI_ROCKETS) ammoitems = "multi rockets";
	else if(this.items & IT_CELLS) ammoitems = "cells";
	else if(this.items & IT_ROCKETS) ammoitems = "rockets";
	else if(this.items & IT_NAILS) ammoitems = "nails";
	else if(this.items & IT_SHELLS) ammoitems = "shells";

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

		.entity weaponentity = weaponentities[0]; // TODO: unhardcode

		switch(escape)
		{
			case "%": replacement = "%"; break;
			case "\\":replacement = "\\"; break;
			case "n": replacement = "\n"; break;
			case "a": replacement = ftos(floor(this.armorvalue)); break;
			case "h": replacement = PlayerHealth(this); break;
			case "l": replacement = NearestLocation(this.origin); break;
			case "y": replacement = NearestLocation(cursor); break;
			case "d": replacement = NearestLocation(this.death_origin); break;
			case "o": replacement = vtos(this.origin); break;
			case "O": replacement = sprintf("'%f %f %f'", this.origin.x, this.origin.y, this.origin.z); break;
			case "w": replacement = WeaponNameFromWeaponentity(this, weaponentity); break;
			case "W": replacement = ammoitems; break;
			case "x": replacement = ((cursor_ent.netname == "" || !cursor_ent) ? "nothing" : cursor_ent.netname); break;
			case "s": replacement = ftos(vlen(this.velocity - this.velocity_z * '0 0 1')); break;
			case "S": replacement = ftos(vlen(this.velocity)); break;
			case "t": replacement = seconds_tostring(ceil(max(0, autocvar_timelimit * 60 - time))); break;
			case "T": replacement = seconds_tostring(floor(time)); break;
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

bool autocvar_g_chat_flood_notify_flooder;

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
        namestr = source.netname;

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
			if(IS_REAL_CLIENT(source) && ignore_playerinlist(source, privatesay)) // check ignored players from personal chat log (from "ignore" command)
				return -1; // no sending to this player, thank you very much
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
            FOREACH_CLIENT(IS_REAL_CLIENT(it) && it != source,
            {
            	if(IS_REAL_CLIENT(source) && ignore_playerinlist(source, it)) // check ignored players from personal chat log (from "ignore" command)
					continue; // no sending to this player, thank you very much
            	
            	sprint(it, msgstr);
            });
        }
	}

	return ret;
}
