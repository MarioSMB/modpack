#include "combat.qh"

.entity sword;

void SetChangeParms(entity this)
{
}

void SetNewParms()
{
}

void GotoNextMap()
{
	changelevel("map2");
}


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

bool sword_customize(entity this, entity client)
{
	return (STAT(SWORDPOWER, this.owner) > 0);
}

/*
============
ClientKill

Player entered the suicide command
============
*/
void ClientKill(entity this)
{
}

vector get_spawn_point()
{
	//entity spawnpoint = NULL;

	//spawnpoint = find(NULL, classname, "info_player_start");
	RandomSelection_Init();
	FOREACH_ENTITY_CLASS("info_player_start", true,
	{
		RandomSelection_AddEnt(it, 1, 1);
	});
	entity spawnpoint = RandomSelection_chosen_ent;

	return spawnpoint.origin + '0 0 1';
}

void revive(entity this)
{
	if(!this.cp)
		setorigin(this, get_spawn_point());
	else
		setorigin(this, this.cp.origin);
	this.health = this.max_health;
	this.solid = SOLID_SLIDEBOX;
	this.takedamage = DAMAGE_YES;
	this.invuln_time = time + 1;
	this.frame = 0;
	set_movetype(this, MOVETYPE_WALK);

	msg_entity = this;
	WriteHeader(MSG_ONE, TE_CSQC_REVIVE);
}

/*
===========
PutClientInServer

called each time a player is spawned
============
*/
void player_hurt(entity this);
void player_die(entity this);
void player_touch(entity this, entity toucher);
void PutClientInServer(entity this)
{
	this.classname = STR_PLAYER;
	this.flags = FL_CLIENT;
	this.solid = SOLID_SLIDEBOX;
	setmodel(this, MDL_PLAYER);
	set_movetype(this, MOVETYPE_WALK);
	this.health = this.max_health = 3;
	setorigin(this, get_spawn_point());
	this.fixangle = true;
	setsize(this, '-16 -16 0', '16 16 64');
	this.view_ofs = '0 0 48';
	this.takedamage = DAMAGE_YES;
	this.hurt = player_hurt;
	this.die = player_die;
	STAT(FEATHER, this) = 1;
	this.effects = EF_TELEPORT_BIT;
	settouch(this, player_touch);
	this.invuln_time = time + 2;

	if(!this.sword)
		this.sword = new(sword);
	this.sword.owner = this;
	setmodel(this.sword, MDL_SWORD_EQUIP);
	setattachment(this.sword, this, "hand.R");
	setcefc(this.sword, sword_customize);
	this.sword.effects = EF_LOWPRECISION;

	this.dphitcontentsmask = DPCONTENTS_BODY | DPCONTENTS_SOLID | DPCONTENTS_PLAYERCLIP;
	
	if(cvar_string("sv_worldbasename") == "map2")
		STAT(SWORDPOWER, this) = 0;
	else
	{
		STAT(SWORDPOWER, this) = 2;
		STAT(FEATHER, this) = 2;
	}
}


/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start(1 0 0)(-16 -16 -24)(16 16 24)
The normal starting point for a level.
*/
spawnfunc(info_player_start)
{
}

spawnfunc(info_player_deathmatch)
{
	this.classname = "info_player_start";
}

spawnfunc(info_player_team1)
{
	this.classname = "info_player_start";
}
spawnfunc(info_player_team2)
{
	this.classname = "info_player_start";
}



/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void GameLogEcho(string s);

.string netname_previous;
void revive(entity this);
void PlayerPreThink(entity this)
{
	// Check for nameless players
	if (this.netname != this.netname_previous)
	{
		if (isInvisibleString(this.netname))
		{
			this.netname = strzone(sprintf("Player#%d", this.playerid));
			// stuffcmd(this, strcat("name ", this.netname, "\n")); // maybe?
		}
		if (autocvar_sv_eventlog) {
			GameLogEcho(strcat(":name:", ftos(this.playerid), ":", this.netname));
        }
		if (this.netname_previous) strunzone(this.netname_previous);
		this.netname_previous = strzone(this.netname);
	}

	this.disableclientprediction = -1;

	if(this.health <= 0)
	{
		this.frame = 6;
		if(time > this.respawn_time)
			revive(this);
		return;
	}

	player_weapons(this);

	if(IS_ONGROUND(this) && time - STAT(JUMP_PRESSED_TIME, this) > 0.1 && this.health > 0)
	{
		if(this.pain_time + 0.3 > time)
			this.frame = 5;
		else if(time > STAT(ATTACK_FINISHED, this))
		{
			if(vdist(this.velocity, >, 1))
				this.frame = 1;
			else
				this.frame = 0;
		}
	}
}

void Player_Physics(entity this)
{
	this.movetype = (this.move_qcphysics) ? MOVETYPE_QCPLAYER : this.move_movetype;

	if(!this.move_qcphysics)
		return;

	if(!frametime && !this.pm_frametime)
		return;

	Movetype_Physics_NoMatchTicrate(this, this.pm_frametime, true);

	this.pm_frametime = 0;
}


