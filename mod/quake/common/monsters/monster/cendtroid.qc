#include "centroid.qh"

#ifdef SVQC
const int anim_scourge_stand = 0; //'0 11 0';
const int anim_scourge_walk = 12; //'12 17 0';
const int anim_scourge_shoot = 18; //'18 19 0';
const int anim_scourge_sting = 20; //'20 30 0';
const int anim_scourge_pain = 31; //'31 35 0';
const int anim_scourge_death = 36; //'36 40 0';

/*
===========
ScourgeCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool ScourgeCheckAttack(entity this)
{
	entity targ = this.enemy;
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	if(vdist(spot1 - spot2, <=, 100))
	{
		if(CanDamage(this.enemy, this))
		{
			this.attack_state = AS_MELEE;
			return true;
		}
	}
	if(time < this.attack_finished)
		return false;

	if(!this.enemy_visible)
		return false;


	float chance = spot2.z - spot1.z;
	if(chance > 64)
		return false;
	else if(chance < -200)
		return false;

	if(vdist(spot1 - spot2, >, 1000))
		return false;

	if(vdist(spot1 - spot2, <, 150))
		return false;

	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
		return false;	// don't have a clear shot

// missile attack
//   if(enemy_range == RANGE_FAR)
//      return false;

	this.attack_state = AS_MISSILE;
	SUB_AttackFinished(this, 2 + 2*random());
	return true;
}

void SCOURGE_FireSpikes(entity this, float ox)
{
	ai_face(this);
	makevectors(this.angles);
	vector src = this.origin - '0 0 19' + v_right * ox + v_forward * 14;
	vector vec = (this.enemy.origin + (200 * v_forward)) - src;
	vec = normalize(vec);
	_sound(this, CH_WEAPON_SINGLE, "weapons/rocket1i.wav", 1, ATTN_NORM);
	entity missile = launch_spike(this, src, vec);
	missile.projectiledeathtype = DEATH_MONSTER_CENTROID.m_id;

	this.attack_finished = time + 0.2;
}

// Attack_With_Tail
//
void Attack_With_Tail(entity this)
{
	ai_face(this);

	vector delta = this.enemy.origin - this.origin;

	if(vdist(delta, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;

	float ldmg = (random() + random() + random()) * 40;
	T_Damage(this.enemy, this, this, ldmg, this.projectiledeathtype);
	_sound(this, CH_WEAPON_SINGLE, "shambler/smack.wav", 1, ATTN_NORM);

	SpawnMeatSpray(this, this.origin + v_forward * 16, crandom() * 50 * v_right);
}

void ScourgeTriggerThink(entity this);
void ScourgeTriggerTouch(entity this, entity toucher);
void scourge_think(entity this)
{
	if(!this.state && this.health > 0)
	{
		entity trig = spawn();
		trig.angles = '0 0 0';
		trig.solid = SOLID_TRIGGER;
		setsize( trig, '-64 -64 -24', '64 64 64');
		trig.takedamage = DAMAGE_NO;
		set_movetype(trig, MOVETYPE_NONE);
		trig.modelindex = 0;
		trig.model = "";
		trig.lastvictim = this;
		setthink(trig, ScourgeTriggerThink);
		settouch(trig, ScourgeTriggerTouch);
		trig.nextthink = time + 0.1 + random();
		setorigin(trig,this.origin);
		this.lastvictim = trig;
		this.state = 1;
	}
	if((this.spawnsilent == 0) && (this.spawnmulti == 1))
		sound(this, CH_PLAYER_SINGLE, SND_Null, 1, ATTEN_IDLE);
	else if((this.spawnsilent == 1) && (this.spawnmulti == 0))
		_sound(this, CH_PLAYER_SINGLE, "scourge/walk.wav", 1, ATTEN_IDLE);

	this.spawnmulti = this.spawnsilent;
}

void ai_right(entity this, float dist)
{
	t_walkmove(this, (this.angles_y + 90), dist);
}

void ai_left(entity this, float dist)
{
	t_walkmove(this, (this.angles_y + 270), dist);
}
//============================================================================

//void() scourge_wake1;
void scourge_stand1(entity this);
void scourge_stand12(entity this) { set_animofs(this, anim_scourge_stand, 12, scourge_stand1); this.spawnsilent = 0; ai_stand(this); scourge_think(this); }
void scourge_stand11(entity this) { set_animofs(this, anim_scourge_stand, 11, scourge_stand12); this.spawnsilent = 0; ai_stand(this); scourge_think(this); }
void scourge_stand10(entity this) { set_animofs(this, anim_scourge_stand, 10, scourge_stand11); this.spawnsilent = 0; ai_stand(this); scourge_think(this); }
void scourge_stand9(entity this) { set_animofs(this, anim_scourge_stand, 9, scourge_stand10); this.spawnsilent = 0; ai_stand(this); scourge_think(this); }
void scourge_stand8(entity this) { set_animofs(this, anim_scourge_stand, 8, scourge_stand9); this.spawnsilent = 0; ai_stand(this); scourge_think(this); }
void scourge_stand7(entity this) { set_animofs(this, anim_scourge_stand, 7, scourge_stand8); this.spawnsilent = 0; ai_stand(this); scourge_think(this); }
void scourge_stand6(entity this) { set_animofs(this, anim_scourge_stand, 6, scourge_stand7); this.spawnsilent = 0; ai_stand(this); scourge_think(this); }
void scourge_stand5(entity this) { set_animofs(this, anim_scourge_stand, 5, scourge_stand6); this.spawnsilent = 0; ai_stand(this); scourge_think(this); }
void scourge_stand4(entity this) { set_animofs(this, anim_scourge_stand, 4, scourge_stand5); this.spawnsilent = 0; ai_stand(this); scourge_think(this); }
void scourge_stand3(entity this) { set_animofs(this, anim_scourge_stand, 3, scourge_stand4); this.spawnsilent = 0; ai_stand(this); scourge_think(this); }
void scourge_stand2(entity this) { set_animofs(this, anim_scourge_stand, 2, scourge_stand3); this.spawnsilent = 0; ai_stand(this); scourge_think(this); }
void scourge_stand1(entity this) { set_animofs(this, anim_scourge_stand, 1, scourge_stand2); this.spawnsilent = 0; ai_stand(this); scourge_think(this); }

void scourge_walk1(entity this);
void scourge_walk6(entity this) { set_animofs(this, anim_scourge_walk, 6, scourge_walk1); ai_walk(this, 8); }
void scourge_walk5(entity this) { set_animofs(this, anim_scourge_walk, 5, scourge_walk6); ai_walk(this, 8); }
void scourge_walk4(entity this) { set_animofs(this, anim_scourge_walk, 4, scourge_walk5); ai_walk(this, 8); }
void scourge_walk3(entity this) { set_animofs(this, anim_scourge_walk, 3, scourge_walk4); ai_walk(this, 8); }
void scourge_walk2(entity this) { set_animofs(this, anim_scourge_walk, 2, scourge_walk3); ai_walk(this, 8); }
void scourge_walk1(entity this)
{
	set_animofs(this, anim_scourge_walk, 1, scourge_walk2);
	if(random() < 0.1)
		_sound(this, CH_VOICE, "scourge/idle.wav", 1, ATTEN_IDLE);
	this.spawnsilent = 1;
	scourge_think(this);
	ai_walk(this, 8);
}

void scourge_run1(entity this);
void scourge_run6(entity this) { set_animofs(this, anim_scourge_walk, 6, scourge_run1); ai_run(this, 14); }
void scourge_run5(entity this) { set_animofs(this, anim_scourge_walk, 5, scourge_run6); ai_run(this, 14); }
void scourge_run4(entity this) { set_animofs(this, anim_scourge_walk, 4, scourge_run5); ai_run(this, 14); }
void scourge_run3(entity this) { set_animofs(this, anim_scourge_walk, 3, scourge_run4); ai_run(this, 14); }
void scourge_run2(entity this) { set_animofs(this, anim_scourge_walk, 2, scourge_run3); scourge_think(this);ai_run(this, 14); }
void scourge_run1(entity this)
{
	set_animofs(this, anim_scourge_walk, 1, scourge_run2);
	if(random() < 0.1)
		_sound(this, CH_VOICE, "scourge/idle.wav", 1, ATTEN_IDLE);
	this.spawnsilent = 1;
	scourge_think(this);
	ai_run(this, 18);
}

void scourge_strafeleft6(entity this) { set_animofs(this, anim_scourge_walk, 6, scourge_run1); ai_left(this, 14); }
void scourge_strafeleft5(entity this) { set_animofs(this, anim_scourge_walk, 5, scourge_strafeleft6); ai_left(this, 14); }
void scourge_strafeleft4(entity this) { set_animofs(this, anim_scourge_walk, 4, scourge_strafeleft5); ai_left(this, 14); }
void scourge_strafeleft3(entity this) { set_animofs(this, anim_scourge_walk, 3, scourge_strafeleft4); ai_left(this, 20); }
void scourge_strafeleft2(entity this) { set_animofs(this, anim_scourge_walk, 2, scourge_strafeleft3); ai_left(this, 20); }
void scourge_strafeleft1(entity this) { set_animofs(this, anim_scourge_walk, 1, scourge_strafeleft2); this.spawnsilent = 1;scourge_think(this);ai_left(this, 20); }

void scourge_straferight6(entity this) { set_animofs(this, anim_scourge_walk, 6, scourge_run1); ai_right(this, 14); }
void scourge_straferight5(entity this) { set_animofs(this, anim_scourge_walk, 5, scourge_straferight6); ai_right(this, 14); }
void scourge_straferight4(entity this) { set_animofs(this, anim_scourge_walk, 4, scourge_straferight5); ai_right(this, 14); }
void scourge_straferight3(entity this) { set_animofs(this, anim_scourge_walk, 3, scourge_straferight4); ai_right(this, 20); }
void scourge_straferight2(entity this) { set_animofs(this, anim_scourge_walk, 2, scourge_straferight3); ai_right(this, 20); }
void scourge_straferight1(entity this) { set_animofs(this, anim_scourge_walk, 1, scourge_straferight2); this.spawnsilent = 1;scourge_think(this);ai_right(this, 20); }

/*
void()   scourge_wake1  =[ anim_scourge_stand2, scourge_wake2  ] {this.spawnsilent = 0;scourge_think(this); }
void()   scourge_wake2  =[ anim_scourge_stand3, scourge_wake3  ] {}
void()   scourge_wake3  =[ anim_scourge_stand4, scourge_wake4  ] {}
void()   scourge_wake4  =[ anim_scourge_stand5, scourge_wake5  ] {}
void()   scourge_wake5  =[ anim_scourge_stand6, scourge_wake6  ] {}
void()   scourge_wake6  =[ anim_scourge_stand7, scourge_run1  ]
	{
	SUB_AttackFinished(1);
	}
//void()   scourge_wake7  =[ anim_scourge_stand7, scourge_run1   ] {}
*/

