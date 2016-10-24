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
// when a monster becomes angry at a player, that monster will be used
// as the sight target the next frame so that monsters near that one
// will wake up even if they wouldn't have noticed the player
//
entity	sight_entity;
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
void movetarget_f(entity this)
{
	if(!this.targetname)
		objerror("monster_movetarget: no targetname");
		
	this.solid = SOLID_TRIGGER;
	settouch(this, t_movetarget);
	setsize(this, '-8 -8 -8', '8 8 8');
	
}

/*QUAKED path_corner(0.5 0.3 0)(-8 -8 -8)(8 8 8)
Monsters will continue walking towards the next target corner.
*/
spawnfunc(path_corner)
{
	movetarget_f(this);
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
		return;		// fighting, not following a path

	if(this.classname == "monster_ogre")
		_sound(this, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);// play chainsaw drag sound

//dprint("t_movetarget\n");
	this.goalentity = this.movetarget = find(NULL, targetname, toucher.target);
	this.ideal_yaw = vectoyaw(this.goalentity.origin - this.origin);
	if(!this.movetarget)
	{
		this.pausetime = time + 999999;
		this.th_stand(this);
		return;
	}
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
int range(entity targ)
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

returns 1 if the entity is visible to this, even if not infront()
=============
*/
bool visible(entity targ)
{
	vector	spot1, spot2;
	
	spot1 = this.origin + this.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	traceline(spot1, spot2, true, this);	// see through other monsters
	
	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

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
bool infront(entity targ)
{
	makevectors(this.angles);
	vector vec = normalize(targ.origin - this.origin);
	float dot = vec * v_forward;
	
	if( dot > 0.3)
		return true;
	return false;
}


//============================================================================


//============================================================================

void HuntTarget()
{
	this.goalentity = this.enemy;
	setthink(this, this.th_run);
	this.ideal_yaw = vectoyaw(this.enemy.origin - this.origin);
	this.nextthink = time + 0.1;
	SUB_AttackFinished(this, 1);	// wait a while before first attack
}

void SightSound()
{
	if(this.classname == "monster_ogre")	
		_sound(this, CHAN_VOICE, "ogre/ogwake.wav", 1, ATTN_NORM);
	else if(this.classname == "monster_knight")
		_sound(this, CHAN_VOICE, "knight/ksight.wav", 1, ATTN_NORM);
	else if(this.classname == "monster_shambler")
		_sound(this, CHAN_VOICE, "shambler/ssight.wav", 1, ATTN_NORM);
	else if(this.classname == "monster_demon1")
		_sound(this, CHAN_VOICE, "demon/sight2.wav", 1, ATTN_NORM);
	else if(this.classname == "monster_wizard")
		_sound(this, CHAN_VOICE, "wizard/wsight.wav", 1, ATTN_NORM);
	else if(this.classname == "monster_zombie")
		_sound(this, CHAN_VOICE, "zombie/z_idle.wav", 1, ATTN_NORM);
	else if(this.classname == "monster_dog")
		_sound(this, CHAN_VOICE, "dog/dsight.wav", 1, ATTN_NORM);
	else if(this.classname == "monster_hell_knight")
		_sound(this, CHAN_VOICE, "hknight/sight1.wav", 1, ATTN_NORM);
	else if(this.classname == "monster_tarbaby")
		_sound(this, CHAN_VOICE, "blob/sight1.wav", 1, ATTN_NORM);
	else if(this.classname == "monster_vomit")
		_sound(this, CHAN_VOICE, "vomitus/v_sight1.wav", 1, ATTN_NORM);
	else if(this.classname == "monster_enforcer")
	{
		int rsnd = rint(random() * 3);			
		if(rsnd == 1)
			_sound(this, CHAN_VOICE, "enforcer/sight1.wav", 1, ATTN_NORM);
		else if(rsnd == 2)
			_sound(this, CHAN_VOICE, "enforcer/sight2.wav", 1, ATTN_NORM);
		else if(rsnd == 0)
			_sound(this, CHAN_VOICE, "enforcer/sight3.wav", 1, ATTN_NORM);
		else
			_sound(this, CHAN_VOICE, "enforcer/sight4.wav", 1, ATTN_NORM);
	}
	else if(this.classname == "monster_army")
		_sound(this, CHAN_VOICE, "soldier/sight1.wav", 1, ATTN_NORM);
	else if(this.classname == "monster_shalrath")
		_sound(this, CHAN_VOICE, "shalrath/sight.wav", 1, ATTN_NORM);
}

void FoundTarget(entity this)
{
	if(IS_PLAYER(this.enemy))
	{	// let other monsters see this monster for a while
		sight_entity = this;
		sight_entity_time = time;
	}
	
	this.show_hostile = time + 1;		// wake up other monsters

	SightSound();
	HuntTarget();
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
	entity	client;

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
		client = checkclient(client);
		if(!client)
			return false;	// current check entity isn't in PVS
	}

	if(client == this.enemy)
		return false;

	if(client.flags & FL_NOTARGET)
		return false;
	if(client.items & IT_INVISIBILITY)
		return false;

	int r = range(client);
	if(r == RANGE_FAR)
		return false;
		
	if(!visible(client))
		return false;

	if(r == RANGE_NEAR)
	{
		if(client.show_hostile < time && !infront(client))
			return false;
	}
	else if(r == RANGE_MID)
	{
		if( /* client.show_hostile < time || */ !infront(client))
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

void ai_forward(float dist)
{
	walkmove(this.angles_y, dist);
}

void ai_back(float dist)
{
	walkmove((this.angles_y+180), dist);
}


/*
=============
ai_pain

stagger back a bit
=============
*/
void ai_pain(float dist)
{
	ai_back(dist);
/*
	float away = anglemod(vectoyaw(this.origin - this.enemy.origin) 
	+ 180*(random()- 0.5) );
	
	walkmove(away, dist);
*/
}

/*
=============
ai_painforward

stagger back a bit
=============
*/
void ai_painforward(float dist)
{
	walkmove(this.ideal_yaw, dist);
}

/*
=============
ai_walk

The monster is walking it's beat
=============
*/
void ai_walk(entity this, float dist)
{
	vector		mtemp;
	
	movedist = dist;
	
	if(this.classname == "monster_dragon")
	{
		movetogoal(this, dist);
		return;
	}
	// check for noticing a player
	if(FindTarget(this))
		return;

	movetogoal(this, dist);
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
void ai_turn()
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
void ChooseTurn(vector dest3)
{
	vector	dir, newdir;
	
	dir = this.origin - dest3;

	newdir_x = trace_plane_normal_y;
	newdir_y = 0 - trace_plane_normal_x;
	newdir_z = 0;
	
	if(dir * newdir > 0)
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

bool WizardCheckAttack(entity this);
bool DogCheckAttack(entity this);

bool CheckAnyAttack(entity this)
{
	if(!enemy_vis)
		return;
	if(this.classname == "monster_army")
		return SoldierCheckAttack(this);
	if(this.classname == "monster_ogre")
		return OgreCheckAttack(this);
	if(this.classname == "monster_shambler")
		return ShamCheckAttack(this);
	if(this.classname == "monster_demon1")
		return DemonCheckAttack(this);
	if(this.classname == "monster_dog")
		return DogCheckAttack(this);
	if(this.classname == "monster_wizard")
		return WizardCheckAttack(this);
	return CheckAttack(this);
}


/*
=============
ai_run_melee

Turn and close until within an angle to launch a melee attack
=============
*/
void ai_run_melee()
{
	this.ideal_yaw = enemy_yaw;
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
void ai_run_missile()
{
	this.ideal_yaw = enemy_yaw;
	ChangeYaw(this);
	if(FacingIdeal())
	{
		this.th_missile();
		this.attack_state = AS_STRAIGHT;
	}
}


/*
=============
ai_run_slide

Strafe sideways, but stay at aproximately the same range
=============
*/
void ai_run_slide()
{
	float ofs;
	
	this.ideal_yaw = enemy_yaw;
	ChangeYaw(this);
	if(this.lefty)
		ofs = 90;
	else
		ofs = -90;
	
	if(walkmove(this, this.ideal_yaw + ofs, movedist))
		return;
		
	this.lefty = 1 - this.lefty;
	
	walkmove(this, this.ideal_yaw - ofs, movedist);
}


/*
=============
ai_run

The monster has an enemy it is trying to kill
=============
*/
void ai_run(float dist)
{
	movedist = dist;
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

	this.show_hostile = time + 1;		// wake up other monsters

// check knowledge of enemy
	enemy_vis = visible(this.enemy);
	if(enemy_vis)
		this.search_time = time + 5;

// look for other coop players
	if(coop && this.search_time < time)
	{
		if(FindTarget(this))
			return;
	}

	enemy_infront = infront(this.enemy);
	enemy_range = range(this.enemy);
	enemy_yaw = vectoyaw(this.enemy.origin - this.origin);
	
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
	movetogoal(this, dist);		// done in C code...
}

