#define LATENCY_THINKRATE 10
.float latency_sum;
.float latency_cnt;
.float latency_time;
entity pingplreport;
void PingPLReport_Think()
{
	float delta;
	entity e;

	delta = 3 / maxclients;
	if(delta < sys_frametime)
		delta = 0;
	self.nextthink = time + delta;

	e = edict_num(self.cnt + 1);
	if(IS_REAL_CLIENT(e))
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_CSQC_PINGPLREPORT);
		WriteByte(MSG_BROADCAST, self.cnt);
		WriteShort(MSG_BROADCAST, max(1, e.ping));
		WriteByte(MSG_BROADCAST, ceil(e.ping_packetloss * 255));
		WriteByte(MSG_BROADCAST, ceil(e.ping_movementloss * 255));

		// record latency times for clients throughout the match so we can report it to playerstats
		if(time > (e.latency_time + LATENCY_THINKRATE))
		{
			e.latency_sum += e.ping;
			e.latency_cnt += 1;
			e.latency_time = time;
			//print("sum: ", ftos(e.latency_sum), ", cnt: ", ftos(e.latency_cnt), ", avg: ", ftos(e.latency_sum / e.latency_cnt), ".\n");
		}
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_CSQC_PINGPLREPORT);
		WriteByte(MSG_BROADCAST, self.cnt);
		WriteShort(MSG_BROADCAST, 0);
		WriteByte(MSG_BROADCAST, 0);
		WriteByte(MSG_BROADCAST, 0);
	}
	self.cnt = mod(self.cnt + 1, maxclients);
}
void PingPLReport_Spawn()
{
	pingplreport = spawn();
	pingplreport.classname = "pingplreport";
	pingplreport.think = PingPLReport_Think;
	pingplreport.nextthink = time;
}

const float SPAWNFLAG_NO_WAYPOINTS_FOR_ITEMS = 1;
string redirection_target;
float world_initialized;

string GetGametype();
void GotoNextMap(float reinit);
void ShuffleMaplist();
float(float reinit) DoNextMapOverride;

void SetDefaultAlpha()
{
	if(autocvar_g_running_guns)
	{
		default_player_alpha = -1;
		default_weapon_alpha = +1;
	}
	else if(g_cloaked)
	{
		default_player_alpha = autocvar_g_balance_cloaked_alpha;
		default_weapon_alpha = default_player_alpha;
	}
	else
	{
		default_player_alpha = autocvar_g_player_alpha;
		if(default_player_alpha == 0)
			default_player_alpha = 1;
		default_weapon_alpha = default_player_alpha;
	}
}

void fteqcc_testbugs()
{
	float a, b;

	if(!autocvar_developer_fteqccbugs)
		return;

	dprint("*** fteqcc test: checking for bugs...\n");

	a = 1;
	b = 5;
	if(sqrt(a) - sqrt(b - a) == 0)
		dprint("*** fteqcc test: found same-function-twice bug\n");
	else
		dprint("*** fteqcc test: same-function-twice bug got FINALLY FIXED! HOORAY!\n");

	world.cnt = -10;
	world.enemy = world;
	world.enemy.cnt += 10;
	if(world.cnt > 0.2 || world.cnt < -0.2) // don't error out if it's just roundoff errors
		dprint("*** fteqcc test: found += bug\n");
	else
		dprint("*** fteqcc test: += bug got FINALLY FIXED! HOORAY!\n");
	world.cnt = 0;
}

void GotoFirstMap()
{
	float n;
	if(autocvar__sv_init)
	{
		// cvar_set("_sv_init", "0");
		// we do NOT set this to 0 any more, so someone "accidentally" changing
		// to this "init" map on a dedicated server will cause no permanent
		// harm
		if(autocvar_g_maplist_shuffle)
			ShuffleMaplist();
		n = tokenizebyseparator(autocvar_g_maplist, " ");
		cvar_set("g_maplist_index", ftos(n - 1)); // jump to map 0 in GotoNextMap

		MapInfo_Enumerate();
		MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);

		if(!DoNextMapOverride(1))
			GotoNextMap(1);

		return;
	}

	if(time < 5)
	{
		self.nextthink = time;
	}
	else
	{
		self.nextthink = time + 1;
		print("Waiting for _sv_init being set to 1 by initialization scripts...\n");
	}
}

void cvar_changes_init()
{
	float h;
	string k, v, d;
	float n, i, adding, pureadding;

	if(cvar_changes)
		strunzone(cvar_changes);
	cvar_changes = string_null;
	if(cvar_purechanges)
		strunzone(cvar_purechanges);
	cvar_purechanges = string_null;
	cvar_purechanges_count = 0;

	h = buf_create();
	buf_cvarlist(h, "", "_"); // exclude all _ cvars as they are temporary
	n = buf_getsize(h);

	adding = TRUE;
	pureadding = TRUE;

	for(i = 0; i < n; ++i)
	{
		k = bufstr_get(h, i);

#define BADPREFIX(p) if(substring(k, 0, strlen(p)) == p) continue
#define BADPRESUFFIX(p,s) if(substring(k, 0, strlen(p)) == p && substring(k, -strlen(s), -1) == s) continue
#define BADCVAR(p) if(k == p) continue

		// general excludes and namespaces for server admin used cvars
		BADPREFIX("help_"); // PN's server has this listed as changed, let's not rat him out for THAT

		// internal
		BADPREFIX("csqc_");
		BADPREFIX("cvar_check_");
		BADCVAR("gamecfg");
		BADCVAR("g_configversion");
		BADCVAR("g_maplist_index");
		BADCVAR("halflifebsp");
		BADPREFIX("sv_world");

		// client
		BADPREFIX("chase_");
		BADPREFIX("cl_");
		BADPREFIX("con_");
		BADPREFIX("scoreboard_");
		BADPREFIX("g_campaign");
		BADPREFIX("g_waypointsprite_");
		BADPREFIX("gl_");
		BADPREFIX("joy");
		BADPREFIX("hud_");
		BADPREFIX("m_");
		BADPREFIX("menu_");
		BADPREFIX("net_slist_");
		BADPREFIX("r_");
		BADPREFIX("sbar_");
		BADPREFIX("scr_");
		BADPREFIX("snd_");
		BADPREFIX("show");
		BADPREFIX("sensitivity");
		BADPREFIX("userbind");
		BADPREFIX("v_");
		BADPREFIX("vid_");
		BADPREFIX("crosshair");
		BADCVAR("mod_q3bsp_lightmapmergepower");
		BADCVAR("mod_q3bsp_nolightmaps");
		BADCVAR("fov");
		BADCVAR("mastervolume");
		BADCVAR("volume");
		BADCVAR("bgmvolume");

		// private
		BADCVAR("developer");
		BADCVAR("log_dest_udp");
		BADCVAR("log_file");
		BADCVAR("net_address");
		BADCVAR("net_address_ipv6");
		BADCVAR("port");
		BADCVAR("savedgamecfg");
		BADCVAR("serverconfig");
		BADCVAR("sv_autoscreenshot");
		BADCVAR("sv_heartbeatperiod");
		BADCVAR("sv_vote_master_password");
		BADCVAR("sys_colortranslation");
		BADCVAR("sys_specialcharactertranslation");
		BADCVAR("timeformat");
		BADCVAR("timestamps");
		BADPREFIX("developer_");
		BADPREFIX("g_ban_");
		BADPREFIX("g_banned_list");
		BADPREFIX("g_chat_flood_");
		BADPREFIX("g_ghost_items");
		BADPREFIX("g_playerstats_");
		BADPREFIX("g_respawn_ghosts");
		BADPREFIX("g_voice_flood_");
		BADPREFIX("rcon_");
		BADPREFIX("sv_allowdownloads");
		BADPREFIX("sv_autodemo");
		BADPREFIX("sv_curl_");
		BADPREFIX("sv_eventlog");
		BADPREFIX("sv_logscores_");
		BADPREFIX("sv_master");
		BADPREFIX("sv_weaponstats_");
		BADPREFIX("sv_waypointsprite_");
		BADCVAR("rescan_pending");
		BADPREFIX("sv_allow_customplayermodels");

		// these can contain player IDs, so better hide
		BADPREFIX("g_forced_team_");

		// mapinfo
		BADCVAR("fraglimit");
		BADCVAR("g_arena");
		BADCVAR("g_assault");
		BADCVAR("g_ca");
		BADCVAR("g_ca_teams");
		BADCVAR("g_ctf");
		BADCVAR("g_cts");
		BADCVAR("g_dm");
		BADCVAR("g_domination");
		BADCVAR("g_domination_default_teams");
		BADCVAR("g_freezetag");
		BADCVAR("g_freezetag_teams");
		BADCVAR("g_keepaway");
		BADCVAR("g_keyhunt");
		BADCVAR("g_keyhunt_teams");
		BADCVAR("g_lms");
		BADCVAR("g_nexball");
		BADCVAR("g_onslaught");
		BADCVAR("g_race");
		BADCVAR("g_race_qualifying_timelimit");
		BADCVAR("g_tdm");
		BADCVAR("g_tdm_teams");
		BADCVAR("leadlimit");
		BADCVAR("nextmap");
		BADCVAR("teamplay");
		BADCVAR("timelimit");

		// long
		BADCVAR("hostname");
		BADCVAR("g_maplist");
		BADCVAR("g_maplist_mostrecent");
		BADCVAR("sv_motd");

		v = cvar_string(k);
		d = cvar_defstring(k);
		if(v == d)
			continue;

		if(adding)
		{
			cvar_changes = strcat(cvar_changes, k, " \"", v, "\" // \"", d, "\"\n");
			if(strlen(cvar_changes) > 16384)
			{
				cvar_changes = "// too many settings have been changed to show them here\n";
				adding = 0;
			}
		}

		// now check if the changes are actually gameplay relevant

		// does nothing visible
		BADCVAR("captureleadlimit_override");
		BADCVAR("g_arena_point_leadlimit");
		BADCVAR("g_balance_kill_delay");
		BADCVAR("g_ca_point_leadlimit");
		BADCVAR("g_ctf_captimerecord_always");
		BADCVAR("g_ctf_flag_glowtrails");
		BADCVAR("g_ctf_flag_pickup_verbosename");
		BADCVAR("g_domination_point_leadlimit");
		BADCVAR("g_forced_respawn");
		BADCVAR("g_keyhunt_point_leadlimit");
		BADPREFIX("g_mod_");
		BADCVAR("g_nexball_goalleadlimit");
		BADCVAR("leadlimit_and_fraglimit");
		BADCVAR("leadlimit_override");
		BADCVAR("pausable");
		BADCVAR("sv_allow_fullbright");
		BADCVAR("sv_checkforpacketsduringsleep");
		BADCVAR("sv_fraginfo");
		BADCVAR("sv_timeout");
		BADPREFIX("sv_timeout_");
		BADPREFIX("crypto_");
		BADPREFIX("g_chat_");
		BADPREFIX("g_ctf_captimerecord_");
		BADPREFIX("g_maplist_votable_");
		BADPREFIX("net_");
		BADPREFIX("prvm_");
		BADPREFIX("skill_");
		BADPREFIX("sv_cullentities_");
		BADPREFIX("sv_fraginfo_");
		BADPREFIX("sv_maxidle_");
		BADPREFIX("sv_vote_");
		BADPREFIX("timelimit_");
		BADCVAR("gameversion");
		BADPREFIX("gameversion_");
		BADCVAR("sv_namechangetimer");

		// allowed changes to server admins (please sync this to server.cfg)
		// vi commands:
		//   :/"impure"/,$d
		//   :g!,^\/\/[^ /],d
		//   :%s,//\([^ ]*\).*,BADCVAR("\1");,
		//   :%!sort
		// yes, this does contain some redundant stuff, don't really care
		BADCVAR("bot_config_file");
		BADCVAR("bot_number");
		BADCVAR("bot_prefix");
		BADCVAR("bot_suffix");
		BADCVAR("capturelimit_override");
		BADCVAR("fraglimit_override");
		BADCVAR("gametype");
		BADCVAR("g_antilag");
		BADCVAR("g_balance_teams");
		BADCVAR("g_balance_teams_prevent_imbalance");
		BADCVAR("g_balance_teams_scorefactor");
		BADCVAR("g_ban_sync_trusted_servers");
		BADCVAR("g_ban_sync_uri");
		BADCVAR("g_ca_teams_override");
		BADCVAR("g_ctf_ignore_frags");
		BADCVAR("g_domination_point_limit");
		BADCVAR("g_freezetag_teams_override");
		BADCVAR("g_friendlyfire");
		BADCVAR("g_fullbrightitems");
		BADCVAR("g_fullbrightplayers");
		BADCVAR("g_keyhunt_point_limit");
		BADCVAR("g_keyhunt_teams_override");
		BADCVAR("g_lms_lives_override");
		BADCVAR("g_maplist");
		BADCVAR("g_maplist_check_waypoints");
		BADCVAR("g_maplist_mostrecent_count");
		BADCVAR("g_maplist_shuffle");
		BADCVAR("g_maplist_votable");
		BADCVAR("g_maplist_votable_abstain");
		BADCVAR("g_maplist_votable_nodetail");
		BADCVAR("g_maplist_votable_suggestions");
		BADCVAR("g_maxplayers");
		BADCVAR("g_mirrordamage");
		BADCVAR("g_nexball_goallimit");
		BADCVAR("g_powerups");
		BADCVAR("g_start_delay");
		BADCVAR("g_warmup");
		BADCVAR("g_weapon_stay"); BADPRESUFFIX("g_", "_weapon_stay");
		BADCVAR("hostname");
		BADCVAR("log_file");
		BADCVAR("maxplayers");
		BADCVAR("minplayers");
		BADCVAR("net_address");
		BADCVAR("port");
		BADCVAR("rcon_password");
		BADCVAR("rcon_restricted_commands");
		BADCVAR("rcon_restricted_password");
		BADCVAR("skill");
		BADCVAR("sv_adminnick");
		BADCVAR("sv_autoscreenshot");
		BADCVAR("sv_autotaunt");
		BADCVAR("sv_curl_defaulturl");
		BADCVAR("sv_defaultcharacter");
		BADCVAR("sv_defaultplayercolors");
		BADCVAR("sv_defaultplayermodel");
		BADCVAR("sv_defaultplayerskin");
		BADCVAR("sv_maxidle");
		BADCVAR("sv_maxrate");
		BADCVAR("sv_motd");
		BADCVAR("sv_public");
		BADCVAR("sv_ready_restart");
		BADCVAR("sv_status_privacy");
		BADCVAR("sv_taunt");
		BADCVAR("sv_vote_call");
		BADCVAR("sv_vote_commands");
		BADCVAR("sv_vote_majority_factor");
		BADCVAR("sv_vote_master");
		BADCVAR("sv_vote_master_commands");
		BADCVAR("sv_vote_master_password");
		BADCVAR("sv_vote_simple_majority_factor");
		BADCVAR("teamplay_mode");
		BADCVAR("timelimit_override");
		BADCVAR("g_spawnshieldtime");
		BADPREFIX("g_warmup_");
		BADPREFIX("sv_ready_restart_");

		// mutators that announce themselves properly to the server browser
		BADCVAR("g_minstagib");
		BADCVAR("g_new_toys");
		BADCVAR("g_nix");
		BADCVAR("g_grappling_hook");
		BADCVAR("g_jetpack");

#undef BADPREFIX
#undef BADCVAR

		if(pureadding)
		{
			cvar_purechanges = strcat(cvar_purechanges, k, " \"", v, "\" // \"", d, "\"\n");
			if(strlen(cvar_purechanges) > 16384)
			{
				cvar_purechanges = "// too many settings have been changed to show them here\n";
				pureadding = 0;
			}
		}
		++cvar_purechanges_count;
		// WARNING: this variable is used for the server list
		// NEVER dare to skip this code!
		// Hacks to intentionally appearing as "pure server" even though you DO have
		// modified settings may be punished by removal from the server list.
		// You can do to the variables cvar_changes and cvar_purechanges all you want,
		// though.
	}
	buf_del(h);
	if(cvar_changes == "")
		cvar_changes = "// this server runs at default server settings\n";
	else
		cvar_changes = strcat("// this server runs at modified server settings:\n", cvar_changes);
	cvar_changes = strzone(cvar_changes);
	if(cvar_purechanges == "")
		cvar_purechanges = "// this server runs at default gameplay settings\n";
	else
		cvar_purechanges = strcat("// this server runs at modified gameplay settings:\n", cvar_purechanges);
	cvar_purechanges = strzone(cvar_purechanges);
}

