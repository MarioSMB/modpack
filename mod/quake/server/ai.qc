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
	start = stop = vec2((minz + maxz) * 0.5);
	start.z = stop.z = 2 * PHYS_STEPHEIGHT(this);

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
			if(trace_fraction == 1.0 || mid - trace_endpos.z > PHYS_STEPHEIGHT(this))
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
	entity targ;

	// flying monsters don't step up
	if((this.flags & FL_SWIM) || (this.flags & FL_FLY))
	{
		// try one move with vertical motion, then one without
		for(int j = 0; j < 2; ++j)
		{
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
				if((this.flags & FL_SWIM) && (Mod_Q1BSP_SuperContentsFromNativeContents(pointcontents(trace_endpos)) & DPCONTENTS_LIQUIDSMASK))
					return false; // swim monster left water

				this.origin = trace_endpos;
				if(relink)
				{
					// do nothing for now
					setorigin(this, this.origin);
				}
				return true;
			}

			if(!targ)
				break;
		}

		return false;
	}

	// push down from a step height above the desired position
	neworg.z += PHYS_STEPHEIGHT(this);
	vector end = neworg;
	end.z -= PHYS_STEPHEIGHT(this) * 2;

	tracebox(neworg, this.mins, this.maxs, end, MOVE_NORMAL, this);
	if(trace_startsolid)
	{
		neworg.z -= PHYS_STEPHEIGHT(this);
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
				setorigin(this, this.origin);
			}
			UNSET_ONGROUND(this);
			return true;
		}

		return false; // walked off an edge
	}

	// check point traces down for dangling corners
	setorigin(this, trace_endpos);

	if(!t_checkbottom(this))
	{
		if(this.flags & FL_PARTIALGROUND)
		{
			// entity had floor mostly pulled out from underneath it
			// and is trying to correct
			if(relink)
			{
				// do nothing for now
				setorigin(this, this.origin);
			}
			return true;
		}
		this.origin = oldorg;
		if(relink)
			setorigin(this, this.origin);
		return false;
	}

	if(this.flags & FL_PARTIALGROUND)
		this.flags &= ~FL_PARTIALGROUND;

	// gameplayfix: check if reached pretty steep plane and bail
	if(!((this.flags & FL_SWIM) || (this.flags & FL_FLY)) && STAT(GAMEPLAYFIX_NOSTEPMOVEONSTEEPSLOPES, this))
	{
		if(trace_plane_normal.z < 0.5)
		{
			this.origin = oldorg;
			if(relink)
				setorigin(this, this.origin);
			return false;
		}
	}

	this.groundentity = trace_ent;

	// the move is ok
	if(relink)
	{
		// do nothing for now
		setorigin(this, this.origin);
	}

	return true;
}

bool t_walkmove(entity this, float yaw, float dist)
{
#if 1
	if(!(IS_ONGROUND(this) || (this.flags & FL_SWIM) || (this.flags & FL_FLY)))
		return false;

	yaw = yaw * M_PI * 2 / 360;
	vector move = vec2(cos(yaw) * dist, sin(yaw) * dist);

	return t_movestep(this, move, true, false);
#else
	return walkmove(this, yaw, dist);
#endif
}

// hacked in version of movetogoal (to be rewritten)
#if 0
bool t_stepdirection(entity this, float yaw, float dist)
{
	this.ideal_yaw = yaw;
	changeyaw(this);

	yaw = yaw * M_PI * 2 / 360;
	vector move = vec2(cos(yaw) * dist, sin(yaw) * dist);
	vector oldorg = this.origin;

	if(t_movestep(this, move, false, false))
	{
		float delta = this.angles.y - this.ideal_yaw;
		if(delta > 45 && delta < 315)
			this.origin = oldorg; // not turned far enough, so don't take the step
		// leave the linking to the engine? TODO
		setorigin(this, this.origin);
		return true;
	}

	// relink...
	setorigin(this, this.origin);

	return false;
}

