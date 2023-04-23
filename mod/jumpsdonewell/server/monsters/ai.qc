#include "ai.qh"

/*

.enemy
Will be world if not currently angry at anyone.

.movetarget
The next path spot to walk toward.  If .enemy, ignore .movetarget.
When an enemy is killed, the monster will try to return to it's path.

.huntt_ime
Set to time + something when the player is in sight, but movement straight for
him is blocked.  This causes the monster to use wall following code for
movement direction instead of sighting on the player.

.ideal_yaw
A yaw angle of the intended direction, which will be turned towards at up
to 45 deg / state.  If the enemy is in view and hunt_time is not active,
this will be the exact line towards the enemy.

.pausetime
A monster will leave it's stand state and head towards it's .movetarget when
time > .pausetime.

walkmove(angle, speed) primitive is all or nothing
*/

void changeyaw(entity this)
{
#if 1
	float current = anglemods(this.angles_y);

	if (current == this.ideal_yaw)
		return;

	float move = this.ideal_yaw - current;
	if (this.ideal_yaw > current)
	{
		if(move >= 180)
			move -= 360;
	}
	else
	{
		if(move <= -180)
			move += 360;
	}
	if(move > 0)
	{
		if(move > this.yaw_speed)
			move = this.yaw_speed;
	}
	else
	{
		if(move < -this.yaw_speed)
			move = -this.yaw_speed;
	}

	current += move;
	this.angles_y = anglemods(current);
#else
	ChangeYaw(this);
#endif
}

bool t_checkbottom(entity this)
{
#if 1
	vector minz = this.origin + this.mins;
	vector maxz = this.origin + this.maxs;

	vector start = minz - '0 0 1';

	// if all the points under the corners are solid world, don't bother with the tougher checks
	// the corners must be within 16 of the midpoint
	for(int j = 0; j <= 1; j++)
	{
		for(int k = 0; k <= 1; k++)
		{
			start.x = (j) ? maxz.x : minz.x;
			start.y = (k) ? maxz.y : minz.y;
			if(pointcontents(start) != CONTENT_SOLID)
				goto realcheck;
		}
	}

	return true; // we got out easy

	LABEL(realcheck)

	// check it for real...
	start.z = minz.z;

	// the midpoint must be within 16 of the bottom
	vector stop;
	start.x = stop.x = (minz.x + maxz.x) * 0.5;
	start.y = stop.y = (minz.y + maxz.y) * 0.5;
	//start = stop = vec2((minz + maxz) * 0.5);
	stop.z = start.z - 2 * PHYS_STEPHEIGHT(NULL);

	traceline(start, stop, MOVE_NOMONSTERS, this);
	if(trace_fraction == 1.0)
		return false;
	float mid, bottom;
	mid = bottom = trace_endpos.z;

	// the corners must be within 16 of the midpoint
	for(int j = 0; j <= 1; j++)
	{
		for(int k = 0; k <= 1; k++)
		{
			start.x = stop.x = ((j) ? maxz.x : minz.x);
			start.y = stop.y = ((k) ? maxz.y : minz.y);

			traceline(start, stop, MOVE_NOMONSTERS, this);

			if(trace_fraction != 1.0 && trace_endpos.z > bottom)
				bottom = trace_endpos.z;
			if(trace_fraction == 1.0 || mid - trace_endpos.z > PHYS_STEPHEIGHT(NULL))
				return false;
		}
	}

	return true;
#else
	return checkbottom(this);
#endif
}