void scourge_turn1(entity this);
void scourge_turn6(entity this) { set_animofs(this, anim_scourge_walk, 6, scourge_turn1); ai_turn_in_place(this); }
void scourge_turn5(entity this) { set_animofs(this, anim_scourge_walk, 5, scourge_turn6); ai_turn_in_place(this); }
void scourge_turn4(entity this) { set_animofs(this, anim_scourge_walk, 4, scourge_turn5); ai_turn_in_place(this); }
void scourge_turn3(entity this) { set_animofs(this, anim_scourge_walk, 3, scourge_turn4); ai_turn_in_place(this); }
void scourge_turn2(entity this) { set_animofs(this, anim_scourge_walk, 2, scourge_turn3); ai_turn_in_place(this); }
void scourge_turn1(entity this) { set_animofs(this, anim_scourge_walk, 1, scourge_turn2); this.spawnsilent = 1; scourge_think(this); ai_turn_in_place(this); }

void scourge_atk8(entity this) 
{
	set_animofs(this, anim_scourge_shoot, 2, scourge_run1);
	this.effects |= EF_MUZZLEFLASH;
	SCOURGE_FireSpikes(this, 56);
//   SCOURGE_FireSpikes(-56);
	SUB_AttackFinished(this, 4 * random());
}
void scourge_atk7(entity this) 
{
	set_animofs(this, anim_scourge_shoot, 1, scourge_atk8);
	this.effects |= EF_MUZZLEFLASH;
//   SCOURGE_FireSpikes(this, 40);
	SCOURGE_FireSpikes(this, -40);
}
void scourge_atk6(entity this) 
{
	set_animofs(this, anim_scourge_shoot, 2, scourge_atk7);
	this.effects |= EF_MUZZLEFLASH;
//   SCOURGE_FireSpikes(this, 56);
	SCOURGE_FireSpikes(this, -56);
}
void scourge_atk5(entity this) 
{
	set_animofs(this, anim_scourge_shoot, 1, scourge_atk6);
	this.effects |= EF_MUZZLEFLASH;
	SCOURGE_FireSpikes(this, 40);
//   SCOURGE_FireSpikes(this, -40);
}
void scourge_atk4(entity this) 
{
	set_animofs(this, anim_scourge_shoot, 2, scourge_atk5);
	this.effects |= EF_MUZZLEFLASH;
	SCOURGE_FireSpikes(this, 56);
//   SCOURGE_FireSpikes(this, -56);
}
void scourge_atk3(entity this) 
{
	set_animofs(this, anim_scourge_shoot, 1, scourge_atk4);
	this.effects |= EF_MUZZLEFLASH;
//   SCOURGE_FireSpikes(this, 40);
	SCOURGE_FireSpikes(this, -40);
}
void scourge_atk2(entity this) 
{
	set_animofs(this, anim_scourge_shoot, 2, scourge_atk3);
	this.effects |= EF_MUZZLEFLASH;
//   SCOURGE_FireSpikes(this, 56);
	SCOURGE_FireSpikes(this, -56);
}
void scourge_atk1(entity this) 
{
	set_animofs(this, anim_scourge_shoot, 1, scourge_atk2);
	this.spawnsilent = 0;
	scourge_think(this);
	this.effects |= EF_MUZZLEFLASH;
	SCOURGE_FireSpikes(this, 40);
//   SCOURGE_FireSpikes(this, -40);
}

