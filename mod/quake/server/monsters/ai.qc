#include "ai.qh"

bool CanTakedamage(entity e, entity actor)
{
	return (e.takedamage > 0);
}

void spider_wake1(entity this); // TODO?
/*

.enemy
Will be world if not currently angry at anyone.

.movetarget
The next path spot to walk toward.  If .enemy, ignore .movetarget.
When an enemy is killed, the monster will try to return to it's path.

.hunt_ime
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
	float current = ANGLEMOD(this.angles_y);

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
	this.angles_y = ANGLEMOD(current);
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

	if(trace_fraction == 1 && !this.charmed)
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

	if(!this.charmed && !t_checkbottom(this))
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
	if(StatusEffects_active(STATUSEFFECT_Slowness, this))
		dist *= 0.25;

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
		float delta = this.angles_y - this.ideal_yaw;
		if(delta > 45 && delta < 315)
			this.origin = oldorg; // not turned far enough, so don't take the step
		_Movetype_LinkEdict(this, true);
		return true;
	}

	// relink...
	_Movetype_LinkEdict(this, true);

	return false;
}

const float DI_NODIR = -1;
void t_newchasedir(entity this, entity targ, float dist)
{
	float olddir = ANGLEMOD(rint(this.ideal_yaw / 45) * 45);
	float turnaround = ANGLEMOD(olddir - 180);

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
	if(StatusEffects_active(STATUSEFFECT_Slowness, this))
		dist *= 0.25;

#if 1
	if(!(IS_ONGROUND(this) || (this.flags & FL_SWIM) || (this.flags & FL_FLY)))
		return;

	// if the next step hits the enemy, return immediately
	vector rdist = '1 1 1' * dist;
	if(!(this.monsterdef.spawnflags & MON_FLAG_PASSTARGET) && this.enemy
		&& boxesoverlap(this.goalentity.absmin, this.goalentity.absmax, this.absmin - rdist, this.absmax + rdist))
		return;

	// bump around...
	if(random() <= 0.333 || !t_stepdirection(this, this.ideal_yaw, dist))
		t_newchasedir(this, this.goalentity, dist);
#else
	movetogoal(this, dist);
#endif
}


//
// when a monster becomes angry at a player, that monster will be used
// as the sight target the next frame so that monsters near that one
// will wake up even if they wouldn't have noticed the player
//
entity sight_entity;
float sight_entity_time;

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

void t_movetarget(entity this, entity toucher);

/*QUAKED path_corner(0.5 0.3 0)(-8 -8 -8)(8 8 8)
Monsters will continue walking towards the next target corner.
"delay" delay to wait before proceeding to next segment;
*/
spawnfunc(path_corner)
{
	if(!this.targetname || this.targetname == "")
	{
		objerror(this, "path_corner with no targetname");
		return;
	}

	if(this.wait < 0)
		this.wait = 999999;
	if(!this.wait && this.pausetime)
		this.wait = this.pausetime;
		
	this.solid = SOLID_TRIGGER;
	settouch(this, t_movetarget);
	setsize(this, '-8 -8 -8', '8 8 8');
}


/*
=============
t_movetarget

Something has bumped into a movetarget.  If it is a monster
moving towards it, change the next destination and continue.
==============
*/
entity findunlocked(entity start, .string fld, string match);
void t_movetarget(entity this, entity toucher)
{
	if(toucher.movetarget != this)
		return;
	if(toucher.enemy)
		return; // fighting, not following a path

	if(IsMGMap())
	{
		this.owner = toucher; // we have a valid visitor!
		if(toucher.dmg_inflictor && toucher.dmg_inflictor.classname == "path_corner")
		{
			// clear the previous path_corner from owning our new visitor
			if(toucher.dmg_inflictor.owner == toucher.dmg_inflictor)
				toucher.dmg_inflictor.owner = NULL;
		}
		toucher.dmg_inflictor = this;
		if(toucher.pausetime > time)
			return; // waiting to walk...
	}

	if(this.target && this.target != "")
	{
		toucher.goalentity = toucher.movetarget = findunlocked(NULL, targetname, this.target);
		if (!toucher.movetarget)
		{
			toucher.pausetime = -1;
			toucher.th_stand(toucher);
			return;
		}
		else if(this.wait)
		{
			toucher.pausetime = time + this.wait;
			toucher.th_stand(toucher);
		}
		else if(this.delay)
		{
			toucher.pausetime = time + this.delay;
			toucher.th_stand(toucher);
		}
		else
			toucher.ideal_yaw = vectoyaw(toucher.goalentity.origin - toucher.origin);
	}
	else
	{
		toucher.goalentity = toucher.movetarget = NULL;
		toucher.pausetime = -1;
		toucher.th_stand(toucher);
	}
}

