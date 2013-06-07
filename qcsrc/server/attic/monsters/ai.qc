void() movetarget_f;
void() t_movetarget;
void() FoundTarget;

float MONSTER_WANDER = 64; // disable wandering around
float MONSTER_APPEAR = 128; // spawn invisible, and appear when triggered

.float ismonster;
.float monsterawaitingteleport; // avoid awaking monsters in teleport rooms

// when a monster becomes angry at a player, that monster will be used
// as the sight target the next frame so that monsters near that one
// will wake up even if they wouldn't have noticed the player
//
entity sight_entity;
float sight_entity_time;

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


//
// globals
//
//float current_yaw;

float(float v) anglemod =
{
	v = v - 360 * floor(v / 360);
	return v;
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


void() movetarget_f =
{
	if (!self.targetname)
		objerror ("monster_movetarget: no targetname");

	self.solid = SOLID_TRIGGER;
	self.touch = t_movetarget;
	setsize (self, '-8 -8 -8', '8 8 8');
}

/*QUAKED path_corner (0.5 0.3 0) (-8 -8 -8) (8 8 8)
Monsters will continue walking towards the next target corner.
*/
void() path_corner =
{
	movetarget_f ();
}

/*
=============
t_movetarget

Something has bumped into a movetarget.  If it is a monster
moving towards it, change the next destination and continue.
==============
*/
void() t_movetarget =
{
	entity temp;

	if (other.health < 1)
		return;
	if (other.movetarget != self)
		return;

	if (other.enemy)
		return;		// fighting, not following a path

	temp = self;
	self = other;
	other = temp;

	/* PLEASE FIX THE SOUND CHANNEL BEFORE ACTIVATING THIS
	if (self.classname == "monster_ogre")
		sound (self, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);// play chainsaw drag sound
	*/

//dprint ("t_movetarget\n");
	self.goalentity = self.movetarget = find (world, targetname, other.target);
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	if (!self.movetarget)
	{
		self.pausetime = time + 999999;
		self.th_stand ();
		return;
	}
}

void() monster_wanderpaththink =
{
	vector v, v1;
	float b, c;
	self.nextthink = time + random() * 10 + 1;
	if (self.owner.health < 1) // dead, also handled in death code
	{
		self.owner.movetarget = world;
		remove(self);
		return;
	}
	b = -1;
	c = 10;
	while (c > 0)
	{
		c = c - 1;
		v = randomvec();
		traceline(self.owner.origin, v * 1024 + self.owner.origin, FALSE, self);
		v = trace_endpos - (normalize(v) * 16) - self.owner.origin;
		if (vlen(v) > b)
		{
			b = vlen(v);
			v1 = v;
		}
	}
	setorigin(self, v1 + self.owner.origin);
	self.owner.ideal_yaw = vectoyaw(self.origin - self.owner.origin);
}

void() monster_wanderpathtouch =
{
	if (other.health < 1)
		return;
	if (other.movetarget != self)
		return;

	if (other.enemy)
		return;		// fighting, not following a path

	/* PLEASE FIX THE SOUND CHANNEL BEFORE ACTIVATING THIS
	if (other.classname == "monster_ogre")
		sound (other, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);// play chainsaw drag sound
	*/
	monster_wanderpaththink();
}

void() monster_spawnwanderpath =
{
	newmis = spawn();
	newmis.classname = "monster_wanderpath";
	newmis.solid = SOLID_TRIGGER;
	newmis.touch = monster_wanderpathtouch;
	setsize (newmis, '-8 -8 -8', '8 8 8');
	newmis.think = monster_wanderpaththink;
	newmis.nextthink = time + random() * 10 + 1;
	newmis.owner = self;
	self.goalentity = self.movetarget = newmis;
}

void() monster_checkbossflag =
{
//#NO AUTOCVARS START
#if 0
	float healthboost;
	float r;

	// monsterbosses cvar or spawnflag 64 causes a monster to be a miniboss
	if ((self.spawnflags & 64) || (random() * 100 < cvar("monsterbosspercent")))
	{
		self.radsuit_finished = time + 1000000000;
		r = random() * 4;
		if (r < 2)
		{
			self.super_damage_finished = time + 1000000000;
			healthboost = 30 + self.health * 0.5;
			self.effects = self.effects | (EF_FULLBRIGHT | EF_BLUE);
		}
		if (r >= 1)
		{
			healthboost = 30 + self.health * bound(0.5, skill * 0.5, 1.5);
			self.effects = self.effects | (EF_FULLBRIGHT | EF_RED);
			self.healthregen = max(self.healthregen, min(skill * 10, 30));
		}
		self.health = self.health + healthboost;
		self.max_health = self.health;
		self.bodyhealth = self.bodyhealth * 2 + healthboost;
		do
		{
			self.colormod_x = random();
			self.colormod_y = random();
			self.colormod_z = random();
			self.colormod =  normalize(self.colormod);
		}
		while (self.colormod_x > 0.6 && self.colormod_y > 0.6 && self.colormod_z > 0.6);
	}
#endif
//#NO AUTOCVARS END
}


//============================================================================

/*
=============
range

returns the range catagorization of an entity reletive to self
0	melee range, will become hostile even if back is turned
1	visibility and infront, or visibility and show hostile
2	infront and show hostile
3	only triggered by damage
=============
*/
float(entity targ) range =
{
	float r;
	r = vlen ((self.origin + self.view_ofs) - (targ.origin + targ.view_ofs));
	if (r < 120)
		return RANGE_MELEE;
	if (r < 500)
		return RANGE_NEAR;
	if (r < 2000) // increased from 1000 for DP
		return RANGE_MID;
	return RANGE_FAR;
}

/*
=============
visible

returns 1 if the entity is visible to self, even if not infront ()
=============
*/
float (entity targ) visible =
{
	if (vlen(targ.origin - self.origin) > 5000) // long traces are slow
		return FALSE;

	traceline ((self.origin + self.view_ofs), (targ.origin + targ.view_ofs), TRUE, self);   // see through other monsters

	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_fraction == 1)
		return TRUE;
	return FALSE;
}