void t_newchasedir(entity this, entity targ, float dist)
{
	float di_nodir = -1;
	vector d;
	float olddir = anglemods(rint(this.ideal_yaw / 45) * 45);
	float turnaround = anglemods(olddir - 180);
	float tdir;

	vector delta = vec2(targ.origin - this.origin);

	d.x = ((delta.x > 10) ? 0 : ((delta.x < -10) ? 180 : di_nodir));
	d.y = ((delta.y < -10) ? 270 : ((delta.y > 10) ? 90 : di_nodir));

	// try direct route
	if(d.x != di_nodir && d.y != di_nodir)
	{
		if(d.x == 0)
			tdir = (d.y == 90) ? 45 : 315;
		else
			tdir = (d.y == 90) ? 135 : 215;

		if(tdir != turnaround && t_stepdirection(this, tdir, dist))
			return;
	}

	// try other directions
	if(random() < 0.5 || fabs(delta.y) > fabs(delta.x))
		d = vec2(d.y, d.x);

	if(d.x != di_nodir && d.x != turnaround && t_stepdirection(this, d.x, dist))
		return;
	if(d.y != di_nodir && d.y != turnaround && t_stepdirection(this, d.y, dist))
		return;

	// there is no direct path to the player, so pick another direction

	if(olddir != di_nodir && t_stepdirection(this, olddir, dist))
		return;

	if(random() < 0.5) // randomly determine direction of search
	{
		for(tdir = 0; tdir <= 315; tdir += 45)
		{
			if(tdir != turnaround && t_stepdirection(this, tdir, dist))
				return;
		}
	}
	else
	{
		for(tdir = 315; tdir >= 0; tdir -= 45)
		{
			if(tdir != turnaround && t_stepdirection(this, tdir, dist))
				return;
		}
	}

	if(turnaround != di_nodir && t_stepdirection(this, turnaround, dist))
		return;

	this.ideal_yaw = olddir; // can't move

	// if a bridge was pulled out from underneath a monster, it may not have a valid standing position at all
	if(!t_checkbottom(this))
		this.flags |= FL_PARTIALGROUND;
}
#endif

void t_movetogoal(entity this, float dist)
{
#if 0
	if(!(IS_ONGROUND(this) || (this.flags & FL_SWIM) || (this.flags & FL_FLY)))
		return;

	// if the next step hits the enemy, return immediately
	if(this.enemy)
	{
		vector rdist = '1 1 1' * dist;
		if(boxesoverlap(this.absmin - rdist, this.absmax + rdist, this.goalentity.absmin, this.goalentity.absmax))
			return;
	}

	// bump around...
	if(random() <= 0.25 || !t_stepdirection(this, this.ideal_yaw, dist))
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
		_sound(toucher, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE); // play chainsaw drag sound

	toucher.goalentity = toucher.movetarget = find (NULL, targetname, toucher.target);
	toucher.ideal_yaw = vectoyaw(toucher.goalentity.origin - toucher.origin);
	if (!toucher.movetarget)
	{
		toucher.pausetime = time + 999999;
		toucher.th_stand(toucher);
		return;
	}
};



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
	traceline(spot1, spot2, true, this); // see through other monsters
	
	if(trace_inopen && trace_inwater)
		return false; // sight line crossed contents
	if(trace_fraction == 1)
		return true;
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
	if(this.sightsound)
		_sound(this, CHAN_VOICE, this.sightsound(this), 1, ATTN_NORM);
}

void FoundTarget(entity this)
{
	if(IS_PLAYER(this.enemy))
	{	// let other monsters see this monster for a while
		sight_entity = this;
		sight_entity_time = time;
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
	if(sight_entity_time >= time - 0.1 && !(this.spawnflags & 3) )
	{
		client = sight_entity;
		if(client.enemy == this.enemy)
			return false;
	}
	else
	{
		client = checkclient(this);
		if(!client)
			return false;	// current check entity isn't in PVS
	}

	if(client == this.enemy)
		return false;

	if(client.flags & FL_NOTARGET)
		return false;
	if(client.items & IT_INVISIBILITY)
		return false;

	int r = range(this, client);
	if(r == RANGE_FAR)
		return false;
		
	if(!visible(this, client))
		return false;

	if(r == RANGE_NEAR)
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
	if(!IS_PLAYER(this.enemy))
	{
		this.enemy = this.enemy.enemy;
		if(!IS_PLAYER(this.enemy))
		{
			this.enemy = NULL;
			return false;
		}
	}
	
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
	float away = anglemod(vectoyaw(this.origin - this.enemy.origin) 
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

The monster is walking it's beat
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
	
	if(time > this.pausetime)
	{
		this.th_walk(this);
		return;
	}
	
// change angle slightly

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
	float delta = anglemod(this.angles_y - this.ideal_yaw);
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


/*
=============
ai_run

The monster has an enemy it is trying to kill
=============
*/
void ai_run(entity this, float dist)
{
	this.move_dist = dist;
// see if the enemy is dead
	if(this.enemy.health <= 0)
	{
		this.enemy = NULL;
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
	if(coop && this.search_time < time)
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
		ai_run_slide(this);
		return;
	}
		
// head straight in
	t_movetogoal(this, dist);		// done in C code...
}