//============================================================================
// Functions for changing how path_corners work.
//============================================================================

void target_cancelpause_use(entity this, entity actor, entity trigger)
{
	FOREACH_ENTITY_STRING(targetname, this.target,
	{
		if(IS_MONSTER(it))
		{
			it.pausetime = 0;
			it.use = monster_use;
		}
	});
}

/*QUAKED target_cancelpause (0.5 0.3 0) (-8 -8 -8) (8 8 8)
When activated, will zero out the pausetime for monsters, causing them to continue walking their paths.
*/
spawnfunc(target_cancelpause)
{
	if(!this.target || this.target == "")
		objerror(this, "target_cancelpause with no target given.\n");
	if(!this.targetname || this.targetname == "")
		objerror(this, "target_cancelpause with no targetname given.\n");
	this.use = target_cancelpause_use;
}

void target_switchpath_use(entity this, entity actor, entity trigger)
{
	FOREACH_ENTITY_STRING(targetname, this.target,
	{
		if(it.classname == "path_corner")
		{
			string oldTarget = it.target;
			// Just switch the target
			it.target = this.netname;
			
			// Has this corner been visited by a monster lately?
			if(it.owner)
			{
				entity o = it.owner;
				entity oldtarg = find(NULL, targetname, oldTarget);
				if(o.movetarget == oldtarg)
				{
					// Switch that monster over to walk to the new target instead
					o.goalentity = o.movetarget = find(NULL, targetname, it.target);
					o.ideal_yaw = vectoyaw(o.goalentity.origin - o.origin);
				}
			}
		}
	});
}

/*QUAKED target_switchpath (0.5 0.3 0) (-8 -8 -8) (8 8 8)
When activated, will switch out the target .
*/
spawnfunc(target_switchpath)
{
	if(!this.target || this.target == "")
		objerror(this, "target_switchtarget with no target given.\n");
	if(!this.targetname || this.targetname == "")
		objerror(this, "target_switchtarget with no targetname given.\n");
	if(!this.netname || this.netname == "")
		objerror(this, "target_switchtarget with no netname given.\n");
	this.use = target_switchpath_use;
}

//============================================================================

const vector RANGES_NORMAL = '120 500 1000';
const vector RANGES_NEARSIGHTED = '120 300 340';

const float VISIONCONE_NORMAL = 0.3;
const float VISIONCONE_NEARSIGHTED = 0.866; // ~30 degrees

/*
=============
t_followtarget

Something has bumped into a followtarget.  If it is a monster
moving towards it, change the next destination and continue.
==============
*/
.float followtarget_time;
void t_followtarget(entity this, entity toucher)
{
	if(!IS_MONSTER(toucher))
		return;
	if(toucher.flags & FL_DECOY)
		return;
//  if (toucher.enemy == NULL)
//  	return;
	if (toucher.followtarget_time > time)
		return;
	entity targ = toucher.enemy;

// see if any entities are in the way of the shot
	vector spot1 = toucher.origin + toucher.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, false, toucher);
	if(trace_fraction == 1)
		return;

	if (toucher.enemy)
	{
	  // make the monster tame
		toucher.oldenemy = toucher.enemy;
		toucher.enemy = NULL;
		if(toucher.th_walk)
		{
			setthink(toucher, toucher.th_walk);
			toucher.nextthink = time + 0.1;
		}
	}

	toucher.goalentity = toucher.movetarget = find(NULL, targetname, this.target);

	toucher.ideal_yaw = vectoyaw(toucher.goalentity.origin - toucher.origin);
	toucher.followtarget_time = time + 2;
	if(!toucher.movetarget)
	{
		if (toucher.oldenemy)
		{
			toucher.enemy = toucher.oldenemy;
			FoundTarget(toucher);
			return;
		}
		else
		{
			entity client = t_checkclient(toucher);
			if (client)
			{
				toucher.enemy = client;
				FoundTarget(toucher);
				return;
			}
			toucher.pausetime = -1;
			if(toucher.th_stand)
				toucher.th_stand(toucher);
		}
	}
}

