entity lastspawn;

#define cvar_string_normal builtin_cvar_string
#define cvar_normal builtin_cvar
#define cvar_set_normal builtin_cvar_set

// unused
void main()
{

}

bool sv_playerphysicsqc_backup;
void SV_Shutdown()
{
	cvar_set("sv_playerphysicsqc", ftos(sv_playerphysicsqc_backup));
}

//=======================
/*QUAKED worldspawn(0 0 0) ?
Only used for the world entity.
Set message to the level name.
Set sounds to the cd track to play.

World Types:
0: medieval
1: metal
2: base
*/
//=======================
void PrecacheJunk()
{
	// player precaches	
	W_Precache();			// get weapon precaches

// sounds used from C physics code
	precache_sound("demon/dland2.wav");		// landing thud
	precache_sound("misc/h2ohit1.wav");		// landing splash

// setup precaches allways needed
	precache_sound("items/itembk2.wav");		// item respawn sound
	precache_sound("player/plyrjmp8.wav");		// player jump
	precache_sound("player/land.wav");			// player landing
	precache_sound("player/land2.wav");		// player hurt landing
	precache_sound("player/drown1.wav");		// drowning pain
	precache_sound("player/drown2.wav");		// drowning pain
	precache_sound("player/gasp1.wav");		// gasping for air
	precache_sound("player/gasp2.wav");		// taking breath
	precache_sound("player/h2odeath.wav");		// drowning death

	precache_sound("misc/talk.wav");			// talk
	precache_sound("player/teledth1.wav");		// telefrag
	precache_sound("misc/r_tele1.wav");		// teleport sounds
	precache_sound("misc/r_tele2.wav");
	precache_sound("misc/r_tele3.wav");
	precache_sound("misc/r_tele4.wav");
	precache_sound("misc/r_tele5.wav");
	precache_sound("weapons/lock4.wav");		// ammo pick up
	precache_sound("weapons/pkup.wav");		// weapon up
	precache_sound("items/armor1.wav");		// armor up
	precache_sound("weapons/lhit.wav");		//lightning
	precache_sound("weapons/lstart.wav");		//lightning start
	precache_sound("items/damage3.wav");

	precache_sound("misc/power.wav");			//lightning for boss

// player gib sounds
	precache_sound("player/gib.wav");			// player gib sound
	precache_sound("player/udeath.wav");		// player gib sound
	precache_sound("player/tornoff2.wav");		// gib sound

// player pain sounds

	precache_sound("player/pain1.wav");
	precache_sound("player/pain2.wav");
	precache_sound("player/pain3.wav");
	precache_sound("player/pain4.wav");
	precache_sound("player/pain5.wav");
	precache_sound("player/pain6.wav");

// player death sounds
	precache_sound("player/death1.wav");
	precache_sound("player/death2.wav");
	precache_sound("player/death3.wav");
	precache_sound("player/death4.wav");
	precache_sound("player/death5.wav");

// ax sounds	
	precache_sound("weapons/ax1.wav");			// ax swoosh
	precache_sound("player/axhit1.wav");		// ax hit meat
	precache_sound("player/axhit2.wav");		// ax hit world

	precache_sound("player/h2ojump.wav");		// player jumping into water
	precache_sound("player/slimbrn2.wav");		// player enter slime
	precache_sound("player/inh2o.wav");		// player enter water
	precache_sound("player/inlava.wav");		// player enter lava
	precache_sound("misc/outwater.wav");		// leaving water sound

	precache_sound("player/lburn1.wav");		// lava burn
	precache_sound("player/lburn2.wav");		// lava burn

	precache_sound("misc/water1.wav");			// swimming
	precache_sound("misc/water2.wav");			// swimming

	precache_model("progs/player.mdl");
	precache_model("progs/eyes.mdl");
	precache_model("progs/h_player.mdl");
	precache_model("progs/gib1.mdl");
	precache_model("progs/gib2.mdl");
	precache_model("progs/gib3.mdl");

	precache_model("progs/s_bubble.spr");	// drowning bubbles
	precache_model("progs/s_explod.spr");	// sprite explosion

	precache_model("progs/v_axe.mdl");
	precache_model("progs/v_shot.mdl");
	precache_model("progs/v_nail.mdl");
	precache_model("progs/v_rock.mdl");
	precache_model("progs/v_shot2.mdl");
	precache_model("progs/v_nail2.mdl");
	precache_model("progs/v_rock2.mdl");

	precache_model("progs/bolt.mdl");		// for lightning gun
	precache_model("progs/bolt2.mdl");		// for lightning gun
	precache_model("progs/bolt3.mdl");		// for boss shock
	precache_model("progs/lavaball.mdl");	// for testing
	
	precache_model("progs/missile.mdl");
	precache_model("progs/grenade.mdl");
	precache_model("progs/spike.mdl");
	precache_model("progs/s_spike.mdl");

	precache_model("progs/backpack.mdl");

	precache_model("progs/zom_gib.mdl");

	precache_model("progs/v_light.mdl");
}