void detect_maptype()
{
#if 0
	vector o, v;
	float i;

	for(;;)
	{
		o = world.mins;
		o_x += random() * (world.maxs_x - world.mins_x);
		o_y += random() * (world.maxs_y - world.mins_y);
		o_z += random() * (world.maxs_z - world.mins_z);

		tracebox(o, PL_MIN, PL_MAX, o - '0 0 32768', MOVE_WORLDONLY, world);
		if(trace_fraction == 1)
			continue;

		v = trace_endpos;

		for(i = 0; i < 64; i += 4)
		{
			tracebox(o, '-1 -1 -1' * i, '1 1 1' * i, o - '0 0 32768', MOVE_WORLDONLY, world);
	if(trace_fraction == 1)
		continue;
			print(ftos(i), " -> ", vtos(trace_endpos), "\n");
		}

		break;
	}
#endif
}

entity randomseed;
float RandomSeed_Send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_RANDOMSEED);
	WriteShort(MSG_ENTITY, self.cnt);
	return TRUE;
}
void RandomSeed_Think()
{
	self.cnt = bound(0, floor(random() * 65536), 65535);
	self.nextthink = time + 5;

	self.SendFlags |= 1;
}
void RandomSeed_Spawn()
{
	randomseed = spawn();
	randomseed.think = RandomSeed_Think;
	Net_LinkEntity(randomseed, FALSE, 0, RandomSeed_Send);

	entity oldself;
	oldself = self;
	self = randomseed;
	self.think(); // sets random seed and nextthink
	self = oldself;
}

void spawnfunc___init_dedicated_server(void)
{
	// handler for _init/_init map (only for dedicated server initialization)

	world_initialized = -1; // don't complain
	cvar = cvar_normal;
	cvar_string = cvar_string_normal;
	cvar_set = cvar_set_normal;

	remove = remove_unsafely;

	entity e;
	e = spawn();
	e.think = GotoFirstMap;
	e.nextthink = time; // this is usually 1 at this point

	e = spawn();
	e.classname = "info_player_deathmatch"; // safeguard against player joining

	self.classname = "worldspawn"; // safeguard against various stuff ;)

	// needs to be done so early because of the constants they create
	CALL_ACCUMULATED_FUNCTION(RegisterWeapons);
	CALL_ACCUMULATED_FUNCTION(RegisterMonsters);
	CALL_ACCUMULATED_FUNCTION(RegisterTurrets);
	CALL_ACCUMULATED_FUNCTION(RegisterVehicles);
	CALL_ACCUMULATED_FUNCTION(RegisterGametypes);
	CALL_ACCUMULATED_FUNCTION(RegisterNotifications);
	CALL_ACCUMULATED_FUNCTION(RegisterDeathtypes);

	MapInfo_Enumerate();
	MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);
}