void scourge_melee1(entity this);
void scourge_melee11(entity this) { set_animofs(this, anim_scourge_sting, 11, scourge_run1); ai_face(this); SUB_CheckRefire(this, scourge_melee1); }
void scourge_melee10(entity this) { set_animofs(this, anim_scourge_sting, 10, scourge_melee11); ai_face(this); }
void scourge_melee9(entity this) { set_animofs(this, anim_scourge_sting, 9, scourge_melee10); ai_face(this); }
void scourge_melee8(entity this) { set_animofs(this, anim_scourge_sting, 8, scourge_melee9); ai_face(this); }
void scourge_melee7(entity this) { set_animofs(this, anim_scourge_sting, 7, scourge_melee8); Attack_With_Tail(this); }
void scourge_melee6(entity this) { set_animofs(this, anim_scourge_sting, 6, scourge_melee7); ai_charge(this, 1); }
void scourge_melee5(entity this) { set_animofs(this, anim_scourge_sting, 5, scourge_melee6); _sound(this, CH_WEAPON_SINGLE, "scourge/tailswng.wav", 1, ATTN_NORM); ai_charge(this, 3); }
void scourge_melee4(entity this) { set_animofs(this, anim_scourge_sting, 4, scourge_melee5); ai_charge(this, 2); }
void scourge_melee3(entity this) { set_animofs(this, anim_scourge_sting, 3, scourge_melee4); ai_charge(this, 2); }
void scourge_melee2(entity this) { set_animofs(this, anim_scourge_sting, 2, scourge_melee3); ai_charge(this, 3); }
void scourge_melee1(entity this) { set_animofs(this, anim_scourge_sting, 1, scourge_melee2); this.spawnsilent = 0; scourge_think(this); ai_charge(this, 3); }

