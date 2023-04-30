#include "frametick.qh"

/*  Copyright (C) 1996-2022 id Software LLC

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

	See file, 'COPYING', for details.
*/

IntrusiveList g_frametick;
STATIC_INIT(g_frametick) { g_frametick = IL_NEW(); }

void RegisterFrameTickEntity(entity this)
{
	if(!this.tick)
		objerror(this, "Registered frame tick entity doesn't have tick function.\n");
	IL_PUSH(g_frametick, this);
}

void RemoveFrameTickEntity(entity this)
{
	if(!this.tick)
		return;

	IL_REMOVE(g_frametick, this);
}

void RunFrameTickEntities(float dt)
{
	IL_EACH(g_frametick, it.tick, it.tick(it, dt));
}