string cvar_changes, cvar_purechanges;
int cvar_purechanges_count;
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

	adding = true;
	pureadding = true;

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
		BADCVAR("sv_mapformat_is_quake2");
		BADCVAR("sv_mapformat_is_quake3");
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
		BADCVAR("g_require_stats");
		BADPREFIX("developer_");
		BADPREFIX("g_ban_");
		BADPREFIX("g_banned_list");
		BADPREFIX("g_require_stats_");
		BADPREFIX("g_chat_flood_");
		BADPREFIX("g_ghost_items");
		BADPREFIX("g_playerstats_");
		BADPREFIX("g_voice_flood_");
		BADPREFIX("log_file");
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

		// these can contain player IDs, so better hide
		BADPREFIX("g_forced_team_");

		// mapinfo
		BADCVAR("fraglimit");
		BADCVAR("g_arena");
		BADCVAR("g_assault");
		BADCVAR("g_ca");
		BADCVAR("g_ca_teams");
		BADCVAR("g_conquest");
		BADCVAR("g_ctf");
		BADCVAR("g_cts");
		BADCVAR("g_dotc");
		BADCVAR("g_dm");
		BADCVAR("g_domination");
		BADCVAR("g_domination_default_teams");
		BADCVAR("g_freezetag");
		BADCVAR("g_freezetag_teams");
		BADCVAR("g_invasion_teams");
		BADCVAR("g_jailbreak");
		BADCVAR("g_jailbreak_teams");
		BADCVAR("g_keepaway");
		BADCVAR("g_keyhunt");
		BADCVAR("g_keyhunt_teams");
		BADCVAR("g_lms");
		BADCVAR("g_nexball");
		BADCVAR("g_onslaught");
		BADCVAR("g_race");
		BADCVAR("g_race_laps_limit");
		BADCVAR("g_race_qualifying_timelimit");
		BADCVAR("g_race_qualifying_timelimit_override");
		BADCVAR("g_snafu");
		BADCVAR("g_tdm");
		BADCVAR("g_tdm_teams");
		BADCVAR("g_vip");
		BADCVAR("leadlimit");
		BADCVAR("nextmap");
		BADCVAR("teamplay");
		BADCVAR("timelimit");
		BADCVAR("g_mapinfo_ignore_warnings");

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

		// does nothing gameplay relevant
		BADCVAR("captureleadlimit_override");
		BADCVAR("gameversion");
		BADCVAR("g_allow_oldvortexbeam");
		BADCVAR("g_balance_kill_delay");
		BADCVAR("g_buffs_pickup_anyway");
		BADCVAR("g_buffs_randomize");
		BADCVAR("g_campcheck_distance");
		BADCVAR("g_ca_point_leadlimit");
		BADCVAR("g_ca_point_limit");
		BADCVAR("g_ctf_captimerecord_always");
		BADCVAR("g_ctf_flag_glowtrails");
		BADCVAR("g_ctf_flag_pickup_verbosename");
		BADCVAR("g_domination_point_leadlimit");
		BADCVAR("g_forced_respawn");
		BADCVAR("g_freezetag_point_leadlimit");
		BADCVAR("g_freezetag_point_limit");
		BADCVAR("g_hats");
		BADCVAR("g_invasion_point_limit");
		BADCVAR("g_jump_grunt");
		BADCVAR("g_keyhunt_point_leadlimit");
		BADCVAR("g_maplist_selectrandom");
		BADCVAR("g_nexball_goalleadlimit");
		BADCVAR("g_new_toys_use_pickupsound");
		BADCVAR("g_physics_predictall");
		BADCVAR("g_piggyback");
		BADCVAR("g_playerclip_collisions");
		BADCVAR("g_tdm_point_leadlimit");
		BADCVAR("g_tdm_point_limit");
		BADCVAR("leadlimit_and_fraglimit");
		BADCVAR("leadlimit_override");
		BADCVAR("pausable");
		BADCVAR("sv_checkforpacketsduringsleep");
		BADCVAR("sv_intermission_cdtrack");
		BADCVAR("sv_minigames");
		BADCVAR("sv_namechangetimer");
		BADCVAR("sv_precacheplayermodels");
		BADCVAR("sv_stepheight");
		BADCVAR("sv_timeout");
		BADCVAR("sv_weapons_modeloverride");
		BADPREFIX("crypto_");
		BADPREFIX("gameversion_");
		BADPREFIX("g_chat_");
		BADPREFIX("g_ctf_captimerecord_");
		BADPREFIX("g_maplist_votable_");
		BADPREFIX("g_mod_");
		BADPREFIX("g_respawn_");
		BADPREFIX("net_");
		BADPREFIX("prvm_");
		BADPREFIX("skill_");
		BADPREFIX("sv_allow_");
		BADPREFIX("sv_cullentities_");
		BADPREFIX("sv_maxidle_");
		BADPREFIX("sv_minigames_");
		BADPREFIX("sv_radio_");
		BADPREFIX("sv_timeout_");
		BADPREFIX("sv_vote_");
		BADPREFIX("timelimit_");

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
		BADCVAR("g_buffs");
		BADCVAR("g_ca_teams_override");
		BADCVAR("g_ctf_ignore_frags");
		BADCVAR("g_domination_point_limit");
		BADCVAR("g_domination_teams_override");
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
		BADCVAR("g_norecoil");
		BADCVAR("g_physics_clientselect");
		BADCVAR("g_pinata");
		BADCVAR("g_powerups");
		BADCVAR("g_spawnshieldtime");
		BADCVAR("g_start_delay");
		BADCVAR("g_superspectate");
		BADCVAR("g_tdm_teams_override");
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
		BADCVAR("sv_defaultcharacterskin");
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
		BADPREFIX("g_warmup_");
		BADPREFIX("sv_ready_restart_");

		// mutators that announce themselves properly to the server browser
		BADCVAR("g_instagib");
		BADCVAR("g_new_toys");
		BADCVAR("g_nix");
		BADCVAR("g_grappling_hook");
		BADCVAR("g_jetpack");

