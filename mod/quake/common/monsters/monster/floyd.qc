#include "floyd.qh"

#ifdef SVQC
const int anim_floyd_idle1 = 0;
const int anim_floyd_walk1 = 1; //'1 16 0'
const int anim_floyd_run1 = 17; //'17 24 0'
const int anim_floyd_attack1 = 25; //'25 33 0'
const int anim_floyd_paina1 = 34; //'34 39 0'
const int anim_floyd_painb1 = 40; //'40 49 0'
const int anim_floyd_painc1 = 50; //'50 63 0'
const int anim_floyd_death1 = 64; //'64 79 0'

void floyd_sleep(entity this) { set_anim(this, anim_floyd_idle1, floyd_sleep); ai_stand(this); }

void floyd_idle1(entity this)
{
	set_anim(this, anim_floyd_idle1, floyd_idle1);
	if(random() < 0.02 && !this.enemy)
		_sound(this, CH_VOICE, "floyd/idle.wav", 1, ATTN_IDLE);
	ai_stand(this);
}

void floyd_walk1(entity this);
void floyd_walk16(entity this) { set_animofs(this, anim_floyd_walk1, 16, floyd_walk1); ai_walk(this, 1.875); }
void floyd_walk15(entity this) { set_animofs(this, anim_floyd_walk1, 15, floyd_walk16); ai_walk(this, 1.875); }
void floyd_walk14(entity this) { set_animofs(this, anim_floyd_walk1, 14, floyd_walk15); ai_walk(this, 1.875); }
void floyd_walk13(entity this) { set_animofs(this, anim_floyd_walk1, 13, floyd_walk14); ai_walk(this, 1.875); }
void floyd_walk12(entity this) { set_animofs(this, anim_floyd_walk1, 12, floyd_walk13); ai_walk(this, 1.875); }
void floyd_walk11(entity this) { set_animofs(this, anim_floyd_walk1, 11, floyd_walk12); ai_walk(this, 1.875); }
void floyd_walk10(entity this) { set_animofs(this, anim_floyd_walk1, 10, floyd_walk11); ai_walk(this, 1.875); }
void floyd_walk9(entity this) { set_animofs(this, anim_floyd_walk1, 9, floyd_walk10); ai_walk(this, 1.875); }
void floyd_walk8(entity this) { set_animofs(this, anim_floyd_walk1, 8, floyd_walk9); ai_walk(this, 1.875); }
void floyd_walk7(entity this) { set_animofs(this, anim_floyd_walk1, 7, floyd_walk8); ai_walk(this, 1.875); }
void floyd_walk6(entity this) { set_animofs(this, anim_floyd_walk1, 6, floyd_walk7); ai_walk(this, 1.875); }
void floyd_walk5(entity this) { set_animofs(this, anim_floyd_walk1, 5, floyd_walk6); ai_walk(this, 1.875); }
void floyd_walk4(entity this) { set_animofs(this, anim_floyd_walk1, 4, floyd_walk5); ai_walk(this, 1.875); }
void floyd_walk3(entity this) { set_animofs(this, anim_floyd_walk1, 3, floyd_walk4); ai_walk(this, 1.875); }
void floyd_walk2(entity this) { set_animofs(this, anim_floyd_walk1, 2, floyd_walk3); ai_walk(this, 1.875); }
void floyd_walk1(entity this)
{
	set_animofs(this, anim_floyd_walk1, 1, floyd_walk2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "floyd/idle.wav", 1, ATTN_IDLE);
	ai_walk(this, 1.875);
}

void floyd_run1(entity this);
void floyd_run8(entity this) { set_animofs(this, anim_floyd_run1, 8, floyd_run1); ai_run(this, 3.75); }
void floyd_run7(entity this) { set_animofs(this, anim_floyd_run1, 7, floyd_run8); ai_run(this, 3.75); }
void floyd_run6(entity this) { set_animofs(this, anim_floyd_run1, 6, floyd_run7); ai_run(this, 3.75); }
void floyd_run5(entity this) { set_animofs(this, anim_floyd_run1, 5, floyd_run6); ai_run(this, 3.75); }
void floyd_run4(entity this) { set_animofs(this, anim_floyd_run1, 4, floyd_run5); ai_run(this, 3.75); }
void floyd_run3(entity this) { set_animofs(this, anim_floyd_run1, 3, floyd_run4); ai_run(this, 3.75); }
void floyd_run2(entity this) { set_animofs(this, anim_floyd_run1, 2, floyd_run3); ai_run(this, 3.75); }
void floyd_run1(entity this) { set_animofs(this, anim_floyd_run1, 1, floyd_run2); ai_run(this, 3.75); }

