#include "util.qh"

#ifdef GAMEQC
#include "weapons/all.qh"
#endif

#ifdef GAMEQC
/*
==================
findbetterlocation

Returns a point at least 12 units away from walls
(useful for explosion animations, although the blast is performed where it really happened)
Ripped from DPMod
==================
*/
vector findbetterlocation (vector org, float mindist)
{
	vector vec = mindist * '1 0 0';
	int c = 0;
	while (c < 6)
	{
		traceline (org, org + vec, true, NULL);
		vec = vec * -1;
		if (trace_fraction < 1)
		{
			vector loc = trace_endpos;
			traceline (loc, loc + vec, true, NULL);
			if (trace_fraction >= 1)
				org = loc + vec;
		}
		if (c & 1)
		{
			float h = vec.y;
			vec.y = vec.x;
			vec.x = vec.z;
			vec.z = h;
		}
		c = c + 1;
	}

	return org;
}
#endif

USING(textLengthUpToWidth_widthFunction_t, float(string s, vector size));
USING(textLengthUpToLength_lenFunction_t, float(string s));

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

string textShortenToWidth(string theText, float maxWidth, vector theFontSize, textLengthUpToWidth_widthFunction_t tw)
{
	if(tw(theText, theFontSize) <= maxWidth)
		return theText;
	else
		return strcat(substring(theText, 0, textLengthUpToWidth(theText, maxWidth - tw("...", theFontSize), theFontSize, tw)), "...");
}

string textShortenToLength(string theText, float maxWidth, textLengthUpToLength_lenFunction_t tw)
{
	if(tw(theText) <= maxWidth)
		return theText;
	else
		return strcat(substring(theText, 0, textLengthUpToLength(theText, maxWidth - tw("..."), tw)), "...");
}

string wordwrap_buffer;

void wordwrap_buffer_put(string s)
{
	wordwrap_buffer = strcat(wordwrap_buffer, s);
}

string wordwrap(string s, float l)
{
	string r;
	wordwrap_buffer = "";
	wordwrap_cb(s, l, wordwrap_buffer_put);
	r = wordwrap_buffer;
	wordwrap_buffer = "";
	return r;
}

#ifdef SVQC
entity _wordwrap_buffer_sprint_ent;
void wordwrap_buffer_sprint(string s)
{
	wordwrap_buffer = strcat(wordwrap_buffer, s);
	if(s == "\n")
	{
		sprint(_wordwrap_buffer_sprint_ent, wordwrap_buffer);
		wordwrap_buffer = "";
	}
}

void wordwrap_sprint(entity to, string s, float l)
{
	wordwrap_buffer = "";
	_wordwrap_buffer_sprint_ent = to;
	wordwrap_cb(s, l, wordwrap_buffer_sprint);
	_wordwrap_buffer_sprint_ent = NULL;
	if(wordwrap_buffer != "")
		sprint(to, strcat(wordwrap_buffer, "\n"));
	wordwrap_buffer = "";
	return;
}
#endif

void wordwrap_cb(string s, float l, void(string) callback)
{
	string c;
	float lleft, i, j, wlen;

	s = strzone(s);
	lleft = l;
	for (i = 0;i < strlen(s);++i)
	{
		if (substring(s, i, 2) == "\\n")
		{
			callback("\n");
			lleft = l;
			++i;
		}
		else if (substring(s, i, 1) == "\n")
		{
			callback("\n");
			lleft = l;
		}
		else if (substring(s, i, 1) == " ")
		{
			if (lleft > 0)
			{
				callback(" ");
				lleft = lleft - 1;
			}
		}
		else
		{
			for (j = i+1;j < strlen(s);++j)
				//    ^^ this skips over the first character of a word, which
				//       is ALWAYS part of the word
				//       this is safe since if i+1 == strlen(s), i will become
				//       strlen(s)-1 at the end of this block and the function
				//       will terminate. A space can't be the first character we
				//       read here, and neither can a \n be the start, since these
				//       two cases have been handled above.
			{
				c = substring(s, j, 1);
				if (c == " ")
					break;
				if (c == "\\")
					break;
				if (c == "\n")
					break;
				// we need to keep this tempstring alive even if substring is
				// called repeatedly, so call strcat even though we're not
				// doing anything
				callback("");
			}
			wlen = j - i;
			if (lleft < wlen)
			{
				callback("\n");
				lleft = l;
			}
			callback(substring(s, i, wlen));
			lleft = lleft - wlen;
			i = j - 1;
		}
	}
	strunzone(s);
}

string fixPriorityList(string order, float from, float to, float subtract, float complete)
{
	string neworder;
	float i, n, w;

	n = tokenize_console(order);
	neworder = "";
	for(i = 0; i < n; ++i)
	{
		w = stof(argv(i));
		if(w == floor(w))
		{
			if(w >= from && w <= to)
				neworder = strcat(neworder, ftos(w), " ");
			else
			{
				w -= subtract;
				if(w >= from && w <= to)
					neworder = strcat(neworder, ftos(w), " ");
			}
		}
	}

	if(complete)
	{
		n = tokenize_console(neworder);
		for(w = to; w >= from; --w)
		{
			//int wflags = REGISTRY_GET(Weapons, w).spawnflags;
			for(i = 0; i < n; ++i)
				if(stof(argv(i)) == w)
					break;
			if(i == n) // not found
				neworder = strcat(neworder, ftos(w), " ");
		}
	}

	return substring(neworder, 0, strlen(neworder) - 1);
}

