//bool sv_radio;
.bool radio_enabled;

bool radio_playing;
bool radio_looping;
float radio_starttime;
float radio_tracklen;
float radio_playing_queue;
float radio_queue_advanceat;
float radio_queue_next_request;
string radio_url;
string radio_filename;

const int URI_GET_RADIO = 195;

AUTOCVAR_NOREF(sv_radio, bool, false, "Enable radio");
AUTOCVAR(sv_radio_announce, bool, true, "");
AUTOCVAR(sv_radio_announce_howto, bool, true, "");
AUTOCVAR(sv_radio_log_skips, bool, false, "");
AUTOCVAR(sv_radio_preload, bool, true, "");
AUTOCVAR(sv_radio_queue_advanceat, float, 0.4, "");
AUTOCVAR(sv_radio_queue_autofill, bool, false, "");
AUTOCVAR(sv_radio_queue_autofill_retry, float, 10, "");
AUTOCVAR(sv_radio_queue_autofill_server, string, "http://example.com/smb/radio", "");

REGISTER_MUTATOR(radio, cvar("sv_radio"))
{
	MUTATOR_ONADD
	{
		sv_radio = cvar("sv_radio");
		radio_playing_queue = -1;

		if(!sv_radio)
			return false;

		registercvar("_radio_queue", "");
		registercvar("_radio_queue_left", "0");
	}

	return false;
}

void Radio_SendPreload(entity e, string url)
{
	msg_entity = e;
	WriteHeader(MSG_ONE, TE_CSQC_RADIO);
	WriteByte(MSG_ONE, true);
	WriteString(MSG_ONE, url);
}

string mmss(float tenths)
{
	tenths = floor(tenths + 0.5);
	float minutes = floor(tenths / 600);
	tenths -= minutes * 600;
	string s = ftos(1000 + tenths);
	return strcat(ftos(minutes), ":", substring(s, 1, 2));
}

void Radio_Announce(entity this)
{
	if(radio_playing_queue >= 0)
	if(autocvar_sv_radio_announce)
	{
		string desc = cvar_string(strcat("_radio_queue_", ftos(radio_playing_queue), "_desc"));
		if(desc == "")
			desc = "^8(unknown track)";
		desc = strcat("^1[RADIO] ^2Now playing ^3", desc);
		if(radio_tracklen)
			desc = strcat(desc, "^8 (", mmss(radio_tracklen * 10), ")");
		float left = cvar("_radio_queue_left");
		if(left)
			desc = strcat(desc, "^7 - ", ftos(left), " in queue");

		if(autocvar_sv_radio_announce_howto)
			desc = strcat(desc, " ^2(NOTE: you can turn off radio with ^1radio off^2)");

		if(this)
			sprint(this, strcat("\{1}", desc, "\n"));
		else
		{
			bprint("\{1}", desc, "\n");
		}
	}
}

void Radio_SendPlay(entity this)
{
	if(!radio_playing)
		return;

	Radio_Announce(this);

	msg_entity = this;
	WriteHeader(MSG_ONE, TE_CSQC_RADIO);
	WriteByte(MSG_ONE, false);
	WriteString(MSG_ONE, radio_url);
	WriteString(MSG_ONE, radio_filename);
	WriteByte(MSG_ONE, radio_looping);
	if(!radio_looping)
		WriteCoord(MSG_ONE, radio_starttime);
}

void Radio_Preload(string url)
{
	if(!sv_radio)
		return;

	if(!autocvar_sv_radio_preload)
		return;

	FOREACH_CLIENT(IS_REAL_CLIENT(it),
	{
		Radio_SendPreload(it, url);
	});
}

void Radio_Play(string url, string fname, bool loop)
{
	if(!sv_radio)
		return;

	if(radio_url)       strunzone(radio_url);
	if(radio_filename)  strunzone(radio_filename);

	radio_url = strzone(url);
	radio_filename = strzone(fname);
	radio_looping = loop;
	radio_starttime = time;
	radio_playing = true;
	radio_tracklen = 0;
	radio_playing_queue = -1;

	dprint("URL: ", radio_url, "\n");
	dprint("File: ", radio_filename, "\n");
	dprint("Loop: ", ftos(radio_looping), "\n");
	dprint("Start: ", ftos(radio_starttime), "\n");

	FOREACH_CLIENT(IS_REAL_CLIENT(it),
	{
		Radio_SendPlay(it);
	});
}

