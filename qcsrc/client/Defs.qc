//NOTE: THIS IS AN INTERFACE FILE. DO NOT EDIT.
//MODIFYING THIS FILE CAN RESULT IN CRC ERRORS.
//YOU HAVE BEEN WARNED.

//feel free to look though. :)





/*
==============================================================================

			SOURCE FOR GLOBALVARS_T C STRUCTURE

==============================================================================
*/

//
// system globals
//
entity		self;
entity		other;
entity		world;
float		time;
float		frametime;

float 		player_localentnum;	//the entnum of the VIEW entity
float 		player_localnum;	//the playernum
float		maxclients;	//a constant filled in by the engine. gah, portability eh?

float		clientcommandframe;	//player movement
float		servercommandframe;	//clientframe echoed off the server

string		mapname;

//
// global variables set by built in functions
//
vector		v_forward, v_up, v_right;	// set by makevectors()

// set by traceline / tracebox
float		trace_allsolid;
float		trace_startsolid;
float		trace_fraction;
vector		trace_endpos;
vector		trace_plane_normal;
float		trace_plane_dist;
entity		trace_ent;
float		trace_inopen;
float		trace_inwater;

//
// required prog functions
//
void()		CSQC_Init;
void()		CSQC_Shutdown;
float(float f, float t, float n)	CSQC_InputEvent;
void(float w, float h)		CSQC_UpdateView;
float(string s)	CSQC_ConsoleCommand;

//these fields are read and set by the default player physics
vector		pmove_org;
vector		pmove_vel;
vector		pmove_mins;
vector		pmove_maxs;
//retrieved from the current movement commands (read by player physics)
float		input_timelength;
vector		input_angles;
vector		input_movevalues;	//forwards, right, up.
float		input_buttons;		//attack, use, jump (default physics only uses jump)

float		movevar_gravity;
float		movevar_stopspeed;
float		movevar_maxspeed;
float		movevar_spectatormaxspeed;	//used by NOCLIP movetypes.
float		movevar_accelerate;
float		movevar_airaccelerate;
float		movevar_wateraccelerate;
float		movevar_friction;
float		movevar_waterfriction;
float		movevar_entgravity;	//the local player's gravity field. Is a multiple (1 is the normal value)

//================================================
void		end_sys_globals;		// flag for structure dumping
//================================================

/*
==============================================================================

			SOURCE FOR ENTVARS_T C STRUCTURE

==============================================================================
*/

//
// system fields (*** = do not set in prog code, maintained by C code)
//
.float		modelindex;		// *** model index in the precached list
.vector		absmin, absmax;	// *** origin + mins / maxs

.float		entnum;	// *** the ent number as on the server
.float		drawmask;
.void()		predraw;

.float		movetype;
.float		solid;

.vector		origin;			// ***
.vector		oldorigin;		// ***
.vector		velocity;
.vector		angles;
.vector		avelocity;

.string		classname;		// spawn function
.string		model;
.float		frame;
.float		skin;
.float		effects;

.vector		mins, maxs;		// bounding box extents reletive to origin
.vector		size;			// maxs - mins

.void()		touch;
.void()		use;
.void()		think;
.void()		blocked;		// for doors or plats, called when can't push other

.float		nextthink;

.entity		chain;

.string		netname;

.entity 	enemy;

.float		flags;

.float		colormap;

.entity		owner;		// who launched a missile

//================================================
void		end_sys_fields;			// flag for structure dumping
//================================================

// Additional OPTIONAL Fields and Globals
float		intermission;
float		scoreboard_showscores;
float		scoreboard_showaccuracy;
.string		message;
.float renderflags;
// float		coop;
// float		deathmatch;

float		dmg_take;
// float		dmg_save;
// vector		dmg_origin;

// Darkplaces Render Modifications
#if 0
.float alpha;
.float renderflags;
.vector colormod;
.float scale;
#endif

// Basic variables
.float enttype; // entity type sent from server
.float sv_entnum; // entity number sent from server
.float team;
.float team_size;

float vid_conwidth, vid_conheight;
float binddb;

// QUALIFYING
float race_checkpoint;
float race_time;
float race_laptime;
float race_checkpointtime;
float race_previousbesttime;
string race_previousbestname;
float race_nextcheckpoint;
float race_nextbesttime;
string race_nextbestname;
float race_penaltyaccumulator; // qualifying: total penalty time in tenths
float race_penaltyeventtime; // time when the player got the penalty
float race_penaltytime; // duration of penalty time, in tenths
string race_penaltyreason; // reason for penalty
float race_server_record; // server record
float race_speedaward;
string race_speedaward_holder;
float race_speedaward_alltimebest;
string race_speedaward_alltimebest_holder;

// RACE
float race_mycheckpoint;
float race_mycheckpointtime;
float race_mycheckpointdelta;
float race_mycheckpointlapsdelta;
string race_mycheckpointenemy;
float race_othercheckpoint;
float race_othercheckpointtime;
float race_othercheckpointdelta;
float race_othercheckpointlapsdelta;
string race_othercheckpointenemy;
float scoreboard_showscores_force;
float race_status;
string race_status_name;
float race_myrank;

// Nexball
float nb_pb_period;

// Spectating
float spectatee_status;

// short mapname
string shortmapname;

// database for misc stuff
float tempdb;
float ClientProgsDB;
vector hook_shotorigin[4];
vector lightning_shotorigin[4];


#ifdef BLURTEST
float blurtest_time0, blurtest_time1, blurtest_radius, blurtest_power;
#endif

float servertime, serverprevtime, serverdeltatime;

float ticrate;

.float damageforcescale;
#define MIN_DAMAGEEXTRARADIUS 2
#define MAX_DAMAGEEXTRARADIUS 16
.float damageextraradius;
.void(float thisdmg, float hittype, vector org, vector thisforce) event_damage;

// only for Porto
float angles_held_status;
vector angles_held;

// weapons
.float silent;

float w_deathtype, w_issilent, w_random;
vector w_org, w_backoff;

float rifle_scope;
float vortex_scope;

float minelayer_maxmines;

float hagar_maxrockets;

float bgmtime;

string weaponorder_byimpulse;
string weaponorder_bypriority;

float vortex_charge_movingavg;

float serverflags;

float uid2name_dialog;

.float csqcmodel_isdead; // used by shownames and miscfunctions (float getplayerisdead(float) {}) to know when a player is dead

#define player_currententnum (spectatee_status > 0 ? spectatee_status : player_localnum + 1)

float g_balance_porto_secondary;