void scourge_pain5(entity this) { set_animofs(this, anim_scourge_pain, 5, scourge_run1); }
void scourge_pain4(entity this) { set_animofs(this, anim_scourge_pain, 4, scourge_pain5); }
void scourge_pain3(entity this) { set_animofs(this, anim_scourge_pain, 3, scourge_pain4); }
void scourge_pain2(entity this) { set_animofs(this, anim_scourge_pain, 2, scourge_pain3); }
void scourge_pain1(entity this) { set_animofs(this, anim_scourge_pain, 1, scourge_pain2); this.spawnsilent = 0; scourge_think(this); }

void scourge_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(random() * 50 > damage)
		return;		// didn't flinch

	if(this.pain_finished > time)
		return;

	//float r = random ();
	_sound(this, CH_VOICE, "scourge/pain.wav", 1, ATTN_NORM);

	this.pain_finished = time + 2.0;
	scourge_pain1(this);
}

//============================================================================


void scourge_die5(entity this) { set_animofs(this, anim_scourge_death, 5, scourge_die5); }
void scourge_die4(entity this) { set_animofs(this, anim_scourge_death, 4, scourge_die5); }
void scourge_die3(entity this) { set_animofs(this, anim_scourge_death, 3, scourge_die4); this.solid = SOLID_NOT; }
void scourge_die2(entity this) { set_animofs(this, anim_scourge_death, 2, scourge_die3); }
void scourge_die1(entity this) { set_animofs(this, anim_scourge_death, 1, scourge_die2); this.spawnsilent = 0; scourge_think(this); }