void Radio_Stop(bool dostop)
{
	if(radio_url)       strunzone(radio_url);
	if(radio_filename)  strunzone(radio_filename);

	if(!radio_playing)
		return;

	radio_playing = false;
	radio_url = radio_filename = string_null;
	radio_playing_queue = -1;

	if(dostop)
	{
		FOREACH_CLIENT(IS_REAL_CLIENT(it),
		{
			stuffcmd(it, "cd stop\n");
		});
	}
}

void Radio_Queue_Request(void)
{
	radio_queue_next_request = 0;
	if(autocvar_sv_radio_queue_autofill)
		uri_get(autocvar_sv_radio_queue_autofill_server, URI_GET_RADIO);
}

void Radio_Queue_PlayFirst(entity this)
{
	if(!sv_radio)
		return;

	int realclients = 0;
	FOREACH_CLIENT(IS_REAL_CLIENT(it),
	{
		++realclients;
	});

	if(!realclients || intermission_running)
	{
		Radio_Stop(false);
		return;
	}

	string q = cvar_string("_radio_queue");

	if(q == "")
	{
		Radio_Stop(true);
		Radio_Queue_Request();
		return;
	}

	int n = tokenizebyseparator(q, " ");

	string id    = argv(0);
	string url   = cvar_string(strcat("_radio_queue_", id, "_url"));
	string fname = cvar_string(strcat("_radio_queue_", id, "_fname"));

	Radio_Play(url, fname, false);

	radio_tracklen = cvar(strcat("_radio_queue_", id, "_len"));
	radio_playing_queue = stof(id);
	radio_queue_advanceat = radio_starttime + radio_tracklen * autocvar_sv_radio_queue_advanceat;

	// preload next track
	id = argv(1);
	if(id != "")
		Radio_Preload(cvar_string(strcat("_radio_queue_", id, "_url")));

	cvar_set("_radio_queue_left", ftos(n-1));
	Radio_Announce(NULL);
}

string Radio_Queue_GetFreeID(void)
{
	int id;
	string qs = strcat(" ", cvar_string("_radio_queue"), " ");

	for(id = 0 ;; ++id)
	{
		string s = ftos(id);
		if(strstrofs(qs, strcat(" ", s, " "), 0) < 0)
			return s;
	}

	//return ""; // can't get here
}

void Radio_Queue(string url, string fname, float len, string desc)
{
	if(!sv_radio)
		return;

	radio_queue_next_request = 0;

	string id = Radio_Queue_GetFreeID();

	string url_var   = strcat("_radio_queue_", id, "_url");
	string fname_var = strcat("_radio_queue_", id, "_fname");
	string len_var   = strcat("_radio_queue_", id, "_len");
	string desc_var  = strcat("_radio_queue_", id, "_desc");

	registercvar(url_var, "");
	registercvar(fname_var, "");
	registercvar(len_var, "");
	registercvar(desc_var, "");

	cvar_set(url_var, url);
	cvar_set(fname_var, fname);
	cvar_set(len_var, ftos(len));
	cvar_set(desc_var, MakeConsoleSafe(desc));

	string q = cvar_string("_radio_queue");
	if(q == "")
		cvar_set("_radio_queue", id);
	else
		cvar_set("_radio_queue", strcat(q, " ", id));

	if(radio_playing_queue < 0)
		Radio_Queue_PlayFirst(NULL);
	else if(!cvar("_radio_queue_left"))
		Radio_Preload(url);

	cvar_set("_radio_queue_left", ftos(cvar("_radio_queue_left") + 1));
}

void Radio_Queue_Advance(void)
{
	string q = cvar_string("_radio_queue");
	float sp = strstrofs(q, " ", 0);

	if(sp < 0)
	{
		cvar_set("_radio_queue", "");
		return;
	}

	cvar_set("_radio_queue", substring(q, sp+1, strlen(q)));
}

void Radio_Queue_Skip(void)
{
	if(radio_playing_queue < 0)
		return;

	if(autocvar_sv_radio_log_skips)
	{
		float fh = fopen("skiplog", FILE_APPEND);
		if(fh >= 0)
		{
			fputs(fh, strcat(strftime(true, "%a %b %e %H:%M:%S %Z %Y "), radio_url, " ", radio_filename, "\n"));
			fclose(fh);
		}
	}

	if(radio_queue_advanceat)
		Radio_Queue_Advance();
	Radio_Queue_PlayFirst(NULL);
}