bool t_movestep(entity this, vector move, bool relink, bool noenemy)
{
	vector oldorg = this.origin;
	vector neworg = this.origin + move;

	// flying monsters don't step up
	if((this.flags & FL_SWIM) || (this.flags & FL_FLY))
	{
		// try one move with vertical motion, then one without
		for(int j = 0; j < 2; ++j)
		{
			entity targ;
			neworg = this.origin + move;
			if(noenemy)
				targ = NULL;
			else
			{
				targ = this.enemy;
				if(j == 0 && targ)
				{
					float dz = this.origin.z - targ.origin.z;
					if(dz > 40)
						neworg.z -= 8;
					if(dz < 30)
						neworg.z += 8;
				}
			}

			tracebox(this.origin, this.mins, this.maxs, neworg, MOVE_NORMAL, this);
			if(trace_fraction == 1)
			{
				if((this.flags & FL_SWIM) && !(Mod_Q1BSP_SuperContentsFromNativeContents(pointcontents(trace_endpos)) & DPCONTENTS_LIQUIDSMASK))
					return false; // swim monster left water

				this.origin = trace_endpos;
				if(relink)
				{
					// do nothing for now
					_Movetype_LinkEdict(this, true);
				}
				return true;
			}

			if(!targ)
				break;
		}

		return false;
	}

	// push down from a step height above the desired position
	neworg.z += PHYS_STEPHEIGHT(NULL);
	vector end = neworg;
	end.z -= PHYS_STEPHEIGHT(NULL) * 2;

	tracebox(neworg, this.mins, this.maxs, end, MOVE_NORMAL, this);
	if(trace_startsolid)
	{
		neworg.z -= PHYS_STEPHEIGHT(NULL);
		tracebox(neworg, this.mins, this.maxs, end, MOVE_NORMAL, this);
		if(trace_startsolid)
			return false;
	}

	if(trace_fraction == 1)
	{
		// if monster had the ground pulled out, go ahead and fall
		if(this.flags & FL_PARTIALGROUND)
		{
			this.origin = this.origin + move;
			if(relink)
			{
				// do nothing for now
				_Movetype_LinkEdict(this, true);
			}
			UNSET_ONGROUND(this);
			return true;
		}

		return false; // walked off an edge
	}

	// check point traces down for dangling corners
	vector oldtracenormal = trace_plane_normal;
	entity oldtraceent = trace_ent;
	this.origin = trace_endpos;
	if(relink)
		_Movetype_LinkEdict(this, true);

	if(!t_checkbottom(this))
	{
		if(this.flags & FL_PARTIALGROUND)
		{
			// entity had floor mostly pulled out from underneath it
			// and is trying to correct
			if(relink)
			{
				// do nothing for now
				_Movetype_LinkEdict(this, true);
			}
			return true;
		}
		this.origin = oldorg;
		return false;
	}

	if(this.flags & FL_PARTIALGROUND)
		this.flags &= ~FL_PARTIALGROUND;

	// gameplayfix: check if reached pretty steep plane and bail
	if(!((this.flags & FL_SWIM) || (this.flags & FL_FLY)) && STAT(GAMEPLAYFIX_NOSTEPMOVEONSTEEPSLOPES))
	{
		if(oldtracenormal.z < 0.5)
		{
			this.origin = oldorg;
			return false;
		}
	}

	this.groundentity = oldtraceent;

	// the move is ok
	if(relink)
	{
		// do nothing for now
		_Movetype_LinkEdict(this, true);
	}

	return true;
}

bool t_walkmove(entity this, float yaw, float dist)
{
#if 1
	if(!(IS_ONGROUND(this) || (this.flags & FL_SWIM) || (this.flags & FL_FLY)))
		return false;

	yaw = yaw * M_PI * 2 / 360;
	vector move = '0 0 0';
	move.x = cos(yaw) * dist;
	move.y = sin(yaw) * dist;
	//vector move = vec2(cos(yaw) * dist, sin(yaw) * dist);

	return t_movestep(this, move, true, false);
#else
	return walkmove(this, yaw, dist);
#endif
}

