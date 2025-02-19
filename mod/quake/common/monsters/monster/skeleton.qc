#include "skeleton.qh"

#ifdef SVQC
const int anim_skeleton_shoot = 42;
const int anim_skeleton_stand = 0;
const int anim_skeleton_run = 1;
const int anim_skeleton_walk = 1;
const int anim_skeleton_attack = 0;

const int SKELETON_STRAY = BIT(1);
const int SKELETON_BOGGED = BIT(2);

.float idle_finished;

void skeleton_idlesound(entity this)
{
	if(time < this.pain_finished)
		return;

	if(random() < 0.2 && time >= this.idle_finished)
	{
		this.idle_finished = time + 2 + (random() * 2);
		if(this.skin == 1)
			sound(this, CH_VOICE, SND_MON_STRAY_IDLE_RANDOM(), 1, ATTN_NORM);
		else if(this.skin == 2)
			sound(this, CH_VOICE, SND_MON_BOGGED_IDLE_RANDOM(), 1, ATTN_NORM);
		else
			sound(this, CH_VOICE, SND_MON_SKELETON_IDLE_RANDOM(), 1, ATTN_NORM);
	}
}

void skeleton_stand(entity this)
{
	this.walkframe = anim_skeleton_stand;

	skeleton_idlesound(this);
	set_anim(this, this.walkframe, skeleton_stand);

	ai_stand(this);
}

void skeleton_moveframe(entity this, int startframe, int endframe)
{
	this.walkframe += 1;
	if(this.walkframe < startframe || this.walkframe > endframe)
		this.walkframe = startframe;

	if(time >= this.footstep && IS_ONGROUND(this))
	{
		this.footstep = time + 0.6 + random();
		if(this.skin == 1)
			sound(this, CH_VOICE, SND_MON_STRAY_STEP_RANDOM(), 1, ATTN_NORM);
		else if(this.skin == 2)
			sound(this, CH_VOICE, SND_MON_BOGGED_STEP_RANDOM(), 1, ATTN_NORM);
		else
			sound(this, CH_VOICE, SND_MON_SKELETON_STEP_RANDOM(), 1, ATTN_NORM);
	}

	skeleton_idlesound(this);
}

void skeleton_walk(entity this)
{
	skeleton_moveframe(this, anim_skeleton_walk, 22);
	set_anim(this, this.walkframe, skeleton_walk);

	ai_walk(this, 6);
}

.float skeleton_movetime;
void skeleton_run(entity this)
{
	skeleton_moveframe(this, anim_skeleton_run, 22);
	set_anim(this, this.walkframe, skeleton_run);

	if(time >= this.attack_finished && time >= this.skeleton_movetime)
	{
		this.skeleton_movetime = time + 1 + random();
		if(random() < 0.25)
			this.attack_state = AS_DODGING;
		else
			this.attack_state = AS_SLIDING;
	}
	ai_run(this, 8);
}

void skeleton_arrow_stick(entity this, entity toucher)
{
	if(toucher)
	{
		delete(this);
		return;
	}

	settouch(this, func_null);
	set_movetype(this, MOVETYPE_NONE);
	SUB_SetFade(this, time + 3, 1);
}

void skeleton_arrow_touch(entity this, entity toucher)
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
	
// hit something that bleeds
	if(toucher.takedamage) // yoder mod, jan 05 2021
	{
		float damg = ((this.dmg) ? this.dmg : 20);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);

		if(this.cnt == 1) // stray
		{
			float efftime = 7;
			float curtime = StatusEffects_gettime(STATUSEFFECT_Slowness, toucher);
			if((time + efftime) > curtime)
				StatusEffects_apply(STATUSEFFECT_Slowness, toucher, time + efftime, 0);
		}
		else if(this.cnt == 2) // bogged
		{
			float efftime = 7;
			float curtime = StatusEffects_gettime(STATUSEFFECT_Poisoned, toucher);
			if((time + efftime) > curtime)
				StatusEffects_apply(STATUSEFFECT_Poisoned, toucher, time + efftime, 0);
		}
	}

	sound(this, CH_TRIGGER_SINGLE, SND_MON_SKELETON_ARROWHIT_RANDOM(), 1, ATTN_NORM);

	skeleton_arrow_stick(this, toucher);
}