void Map_MarkAsRecent(string m);
float world_already_spawned;
void Nagger_Init();
void ClientInit_Spawn();
void WeaponStats_Init();
void WeaponStats_Shutdown();
void spawnfunc_worldspawn (void)
{
	float fd, l, i, j, n;
	string s;

	cvar = cvar_normal;
	cvar_string = cvar_string_normal;
	cvar_set = cvar_set_normal;

	if(world_already_spawned)
		error("world already spawned - you may have EXACTLY ONE worldspawn!");
	world_already_spawned = TRUE;

	remove = remove_safely; // during spawning, watch what you remove!

	check_unacceptable_compiler_bugs();

	cvar_changes_init(); // do this very early now so it REALLY matches the server config

	compressShortVector_init();

	entity head;
	head = nextent(world);
	maxclients = 0;
	while(head)
	{
		++maxclients;
		head = nextent(head);
	}

	server_is_dedicated = (stof(cvar_defstring("is_dedicated")) ? TRUE : FALSE);

	// needs to be done so early because of the constants they create
	CALL_ACCUMULATED_FUNCTION(RegisterWeapons);
	CALL_ACCUMULATED_FUNCTION(RegisterMonsters);
	CALL_ACCUMULATED_FUNCTION(RegisterTurrets);
	CALL_ACCUMULATED_FUNCTION(RegisterVehicles);
	CALL_ACCUMULATED_FUNCTION(RegisterGametypes);
	CALL_ACCUMULATED_FUNCTION(RegisterNotifications);
	CALL_ACCUMULATED_FUNCTION(RegisterDeathtypes);

	ServerProgsDB = db_load(strcat("server.db", autocvar_sessionid));

	TemporaryDB = db_create();

	// 0 normal
	lightstyle(0, "m");

	// 1 FLICKER (first variety)
	lightstyle(1, "mmnmmommommnonmmonqnmmo");

	// 2 SLOW STRONG PULSE
	lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");

	// 3 CANDLE (first variety)
	lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");

	// 4 FAST STROBE
	lightstyle(4, "mamamamamama");

	// 5 GENTLE PULSE 1
	lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");

	// 6 FLICKER (second variety)
	lightstyle(6, "nmonqnmomnmomomno");

	// 7 CANDLE (second variety)
	lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");

	// 8 CANDLE (third variety)
	lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");

	// 9 SLOW STROBE (fourth variety)
	lightstyle(9, "aaaaaaaazzzzzzzz");

	// 10 FLUORESCENT FLICKER
	lightstyle(10, "mmamammmmammamamaaamammma");

	// 11 SLOW PULSE NOT FADE TO BLACK
	lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");

	// styles 32-62 are assigned by the spawnfunc_light program for switchable lights

	// 63 testing
	lightstyle(63, "a");

	if(autocvar_g_campaign)
		CampaignPreInit();

	Map_MarkAsRecent(mapname);

	PlayerStats_Init(); // we need this to be initiated before InitGameplayMode

	precache_model ("null"); // we need this one before InitGameplayMode
	InitGameplayMode();
	readlevelcvars();
	GrappleHookInit();
	ElectroInit();
	LaserInit();

	player_count = 0;
	bot_waypoints_for_items = autocvar_g_waypoints_for_items;
	if(bot_waypoints_for_items == 1)
		if(self.spawnflags & SPAWNFLAG_NO_WAYPOINTS_FOR_ITEMS)
			bot_waypoints_for_items = 0;

	precache();

	WaypointSprite_Init();

	GameLogInit(); // prepare everything
	// NOTE for matchid:
	// changing the logic generating it is okay. But:
	// it HAS to stay <= 64 chars
	// character set: ASCII 33-126 without the following characters: : ; ' " \ $
	if(autocvar_sv_eventlog)
	{
		s = sprintf("%d.%s.%06d", ftos(autocvar_sv_eventlog_files_counter), strftime(FALSE, "%s"), floor(random() * 1000000));
		matchid = strzone(s);

		GameLogEcho(strcat(":gamestart:", GetGametype(), "_", GetMapname(), ":", s));
		s = ":gameinfo:mutators:LIST";

		ret_string = s;
		MUTATOR_CALLHOOK(BuildMutatorsString);
		s = ret_string;

		// simple, probably not good in the mutator system
		if(autocvar_g_grappling_hook)
			s = strcat(s, ":grappling_hook");

		// initialiation stuff, not good in the mutator system
		if(!autocvar_g_use_ammunition)
			s = strcat(s, ":no_use_ammunition");

		// initialiation stuff, not good in the mutator system
		if(autocvar_g_pickup_items == 0)
			s = strcat(s, ":no_pickup_items");
		if(autocvar_g_pickup_items > 0)
			s = strcat(s, ":pickup_items");

		// initialiation stuff, not good in the mutator system
		if(autocvar_g_weaponarena != "0")
			s = strcat(s, ":", autocvar_g_weaponarena, " arena");

		// TODO to mutator system
		if(autocvar_g_norecoil)
			s = strcat(s, ":norecoil");

		// TODO to mutator system
		if(autocvar_g_powerups == 0)
			s = strcat(s, ":no_powerups");
		if(autocvar_g_powerups > 0)
			s = strcat(s, ":powerups");

		GameLogEcho(s);
		GameLogEcho(":gameinfo:end");
	}
	else
		matchid = strzone(ftos(random()));

	cvar_set("nextmap", "");

	SetDefaultAlpha();

	if(autocvar_g_campaign)
		CampaignPostInit();

	fteqcc_testbugs();

	Ban_LoadBans();

	MapInfo_Enumerate();
	MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 1);

	if(whichpack(strcat("maps/", mapname, ".cfg")) != "")
	{
		fd = fopen(strcat("maps/", mapname, ".cfg"), FILE_READ);
		if(fd != -1)
		{
			while((s = fgets(fd)))
			{
				l = tokenize_console(s);
				if(l < 2)
					continue;
				if(argv(0) == "cd")
				{
					print("Found ^1UNSUPPORTED^7 cd loop command in .cfg file; put this line in mapinfo instead:\n");
					print("  cdtrack ", argv(2), "\n");
				}
				else if(argv(0) == "fog")
				{
					print("Found ^1UNSUPPORTED^7 fog command in .cfg file; put this line in worldspawn in the .map/.bsp/.ent file instead:\n");
					print("  \"fog\" \"", s, "\"\n");
				}
				else if(argv(0) == "set")
				{
					print("Found ^1UNSUPPORTED^7 set command in .cfg file; put this line in mapinfo instead:\n");
					print("  clientsettemp_for_type all ", argv(1), " ", argv(2), "\n");
				}
				else if(argv(0) != "//")
				{
					print("Found ^1UNSUPPORTED^7 set command in .cfg file; put this line in mapinfo instead:\n");
					print("  clientsettemp_for_type all ", argv(0), " ", argv(1), "\n");
				}
			}
			fclose(fd);
		}
	}

	WeaponStats_Init();

	WepSet_AddStat();
	WepSet_AddStat_InMap();
	addstat(STAT_SWITCHWEAPON, AS_INT, switchweapon);
	addstat(STAT_SWITCHINGWEAPON, AS_INT, switchingweapon);
	addstat(STAT_GAMESTARTTIME, AS_FLOAT, stat_game_starttime);
	addstat(STAT_ROUNDSTARTTIME, AS_FLOAT, stat_round_starttime);
	addstat(STAT_ALLOW_OLDNEXBEAM, AS_INT, stat_allow_oldnexbeam);
	Nagger_Init();

	addstat(STAT_STRENGTH_FINISHED, AS_FLOAT, strength_finished);
	addstat(STAT_INVINCIBLE_FINISHED, AS_FLOAT, invincible_finished);
	addstat(STAT_SUPERWEAPONS_FINISHED, AS_FLOAT, superweapons_finished);
	addstat(STAT_PRESSED_KEYS, AS_FLOAT, pressedkeys);
	addstat(STAT_FUEL, AS_INT, ammo_fuel);
	addstat(STAT_SHOTORG, AS_INT, stat_shotorg);
	addstat(STAT_LEADLIMIT, AS_FLOAT, stat_leadlimit);
	addstat(STAT_WEAPON_CLIPLOAD, AS_INT, clip_load);
	addstat(STAT_WEAPON_CLIPSIZE, AS_INT, clip_size);
	addstat(STAT_LAST_PICKUP, AS_FLOAT, last_pickup);
	addstat(STAT_HIT_TIME, AS_FLOAT, hit_time);
	addstat(STAT_TYPEHIT_TIME, AS_FLOAT, typehit_time);
	addstat(STAT_LAYED_MINES, AS_INT, minelayer_mines);

	addstat(STAT_NEX_CHARGE, AS_FLOAT, nex_charge);
	addstat(STAT_NEX_CHARGEPOOL, AS_FLOAT, nex_chargepool_ammo);

	addstat(STAT_HAGAR_LOAD, AS_INT, hagar_load);

	addstat(STAT_SUPERCELLS, AS_INT, ammo_supercells);

	// freeze attacks
	addstat(STAT_FROZEN, AS_INT, frozen);
	addstat(STAT_REVIVE_PROGRESS, AS_FLOAT, revive_progress);

	// g_movementspeed hack
	addstat(STAT_MOVEVARS_AIRSPEEDLIMIT_NONQW, AS_FLOAT, stat_sv_airspeedlimit_nonqw);
	addstat(STAT_MOVEVARS_MAXSPEED, AS_FLOAT, stat_sv_maxspeed);
	addstat(STAT_MOVEVARS_AIRACCEL_QW, AS_FLOAT, stat_sv_airaccel_qw);
	addstat(STAT_MOVEVARS_AIRSTRAFEACCEL_QW, AS_FLOAT, stat_sv_airstrafeaccel_qw);

	// secrets
	addstat(STAT_SECRETS_TOTAL, AS_FLOAT, stat_secrets_total);
	addstat(STAT_SECRETS_FOUND, AS_FLOAT, stat_secrets_found);

	// monsters
	addstat(STAT_MONSTERS_TOTAL, AS_FLOAT, stat_monsters_total);
	addstat(STAT_MONSTERS_KILLED, AS_FLOAT, stat_monsters_killed);

	// misc
	addstat(STAT_RESPAWN_TIME, AS_FLOAT, stat_respawn_time);

	addstat(STAT_GRENADE_BONUS, AS_FLOAT, bonus_nades);
	addstat(STAT_GRENADE_BONUS_TYPE, AS_INT, nade_type);
	addstat(STAT_GRENADE_BONUS_SCORE, AS_FLOAT, bonus_nade_score);

	next_pingtime = time + 5;

	detect_maptype();

	// set up information replies for clients and server to use
	maplist_reply = strzone(getmaplist());
	lsmaps_reply = strzone(getlsmaps());
	monsterlist_reply = strzone(getmonsterlist());
	for(i = 0; i < 10; ++i)
	{
		s = getrecords(i);
		if (s)
			records_reply[i] = strzone(s);
	}
	ladder_reply = strzone(getladder());
	rankings_reply = strzone(getrankings());

	// begin other init
	ClientInit_Spawn();
	RandomSeed_Spawn();
	PingPLReport_Spawn();

	CheatInit();

	localcmd("\n_sv_hook_gamestart ", GetGametype(), "\n");

	// fill sv_curl_serverpackages from .serverpackage files
	if(autocvar_sv_curl_serverpackages_auto)
	{
		s = "";
		n = tokenize_console(cvar_string("sv_curl_serverpackages"));
		for(i = 0; i < n; ++i)
			if(substring(argv(i), -18, -1) != "-serverpackage.txt")
			if(substring(argv(i), -14, -1) != ".serverpackage") // OLD legacy
				s = strcat(s, " ", argv(i));
		fd = search_begin("*-serverpackage.txt", TRUE, FALSE);
		if(fd >= 0)
		{
			j = search_getsize(fd);
			for(i = 0; i < j; ++i)
				s = strcat(s, " ", search_getfilename(fd, i));
			search_end(fd);
		}
		fd = search_begin("*.serverpackage", TRUE, FALSE);
		if(fd >= 0)
		{
			j = search_getsize(fd);
			for(i = 0; i < j; ++i)
				s = strcat(s, " ", search_getfilename(fd, i));
			search_end(fd);
		}
		cvar_set("sv_curl_serverpackages", substring(s, 1, -1));
	}

	// MOD AUTHORS: change this, and possibly remove a few of the blocks below to ignore certain changes
	modname = "Xonotic";
	// physics/balance/config changes that count as mod
	if(cvar_string("g_mod_physics") != cvar_defstring("g_mod_physics"))
		modname = cvar_string("g_mod_physics");
	if(cvar_string("g_mod_balance") != cvar_defstring("g_mod_balance"))
		modname = cvar_string("g_mod_balance");
	if(cvar_string("g_mod_config") != cvar_defstring("g_mod_config"))
		modname = cvar_string("g_mod_config");
	// extra mutators that deserve to count as mod
	MUTATOR_CALLHOOK(SetModname);

	// save it for later
	modname = strzone(modname);

	WinningConditionHelper(); // set worldstatus

	world_initialized = 1;
}

void spawnfunc_light (void)
{
	//makestatic (self); // Who the f___ did that?
	remove(self);
}

string GetGametype()
{
	return MapInfo_Type_ToString(MapInfo_LoadedGametype);
}

string getmapname_stored;
string GetMapname()
{
	return mapname;
}

float Map_Count, Map_Current;
string Map_Current_Name;

// NOTE: this now expects the map list to be already tokenized and the count in Map_Count
float GetMaplistPosition()
{
	float pos, idx;
	string map;

	map = GetMapname();
	idx = autocvar_g_maplist_index;

	if(idx >= 0)
		if(idx < Map_Count)
			if(map == argv(idx))
				return idx;

	for(pos = 0; pos < Map_Count; ++pos)
		if(map == argv(pos))
			return pos;

	// resume normal maplist rotation if current map is not in g_maplist
	return idx;
}

