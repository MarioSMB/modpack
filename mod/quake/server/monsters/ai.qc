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

void t_linkedict(entity this, bool touch_triggers)
{
	setorigin(this, this.origin); // calls SV_LinkEdict
	if(touch_triggers)
		_Movetype_LinkEdict_TouchAreaGrid(this);
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
					t_linkedict(this, true);
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
				t_linkedict(this, true);
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
		t_linkedict(this, true);

	if(!t_checkbottom(this))
	{
		if(this.flags & FL_PARTIALGROUND)
		{
			// entity had floor mostly pulled out from underneath it
			// and is trying to correct
			if(relink)
			{
				// do nothing for now
				t_linkedict(this, true);
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
		t_linkedict(this, true);
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
		t_linkedict(this, true);
		return true;
	}

	// relink...
	t_linkedict(this, true);

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


//
// when a monster becomes angry at a player, that monster will be used
// as the sight target the next frame so that monsters near that one
// will wake up even if they wouldn't have noticed the player
//
entity sight_entity;
float sight_entity_time;

void FoundTarget(entity this);

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
		objerror(this, "monster_movetarget: no targetname");
		
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
void t_movetarget(entity this, entity toucher)
{
	if(toucher.movetarget != this)
		return;
	if(toucher.enemy)
		return; // fighting, not following a path

	if(toucher.classname == "monster_ogre")
		_sound(toucher, CH_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE); // play chainsaw drag sound

	if(this.target && this.target != "")
	{
		toucher.goalentity = toucher.movetarget = find (NULL, targetname, this.target);
		if (!toucher.movetarget)
		{
			toucher.pausetime = -1;
			toucher.th_stand(toucher);
			return;
		}
		else if(MP_HIPNOTIC && this.delay)
		{
			toucher.pausetime = time + this.delay;
			toucher.th_stand(toucher);
		}
		else
			toucher.ideal_yaw = vectoyaw(toucher.goalentity.origin - toucher.origin);
	}
	else
	{
		toucher.pausetime = -1;
		toucher.th_stand(toucher);
		return;
	}
}


/*
=============
t_followtarget

Something has bumped into a followtarget.  If it is a monster
moving towards it, change the next destination and continue.
==============
*/
void t_followtarget(entity this, entity toucher)
{
	if(!IS_MONSTER(toucher))
		return;
	if(toucher.classname == "monster_decoy")
		return;
//  if (toucher.enemy == NULL)
//  	return;
	if (toucher.wetsuit_time > time)
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
		setthink(toucher, toucher.th_walk);
	}

	toucher.goalentity = toucher.movetarget = find (NULL, targetname, this.target);

	toucher.ideal_yaw = vectoyaw(toucher.goalentity.origin - toucher.origin);
	toucher.wetsuit_time = time + 2;
	if(!toucher.movetarget)
	{
		if (toucher.oldenemy != NULL)
		{
			toucher.enemy = toucher.oldenemy;
			FoundTarget(toucher);
			return;
		}
		else
		{
			entity client = checkclient(toucher);
			if (!client)
			{
				toucher.enemy = client;
				FoundTarget(toucher);
				return;
			}
			toucher.pausetime = -1;
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
	if(!MP_HIPNOTIC) { delete(this); return; }
	
   followtarget_f(this);
}

/*QUAKED path_follow2 (0.5 0.3 0) (-8 -8 -8) (8 8 8)
Monsters will stop what they are doing and follow to the path
*/

spawnfunc(path_follow2)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

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
	
	if(vdist(spot1 - spot2, <, 120))
		return RANGE_MELEE;
	if(vdist(spot1 - spot2, <, 500))
		return RANGE_NEAR;
	if(vdist(spot1 - spot2, <, 1000))
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
		visible_distance = vlen(spot2 - spot1);
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
	makevectors(this.angles);
	vector vec = normalize(targ.origin - this.origin);
	float dot = vec * v_forward;
	
	if(dot > 0.3)
		return true;
	return false;
}


//============================================================================


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
	setthink(this, this.th_run);
	this.ideal_yaw = vectoyaw(this.enemy.origin - this.origin);
	this.nextthink = time + 0.1;
	SUB_AttackFinished(this, 1);	// wait a while before first attack
}

.string(entity this) sightsound;
void SightSound(entity this)
{
	if(this.classname == "monster_gremlin" && this.stoleweapon != 0)
		return; // don't play a sound if we have a weapon?

	float atten = ATTN_NORM;
	if(this.classname == "monster_armagon")
		atten = 0.1;

	if(this.sightsound)
		_sound(this, CH_VOICE, this.sightsound(this), 1, atten);
}

void FoundTarget(entity this)
{
	if(IS_PLAYER(this.enemy))
	{
		if(MP_HIPNOTIC && this.charmed && (this.charmer == this.enemy || this.charmer == this.enemy.charmer))
		{
			this.enemy = NULL;
			return;
		}

		// let other monsters see this monster for a while
		sight_entity = this;
		sight_entity_time = time;
	}
	else if(MP_HIPNOTIC && this.charmed && (this.charmer == this.enemy.charmer))
	{
		this.enemy = NULL;
		return;
	}
	else if(MP_ROGUE && (this.spawnflags & 2) && this.classname == "monster_knight" && this.takedamage == DAMAGE_NO) // special case, could be tweaked!
	{
		this.enemy = NULL;
		return;
	}
	
	this.show_hostile = time + 1;		// wake up other monsters

	SightSound(this);
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

// if the first spawnflag bit is set, the monster will only wake up on
// really seeing the player, not another monster getting angry

// spawnflags & 3 is a big hack, because zombie crucified used the first
// spawn flag prior to the ambush flag, and I forgot about it, so the second
// spawn flag works as well
	//MED 10/17/96 added charmed stuff
	if(MP_HIPNOTIC && this.charmed)
	{
		this.effects |= EF_DIMLIGHT;
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

	if(sight_entity_time >= time - 0.1 && !(this.spawnflags & 3) && !this.charmed)
	{
		client = sight_entity;
		if(client.enemy == this.enemy)
			return false;
	}
	else if (this.charmed)
	{
		entity selected = NULL;
		float dist = CHARMED_RADIUS;
		entity head = findradius(this.origin, CHARMED_RADIUS);
		while(head)
		{
			if(!(head.flags & FL_NOTARGET) && IS_MONSTER(head))
			{
				if (visible(this, head) && (visible_distance < dist) && (head.health>0))
				{
					if ((head != this) && (head != this.charmer) && (head.charmer != this.charmer))
					{
						selected = head;
						dist = visible_distance;
					}
				}
			}
			head = head.chain;
		}
		if (selected == world)
			return false;

		client = selected;
	}
	else
	{
		client = checkclient(this);
		if(!client)
			return false;	// current check entity isn't in PVS
	}

	if(client == this.enemy)
		return false;

	if(!this.charmed && (client.flags & FL_NOTARGET))
		return false;
	if(client.items & IT_INVISIBILITY)
		return false;

	int r = range(this, client);
	if(r == RANGE_FAR)
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
	
//
// got one
//
	this.enemy = client;
	if(!this.charmed && !this.enemy.charmed && !IS_PLAYER(this.enemy))
	{
		this.enemy = this.enemy.enemy;
		if(!IS_PLAYER(this.enemy))
		{
			this.enemy = NULL;
			return false;
		}
	}

	if(this.classname != "monster_dragon")
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
.float move_dist;
void ai_walk(entity this, float dist)
{
	this.move_dist = dist;

	// check for noticing a player
	if(FindTarget(this))
		return;

	t_movetogoal(this, dist);

	if(MP_HIPNOTIC && this.huntingcharmer)
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
		this.th_walk(this);
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

.bool(entity this) checkattack;
bool CheckAnyAttack(entity this)
{
	if(!this.enemy_vis)
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

	if(FacingIdeal(this))
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
	if(FacingIdeal(this))
	{
		this.th_missile(this);
		this.attack_state = AS_STRAIGHT;
	}
}


/*
=============
ai_run_slide

Strafe sideways, but stay at aproximately the same range
=============
*/
void ai_run_slide(entity this)
{
	this.ideal_yaw = this.enemy_yaw;
	changeyaw(this);
	float ofs = (this.lefty) ? 90 : -90;
	
	if(t_walkmove(this, this.ideal_yaw + ofs, this.move_dist))
		return;
		
	this.lefty = 1 - this.lefty;
	
	t_walkmove(this, this.ideal_yaw - ofs, this.move_dist);
}


//MED
/*
=============
ai_run_dodge

Strafe sideways, but continue moving towards the enemy
Used by the Scourge.
=============
*/
void ai_run_dodge(entity this)
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
	if(t_walkmove(this, newyaw, this.move_dist))
	{
		changeyaw(this);
		return;
	}

	this.lefty = 1 - this.lefty;
	this.ltime = time + 0.8;
	newyaw = this.enemy_yaw - ofs;
	this.ideal_yaw = this.enemy_yaw;
	t_walkmove(this, newyaw, this.move_dist);
	changeyaw(this);
}


/*
=============
ai_run

The monster has an enemy it is trying to kill
=============
*/
.bool run_straight;
void ai_run(entity this, float dist)
{
	this.move_dist = dist;
// see if the enemy is dead
	if(this.enemy.health <= 0 || (this.charmed && (this.charmer == this.enemy)))
	{
		this.enemy = NULL;
		if(MP_HIPNOTIC && this.charmed)
		{
			HuntCharmer(this);
			return;
		}
	// FIXME: look all around for other targets
		if(this.oldenemy.health > 0)
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
	this.enemy_vis = visible(this, this.enemy);
	if(this.enemy_vis)
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

	//MED
	if (MP_HIPNOTIC && this.th_turn)
	{
		float angledelta = fabs(this.angles_y - this.enemy_yaw);
		if (angledelta > MIN_ANGLE_DELTA)
		{
			this.th_turn(this);
			return;
		}
	}
	
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
		ai_run_slide(this);
		return;
	}

	if (MP_HIPNOTIC && this.attack_state == AS_DODGING)
	{
		ai_run_dodge(this);
		return;
	}

//MED 11/11/96
	if(MP_HIPNOTIC && this.run_straight && time > this.endtime)
	{
		this.run_straight = false;
		bool axis = t_walkmove(this, this.angles_y, this.move_dist);
		if (!axis)
		{
			this.endtime = time + 3;
			t_movetogoal(this, dist);      // done in C code...
		}
//      else
//         changeyaw();
	}
	else
	{
		// head straight in
		t_movetogoal(this, dist);      // done in C code...
	}
}
