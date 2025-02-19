#include "breeze.qh"

#ifdef SVQC
const int anim_breeze = 0; // no actual animations!

.entity breeze_body;
.float idle_finished;

void breeze_idlesound(entity this)
{
	if(time < this.pain_finished)
		return;

	if(random() < 0.1 && time >= this.idle_finished)
	{
		this.idle_finished = time + 2;
		if(!IS_ONGROUND(this))
			sound(this, CH_VOICE, SND_MON_BREEZE_IDLE_AIR_RANDOM(), 1, ATTN_NORM);
		else
			sound(this, CH_VOICE, SND_MON_BREEZE_IDLE_RANDOM(), 1, ATTN_NORM);
	}
}

void breeze_stand(entity this) { set_anim(this, anim_breeze, breeze_stand); ai_stand(this); breeze_idlesound(this); }

void breeze_walk(entity this) { set_anim(this, anim_breeze, breeze_walk); ai_walk(this, 1); breeze_idlesound(this); }

void breeze_run(entity this) { set_anim(this, anim_breeze, breeze_run); ai_run(this, 2); breeze_idlesound(this); }

//===========================================================================

void breeze_gust_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	sound(this, CH_VOICE, SND_MON_BREEZE_EXPLODE_RANDOM(), 1, ATTN_NORM);
	Send_Effect(EFFECT_EXPLOSION_MEDIUM, this.origin, '0 0 0', 1);
	// NOTE: super high damage is reduced in the main function
	T_RadiusDamage(this, this, 500, DEATH_MONSTER_BREEZE.m_id, this);

	delete(this);
}