/*
================
attack
================
*/

void FLaser_Touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
	_sound(this, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	vector org = this.origin - 10 * normalize(this.velocity);

	if(toucher.health)
	{
		SpawnBlood(org, this.velocity * 0.2, 15, trace_ent);
		T_Damage(toucher, this, this.owner, 15, this.projectiledeathtype);
	}
	else
	{
		te_gunshot(org);
	}
	
	delete(this);	
}

void FLaunchLaser(entity this, vector org, vector vec)
{
	if(this.monsterdef == MON_FLOYD && this.classname != "gib")
		_sound(this, CHAN_WEAPON, "floyd/fire.wav", 1, ATTN_NORM);
	
	entity newmis = spawn();
	newmis.owner = this;
	set_movetype(newmis, MOVETYPE_FLY);
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;
	newmis.flags = FL_PROJECTILE;
	newmis.projectiledeathtype = DEATH_MONSTER_FLOYD.m_id;

	_setmodel(newmis, "progs/flaser.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		

	setorigin(newmis, org);

	vec = normalize(vec);
	newmis.velocity = vec * 800;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	setthink(newmis, SUB_Remove);
	settouch(newmis, FLaser_Touch);
}

void floyd_fire(entity this, float muzzle)
{
	this.effects |= EF_MUZZLEFLASH;
	makevectors(this.angles);
	
	vector org = this.origin + v_forward * 30 + '0 0 28' + v_right * muzzle;

	FLaunchLaser(this, org, this.enemy.origin - this.origin - '0 0 12');
}

void floyd_attack1(entity this);
void floyd_ready4(entity this)
{
	set_animofs(this, anim_floyd_run1, 4, floyd_attack1); 
	ai_face(this);
	if(!visible(this, this.enemy))
		setthink(this, floyd_run5); // abort if shot is blocked by monster or wall
}
void floyd_ready3(entity this) { set_animofs(this, anim_floyd_run1, 3, floyd_ready4); ai_face(this); }
void floyd_ready2(entity this) { set_animofs(this, anim_floyd_run1, 2, floyd_ready3); ai_face(this); }
void floyd_ready1(entity this) { set_animofs(this, anim_floyd_run1, 1, floyd_ready2); ai_face(this); }

void floyd_attack9(entity this)
{
	set_animofs(this, anim_floyd_attack1, 9, floyd_run1);
	ai_face(this);
}
void floyd_attack8(entity this) { set_animofs(this, anim_floyd_attack1, 8, floyd_attack9); ai_face(this); }
void floyd_attack7(entity this) { set_animofs(this, anim_floyd_attack1, 7, floyd_attack8); floyd_fire(this, -6); }
void floyd_attack6(entity this) { set_animofs(this, anim_floyd_attack1, 6, floyd_attack7); ai_face(this); }
void floyd_attack5(entity this) { set_animofs(this, anim_floyd_attack1, 5, floyd_attack6); ai_face(this); }
void floyd_attack4(entity this) { set_animofs(this, anim_floyd_attack1, 4, floyd_attack5); floyd_fire(this, 0); }
void floyd_attack3(entity this) { set_animofs(this, anim_floyd_attack1, 3, floyd_attack4); ai_face(this); }
void floyd_attack2(entity this) { set_animofs(this, anim_floyd_attack1, 2, floyd_attack3); ai_face(this); }
void floyd_attack1(entity this) { set_animofs(this, anim_floyd_attack1, 1, floyd_attack2); floyd_fire(this, 6); }


/*
================
pain
================
*/

void floyd_paina6(entity this) { set_animofs(this, anim_floyd_paina1, 6, floyd_run1); }
void floyd_paina5(entity this) { set_animofs(this, anim_floyd_paina1, 5, floyd_paina6); }
void floyd_paina4(entity this) { set_animofs(this, anim_floyd_paina1, 4, floyd_paina5); }
void floyd_paina3(entity this) { set_animofs(this, anim_floyd_paina1, 3, floyd_paina4); }
void floyd_paina2(entity this) { set_animofs(this, anim_floyd_paina1, 2, floyd_paina3); }
void floyd_paina1(entity this) { set_animofs(this, anim_floyd_paina1, 1, floyd_paina2); }

void floyd_painb10(entity this) { set_animofs(this, anim_floyd_painb1, 10, floyd_run1); }
void floyd_painb9(entity this) { set_animofs(this, anim_floyd_painb1, 9, floyd_painb10); }
void floyd_painb8(entity this) { set_animofs(this, anim_floyd_painb1, 8, floyd_painb9); }
void floyd_painb7(entity this) { set_animofs(this, anim_floyd_painb1, 7, floyd_painb8); }
void floyd_painb6(entity this) { set_animofs(this, anim_floyd_painb1, 6, floyd_painb7); }
void floyd_painb5(entity this) { set_animofs(this, anim_floyd_painb1, 5, floyd_painb6); }
void floyd_painb4(entity this) { set_animofs(this, anim_floyd_painb1, 4, floyd_painb5); }
void floyd_painb3(entity this) { set_animofs(this, anim_floyd_painb1, 3, floyd_painb4); }
void floyd_painb2(entity this) { set_animofs(this, anim_floyd_painb1, 2, floyd_painb3); }
void floyd_painb1(entity this) { set_animofs(this, anim_floyd_painb1, 1, floyd_painb2); }

void floyd_painc14(entity this) { set_animofs(this, anim_floyd_painc1, 14, floyd_run1); ai_painforward(this, 1.25); }
void floyd_painc13(entity this) { set_animofs(this, anim_floyd_painc1, 13, floyd_painc14); ai_painforward(this, 1.25); }
void floyd_painc12(entity this) { set_animofs(this, anim_floyd_painc1, 12, floyd_painc13); ai_painforward(this, 1.25); }
void floyd_painc11(entity this) { set_animofs(this, anim_floyd_painc1, 11, floyd_painc12); ai_painforward(this, 1.25); }
void floyd_painc10(entity this) { set_animofs(this, anim_floyd_painc1, 10, floyd_painc11); ai_painforward(this, 1.25); }
void floyd_painc9(entity this) { set_animofs(this, anim_floyd_painc1, 9, floyd_painc10); ai_painforward(this, 1.25); }
void floyd_painc8(entity this) { set_animofs(this, anim_floyd_painc1, 8, floyd_painc9); ai_painforward(this, 1.25); }
void floyd_painc7(entity this) { set_animofs(this, anim_floyd_painc1, 7, floyd_painc8); ai_painforward(this, 1.25); }
void floyd_painc6(entity this) { set_animofs(this, anim_floyd_painc1, 6, floyd_painc7); }
void floyd_painc5(entity this) { set_animofs(this, anim_floyd_painc1, 5, floyd_painc6); }
void floyd_painc4(entity this) { set_animofs(this, anim_floyd_painc1, 4, floyd_painc5); }
void floyd_painc3(entity this) { set_animofs(this, anim_floyd_painc1, 3, floyd_painc4); }
void floyd_painc2(entity this) { set_animofs(this, anim_floyd_painc1, 2, floyd_painc3); }
void floyd_painc1(entity this) { set_animofs(this, anim_floyd_painc1, 1, floyd_painc2); }

void floyd_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
		
	if(random() * 150 > damage)
		return; // didn't flinch
	
	_sound(this, CH_VOICE, "floyd/pain.wav", 1, ATTN_NORM);

	if(this.spawnflags & FLOYD_ROLLING)
		return;
	
	float d = ANGLEMOD(this.angles_y - this.ideal_yaw);

	if(d > 90 && d < 270) //lurch forward if hit in the back
	{
		floyd_painc1(this);
		this.pain_finished = time + 2;
	}
	else if(random() < 0.4)
	{
		floyd_paina1(this);
		this.pain_finished = time + 1;
	}
	else
	{
		floyd_painb1(this);
		this.pain_finished = time + 2;
	}
	
}

