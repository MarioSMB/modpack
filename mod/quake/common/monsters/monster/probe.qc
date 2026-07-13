#include "probe.qh"

#ifdef SVQC
.float attack2_finished;
.float idle_finished;

/*
=================
ProbeCheckAttack
=================
*/
bool ProbeCheckAttack(entity this)
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

void probe_attack(entity this)
{
	this.attack_finished = time + 0.5 + (random() * 2);

	vector org = this.origin;
	entity targ = this.enemy;
	vector targ_org = (targ.absmin + targ.absmax) * 0.5;
	vector enemy_org = ai_shotlead(org, targ_org, targ.velocity, 600);

	entity newmis = LaunchLaser(this, org, enemy_org - org);
	newmis.projectiledeathtype = DEATH_MONSTER_PROBE.m_id;
	_sound(this, CH_WEAPON_SINGLE, "destroyer/laser_fire.wav", 1, ATTN_NORM);
}


// BIG TODO: clean up boss targeting
void boss_FindTarget(entity this);

/*================
	MOVEMENT
==================*/
void probe_setangle(entity this)
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

void probe_movetogoal(entity this, float movespeed, bool dobrake)
{
	probe_setangle(this);

	vector ang = this.angles;
	ang.x = -ang.x;
	makevectors(ang);

	// TODO: strafe/avoid wall?
	vector dir = v_forward;

	dir = dir + v_right * sin(cos(0.75 * this.spawn_time) * M_PI * time) + v_up * cos(sin(0.05 * this.spawn_time) * M_PI * time);

	if(dobrake)
		movespeed = max(0, vlen(this.velocity) - movespeed);

	this.velocity = dir * movespeed;
}

void probe_move_loop(entity this)
{
	setthink(this, probe_move_loop);
	this.nextthink = time;

	// TODO: maybe don't copy owner's enemy? might not be visible anymore!
	if(this.owner)
		this.enemy = this.owner.enemy;
	else
		boss_FindTarget(this);

	if(this.enemy)
		this.goalentity = this.enemy;
	else if(this.charmer)
		this.goalentity = this.charmer;
	else if(this.goalentity.classname != "path_corner")
		this.goalentity = NULL;

	if(this.enemy)
	{
		// check knowledge of enemy
		this.enemy_visible = visible(this, this.enemy);
		this.enemy_range = range(this, this.enemy);
	}

	if(this.enemy)
		CheckAnyAttack(this);

	float movespeed = 150;

	bool dobrake = false;
	if(!this.goalentity)
		dobrake = true;

	probe_movetogoal(this, movespeed, dobrake); // TODO: do a circular motion
}

//===========================================================================

void probe_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(time < this.pain_finished)
		return;
	this.pain_finished = time + 0.1;
	_sound(this, CH_VOICE, "destroyer/hit.wav", 1, ATTN_NORM);
}

//===========================================================================

void probe_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.velocity = '0 0 0';

	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED: break; // always gibs anyway
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	_sound(this, CH_VOICE, "destroyer/explode.wav", 1, ATTN_NORM);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	entity exp = spawn();
	exp.nextthink = time;
	setthink(exp, s_explode1);
	_setmodel(exp, "progs/s_explod.spr");
	setsize(exp, '0 0 0', '0 0 0');
	setorigin(exp, this.origin);

	delete(this);
}

// TODO: timer applies to all 20 creepers!
.float probe_hurttime;
void probe_touch(entity this, entity toucher)
{
	if(toucher.flags & FL_PROJECTILE)
		return;
	if(time < toucher.probe_hurttime)
		return;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, this))
		return;
	
	if(toucher == this.owner || toucher.owner == this)
		return;

	toucher.probe_hurttime = time + 0.2; // no spam please

	float damage = 10 + (random() * 4) + (random() * 2);
	
	T_Damage(toucher, this, this, damage, DEATH_MONSTER_PROBE.m_id);
}

// does not spawn naturally
#endif // SVQC

#ifdef SVQC
METHOD(Probe, mr_setup, bool(Probe this, entity actor))
{
	TC(Probe, this);

	precache_sound("destroyer/explode.wav");
	precache_sound("destroyer/hit.wav");
	precache_sound("destroyer/laser_fire.wav");

	actor.yaw_speed = 20;
	settouch(actor, probe_touch);
	set_movetype(actor, MOVETYPE_FLY);

	// wait a second before shooting
	actor.attack_finished = time + 3 + (random() * 3);
	actor.spawn_time = time + random(); // slight offset so they aren't in sync!

	// pass through players, dealing damage on the way
	actor.solid = SOLID_CORPSE;
	setorigin(actor, actor.origin);

	actor.health = 100;
	actor.th_stand = probe_move_loop;
	actor.th_walk = probe_move_loop;
	actor.th_run = probe_move_loop;
	actor.th_pain = probe_pain;
	actor.th_die = probe_die;
	actor.th_missile = probe_attack;

	actor.checkattack = ProbeCheckAttack;

	return true;
}
#endif