void followtarget_f(entity this)
{
//	if (!this.targetname)
//      objerror ("monster_followtarget: no targetname");

	this.solid = SOLID_TRIGGER;
	settouch(this, t_followtarget);
	_setmodel(this, this.model); // set size and link into world
	set_movetype(this, MOVETYPE_NONE);
	this.modelindex = 0;
	this.model = "";
//   setsize (this, '-8 -8 -8', '8 8 8');

}

/*QUAKED path_follow (0.5 0.3 0) ?
Monsters will stop what they are doing and follow to the path
*/

spawnfunc(path_follow)
{
	followtarget_f(this);
}

/*QUAKED path_follow2 (0.5 0.3 0) (-8 -8 -8) (8 8 8)
Monsters will stop what they are doing and follow to the path
*/

spawnfunc(path_follow2)
{
	this.solid = SOLID_TRIGGER;
	settouch(this, t_followtarget);
	setsize (this, '-8 -8 -8', '8 8 8');
}


//============================================================================

/*
=============
range

returns the range catagorization of an entity reletive to this
0	melee range, will become hostile even if back is turned
1	visibility and infront, or visibility and show hostile
2	infront and show hostile
3	only triggered by damage
=============
*/
int range(entity this, entity targ)
{
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	vector offset = '1 1 1';
	if(boxesoverlap(this.absmin - offset, this.absmax + offset, targ.absmin - offset, targ.absmax + offset))
		return RANGE_MELEE;

	vector ranges = RANGES_NORMAL;
	if(this.spawnflags & SPAWNFLAG_NEARSIGHTED)
	{
		if(this.enemy)
			ranges = RANGES_NORMAL * 0.8;
		else
			ranges = RANGES_NEARSIGHTED;
	}

	if(vdist(spot1 - spot2, <, ranges.x))
		return RANGE_MELEE;
	if(vdist(spot1 - spot2, <, ranges.y))
		return RANGE_NEAR;
	if(vdist(spot1 - spot2, <, ranges.z))
		return RANGE_MID;
	return RANGE_FAR;
}

/*
=============
visible

returns true if the entity is visible to this, even if not infront()
=============
*/
bool visible(entity this, entity targ)
{
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;
	traceline(spot1, spot2, MOVE_NOMONSTERS, this); // see through other monsters
	
	if(trace_inopen && trace_inwater)
		return false; // sight line crossed contents
	if(trace_fraction == 1)
	{
		this.visible_distance = vlen(spot2 - spot1);
		return true;
	}

	return false;
}


/*
=============
infront

returns 1 if the entity is in front(in sight) of this
=============
*/
bool infront(entity this, entity targ)
{
	fixedmakevectors(this.angles);
	vector vec = normalize(targ.origin - this.origin);
	float dot = vec * v_forward;
	float dottarget = VISIONCONE_NORMAL;
	if(this.spawnflags & SPAWNFLAG_NEARSIGHTED)
		dottarget = VISIONCONE_NEARSIGHTED;
	
	return (dot > dottarget);
}