float MapHasRightSize(string map)
{
	float fh;
	if(currentbots || autocvar_bot_number || player_count < autocvar_minplayers)
	if(autocvar_g_maplist_check_waypoints)
	{
		dprint("checkwp "); dprint(map);
		if(!fexists(strcat("maps/", map, ".waypoints")))
		{
			dprint(": no waypoints\n");
			return FALSE;
		}
		dprint(": has waypoints\n");
	}

	// open map size restriction file
	dprint("opensize "); dprint(map);
	fh = fopen(strcat("maps/", map, ".sizes"), FILE_READ);
	if(fh >= 0)
	{
		float mapmin, mapmax;
		dprint(": ok, ");
		mapmin = stof(fgets(fh));
		mapmax = stof(fgets(fh));
		fclose(fh);
		if(player_count < mapmin)
		{
			dprint("not enough\n");
			return FALSE;
		}
		if(player_count > mapmax)
		{
			dprint("too many\n");
			return FALSE;
		}
		dprint("right size\n");
		return TRUE;
	}
	dprint(": not found\n");
	return TRUE;
}

string Map_Filename(float position)
{
	return strcat("maps/", argv(position), ".bsp");
}

string strwords(string s, float w)
{
	float endpos;
	for(endpos = 0; w && endpos >= 0; --w)
		endpos = strstrofs(s, " ", endpos + 1);
	if(endpos < 0)
		return s;
	else
		return substring(s, 0, endpos);
}

float strhasword(string s, string w)
{
	return strstrofs(strcat(" ", s, " "), strcat(" ", w, " "), 0) >= 0;
}

void Map_MarkAsRecent(string m)
{
	cvar_set("g_maplist_mostrecent", strwords(strcat(m, " ", autocvar_g_maplist_mostrecent), max(0, autocvar_g_maplist_mostrecent_count)));
}

float Map_IsRecent(string m)
{
	return strhasword(autocvar_g_maplist_mostrecent, m);
}

float Map_Check(float position, float pass)
{
	string filename;
	string map_next;
	map_next = argv(position);
	if(pass <= 1)
	{
		if(Map_IsRecent(map_next))
			return 0;
	}
	filename = Map_Filename(position);
	if(MapInfo_CheckMap(map_next))
	{
		if(pass == 2)
			return 1;
		if(MapHasRightSize(map_next))
			return 1;
		return 0;
	}
	else
		dprint( "Couldn't select '", filename, "'..\n" );

	return 0;
}

void Map_Goto_SetStr(string nextmapname)
{
	if(getmapname_stored != "")
		strunzone(getmapname_stored);
	if(nextmapname == "")
		getmapname_stored = "";
	else
		getmapname_stored = strzone(nextmapname);
}

void Map_Goto_SetFloat(float position)
{
	cvar_set("g_maplist_index", ftos(position));
	Map_Goto_SetStr(argv(position));
}

void Map_Goto(float reinit)
{
	MapInfo_LoadMap(getmapname_stored, reinit);
}

// return codes of map selectors:
//   -1 = temporary failure (that is, try some method that is guaranteed to succeed)
//   -2 = permanent failure
float() MaplistMethod_Iterate = // usual method
{
	float pass, i;

	dprint("Trying MaplistMethod_Iterate\n");

	for(pass = 1; pass <= 2; ++pass)
	{
		for(i = 1; i < Map_Count; ++i)
		{
			float mapindex;
			mapindex = mod(i + Map_Current, Map_Count);
			if(Map_Check(mapindex, pass))
				return mapindex;
		}
	}
	return -1;
}

float() MaplistMethod_Repeat = // fallback method
{
	dprint("Trying MaplistMethod_Repeat\n");

	if(Map_Check(Map_Current, 2))
		return Map_Current;
	return -2;
}

float() MaplistMethod_Random = // random map selection
{
	float i, imax;

	dprint("Trying MaplistMethod_Random\n");

	imax = 42;

	for(i = 0; i <= imax; ++i)
	{
		float mapindex;
		mapindex = mod(Map_Current + floor(random() * (Map_Count - 1) + 1), Map_Count); // any OTHER map
		if(Map_Check(mapindex, 1))
			return mapindex;
	}
	return -1;
}

float(float exponent) MaplistMethod_Shuffle = // more clever shuffling
// the exponent sets a bias on the map selection:
// the higher the exponent, the less likely "shortly repeated" same maps are
{
	float i, j, imax, insertpos;

	dprint("Trying MaplistMethod_Shuffle\n");

	imax = 42;

	for(i = 0; i <= imax; ++i)
	{
		string newlist;

		// now reinsert this at another position
		insertpos = pow(random(), 1 / exponent);       // ]0, 1]
		insertpos = insertpos * (Map_Count - 1);       // ]0, Map_Count - 1]
		insertpos = ceil(insertpos) + 1;               // {2, 3, 4, ..., Map_Count}
		dprint("SHUFFLE: insert pos = ", ftos(insertpos), "\n");

		// insert the current map there
		newlist = "";
		for(j = 1; j < insertpos; ++j)                 // i == 1: no loop, will be inserted as first; however, i == 1 has been excluded above
			newlist = strcat(newlist, " ", argv(j));
		newlist = strcat(newlist, " ", argv(0));       // now insert the just selected map
		for(j = insertpos; j < Map_Count; ++j)         // i == Map_Count: no loop, has just been inserted as last
			newlist = strcat(newlist, " ", argv(j));
		newlist = substring(newlist, 1, strlen(newlist) - 1);
		cvar_set("g_maplist", newlist);
		Map_Count = tokenizebyseparator(autocvar_g_maplist, " ");

		// NOTE: the selected map has just been inserted at (insertpos-1)th position
		Map_Current = insertpos - 1; // this is not really valid, but this way the fallback has a chance of working
		if(Map_Check(Map_Current, 1))
			return Map_Current;
	}
	return -1;
}

void Maplist_Init()
{
	Map_Count = tokenizebyseparator(autocvar_g_maplist, " ");
	float i;
	for (i = 0; i < Map_Count; ++i)
		if (Map_Check(i, 2))
			break;
	if (i == Map_Count)
	{
		bprint( "Maplist contains no usable maps!  Resetting it to default map list.\n" );
		cvar_set("g_maplist", MapInfo_ListAllAllowedMaps(MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags() | MAPINFO_FLAG_NOAUTOMAPLIST));
		if(autocvar_g_maplist_shuffle)
			ShuffleMaplist();
		localcmd("\nmenu_cmd sync\n");
		Map_Count = tokenizebyseparator(autocvar_g_maplist, " ");
	}
	if(Map_Count == 0)
		error("empty maplist, cannot select a new map");
	Map_Current = bound(0, GetMaplistPosition(), Map_Count - 1);

	if(Map_Current_Name)
		strunzone(Map_Current_Name);
	Map_Current_Name = strzone(argv(Map_Current)); // will be automatically freed on exit thanks to DP
	// this may or may not be correct, but who cares, in the worst case a map
	// isn't chosen in the first pass that should have been
}

string GetNextMap()
{
	float nextMap;

	Maplist_Init();
	nextMap = -1;

	if(nextMap == -1)
		if(autocvar_g_maplist_shuffle > 0)
			nextMap = MaplistMethod_Shuffle(autocvar_g_maplist_shuffle + 1);

	if(nextMap == -1)
		if(autocvar_g_maplist_selectrandom)
			nextMap = MaplistMethod_Random();

	if(nextMap == -1)
		nextMap = MaplistMethod_Iterate();

	if(nextMap == -1)
		nextMap = MaplistMethod_Repeat();

	if(nextMap >= 0)
	{
		Map_Goto_SetFloat(nextMap);
		return getmapname_stored;
	}

	return "";
}

float DoNextMapOverride(float reinit)
{
	if(autocvar_g_campaign)
	{
		CampaignPostIntermission();
		alreadychangedlevel = TRUE;
		return TRUE;
	}
	if(autocvar_quit_when_empty)
	{
		if(player_count <= currentbots)
		{
			localcmd("quit\n");
			alreadychangedlevel = TRUE;
			return TRUE;
		}
	}
	if(autocvar_quit_and_redirect != "")
	{
		redirection_target = strzone(autocvar_quit_and_redirect);
		alreadychangedlevel = TRUE;
		return TRUE;
	}
	if (!reinit && autocvar_samelevel) // if samelevel is set, stay on same level
	{
		localcmd("restart\n");
		alreadychangedlevel = TRUE;
		return TRUE;
	}
	if(autocvar_nextmap != "")
		if(MapInfo_CheckMap(autocvar_nextmap))
		{
			Map_Goto_SetStr(autocvar_nextmap);
			Map_Goto(reinit);
			alreadychangedlevel = TRUE;
			return TRUE;
		}
	if(!reinit && autocvar_lastlevel)
	{
		cvar_settemp_restore();
		localcmd("set lastlevel 0\ntogglemenu 1\n");
		alreadychangedlevel = TRUE;
		return TRUE;
	}
	return FALSE;
}

void GotoNextMap(float reinit)
{
	//string nextmap;
	//float n, nummaps;
	//string s;
	if (alreadychangedlevel)
		return;
	alreadychangedlevel = TRUE;

	string nextMap;

	nextMap = GetNextMap();
	if(nextMap == "")
		error("Everything is broken - cannot find a next map. Please report this to the developers.");
	Map_Goto(reinit);
}


/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
.float autoscreenshot;
void() MapVote_Start;
void() MapVote_Think;
float mapvote_initialized;
void IntermissionThink()
{
	FixIntermissionClient(self);

	float server_screenshot = (autocvar_sv_autoscreenshot && self.cvar_cl_autoscreenshot);
	float client_screenshot = (self.cvar_cl_autoscreenshot == 2);

	if( (server_screenshot || client_screenshot)
		&& ((self.autoscreenshot > 0) && (time > self.autoscreenshot)) )
	{
		self.autoscreenshot = -1;
		if(IS_REAL_CLIENT(self)) { stuffcmd(self, sprintf("\nscreenshot screenshots/autoscreenshot/%s-%s.jpg; echo \"^5A screenshot has been taken at request of the server.\"\n", GetMapname(), strftime(FALSE, "%s"))); }
		return;
	}

	if (time < intermission_exittime)
		return;

	if(!mapvote_initialized)
		if (time < intermission_exittime + 10 && !(self.BUTTON_ATCK || self.BUTTON_JUMP || self.BUTTON_ATCK2 || self.BUTTON_HOOK || self.BUTTON_USE))
			return;

	MapVote_Start();
}

/*
============
FindIntermission

Returns the entity to view from
============
*/
/*
entity FindIntermission()
{
	local	entity spot;
	local	float cyc;

// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{	// pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;

// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

// then look for the start position
	spot = find (world, classname, "info_player_deathmatch");
	if (spot)
		return spot;

	//objerror ("FindIntermission: no spot");
	return world;
}
*/

/*
===============================================================================

RULES

===============================================================================
*/

