/*
	server.qc

	server functions (movetarget code)

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

spawnfunc(monster_ogre) { delete(this); }
spawnfunc(monster_demon1) { delete(this); }
spawnfunc(monster_shambler) { delete(this); }
spawnfunc(monster_knight) { delete(this); }
spawnfunc(monster_army) { delete(this); }
spawnfunc(monster_wizard) { delete(this); }
spawnfunc(monster_dog) { delete(this); }
spawnfunc(monster_zombie) { delete(this); }
spawnfunc(monster_boss) { delete(this); }
spawnfunc(monster_tarbaby) { delete(this); }
spawnfunc(monster_hell_knight) { delete(this); }
spawnfunc(monster_fish) { delete(this); }
spawnfunc(monster_shalrath) { delete(this); }
spawnfunc(monster_enforcer) { delete(this); }
spawnfunc(monster_oldone) { delete(this); }
spawnfunc(event_lightning) { delete(this); }

/*
==============================================================================

MOVETARGET CODE

The angle of the movetarget effects standing and bowing direction, but has no effect on movement, which allways heads to the next target.

targetname
must be present.  The name of this movetarget.

target
the next spot to move to.  If not present, stop here for good.

pausetime
The number of seconds to spend standing or bowing for path_stand or path_bow

==============================================================================
*/

/*
=============
t_movetarget

Something has bumped into a movetarget.  If it is a monster
moving towards it, change the next destination and continue.
==============
*/

void t_movetarget(entity this, entity toucher)
{
	if(toucher.movetarget != this)
		return;
	if(toucher.enemy)
		return; // fighting, not following a path

	if(toucher.classname == "monster_ogre")
		_sound(toucher, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE); // play chainsaw drag sound

	toucher.goalentity = toucher.movetarget = find (NULL, targetname, toucher.target);
	toucher.ideal_yaw = vectoyaw(toucher.goalentity.origin - toucher.origin);
	if (!toucher.movetarget)
	{
		toucher.pausetime = time + 999999;
		toucher.th_stand(toucher);
		return;
	}
}

void movetarget_f(entity this)
{
	if(!this.targetname)
		objerror(this, "monster_movetarget: no targetname");
		
	this.solid = SOLID_TRIGGER;
	settouch(this, t_movetarget);
	setsize(this, '-8 -8 -8', '8 8 8');
	
}

/*QUAKED path_corner (0.5 0.3 0) (-8 -8 -8) (8 8 8)
Monsters will continue walking towards the next target corner.
*/
spawnfunc(path_corner)
{
	movetarget_f(this);
}



//============================================================================