string mapPriorityList(string order, string(string) mapfunc)
{
	string neworder;
	float n;

	n = tokenize_console(order);
	neworder = "";
	for(float i = 0; i < n; ++i)
		neworder = strcat(neworder, mapfunc(argv(i)), " ");

	return substring(neworder, 0, strlen(neworder) - 1);
}

string swapInPriorityList(string order, float i, float j)
{
	float n = tokenize_console(order);

	if(i >= 0 && i < n && j >= 0 && j < n && i != j)
	{
		string s = "";
		for(float w = 0; w < n; ++w)
		{
			if(w == i)
				s = strcat(s, argv(j), " ");
			else if(w == j)
				s = strcat(s, argv(i), " ");
			else
				s = strcat(s, argv(w), " ");
		}
		return substring(s, 0, strlen(s) - 1);
	}

	return order;
}

float compressShotOrigin(vector v)
{
	float rx = rint(v.x * 2);
	float ry = rint(v.y * 4) + 128;
	float rz = rint(v.z * 4) + 128;
	if(rx > 255 || rx < 0)
	{
		LOG_DEBUG("shot origin ", vtos(v), " x out of bounds\n");
		rx = bound(0, rx, 255);
	}
	if(ry > 255 || ry < 0)
	{
		LOG_DEBUG("shot origin ", vtos(v), " y out of bounds\n");
		ry = bound(0, ry, 255);
	}
	if(rz > 255 || rz < 0)
	{
		LOG_DEBUG("shot origin ", vtos(v), " z out of bounds\n");
		rz = bound(0, rz, 255);
	}
	return rx * 0x10000 + ry * 0x100 + rz;
}
vector decompressShotOrigin(int f)
{
	vector v;
	v.x = ((f & 0xFF0000) / 0x10000) / 2;
	v.y = ((f & 0xFF00) / 0x100 - 128) / 4;
	v.z = ((f & 0xFF) - 128) / 4;
	return v;
}

.float FindConnectedComponent_processing;
void FindConnectedComponent(entity e, .entity fld, findNextEntityNearFunction_t nxt, isConnectedFunction_t iscon, entity pass)
{
	entity queue_start, queue_end;

	// we build a queue of to-be-processed entities.
	// queue_start is the next entity to be checked for neighbors
	// queue_end is the last entity added

	if(e.FindConnectedComponent_processing)
		error("recursion or broken cleanup");

	// start with a 1-element queue
	queue_start = queue_end = e;
	queue_end.(fld) = NULL;
	queue_end.FindConnectedComponent_processing = 1;

	// for each queued item:
	for (; queue_start; queue_start = queue_start.(fld))
	{
		// find all neighbors of queue_start
		entity t;
		for(t = NULL; (t = nxt(t, queue_start, pass)); )
		{
			if(t.FindConnectedComponent_processing)
				continue;
			if(iscon(t, queue_start, pass))
			{
				// it is connected? ADD IT. It will look for neighbors soon too.
				queue_end.(fld) = t;
				queue_end = t;
				queue_end.(fld) = NULL;
				queue_end.FindConnectedComponent_processing = 1;
			}
		}
	}

	// unmark
	for (queue_start = e; queue_start; queue_start = queue_start.(fld))
		queue_start.FindConnectedComponent_processing = 0;
}

#ifdef GAMEQC
float trace_hits_box_a0, trace_hits_box_a1;

float trace_hits_box_1d(float end, float thmi, float thma)
{
    if (end == 0)
    {
        // just check if x is in range
        if (0 < thmi)
            return false;
        if (0 > thma)
            return false;
    }
    else
    {
        // do the trace with respect to x
        // 0 -> end has to stay in thmi -> thma
        trace_hits_box_a0 = max(trace_hits_box_a0, min(thmi / end, thma / end));
        trace_hits_box_a1 = min(trace_hits_box_a1, max(thmi / end, thma / end));
        if (trace_hits_box_a0 > trace_hits_box_a1)
            return false;
    }
    return true;
}

float trace_hits_box(vector start, vector end, vector thmi, vector thma)
{
    end -= start;
    thmi -= start;
    thma -= start;
    // now it is a trace from 0 to end

    trace_hits_box_a0 = 0;
    trace_hits_box_a1 = 1;

    if (!trace_hits_box_1d(end.x, thmi.x, thma.x))
        return false;
    if (!trace_hits_box_1d(end.y, thmi.y, thma.y))
        return false;
    if (!trace_hits_box_1d(end.z, thmi.z, thma.z))
        return false;

    return true;
}

float tracebox_hits_box(vector start, vector mi, vector ma, vector end, vector thmi, vector thma)
{
    return trace_hits_box(start, end, thmi - ma, thma - mi);
}
#endif

