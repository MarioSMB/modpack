#include "kangaroo.qh"

#ifdef SVQC

void roo_stand1(entity this);
void roo_run1(entity this);
void roo_stand(entity this);
void roo_run(entity this, float dist);

float MoveToAngle(float s_angle, float e_angle, float rate)
{
	float result = 0;
	if(s_angle > e_angle && s_angle - e_angle > 180)
		e_angle += 360;
	else if(e_angle > s_angle && e_angle - s_angle > 180)
		s_angle += 360;
	if(s_angle > e_angle)
	{
		result = s_angle - rate * frametime;
		if(result < e_angle)
			result = e_angle;
	}
	else
	{
		result = s_angle + rate * frametime;
		if(result > e_angle)
			result = e_angle;
	}
	if(result >= 360)
		result -= 360;
	if(result < 0)
		result += 360;
	return result;
}

void roo_stand5(entity this) { set_anim(this, 5, roo_stand1); }
void roo_stand4(entity this) { set_anim(this, 4, roo_stand5); }
void roo_stand3(entity this) { set_anim(this, 3, roo_stand4); }
void roo_stand2(entity this) { set_anim(this, 2, roo_stand3); }
void roo_stand1(entity this) { set_anim(this, 1, roo_stand2); roo_stand(this); }

void roo_run10(entity this)
{
	set_anim(this, 14, roo_run1);
	roo_run(this, 16);
	if(vdist(this.enemy.origin - this.origin, <, 128))
		this.angles_y = MoveToAngle(this.angles_y, this.angles_y + ((random() < 0.5) * 2 - 1) * 40, 1000);
	else
		this.angles_y = MoveToAngle(this.angles_y, this.angles_y + random() * 40 - 20, 1000);
	if(vdist(this.origin - this.enemy.origin, >, 384))
		setthink(this, roo_stand1);
}
void roo_run9(entity this) { set_anim(this, 13, roo_run10); roo_run(this, 18); }
void roo_run8(entity this) { set_anim(this, 12, roo_run9); roo_run(this, 22); }
void roo_run7(entity this) { set_anim(this, 12, roo_run8); roo_run(this, 26); }
void roo_run6(entity this) { set_anim(this, 11, roo_run7); roo_run(this, 26); }
void roo_run5(entity this) { set_anim(this, 10, roo_run6); roo_run(this, 24); }
void roo_run4(entity this) { set_anim(this, 9, roo_run5); roo_run(this, 20); }
void roo_run3(entity this) { set_anim(this, 8, roo_run4); roo_run(this, 18); }
void roo_run2(entity this) { set_anim(this, 7, roo_run3); roo_run(this, 16); }
void roo_run1(entity this) { set_anim(this, 6, roo_run2); roo_run(this, 12); }

void roo_stand(entity this)
{
	entity trav = findradius(this.origin, 1024);
	while(trav)
	{
		if(trav.classname == "player")
		{
			this.enemy = trav;
			setthink(this, this.th_run);
			return;
		}
		trav = trav.chain;
	}
	if(random() * 10 >= 7)
	{
		if((this.enemy = find(NULL, classname, "player")))
		{
			this.enemy = trav;
			setthink(this, this.th_run);
			return;
		}
	}
}

void roo_pain(entity this, entity attacker, float damage, int deathtype)
{
	SpawnBlood(this.origin, '0 0 -5', 100, this);
	roo_stand1(this);
}

void roo_run(entity this, float dist)
{
	//droptofloor(this);
	if(this.enemy)
		ai_run(this, dist);
	else
		ai_walk(this, dist);
#if 0
	// add some randomness to their movement
	if(random() < 0.05)
	{
		this.angles_y = this.angles_y + ((random() > 0.5) * 2 - 1) * 135;
		this.angles_y = ANGLEMOD(this.angles_y);
		setthink(this, this.th_run);
		return;
	}
#endif
	this.nextthink = time + 0.05;
}

void roo_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
	ThrowHead(this, "progs/gib1.mdl", this.health);
	ThrowGib(this, "progs/gib1.mdl", this.health);
	ThrowGib(this, "progs/gib1.mdl", this.health);
	ThrowGib(this, "progs/gib2.mdl", this.health);
	ThrowGib(this, "progs/gib3.mdl", this.health);
	ThrowGib(this, "progs/gib3.mdl", this.health);
}

void roo_touch(entity this, entity toucher)
{
	if(this.health <= 0 || (!this.takedamage))
		return;
	if(this.charmed && (IS_PLAYER(toucher) || toucher == this.charmer || toucher.charmer == this.charmer))
		return;

	if(toucher.takedamage && this.attack_finished < time && toucher.pain_finished < time)
	{
		float ldmg = 40 + 10*random();
		T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_KANGAROO.m_id);
		this.attack_finished = time + 1;	
	}
}

spawnfunc(monster_kangaroo) { monster_start(this, true, MON_KANGAROO); }
#endif // SVQC

#ifdef SVQC
METHOD(Kangaroo, mr_setup, bool(Kangaroo this, entity actor))
{
    TC(Kangaroo, this);

	actor.health = 120;
	actor.th_stand = roo_stand1;
	actor.th_walk = roo_stand1;
	actor.th_run = roo_run1;
	actor.th_die = roo_die;
	actor.th_pain = roo_pain;

	actor.scale = 2;
	setsize(actor, this.m_mins * actor.scale, this.m_maxs * actor.scale);
	settouch(actor, roo_touch);

    return true;
}
#endif
