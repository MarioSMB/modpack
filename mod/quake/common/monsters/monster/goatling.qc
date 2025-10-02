#include "goatling.qh"

#ifdef SVQC
const int anim_goatling_charge = 0;
const int anim_goatling_walk = 6;
const int anim_goatling_idle = 17;
const int anim_goatling_pain = 35;
const int anim_goatling_death = 50;

void goatling_idle_sound(entity this)
{
	if(random() < 0.05)
	{
		switch(floor(random() * 6))
		{
			case 0: _sound(this, CH_VOICE, "goatling/idle1.wav", 1, ATTN_NORM); break;
			case 1: _sound(this, CH_VOICE, "goatling/idle2.wav", 1, ATTN_NORM); break;
			case 2: _sound(this, CH_VOICE, "goatling/idle3.wav", 1, ATTN_NORM); break;
			case 3: _sound(this, CH_VOICE, "goatling/idle4.wav", 1, ATTN_NORM); break;
			case 4: _sound(this, CH_VOICE, "goatling/idle5.wav", 1, ATTN_NORM); break;
			case 5: _sound(this, CH_VOICE, "goatling/idle6.wav", 1, ATTN_NORM); break;
		}
	}
}

void goatling_idle1(entity this);
void goatling_idle12(entity this) { set_animofs(this, anim_goatling_idle, 12, goatling_idle1); ai_stand(this); }
void goatling_idle11(entity this) { set_animofs(this, anim_goatling_idle, 11, goatling_idle12); ai_stand(this); }
void goatling_idle10(entity this) { set_animofs(this, anim_goatling_idle, 10, goatling_idle11); ai_stand(this); }
void goatling_idle9(entity this) { set_animofs(this, anim_goatling_idle, 9, goatling_idle10); ai_stand(this); }
void goatling_idle8(entity this) { set_animofs(this, anim_goatling_idle, 8, goatling_idle9); ai_stand(this); }
void goatling_idle7(entity this) { set_animofs(this, anim_goatling_idle, 7, goatling_idle8); ai_stand(this); }
void goatling_idle6(entity this) { set_animofs(this, anim_goatling_idle, 6, goatling_idle7); ai_stand(this); }
void goatling_idle5(entity this) { set_animofs(this, anim_goatling_idle, 5, goatling_idle6); ai_stand(this); }
void goatling_idle4(entity this) { set_animofs(this, anim_goatling_idle, 4, goatling_idle5); ai_stand(this); }
void goatling_idle3(entity this) { set_animofs(this, anim_goatling_idle, 3, goatling_idle4); ai_stand(this); }
void goatling_idle2(entity this) { set_animofs(this, anim_goatling_idle, 2, goatling_idle3); ai_stand(this); }
void goatling_idle1(entity this) { set_animofs(this, anim_goatling_idle, 1, goatling_idle2); goatling_idle_sound(this); ai_stand(this); }

void goatling_walk1(entity this);
void goatling_walk6(entity this) { set_animofs(this, anim_goatling_walk, 6, goatling_walk1); ai_walk(this, 4); }
void goatling_walk5(entity this) { set_animofs(this, anim_goatling_walk, 5, goatling_walk6); ai_walk(this, 5); }
void goatling_walk4(entity this) { set_animofs(this, anim_goatling_walk, 4, goatling_walk5); ai_walk(this, 5); }
void goatling_walk3(entity this) { set_animofs(this, anim_goatling_walk, 3, goatling_walk4); ai_walk(this, 4); }
void goatling_walk2(entity this) { set_animofs(this, anim_goatling_walk, 2, goatling_walk3); ai_walk(this, 3); }
void goatling_walk1(entity this) { set_animofs(this, anim_goatling_walk, 1, goatling_walk2); goatling_idle_sound(this); ai_walk(this, 4); }

void goatling_charge1(entity this);
void goatling_run1(entity this);
void goatling_die(entity this, entity inflictor, entity attacker, int deathtype);
void goatling_diethink(entity this)
{
	Killed(this, NULL, NULL, DEATH_CRUSH.m_id);
}

void Goatling_ChargeTouch(entity this, entity toucher)
{
	if(this.health <= 0)
	{
		goatling_diethink(this);
		return;
	}
	if(toucher.takedamage)
	{
		float ldmg = 20;
		T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_GOATLING.m_id);	
		setthink(this, goatling_diethink);
		this.nextthink = time + 0.1;
		return;
	}
}

void goatling_charge6(entity this) { set_animofs(this, anim_goatling_charge, 6, goatling_run1); ai_charge(this, 15); }
void goatling_charge5(entity this) { set_animofs(this, anim_goatling_charge, 5, goatling_charge6); ai_charge(this, 22); }
void goatling_charge4(entity this) { set_animofs(this, anim_goatling_charge, 4, goatling_charge5); ai_charge(this, 22); }
void goatling_charge3(entity this) { set_animofs(this, anim_goatling_charge, 3, goatling_charge4); ai_charge(this, 20); }
void goatling_charge2(entity this)
{
	set_animofs(this, anim_goatling_charge, 2, goatling_charge3);
	ai_face(this);
	
	settouch(this, Goatling_ChargeTouch);
	makevectors(this.angles);
	this.origin_z += 1;
	this.velocity = v_forward * 300;
	if(random() < 0.2)
		this.velocity_z = random() * 600;
	UNSET_ONGROUND(this);
}
void goatling_charge1(entity this) { set_animofs(this, anim_goatling_charge, 1, goatling_charge2); goatling_idle_sound(this); }