/*
=============
infront

returns 1 if the entity is in front (in sight) of self
=============
*/
float(entity targ) infront =
{
	float dot;

	makevectors (self.angles);
	dot = normalize (targ.origin - self.origin) * v_forward;

	return (dot > 0.3);
}
// returns 0 if not infront, or the dotproduct if infront
float(vector dir, entity targ) infront2 =
{
	float dot;

	dir = normalize(dir);
	dot = normalize (targ.origin - self.origin) * dir;

	if (dot >= 0.3) return dot; // infront
	return 0;
}


//============================================================================

/*
===========
ChangeYaw

Turns towards self.ideal_yaw at self.yaw_speed
Sets the global variable current_yaw
Called every 0.1 sec by monsters
============
*/
/*

void() ChangeYaw =
{
	float ideal, move;

//current_yaw = self.ideal_yaw;
// mod down the current angle
	current_yaw = anglemod( self.angles_y );
	ideal = self.ideal_yaw;

	if (current_yaw == ideal)
		return;

	move = ideal - current_yaw;
	if (ideal > current_yaw)
	{
		if (move > 180)
			move = move - 360;
	}
	else
	{
		if (move < -180)
			move = move + 360;
	}

	if (move > 0)
	{
		if (move > self.yaw_speed)
			move = self.yaw_speed;
	}
	else
	{
		if (move < 0-self.yaw_speed )
			move = 0-self.yaw_speed;
	}

	current_yaw = anglemod (current_yaw + move);

	self.angles_y = current_yaw;
}

*/


//============================================================================

void() HuntTarget =
{
	self.goalentity = self.enemy;
	self.think = self.th_run;
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.nextthink = time + 0.1;
	SUB_AttackFinished (1);	// wait a while before first attack
}

.void() th_sightsound;

void() SightSound =
{
	if (self.health < 1)
		return;
	// skill 5 does not play sight sounds, instead you only hear the appear sound as they are about to attack
	if (skill >= 5)
	if (self.classname != "monster_hellfish")
		return;

	if (self.th_sightsound)
		self.th_sightsound();
}

void() FoundTarget =
{
	if (self.health < 1 || !self.th_run)
		return;
	if (self.enemy.health < 1 || !self.enemy.takedamage)
		return;
	if (self.enemy.classname == "player")
	{
		// let other monsters see this monster for a while
		sight_entity = self;
		sight_entity_time = time + 0.1;
	}

	self.show_hostile = time + 1;		// wake up other monsters

	SightSound ();
	HuntTarget ();
}

/*
//float checkplayertime;
entity lastcheckplayer;
entity havocbot_list;


entity() checkplayer =
{
	entity check;
	float worldcount;
	// we can just fallback on checkclient if there are no bots
	if (!havocbot_list)
		return checkclient();
*/
	/*
	if (time < checkplayertime)
	{
		traceline(self.origin + self.view_ofs, lastcheckplayer.origin + lastcheckplayer.view_ofs, TRUE, self);
		if (trace_fraction == 1)
			return lastcheckplayer;
		if (trace_ent == lastcheckplayer)
			return lastcheckplayer;
	}
	checkplayertime = time + 0.1;
	*/