/*
================
death
================
*/

void ThrowFloydHead(entity this, string gibname, float dm)
{
	entity head = this; //spawn();
	setorigin(head, this.origin);
	head.skin = 0;
	_setmodel(head, gibname);
	head.frame = 0;
	set_movetype(head, MOVETYPE_BOUNCE);
	head.takedamage = DAMAGE_NO;
	head.solid = SOLID_TRIGGER;
	setorigin(head, head.origin);
	setsize(head, '-16 -16 0', '16 16 32');
	head.velocity = VelocityForDamage(this, dm);
	head.origin_z = this.origin_z + 32;
	head.angles_y = this.angles_y;
	UNSET_ONGROUND(head);
	head.avelocity = crandom() * '0 600 0';
	head.classname = "gib";
	setthink(head, CorpseThink);
	head.nextthink = time + 2;
}

void ThrowFloydGib(entity this, string gibname, float dm)
{
	entity gib = spawn();
	gib.origin_x = this.origin_x - 16 + random()*32;
	gib.origin_y = this.origin_y - 16 + random()*32;
	gib.origin_z = this.origin_z - 32 + random()*64;
	_setmodel(gib, gibname);
	setsize(gib, '0 0 0', '0 0 0');
	gib.velocity_x = crandom() * 400;
	gib.velocity_y = crandom() * 400;
	gib.velocity_z = 200 + random() * 400;
	set_movetype(gib, MOVETYPE_BOUNCE);
	gib.solid = SOLID_TRIGGER;
	setorigin(gib, gib.origin);
	gib.avelocity_x = random()*600;
	gib.avelocity_y = random()*600;
	gib.avelocity_z = random()*600;
	setthink(gib, SUB_Remove);
	gib.ltime = time;
	gib.nextthink = time + 10 + random()*10;
	gib.flags = 0;	
	gib.classname = "gib";	
}

