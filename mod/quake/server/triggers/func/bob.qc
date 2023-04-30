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

const int FUNC_BOB_NONSOLID = BIT(0);
const int FUNC_BOB_START_ON = BIT(1);

const float FUNC_BOB_THINKINTERVAL = 0.05;

.entity bobbing_controller;

vector func_bob_GetPositionForAngle(entity this, float an)
{
	this.count += (an);
	this.count = (this.count % 360);

	float dd = sin(this.count);
	vector offs = this.dest * dd;
	if(this.dest2 != '0 0 0')
	{   
		float ddc = cos(this.count);
		offs += (this.dest2 * ddc);
	}

	return offs;
}

void func_bob_blocked(entity this, entity blocker)
{
	if(this.attack_finished > time) return;
	T_Damage(blocker, this, this, this.dmg);
	this.attack_finished = time + 0.5;
}

// Used by solid bobbers
void func_bob_controller_think(entity this)
{
	entity bob = this.owner;
	this.nextthink = time + FUNC_BOB_THINKINTERVAL;

	if(!bob.state)
	{
		bob.velocity = '0 0 0';
		CSQCMODEL_AUTOUPDATE(bob);
		return;
	}

	vector offs = func_bob_GetPositionForAngle(bob, bob.cnt * FUNC_BOB_THINKINTERVAL * PHYS_INPUT_FRAMETIME);

	vector diff = offs - bob.origin;
	if(bob.classname == "func_bob") // don't brake stuff if the func_bob was killtarget'ed
		// * 10 so it will arrive in 0.1 sec
		bob.velocity = diff * (1 / FUNC_BOB_THINKINTERVAL);
	CSQCMODEL_AUTOUPDATE(bob);
}

void func_bob_use(entity this, entity actor, entity trigger)
{
	if(this.state)
	{
		this.velocity = '0 0 0';
		this.bobbing_controller.nextthink = -1;
	}
	else
	{
		func_bob_controller_think(this.bobbing_controller);
	}

	this.state = 1 - this.state;
	CSQCMODEL_AUTOUPDATE(this);
}

spawnfunc(func_bob)
{
	if(!MP_MG) { delete(this); return; }

	_setmodel(this, this.model);
	setorigin(this, this.origin);

	if(!this.dest)
		this.dest = '0 0 64';
	if(!this.wait)
		this.wait = 10;
	if(!this.dmg)
		this.dmg = 1;
	this.cnt = 360 / this.wait;
	this.count = 360 * this.delay;
 
	this.use = func_bob_use;
	
	setblocked(this, func_bob_blocked);

	if(this.spawnflags & FUNC_BOB_NONSOLID)
	{
		set_movetype(this, MOVETYPE_FAKEPUSH);
		this.solid = SOLID_NOT;
	}
	else
	{
		set_movetype(this, MOVETYPE_PUSH);
		this.solid = SOLID_BSP;
	}

	// wait for targets to spawn
	entity controller = new_pure(func_bobbing_controller);
	set_movetype(controller, MOVETYPE_NONE); // link with qc
	controller.owner = this;
	setthink(controller, func_bob_controller_think);
	this.nextthink = this.ltime + 999999999;
	setthink(this, SUB_NullThink);
	this.bobbing_controller = controller;

	CSQCMODEL_AUTOINIT(this);

	if(this.spawnflags & FUNC_BOB_START_ON)
		func_bob_use(this, NULL, NULL);
}