void DumpStats(float final)
{
	float file;
	string s;
	float to_console;
	float to_eventlog;
	float to_file;
	float i;

	to_console = autocvar_sv_logscores_console;
	to_eventlog = autocvar_sv_eventlog;
	to_file = autocvar_sv_logscores_file;

	if(!final)
	{
		to_console = TRUE; // always print printstats replies
		to_eventlog = FALSE; // but never print them to the event log
	}

	if(to_eventlog)
		if(autocvar_sv_eventlog_console)
			to_console = FALSE; // otherwise we get the output twice

	if(final)
		s = ":scores:";
	else
		s = ":status:";
	s = strcat(s, GetGametype(), "_", GetMapname(), ":", ftos(rint(time)));

	if(to_console)
		print(s, "\n");
	if(to_eventlog)
		GameLogEcho(s);

	file = -1;
	if(to_file)
	{
		file = fopen(autocvar_sv_logscores_filename, FILE_APPEND);
		if(file == -1)
			to_file = FALSE;
		else
			fputs(file, strcat(s, "\n"));
	}

	s = strcat(":labels:player:", GetPlayerScoreString(world, 0));
	if(to_console)
		print(s, "\n");
	if(to_eventlog)
		GameLogEcho(s);
	if(to_file)
		fputs(file, strcat(s, "\n"));

	FOR_EACH_CLIENT(other)
	{
		if ((IS_REAL_CLIENT(other)) || (IS_BOT_CLIENT(other) && autocvar_sv_logscores_bots))
		{
			s = strcat(":player:see-labels:", GetPlayerScoreString(other, 0), ":");
			s = strcat(s, ftos(rint(time - other.jointime)), ":");
			if(IS_PLAYER(other) || g_arena || other.caplayer == 1 || g_lms)
				s = strcat(s, ftos(other.team), ":");
			else
				s = strcat(s, "spectator:");

			if(to_console)
				print(s, other.netname, "\n");
			if(to_eventlog)
				GameLogEcho(strcat(s, ftos(other.playerid), ":", other.netname));
			if(to_file)
				fputs(file, strcat(s, other.netname, "\n"));
		}
	}

	if(teamplay)
	{
		s = strcat(":labels:teamscores:", GetTeamScoreString(0, 0));
		if(to_console)
			print(s, "\n");
		if(to_eventlog)
			GameLogEcho(s);
		if(to_file)
			fputs(file, strcat(s, "\n"));

		for(i = 1; i < 16; ++i)
		{
			s = strcat(":teamscores:see-labels:", GetTeamScoreString(i, 0));
			s = strcat(s, ":", ftos(i));
			if(to_console)
				print(s, "\n");
			if(to_eventlog)
				GameLogEcho(s);
			if(to_file)
				fputs(file, strcat(s, "\n"));
		}
	}

	if(to_console)
		print(":end\n");
	if(to_eventlog)
		GameLogEcho(":end");
	if(to_file)
	{
		fputs(file, ":end\n");
		fclose(file);
	}
}

void FixIntermissionClient(entity e)
{
	string s;
	if(!e.autoscreenshot) // initial call
	{
		e.autoscreenshot = time + 0.8;	// used for autoscreenshot
		e.health = -2342;
		// first intermission phase; voting phase has positive health (used to decide whether to send SVC_FINALE or not)
		e.solid = SOLID_NOT;
		e.movetype = MOVETYPE_NONE;
		e.takedamage = DAMAGE_NO;
		if(e.weaponentity)
		{
			e.weaponentity.effects = EF_NODRAW;
			if (e.weaponentity.weaponentity)
				e.weaponentity.weaponentity.effects = EF_NODRAW;
		}
		if(IS_REAL_CLIENT(e))
		{
			stuffcmd(e, "\nscr_printspeed 1000000\n");
			s = autocvar_sv_intermission_cdtrack;
			if(s != "")
				stuffcmd(e, strcat("\ncd loop ", s, "\n"));
			msg_entity = e;
			WriteByte(MSG_ONE, SVC_INTERMISSION);
		}
	}
}

/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void NextLevel()
{
	gameover = TRUE;

	intermission_running = 1;

// enforce a wait time before allowing changelevel
	if(player_count > 0)
		intermission_exittime = time + autocvar_sv_mapchange_delay;
	else
		intermission_exittime = -1;

	/*
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);
	// done in FixIntermission
	*/

	//pos = FindIntermission ();

	VoteReset();

	DumpStats(TRUE);

	// send statistics
	entity e;
	PlayerStats_EndMatch(1);
	FOR_EACH_CLIENT(e)
		PlayerStats_AddGlobalInfo(e);
	PlayerStats_Shutdown();
	WeaponStats_Shutdown();

	Kill_Notification(NOTIF_ALL, world, MSG_CENTER, 0); // kill all centerprints now

	if(autocvar_sv_eventlog)
		GameLogEcho(":gameover");

	GameLogClose();

	FOR_EACH_PLAYER(other) {
		FixIntermissionClient(other);
		if(other.winning)
			bprint(other.netname, " ^7wins.\n");
	}

	if(autocvar_g_campaign)
		CampaignPreIntermission();

	MUTATOR_CALLHOOK(MatchEnd);

	localcmd("\nsv_hook_gameend\n");
}

/*
============
CheckRules_Player

Exit deathmatch games upon conditions
============
*/
void CheckRules_Player()
{
	if (gameover)	// someone else quit the game already
		return;

	if(self.deadflag == DEAD_NO)
		self.play_time += frametime;

	// fixme: don't check players; instead check spawnfunc_dom_team and spawnfunc_ctf_team entities
	//   (div0: and that in CheckRules_World please)
}

float checkrules_equality;
float checkrules_suddendeathwarning;
float checkrules_suddendeathend;
float checkrules_overtimesadded; //how many overtimes have been already added

const float WINNING_NO = 0; // no winner, but time limits may terminate the game
const float WINNING_YES = 1; // winner found
const float WINNING_NEVER = 2; // no winner, enter overtime if time limit is reached
const float WINNING_STARTSUDDENDEATHOVERTIME = 3; // no winner, enter suddendeath overtime NOW

float InitiateSuddenDeath()
{
	// Check first whether normal overtimes could be added before initiating suddendeath mode
	// - for this timelimit_overtime needs to be >0 of course
	// - also check the winning condition calculated in the previous frame and only add normal overtime
	//   again, if at the point at which timelimit would be extended again, still no winner was found
	if (!autocvar_g_campaign && (checkrules_overtimesadded >= 0) && (checkrules_overtimesadded < autocvar_timelimit_overtimes) && autocvar_timelimit_overtime && !(g_race && !g_race_qualifying))
	{
		return 1; // need to call InitiateOvertime later
	}
	else
	{
		if(!checkrules_suddendeathend)
		{
			if(autocvar_g_campaign)
				checkrules_suddendeathend = time; // no suddendeath in campaign
			else
				checkrules_suddendeathend = time + 60 * autocvar_timelimit_suddendeath;
			if(g_race && !g_race_qualifying)
				race_StartCompleting();
		}
		return 0;
	}
}

void InitiateOvertime() // ONLY call this if InitiateSuddenDeath returned true
{
	++checkrules_overtimesadded;
	//add one more overtime by simply extending the timelimit
	float tl;
	tl = autocvar_timelimit;
	tl += autocvar_timelimit_overtime;
	cvar_set("timelimit", ftos(tl));

	Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_OVERTIME_TIME, autocvar_timelimit_overtime * 60);
}

float GetWinningCode(float fraglimitreached, float equality)
{
	if(autocvar_g_campaign == 1)
		if(fraglimitreached)
			return WINNING_YES;
		else
			return WINNING_NO;

	else
		if(equality)
			if(fraglimitreached)
				return WINNING_STARTSUDDENDEATHOVERTIME;
			else
				return WINNING_NEVER;
		else
			if(fraglimitreached)
				return WINNING_YES;
			else
				return WINNING_NO;
}

// set the .winning flag for exactly those players with a given field value
void SetWinners(.float field, float value)
{
	entity head;
	FOR_EACH_PLAYER(head)
		head.winning = (head.field == value);
}

// set the .winning flag for those players with a given field value
void AddWinners(.float field, float value)
{
	entity head;
	FOR_EACH_PLAYER(head)
		if(head.field == value)
			head.winning = 1;
}

// clear the .winning flags
void ClearWinners(void)
{
	entity head;
	FOR_EACH_PLAYER(head)
		head.winning = 0;
}

// Onslaught winning condition:
// game terminates if only one team has a working generator (or none)
float WinningCondition_Onslaught()
{
	entity head;
	float t1, t2, t3, t4;

	WinningConditionHelper(); // set worldstatus

	if(warmup_stage)
		return WINNING_NO;

	// first check if the game has ended
	t1 = t2 = t3 = t4 = 0;
	head = find(world, classname, "onslaught_generator");
	while (head)
	{
		if (head.health > 0)
		{
			if (head.team == NUM_TEAM_1) t1 = 1;
			if (head.team == NUM_TEAM_2) t2 = 1;
			if (head.team == NUM_TEAM_3) t3 = 1;
			if (head.team == NUM_TEAM_4) t4 = 1;
		}
		head = find(head, classname, "onslaught_generator");
	}
	if (t1 + t2 + t3 + t4 < 2)
	{
		// game over, only one team remains (or none)
		ClearWinners();
		if (t1) SetWinners(team, NUM_TEAM_1);
		if (t2) SetWinners(team, NUM_TEAM_2);
		if (t3) SetWinners(team, NUM_TEAM_3);
		if (t4) SetWinners(team, NUM_TEAM_4);
		dprint("Have a winner, ending game.\n");
		return WINNING_YES;
	}

	// Two or more teams remain
	return WINNING_NO;
}

// Assault winning condition: If the attackers triggered a round end (by fulfilling all objectives)
// they win. Otherwise the defending team wins once the timelimit passes.
void assault_new_round();
float WinningCondition_Assault()
{
	float status;

	WinningConditionHelper(); // set worldstatus

	status = WINNING_NO;
	// as the timelimit has not yet passed just assume the defending team will win
	if(assault_attacker_team == NUM_TEAM_1)
	{
		SetWinners(team, NUM_TEAM_2);
	}
	else
	{
		SetWinners(team, NUM_TEAM_1);
	}

	entity ent;
	ent = find(world, classname, "target_assault_roundend");
	if(ent)
	{
		if(ent.winning)	// round end has been triggered by attacking team
		{
			bprint("ASSAULT: round completed...\n");
			SetWinners(team, assault_attacker_team);

			TeamScore_AddToTeam(assault_attacker_team, ST_ASSAULT_OBJECTIVES, 666 - TeamScore_AddToTeam(assault_attacker_team, ST_ASSAULT_OBJECTIVES, 0));

			if(ent.cnt == 1 || autocvar_g_campaign) // this was the second round
			{
				status = WINNING_YES;
			}
			else
			{
				entity oldself;
				oldself = self;
				self = ent;
				assault_new_round();
				self = oldself;
			}
		}
	}

	return status;
}

// LMS winning condition: game terminates if and only if there's at most one
// one player who's living lives. Top two scores being equal cancels the time
// limit.
float WinningCondition_LMS()
{
	entity head, head2;
	float have_player;
	float have_players;
	float l;

	have_player = FALSE;
	have_players = FALSE;
	l = LMS_NewPlayerLives();

	head = find(world, classname, "player");
	if(head)
		have_player = TRUE;
	head2 = find(head, classname, "player");
	if(head2)
		have_players = TRUE;

	if(have_player)
	{
		// we have at least one player
		if(have_players)
		{
			// two or more active players - continue with the game
		}
		else
		{
			// exactly one player?

			ClearWinners();
			SetWinners(winning, 0); // NOTE: exactly one player is still "player", so this works out

			if(l)
			{
				// game still running (that is, nobody got removed from the game by a frag yet)? then continue
				return WINNING_NO;
			}
			else
			{
				// a winner!
				// and assign him his first place
				PlayerScore_Add(head, SP_LMS_RANK, 1);
				return WINNING_YES;
			}
		}
	}
	else
	{
		// nobody is playing at all...
		if(l)
		{
			// wait for players...
		}
		else
		{
			// SNAFU (maybe a draw game?)
			ClearWinners();
			dprint("No players, ending game.\n");
			return WINNING_YES;
		}
	}

	// When we get here, we have at least two players who are actually LIVING,
	// now check if the top two players have equal score.
	WinningConditionHelper();

	ClearWinners();
	if(WinningConditionHelper_winner)
		WinningConditionHelper_winner.winning = TRUE;
	if(WinningConditionHelper_topscore == WinningConditionHelper_secondscore)
		return WINNING_NEVER;

	// Top two have different scores? Way to go for our beloved TIMELIMIT!
	return WINNING_NO;
}