/*======================================================================
 viswide (target entity)
  check to see if sightline is blocked by other monsters
  extra wide check using 3 traces, +/- 16 left/right and origin
  All three traces have to complete for a positive result
======================================================================*/
bool visblocked_wide(entity this, entity targ, vector s_ofset, vector t_ofset)
{
	vector spot3;
	vector tr_line = '0 0 0';
	bool tr_leftmon = false, tr_rightmon = false;
	fixedmakevectors(this.angles);

	// Traceline 1 - MIDDLE
	vector spot1 = this.origin + s_ofset_x * v_forward + s_ofset_y * v_right + s_ofset_z * v_up;
	vector spot2 = targ.origin + t_ofset;
	traceline (spot1, spot2, false, this);
	
	// Is trace entity the same as the target entity?
	if(trace_ent == targ)
		tr_line.x = 1;
	// Check for liquid surface block condition
	// Only need to do this once for the central traceline
	// If this fails then the left/right should as well
	if(trace_inopen && trace_inwater)
		tr_line.x = 0;

	// Traceline 2 - 32 units LEFT
	spot3 = spot1 - (v_right * 16);
	traceline(spot3, spot2, false, this);
	// Work out if clear shot, hit world or another entity
	if(trace_ent == targ)
		tr_line.y = 1;
	else if(trace_ent)
		tr_leftmon = true;

	// Traceline 3 - 32 units RIGHT
	spot3 = spot1 + (v_right * 16);
	traceline(spot3, spot2, false, this);
	// Work out if clear shot, hit world or another entity
	if(trace_ent == targ)
		tr_line.z = 1;
	else if(trace_ent)
		tr_rightmon = true;

	// Default = no clear shot (keep aim/moving)
	bool tr_result = true;
	// SIMPLE 3 complete traces = nothing blocking visibility
	if(tr_line.x + tr_line.y + tr_line.z == 3)
		tr_result = false;
	// Central trace is good but either side has hit something?
	else if(tr_line.x)
	{
		// Hit a monster on either side = always fail!
		if(tr_leftmon || tr_rightmon)
			tr_result = true;
		// The crssbow bolt is fired from the LEFT side, only right can be clear
		//else if(this.monsterdef == MON_DCROSSBOW)
		//{
		//	if(tr_line.y == 0 && tr_line.z == 1) tr_result = false;
		//}
		// Default - space available on either side
		else if(tr_line.y + tr_line.z == 1)
			tr_result = false;
	}

	return tr_result;
}

/*
=============
z_overlaps

returns 1 if the entity's bounds on z overlap those of monster
for checking if melee attacks are worthwhile
=============
*/
bool z_overlap(entity this, entity targ)
{
	return (this.absmin_z < targ.absmax_z && targ.absmin_z < this.absmax_z);
}


//============================================================================

int t_checknewclient(entity this, int check)
{
	int j;
	check = bound(1, check, maxclients);
	if(check == maxclients)
		j = 1;
	else
		j = check + 1;

	for( ; ; ++j)
	{
		// wrap around
		if(j == maxclients + 1)
			j = 1;
		// look up client
		entity ent = edict_num(j);
		// check if it is to be ignored, but never ignore the one we started on (prevent infinite loop)
		if(j != check && (wasfreed(ent) || ent.health <= 0 || (ent.flags & FL_NOTARGET)))
			continue;
		// found a valid client (possibly the same one again)
		break;
	}

	return j;
}

.int lastcheck;
.float lastchecktime;
entity t_checkclient(entity this)
{
#if 1
	// find a new check if on a new frame
	if(time - this.lastchecktime >= 0.1)
	{
		this.lastcheck = t_checknewclient(this, this.lastcheck);
		this.lastchecktime = time;
	}

	// return check if it might be visible
	entity ent = edict_num(this.lastcheck);
	if(wasfreed(ent) || ent.health <= 0 || (ent.flags & FL_NOTARGET))
		return NULL;

	// if current entity can't possibly see the check entity, return 0
	if(!checkpvs(this.origin + this.view_ofs, ent))
		return NULL;

	// might be able to see it
	return ent;
#else
	return checkclient(this);
#endif
}


//MED 10/18/96 added charmed stuff
//============================================================================
void UpdateCharmerGoal(entity this)
{
   vector d = normalize(this.origin - this.charmer.origin);

	if (this.huntingcharmer == 1)
	{
		entity targ = spawn();
		this.trigger_field = targ;
		setorigin(targ,this.charmer.origin);
		this.huntingcharmer = 2;
		this.goalentity = targ;
	}
	// TODO: shouldn't this be else if?
	else if (this.huntingcharmer == 2)
	{
		entity targ = this.trigger_field;
		traceline(this.origin,this.charmer.origin,true,this);
		if (trace_fraction == 1.0)
		{
//         dprint("can see ");
//         dprint(vtos(this.charmer.origin));
//         dprint("\n");
			setorigin(targ,this.charmer.origin);
		}
	}
	else
	{
		entity targ = this.trigger_field;
		setorigin(targ, this.charmer.origin + (d*300));
	}
}