MUTATOR_HOOKFUNCTION(radio, SV_ParseServerCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	string cmd_name = M_ARGV(0, string);

	if(cmd_name == "netmusic" || cmd_name == "radio_play")
	{
		Radio_Play(argv(1), argv(2), (argv(3) == "loop"));
		return true;
	}
	
	if(cmd_name == "stopmusic" || cmd_name == "radio_stop")
	{
		Radio_Stop(true);
		return true;
	}

	if(cmd_name == "radio_preload")
	{
		Radio_Preload(argv(1));
		return true;
	}

	if(cmd_name == "radio_queue")
	{
		Radio_Queue(argv(1), argv(2), stof(argv(3)), uri_unescape(argv(4)));
		return true;
	}

	if(cmd_name == "radio_queue_skip")
	{
		Radio_Queue_Skip();
		return true;
	}

	if(cmd_name == "radio_queue_restart")
	{
		Radio_Queue_PlayFirst(NULL);
		return true;
	}

	if(cmd_name == "radio_evil")
	{
		FOREACH_CLIENT(IS_REAL_CLIENT(it),
		{
			stuffcmd(it, "radio 1\n");
		});
		return true;
	}
}

MUTATOR_HOOKFUNCTION(radio, SV_StartFrame)
{
	if(radio_queue_next_request)
	if(time > radio_queue_next_request)
		Radio_Queue_Request();

	if(radio_playing_queue < 0)
		return false;

	if(radio_queue_advanceat > 0)
	if(time > radio_queue_advanceat)
	{
		Radio_Queue_Advance();
		radio_queue_advanceat = 0;

		if(cvar_string("_radio_queue") == "")
			Radio_Queue_Request();
	}

	if(time > radio_starttime + radio_tracklen)
		Radio_Queue_PlayFirst(NULL);
}

void Radio_URI_Get_Callback(float id, float status, string data)
{
	if(status)
	{
		radio_queue_next_request = time + autocvar_sv_radio_queue_autofill_retry;
		return;
	}

	int n = tokenizebyseparator(data, " ");
	string d = "";

	if(n > 3)
	{
		d = substring(data, argv_start_index(3), strlen(data));
		d = strcat(d, " ^8(autoqueue)");
	}

	Radio_Queue(argv(0), argv(1), stof(argv(2)), d);
}

MUTATOR_HOOKFUNCTION(radio, URI_GetCallback)
{
	float uricb_id = M_ARGV(0, float);
	float uricb_status = M_ARGV(1, float);
	string uricb_data = M_ARGV(2, string);

	if(uricb_id == URI_GET_RADIO)
	{
		Radio_URI_Get_Callback(uricb_id, uricb_status, uricb_data);
		return true;
	}
}

void Radio_ClientConnect_Delayed(entity this)
{
	Radio_SendPlay(this);
}

MUTATOR_HOOKFUNCTION(radio, ClientConnect)
{
	entity player = M_ARGV(0, entity);

	if(!IS_REAL_CLIENT(player))
		return;

	int realclients = 0;
	FOREACH_CLIENT(IS_REAL_CLIENT(it),
	{
		++realclients;
	});

	if(realclients == 1 && !radio_playing)
		defer(player, 5, Radio_Queue_PlayFirst);

	if(!radio_playing)
		return;

	if(autocvar_sv_radio_preload)
		Radio_SendPreload(player, radio_url);
	defer(player, 3, Radio_ClientConnect_Delayed);
}

// handle the command as a separate mutator, so it's always checked
REGISTER_MUTATOR(radio_cmd, true);

MUTATOR_HOOKFUNCTION(radio_cmd, SV_ParseClientCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return;

	entity caller = M_ARGV(0, entity);
	string cmd_name = M_ARGV(1, string);

	if(cmd_name == "radio")
	{
		if(!caller.scorekeeper)
			return true;

		if(!sv_radio)
		{
			sprint(caller, "Radio is not enabled\n");
			return true;
		}

		bool o = caller.radio_enabled;
		caller.radio_enabled = stof(argv(1));

		if(!o && caller.radio_enabled)
			Radio_SendPlay(caller);

		return true;
	}
}