void ShuffleMaplist()
{
	cvar_set("g_maplist", shufflewords(autocvar_g_maplist));
}

float leaderfrags;
float WinningCondition_Scores(float limit, float leadlimit)
{
	float limitreached;

	// TODO make everything use THIS winning condition (except LMS)
	WinningConditionHelper();

	if(teamplay)
	{
		team1_score = TeamScore_GetCompareValue(NUM_TEAM_1);
		team2_score = TeamScore_GetCompareValue(NUM_TEAM_2);
		team3_score = TeamScore_GetCompareValue(NUM_TEAM_3);
		team4_score = TeamScore_GetCompareValue(NUM_TEAM_4);
	}

	ClearWinners();
	if(WinningConditionHelper_winner)
		WinningConditionHelper_winner.winning = 1;
	if(WinningConditionHelper_winnerteam >= 0)
		SetWinners(team, WinningConditionHelper_winnerteam);

	if(WinningConditionHelper_lowerisbetter)
	{
		WinningConditionHelper_topscore = -WinningConditionHelper_topscore;
		WinningConditionHelper_secondscore = -WinningConditionHelper_secondscore;
		limit = -limit;
	}

	if(WinningConditionHelper_zeroisworst)
		leadlimit = 0; // not supported in this mode

	if(g_dm || g_tdm || g_arena || g_ca || (g_race && !g_race_qualifying) || g_nexball)
	// these modes always score in increments of 1, thus this makes sense
	{
		if(leaderfrags != WinningConditionHelper_topscore)
		{
			leaderfrags = WinningConditionHelper_topscore;

			if (limit)
			if (leaderfrags == limit - 1)
				Send_Notification(NOTIF_ALL, world, MSG_ANNCE, ANNCE_REMAINING_FRAG_1);
			else if (leaderfrags == limit - 2)
				Send_Notification(NOTIF_ALL, world, MSG_ANNCE, ANNCE_REMAINING_FRAG_2);
			else if (leaderfrags == limit - 3)
				Send_Notification(NOTIF_ALL, world, MSG_ANNCE, ANNCE_REMAINING_FRAG_3);
		}
	}

	limitreached = FALSE;
	if(limit)
		if(WinningConditionHelper_topscore >= limit)
			limitreached = TRUE;
	if(leadlimit)
	{
		float leadlimitreached;
		leadlimitreached = (WinningConditionHelper_topscore - WinningConditionHelper_secondscore >= leadlimit);
		if(autocvar_leadlimit_and_fraglimit)
			limitreached = (limitreached && leadlimitreached);
		else
			limitreached = (limitreached || leadlimitreached);
	}

	if(limit)
		game_completion_ratio = max(game_completion_ratio, bound(0, WinningConditionHelper_topscore / limit, 1));

	return GetWinningCode(
		WinningConditionHelper_topscore && limitreached,
		WinningConditionHelper_equality
	);
}

float WinningCondition_Race(float fraglimit)
{
	float wc;
	entity p;
	float n, c;

	n = 0;
	c = 0;
	FOR_EACH_PLAYER(p)
	{
		++n;
		if(p.race_completed)
			++c;
	}
	if(n && (n == c))
		return WINNING_YES;
	wc = WinningCondition_Scores(fraglimit, 0);

	// ALWAYS initiate overtime, unless EVERYONE has finished the race!
	if(wc == WINNING_YES || wc == WINNING_STARTSUDDENDEATHOVERTIME)
	// do NOT support equality when the laps are all raced!
		return WINNING_STARTSUDDENDEATHOVERTIME;
	else
		return WINNING_NEVER;
}

float WinningCondition_QualifyingThenRace(float limit)
{
	float wc;
	wc = WinningCondition_Scores(limit, 0);

	// NEVER initiate overtime
	if(wc == WINNING_YES || wc == WINNING_STARTSUDDENDEATHOVERTIME)
	{
		return WINNING_YES;
	}

	return wc;
}

float WinningCondition_RanOutOfSpawns()
{
	entity head;

	if(have_team_spawns <= 0)
		return WINNING_NO;

	if(autocvar_g_spawn_useallspawns <= 0)
		return WINNING_NO;

	if(!some_spawn_has_been_used)
		return WINNING_NO;

	team1_score = team2_score = team3_score = team4_score = 0;

	FOR_EACH_PLAYER(head) if(head.deadflag == DEAD_NO)
	{
		if(head.team == NUM_TEAM_1)
			team1_score = 1;
		else if(head.team == NUM_TEAM_2)
			team2_score = 1;
		else if(head.team == NUM_TEAM_3)
			team3_score = 1;
		else if(head.team == NUM_TEAM_4)
			team4_score = 1;
	}

	for(head = world; (head = find(head, classname, "info_player_deathmatch")) != world; )
	{
		if(head.team == NUM_TEAM_1)
			team1_score = 1;
		else if(head.team == NUM_TEAM_2)
			team2_score = 1;
		else if(head.team == NUM_TEAM_3)
			team3_score = 1;
		else if(head.team == NUM_TEAM_4)
			team4_score = 1;
	}

	ClearWinners();
	if(team1_score + team2_score + team3_score + team4_score == 0)
	{
		checkrules_equality = TRUE;
		return WINNING_YES;
	}
	else if(team1_score + team2_score + team3_score + team4_score == 1)
	{
		float t, i;
		if(team1_score)
			t = NUM_TEAM_1;
		else if(team2_score)
			t = NUM_TEAM_2;
		else if(team3_score)
			t = NUM_TEAM_3;
		else // if(team4_score)
			t = NUM_TEAM_4;
		CheckAllowedTeams(world);
		for(i = 0; i < MAX_TEAMSCORE; ++i)
		{
			if(t != NUM_TEAM_1) if(c1 >= 0) TeamScore_AddToTeam(NUM_TEAM_1, i, -1000);
			if(t != NUM_TEAM_2) if(c2 >= 0) TeamScore_AddToTeam(NUM_TEAM_2, i, -1000);
			if(t != NUM_TEAM_3) if(c3 >= 0) TeamScore_AddToTeam(NUM_TEAM_3, i, -1000);
			if(t != NUM_TEAM_4) if(c4 >= 0) TeamScore_AddToTeam(NUM_TEAM_4, i, -1000);
		}

		AddWinners(team, t);
		return WINNING_YES;
	}
	else
		return WINNING_NO;
}

/*
============
CheckRules_World

Exit deathmatch games upon conditions
============
*/
void ReadyRestart();
void CheckRules_World()
{
	float timelimit;
	float fraglimit;
	float leadlimit;

	VoteThink();
	MapVote_Think();

	SetDefaultAlpha();

	/*
	MapVote_Think should now do that part
	if (intermission_running)
		if (time >= intermission_exittime + 60)
		{
			if(!DoNextMapOverride())
				GotoNextMap();
			return;
		}
	*/

	if (gameover)	// someone else quit the game already
	{
		if(player_count == 0) // Nobody there? Then let's go to the next map
			MapVote_Start();
			// this will actually check the player count in the next frame
			// again, but this shouldn't hurt
		return;
	}

	timelimit = autocvar_timelimit * 60;
	fraglimit = autocvar_fraglimit;
	leadlimit = autocvar_leadlimit;

	if(warmup_stage || time <= game_starttime) // NOTE: this is <= to prevent problems in the very tic where the game starts
	{
		if(timelimit > 0)
			timelimit = 0; // timelimit is not made for warmup
		if(fraglimit > 0)
			fraglimit = 0; // no fraglimit for now
		leadlimit = 0; // no leadlimit for now
	}

	if(timelimit > 0)
	{
		timelimit += game_starttime;
	}
	else if (timelimit < 0)
	{
		// endmatch
		NextLevel();
		return;
	}

	if(g_onslaught)
		timelimit = 0; // ONS has its own overtime rule

	float wantovertime;
	wantovertime = 0;

	if(timelimit > game_starttime)
		game_completion_ratio = (time - game_starttime) / (timelimit - game_starttime);
	else
		game_completion_ratio = 0;

	if(checkrules_suddendeathend)
	{
		if(!checkrules_suddendeathwarning)
		{
			checkrules_suddendeathwarning = TRUE;
			if(g_race && !g_race_qualifying)
				Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_RACE_FINISHLAP);
			else
				Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_OVERTIME_FRAG);
		}
	}
	else
	{
		if (timelimit && time >= timelimit)
		{
			if(g_race && (g_race_qualifying == 2) && timelimit > 0)
			{
				float totalplayers;
				float playerswithlaps;
				float readyplayers;
				entity head;
				totalplayers = playerswithlaps = readyplayers = 0;
				FOR_EACH_PLAYER(head)
				{
					++totalplayers;
					if(PlayerScore_Add(head, SP_RACE_FASTEST, 0))
						++playerswithlaps;
					if(head.ready)
						++readyplayers;
				}

				// at least 2 of the players have completed a lap: start the RACE
				// otherwise, the players should end the qualifying on their own
				if(readyplayers || playerswithlaps >= 2)
				{
					checkrules_suddendeathend = 0;
					ReadyRestart(); // go to race
					return;
				}
				else
					wantovertime |= InitiateSuddenDeath();
			}
			else
				wantovertime |= InitiateSuddenDeath();
		}
	}

	if (checkrules_suddendeathend && time >= checkrules_suddendeathend)
	{
		NextLevel();
		return;
	}

	float checkrules_status;
	checkrules_status = WinningCondition_RanOutOfSpawns();
	if(checkrules_status == WINNING_YES)
	{
		bprint("Hey! Someone ran out of spawns!\n");
	}
	else if(g_race && !g_race_qualifying && timelimit >= 0)
	{
		checkrules_status = WinningCondition_Race(fraglimit);
		//print("WC_RACE yields ", ftos(checkrules_status), "\n");
	}
	else if(g_race && g_race_qualifying == 2 && timelimit >= 0)
	{
		checkrules_status = WinningCondition_QualifyingThenRace(fraglimit);
		//print("WC_QUALIFYING_THEN_RACE yields ", ftos(checkrules_status), "\n");
	}
	else if(g_assault)
	{
		checkrules_status = WinningCondition_Assault(); // TODO remove this?
	}
	else if(g_lms)
	{
		checkrules_status = WinningCondition_LMS();
	}
	else if (g_onslaught)
	{
		checkrules_status = WinningCondition_Onslaught(); // TODO remove this?
	}
	else
	{
		checkrules_status = WinningCondition_Scores(fraglimit, leadlimit);
		//print("WC_SCORES yields ", ftos(checkrules_status), "\n");
	}

	if(checkrules_status == WINNING_STARTSUDDENDEATHOVERTIME)
	{
		checkrules_status = WINNING_NEVER;
		checkrules_overtimesadded = -1;
		wantovertime |= InitiateSuddenDeath();
	}

	if(checkrules_status == WINNING_NEVER)
		// equality cases! Nobody wins if the overtime ends in a draw.
		ClearWinners();

	if(wantovertime)
	{
		if(checkrules_status == WINNING_NEVER)
			InitiateOvertime();
		else
			checkrules_status = WINNING_YES;
	}

	if(checkrules_suddendeathend)
		if(checkrules_status != WINNING_NEVER || time >= checkrules_suddendeathend)
			checkrules_status = WINNING_YES;

	if(checkrules_status == WINNING_YES)
	{
		//print("WINNING\n");
		NextLevel();
	}
}