//============================================================================
void HuntCharmer(entity this)
{
	this.huntingcharmer = 1;
	UpdateCharmerGoal(this);
//	this.goalentity = this.charmer;
	setthink(this, this.th_walk);
	this.ideal_yaw = vectoyaw(this.goalentity.origin - this.origin);
	this.nextthink = time + 0.1;
}

//============================================================================
void FleeCharmer(entity this)
{
	this.huntingcharmer = 1;
	UpdateCharmerGoal(this);
	this.huntingcharmer = 3;
//	this.goalentity = this.charmer;
	setthink(this, this.th_walk);
//	this.ideal_yaw = vectoyaw(this.originthis.goalentity.origin - this.origin);
	this.nextthink = time + 0.1;
}

//============================================================================
void StopHuntingCharmer(entity this)
{
	this.goalentity = NULL;
	if (this.huntingcharmer > 1 && this.trigger_field)
		delete(this.trigger_field);
	this.huntingcharmer = 0;
	setthink(this, this.th_stand);
	this.nextthink = time + 0.1;
}


//============================================================================

void HuntTarget(entity this)
{
	this.goalentity = this.enemy;
	if(this.th_run)
	{
		setthink(this, this.th_run);
		this.nextthink = time + 0.1;
	}
	this.ideal_yaw = vectoyaw(this.enemy.origin - this.origin);
	this.attack_finished = time + 1; // initial delay for attacking
}

void FoundTarget(entity this)
{
	// prevent getting stuck without an enemy (some triggers set the think frame to this)
	if(!this.enemy || this.enemy.health <= 0 || (this.enemy.flags & FL_NOTARGET))
	{
		this.enemy = NULL;
		if(this.th_stand)
		{
			setthink(this, this.th_stand);
			this.nextthink = time + 0.1;
		}
		return;
	}

	if(IS_PLAYER(this.enemy))
	{
		if(this.charmed) // && (this.charmer == this.enemy || this.charmer == this.enemy.charmer))
		{
			this.enemy = NULL;
			return;
		}

		// let other monsters see this monster for a while
		sight_entity = this;
		sight_entity_time = time;
	}
	else if(this.charmed && this.enemy.charmed) //&& (this.charmer == this.enemy.charmer))
	{
		this.enemy = NULL;
		return;
	}

	Monster mon = this.monsterdef;
	if(mon.mr_sight && !mon.mr_sight(mon, this))
		return;

	this.show_hostile = time + 1;		// wake up other monsters
	this.aggro_time = time; // stay on target for a bit
	HuntTarget(this);
}