void floyd_explode(entity this)
{
	T_RadiusDamage(this, this, 100, DEATH_MONSTER_FLOYD.m_id, NULL);
	if(this.health > -50)
		this.health = -50;

	//gibs
	int gibs = 8;
	while(gibs > 0)
	{
		ThrowFloydGib(this, "progs/fgib1.mdl", this.health);
		gibs -= 1;
	}
	
	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	//BecomeExplosion ();
	//TriggerExplosion();

	if(!(this.spawnflags & FLOYD_ROLLING)) //don't throw head if you're on your back, cuz it looks funny
		ThrowFloydHead(this, "progs/h_floyd.mdl", this.health);
	else
		BecomeExplosion(this);
}

void floyd_death15(entity this) { set_animofs(this, anim_floyd_death1, 15, floyd_explode); this.spawnflags |= FLOYD_ROLLING; this.takedamage = DAMAGE_NO;}
void floyd_death14(entity this) { set_animofs(this, anim_floyd_death1, 14, floyd_death15); }
void floyd_death13(entity this) { set_animofs(this, anim_floyd_death1, 13, floyd_death14); }
void floyd_death12(entity this) { set_animofs(this, anim_floyd_death1, 12, floyd_death13); }
void floyd_death11(entity this) { set_animofs(this, anim_floyd_death1, 11, floyd_death12); }
void floyd_death10(entity this) { set_animofs(this, anim_floyd_death1, 10, floyd_death11); ai_painforward(this, -8); }
void floyd_death9(entity this) { set_animofs(this, anim_floyd_death1, 9, floyd_death10); ai_painforward(this, -8); }
void floyd_death8(entity this) { set_animofs(this, anim_floyd_death1, 8, floyd_death9); ai_painforward(this, -8); }
void floyd_death7(entity this) { set_animofs(this, anim_floyd_death1, 7, floyd_death8); ai_painforward(this, -8); }
void floyd_death6(entity this) { set_animofs(this, anim_floyd_death1, 6, floyd_death7); ai_painforward(this, -5); }
void floyd_death5(entity this) { set_animofs(this, anim_floyd_death1, 5, floyd_death6); ai_painforward(this, -5); }
void floyd_death4(entity this) { set_animofs(this, anim_floyd_death1, 4, floyd_death5); ai_painforward(this, -3.33); }
void floyd_death3(entity this) { set_animofs(this, anim_floyd_death1, 3, floyd_death4); ai_painforward(this, -3.34); }
void floyd_death2(entity this) { set_animofs(this, anim_floyd_death1, 2, floyd_death3); ai_painforward(this, -3.33); }