float mapvote_nextthink;
float mapvote_initialized;
float mapvote_keeptwotime;
float mapvote_timeout;
string mapvote_message;
#define MAPVOTE_SCREENSHOT_DIRS_COUNT 4
string mapvote_screenshot_dirs[MAPVOTE_SCREENSHOT_DIRS_COUNT];
float mapvote_screenshot_dirs_count;

float mapvote_count;
float mapvote_count_real;
string mapvote_maps[MAPVOTE_COUNT];
float mapvote_maps_screenshot_dir[MAPVOTE_COUNT];
string mapvote_maps_pakfile[MAPVOTE_COUNT];
float mapvote_maps_suggested[MAPVOTE_COUNT];
string mapvote_suggestions[MAPVOTE_COUNT];
float mapvote_suggestion_ptr;
float mapvote_voters;
float mapvote_selections[MAPVOTE_COUNT];
float mapvote_run;
float mapvote_detail;
float mapvote_abstain;
.float mapvote;

void MapVote_ClearAllVotes()
{
	FOR_EACH_CLIENT(other)
		other.mapvote = 0;
}

string MapVote_Suggest(string m)
{
	float i;
	if(m == "")
		return "That's not how to use this command.";
	if(!autocvar_g_maplist_votable_suggestions)
		return "Suggestions are not accepted on this server.";
	if(mapvote_initialized)
		return "Can't suggest - voting is already in progress!";
	m = MapInfo_FixName(m);
	if (!m)
		return "The map you suggested is not available on this server.";
	if(!autocvar_g_maplist_votable_suggestions_override_mostrecent)
		if(Map_IsRecent(m))
			return "This server does not allow for recent maps to be played again. Please be patient for some rounds.";

	if(!MapInfo_CheckMap(m))
		return "The map you suggested does not support the current game mode.";
	for(i = 0; i < mapvote_suggestion_ptr; ++i)
		if(mapvote_suggestions[i] == m)
			return "This map was already suggested.";
	if(mapvote_suggestion_ptr >= MAPVOTE_COUNT)
	{
		i = floor(random() * mapvote_suggestion_ptr);
	}
	else
	{
		i = mapvote_suggestion_ptr;
		mapvote_suggestion_ptr += 1;
	}
	if(mapvote_suggestions[i] != "")
		strunzone(mapvote_suggestions[i]);
	mapvote_suggestions[i] = strzone(m);
	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":vote:suggested:", m, ":", ftos(self.playerid)));
	return strcat("Suggestion of ", m, " accepted.");
}

void MapVote_AddVotable(string nextMap, float isSuggestion)
{
	float j, i, o;
	string pakfile, mapfile;

	if(nextMap == "")
		return;
	for(j = 0; j < mapvote_count; ++j)
		if(mapvote_maps[j] == nextMap)
			return;
	// suggestions might be no longer valid/allowed after gametype switch!
	if(isSuggestion)
		if(!MapInfo_CheckMap(nextMap))
			return;
	mapvote_maps[mapvote_count] = strzone(nextMap);
	mapvote_maps_suggested[mapvote_count] = isSuggestion;

	pakfile = string_null;
	for(i = 0; i < mapvote_screenshot_dirs_count; ++i)
	{
		mapfile = strcat(mapvote_screenshot_dirs[i], "/", mapvote_maps[i]);
		pakfile = whichpack(strcat(mapfile, ".tga"));
		if(pakfile == "")
			pakfile = whichpack(strcat(mapfile, ".jpg"));
		if(pakfile == "")
			pakfile = whichpack(strcat(mapfile, ".png"));
		if(pakfile != "")
			break;
	}
	if(i >= mapvote_screenshot_dirs_count)
		i = 0; // FIXME maybe network this error case, as that means there is no mapshot on the server?
	for(o = strstr(pakfile, "/", 0)+1; o > 0; o = strstr(pakfile, "/", 0)+1)
		pakfile = substring(pakfile, o, -1);

	mapvote_maps_screenshot_dir[mapvote_count] = i;
	mapvote_maps_pakfile[mapvote_count] = strzone(pakfile);

	mapvote_count += 1;
}

void MapVote_Spawn();
void MapVote_Init()
{
	float i;
	float nmax, smax;

	MapVote_ClearAllVotes();

	mapvote_count = 0;
	mapvote_detail = !autocvar_g_maplist_votable_nodetail;
	mapvote_abstain = autocvar_g_maplist_votable_abstain;

	if(mapvote_abstain)
		nmax = min(MAPVOTE_COUNT - 1, autocvar_g_maplist_votable);
	else
		nmax = min(MAPVOTE_COUNT, autocvar_g_maplist_votable);
	smax = min3(nmax, autocvar_g_maplist_votable_suggestions, mapvote_suggestion_ptr);

	// we need this for AddVotable, as that cycles through the screenshot dirs
	mapvote_screenshot_dirs_count = tokenize_console(autocvar_g_maplist_votable_screenshot_dir);
	if(mapvote_screenshot_dirs_count == 0)
		mapvote_screenshot_dirs_count = tokenize_console("maps levelshots");
	mapvote_screenshot_dirs_count = min(mapvote_screenshot_dirs_count, MAPVOTE_SCREENSHOT_DIRS_COUNT);
	for(i = 0; i < mapvote_screenshot_dirs_count; ++i)
		mapvote_screenshot_dirs[i] = strzone(argv(i));

	if(mapvote_suggestion_ptr)
		for(i = 0; i < 100 && mapvote_count < smax; ++i)
			MapVote_AddVotable(mapvote_suggestions[floor(random() * mapvote_suggestion_ptr)], TRUE);

	for(i = 0; i < 100 && mapvote_count < nmax; ++i)
		MapVote_AddVotable(GetNextMap(), FALSE);

	if(mapvote_count == 0)
	{
		bprint( "Maplist contains no single playable map!  Resetting it to default map list.\n" );
		cvar_set("g_maplist", MapInfo_ListAllAllowedMaps(MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags()));
		if(autocvar_g_maplist_shuffle)
			ShuffleMaplist();
		localcmd("\nmenu_cmd sync\n");
		for(i = 0; i < 100 && mapvote_count < nmax; ++i)
			MapVote_AddVotable(GetNextMap(), FALSE);
	}

	mapvote_count_real = mapvote_count;
	if(mapvote_abstain)
		MapVote_AddVotable("don't care", 0);

	//dprint("mapvote count is ", ftos(mapvote_count), "\n");

	mapvote_keeptwotime = time + autocvar_g_maplist_votable_keeptwotime;
	mapvote_timeout = time + autocvar_g_maplist_votable_timeout;
	if(mapvote_count_real < 3 || mapvote_keeptwotime <= time)
		mapvote_keeptwotime = 0;
	mapvote_message = "Choose a map and press its key!";

	MapVote_Spawn();
}

void MapVote_SendPicture(float id)
{
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_PICTURE);
	WriteByte(MSG_ONE, id);
	WritePicture(MSG_ONE, strcat(mapvote_screenshot_dirs[mapvote_maps_screenshot_dir[id]], "/", mapvote_maps[id]), 3072);
}

float MapVote_GetMapMask()
{
	float mask, i, power;
	mask = 0;
	for(i = 0, power = 1; i < mapvote_count; ++i, power *= 2)
		if(mapvote_maps[i] != "")
			mask |= power;
	return mask;
}

entity mapvote_ent;
float MapVote_SendEntity(entity to, float sf)
{
	float i;

	if(sf & 1)
		sf &= ~2; // if we send 1, we don't need to also send 2

	WriteByte(MSG_ENTITY, ENT_CLIENT_MAPVOTE);
	WriteByte(MSG_ENTITY, sf);

	if(sf & 1)
	{
		// flag 1 == initialization
		for(i = 0; i < mapvote_screenshot_dirs_count; ++i)
			WriteString(MSG_ENTITY, mapvote_screenshot_dirs[i]);
		WriteString(MSG_ENTITY, "");
		WriteByte(MSG_ENTITY, mapvote_count);
		WriteByte(MSG_ENTITY, mapvote_abstain);
		WriteByte(MSG_ENTITY, mapvote_detail);
		WriteCoord(MSG_ENTITY, mapvote_timeout);
		if(mapvote_count <= 8)
			WriteByte(MSG_ENTITY, MapVote_GetMapMask());
		else
			WriteShort(MSG_ENTITY, MapVote_GetMapMask());
		for(i = 0; i < mapvote_count; ++i)
			if(mapvote_maps[i] != "")
			{
				if(mapvote_abstain && i == mapvote_count - 1)
				{
					WriteString(MSG_ENTITY, ""); // abstain needs no text
					WriteString(MSG_ENTITY, ""); // abstain needs no pack
					WriteByte(MSG_ENTITY, 0); // abstain needs no screenshot dir
				}
				else
				{
					WriteString(MSG_ENTITY, mapvote_maps[i]);
					WriteString(MSG_ENTITY, mapvote_maps_pakfile[i]);
					WriteByte(MSG_ENTITY, mapvote_maps_screenshot_dir[i]);
				}
			}
	}

	if(sf & 2)
	{
		// flag 2 == update of mask
		if(mapvote_count <= 8)
			WriteByte(MSG_ENTITY, MapVote_GetMapMask());
		else
			WriteShort(MSG_ENTITY, MapVote_GetMapMask());
	}

	if(sf & 4)
	{
		if(mapvote_detail)
			for(i = 0; i < mapvote_count; ++i)
				if(mapvote_maps[i] != "")
					WriteByte(MSG_ENTITY, mapvote_selections[i]);

		WriteByte(MSG_ENTITY, to.mapvote);
	}

	return TRUE;
}

void MapVote_Spawn()
{
	Net_LinkEntity(mapvote_ent = spawn(), FALSE, 0, MapVote_SendEntity);
}

void MapVote_TouchMask()
{
	mapvote_ent.SendFlags |= 2;
}

void MapVote_TouchVotes(entity voter)
{
	mapvote_ent.SendFlags |= 4;
}