void scourge_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	// check for gib
	// stop sound
	if(this.lastvictim)
	{
		delete(this.lastvictim);
		this.lastvictim = NULL;
	}
	this.spawnsilent = 0;
	scourge_think(this);
	if(this.health < -35)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_scourg.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib2.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "scourge/pain2.wav", 1, ATTN_NORM);
	scourge_die1(this);
}

//
// scourge_melee
//
void scourge_melee(entity this)
{
	scourge_melee1(this);
	SUB_AttackFinished(this, 2 * random());
}

//
// ScourgeTriggerThink
//
void ScourgeTriggerThink(entity this)
{
	if(this.lastvictim.health <= 0)
	{
		delete(this);
		return;
	}
	entity targ = this.lastvictim;
	makevectors(targ.angles);
	setorigin(this, targ.origin + (v_forward * 300));
	this.nextthink = time + 0.1;
}

//
// ScourgeTriggerTouch
//
void ScourgeTriggerTouch(entity this, entity toucher)
{
	if(IS_MONSTER(toucher) || IS_CLIENT(toucher))
		return;
	if(toucher.move_movetype != MOVETYPE_FLYMISSILE)
		return;
	entity targ = this.lastvictim;
	if(targ.health <= 0)
	{
		delete(this);
		return;
	}
	vector dir = targ.origin - toucher.origin;
	dir = normalize(dir);
	if((dir * normalize(toucher.velocity)) < 0.8)
		return;

//   targ.think = targ.th_run;
//   if(targ.flags & FL_ONGROUND)
//      {
			if(time > this.duration)
			{
				if(random() < 0.5)
					scourge_strafeleft1(targ);
				else
					scourge_straferight1(targ);
				targ.duration = time + 1.5;
			}
/*
			targ.origin_z = targ.origin_z + 1;
			targ.velocity = targ.velocity + '0 0 500';
			targ.flags = targ.flags - FL_ONGROUND;
*/
//      }
//   dprint("ouch\n");
	}

string scourge_sight(entity this) { return "scourge/sight.wav"; }

/*QUAKED monster_scourge (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_scourge)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	monster_start(this, MON_CENTROID);
}
#endif // SVQC

#ifdef SVQC
METHOD(Centroid, mr_setup, bool(Centroid this, entity actor))
{
    TC(Centroid, this);

	precache_model2("progs/laser.mdl");
	precache_model2("progs/s_light.mdl");
	precache_model2("progs/spike.mdl");

	precache_sound("scourge/idle.wav");
	precache_sound("scourge/pain.wav");
	precache_sound("scourge/pain2.wav");
	precache_sound("scourge/sight.wav");
	precache_sound("scourge/tailswng.wav");
	precache_sound("scourge/walk.wav");
	precache_sound2("shambler/smack.wav");
	precache_sound2("weapons/rocket1i.wav");

	//   actor.th_turn = scourge_turn1;
	actor.yaw_speed = 60;
	actor.attack_state = AS_DODGING;
	actor.state = 0;

    actor.health = 300;
    actor.th_stand = scourge_stand1;
	actor.th_walk = scourge_walk1;
	actor.th_run = scourge_run1;
	actor.th_pain = scourge_pain;
	actor.th_die = scourge_die;
	actor.th_melee = scourge_melee;
	actor.th_missile = scourge_atk1;

	actor.checkattack = ScourgeCheckAttack;
	actor.sightsound = scourge_sight;

    return true;
}
#endif