#ifdef GAMEQC
int Mod_Q1BSP_SuperContentsFromNativeContents(int nativecontents)
{
	switch(nativecontents)
	{
		case CONTENT_EMPTY:
			return 0;
		case CONTENT_SOLID:
			return DPCONTENTS_SOLID | DPCONTENTS_OPAQUE;
		case CONTENT_WATER:
			return DPCONTENTS_WATER;
		case CONTENT_SLIME:
			return DPCONTENTS_SLIME;
		case CONTENT_LAVA:
			return DPCONTENTS_LAVA | DPCONTENTS_NODROP;
		case CONTENT_SKY:
			return DPCONTENTS_SKY | DPCONTENTS_NODROP | DPCONTENTS_OPAQUE; // to match behaviour of Q3 maps, let sky count as opaque
	}
	return 0;
}

int Mod_Q1BSP_NativeContentsFromSuperContents(int supercontents)
{
	if(supercontents & (DPCONTENTS_SOLID | DPCONTENTS_BODY))
		return CONTENT_SOLID;
	if(supercontents & DPCONTENTS_SKY)
		return CONTENT_SKY;
	if(supercontents & DPCONTENTS_LAVA)
		return CONTENT_LAVA;
	if(supercontents & DPCONTENTS_SLIME)
		return CONTENT_SLIME;
	if(supercontents & DPCONTENTS_WATER)
		return CONTENT_WATER;
	return CONTENT_EMPTY;
}
#endif

#ifdef SVQC
.string aiment_classname;
.float aiment_deadflag;
void SetMovetypeFollow(entity ent, entity e)
{
	set_movetype(ent, MOVETYPE_FOLLOW); // make the hole follow
	ent.solid = SOLID_NOT; // MOVETYPE_FOLLOW is always non-solid - this means this cannot be teleported by warpzones any more! Instead, we must notice when our owner gets teleported.
	ent.aiment = e; // make the hole follow bmodel
	ent.punchangle = e.angles; // the original angles of bmodel
	ent.view_ofs = ent.origin - e.origin; // relative origin
	ent.v_angle = ent.angles - e.angles; // relative angles
	ent.aiment_classname = e.classname;
	ent.aiment_deadflag = e.deadflag;

	if(IS_PLAYER(ent.aiment))
	{
		entity pl = ent.aiment;
		ent.view_ofs.x = bound(pl.mins.x + 4, ent.view_ofs.x, pl.maxs.x - 4);
		ent.view_ofs.y = bound(pl.mins.y + 4, ent.view_ofs.y, pl.maxs.y - 4);
		ent.view_ofs.z = bound(pl.mins.z + 4, ent.view_ofs.z, pl.maxs.z - 4);
	}
}
#endif

float cvar_settemp(string tmp_cvar, string tmp_value)
{
	float created_saved_value;

	created_saved_value = 0;

	if (!(tmp_cvar || tmp_value))
	{
		LOG_TRACE("Error: Invalid usage of cvar_settemp(string, string); !");
		return 0;
	}

	if(!cvar_type(tmp_cvar))
	{
		LOG_INFOF("Error: cvar %s doesn't exist!\n", tmp_cvar);
		return 0;
	}

	IL_EACH(g_saved_cvars, it.netname == tmp_cvar,
	{
		created_saved_value = -1; // skip creation
		break; // no need to continue
	});

	if(created_saved_value != -1)
	{
		// creating a new entity to keep track of this cvar
		entity e = new_pure(saved_cvar_value);
		IL_PUSH(g_saved_cvars, e);
		e.netname = strzone(tmp_cvar);
		e.message = strzone(cvar_string(tmp_cvar));
		created_saved_value = 1;
	}

	// update the cvar to the value given
	cvar_set(tmp_cvar, tmp_value);

	return created_saved_value;
}

int cvar_settemp_restore()
{
	int j = 0;
	// FIXME this new-style loop fails!
#if 0
	FOREACH_ENTITY_CLASS("saved_cvar_value", true,
	{
		if(cvar_type(it.netname))
		{
			cvar_set(it.netname, it.message);
			strunzone(it.netname);
			strunzone(it.message);
			delete(it);
			++j;
		}
		else
			LOG_INFOF("Error: cvar %s doesn't exist anymore! It can still be restored once it's manually recreated.\n", it.netname);
	});

#else
	entity e = NULL;
	while((e = find(e, classname, "saved_cvar_value")))
	{
		if(cvar_type(e.netname))
		{
			cvar_set(e.netname, e.message);
			delete(e);
			++j;
		}
		else
			print(sprintf("Error: cvar %s doesn't exist anymore! It can still be restored once it's manually recreated.\n", e.netname));
	}
#endif

	return j;
}

float shutdown_running;
#ifdef SVQC
void SV_Shutdown()
#endif
#ifdef CSQC
void CSQC_Shutdown()
#endif
#ifdef MENUQC
void m_shutdown()
#endif
{
	if(shutdown_running)
	{
		LOG_INFO("Recursive shutdown detected! Only restoring cvars...\n");
	}
	else
	{
		shutdown_running = 1;
		//Shutdown();
		shutdownhooks();
	}
	cvar_settemp_restore(); // this must be done LAST, but in any case
}