float MapVote_Finished(float mappos)
{
	string result;
	float i;
	float didntvote;

	if(autocvar_sv_eventlog)
	{
		result = strcat(":vote:finished:", mapvote_maps[mappos]);
		result = strcat(result, ":", ftos(mapvote_selections[mappos]), "::");
		didntvote = mapvote_voters;
		for(i = 0; i < mapvote_count; ++i)
			if(mapvote_maps[i] != "")
			{
				didntvote -= mapvote_selections[i];
				if(i != mappos)
				{
					result = strcat(result, ":", mapvote_maps[i]);
					result = strcat(result, ":", ftos(mapvote_selections[i]));
				}
			}
		result = strcat(result, ":didn't vote:", ftos(didntvote));

		GameLogEcho(result);
		if(mapvote_maps_suggested[mappos])
			GameLogEcho(strcat(":vote:suggestion_accepted:", mapvote_maps[mappos]));
	}

	FOR_EACH_REALCLIENT(other)
		FixClientCvars(other);

	Map_Goto_SetStr(mapvote_maps[mappos]);
	Map_Goto(0);
	alreadychangedlevel = TRUE;
	return TRUE;
}
void MapVote_CheckRules_1()
{
	float i;

	for(i = 0; i < mapvote_count; ++i) if(mapvote_maps[i] != "")
	{
		//dprint("Map ", ftos(i), ": "); dprint(mapvote_maps[i], "\n");
		mapvote_selections[i] = 0;
	}

	mapvote_voters = 0;
	FOR_EACH_REALCLIENT(other)
	{
		++mapvote_voters;
		if(other.mapvote)
		{
			i = other.mapvote - 1;
			//dprint("Player ", other.netname, " vote = ", ftos(other.mapvote - 1), "\n");
			mapvote_selections[i] = mapvote_selections[i] + 1;
		}
	}
}

float MapVote_CheckRules_2()
{
	float i;
	float firstPlace, secondPlace;
	float firstPlaceVotes, secondPlaceVotes;
	float mapvote_voters_real;
	string result;

	if(mapvote_count_real == 1)
		return MapVote_Finished(0);

	mapvote_voters_real = mapvote_voters;
	if(mapvote_abstain)
		mapvote_voters_real -= mapvote_selections[mapvote_count - 1];

	RandomSelection_Init();
	for(i = 0; i < mapvote_count_real; ++i) if(mapvote_maps[i] != "")
		RandomSelection_Add(world, i, string_null, 1, mapvote_selections[i]);
	firstPlace = RandomSelection_chosen_float;
	firstPlaceVotes = RandomSelection_best_priority;
	//dprint("First place: ", ftos(firstPlace), "\n");
	//dprint("First place votes: ", ftos(firstPlaceVotes), "\n");

	RandomSelection_Init();
	for(i = 0; i < mapvote_count_real; ++i) if(mapvote_maps[i] != "")
		if(i != firstPlace)
			RandomSelection_Add(world, i, string_null, 1, mapvote_selections[i]);
	secondPlace = RandomSelection_chosen_float;
	secondPlaceVotes = RandomSelection_best_priority;
	//dprint("Second place: ", ftos(secondPlace), "\n");
	//dprint("Second place votes: ", ftos(secondPlaceVotes), "\n");

	if(firstPlace == -1)
		error("No first place in map vote... WTF?");

	if(secondPlace == -1 || time > mapvote_timeout || (mapvote_voters_real - firstPlaceVotes) < firstPlaceVotes)
		return MapVote_Finished(firstPlace);

	if(mapvote_keeptwotime)
		if(time > mapvote_keeptwotime || (mapvote_voters_real - firstPlaceVotes - secondPlaceVotes) < secondPlaceVotes)
		{
			float didntvote;
			MapVote_TouchMask();
			mapvote_message = "Now decide between the TOP TWO!";
			mapvote_keeptwotime = 0;
			result = strcat(":vote:keeptwo:", mapvote_maps[firstPlace]);
			result = strcat(result, ":", ftos(firstPlaceVotes));
			result = strcat(result, ":", mapvote_maps[secondPlace]);
			result = strcat(result, ":", ftos(secondPlaceVotes), "::");
			didntvote = mapvote_voters;
			for(i = 0; i < mapvote_count; ++i)
				if(mapvote_maps[i] != "")
				{
					didntvote -= mapvote_selections[i];
					if(i != firstPlace)
						if(i != secondPlace)
						{
							result = strcat(result, ":", mapvote_maps[i]);
							result = strcat(result, ":", ftos(mapvote_selections[i]));
							if(i < mapvote_count_real)
							{
								strunzone(mapvote_maps[i]);
								mapvote_maps[i] = "";
								strunzone(mapvote_maps_pakfile[i]);
								mapvote_maps_pakfile[i] = "";
							}
						}
				}
			result = strcat(result, ":didn't vote:", ftos(didntvote));
			if(autocvar_sv_eventlog)
				GameLogEcho(result);
		}

	return FALSE;
}
void MapVote_Tick()
{
	float keeptwo;
	float totalvotes;

	keeptwo = mapvote_keeptwotime;
	MapVote_CheckRules_1(); // count
	if(MapVote_CheckRules_2()) // decide
		return;

	totalvotes = 0;
	FOR_EACH_REALCLIENT(other)
	{
		// hide scoreboard again
		if(other.health != 2342)
		{
			other.health = 2342;
			other.impulse = 0;
			if(IS_REAL_CLIENT(other))
			{
				msg_entity = other;
				WriteByte(MSG_ONE, SVC_FINALE);
				WriteString(MSG_ONE, "");
			}
		}

		// clear possibly invalid votes
		if(mapvote_maps[other.mapvote - 1] == "")
			other.mapvote = 0;
		// use impulses as new vote
		if(other.impulse >= 1 && other.impulse <= mapvote_count)
			if(mapvote_maps[other.impulse - 1] != "")
			{
				other.mapvote = other.impulse;
				MapVote_TouchVotes(other);
			}
		other.impulse = 0;

		if(other.mapvote)
			++totalvotes;
	}

	MapVote_CheckRules_1(); // just count
}
void MapVote_Start()
{
	if(mapvote_run)
		return;

	// wait for stats to be sent first
	if(!playerstats_waitforme)
		return;

	MapInfo_Enumerate();
	if(MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 1))
		mapvote_run = TRUE;
}
void MapVote_Think()
{
	if(!mapvote_run)
		return;

	if(alreadychangedlevel)
		return;

	if(time < mapvote_nextthink)
		return;
	//dprint("tick\n");

	mapvote_nextthink = time + 0.5;

	if(!mapvote_initialized)
	{
		if(autocvar_rescan_pending == 1)
		{
			cvar_set("rescan_pending", "2");
			localcmd("fs_rescan\nrescan_pending 3\n");
			return;
		}
		else if(autocvar_rescan_pending == 2)
		{
			return;
		}
		else if(autocvar_rescan_pending == 3)
		{
			// now build missing mapinfo files
			if(!MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 1))
				return;

			// we're done, start the timer
			cvar_set("rescan_pending", "0");
		}

		mapvote_initialized = TRUE;
		if(DoNextMapOverride(0))
			return;
		if(!autocvar_g_maplist_votable || player_count <= 0)
		{
			GotoNextMap(0);
			return;
		}
		MapVote_Init();
	}

	MapVote_Tick();
}

string GotoMap(string m)
{
	if(!MapInfo_CheckMap(m))
		return "The map you chose is not available on this server.";
	cvar_set("nextmap", m);
	cvar_set("timelimit", "-1");
	if(mapvote_initialized || alreadychangedlevel)
	{
		if(DoNextMapOverride(0))
			return "Map switch initiated.";
		else
			return "Hm... no. For some reason I like THIS map more.";
	}
	else
		return "Map switch will happen after scoreboard.";
}


void EndFrame()
{
	float altime;
	FOR_EACH_REALCLIENT(self)
	{
		if(IS_SPEC(self))
		{
			if(self.enemy.typehitsound)
				self.typehit_time = time;
			else if(self.enemy.hitsound)
				self.hit_time = time;
		}
		else
		{
			if(self.typehitsound)
				self.typehit_time = time;
			else if(self.hitsound)
				self.hit_time = time;
		}
	}
	altime = time + frametime * (1 + autocvar_g_antilag_nudge);
	// add 1 frametime because after this, engine SV_Physics
	// increases time by a frametime and then networks the frame
	// add another frametime because client shows everything with
	// 1 frame of lag (cl_nolerp 0). The last +1 however should not be
	// needed!
	FOR_EACH_CLIENT(self)
	{
		self.hitsound = FALSE;
		self.typehitsound = FALSE;
		antilag_record(self, altime);
	}
}


/*
 * RedirectionThink:
 * returns TRUE if redirecting
 */
float redirection_timeout;
float redirection_nextthink;
float RedirectionThink()
{
	float clients_found;

	if(redirection_target == "")
		return FALSE;

	if(!redirection_timeout)
	{
		cvar_set("sv_public", "-2");
		redirection_timeout = time + 0.6; // this will only try twice... should be able to keep more clients
		if(redirection_target == "self")
			bprint("^3SERVER NOTICE:^7 restarting the server\n");
		else
			bprint("^3SERVER NOTICE:^7 redirecting everyone to ", redirection_target, "\n");
	}

	if(time < redirection_nextthink)
		return TRUE;

	redirection_nextthink = time + 1;

	clients_found = 0;
	FOR_EACH_REALCLIENT(self)
	{
		// TODO add timer
		print("Redirecting: sending connect command to ", self.netname, "\n");
		if(redirection_target == "self")
			stuffcmd(self, "\ndisconnect; defer ", ftos(autocvar_quit_and_redirect_timer), " reconnect\n");
		else
			stuffcmd(self, strcat("\ndisconnect; defer ", ftos(autocvar_quit_and_redirect_timer), " \"connect ", redirection_target, "\"\n"));
		++clients_found;
	}

	print("Redirecting: ", ftos(clients_found), " clients left.\n");

	if(time > redirection_timeout || clients_found == 0)
		localcmd("\nwait; wait; wait; quit\n");

	return TRUE;
}

void TargetMusic_RestoreGame();
void RestoreGame()
{
	// Loaded from a save game
	// some things then break, so let's work around them...

	// Progs DB (capture records)
	ServerProgsDB = db_load(strcat("server.db", autocvar_sessionid));

	// Mapinfo
	MapInfo_Shutdown();
	MapInfo_Enumerate();
	MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 1);
	WeaponStats_Init();

	TargetMusic_RestoreGame();
}

void Shutdown()
{
	entity e;

	gameover = 2;

	if(world_initialized > 0)
	{
		world_initialized = 0;
		print("Saving persistent data...\n");
		Ban_SaveBans();

		PlayerStats_EndMatch(0);
		FOR_EACH_CLIENT(e)
			PlayerStats_AddGlobalInfo(e);
		PlayerStats_Shutdown();

		if(!cheatcount_total)
		{
			if(autocvar_sv_db_saveasdump)
				db_dump(ServerProgsDB, strcat("server.db", autocvar_sessionid));
			else
				db_save(ServerProgsDB, strcat("server.db", autocvar_sessionid));
		}
		if(autocvar_developer)
		{
			if(autocvar_sv_db_saveasdump)
				db_dump(TemporaryDB, "server-temp.db");
			else
				db_save(TemporaryDB, "server-temp.db");
		}
		CheatShutdown(); // must be after cheatcount check
		db_close(ServerProgsDB);
		db_close(TemporaryDB);
		print("done!\n");
		// tell the bot system the game is ending now
		bot_endgame();

		WeaponStats_Shutdown();
		MapInfo_Shutdown();
	}
	else if(world_initialized == 0)
	{
		print("NOTE: crashed before even initializing the world, not saving persistent data\n");
	}
}