void goatling_run6(entity this) { set_animofs(this, anim_goatling_walk, 6, goatling_run1); ai_run(this, 6); }
void goatling_run5(entity this) { set_animofs(this, anim_goatling_walk, 5, goatling_run6); ai_run(this, 8); }
void goatling_run4(entity this) { set_animofs(this, anim_goatling_walk, 4, goatling_run5); ai_run(this, 10); }
void goatling_run3(entity this) { set_animofs(this, anim_goatling_walk, 3, goatling_run4); ai_run(this, 8); }
void goatling_run2(entity this) { set_animofs(this, anim_goatling_walk, 2, goatling_run3); ai_run(this, 6); }
void goatling_run1(entity this) { set_animofs(this, anim_goatling_walk, 1, goatling_run2); goatling_idle_sound(this); ai_face(this); }

void goatling_slide5(entity this) { set_animofs(this, anim_goatling_walk, 6, goatling_run1); ai_run(this, 4); }
void goatling_slide6(entity this) { set_animofs(this, anim_goatling_walk, 5, goatling_slide6); ai_run_slide(this, 4); }
void goatling_slide4(entity this) { set_animofs(this, anim_goatling_walk, 4, goatling_slide5); ai_run_slide(this, 4); }
void goatling_slide3(entity this) { set_animofs(this, anim_goatling_walk, 3, goatling_slide4); ai_run_slide(this, 4); }
void goatling_slide2(entity this) { set_animofs(this, anim_goatling_walk, 2, goatling_slide3); ai_run_slide(this, 4); }
void goatling_slide1(entity this) { set_animofs(this, anim_goatling_walk, 1, goatling_slide2); ai_run_slide(this, 4); goatling_idle_sound(this); }

void goatling_pain2(entity this) { set_animofs(this, anim_goatling_pain, 2, goatling_run1); }
void goatling_pain1(entity this) { set_animofs(this, anim_goatling_pain, 1, goatling_pain2); }

void goatling_pain(entity this, entity attacker, float damage, int deathtype)
{
	//if(time < this.pain_finished)
		//return;
	// Any pain animation/sound required?
	_sound(this, CH_VOICE, "goatling/pain.wav", 1, ATTN_NORM);
	this.pain_finished = time + 1;

	goatling_pain1(this);
}

void goatling_die6(entity this) { set_animofs(this, anim_goatling_death, 6, goatling_die6); this.health = 0; delete(this); }
void goatling_die5(entity this) { set_animofs(this, anim_goatling_death, 5, goatling_die6); }
void goatling_die4(entity this) { set_animofs(this, anim_goatling_death, 4, goatling_die5); }
void goatling_die3(entity this) { set_animofs(this, anim_goatling_death, 3, goatling_die4); }
void goatling_die2(entity this) { set_animofs(this, anim_goatling_death, 2, goatling_die3); }
void goatling_die1(entity this) { set_animofs(this, anim_goatling_death, 1, goatling_die2); this.solid = SOLID_NOT; }

void goatling_dieB7(entity this) { set_animofs(this, anim_goatling_death, 7, goatling_dieB7); this.health = 0; delete(this); }
void goatling_dieB6(entity this) { set_animofs(this, anim_goatling_death, 6, goatling_dieB7); }
void goatling_dieB5(entity this) { set_animofs(this, anim_goatling_death, 5, goatling_dieB6); }
void goatling_dieB4(entity this) { set_animofs(this, anim_goatling_death, 4, goatling_dieB5); }
void goatling_dieB3(entity this) { set_animofs(this, anim_goatling_death, 3, goatling_dieB4); }
void goatling_dieB2(entity this) { set_animofs(this, anim_goatling_death, 2, goatling_dieB3); }
void goatling_dieB1(entity this) { set_animofs(this, anim_goatling_death, 1, goatling_dieB2); this.solid = SOLID_NOT; }

void goatling_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	settouch(this, func_null);
	if(random() > 0.5)
		_sound(this, CH_VOICE, "goatling/death1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "goatling/death2.wav", 1, ATTN_NORM);
	if(random() < 0.6) 
		goatling_die1(this);
	else 
		goatling_dieB1(this);
}

/*======================================================================
QUAKED monster_goatling (1 0 0) (-16 -16 -24) (16 16 24) Ambush
======================================================================*/
spawnfunc(monster_goatling) { monster_start(this, true, MON_GOATLING); }
#endif // SVQC

#ifdef SVQC
METHOD(Goatling, mr_setup, bool(Goatling this, entity actor))
{
    TC(Goatling, this);

	precache_sound("goatling/death1.wav");
	precache_sound("goatling/death2.wav");
	precache_sound("goatling/pain.wav");
	precache_sound("goatling/idle1.wav");
	precache_sound("goatling/idle2.wav");
	precache_sound("goatling/idle3.wav");
	precache_sound("goatling/idle4.wav");
	precache_sound("goatling/idle5.wav");
	precache_sound("goatling/idle6.wav");

	actor.scale = 0.5; // TODO: fix model!

    actor.health = 15;
    actor.th_pain = goatling_pain;
	actor.th_die = goatling_die;
	actor.th_stand = goatling_idle1;
	actor.th_walk = goatling_walk1;
	actor.th_run = goatling_run1;
	actor.th_missile = goatling_charge1;

    return true;
}
#endif