/*
===========
FindTarget

Self is currently not attacking anything, so try to find a target

Returns true if an enemy was sighted

When a player fires a missile, the point of impact becomes a fakeplayer so
that monsters that see the impact will respond as if they had seen the
player.

To avoid spending too much time, only a single client(or fakeclient) is
checked each frame.  This means multi player games will have slightly
slower noticing monsters.
============
*/
bool FindTarget(entity this)
{
	entity client = NULL;

	// First, if we are attacking friends, try to find another friend
	if((this.spawnflags & MONSTER_ATTACK_FRIEND) && this.target && this.target != "" && IsMGMap())
	{
		RandomSelection_Init();
		FOREACH_ENTITY_STRING(targetname, this.target,
		{
			if(!it.takedamage)
				continue;
			RandomSelection_AddEnt(it, 1, 1);
		});

		entity f = RandomSelection_chosen_ent;
		if(f)
		{
			this.enemy = f;
			FoundTarget(this);
			return true;
		}
	}

// if the first spawnflag bit is set, the monster will only wake up on
// really seeing the player, not another monster getting angry

// spawnflags & 3 is a big hack, because zombie crucified used the first
// spawn flag prior to the ambush flag, and I forgot about it, so the second
// spawn flag works as well
	//MED 10/17/96 added charmed stuff
	if(this.charmed)
	{
		//this.effects |= EF_DIMLIGHT;
		if(this.huntingcharmer > 0)
		{
			UpdateCharmerGoal(this);
//          this.goalentity = this.charmer;
			if(vdist(this.origin - this.goalentity.origin, <, MIN_CHARMER_DISTANCE))
			{
//              dprint("stopping\n");
				if((this.huntingcharmer == 3) && (vdist(this.origin - this.goalentity.origin, >, TOOCLOSE_CHARMER_DISTANCE)))
					return false;
//              this.huntingcharmer = 0;
				StopHuntingCharmer(this);
				return true;
			}
		}
		else if(vdist(this.origin - this.charmer.origin, >, MAX_CHARMER_DISTANCE))
		{
//          this.huntingcharmer = 1;
//          dprint("hunting\n");
			HuntCharmer(this);
			return false;
		}
		else if(vdist(this.origin - this.charmer.origin, <, TOOCLOSE_CHARMER_DISTANCE))
		{
//          this.huntingcharmer = 1;
//          dprint("fleeing\n");
			FleeCharmer(this);
			return false;
		}
	}

	if((this.spawnflags & 4) && IsImpelMap())
		return false;

	if((this.spawnflags & MONSTER_IGNOREPLAYER) && !IsMGMap())
		return false;

	// if the first spawnflag bit is set, the monster will only wake up on
	// really seeing the player, not another monster getting angry

	// spawnflags & 3 is a big hack, because zombie crucified used the first
	// spawn flag prior to the ambush flag, and I forgot about it, so the second
	// spawn flag works as well
	if(sight_entity_time >= time - 0.1 && !(this.spawnflags & 3) && !this.charmed)
	{
		client = sight_entity;
		if(client.enemy == this.enemy)
			return true;
	}
	else if(this.charmed)
	{
		entity selected = NULL;
		float dist = CHARMED_RADIUS;
		FOREACH_ENTITY_RADIUS(this.origin, CHARMED_RADIUS, IS_MONSTER(it) && !(it.flags & FL_NOTARGET) && it.health > 0 && !(it.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD),
		{
			if(visible(this, it) && this.visible_distance < dist)
			{
				if(it != this && it != this.charmer && it.charmer != this.charmer)
				{
					selected = it;
					dist = this.visible_distance;
				}
			}
		});
		if(!selected)
			return false;

		client = selected;
	}
	else
	{
		client = t_checkclient(this);
		if(!client)
			return false;	// current check entity isn't in PVS
	}

	if(client == this.enemy)
		return false;

	if(!this.charmed && (client.flags & FL_NOTARGET))
		return false;
	if(StatusEffects_active(STATUSEFFECT_Invisibility, client))
		return false;

	if(this.monsterdef.spawnflags & MON_FLAG_NOTARGET)
		return false;

	if(!angry_monsters)
	{
		int r = range(this, client);
		if(r == RANGE_FAR && !(this.monsterdef.spawnflags & MONSTER_TYPE_BOSS)) // give bosses a further range
			return false;
			
		if(!visible(this, client))
			return false;

		if(this.charmed) { /* do nothing */ }
		else if(r == RANGE_NEAR)
		{
			if(client.show_hostile < time && !infront(this, client))
				return false;
		}
		else if(r == RANGE_MID)
		{
			if( /* client.show_hostile < time || */ !infront(this, client))
				return false;
		}
	}
	else if(this.enemy)
	{
		if(!visible(this, client))
			return false;
	}
	
//
// got one
//
	this.enemy = client;
	if(!this.charmed && !this.enemy.charmed && !IS_PLAYER(this.enemy) && !this.enemy.monster_attack)
	{
		this.enemy = this.enemy.enemy;
		if((!IS_PLAYER(this.enemy) && !this.enemy.monster_attack) || this.enemy.health < 1 || (this.enemy.flags & FL_NOTARGET))
		{
			this.enemy = NULL;
			return false;
		}
	}

	if(!(this.monsterdef.spawnflags & MON_FLAG_NOAGGRO))
		FoundTarget(this);

	return true;
}


//=============================================================================

void ai_forward(entity this, float dist)
{
	t_walkmove(this, this.angles_y, dist);
}

