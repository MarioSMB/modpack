#include "brain.qh"

REGISTER_NET_TEMP(boc_gibsplash)

#ifdef SVQC
const int CLIPGROUP_BRAIN = 23; // randomly picked!

.int bosswave;

/*
=================
BrainCheckAttack
=================
*/
bool BrainCheckAttack(entity this)
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
		chance = 0.8;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.6;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.4;

	if(time > this.attack_finished && this.th_missile && random() < chance)
		this.th_missile(this);

	return false;
}

bool brain_teleport(entity this)
{
	vector extrasize = '1 1 1' * 600;
	vector from = this.origin;
	if(MoveToRandomLocationWithinBounds(this, this.absmin - extrasize, this.absmax + extrasize,
											DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, 
											Q3SURFACEFLAG_SKY, 20, 512, 512, true))
	{
		// no special treatment needed, we're just using it as a position!
		this.mangle = '0 1 0' * this.angles_y;
		this.angles = '0 0 0';
		soundat(NULL, from, CH_TRIGGER, "brain/teleport.wav", 1, ATTN_NORM);
		soundat(NULL, this.origin, CH_TRIGGER, "brain/teleport.wav", 1, ATTN_NORM);
		te_teleport(this.origin);
		te_teleport(from);
		UNSET_ONGROUND(this);
		return true;
	}
	return false;
}

void brain_attack(entity this)
{
	bool teleported = brain_teleport(this);
	if(!teleported)
		this.attack_finished = time + 0.1; // try again soon!
	else if(this.bosswave >= 1)
		this.attack_finished = time + 1 + (random() * 1);
	else
		this.attack_finished = time + 2 + (random() * 2);
}

// BIG TODO: clean up boss targeting
void boss_FindTarget(entity this);

void brain_transform(entity this);

/*================
	MOVEMENT
==================*/
void brain_setangle(entity this)
{
	if(!this.goalentity)
		return;

	vector myorg = CENTER_OR_VIEWOFS(this);
	vector targorg = CENTER_OR_VIEWOFS(this.goalentity);
	vector ideal = vectoangles(normalize(targorg - myorg));
	// TODO: special angling for brain, it has funny behaviour!
	ideal.x = this.angles_x;
	ideal.z = this.angles_z;
	if(this.angles == ideal)
		return;

	float angspeed = this.yaw_speed;
	ideal -= this.angles;

	//this.angles_x += bound(-angspeed, shortangle_f(ideal_x, this.angles_x), angspeed);
	this.angles_y += bound(-angspeed, shortangle_f(ideal_y, this.angles_y), angspeed);
	//this.angles_z += bound(-angspeed, shortangle_f(ideal_z, this.angles_z), angspeed);
}

void brain_movetogoal(entity this, float movespeed, bool dobrake)
{
	brain_setangle(this);

	vector ang = this.angles;
	ang.x = -ang.x;
	makevectors(ang);

	// TODO: strafe/avoid wall?
	vector dir = (this.goalentity) ? normalize(CENTER_OR_VIEWOFS(this.goalentity) - this.origin) : v_forward;

	if(dobrake)
		movespeed = max(0, vlen(this.velocity) - movespeed);

	this.velocity = dir * movespeed;
}

void brain_checkcreepers(entity this)
{
	int found = 0;
	IL_EACH(g_brainparts, it.owner == this,
	{
		found += 1;
	});

	if(found <= 0)
		brain_transform(this);
}

void brain_move_loop(entity this)
{
	setthink(this, brain_move_loop);
	this.nextthink = time;

	if(time >= this.idle_finished)
	{
		this.idle_finished = time + 0.1;
		this.frame += 1;
		if(this.frame > 3)
			this.frame = 0;
	}

	if(this.bosswave < 1)
		brain_checkcreepers(this);

	// set our damage state here to prevent it being overridden at spawn
	this.takedamage = (this.bosswave >= 1) ? DAMAGE_AIM : DAMAGE_NO;

	boss_FindTarget(this);

	if(this.enemy)
		this.goalentity = this.enemy;
	else if(this.charmer)
		this.goalentity = this.charmer;
	else if(this.goalentity.classname != "path_corner")
		this.goalentity = NULL;

	if(this.enemy)
	{
		this.show_hostile = time + 1; // wake up other monsters

		// check knowledge of enemy
		this.enemy_visible = visible(this, this.enemy);
		this.enemy_range = range(this, this.enemy);
		if(this.enemy_visible)
			this.search_time = time + 5;

		// look for other coop players
		if(coop && this.search_time < time && !this.charmed)
			this.enemy = NULL;
	}

	if(this.enemy)
		CheckAnyAttack(this);

	float movespeed = 80;
	if(this.enemy)
		movespeed = (this.bosswave >= 1) ? 240 : 160;

	bool dobrake = false;
	if(!this.goalentity)
		dobrake = true;

	brain_movetogoal(this, movespeed, dobrake);
}