void floyd_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	//check for gib
	if(this.health < -35 || random() > 0.75 || (this.spawnflags & FLOYD_ROLLING))
	{
		this.takedamage = DAMAGE_NO;
		setthink(this, floyd_explode);
		this.nextthink = time; // add a delay so there isn't a recursive explosion
	}
	else // regular death
	{
		_sound(this, CH_VOICE, "floyd/death.wav", 1, ATTN_NORM);
		floyd_death2(this); //skip $death1, which is the idle frame
	}
}

void floyd_roll(entity this)
{
	this.frame += 1;

	// pardon the uglies here, animations are off by one!
	if(this.frame > (anim_floyd_death1 + 15 - 1) || this.frame < (anim_floyd_death1 + 10 - 1))
		this.frame = (anim_floyd_death1 + 10 - 1);

	setthink(this, floyd_roll);
	this.nextthink = time + 0.1;
}

/*
================
this chunk of code figures out rolling floyd's ideal bounding box no matter at what angle he's placed.
================
*/

vector test_moos_angle(vector testmoos, float testang, float testradius, float minmax)
{
	vector floyd_moos = testmoos;
	vector testangs = '0 0 0';
	testangs.y = testang;
	makevectors(testangs); 
	v_forward.y = v_forward.y * testradius;
	v_forward.x = v_forward.x * testradius;
	if(minmax == 1) //1 for maxes, 0 for mins
	{
		if(v_forward.y > floyd_moos.y)
			floyd_moos.y = v_forward.y;
		if(v_forward.x > floyd_moos.x)
			floyd_moos.x = v_forward.x;
	}
	else
	{
		if(v_forward.y < floyd_moos.y)
			floyd_moos.y = v_forward.y;
		if(v_forward.x < floyd_moos.x)
			floyd_moos.x = v_forward.x;
	}
	return floyd_moos;
}

vector get_floyd_mins(entity this)
{
	vector floyd_mins = '0 0 -24';
	float feetyaw = ANGLEMOD(this.angles_y);

	floyd_mins = test_moos_angle(floyd_mins, feetyaw + 17.4, 38, 0); //foot
	floyd_mins = test_moos_angle(floyd_mins, feetyaw + 180 - 17.4, 38, 0); //shoulder
	floyd_mins = test_moos_angle(floyd_mins, feetyaw + 180, 40, 0); //head
	floyd_mins = test_moos_angle(floyd_mins, feetyaw + 180 + 17.4, 38, 0); //shoulder
	floyd_mins = test_moos_angle(floyd_mins, feetyaw + 360 - 17.4, 38, 0); //foot

	return floyd_mins;
}

vector get_floyd_maxs(entity this)
{
	vector floyd_maxs = '0 0 12';
	float feetyaw = ANGLEMOD(this.angles_y);

	floyd_maxs = test_moos_angle(floyd_maxs, feetyaw + 17.4, 38, 1); //foot
	floyd_maxs = test_moos_angle(floyd_maxs, feetyaw + 180 - 17.4, 38, 1); //shoulder
	floyd_maxs = test_moos_angle(floyd_maxs, feetyaw + 180, 40, 1); //head
	floyd_maxs = test_moos_angle(floyd_maxs, feetyaw + 180 + 17.4, 38, 1); //shoulder
	floyd_maxs = test_moos_angle(floyd_maxs, feetyaw + 360 - 17.4, 38, 1); //foot
	
	return floyd_maxs;
}

/*
================
awake
================
*/

