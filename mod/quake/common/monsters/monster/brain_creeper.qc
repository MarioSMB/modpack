#include "brain_creeper.qh"

#ifdef SVQC
.float attack2_finished;
.float idle_finished;

/*
=================
BrainCreeperCheckAttack
=================
*/
bool BrainCreeperCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
	if(!this.enemy_visible)
		return false;

	if(this.enemy_range == RANGE_FAR)
		return false;
		
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, false, this);

	if(trace_ent != targ)
	{	// don't have a clear shot, so move to a side
		return false;
	}

	float chance = 0;	
	if(this.enemy_range == RANGE_MELEE)
		chance = 0;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.4;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.6;

	if(time > this.attack_finished && this.th_missile && random() < chance)
		this.th_missile(this);

	return false;
}

void brain_creeper_attack(entity this)
{
	// next attack time (preferably double the return time)
	this.attack_finished = time + 6 + (random() * 6);
	// return time
	this.attack2_finished = time + 3 + (random() * 3);
}


// BIG TODO: clean up boss targeting
void boss_FindTarget(entity this);

/*================
	MOVEMENT
==================*/
void brain_creeper_setangle(entity this)
{
	if(!this.goalentity)
		return;

	vector myorg = CENTER_OR_VIEWOFS(this);
	vector targorg = CENTER_OR_VIEWOFS(this.goalentity);
	vector ideal = vectoangles(normalize(targorg - myorg));
	if(this.angles == ideal)
		return;

	float angspeed = this.yaw_speed;
	ideal -= this.angles;

	this.angles_x += bound(-angspeed, shortangle_f(ideal_x, this.angles_x), angspeed);
	this.angles_y += bound(-angspeed, shortangle_f(ideal_y, this.angles_y), angspeed);
	this.angles_z += bound(-angspeed, shortangle_f(ideal_z, this.angles_z), angspeed);
}

void brain_creeper_movetogoal(entity this, float movespeed, bool dobrake)
{
	brain_creeper_setangle(this);

	vector ang = this.angles;
	ang.x = -ang.x;
	makevectors(ang);

	// TODO: strafe/avoid wall?
	vector dir = v_forward;

	if((time > this.attack2_finished || !this.enemy) && this.owner)
	{
		dobrake = false; // always return home!
		vector owner_org = ((this.owner.absmin + this.owner.absmax) * 0.5) + ('1 1 1' * sin(512 * M_PI * time));
		dir = normalize(owner_org - this.origin);
	}

	dir = dir + v_right * sin(cos(2 * this.spawn_time) * M_PI * time) + v_up * cos(sin(0.15 * this.spawn_time) * M_PI * time);

	if(dobrake)
		movespeed = max(0, vlen(this.velocity) - movespeed);

	this.velocity = dir * movespeed;
}

void brain_creeper_move_loop(entity this)
{
	setthink(this, brain_creeper_move_loop);
	this.nextthink = time;

	if(this.owner)
		this.enemy = this.owner.enemy;
	else
		boss_FindTarget(this);

	if(this.enemy)
		this.goalentity = this.enemy;
	else if(this.charmer)
		this.goalentity = this.charmer;
	else if(this.goalentity.classname != "path_corner")
		this.goalentity = (this.owner) ? this.owner : NULL;

	if(this.enemy)
	{
		// check knowledge of enemy
		this.enemy_visible = visible(this, this.enemy);
		this.enemy_range = range(this, this.enemy);
	}

	if(this.enemy)
		CheckAnyAttack(this);

	float movespeed = 300;

	bool dobrake = false;
	if(!this.goalentity)
		dobrake = true;

	brain_creeper_movetogoal(this, movespeed, dobrake); // TODO: do a circular motion
}

//===========================================================================

void brain_creeper_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(time < this.pain_finished)
		return;
	// chance to return to the brain!
	if(random() < 0.25)
		this.attack2_finished = time;
	this.pain_finished = time + 0.2;
	_sound(this, CH_VOICE, "brain/pain.wav", 1, ATTN_NORM);
}

//===========================================================================

void brain_creeper_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.velocity = '0 0 0';

	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED: break; // always gibs anyway
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	_sound(this, CH_VOICE, "brain/death.wav", 1, ATTN_NORM);
	spawn_touchblood(this, 60, inflictor);

	Send_Effect(EFFECT_BRAIN_CREEPER_DEATH, this.origin, '0 0 0', 1);

	delete(this);
}

// TODO: timer applies to all 20 creepers!
.float brain_creeper_hurttime;
void brain_creeper_touch(entity this, entity toucher)
{
	if(toucher.flags & FL_PROJECTILE)
		return;
	if(time < toucher.brain_creeper_hurttime)
		return;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, this))
		return;
	
	if(toucher == this.owner || toucher.owner == this)
		return;

	toucher.brain_creeper_hurttime = time + 0.2; // no spam please

	float damage = 10 + (random() * 4) + (random() * 2);
	
	T_Damage(toucher, this, this, damage, DEATH_MONSTER_BRAIN_CREEPER.m_id);
}

// does not spawn naturally
#endif // SVQC

#ifdef SVQC
METHOD(BrainCreeper, mr_setup, bool(BrainCreeper this, entity actor))
{
	TC(BrainCreeper, this);

	precache_model("progs/brain_creeper.mdl");
	precache_sound("brain/death.wav");
	precache_sound("brain/pain.wav");

	actor.yaw_speed = 20;
	settouch(actor, brain_creeper_touch);
	set_movetype(actor, MOVETYPE_FLY);

	// wait a second before going out
	actor.attack_finished = time + 3 + (random() * 3);
	actor.spawn_time = time + random(); // slight offset so they aren't in sync!

	// pass through players, dealing damage on the way
	actor.solid = SOLID_CORPSE;
	setorigin(actor, actor.origin);

	actor.health = 100;
	actor.th_stand = brain_creeper_move_loop;
	actor.th_walk = brain_creeper_move_loop;
	actor.th_run = brain_creeper_move_loop;
	actor.th_pain = brain_creeper_pain;
	actor.th_die = brain_creeper_die;
	actor.th_missile = brain_creeper_attack;

	actor.checkattack = BrainCreeperCheckAttack;

	return true;
}
#endif
