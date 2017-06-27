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


#if 0
// hacked in version of movetogoal (to be rewritten)

bool t_stepdirection(entity this, float yaw, float dist)
{
	this.ideal_yaw = yaw;
	ChangeYaw(this);

	/*float oldyaw = yaw; // before we hack it apart
	yaw = yaw * M_PI * 2 / 360;
	vector move = vec2(cos(yaw) * dist, sin(yaw) * dist);*/
	vector oldorg = this.origin;

	if(walkmove(this, yaw, dist))
	{
		float delta = this.angles.y - this.ideal_yaw;
		if(delta > 45 && delta < 315)
			setorigin(this, oldorg);
		// leave the linking to the engine? TODO
		return true;
	}

	return false;
}

void t_newchasedir(entity this, entity targ, float dist)
{
	float di_nodir = -1;
	vector d;
	float olddir = anglemods((this.ideal_yaw / 45) * 45);
	float turnaround = anglemods(olddir - 180);
	float tdir;

	vector delta = vec2(targ.origin - this.origin);

	if(delta.x > 10)
		d.x = 0;
	else if(delta.x < -10)
		d.x = 180;
	else
		d.x = di_nodir;
	if(delta.y < -10)
		d.y = 270;
	else if(delta.y > 10)
		d.y = 90;
	else
		d.y = di_nodir;

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
	if(random() < 0.33 || fabs(delta.y) > fabs(delta.x))
		d = vec2(d.y, d.x);

	if(d.x != di_nodir && d.x != turnaround && t_stepdirection(this, d.x, dist))
		return;
	if(d.y != di_nodir && d.y != turnaround && t_stepdirection(this, d.y, dist))
		return;

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

	if(!checkbottom(this))
		this.flags |= FL_PARTIALGROUND;
}

bool t_closeenough(entity this, entity goal, float dist)
{
	if(goal.absmin.x > (this.absmax.x + dist)) return false;
	if(goal.absmin.y > (this.absmax.y + dist)) return false;
	if(goal.absmin.z > (this.absmax.z + dist)) return false;

	if(goal.absmax.x < (this.absmin.x - dist)) return false;
	if(goal.absmax.y < (this.absmin.y - dist)) return false;
	if(goal.absmax.z < (this.absmin.z - dist)) return false;

	return true;
}
#endif

void t_movetogoal(entity this, float dist)
{
#if 0
	if(!(this.flags & (FL_ONGROUND | FL_FLY | FL_SWIM)))
		return;

	// if the next step hits the enemy, return immediately
	if(this.enemy && t_closeenough(this, this.goalentity, dist))
		return;

	// bump around...
	if(random() < 0.33 || !t_stepdirection(this, this.ideal_yaw, dist))
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
	walkmove(this, this.angles_y, dist);
}

void ai_back(entity this, float dist)
{
	walkmove(this, (this.angles_y+180), dist);
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
	
	walkmove(this, away, dist);
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
	walkmove(this, this.ideal_yaw, dist);
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
	
	ChangeYaw(this);
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
	ChangeYaw(this);

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
	ChangeYaw(this);
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
	ChangeYaw(this);
	float ofs = (this.lefty) ? 90 : -90;
	
	if(walkmove(this, this.ideal_yaw + ofs, this.move_dist))
		return;
		
	this.lefty = 1 - this.lefty;
	
	walkmove(this, this.ideal_yaw - ofs, this.move_dist);
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