#undef BADPRESUFFIX
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

void make_safe_for_remove(entity e)
{
}

void remove_safely(entity e)
{
    make_safe_for_remove(e);
    builtin_remove(e);
}

.float remove_except_protected_forbidden;
void remove_except_protected(entity e)
{
	if(e.remove_except_protected_forbidden)
		error("not allowed to remove this at this point");
	builtin_remove(e);
}

void SV_OnEntityPreSpawnFunction(entity this)
{
	__spawnfunc_expecting = true;
	__spawnfunc_expect = this;
}

int nJoinAllowed(entity this, entity ignore);
//bool autocvar_g_full_getstatus_responses;
string autocvar_g_xonoticversion;
void SetMod()
{
	// MOD AUTHORS: change this, and possibly remove a few of the blocks below to ignore certain changes
	string modname = "Quake";
	// config changes that count as mod
	if(cvar_string("g_mod_config") != cvar_defstring("g_mod_config"))
		modname = cvar_string("g_mod_config");

	//bool fullstatus = autocvar_g_full_getstatus_responses;
	string s = "coop"; // the gametype
	s = strcat(s, ":", autocvar_g_xonoticversion);
	s = strcat(s, ":P", ftos(cvar_purechanges_count));
	s = strcat(s, ":S", ftos(nJoinAllowed(NULL, NULL)));
	s = strcat(s, ":F", "0"); // no serverflags?
	s = strcat(s, ":M", modname);
	//s = strcat(s, "::", GetPlayerScoreString(NULL, (fullstatus ? 1 : 2)));

	if(worldstatus)
		strunzone(worldstatus);
	worldstatus = strzone(s);
}