void floyd_awake_go(entity this)
{
	if(this.health <= 0)
		return;
		
	this.spawnflags &= ~FLOYD_ASLEEP;
	this.skin = 0;
	this.th_stand = floyd_idle1;
	this.th_walk = floyd_walk1;
	this.th_run = floyd_run1;
	this.th_pain = floyd_pain;
	this.th_die = floyd_die;
	this.th_missile = floyd_ready1;
	this.nextthink = time + 0.1;
	setthink(this, FoundTarget);
	this.use = monster_use;
	floyd_ready1(this);
}

void floyd_painawake(entity this, entity attacker, float damage, int deathtype)
{
	floyd_awake_go(this);
	this.enemy = attacker;
	this.nextthink = time + 0.1;
	setthink(this, FoundTarget);
}

void floyd_awake(entity this, entity actor, entity trigger)
{
	floyd_awake_go(this);
	this.enemy = actor;
	this.nextthink = time + 0.1;
	setthink(this, FoundTarget);
}

/*QUAKED monster_floyd (1 0 0) (-32 -32 -24) (32 32 64) AMBUSH ROLLING ASLEEP
Automaton, 200 health points.

AMBUSH: floyd will only wake up on really seeing the player, not another monster getting angry.

ROLLING: floyd is on his back and helpless. explodes after taking 50 damage.

ASLEEP: floyd will not respond to anything unless he is shot or his targetname is triggered.
*/
spawnfunc(monster_floyd) { monster_start(this, true, MON_FLOYD); }
#endif // SVQC

#ifdef SVQC
METHOD(Floyd, mr_setup, bool(Floyd this, entity actor))
{
    TC(Floyd, this);

	precache_model2("progs/floyd.mdl");
	precache_model2("progs/flaser.mdl");
	precache_model2("progs/h_floyd.mdl");
	precache_model2("progs/fgib1.mdl");
	
	precache_sound2("floyd/idle.wav");
	precache_sound2("floyd/sight.wav");
	precache_sound2("floyd/pain.wav");
	precache_sound2("floyd/fire.wav");
	precache_sound2("floyd/death.wav");
	precache_sound2("enforcer/enfstop.wav");

	// random chance outside of horde to be on side!
	if(!horde_ent && !actor.spawnflags && random() <= 0.1)
	{
		if(random() > 0.5)
			actor.spawnflags |= FLOYD_ROLLING;
		else
			actor.spawnflags |= FLOYD_ASLEEP;
	}
    
    if(actor.spawnflags & FLOYD_ROLLING)
    {
    	setsize(actor, get_floyd_mins(actor), get_floyd_maxs(actor));
    	actor.health = 75;
    	actor.skin = 0;
    	actor.th_stand = floyd_roll;
		actor.th_walk = floyd_roll;
		actor.th_run = floyd_roll;
		actor.th_pain = floyd_pain;
		actor.th_die = floyd_die;
    }
    else if(actor.spawnflags & FLOYD_ASLEEP)
    {
    	setsize(actor, this.m_mins, this.m_maxs);
    	actor.health = 200;
    	actor.skin = 1;
    	actor.th_stand = floyd_sleep;
		actor.th_run = floyd_sleep;
		actor.th_pain = floyd_painawake;
		actor.th_die = floyd_die;
		actor.use = floyd_awake;

		setorigin(actor, actor.origin + '0 0 10');
		droptofloor(actor);
		actor.ideal_yaw = actor.angles * '0 1 0';
		if(!actor.yaw_speed)
			actor.yaw_speed = 20;
		actor.view_ofs = '0 0 25';
    }
    else
    {
    	setsize(actor, this.m_mins, this.m_maxs);
    	actor.health = 200;
    	actor.skin = 0;
    	actor.th_stand = floyd_idle1;
		actor.th_walk = floyd_walk1;
		actor.th_run = floyd_run1;
		actor.th_pain = floyd_pain;
		actor.th_die = floyd_die;
		actor.th_missile = floyd_ready1;
    }

    return true;
}
METHOD(Floyd, mr_sight, bool(Floyd this, entity actor))
{
    TC(Floyd, this);

    if(!(actor.spawnflags & FLOYD_ASLEEP) || (actor.spawnflags & FLOYD_ROLLING))
		sound(actor, CH_VOICE, this.m_sound, 1, ATTN_NORM);

    return true;
}
#endif