void ai_back(entity this, float dist)
{
	t_walkmove(this, (this.angles_y+180), dist);
}


/*
=============
ai_pain

stagger back a bit
=============
*/
void ai_pain(entity this, float dist)
{
	ai_back(this, dist);
/*
	float away = anglemods(vectoyaw(this.origin - this.enemy.origin) 
	+ 180*(random()- 0.5) );
	
	t_walkmove(this, away, dist);
*/
}

/*
=============
ai_painforward

stagger back a bit
=============
*/
void ai_painforward(entity this, float dist)
{
	t_walkmove(this, this.ideal_yaw, dist);
}

/*
=============
ai_walk

The monster is walking its beat
=============
*/
void ai_walk(entity this, float dist)
{
	if(!IS_MONSTER(this))
		return;
	// check for noticing a player
	if(FindTarget(this))
		return;

	t_movetogoal(this, dist);

	if(this.huntingcharmer)
		this.nextthink = time + ((this.nextthink - time) / 2);
}


/*
=============
ai_stand

The monster is staying in one place for a while, with slight angle turns
=============
*/
void ai_stand(entity this)
{
	if(FindTarget(this))
		return;

	if(this.pausetime != -1 && time > this.pausetime)
	{
		setthink(this, this.th_walk);
		this.nextthink = time + 0.1;
	}
}

/*
=============
ai_turn

don't move, but turn towards ideal_yaw
=============
*/
void ai_turn(entity this)
{
	if(FindTarget(this))
		return;
	
	changeyaw(this);
}

//MED 11/10/96 added ai_turn_in_place
/*
=============
ai_turn_in_place

don't move, but turn towards ideal_yaw
=============
*/
void ai_turn_in_place(entity this)
{
	this.nextthink = time + 0.1;
	this.enemy_yaw = vectoyaw(this.enemy.origin - this.origin);
	float delta = fabs(this.angles_y - this.enemy_yaw);
	if (delta > MIN_ANGLE_DELTA)
	{
		this.ideal_yaw = this.enemy_yaw;
		changeyaw(this);
	}
	else
		setthink(this, this.th_run);
}

//=============================================================================

/*
=============
ChooseTurn
=============
*/
void ChooseTurn(entity this, vector dest3)
{
	vector dir = this.origin - dest3;
	vector newdir = vec2(trace_plane_normal.y, trace_plane_normal.x);
	
	if(dir * newdir > 0)
	{
		dir.x = 0 - trace_plane_normal.y;
		dir.y = trace_plane_normal.x;
	}
	else
	{
		dir.x = trace_plane_normal.y;
		dir.y = 0 - trace_plane_normal.x;
	}

	dir.z = 0;
	this.ideal_yaw = vectoyaw(dir);	
}

/*
============
FacingIdeal

============
*/
bool FacingIdeal(entity this)
{
	float delta = anglemods(this.angles_y - this.ideal_yaw);
	if(delta > 45 && delta < 315)
		return false;
	return true;
}


//=============================================================================

bool CheckAnyAttack(entity this)
{
	if(!this.enemy_visible)
		return false;
	if(this.checkattack)
		return this.checkattack(this);
	return CheckAttack(this);
}


/*
=============
ai_run_melee

Turn and close until within an angle to launch a melee attack
=============
*/
void ai_run_melee(entity this)
{
	this.ideal_yaw = this.enemy_yaw;
	changeyaw(this);

	if(this.th_melee && FacingIdeal(this))
	{
		this.th_melee(this);
		this.attack_state = AS_STRAIGHT;
	}
}


/*
=============
ai_run_missile

Turn in place until within an angle to launch a missile attack
=============
*/
void ai_run_missile(entity this)
{
	this.ideal_yaw = this.enemy_yaw;
	changeyaw(this);
	if(this.th_missile && FacingIdeal(this))
	{
		this.th_missile(this);
		this.attack_state = AS_STRAIGHT;
	}
}