/*
	check = lastcheckplayer;
	worldcount = 0;
	c = 0;
	do
	{
		c = c + 1;
		check = findfloat(check, havocattack, TRUE);
		if (check.classname == "player" || check.classname == "turretbase")
		{
			traceline(self.origin + self.view_ofs, check.origin + check.view_ofs, TRUE, self);
			if (trace_fraction == 1)
				return lastcheckplayer = check;
			if (trace_ent == check)
				return lastcheckplayer = check;
		}
		else if (check == world)
		{
			worldcount = worldcount + 1;
			if (worldcount >= 2)
				return lastcheckplayer = check;
		}
	}
	while(check != lastcheckplayer && c < 100);
	return world;
}
*/

/*
===========
FindTarget

Self is currently not attacking anything, so try to find a target

Returns TRUE if an enemy was sighted

When a player fires a missile, the point of impact becomes a fakeplayer so
that monsters that see the impact will respond as if they had seen the
player.

To avoid spending too much time, only a single client (or fakeclient) is
checked each frame.  This means multi player games will have slightly
slower noticing monsters.
============
*/
.float findtarget;
float() FindTarget =
{
	entity client;
	float r;

	if (self.health < 1)
		return FALSE;

	// if the first or second spawnflag bit is set, the monster will only
	// wake up on really seeing the player, not another monster getting angry

	if (self.spawnflags & 3)
	{
		// don't wake up on seeing another monster getting angry
		client = checkclient ();
		if (!client)
			return FALSE;   // current check entity isn't in PVS
	}
	else
	{
		if (sight_entity_time >= time)
		{
			client = sight_entity;
			if (client.enemy == self.enemy)
				return TRUE;
		}
		else
		{
			client = checkclient ();
			if (!client)
				return FALSE;   // current check entity isn't in PVS
		}
	}

	if (client == self.enemy)
		return FALSE;

	if (client.flags & FL_NOTARGET)
		return FALSE;

#if 0
	if (client.items & IT_INVISIBILITY)
		return FALSE;
#endif

	// on skill 5 the monsters usually ignore the player and remain ghostlike
	if (skill >= 5)
	if (self.classname != "monster_hellfish")
	if (random() < 0.99)
		return FALSE;

	r = range(client);
	if (r == RANGE_FAR)
		return FALSE;

	if (!visible (client))
		return FALSE;

	if (r == RANGE_NEAR)
	{
		if (client.show_hostile < time && !infront (client))
			return FALSE;
	}
	else if (r == RANGE_MID)
	{
		// LordHavoc: was if ( /* client.show_hostile < time || */ !infront (client))
		if (client.show_hostile < time && !infront (client))
			return FALSE;
	}

	//
	// got one
	//

	if (client.model == "")
		return FALSE;
	self.enemy = client;
	if (self.enemy.classname != "player" && self.enemy.classname != "turretbase")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player" && self.enemy.classname != "turretbase")
		{
			self.enemy = world;
			return FALSE;
		}
	}

	FoundTarget ();

	return TRUE;
}


//=============================================================================

void(float dist) ai_forward =
{
	walkmove (self.angles_y, dist);
}

void(float dist) ai_back =
{
	walkmove ( (self.angles_y+180), dist);
}


void(float a) monster_setalpha;

/*
=============
ai_pain

stagger back a bit
=============
*/
void(float dist) ai_pain =
{
	if (self.health < 1)
		return;
	ai_back (dist);
}

/*
=============
ai_painforward

stagger back a bit
=============
*/
void(float dist) ai_painforward =
{
	if (self.health < 1)
		return;
	walkmove (self.ideal_yaw, dist);
}

/*
=============
ai_walk

The monster is walking it's beat
=============
*/
void(float dist) ai_walk =
{
	if (self.health < 1)
		return;

	movedist = dist;

	// check for noticing a player
	if (self.oldenemy.takedamage)
	if (self.oldenemy.health >= 1)
	{
		self.enemy = self.oldenemy;
		self.oldenemy = world;
		FoundTarget();
		monster_setalpha(0);
		return;
	}
	if (self.enemy)
	{
		if (self.enemy.takedamage)
		{
			if (self.enemy.health >= 1)
			{
				FoundTarget();
				monster_setalpha(0);
				return;
			}
			else
				self.enemy = world;
		}
		else
			self.enemy = world;
	}

	self.findtarget = TRUE;

	movetogoal (dist);
	monster_setalpha(0);
}