void skeleton_arrow_launch(entity this)
{
	vector offang = vectoangles(this.enemy.origin - this.origin);
	
	makevectors(offang);

	vector org = this.origin + this.mins + this.size*0.5 + v_forward * 20;

// set missile speed
	vector vec = normalize(v_forward);
	vec_z = 0 - vec_z +(random() - 0.5)*0.1;
	
	entity newmis = launch_spike(this, org, vec);
	newmis.projectiledeathtype = DEATH_MONSTER_SKELETON.m_id;
	set_movetype(newmis, MOVETYPE_TOSS);
	newmis.classname = "knight_spike";
	newmis.scale = 0.6;
	newmis.dmg = 20;
	newmis.cnt = this.skin; // save it for use incase we lose owner
	settouch(newmis, skeleton_arrow_touch);
	_setmodel(newmis, "progs/mcarrow.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		
	newmis.velocity = vec * 1500 + v_up * 64;
	_sound(this, CH_WEAPON_SINGLE, "skeleton/bow.wav", 1, ATTN_NORM);
}

void skeleton_shoot7(entity this) { set_animofs(this, anim_skeleton_shoot, 7, skeleton_run); ai_face(this); this.attack_finished = time + 2; }
void skeleton_shoot6(entity this) { set_animofs(this, anim_skeleton_shoot, 6, skeleton_shoot7); ai_face(this); }
void skeleton_shoot5(entity this) { set_animofs(this, anim_skeleton_shoot, 5, skeleton_shoot6); ai_face(this); }
void skeleton_shoot4(entity this) { set_animofs(this, anim_skeleton_shoot, 4, skeleton_shoot5); ai_face(this); }
void skeleton_shoot3(entity this) { set_animofs(this, anim_skeleton_shoot, 3, skeleton_shoot4); ai_face(this); }
void skeleton_shoot2(entity this) { set_animofs(this, anim_skeleton_shoot, 2, skeleton_shoot3); ai_face(this); }
void skeleton_shoot1(entity this) { set_animofs(this, anim_skeleton_shoot, 1, skeleton_shoot2); ai_face(this); skeleton_arrow_launch(this); }

void skeleton_shoot(entity this)
{
	skeleton_shoot1(this);
}

void skeleton_melee(entity this)
{
	set_anim(this, anim_skeleton_attack, skeleton_run);
	this.nextthink = time + 0.5;
	ai_face(this);
	ai_melee(this, DEATH_MONSTER_SKELETON.m_id, 100, false);
	this.attack_finished = time + 0.5;
}

//===========================================================================

void skeleton_pain6(entity this) { set_anim(this, anim_skeleton_stand, skeleton_run); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void skeleton_pain5(entity this) { set_anim(this, anim_skeleton_stand, skeleton_pain6); }
void skeleton_pain4(entity this) { set_anim(this, anim_skeleton_stand, skeleton_pain5); this.colormod = '1 0.8 0.8'; }
void skeleton_pain3(entity this) { set_anim(this, anim_skeleton_stand, skeleton_pain4);}
void skeleton_pain2(entity this) { set_anim(this, anim_skeleton_stand, skeleton_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void skeleton_pain1(entity this) { set_anim(this, anim_skeleton_stand, skeleton_pain2); ai_pain(this, 6); }

void skeleton_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	if(this.skin == 1)
		sound(this, CH_VOICE, SND_MON_STRAY_PAIN_RANDOM(), 1, ATTN_NORM);
	else if(this.skin == 2)
		sound(this, CH_VOICE, SND_MON_BOGGED_PAIN_RANDOM(), 1, ATTN_NORM);
	else
		sound(this, CH_VOICE, SND_MON_SKELETON_PAIN_RANDOM(), 1, ATTN_NORM);

	this.pain_finished = time + 1;
	this.colormod = '1 0.9 0.9';

	skeleton_pain1(this);
}

//===========================================================================

void skeleton_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void skeleton_die7(entity this) { set_anim(this, anim_skeleton_stand, skeleton_vanish); this.nextthink = time + 0.7; this.angles_z = 90; }
void skeleton_die6(entity this) { set_anim(this, anim_skeleton_stand, skeleton_die7); this.angles_z = 90; }
void skeleton_die5(entity this) { set_anim(this, anim_skeleton_stand, skeleton_die6); this.angles_z = 75; }
void skeleton_die4(entity this) { set_anim(this, anim_skeleton_stand, skeleton_die5); this.angles_z = 60; }
void skeleton_die3(entity this) { set_anim(this, anim_skeleton_stand, skeleton_die4); this.angles_z = 45; }
void skeleton_die2(entity this) { set_anim(this, anim_skeleton_stand, skeleton_die3); this.angles_z = 30; }
void skeleton_die1(entity this) { set_anim(this, anim_skeleton_stand, skeleton_die2); this.solid = SOLID_NOT; this.angles_z = 15; }

void skeleton_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.skin == 1)
	{
		if(random() < 0.5)
			_sound(this, CH_VOICE, "stray/death1.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "stray/death2.wav", 1, ATTN_NORM);
	}
	else if(this.skin == 2)
		_sound(this, CH_VOICE, "bogged/death.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "skeleton/death.wav", 1, ATTN_NORM);

	this.colormod = '1 0.6 0.6';
	this.angles_z = 0;
	skeleton_die1(this);
}

/*QUAKED monster_skeleton (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_skeleton) { monster_start(this, true, MON_SKELETON); }
#endif // SVQC

#ifdef SVQC
METHOD(Skeleton, mr_setup, bool(Skeleton this, entity actor))
{
    TC(Skeleton, this);

	precache_model("progs/mcarrow.mdl");
	precache_sound("skeleton/death.wav");
	precache_sound("skeleton/bow.wav");

	float r = random();
	if(r < 0.33)
		actor.spawnflags |= SKELETON_STRAY;
	else if(r < 0.66)
		actor.spawnflags |= SKELETON_BOGGED;
	// otherwise normal

	actor.yaw_speed = 180;
		actor.skin = 0;

	if(actor.spawnflags & SKELETON_STRAY)
	{
		precache_sound("stray/death1.wav");
		precache_sound("stray/death2.wav");
		actor.skin = 1;
	}
	else if(actor.spawnflags & SKELETON_BOGGED)
	{
		precache_sound("bogged/death.wav");
		actor.skin = 2;
	}

    actor.health = 100;
    actor.th_stand = skeleton_stand;
	actor.th_walk = skeleton_walk;
	actor.th_run = skeleton_run;
	actor.th_pain = skeleton_pain;
	actor.th_die = skeleton_die;
	actor.th_melee = skeleton_melee;
	actor.th_missile = skeleton_shoot;

    return true;
}
#endif
