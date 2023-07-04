#include "voreling.qh"

#ifdef SVQC
const int anim_voreling_idle = 0; //'0 12 0'
const int anim_voreling_idleup = 13; //'13 18 0'
const int anim_voreling_drop = 19; //'19 23 0'
const int anim_voreling_grow = 24; //'24 33 0'
const int anim_voreling_walk = 34; //'34 38 0'
const int anim_voreling_run = 39; //'39 42 0'
const int anim_voreling_jump = 43; //'43 48 0'
const int anim_voreling_bite = 49; //'49 55 0'
const int anim_voreling_pain = 56; //'56 57 0'
const int anim_voreling_death = 58; //'58 63 0'
const int anim_voreling_deathB = 64; //'64 70 0'
//const int anim_voreling_base = 71; //'71 72 0'

void voreling_idle_sound(entity this)
{
	if(random() < 0.05)
		_sound(this, CH_VOICE, "voreling/idle.wav", 1, ATTN_NORM);
}

void voreling_idle1(entity this);
void voreling_idle13(entity this) { set_animofs(this, anim_voreling_idle, 13, voreling_idle1); ai_stand(this); }
void voreling_idle12(entity this) { set_animofs(this, anim_voreling_idle, 12, voreling_idle13); ai_stand(this); }
void voreling_idle11(entity this) { set_animofs(this, anim_voreling_idle, 11, voreling_idle12); ai_stand(this); }
void voreling_idle10(entity this) { set_animofs(this, anim_voreling_idle, 10, voreling_idle11); ai_stand(this); }
void voreling_idle9(entity this) { set_animofs(this, anim_voreling_idle, 9, voreling_idle10); ai_stand(this); }
void voreling_idle8(entity this) { set_animofs(this, anim_voreling_idle, 8, voreling_idle9); ai_stand(this); }
void voreling_idle7(entity this) { set_animofs(this, anim_voreling_idle, 7, voreling_idle8); ai_stand(this); }
void voreling_idle6(entity this) { set_animofs(this, anim_voreling_idle, 6, voreling_idle7); ai_stand(this); }
void voreling_idle5(entity this) { set_animofs(this, anim_voreling_idle, 5, voreling_idle6); ai_stand(this); }
void voreling_idle4(entity this) { set_animofs(this, anim_voreling_idle, 4, voreling_idle5); ai_stand(this); }
void voreling_idle3(entity this) { set_animofs(this, anim_voreling_idle, 3, voreling_idle4); ai_stand(this); }
void voreling_idle2(entity this) { set_animofs(this, anim_voreling_idle, 2, voreling_idle3); ai_stand(this); }
void voreling_idle1(entity this) { set_animofs(this, anim_voreling_idle, 1, voreling_idle2); voreling_idle_sound(this); ai_stand(this); }

void voreling_walk1(entity this);
void voreling_walk5(entity this) { set_animofs(this, anim_voreling_walk, 5, voreling_walk1); ai_walk(this, 5); }
void voreling_walk4(entity this) { set_animofs(this, anim_voreling_walk, 4, voreling_walk5); ai_walk(this, 5); }
void voreling_walk3(entity this) { set_animofs(this, anim_voreling_walk, 3, voreling_walk4); ai_walk(this, 4); }
void voreling_walk2(entity this) { set_animofs(this, anim_voreling_walk, 2, voreling_walk3); ai_walk(this, 3); }
void voreling_walk1(entity this) { set_animofs(this, anim_voreling_walk, 1, voreling_walk2); voreling_idle_sound(this); ai_walk(this, 4); }

void voreling_jump1(entity this);
void voreling_run1(entity this);
void voreling_die(entity this, entity inflictor, entity attacker, int deathtype);
void voreling_diethink(entity this)
{
	voreling_die(this, NULL, NULL, DEATH_CRUSH.m_id);
}

void Voreling_JumpTouch(entity this, entity toucher)
{
	if(this.health <= 0)
	{
		voreling_die(this, NULL, NULL, DEATH_CRUSH.m_id);
		return;
	}
	if(toucher.takedamage)
	{
		if(vdist(this.velocity, >, 300))
		{
			float ldmg = 20;
			T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_VORELING.m_id);	
			setthink(this, voreling_diethink);
			this.nextthink = time + 0.1;
			return;
		}
	}

	if(!t_checkbottom(this))
	{
		if(IS_ONGROUND(this))
		{	// jump randomly to not get hung up
			settouch(this, func_null);
			setthink(this, voreling_jump1);
			this.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}

	settouch(this, func_null);
	setthink(this, voreling_run1);
	this.nextthink = time + 0.1;
}

void voreling_jump6(entity this) { set_animofs(this, anim_voreling_jump, 6, voreling_run1); }
void voreling_jump5(entity this) { set_animofs(this, anim_voreling_jump, 5, voreling_jump6); }
void voreling_jump4(entity this) { set_animofs(this, anim_voreling_jump, 4, voreling_jump5); }
void voreling_jump3(entity this) { set_animofs(this, anim_voreling_jump, 3, voreling_jump4); }
void voreling_jump2(entity this)
{
	set_animofs(this, anim_voreling_jump, 2, voreling_jump3);
	ai_face(this);
	
	settouch(this, Voreling_JumpTouch);
	makevectors(this.angles);
	this.origin_z += 1;
	this.velocity = v_forward * 300 + '0 0 200';
	UNSET_ONGROUND(this);
}
void voreling_jump1(entity this) { set_animofs(this, anim_voreling_jump, 1, voreling_jump2); voreling_idle_sound(this); }

