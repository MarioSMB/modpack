/*
==============================================================================

WIZARD

==============================================================================
*/

$cd id1/models/a_wizard
$origin 0 0 24
$base wizbase	
$skin wizbase

$frame hover1 hover2 hover3 hover4 hover5 hover6 hover7 hover8
$frame hover9 hover10 hover11 hover12 hover13 hover14 hover15

$frame fly1 fly2 fly3 fly4 fly5 fly6 fly7 fly8 fly9 fly10
$frame fly11 fly12 fly13 fly14

$frame magatt1 magatt2 magatt3 magatt4 magatt5 magatt6 magatt7
$frame magatt8 magatt9 magatt10 magatt11 magatt12 magatt13

$frame pain1 pain2 pain3 pain4

$frame death1 death2 death3 death4 death5 death6 death7 death8

/*
==============================================================================

WIZARD

If the player moves behind cover before the missile is launched, launch it
at the last visible spot with no velocity leading, in hopes that the player
will duck back out and catch it.
==============================================================================
*/

/*
=============
LaunchMissile

Sets the given entities velocity and angles so that it will hit this.enemy
if this.enemy maintains it's current velocity
0.1 is moderately accurate, 0.0 is totally accurate
=============
*/
void LaunchMissile(entity missile, float mspeed, float accuracy)
{
	makevectors(this.angles);
		
// set missile speed
	vector vec = this.enemy.origin + this.enemy.mins + this.enemy.size * 0.7 - missile.origin;

// calc aproximate time for missile to reach vec
	float fly = vlen(vec) / mspeed;
	
// get the entities xy velocity
	vector move = vec2(this.enemy.velocity);

// project the target forward in time
	vec = vec + move * fly;
	
	vec = normalize(vec);
	vec = vec + accuracy*v_up*(random()- 0.5) + accuracy*v_right*(random()- 0.5);
	
	missile.velocity = vec * mspeed;

	missile.angles = '0 0 0';
	missile.angles_y = vectoyaw(missile.velocity);

// set missile duration
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);	
}


void wiz_run1();
void wiz_side1();

/*
=================
WizardCheckAttack
=================
*/
float WizardCheckAttack()
{
	if(time < this.attack_finished)
		return false;
	if(!this.enemy_vis)
		return false;

	if(this.enemy_range == RANGE_FAR)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			wiz_run1();
		}
		return false;
	}
		
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, false, this);

	if(trace_ent != targ)
	{	// don't have a clear shot, so move to a side
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			wiz_run1();
		}
		return false;
	}

	float chance;	
	if(this.enemy_range == RANGE_MELEE)
		chance = 0.9;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.6;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.2;
	else
		chance = 0;

	if(random() < chance)
	{
		this.attack_state = AS_MISSILE;
		return true;
	}

	if(this.enemy_range == RANGE_MID)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			wiz_run1();
		}
	}
	else
	{
		if(this.attack_state != AS_SLIDING)
		{
			this.attack_state = AS_SLIDING;
			wiz_side1();
		}
	}
	
	return false;
}

/*
=================
WizardAttackFinished
=================
*/
void WizardAttackFinished(entity this)
{
	if(this.enemy_range >= RANGE_MID || !this.enemy_vis)
	{
		this.attack_state = AS_STRAIGHT;
		setthink(this, wiz_run1);
	}
	else
	{
		this.attack_state = AS_SLIDING;
		setthink(this, wiz_side1);
	}
}

/*
==============================================================================

FAST ATTACKS

==============================================================================
*/

void Wiz_FastFire()
{
	vector		vec;
	vector		dst;

	if(this.owner.health > 0)
	{
		this.owner.effects = this.owner.effects | EF_MUZZLEFLASH;

		makevectors(this.enemy.angles);	
		dst = this.enemy.origin - 13*this.movedir;
	
		vec = normalize(dst - this.origin);
		_sound(this, CHAN_WEAPON, "wizard/wattack.wav", 1, ATTN_NORM);
		launch_spike(this.origin, vec);
		newmis.velocity = vec*600;
		newmis.owner = this.owner;
		newmis.classname = "wizspike";
		_setmodel(newmis, "progs/w_spike.mdl");
		setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);		
	}

	delete(this);
}


