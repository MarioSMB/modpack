nosave entity          self;
nosave entity		other;
nosave entity		world;
nosave float		time;
nosave float		frametime;
nosave float		force_retouch;		// force all entities to touch triggers
nosave string		mapname;
nosave float		deathmatch;
nosave float		coop;
nosave float		teamplay;
float		serverflags;		// propagated from level to level, used to
nosave float		total_secrets;
nosave float		total_monsters;
nosave float		found_secrets;		// number of secrets found
nosave float		killed_monsters;	// number of monsters killed
float		parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8, parm9, parm10, parm11, parm12, parm13, parm14, parm15, parm16;
nosave vector		v_forward, v_up, v_right;	// set by makevectors()
nosave float		trace_allsolid;
nosave float		trace_startsolid;
nosave float		trace_fraction;
nosave vector		trace_endpos;
nosave vector		trace_plane_normal;
nosave float		trace_plane_dist;
nosave entity		trace_ent;
nosave float		trace_inopen;
nosave float		trace_inwater;

nosave entity          msg_entity;                      // destination of single entity writes
void()          main;                            // only for testing
void()		StartFrame;
void() 		PlayerPreThink;
void() 		PlayerPostThink;
void()		ClientKill;
void()		ClientConnect;
void() 		PutClientInServer;		// call after setting the parm1... parms
void()		ClientDisconnect;
void()		SetNewParms;			// called when a client first connects to
void()		SetChangeParms;			// call to set parms for self so they can
void		end_sys_globals;		// flag for structure dumping

.float		modelindex;		// *** model index in the precached list
.vector		absmin, absmax;	// *** origin + mins / maxs
.float		ltime;			// local time for entity
.float		movetype;
.float		solid;
.vector		origin;			// ***
.vector		oldorigin;		// ***
.vector		velocity;
.vector		angles;
.vector		avelocity;
.vector		punchangle;		// temp angle adjust from damage or recoil
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
.entity		groundentity;
.float		health;
.float		frags;
.float		weapon;			// one of the IT_SHOTGUN, etc flags
.string		weaponmodel;
.float		weaponframe;
.float		currentammo;
.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
.float		items;			// bit flags
.float		takedamage;
.entity		chain;
.float		deadflag;
.vector		view_ofs;			// add to origin to get eye point
.float		button0;		// fire
.float		button1;		// use
.float		button2;		// jump
.float		impulse;		// weapon changes
.float		fixangle;
.vector		v_angle;		// view / targeting angle for players
.float		idealpitch;		// calculated pitch angle for lookup up slopes
.string		netname;
.entity 	enemy;
.float		flags;
.float		colormap;
.float		team;
.float		max_health;		// players maximum health is stored here
.float		teleport_time;	// don't back up
.float		armortype;		// save this fraction of incoming damage
.float		armorvalue;
.float		waterlevel;		// 0 = not in, 1 = feet, 2 = wast, 3 = eyes
.float		watertype;		// a contents value
.float		ideal_yaw;
.float		yaw_speed;
.entity		aiment;
.entity 	goalentity;		// a movetarget or an enemy
.float		spawnflags;
.string		target;
.string		targetname;
.float		dmg_take;
.float		dmg_save;
.entity		dmg_inflictor;
.entity		owner;		// who launched a missile
.vector		movedir;	// mostly for doors, but also used for waterjump
.string		message;		// trigger messages
.float		sounds;		// either a cd track number or sound number
.string         noise, noise1, noise2, noise3;  // contains names of wavs to play

void		end_sys_fields;			// flag for structure dumping