#include "client.qh"

#include "chat.qh"
#include "combat.qh"
#include "prydon/player/client.qh"
#include "prydon/player/parms.qh"
#include "prydon/player/spawn.qh"

void SetChangeParms(entity this)
{
	prydon_SetChangeParms(this);
}

void SetNewParms()
{
	prydon_SetNewParms();
}

void GotoNextMap()
{
	changelevel(mapname);
}


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

/*
============
ClientKill

Player entered the suicide command
============
*/
void ClientKill(entity this)
{
	prydon_ClientKill(this);
}

entity get_spawn_point()
{
	RandomSelection_Init();
	IL_EACH(g_spawnpoints, true,
	{
		RandomSelection_AddEnt(it, 1, 1);
	});
	entity spawnpoint = RandomSelection_chosen_ent;

	return spawnpoint;
}

/*
===========
PutClientInServer

called each time a player is spawned
============
*/
void PutClientInServer(entity this)
{
	prydon_PutClientInServer(this);

	// generic stats not set by prydon
	this.dphitcontentsmask = DPCONTENTS_BODY | DPCONTENTS_SOLID | DPCONTENTS_PLAYERCLIP;
}


/*
================
PlayerPreThink

Called every frame before physics are run
================
*/

.string netname_previous;
void PlayerPreThink(entity this)
{
	// Check for nameless players
	if(this.netname != this.netname_previous)
	{
		if(isInvisibleString(this.netname))
		{
			this.netname = strzone(sprintf("Player#%d", this.playerid));
			// stuffcmd(this, strcat("name ", this.netname, "\n")); // maybe?
		}
		if(autocvar_sv_eventlog) {
			GameLogEcho(strcat(":name:", ftos(this.playerid), ":", this.netname));
        }
		if(this.netname_previous) strunzone(this.netname_previous);
		this.netname_previous = strzone(this.netname);
	}

	this.disableclientprediction = -1;

	prydon_PlayerPreThink(this);
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
	prydon_PlayerPostThink(this);

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

	prydon_ClientConnect(this);

	static int playerid_last;
	this.playerid = ++playerid_last;

	this.flags |= FL_CLIENT;

	this.netname_previous = strzone(this.netname);

	this.disableclientprediction = -1;

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
	// let everyone else know
	prydon_ClientDisconnect(this);
	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":part:", ftos(this.playerid)));

	ONREMOVE(this);
}

void SV_ParseClientCommand(entity this, string command)
{
	// If invalid UTF-8, don't even parse it
	string command2 = "";
	float len = strlen(command);
	float i;
	for (i = 0; i < len; ++i)
		command2 = strcat(command2, chr2str(str2chr(command, i)));
	if(command != command2) return;

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

		if(thecmd) wordwrap_sprint(this, thecmd, 1000);
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
