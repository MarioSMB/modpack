/*
	spectate.qc

	spectator functions

	PURPOSE

	Copyright (C) 1996-1997  Id Software, Inc.

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA

*/
// Added Aug11'97 by Zoid <zoid@idsoftware.com>
//
// These functions are called from the server if they exist.
// Note that Spectators only have one think since they movement code doesn't
// track them much.  Impulse commands work as usual, but don't call
// the regular ImpulseCommand handler in weapons.qc since Spectators don't
// have any weapons and things can explode.
//
//   --- Zoid.

/*
===========
SpectatorConnect

called when a spectator connects to a server
============
*/
void SpectatorConnect(entity this)
{
	bprintf("Spectator %s entered the game\n", this.netname);

	this.classname = "spectator";

	this.goalentity = NULL; // used for impulse 1 below
}

/*
===========
SpectatorDisconnect

called when a spectator disconnects from a server
============
*/
void SpectatorDisconnect(entity this)
{
	bprintf("Spectator %s left the game\n", this.netname);
}

/*
================
SpectatorImpulseCommand

Called by SpectatorThink if the spectator entered an impulse
================
*/
void SpectatorImpulseCommand(entity this)
{
	if(this.impulse == 1)
	{
		// teleport the spectator to the next spawn point
		// note that if the spectator is tracking, this doesn't do
		// much
		this.goalentity = find(this.goalentity, classname, "info_player_deathmatch");
		if(this.goalentity == NULL)
			this.goalentity = find(this.goalentity, classname, "info_player_deathmatch");
		if(this.goalentity != NULL)
		{
			setorigin(this, this.goalentity.origin);
			this.angles = this.goalentity.angles;
			this.fixangle = true; // turn this way immediately
		}
	}

	this.impulse = 0;
}

/*
================
SpectatorThink

Called every frame after physics are run
================
*/
void SpectatorThink(entity this)
{
	// this.origin, etc contains spectator position, so you could
	// do some neat stuff here

	if(this.impulse)
		SpectatorImpulseCommand(this);
}
