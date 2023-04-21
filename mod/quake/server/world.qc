entity lastspawn;

void main() { /* unused */ }

entity pingplreport;
void PingPLReport_Think(entity this)
{
	float delta = 3 / maxclients;
	if(delta < sys_frametime)
		delta = 0;
	this.nextthink = time + delta;

	entity e = edict_num(this.cnt + 1);
	if(IS_CLIENT(e) && IS_REAL_CLIENT(e))
	{
		WriteHeader(MSG_BROADCAST, TE_CSQC_PINGPLREPORT);
		WriteByte(MSG_BROADCAST, this.cnt);
		WriteShort(MSG_BROADCAST, bound(1, e.ping, 65535));
		WriteByte(MSG_BROADCAST, min(ceil(e.ping_packetloss * 255), 255));
		WriteByte(MSG_BROADCAST, min(ceil(e.ping_movementloss * 255), 255));
	}
	else
	{
		WriteHeader(MSG_BROADCAST, TE_CSQC_PINGPLREPORT);
		WriteByte(MSG_BROADCAST, this.cnt);
		WriteShort(MSG_BROADCAST, 0);
		WriteByte(MSG_BROADCAST, 0);
		WriteByte(MSG_BROADCAST, 0);
	}
	this.cnt = (this.cnt + 1) % maxclients;
}
STATIC_INIT_LATE(PingPLReport_Spawn)
{
	pingplreport = new_pure(pingplreport);
	setthink(pingplreport, PingPLReport_Think);
	pingplreport.nextthink = time;
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
PRECACHE(Junk)
{
	// player precaches	

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

	precache_sound("player_katria/plyrjmp8.wav");		// player jump
	precache_sound("player_katria/land.wav");			// player landing
	precache_sound("player_katria/land2.wav");		// player hurt landing
	precache_sound("player_katria/drown1.wav");		// drowning pain
	precache_sound("player_katria/drown2.wav");		// drowning pain
	precache_sound("player_katria/gasp1.wav");		// gasping for air
	precache_sound("player_katria/gasp2.wav");		// taking breath
	precache_sound("player_katria/h2odeath.wav");		// drowning death

	precache_sound("player_mario/plyrjmp8.wav");		// player jump
	precache_sound("player_mario/land.wav");			// player landing
	precache_sound("player_mario/land2.wav");		// player hurt landing
	precache_sound("player_mario/drown1.wav");		// drowning pain
	precache_sound("player_mario/drown2.wav");		// drowning pain
	precache_sound("player_mario/gasp1.wav");		// gasping for air
	precache_sound("player_mario/gasp2.wav");		// taking breath
	precache_sound("player_mario/h2odeath.wav");		// drowning death

	precache_sound(QUAKE_TALKSOUND);			// talk
	precache_sound("player/teledth1.wav");		// telefrag
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

	precache_sound("player_katria/pain1.wav");
	precache_sound("player_katria/pain2.wav");
	precache_sound("player_katria/pain3.wav");
	precache_sound("player_katria/pain4.wav");
	precache_sound("player_katria/pain5.wav");
	precache_sound("player_katria/pain6.wav");

	precache_sound("player_mario/pain1.wav");
	precache_sound("player_mario/pain2.wav");
	precache_sound("player_mario/pain3.wav");
	precache_sound("player_mario/pain4.wav");
	precache_sound("player_mario/pain5.wav");
	precache_sound("player_mario/pain6.wav");

// player death sounds
	precache_sound("player/death1.wav");
	precache_sound("player/death2.wav");
	precache_sound("player/death3.wav");
	precache_sound("player/death4.wav");
	precache_sound("player/death5.wav");

	precache_sound("player_katria/death1.wav");
	precache_sound("player_katria/death2.wav");
	precache_sound("player_katria/death3.wav");
	precache_sound("player_katria/death4.wav");
	precache_sound("player_katria/death5.wav");

	precache_sound("player_mario/death1.wav");
	precache_sound("player_mario/death2.wav");
	precache_sound("player_mario/death3.wav");
	precache_sound("player_mario/death4.wav");
	precache_sound("player_mario/death5.wav");

// ax sounds	
	precache_sound("weapons/ax1.wav");			// ax swoosh
	precache_sound("player/axhit1.wav");		// ax hit meat
	precache_sound("player/axhit2.wav");		// ax hit world

	precache_sound("player_katria/axhit1.wav");

	precache_sound("player_mario/axhit1.wav");

	precache_sound("player/h2ojump.wav");		// player jumping into water
	precache_sound("player/slimbrn2.wav");		// player enter slime
	precache_sound("player/inh2o.wav");		// player enter water
	precache_sound("player/inlava.wav");		// player enter lava
	precache_sound("misc/quake_outwater.wav");		// leaving water sound

	precache_sound("player/lburn1.wav");		// lava burn
	precache_sound("player/lburn2.wav");		// lava burn

	precache_sound("player_katria/lburn1.wav");		// lava burn
	precache_sound("player_katria/lburn2.wav");		// lava burn

	precache_sound("player_mario/lburn1.wav");		// lava burn
	precache_sound("player_mario/lburn2.wav");		// lava burn

	precache_sound("misc/water1.wav");			// swimming
	precache_sound("misc/water2.wav");			// swimming

	precache_model("progs/player.mdl");
	precache_model("progs/player_katria.mdl");
	precache_model("progs/player_mario.mdl");
	precache_model("progs/eyes.mdl");
	precache_model("progs/h_player.mdl");
	precache_model("progs/h_player_katria.mdl");
	// NOTE: mario has no head model, uses progs/null.mdl
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
		BADCVAR("in_pitch_min");
		BADCVAR("in_pitch_max");

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
		BADPREFIX("quit_");
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
		BADCVAR("sv_muteban_list");
		BADCVAR("sv_voteban_list");
		BADCVAR("sv_allow_customplayermodels_idlist");
		BADCVAR("sv_allow_customplayermodels_speciallist");

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
		BADCVAR("g_duel");
		BADCVAR("g_duel_not_dm_maps");
		BADCVAR("g_freezetag");
		BADCVAR("g_freezetag_teams");
		BADCVAR("g_invasion_teams");
		BADCVAR("g_invasion_type");
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
		BADCVAR("g_runematch");
		BADCVAR("g_shootfromeye");
		BADCVAR("g_snafu");
		BADCVAR("g_tdm");
		BADCVAR("g_tdm_on_dm_maps");
		BADCVAR("g_tdm_teams");
		BADCVAR("g_vip");
		BADCVAR("leadlimit");
		BADCVAR("nextmap");
		BADCVAR("teamplay");
		BADCVAR("timelimit");
		BADCVAR("g_mapinfo_settemp_acl");
		BADCVAR("g_mapinfo_ignore_warnings");
		BADCVAR("g_maplist_ignore_sizes");
		BADCVAR("g_maplist_sizes_count_bots");

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
		BADCVAR("condump_stripcolors");
		BADCVAR("gameversion");
		BADCVAR("fs_gamedir");
		BADCVAR("g_allow_oldvortexbeam");
		BADCVAR("g_balance_kill_delay");
		BADCVAR("g_buffs_pickup_anyway");
		BADCVAR("g_buffs_randomize");
		BADCVAR("g_buffs_randomize_teamplay");
		BADCVAR("g_campcheck_distance");
		BADCVAR("g_chatsounds");
		BADCVAR("g_ca_point_leadlimit");
		BADCVAR("g_ca_point_limit");
		BADCVAR("g_ctf_captimerecord_always");
		BADCVAR("g_ctf_flag_glowtrails");
		BADCVAR("g_ctf_dynamiclights");
		BADCVAR("g_ctf_flag_pickup_verbosename");
		BADPRESUFFIX("g_ctf_flag_", "_model");
		BADPRESUFFIX("g_ctf_flag_", "_skin");
		BADCVAR("g_domination_point_leadlimit");
		BADCVAR("g_forced_respawn");
		BADCVAR("g_freezetag_point_leadlimit");
		BADCVAR("g_freezetag_point_limit");
		BADCVAR("g_glowtrails");
		BADCVAR("g_hats");
		BADCVAR("g_casings");
		BADCVAR("g_invasion_point_limit");
		BADCVAR("g_jump_grunt");
		BADCVAR("g_keepaway_ballcarrier_effects");
		BADCVAR("g_keepawayball_effects");
		BADCVAR("g_keyhunt_point_leadlimit");
		BADCVAR("g_nexball_goalleadlimit");
		BADCVAR("g_new_toys_autoreplace");
		BADCVAR("g_new_toys_use_pickupsound");
		BADCVAR("g_physics_predictall");
		BADCVAR("g_piggyback");
		BADCVAR("g_playerclip_collisions");
		BADCVAR("g_spawn_alloweffects");
		BADCVAR("g_tdm_point_leadlimit");
		BADCVAR("g_tdm_point_limit");
		BADCVAR("leadlimit_and_fraglimit");
		BADCVAR("leadlimit_override");
		BADCVAR("pausable");
		BADCVAR("sv_announcer");
		BADCVAR("sv_checkforpacketsduringsleep");
		BADCVAR("sv_damagetext");
		BADCVAR("sv_db_saveasdump");
		BADCVAR("sv_intermission_cdtrack");
		BADCVAR("sv_mapchange_delay");
		BADCVAR("sv_minigames");
		BADCVAR("sv_namechangetimer");
		BADCVAR("sv_precacheplayermodels");
		BADCVAR("sv_radio");
		BADCVAR("sv_stepheight");
		BADCVAR("sv_timeout");
		BADCVAR("sv_weapons_modeloverride");
		BADCVAR("w_prop_interval");
		BADPREFIX("chat_");
		BADPREFIX("crypto_");
		BADPREFIX("gameversion_");
		BADPREFIX("g_chat_");
		BADPREFIX("g_ctf_captimerecord_");
		BADPREFIX("g_hats_");
		BADPREFIX("g_maplist_");
		BADPREFIX("g_mod_");
		BADPREFIX("g_respawn_");
		BADPREFIX("net_");
		BADPREFIX("notification_");
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
		BADPREFIX("bot_ai_");
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
		BADCVAR("g_ctf_fullbrightflags");
		BADCVAR("g_ctf_ignore_frags");
		BADCVAR("g_ctf_leaderboard");
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
		BADCVAR("g_maxplayers");
		BADCVAR("g_mirrordamage");
		BADCVAR("g_nexball_goallimit");
		BADCVAR("g_norecoil");
		BADCVAR("g_physics_clientselect");
		BADCVAR("g_pinata");
		BADCVAR("g_powerups");
		BADCVAR("g_player_brightness");
		BADCVAR("g_rocket_flying");
		BADCVAR("g_rocket_flying_disabledelays");
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
		BADCVAR("minplayers_per_team");
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
		BADPREFIX("sv_info_");
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
	set_movetype(this, this.movetype);
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
	string s = ((coop) ? "coop" : "dm"); // the gametype
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

STATIC_INIT_EARLY(maxclients)
{
	maxclients = 0;
	for (entity head = nextent(NULL); head; head = nextent(head)) {
		++maxclients;
	}
}

// hack to auto enable/disable mission packs if their content is detected
STATIC_INIT_EARLY(missionpacks)
{
	cvar_set("sv_missionpack_impel", ftos(fexists("progs/legond.mdl")));

	cvar_set("sv_missionpack_rogue", ftos(fexists("progs/dragon.mdl")));

	cvar_set("sv_missionpack_hipnotic", ftos(fexists("progs/armabody.mdl")));
}

void GameLogEcho(string s);
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
			wantrestart = cvar_string("csqc_progname") != expect;
			cvar_set("csqc_progname", expect);
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
			if (cvar_string("csqc_progname") != select)
			{
				cvar_set("csqc_progname", select);
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
						cvar_set("sv_progs", newprogs);
						wantrestart = true;
					}
					string newcsprogs = sprintf("csprogs-%s.dat", switchversion);
					if (fexists(newcsprogs))
					{
						cvar_set("csqc_progname", newcsprogs);
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

	// needs to be done so early because of the constants they create
	static_init();

	teamplay = cvar("teamplay"); // set it super early so other spawnfuncs can access it

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

	if(autocvar_sv_eventlog)
	{
		string s = sprintf("%d.%s.%06d", itos(autocvar_sv_eventlog_files_counter), strftime(false, "%s"), floor(random() * 1000000));
		//matchid = strzone(s);
		string gtype = ((coop) ? "coop" : ((teamplay >= TEAM_CTF) ? "ctf" : "dm"));

		GameLogEcho(sprintf(":gamestart:%s_%s:%s", gtype, mapname, s));

		GameLogEcho(":gameinfo:end");
	}

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

	// TODO: make an actual use of this or unreference it!
	if(autocvar_physics_ode) {}

	SetMod();

	world_initialized = 1;
	__spawnfunc_spawn_all();
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
		if(MP_IMPEL)
			mapname = "aopstart";
		else if(MP_ROGUE)
			mapname = "rstart";
		else if(MP_HIPNOTIC)
			mapname = "hipstart";
		else
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

	delete_fn = remove_unsafely;

	entity e = spawn();
	setthink(e, GotoFirstMap);
	e.nextthink = time; // this is usually 1 at this point

	e = new(info_player_deathmatch);  // safeguard against player joining

	// assign reflectively to avoid "assignment to world" warning
    for (int i = 0, n = numentityfields(); i < n; ++i) {
        string k = entityfieldname(i);
        if (k == "classname") {
            // safeguard against various stuff ;)
            putentityfieldstring(i, this, "worldspawn");
            break;
        }
    }

	// needs to be done so early because of the constants they create
	static_init();
	static_init_late();
	static_init_precache();
}

/*
============
CheckRules_World

Exit deathmatch games upon conditions
============
*/
void TeamCheckUpdate();
void NextLevel();
bool autocvar_quit_when_empty = true;
void CheckRules_World()
{
	if(gameover)	// someone else quit the game already
		return;
		
	float timelimit = autocvar_timelimit * 60;
	float fraglimit = autocvar_fraglimit;
	
	if(timelimit && time >= timelimit)
	{
		// crude hack to force restart of the server if we've reached the timelimit on a co-op level
		if(server_is_dedicated && autocvar_quit_when_empty && !deathmatch 
			&& world.model != "maps/start.bsp" && world.model != "maps/rstart.bsp" && world.model != "maps/hipstart.bsp" && world.model != "maps/aopstart.bsp")
		{
			if(MP_IMPEL)
				localcmd("\nmap aopstart\n");
			else if(MP_HIPNOTIC)
				localcmd("\nmap hipstart\n");
			else if(MP_ROGUE)
				localcmd("\nmap rstart\n");
			else
				localcmd("\nmap start\n");
		}
		else
			NextLevel();
		return;
	}

	if(fraglimit)
	{
		FOREACH_CLIENT(IS_PLAYER(it),
		{
			if(it.frags >= fraglimit)
			{
				NextLevel();
				return;
			}
		});
	}

	if(MP_ROGUE)
		TeamCheckUpdate();
}

.float dmgtime;
void CreatureFrame_hotliquids(entity this)
{
	if(this.dmgtime > time)
		return;

	if (this.watertype == CONTENT_LAVA)
	{
		if(this.radsuit_finished > time)
			this.dmgtime = time + 1;
		else
			this.dmgtime = time + 0.2;
		T_Damage(this, NULL, NULL, 10 * this.waterlevel);
	}
	else if (this.watertype == CONTENT_SLIME)
	{
		if(this.dmgtime < time && this.radsuit_finished < time)
		{
			this.dmgtime = time + 1;
			T_Damage(this, NULL, NULL, 4 * this.waterlevel);
		}
	}
}

void CreatureFrame_Liquids(entity this)
{
	if (this.watertype <= CONTENT_WATER && this.waterlevel > 0) // workaround a retarded bug made by id software :P (yes, it's that old of a bug)
	{
		if (!(this.flags & FL_INWATER))
		{
			if(IS_PLAYER(this)) // TODO: allow this on non-players? nothing else uses this currently
			{
				if(this.watertype == CONTENT_LAVA)
					_sound(this, CH_PLAYER, "player/inlava.wav", 1, ATTN_NORM);
				else if(this.watertype == CONTENT_WATER)
					_sound(this, CH_PLAYER, "player/inh2o.wav", 1, ATTN_NORM);
				else if(this.watertype == CONTENT_SLIME)
					_sound(this, CH_PLAYER, "player/slimbrn2.wav", 1, ATTN_NORM);
			}

			this.flags |= FL_INWATER;
			this.dmgtime = 0;
		}

		CreatureFrame_hotliquids(this);
	}
	else
	{
		if (this.flags & FL_INWATER)
		{
			// play leave water sound
			if(IS_PLAYER(this))
				_sound(this, CH_PLAYER, "misc/quake_outwater.wav", 1, ATTN_NORM);
			this.flags &= ~FL_INWATER;
			this.dmgtime = 0;
		}
		this.air_finished = time + 12;
		this.dmg = 2;
	}
}

void CreatureFrame_FallDamage(entity this)
{
	// check to see if player landed and play landing sound	
	if(this.jump_flag) // moving or has moved
	{
		if(this.jump_flag < -300 && IS_ONGROUND(this) && this.health > 0)
		{
			if(this.watertype == CONTENT_WATER)
			{
				if(IS_PLAYER(this))
					_sound(this, CH_PLAYER, "player/h2ojump.wav", 1, ATTN_NORM);
			}
			else if(this.jump_flag < -650)
			{
				if(MP_IMPEL && this.exptime != 0)
				{
					if(IS_PLAYER(this))
						player_sound(this, CH_VOICE, "land2.wav", ATTN_NORM);
				}
				else
				{
					T_Damage(this, NULL, NULL, 5);
					if(IS_PLAYER(this))
					{
						player_sound(this, CH_VOICE, "land2.wav", ATTN_NORM);
						this.deathtype = "falling";
					}
				}
			}
			else if(IS_PLAYER(this))
				player_sound(this, CH_VOICE, "land.wav", ATTN_NORM);
		}

		this.jump_flag = 0;
	}

	if(!IS_ONGROUND(this))
		this.jump_flag = this.velocity_z; // always update
}

void CreatureFrame_All()
{
	//IL_EACH(g_damagedbycontents, it.damagedbycontents,
	FOREACH_CLIENT(IS_PLAYER(it) && it.damagedbycontents,
	{
		if (it.move_movetype == MOVETYPE_NOCLIP) continue;
		CreatureFrame_Liquids(it);
		CreatureFrame_FallDamage(it);
	});
}

void StartFrame()
{
	sys_frametime = autocvar_sys_ticrate * autocvar_slowmo;
	if (sys_frametime <= 0) sys_frametime = 1.0 / 60.0; // somewhat safe fallback

	serverprevtime = servertime;
	servertime = time;
	serverframetime = frametime;
	
	teamplay = autocvar_teamplay;
	//framecount = framecount + 1;

	//delete_fn = remove_unsafely; // not during spawning!
	delete_fn = remove_except_protected; // we don't use remove_unsafely as quake does infact use spikes

	if(MP_HIPNOTIC)
		earthquake_frame();

	CreatureFrame_All();
	CheckRules_World();

	GlobalStats_updateglobal();
	FOREACH_CLIENT(true, GlobalStats_update(it));
}

void WarpZoneLib_MoveOutOfSolid_Expand(entity e, vector by)
{
	const float eps = 0.0625;
	tracebox(e.origin, e.mins - '1 1 1' * eps, e.maxs + '1 1 1' * eps, e.origin + by, MOVE_WORLDONLY, e);
	if (trace_startsolid)
		return;
	if (trace_fraction < 1)
	{
		// hit something
		// adjust origin in the other direction...
		setorigin(e, e.origin - by * (1 - trace_fraction));
	}
}

bool WarpZoneLib_MoveOutOfSolid(entity e)
{
	vector o = e.origin;
	traceline(o, o, MOVE_WORLDONLY, e);
	if (trace_startsolid)
		return false;

	tracebox(o, e.mins, e.maxs, o, MOVE_WORLDONLY, e);
	if (!trace_startsolid)
		return true;

	vector m0 = e.mins;
	vector m1 = e.maxs;
	e.mins = '0 0 0';
	e.maxs = '0 0 0';
	WarpZoneLib_MoveOutOfSolid_Expand(e, eX * m0.x); e.mins_x = m0.x;
	WarpZoneLib_MoveOutOfSolid_Expand(e, eX * m1.x); e.maxs_x = m1.x;
	WarpZoneLib_MoveOutOfSolid_Expand(e, eY * m0.y); e.mins_y = m0.y;
	WarpZoneLib_MoveOutOfSolid_Expand(e, eY * m1.y); e.maxs_y = m1.y;
	WarpZoneLib_MoveOutOfSolid_Expand(e, eZ * m0.z); e.mins_z = m0.z;
	WarpZoneLib_MoveOutOfSolid_Expand(e, eZ * m1.z); e.maxs_z = m1.z;
	setorigin(e, e.origin);

	tracebox(e.origin, e.mins, e.maxs, e.origin, MOVE_WORLDONLY, e);
	if (trace_startsolid)
	{
		setorigin(e, o);
		return false;
	}

	return true;
}

bool WarpZoneLib_MoveOutOfSolid(entity e);
#define move_out_of_solid(e) WarpZoneLib_MoveOutOfSolid(e)

bool autocvar_sv_gameplayfix_droptofloorstartsolid;
bool autocvar_sv_gameplayfix_droptofloorstartsolid_nudgetocorrect;

bool autocvar_sv_mapformat_is_quake3;
bool autocvar_sv_mapformat_is_quake2;

// deferred dropping
// ported from VM_SV_droptofloor TODO: make a common function for the client-side?
void DropToFloor_Handler(entity this)
{
	if(!this || wasfreed(this))
	{
		// no modifying free entities
		return;
	}

	vector end = this.origin;
	if (autocvar_sv_mapformat_is_quake3)
		end.z -= 4096;
	else if (autocvar_sv_mapformat_is_quake2)
		end.z -= 128;
	else
		end.z -= 256; // Quake, QuakeWorld

	// NOTE: SV_NudgeOutOfSolid is used in the engine here
	if(autocvar_sv_gameplayfix_droptofloorstartsolid_nudgetocorrect)
	{
		_Movetype_UnstickEntity(this);
		move_out_of_solid(this);
	}

	tracebox(this.origin, this.mins, this.maxs, end, MOVE_NORMAL, this);

	if(trace_startsolid && autocvar_sv_gameplayfix_droptofloorstartsolid)
	{
		vector offset, org;
		offset = 0.5 * (this.mins + this.maxs);
		offset.z = this.mins.z;
		org = this.origin + offset;
		traceline(org, end, MOVE_NORMAL, this);
		trace_endpos = trace_endpos - offset;
		if(trace_startsolid)
		{
			LOG_DEBUGF("DropToFloor_Handler: %v could not fix badly placed entity", this.origin);
			_Movetype_LinkEdict(this, false);
			SET_ONGROUND(this);
			this.groundentity = NULL;
		}
		else if(trace_fraction < 1)
		{
			LOG_DEBUGF("DropToFloor_Handler: %v fixed badly placed entity", this.origin);
			setorigin(this, trace_endpos);
			if(autocvar_sv_gameplayfix_droptofloorstartsolid_nudgetocorrect)
			{
				_Movetype_UnstickEntity(this);
				move_out_of_solid(this);
			}
			SET_ONGROUND(this);
			this.groundentity = trace_ent;
			// if support is destroyed, keep suspended (gross hack for floating items in various maps)
			this.move_suspendedinair = true;
		}
	}
	else
	{
		if(!trace_allsolid && trace_fraction < 1)
		{
			setorigin(this, trace_endpos);
			SET_ONGROUND(this);
			this.groundentity = trace_ent;
			// if support is destroyed, keep suspended (gross hack for floating items in various maps)
			this.move_suspendedinair = true;
		}
		else
		{
			// if we can't get the entity out of solid, mark it as on ground so physics doesn't attempt to drop it
			// hacky workaround for #2774
			SET_ONGROUND(this);
		}
	}
}

void droptofloor(entity this)
{
	DropToFloor_Handler(this);
}

bool autocvar_sv_gameplayfix_multiplethinksperframe = true;
void RunThink(entity this, float dt)
{
	// don't let things stay in the past.
	// it is possible to start that way by a trigger with a local time.
	if(this.nextthink <= 0 || this.nextthink > time + dt)
		return;

	float oldtime = time; // do we need to save this?

	for (int iterations = 0; iterations < 128 && !wasfreed(this); iterations++)
	{
		time = max(oldtime, this.nextthink);
		this.nextthink = 0;

		if(getthink(this))
			getthink(this)(this);
		// mods often set nextthink to time to cause a think every frame,
		// we don't want to loop in that case, so exit if the new nextthink is
		// <= the time the qc was told, also exit if it is past the end of the
		// frame
		if(this.nextthink <= time || this.nextthink > oldtime + dt || !autocvar_sv_gameplayfix_multiplethinksperframe)
			break;
	}

	time = oldtime;
}

bool autocvar_sv_freezenonclients;
void Physics_Frame()
{
	if(autocvar_sv_freezenonclients)
		return;

	IL_EACH(g_moveables, true,
	{
		if(IS_CLIENT(it) || it.move_movetype == MOVETYPE_PHYSICS)
			continue;

		//set_movetype(it, it.move_movetype);
		// inline the set_movetype function, since this is called a lot
		it.movetype = (it.move_qcphysics) ? MOVETYPE_QCENTITY : it.move_movetype;

		if(it.move_qcphysics && it.move_movetype != MOVETYPE_NONE)
			Movetype_Physics_NoMatchTicrate(it, PHYS_INPUT_TIMELENGTH, false);

		if(it.movetype >= MOVETYPE_USER_FIRST && it.movetype <= MOVETYPE_USER_LAST) // these cases have no think handling
		{
			if(it.move_movetype == MOVETYPE_PUSH || it.move_movetype == MOVETYPE_FAKEPUSH)
				continue; // these movetypes have no regular think function
			// handle thinking here
			if (getthink(it) && it.nextthink > 0 && it.nextthink <= time + PHYS_INPUT_TIMELENGTH)
				RunThink(it, PHYS_INPUT_TIMELENGTH);
		}
	});

	if(autocvar_sv_gameplayfix_delayprojectiles >= 0)
		return;

	// make a second pass to see if any ents spawned this frame and make
	// sure they run their move/think. this is verified by checking .move_time, which will never be 0 if the entity has moved
	// MOVETYPE_NONE is also checked as .move_time WILL be 0 with that movetype
	IL_EACH(g_moveables, it.move_qcphysics,
	{
		if(IS_CLIENT(it) || it.move_time || it.move_movetype == MOVETYPE_NONE || it.move_movetype == MOVETYPE_PHYSICS)
			continue;
		Movetype_Physics_NoMatchTicrate(it, PHYS_INPUT_TIMELENGTH, false);
	});
}

void EndFrame()
{
	Physics_Frame();

	IL_ENDFRAME();
}