void Wiz_StartFast()
{
	entity	missile;
	
	_sound(this, CHAN_WEAPON, "wizard/wattack.wav", 1, ATTN_NORM);
	this.v_angle = this.angles;
	makevectors(this.angles);

	missile = spawn();
	missile.owner = this;
	missile.nextthink = time + 0.6;
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin + '0 0 30' + v_forward*14 + v_right*14);
	missile.enemy = this.enemy;
	missile.nextthink = time + 0.8;
	setthink(missile, Wiz_FastFire);
	missile.movedir = v_right;

	missile = spawn();
	missile.owner = this;
	missile.nextthink = time + 1;
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin + '0 0 30' + v_forward*14 + v_right* -14);
	missile.enemy = this.enemy;
	missile.nextthink = time + 0.3;
	setthink(missile, Wiz_FastFire);
	missile.movedir = VEC_ORIGIN - v_right;
}



void Wiz_idle_sound()
{
	float wr = random() * 5;

	if(this.waitmin < time)
	{
	 	this.waitmin = time + 2;
	 	if(wr > 4.5) 
	 		_sound(this, CHAN_VOICE, "wizard/widle1.wav", 1,  ATTN_IDLE);
	 	if(wr < 1.5)
	 		_sound(this, CHAN_VOICE, "wizard/widle2.wav", 1, ATTN_IDLE);
	}
	return;
}

void(entity this)	wiz_stand1	=[	$hover1,		wiz_stand2	] {ai_stand(this);}
void()	wiz_stand2	=[	$hover2,		wiz_stand3	] {ai_stand(this);}
void()	wiz_stand3	=[	$hover3,		wiz_stand4	] {ai_stand(this);}
void()	wiz_stand4	=[	$hover4,		wiz_stand5	] {ai_stand(this);}
void()	wiz_stand5	=[	$hover5,		wiz_stand6	] {ai_stand(this);}
void()	wiz_stand6	=[	$hover6,		wiz_stand7	] {ai_stand(this);}
void()	wiz_stand7	=[	$hover7,		wiz_stand8	] {ai_stand(this);}
void()	wiz_stand8	=[	$hover8,		wiz_stand1	] {ai_stand(this);}

void()	wiz_walk1	=[	$hover1,		wiz_walk2	] {ai_walk(8);
Wiz_idle_sound();}
void()	wiz_walk2	=[	$hover2,		wiz_walk3	] {ai_walk(8);}
void()	wiz_walk3	=[	$hover3,		wiz_walk4	] {ai_walk(8);}
void()	wiz_walk4	=[	$hover4,		wiz_walk5	] {ai_walk(8);}
void()	wiz_walk5	=[	$hover5,		wiz_walk6	] {ai_walk(8);}
void()	wiz_walk6	=[	$hover6,		wiz_walk7	] {ai_walk(8);}
void()	wiz_walk7	=[	$hover7,		wiz_walk8	] {ai_walk(8);}
void()	wiz_walk8	=[	$hover8,		wiz_walk1	] {ai_walk(8);}

void()	wiz_side1	=[	$hover1,		wiz_side2	] {ai_run(8);
Wiz_idle_sound();}
void()	wiz_side2	=[	$hover2,		wiz_side3	] {ai_run(8);}
void()	wiz_side3	=[	$hover3,		wiz_side4	] {ai_run(8);}
void()	wiz_side4	=[	$hover4,		wiz_side5	] {ai_run(8);}
void()	wiz_side5	=[	$hover5,		wiz_side6	] {ai_run(8);}
void()	wiz_side6	=[	$hover6,		wiz_side7	] {ai_run(8);}
void()	wiz_side7	=[	$hover7,		wiz_side8	] {ai_run(8);}
void()	wiz_side8	=[	$hover8,		wiz_side1	] {ai_run(8);}

void()	wiz_run1	=[	$fly1,		wiz_run2	] {ai_run(16);
Wiz_idle_sound();
}
void()	wiz_run2	=[	$fly2,		wiz_run3	] {ai_run(16);}
void()	wiz_run3	=[	$fly3,		wiz_run4	] {ai_run(16);}
void()	wiz_run4	=[	$fly4,		wiz_run5	] {ai_run(16);}
void()	wiz_run5	=[	$fly5,		wiz_run6	] {ai_run(16);}
void()	wiz_run6	=[	$fly6,		wiz_run7	] {ai_run(16);}
void()	wiz_run7	=[	$fly7,		wiz_run8	] {ai_run(16);}
void()	wiz_run8	=[	$fly8,		wiz_run9	] {ai_run(16);}
void()	wiz_run9	=[	$fly9,		wiz_run10	] {ai_run(16);}
void()	wiz_run10	=[	$fly10,		wiz_run11	] {ai_run(16);}
void()	wiz_run11	=[	$fly11,		wiz_run12	] {ai_run(16);}
void()	wiz_run12	=[	$fly12,		wiz_run13	] {ai_run(16);}
void()	wiz_run13	=[	$fly13,		wiz_run14	] {ai_run(16);}
void()	wiz_run14	=[	$fly14,		wiz_run1	] {ai_run(16);}