void breeze_gust_launch(entity this)
{
	vector offang = vectoangles(this.enemy.origin - this.origin);
	
	makevectors(offang);

	vector org = this.origin + this.mins + this.size*0.5 + v_forward * 20;

// set missile speed
	vector vec = normalize(v_forward);
	vec_z = 0 - vec_z +(random() - 0.5)*0.1;
	
	entity newmis = launch_spike(this, org, vec);
	newmis.projectiledeathtype = DEATH_MONSTER_BREEZE.m_id;
	newmis.classname = "knight_spike";
	newmis.scale = 2;
	newmis.avelocity = randomvec() * 30;
	newmis.modelflags |= MF_TRACER2;
	settouch(newmis, breeze_gust_touch);
	_setmodel(newmis, "progs/v_spike.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		
	newmis.velocity = vec*500;
	_sound(this, CH_WEAPON_SINGLE, "breeze/shoot.wav", 1, ATTN_NORM);
}

void breeze_shoot7(entity this) { set_anim(this, anim_breeze, breeze_run); ai_face(this); breeze_gust_launch(this); this.attack_finished = time + 5; }
void breeze_shoot6(entity this) { set_anim(this, anim_breeze, breeze_shoot7); ai_face(this); }
void breeze_shoot5(entity this) { set_anim(this, anim_breeze, breeze_shoot6); ai_face(this); }
void breeze_shoot4(entity this) { set_anim(this, anim_breeze, breeze_shoot5); ai_face(this); }
void breeze_shoot3(entity this) { set_anim(this, anim_breeze, breeze_shoot4); ai_face(this); }
void breeze_shoot2(entity this) { set_anim(this, anim_breeze, breeze_shoot3); ai_face(this); }
void breeze_shoot1(entity this) { set_anim(this, anim_breeze, breeze_shoot2); ai_face(this); }

void breeze_jump4(entity this) { set_anim(this, anim_breeze, breeze_run); }
void breeze_jump3(entity this)
{
	set_anim(this, anim_breeze, breeze_jump3);
	if(IS_ONGROUND(this))
		setthink(this, breeze_jump4);
}
void breeze_jump2(entity this)
{
	set_anim(this, anim_breeze, breeze_jump3);

	if(random() < 0.5)
		_sound(this, CH_VOICE, "breeze/jump1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "breeze/jump2.wav", 1, ATTN_NORM);

	fixedmakevectors(this.angles);
	this.velocity = v_forward * max(100, random() * 400) + v_up * max(200, random() * 600);
	UNSET_ONGROUND(this);
}

void breeze_jump1(entity this)
{
	set_anim(this, anim_breeze, breeze_jump2);
	if(random() < 0.5)
		_sound(this, CH_VOICE, "breeze/inhale1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "breeze/inhale2.wav", 1, ATTN_NORM);
	this.ideal_yaw = random() * 180;
	changeyaw(this);
	this.attack_finished = time + 2;
}

void breeze_shoot(entity this)
{
	if(random() < 0.5)
	{
		breeze_jump1(this);
		return;
	}

	sound(this, CH_WEAPON_SINGLE, SND_MON_BREEZE_CHARGE_RANDOM(), 1, ATTN_NORM);
	breeze_shoot1(this);
}

//===========================================================================

void breeze_pain6(entity this) { set_anim(this, anim_breeze, breeze_run); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void breeze_pain5(entity this) { set_anim(this, anim_breeze, breeze_pain6); }
void breeze_pain4(entity this) { set_anim(this, anim_breeze, breeze_pain5); this.colormod = '1 0.8 0.8'; }
void breeze_pain3(entity this) { set_anim(this, anim_breeze, breeze_pain4);}
void breeze_pain2(entity this) { set_anim(this, anim_breeze, breeze_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void breeze_pain1(entity this) { set_anim(this, anim_breeze, breeze_pain2); ai_pain(this, 6); }

void breeze_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	sound(this, CH_VOICE, SND_MON_BREEZE_PAIN_RANDOM(), 1, ATTN_NORM);

	this.pain_finished = time + 0.5;
	this.colormod = '1 0.9 0.9';

	breeze_pain1(this);
}

/*
=================
BreezeCheckAttack
=================
*/
bool BreezeCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
	if(!this.enemy_visible)
		return false;

	if(this.enemy_range == RANGE_FAR)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			breeze_run(this);
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
			breeze_run(this);
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
	
	return false;
}

//===========================================================================

void breeze_vanish(entity this)
{
	if(this.breeze_body)
		delete(this.breeze_body);

	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void breeze_die1(entity this)
{
	set_anim(this, anim_breeze, breeze_vanish);
	this.nextthink = time + 1;
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_TOSS);
	this.velocity_x = -200 + 400*random();
	this.velocity_y = -200 + 400*random();
	this.velocity_z = 100 + 100*random();
	UNSET_ONGROUND(this);
}

void breeze_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(random() < 0.5)
		_sound(this, CH_VOICE, "breeze/death1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "breeze/death2.wav", 1, ATTN_NORM);

	this.colormod = '1 0.6 0.6';
	breeze_die1(this);
}

void breeze_body_think(entity this)
{
	if(!this.owner || this.owner.breeze_body != this)
	{
		delete(this);
		return;
	}
	this.colormod = this.owner.colormod;
	this.nextthink = time;

	if(time >= this.delay)
	{
		this.cnt = (random() < 0.5) ? 1 : -1;
		this.delay = time + 3;
	}
	vector dir = '0 360 0' * this.cnt;
	this.angles = dir * fmod(time, 3.6);
}

void breeze_body_create(entity this)
{
	if(this.breeze_body)
		delete(this.breeze_body);

	entity body = spawn();
	body.classname = "breeze_body";
	body.owner = this;
	body.solid = SOLID_NOT; // main monster handles hitbox
	setmodel(body, MDL_MON_BREEZE_BODY);
	setsize(body, '0 0 0', '0 0 0');
	set_movetype(body, MOVETYPE_NONE);
	setattachment(body, this, "");
	setthink(body, breeze_body_think);
	body.nextthink = time;
	body.cnt = 1;

	this.breeze_body = body;
}

void breeze_touch(entity this, entity toucher)
{
	if(this.health <= 0 || (!this.takedamage))
		return;
	if(!Damage_ValidTarget(toucher, this))
		return;

	if(toucher.takedamage && toucher.pain_finished < time)
	{
		float ldmg = 10*random();
		T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_BREEZE.m_id);	
	}
}

/*QUAKED monster_breeze (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_breeze) { monster_start(this, true, MON_BREEZE); }
#endif // SVQC

#ifdef SVQC
METHOD(Breeze, mr_setup, bool(Breeze this, entity actor))
{
    TC(Breeze, this);

	precache_sound("breeze/death1.wav");
	precache_sound("breeze/death2.wav");
	precache_sound("breeze/shoot.wav");
	precache_sound("breeze/jump1.wav");
	precache_sound("breeze/jump2.wav");
	precache_sound("breeze/inhale1.wav");
	precache_sound("breeze/inhale2.wav");

	precache_model("progs/v_spike.mdl");

	actor.yaw_speed = 180;

    actor.health = 200;
    actor.th_stand = breeze_stand;
	actor.th_walk = breeze_walk;
	actor.th_run = breeze_run;
	actor.th_pain = breeze_pain;
	actor.th_die = breeze_die;
	actor.th_missile = breeze_shoot;
	actor.checkattack = BreezeCheckAttack;

	settouch(actor, breeze_touch);

	breeze_body_create(actor);

    return true;
}
#endif