bool world_already_spawned;
int world_initialized;
bool server_is_dedicated;
spawnfunc(worldspawn)
{
	server_is_dedicated = boolean(stof(cvar_defstring("is_dedicated")));

    bool wantrestart = false;
	{
		if (!server_is_dedicated)
		{
			// force unloading of server pk3 files when starting a listen server
			// localcmd("\nfs_rescan\n"); // FIXME: does more harm than good, has unintended side effects. What we really want is to unload temporary pk3s only
			// restore csqc_progname too
			string expect = "csprogs.dat";
			wantrestart = cvar_string_normal("csqc_progname") != expect;
			cvar_set_normal("csqc_progname", expect);
		}
		else
		{
			// Try to use versioned csprogs from pk3
			// Only ever use versioned csprogs.dat files on dedicated servers;
			// we need to reset csqc_progname on clients ourselves, and it's easier if the client's release name is constant
			string pk3csprogs = "csprogs-" WATERMARK ".dat";
			// This always works; fall back to it if a versioned csprogs.dat is suddenly missing
			string select = "csprogs.dat";
			if (fexists(pk3csprogs)) select = pk3csprogs;
			if (cvar_string_normal("csqc_progname") != select)
			{
				cvar_set_normal("csqc_progname", select);
				wantrestart = true;
			}
			// Check for updates on startup
			// We do it this way for atomicity so that connecting clients still match the server progs and don't disconnect
			int sentinel = fopen("progs.txt", FILE_READ);
			if (sentinel >= 0)
			{
				string switchversion = fgets(sentinel);
				fclose(sentinel);
				if (switchversion != "" && switchversion != WATERMARK)
				{
					LOG_INFOF("Switching progs: " WATERMARK " -> %s\n", switchversion);
					// if it doesn't exist, assume either:
					//   a) the current program was overwritten
					//   b) this is a client only update
					string newprogs = sprintf("progs-%s.dat", switchversion);
					if (fexists(newprogs))
					{
						cvar_set_normal("sv_progs", newprogs);
						wantrestart = true;
					}
					string newcsprogs = sprintf("csprogs-%s.dat", switchversion);
					if (fexists(newcsprogs))
					{
						cvar_set_normal("csqc_progname", newcsprogs);
						wantrestart = true;
					}
				}
			}
		}
		if (wantrestart)
		{
			LOG_INFOF("Restart requested\n");
			changelevel(mapname);
			// let initialization continue, shutdown depends on it
		}
	}

	lastspawn = NULL;

// the area based ambient sounds MUST be the first precache_sounds

	cvar = cvar_normal;
	cvar_string = cvar_string_normal;
	cvar_set = cvar_set_normal;

	// custom map attributes
	if(this.model == "maps/e1m8.bsp")
		cvar_set("sv_gravity", "100");
	else
		cvar_set("sv_gravity", "800");

	if(world_already_spawned)
		error("world already spawned - you may have EXACTLY ONE worldspawn!");
	world_already_spawned = true;

	delete_fn = remove_safely; // during spawning, watch what you remove!

	cvar_changes_init(); // do this very early now so it REALLY matches the server config

	maxclients = 0;
	for(entity head = nextent(NULL); head; head = nextent(head))
	{
		++maxclients;
	}

	// needs to be done so early because of the constants they create
	static_init();

//
// Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
//

	// 0 normal
	lightstyle(0, "m");
	
	// 1 FLICKER(first variety)
	lightstyle(1, "mmnmmommommnonmmonqnmmo");
	
	// 2 SLOW STRONG PULSE
	lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
	
	// 3 CANDLE(first variety)
	lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");
	
	// 4 FAST STROBE
	lightstyle(4, "mamamamamama");
	
	// 5 GENTLE PULSE 1
	lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");
	
	// 6 FLICKER(second variety)
	lightstyle(6, "nmonqnmomnmomomno");
	
	// 7 CANDLE(second variety)
	lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");
	
	// 8 CANDLE(third variety)
	lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");
	
	// 9 SLOW STROBE(fourth variety)
	lightstyle(9, "aaaaaaaazzzzzzzz");
	
	// 10 FLUORESCENT FLICKER
	lightstyle(10, "mmamammmmammamamaaamammma");

	// 11 SLOW PULSE NOT FADE TO BLACK
	lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");
	
	// styles 32-62 are assigned by the light program for switchable lights

	// 63 testing
	lightstyle(63, "a");

	static_init_late();
	static_init_precache();

	PrecacheJunk();

	if(autocvar_sv_eventlog)
	{
		string s = sprintf("%d.%s.%06d", itos(autocvar_sv_eventlog_files_counter), strftime(false, "%s"), floor(random() * 1000000));
		//matchid = strzone(s);
		string gtype = ((coop) ? "coop" : "dm");

		GameLogEcho(sprintf(":gamestart:%s_%s:%s", gtype, mapname, s));

		GameLogEcho(":gameinfo:end");
	}

	world_initialized = 1;

	// fill sv_curl_serverpackages from .serverpackage files
	if (autocvar_sv_curl_serverpackages_auto)
	{
		string s = "csprogs-" WATERMARK ".txt";
		// remove automatically managed files from the list to prevent duplicates
		for (int i = 0, n = tokenize_console(cvar_string("sv_curl_serverpackages")); i < n; ++i)
		{
			string pkg = argv(i);
			if (startsWith(pkg, "csprogs-")) continue;
			if (endsWith(pkg, "-serverpackage.txt")) continue;
			if (endsWith(pkg, ".serverpackage")) continue;  // OLD legacy
			s = cons(s, pkg);
		}
		// add automatically managed files to the list
		#define X(match) MACRO_BEGIN { \
			int fd = search_begin(match, true, false); \
			if (fd >= 0) \
			{ \
				for (int i = 0, j = search_getsize(fd); i < j; ++i) \
				{ \
					s = cons(s, search_getfilename(fd, i)); \
				} \
				search_end(fd); \
			} \
		} MACRO_END
		X("*-serverpackage.txt");
		X("*.serverpackage");
		#undef X
		cvar_set("sv_curl_serverpackages", s);
	}

	sv_playerphysicsqc_backup = cvar("sv_playerphysicsqc");
	cvar_set("sv_playerphysicsqc", "0");

	SetMod();
}