/*
=============
ai_run_slide

Strafe sideways, but stay at approximately the same range
=============
*/
void ai_run_slide(entity this, float dist)
{
	this.ideal_yaw = this.enemy_yaw;
	changeyaw(this);
	float ofs = (this.lefty) ? 90 : -90;
	
	if(t_walkmove(this, this.ideal_yaw + ofs, dist))
		return;
		
	this.lefty = 1 - this.lefty;
	
	t_walkmove(this, this.ideal_yaw - ofs, dist);
}


//MED
/*
=============
ai_run_dodge

Strafe sideways, but continue moving towards the enemy
Used by the Scourge.
=============
*/
void ai_run_dodge(entity this, float dist)
{
/*
// attempt to jump over missiles
   if (this.enemy.weaponframe == 1)
	  {
	  if (this.flags & FL_ONGROUND)
		 {
		 this.origin_z = this.origin_z + 1;
		 this.velocity = this.velocity + '0 0 500';
		 this.flags = this.flags - FL_ONGROUND;
		 }
	  this.ltime = this.ltime + 1.0;
	  }
*/
	this.nextthink = time + 0.1;

	float ofs = (this.lefty) ? 40 : -40;

	if(time > this.ltime)
	{
		this.lefty = 1 - this.lefty;
		this.ltime = time + 0.8;
	}

	float newyaw = this.enemy_yaw + ofs;
	this.ideal_yaw = this.enemy_yaw;
	if(t_walkmove(this, newyaw, dist))
	{
		changeyaw(this);
		return;
	}

	this.lefty = 1 - this.lefty;
	this.ltime = time + 0.8;
	newyaw = this.enemy_yaw - ofs;
	this.ideal_yaw = this.enemy_yaw;
	t_walkmove(this, newyaw, dist);
	changeyaw(this);
}


/*
=============
ai_run

The monster has an enemy it is trying to kill
=============
*/
.bool run_straight;
.float endtime; // reused
void ai_run(entity this, float dist)
{
	if(!IS_MONSTER(this))
		return;
// see if the enemy is dead
	if(wasfreed(this.enemy) || this.enemy.health <= 0 || (this.charmed && (this.charmer == this.enemy)) || (this.enemy.flags & FL_NOTARGET))
	{
		this.enemy = NULL;
		if(this.charmed)
		{
			HuntCharmer(this);
			return;
		}
	// FIXME: look all around for other targets
		if(this.oldenemy.health > 0 && !(this.oldenemy.flags & FL_NOTARGET) && !StatusEffects_active(STATUSEFFECT_Invisibility, this.oldenemy))
		{
			this.enemy = this.oldenemy;
			HuntTarget(this);
		}
		else
		{
			if(this.movetarget)
				this.th_walk(this);
			else
				this.th_stand(this);
			return;
		}
	}

	this.show_hostile = time + 1; // wake up other monsters

// check knowledge of enemy
	this.enemy_visible = visible(this, this.enemy);
	if(this.enemy_visible)
		this.search_time = time + 5;

// look for other coop players
	if(coop && this.search_time < time && !this.charmed)
	{
		if(FindTarget(this))
			return;
	}

	//this.enemy_infront = infront(this, this.enemy);
	this.enemy_range = range(this, this.enemy);
	this.enemy_yaw = vectoyaw(this.enemy.origin - this.origin);
	
	if(this.attack_state == AS_MISSILE)
	{
//dprint("ai_run_missile\n");
		ai_run_missile(this);
		return;
	}
	if(this.attack_state == AS_MELEE)
	{
//dprint("ai_run_melee\n");
		ai_run_melee(this);
		return;
	}

	if(CheckAnyAttack(this))
		return;					// beginning an attack
		
	if(this.attack_state == AS_SLIDING)
	{
		ai_run_slide(this, dist);
		return;
	}

	if (this.attack_state == AS_DODGING)
	{
		ai_run_dodge(this, dist);
		return;
	}

//MED 11/11/96
	if(this.run_straight && time > this.endtime)
	{
		this.run_straight = false;
		bool axis = t_walkmove(this, this.angles_y, dist);
		if (!axis)
		{
			this.endtime = time + 3;
			t_movetogoal(this, dist); // fall back to normal Quake movement behavior.
		}
//      else
//         changeyaw();
	}
	else
	{
		t_movetogoal(this, dist); // fall back to normal Quake movement behavior.
	}
}