void voreling_run8(entity this) { set_animofs(this, anim_voreling_run, 4, voreling_run1); ai_run(this, 10); }
void voreling_run7(entity this) { set_animofs(this, anim_voreling_run, 3, voreling_run8); ai_run(this, 8); }
void voreling_run6(entity this) { set_animofs(this, anim_voreling_run, 2, voreling_run7); ai_run(this, 6); }
void voreling_run5(entity this) { set_animofs(this, anim_voreling_run, 1, voreling_run6); ai_run(this, 8); }
void voreling_run4(entity this) { set_animofs(this, anim_voreling_run, 4, voreling_run5); ai_run(this, 10); }
void voreling_run3(entity this) { set_animofs(this, anim_voreling_run, 3, voreling_run4); ai_run(this, 8); }
void voreling_run2(entity this) { set_animofs(this, anim_voreling_run, 2, voreling_run3); ai_run(this, 6); }
void voreling_run1(entity this) { set_animofs(this, anim_voreling_run, 1, voreling_run2); voreling_idle_sound(this); ai_face(this); }

void voreling_slide5(entity this) { set_animofs(this, anim_voreling_walk, 5, voreling_run1); ai_run(this, 4); }
void voreling_slide4(entity this) { set_animofs(this, anim_voreling_walk, 4, voreling_slide5); ai_run_slide(this, 4); }
void voreling_slide3(entity this) { set_animofs(this, anim_voreling_walk, 3, voreling_slide4); ai_run_slide(this, 4); }
void voreling_slide2(entity this) { set_animofs(this, anim_voreling_walk, 2, voreling_slide3); ai_run_slide(this, 4); }
void voreling_slide1(entity this) { set_animofs(this, anim_voreling_walk, 1, voreling_slide2); ai_run_slide(this, 4); voreling_idle_sound(this); }

void voreling_pain2(entity this) { set_animofs(this, anim_voreling_pain, 2, voreling_run1); }
void voreling_pain1(entity this) { set_animofs(this, anim_voreling_pain, 1, voreling_pain2); }

void voreling_pain(entity this, entity attacker, float damage, int deathtype)
{
	//if(time < this.pain_finished)
		//return;
	// Any pain animation/sound required?
	_sound(this, CH_VOICE, "voreling/pain.wav", 1, ATTN_NORM);
	this.pain_finished = time + 1;

	voreling_pain1(this);
}

void voreling_die6(entity this) { set_animofs(this, anim_voreling_death, 6, voreling_die6); this.health = 0; delete(this);}
void voreling_die5(entity this) { set_animofs(this, anim_voreling_death, 5, voreling_die6); }
void voreling_die4(entity this) { set_animofs(this, anim_voreling_death, 4, voreling_die5); }
void voreling_die3(entity this) { set_animofs(this, anim_voreling_death, 3, voreling_die4); }
void voreling_die2(entity this) { set_animofs(this, anim_voreling_death, 2, voreling_die3); }
void voreling_die1(entity this) { set_animofs(this, anim_voreling_death, 1, voreling_die2); this.solid = SOLID_NOT; }

void voreling_dieB7(entity this) { set_animofs(this, anim_voreling_deathB, 7, voreling_dieB7); this.health = 0; delete(this); }
void voreling_dieB6(entity this) { set_animofs(this, anim_voreling_deathB, 6, voreling_dieB7); }
void voreling_dieB5(entity this) { set_animofs(this, anim_voreling_deathB, 5, voreling_dieB6); }
void voreling_dieB4(entity this) { set_animofs(this, anim_voreling_deathB, 4, voreling_dieB5); }
void voreling_dieB3(entity this) { set_animofs(this, anim_voreling_deathB, 3, voreling_dieB4); }
void voreling_dieB2(entity this) { set_animofs(this, anim_voreling_deathB, 2, voreling_dieB3); }
void voreling_dieB1(entity this) { set_animofs(this, anim_voreling_deathB, 1, voreling_dieB2); this.solid = SOLID_NOT; }

void voreling_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	settouch(this, func_null);
	_sound(this, CH_VOICE, "voreling/death.wav", 1, ATTN_NORM);
	if(random() < 0.6) 
		voreling_die1(this);
	else 
		voreling_dieB1(this);
}

/*======================================================================
QUAKED monster_voreling (1 0 0) (-16 -16 -24) (16 16 24) Ambush
======================================================================*/
spawnfunc(monster_voreling) { monster_start(this, true, MON_VORELING); }
#endif // SVQC

#ifdef SVQC
METHOD(Voreling, mr_setup, bool(Voreling this, entity actor))
{
    TC(Voreling, this);

	precache_sound("voreling/death.wav");
	precache_sound("voreling/pain.wav");
	precache_sound("voreling/idle.wav");

    actor.health = 10;
    actor.th_pain = voreling_pain;
	actor.th_die = voreling_die;
	actor.th_stand = voreling_idle1;
	actor.th_walk = voreling_walk1;
	actor.th_run = voreling_run1;
	actor.th_missile = voreling_jump1;

    return true;
}
#endif