// hacked in version of movetogoal (to be rewritten)
#if 1
bool t_stepdirection(entity this, float yaw, float dist)
{
	this.ideal_yaw = yaw;
	changeyaw(this);

	yaw = yaw * M_PI * 2 / 360;
	vector move = '0 0 0';
	move.x = cos(yaw) * dist;
	move.y = sin(yaw) * dist;
	//vector move = vec2(cos(yaw) * dist, sin(yaw) * dist);
	vector oldorg = this.origin;

	if(t_movestep(this, move, false, false))
	{
		float delta = this.angles.y - this.ideal_yaw;
		if(delta > 45 && delta < 315)
			this.origin = oldorg; // not turned far enough, so don't take the step
		// leave the linking to the engine? TODO
		_Movetype_LinkEdict(this, true);
		return true;
	}

	// relink...
	_Movetype_LinkEdict(this, true);

	return false;
}

const int DI_NODIR = -1;
void t_newchasedir(entity this, entity targ, float dist)
{
	float olddir = anglemods(rint(this.ideal_yaw / 45) * 45);
	float turnaround = anglemods(olddir - 180);

	vector delta = vec2(targ.origin - this.origin);

	vector d;
	d.x = ((delta.x > 10) ? 0 : ((delta.x < -10) ? 180 : DI_NODIR));
	d.y = ((delta.y < -10) ? 270 : ((delta.y > 10) ? 90 : DI_NODIR));

	// try direct route
	if(d.x != DI_NODIR && d.y != DI_NODIR)
	{
		float tdir;
		if(d.x == 0)
			tdir = (d.y == 90) ? 45 : 315;
		else
			tdir = (d.y == 90) ? 135 : 215;

		if(tdir != turnaround && t_stepdirection(this, tdir, dist))
			return;
	}

	// try other directions
	if(random() <= 0.333 || fabs(delta.y) > fabs(delta.x))
		d = vec2(d.y, d.x);

	if(d.x != DI_NODIR && d.x != turnaround && t_stepdirection(this, d.x, dist))
		return;
	if(d.y != DI_NODIR && d.y != turnaround && t_stepdirection(this, d.y, dist))
		return;

	// there is no direct path to the player, so pick another direction

	if(olddir != DI_NODIR && t_stepdirection(this, olddir, dist))
		return;

	if(random() <= 0.5) // randomly determine direction of search
	{
		for(int j = 0; j <= 315; j += 45)
		{
			if(j != turnaround && t_stepdirection(this, j, dist))
				return;
		}
	}
	else
	{
		for(int j = 315; j >= 0; j -= 45)
		{
			if(j != turnaround && t_stepdirection(this, j, dist))
				return;
		}
	}

	if(turnaround != DI_NODIR && t_stepdirection(this, turnaround, dist))
		return;

	this.ideal_yaw = olddir; // can't move

	// if a bridge was pulled out from underneath a monster, it may not have a valid standing position at all
	if(!t_checkbottom(this))
		this.flags |= FL_PARTIALGROUND;
}
#endif

void t_movetogoal(entity this, float dist)
{
#if 1
	if(!(IS_ONGROUND(this) || (this.flags & FL_SWIM) || (this.flags & FL_FLY)))
		return;

	// if the next step hits the enemy, return immediately
	vector rdist = '1 1 1' * dist;
	if(this.enemy && boxesoverlap(this.goalentity.absmin, this.goalentity.absmax, this.absmin - rdist, this.absmax + rdist))
		return;

	// bump around...
	if(random() <= 0.333 || !t_stepdirection(this, this.ideal_yaw, dist))
		t_newchasedir(this, this.goalentity, dist);
#else
	movetogoal(this, dist);
#endif
}

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
.entity movetarget;
.float pausetime;
void t_movetarget(entity this, entity toucher)
{
	if(toucher.movetarget != this)
		return;
	if(toucher.enemy)
		return; // fighting, not following a path

	if(this.target && this.target != "")
	{
		toucher.goalentity = toucher.movetarget = find(NULL, targetname, this.target);
		if (!toucher.movetarget)
		{
			toucher.pausetime = -1;
			return;
		}
		else
			toucher.ideal_yaw = vectoyaw(toucher.goalentity.origin - toucher.origin);
	}
	else
	{
		toucher.pausetime = -1;
		return;
	}
}