/*
=============
ai_stand

The monster is staying in one place for a while, with slight angle turns
=============
*/
void() ai_stand =
{
	if (self.health < 1)
		return;
	if (self.enemy)
	{
		if (self.enemy.takedamage)
		{
			if (self.enemy.health >= 1)
			{
				FoundTarget();
				monster_setalpha(0);
				return;
			}
			else
				self.enemy = world;
		}
		else
			self.enemy = world;
	}
	self.findtarget = TRUE;

	if (time > self.pausetime)
	{
		self.th_walk ();
		monster_setalpha(0);
		return;
	}

// change angle slightly

	monster_setalpha(0);
}

/*
=============
ai_turn

don't move, but turn towards ideal_yaw
=============
*/
void() ai_turn =
{
	if (self.enemy)
	{
		if (self.enemy.takedamage)
		{
			if (self.enemy.health >= 1)
			{
				FoundTarget();
				monster_setalpha(0);
				return;
			}
			else
				self.enemy = world;
		}
		else
			self.enemy = world;
	}
	self.findtarget = TRUE;

	ChangeYaw ();
	monster_setalpha(0);
}

//=============================================================================

/*
=============
ChooseTurn
=============
*/
void(vector pDestvec) ChooseTurn =
{
	vector dir, newdir;

	dir = self.origin - pDestvec;

	newdir_x = trace_plane_normal_y;
	newdir_y = 0 - trace_plane_normal_x;
	newdir_z = 0;

	if (dir * newdir > 0)
	{
		dir_x = 0 - trace_plane_normal_y;
		dir_y = trace_plane_normal_x;
	}
	else
	{
		dir_x = trace_plane_normal_y;
		dir_y = 0 - trace_plane_normal_x;
	}

	dir_z = 0;
	self.ideal_yaw = vectoyaw(dir);
}

/*
============
FacingIdeal

============
*/
float() FacingIdeal =
{
	float delta;

	delta = anglemod(self.angles_y - self.ideal_yaw);
	if (delta > 45 && delta < 315)
		return FALSE;
	return TRUE;
}


//=============================================================================

.float() th_checkattack;



/*
=============
ai_run

The monster has an enemy it is trying to kill
=============
*/
void(float dist) ai_run =
{
	float ofs;
	if (self.health < 1)
		return;
	movedist = dist;
	// see if the enemy is dead
	if (self.enemy.health < 1 || self.enemy.takedamage == DAMAGE_NO)
	{
		self.enemy = world;
		// FIXME: look all around for other targets
		if (self.oldenemy.health >= 1 && self.oldenemy.takedamage)
		{
			self.enemy = self.oldenemy;
			self.oldenemy = world;
			HuntTarget ();
		}
		else
		{
			if (self.movetarget)
				self.th_walk ();
			else
				self.th_stand ();
			return;
		}
	}

	// wake up other monsters
	self.show_hostile = time + 1;

	// check knowledge of enemy
	enemy_range = range(self.enemy);

	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	ChangeYaw ();

	if (self.attack_state == AS_MELEE)
	{
		//dprint ("ai_run_melee\n");
		//Turn and close until within an angle to launch a melee attack
		if (FacingIdeal())
		{
			self.th_melee ();
			self.attack_state = AS_STRAIGHT;
		}
		return;
	}
	else if (self.attack_state == AS_MISSILE)
	{
		//dprint ("ai_run_missile\n");
		//Turn in place until within an angle to launch a missile attack
		if (FacingIdeal())
		if (self.th_missile ())
			self.attack_state = AS_STRAIGHT;
		return;
	}

	if (self.th_checkattack())
		return;					// beginning an attack

	if (visible(self.enemy))
		self.search_time = time + 5;
	else if (coop)
	{
		// look for other coop players
		if (self.search_time < time)
			self.findtarget = TRUE;
	}

	if (self.attack_state == AS_SLIDING)
	{
		//dprint ("ai_run_slide\n");
		//Strafe sideways, but stay at aproximately the same range
		if (self.lefty)
			ofs = 90;
		else
			ofs = -90;

		if (walkmove (self.ideal_yaw + ofs, movedist))
			return;

		self.lefty = !self.lefty;

		walkmove (self.ideal_yaw - ofs, movedist);
	}

	// head straight in
	movetogoal (dist);		// done in C code...
}

