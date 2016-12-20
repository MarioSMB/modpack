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