void brain_transform(entity this)
{
	vector oldmin = this.mins;
	vector oldmax = this.maxs;
	_setmodel(this, "progs/brain_phase2.mdl");
	setsize(this, oldmin, oldmax);

	_sound(this, CH_VOICE, "brain/sight.wav", 1, ATTN_BOSS);

	this.bosswave += 1;
}

//===========================================================================

void brain_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(time < this.pain_finished)
		return;
	this.pain_finished = time + 0.2;
	_sound(this, CH_VOICE, "brain/pain.wav", 1, ATTN_BOSS);
}

//===========================================================================

void brain_clearparts(entity this)
{
	// should be impossible, but let's clean them up anyway!
	IL_EACH(g_brainparts, it.owner == this,
	{
		if(it.health > 0)
		{
			it.health = 0;
			Killed(it, this, this, DEATH_GENERIC.m_id);
		}
	});
}

void brain_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.velocity = '0 0 0';

	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED: break; // always gibs anyway
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	_sound(this, CH_VOICE, "brain/death.wav", 1, ATTN_BOSS);
	spawn_touchblood(this, 60, inflictor);

	int channel = MSG_ALL;
	WriteHeader(channel, boc_gibsplash);
	WriteVector(channel, this.origin);
	WriteFloat(channel, this.health);
	//WriteFloat(channel, this.scale);
	//WriteVector(channel, inflictor.origin);
	//WriteShort(channel, compressShortVector(normalize(this.origin - inflictor.origin)));
	//WriteShort(channel, compressShortVector(inflictor.velocity));

	brain_clearparts(this);
	delete(this);
}

.float brain_hurttime;
void brain_touch(entity this, entity toucher)
{
	if(toucher.flags & FL_PROJECTILE)
		return;
	if(time < toucher.brain_hurttime)
		return;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, this))
		return;
	
	if(toucher == this.owner || toucher.owner == this)
		return;

	toucher.brain_hurttime = time + 0.2; // no spam please

	float damage = (this.dmg) ? this.dmg : 40;
	
	T_Damage(toucher, this, this, damage, DEATH_MONSTER_BRAIN.m_id);
}

void brain_spawncreepers(entity this)
{
	// TODO: 40 on some settings?
	for(int j = 0; j < this.minion_maxcount; ++j)
	{
		entity creeper = minion_spawn(this, this.origin + '0 0 16', new(monster), MON_BRAIN_CREEPER);
		if(creeper)
			IL_PUSH(g_brainparts, creeper);
	}
}

/*QUAKED monster_brain (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_brain) { monster_start(this, true, MON_BRAIN); }
#endif // SVQC

#ifdef SVQC
METHOD(Brain, mr_setup, bool(Brain this, entity actor))
{
	TC(Brain, this);

	precache_model("progs/brain_phase2.mdl");
	precache_sound("brain/death.wav");
	precache_sound("brain/pain.wav");
	precache_sound("brain/sight.wav");

	// for our pets
	if(!actor.clipgroup)
		actor.clipgroup = CLIPGROUP_BRAIN;

	actor.yaw_speed = 20;
	settouch(actor, brain_touch);
	set_movetype(actor, MOVETYPE_FLY);

	if(!actor.minion_maxcount)
		actor.minion_maxcount = 20;

	// invincible to begin with
	actor.bosswave = 0;
	//actor.solid = SOLID_TRIGGER;
	//setorigin(actor, actor.origin);

	actor.health = 1000;
	actor.th_stand = brain_move_loop;
	actor.th_walk = brain_move_loop;
	actor.th_run = brain_move_loop;
	actor.th_pain = brain_pain;
	actor.th_die = brain_die;
	actor.th_missile = brain_attack;

	actor.checkattack = BrainCheckAttack;

	brain_spawncreepers(actor);

	return true;
}
METHOD(Brain, mr_sight, bool(Brain this, entity actor))
{
	TC(Brain, this);

	_sound(actor, CH_VOICE, "brain/sight.wav", 1, ATTN_BOSS);

	return true;
}
#endif

#ifdef CSQC
PRECACHE(BOC)
{
	precache_model("progs/gib1.mdl");
	precache_model("progs/gib2.mdl");
	precache_model("progs/gib3.mdl");
	precache_model("progs/xtragib.mdl");
	precache_model("progs/bone.mdl");
	precache_model("progs/bone2.mdl");
	precache_model("progs/rawbone.mdl");
}

NET_HANDLE(boc_gibsplash, bool isnew)
{
	vector org = ReadVector();
	float mhealth = ReadFloat();
	//float myscale = ReadFloat();
	//vector targorg = ReadVector();
	//vector targnorm = decompressShortVector(ReadShort());
	//vector targvel = decompressShortVector(ReadShort());
	vector targvel = '0 0 0';

	return = true;

	TossGib ("progs/xtragib.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/gib1.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/bone.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/gib2.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/xtragib.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/bone2.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/gib1.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/xtragib.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/gib2.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/xtragib.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/rawbone.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/gib3.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
}
#endif