void GotoNextMap();
bool autocvar__sv_init;
void GotoFirstMap(entity this)
{
	if(autocvar__sv_init)
	{
		// cvar_set("_sv_init", "0");
		// we do NOT set this to 0 any more, so someone "accidentally" changing
		// to this "init" map on a dedicated server will cause no permanent
		// harm
		mapname = "start";
		GotoNextMap();

		return;
	}

	if(time < 5)
	{
		this.nextthink = time;
	}
	else
	{
		this.nextthink = time + 1;
		LOG_INFO("Waiting for _sv_init being set to 1 by initialization scripts...\n");
	}
}

void remove_unsafely(entity e)
{
    if(e.classname == "spike")
        error("Removing spikes is forbidden (crylink bug), please report");
    builtin_remove(e);
}

spawnfunc(__init_dedicated_server)
{
	// handler for _init/_init map (only for dedicated server initialization)

	world_initialized = -1; // don't complain
	cvar = cvar_normal;
	cvar_string = cvar_string_normal;
	cvar_set = cvar_set_normal;

	delete_fn = remove_unsafely;

	entity e = spawn();
	setthink(e, GotoFirstMap);
	e.nextthink = time; // this is usually 1 at this point

	e = new(info_player_deathmatch);  // safeguard against player joining

	this.classname = "worldspawn"; // safeguard against various stuff ;)

	// needs to be done so early because of the constants they create
	static_init();
	static_init_late();
	static_init_precache();
}

void StartFrame()
{
	teamplay = autocvar_teamplay;
	skill = autocvar_skill;
	//framecount = framecount + 1;

	//delete_fn = remove_unsafely; // not during spawning!
	delete_fn = remove_except_protected;
}