/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void PlayerPostThink(entity this)
{
	Player_Physics(this);

	CSQCMODEL_AUTOUPDATE(this);
}

/*
===========
ClientConnect

called when a player connects to a server
============
*/
void ClientConnect(entity this)
{
	make_impure(this);
	this.classname = "player_joining";
	bprintf("%s entered the game\n", this.netname);

	static int playerid_last;
	this.playerid = ++playerid_last;

	this.flags |= FL_CLIENT;

	this.netname_previous = strzone(this.netname);

	this.disableclientprediction = -1;

	//stuffcmd(this, "cd loop track001\n");

	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":join:", ftos(this.playerid), ":", ftos(etof(this)), ":", this.netaddress, ":", this.netname));

	CSQCMODEL_AUTOINIT(this);

	Physics_UpdateStats(this);
}


/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void ClientDisconnect(entity this)
{
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving

	// let everyone else know
	bprint(strcat(this.netname, " has left the game.\n"));
	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":part:", ftos(this.playerid)));

	IL_EACH(g_moveables, it.collected,
	{
		if(IL_CONTAINS(it.collected, this))
			IL_REMOVE(it.collected, this);
	});

	ONREMOVE(this);
}

int Say(entity source, int teamsay, entity privatesay, string msgin, bool floodcontrol);
void SV_ParseClientCommand(entity this, string command)
{
	// If invalid UTF-8, don't even parse it
	string command2 = "";
	float len = strlen(command);
	float i;
	for (i = 0; i < len; ++i)
		command2 = strcat(command2, chr2str(str2chr(command, i)));
	if (command != command2) return;

	float argc = tokenize_console(command);

	// Guide for working with argc arguments by example:
	// argc:   1    - 2      - 3     - 4
	// argv:   0    - 1      - 2     - 3
	// cmd     vote - master - login - password

	string cmd_name = strtolower(argv(0));

	// for floodcheck
	switch (cmd_name)
	{
		// exempt commands which are not subject to floodcheck
		case "begin": break;                               // handled by engine in host_cmd.c
		case "download": break;                            // handled by engine in cl_parse.c
		case "mv_getpicture": break;                       // handled by server in this file
		case "pause": break;                               // handled by engine in host_cmd.c
		case "prespawn": break;                            // handled by engine in host_cmd.c
		case "sentcvar": break;                            // handled by server in this file
		case "spawn": break;                               // handled by engine in host_cmd.c
		case "c2s": Net_ClientCommand(this, command); return; // handled by net.qh
	}

	if(cmd_name == "cvar_purechanges")
	{
		sprint(this, strcat(cvar_purechanges, "\n"));
		return;
	}

	if(cmd_name == "cvar_changes")
	{
		sprint(this, strcat(cvar_changes, "\n"));
		return;
	}

	if(cmd_name == "say" || cmd_name == "say_team")
	{
		if(argc >= 2) Say(this, false, NULL, substring(command, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)), 1);
		return;
	}

	if(cmd_name == "info")
	{
		string thecmd = cvar_string(strcat("sv_info_", argv(1)));

		if (thecmd) wordwrap_sprint(this, thecmd, 1000);
		else sprint(this, "ERROR: unsupported info command");
		return;
	}

	clientcommand(this, command);
}

void setcolor(entity this, int clr)
{
#if 0
	this.clientcolors = clr;
	this.team = (clr & 15) + 1;
#else
	builtin_setcolor(this, clr);
#endif
}

void SetPlayerColors(entity pl, float _color)
{
	/*string s;
	s = ftos(cl);
	stuffcmd(pl, strcat("color ", s, " ", s, "\n")  );
	pl.team = cl + 1;
	//pl.clientcolors = pl.clientcolors - (pl.clientcolors & 15) + cl;
	pl.clientcolors = 16*cl + cl;*/

	int pants = _color & 0x0F;
	int shirt = _color & 0xF0;

	setcolor(pl, shirt + pants);
}

void SV_ChangeTeam(entity this, float _color)
{
	SetPlayerColors(this, _color);

	if(!IS_CLIENT(this))
	{
		// since this is an engine function, and gamecode doesn't have any calls earlier than this, do the connecting message here
		bprintf("%s is connecting...\n", this.netname);
		return;
	}
}

/**
 * Determines whether the player is allowed to join. This depends on cvar
 * g_maxplayers, if it isn't used this function always return true, otherwise
 * it checks whether the number of currently playing players exceeds g_maxplayers.
 * @return int number of free slots for players, 0 if none
 */
int nJoinAllowed(entity this, entity ignore)
{
	// TODO simplify this
	int totalClients = 0;
	int currentlyPlaying = 0;
	FOREACH_CLIENT(true, LAMBDA(
		if(it != ignore)
			++totalClients;
		if(IS_REAL_CLIENT(it) && IS_PLAYER(it))
			++currentlyPlaying;
	));

	int free_slots = maxclients - totalClients;

	return free_slots;
}