void()	wiz_fast1	=[	$magatt1,		wiz_fast2	] {ai_face(this);Wiz_StartFast();}
void()	wiz_fast2	=[	$magatt2,		wiz_fast3	] {ai_face(this);}
void()	wiz_fast3	=[	$magatt3,		wiz_fast4	] {ai_face(this);}
void()	wiz_fast4	=[	$magatt4,		wiz_fast5	] {ai_face(this);}
void()	wiz_fast5	=[	$magatt5,		wiz_fast6	] {ai_face(this);}
void()	wiz_fast6	=[	$magatt6,		wiz_fast7	] {ai_face(this);}
void()	wiz_fast7	=[	$magatt5,		wiz_fast8	] {ai_face(this);}
void()	wiz_fast8	=[	$magatt4,		wiz_fast9	] {ai_face(this);}
void()	wiz_fast9	=[	$magatt3,		wiz_fast10	] {ai_face(this);}
void()	wiz_fast10	=[	$magatt2,		wiz_run1	] {ai_face(this);SUB_AttackFinished(2);WizardAttackFinished();}

void()	wiz_pain1	=[	$pain1,		wiz_pain2	] {}
void()	wiz_pain2	=[	$pain2,		wiz_pain3	] {}
void()	wiz_pain3	=[	$pain3,		wiz_pain4	] {}
void()	wiz_pain4	=[	$pain4,		wiz_run1	] {}

void()	wiz_death1	=[	$death1,		wiz_death2	] {

this.velocity_x = -200 + 400*random();
this.velocity_y = -200 + 400*random();
this.velocity_z = 100 + 100*random();
this.flags &= ~FL_ONGROUND;
_sound(this, CHAN_VOICE, "wizard/wdeath.wav", 1, ATTN_NORM);
}
void()	wiz_death2	=[	$death2,		wiz_death3	] {}
void()	wiz_death3	=[	$death3,		wiz_death4	]{this.solid = SOLID_NOT;}
void()	wiz_death4	=[	$death4,		wiz_death5	] {}
void()	wiz_death5	=[	$death5,		wiz_death6	] {}
void()	wiz_death6	=[	$death6,		wiz_death7	] {}
void()	wiz_death7	=[	$death7,		wiz_death8	] {}
void()	wiz_death8	=[	$death8,		wiz_death8	] {}

void wiz_die(entity this, entity attacker)
{
// check for gib
	if(this.health < -40)
	{
		_sound(this, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead("progs/h_wizard.mdl", this.health);
		ThrowGib("progs/gib2.mdl", this.health);
		ThrowGib("progs/gib2.mdl", this.health);
		ThrowGib("progs/gib2.mdl", this.health);
		return;
	}

	wiz_death1();
}


void Wiz_Pain(entity this, entity attacker, float damage)
{
	_sound(this, CHAN_VOICE, "wizard/wpain.wav", 1, ATTN_NORM);
	if(random()*70 > damage)
		return;		// didn't flinch

	wiz_pain1();
}


void Wiz_Missile()
{
	wiz_fast1();
}

string wiz_sight() { return "wizard/wsight.wav"; }
string wiz_deathmessage() { return "was scragged by a Scrag"; }

/*QUAKED monster_wizard(1 0 0)(-16 -16 -24)(16 16 40) Ambush
*/
spawnfunc(monster_wizard)
{
	if(deathmatch)
	{
		delete(this);
		return;
	}
	precache_model("progs/wizard.mdl");
	precache_model("progs/h_wizard.mdl");
	precache_model("progs/w_spike.mdl");

	precache_sound("wizard/hit.wav");		// used by c code
	precache_sound("wizard/wattack.wav");
	precache_sound("wizard/wdeath.wav");
	precache_sound("wizard/widle1.wav");
	precache_sound("wizard/widle2.wav");
	precache_sound("wizard/wpain.wav");
	precache_sound("wizard/wsight.wav");

	this.solid = SOLID_SLIDEBOX;
	this.movetype = MOVETYPE_STEP;

	_setmodel(this, "progs/wizard.mdl");

	setsize(this, '-16 -16 -24', '16 16 40');
	this.health = 80;

	this.th_stand = wiz_stand1;
	this.th_walk = wiz_walk1;
	this.th_run = wiz_run1;
	this.th_missile = Wiz_Missile;
	this.th_pain = Wiz_Pain;
	this.th_die = wiz_die;

	this.sightsound = wiz_sight;
	this.checkattack = WizardCheckAttack;
	this.deathmessage = wiz_deathmessage;
		
	flymonster_start(this);
}
