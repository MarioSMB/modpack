#include "mcslime.qh"

#ifdef SVQC
const int anim_slime = 0; // no actual animations!

.int slime_size; // NOTE: larger = smaller, silly maths

void mcslime_hop(entity this, float dist, float distz)
{
	fixedmakevectors(this.angles);
	vector dir = v_forward * dist + v_up * distz;

	UNSET_ONGROUND(this);
	this.velocity = dir;

	if(this.slime_size >= 3)
	{
		float r = random();
		if(r < 0.2)
			_sound(this, CH_VOICE, "slime/small1.wav", 1, ATTN_NORM);
		else if(r < 0.4)
			_sound(this, CH_VOICE, "slime/small2.wav", 1, ATTN_NORM);
		else if(r < 0.6)
			_sound(this, CH_VOICE, "slime/small3.wav", 1, ATTN_NORM);
		else if(r < 0.8)
			_sound(this, CH_VOICE, "slime/small4.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "slime/small5.wav", 1, ATTN_NORM);
	}
	else
	{
		float r = random();
		if(r < 0.25)
			_sound(this, CH_VOICE, "slime/big1.wav", 1, ATTN_NORM);
		else if(r < 0.5)
			_sound(this, CH_VOICE, "slime/big2.wav", 1, ATTN_NORM);
		else if(r < 0.75)
			_sound(this, CH_VOICE, "slime/big3.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "slime/big4.wav", 1, ATTN_NORM);
	}
}

void slime_stand(entity this) { set_anim(this, anim_slime, slime_stand); ai_stand(this); }

void slime_walk1(entity this);
void slime_walk3(entity this) { set_anim(this, anim_slime, slime_walk3); if(IS_ONGROUND(this)) setthink(this, slime_walk1); }
void slime_walk2(entity this) { set_anim(this, anim_slime, slime_walk3); mcslime_hop(this, 150, 150); }
void slime_walk1(entity this) { set_anim(this, anim_slime, slime_walk2); ai_walk(this, 0); this.nextthink = time + 1 * this.scale; }

void slime_run1(entity this);
void slime_run3(entity this) { set_anim(this, anim_slime, slime_run3); if(IS_ONGROUND(this)) setthink(this, slime_run1); }
void slime_run2(entity this) { set_anim(this, anim_slime, slime_run3); mcslime_hop(this, 200, 150); }
void slime_run1(entity this) { set_anim(this, anim_slime, slime_run2); ai_run(this, 0); ai_face(this); this.nextthink = time + 1 * this.scale; }

//===========================================================================

void slime_pain6(entity this) { set_anim(this, anim_slime, slime_run1); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void slime_pain5(entity this) { set_anim(this, anim_slime, slime_pain6); }
void slime_pain4(entity this) { set_anim(this, anim_slime, slime_pain5); this.colormod = '1 0.8 0.8'; }
void slime_pain3(entity this) { set_anim(this, anim_slime, slime_pain4);}
void slime_pain2(entity this) { set_anim(this, anim_slime, slime_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void slime_pain1(entity this) { set_anim(this, anim_slime, slime_pain2); ai_pain(this, 6); }

void mcslime_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	if(this.slime_size >= 3)
	{
		float r = random();
		if(r < 0.2)
			_sound(this, CH_VOICE, "slime/small1.wav", 1, ATTN_NORM);
		else if(r < 0.4)
			_sound(this, CH_VOICE, "slime/small2.wav", 1, ATTN_NORM);
		else if(r < 0.6)
			_sound(this, CH_VOICE, "slime/small3.wav", 1, ATTN_NORM);
		else if(r < 0.8)
			_sound(this, CH_VOICE, "slime/small4.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "slime/small5.wav", 1, ATTN_NORM);
	}
	else
	{
		float r = random();
		if(r < 0.25)
			_sound(this, CH_VOICE, "slime/big1.wav", 1, ATTN_NORM);
		else if(r < 0.5)
			_sound(this, CH_VOICE, "slime/big2.wav", 1, ATTN_NORM);
		else if(r < 0.75)
			_sound(this, CH_VOICE, "slime/big3.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "slime/big4.wav", 1, ATTN_NORM);
	}

	this.pain_finished = time + 0.5;
	this.colormod = '1 0.9 0.9';

	slime_pain1(this);
}

//===========================================================================

void mcslime_split(entity this, vector org)
{
	Monster mon = (this.monsterdef) ? this.monsterdef : MON_MCSLIME;

	entity monster = new(monster);
	monster.slime_size = this.slime_size + 1;
	minion_spawn(this, org, monster, mon);
	monster.nextthink = time + random() * 1;
}

vector mcslime_randompos(entity this)
{
	vector mypos = this.origin + randomvec() * 16;
	mypos.z = this.origin_z;
	traceline(this.origin, mypos, MOVE_NOMONSTERS, this);
	return trace_endpos;
}

void slime_vanish(entity this)
{
	if(this.slime_size > 0 && this.slime_size < 3)
	{
		this.colormod = '1 1 1'; // don't break clone's colormod TODO
		mcslime_split(this, mcslime_randompos(this));
		mcslime_split(this, mcslime_randompos(this));
		if(random() < 0.5)
			mcslime_split(this, mcslime_randompos(this));
	}

	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void slime_die7(entity this) { set_anim(this, anim_slime, slime_vanish); this.nextthink = time + 0.7; this.angles_z = 90; }
void slime_die6(entity this) { set_anim(this, anim_slime, slime_die7); this.angles_z = 90; }
void slime_die5(entity this) { set_anim(this, anim_slime, slime_die6); this.angles_z = 75; }
void slime_die4(entity this) { set_anim(this, anim_slime, slime_die5); this.angles_z = 60; }
void slime_die3(entity this) { set_anim(this, anim_slime, slime_die4); this.angles_z = 45; }
void slime_die2(entity this) { set_anim(this, anim_slime, slime_die3); this.angles_z = 30; }
void slime_die1(entity this) { set_anim(this, anim_slime, slime_die2); this.solid = SOLID_NOT; this.angles_z = 15; }

void mcslime_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.slime_size >= 3)
	{
		float r = random();
		if(r < 0.2)
			_sound(this, CH_VOICE, "slime/small1.wav", 1, ATTN_NORM);
		else if(r < 0.4)
			_sound(this, CH_VOICE, "slime/small2.wav", 1, ATTN_NORM);
		else if(r < 0.6)
			_sound(this, CH_VOICE, "slime/small3.wav", 1, ATTN_NORM);
		else if(r < 0.8)
			_sound(this, CH_VOICE, "slime/small4.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "slime/small5.wav", 1, ATTN_NORM);
	}
	else
	{
		float r = random();
		if(r < 0.25)
			_sound(this, CH_VOICE, "slime/big1.wav", 1, ATTN_NORM);
		else if(r < 0.5)
			_sound(this, CH_VOICE, "slime/big2.wav", 1, ATTN_NORM);
		else if(r < 0.75)
			_sound(this, CH_VOICE, "slime/big3.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "slime/big4.wav", 1, ATTN_NORM);
	}

	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	// ensure it gets gibbed by non-player sources (TODO?)
	switch(deathtype)
	{
		case DEATH_VOID.m_id:
		case DEATH_HURTTRIGGER.m_id:
		case DEATH_KILL.m_id:
		case DEATH_GENERIC.m_id:
		case DEATH_LAVA.m_id:
		case DEATH_CHECKPOINT.m_id:
		{
			if(killed_type == KILLED_NORMAL)
				killed_type = KILLED_GIBBED;
			break;
		}
	}

	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	this.colormod = '1 0.6 0.6';
	this.angles_z = 0;
	slime_die1(this);
}

void mcslime_touch(entity this, entity toucher)
{
	if(this.health <= 0 || (!this.takedamage))
		return;
	if(this.slime_size >= 3)
		return; // baby slime no hurty
	if(toucher.monsterdef == this.monsterdef)
		return; // no slimy action ever
	if(!Damage_ValidTarget(toucher, this))
		return;

	if(toucher.takedamage && toucher.pain_finished < time)
	{
		float ldmg = (20 * this.scale) * random();
		T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_MCSLIME.m_id);

		if(random() < 0.5)
			_sound(this, CH_WEAPON_SINGLE, "slime/attack1.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_WEAPON_SINGLE, "slime/attack2.wav", 1, ATTN_NORM);
	}
}

/*QUAKED monster_slime (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_mcslime) { monster_start(this, true, MON_MCSLIME); }
#endif // SVQC

#ifdef SVQC
METHOD(MCSlime, mr_setup, bool(MCSlime this, entity actor))
{
    TC(MCSlime, this);

	precache_sound("slime/attack1.wav");
	precache_sound("slime/attack2.wav");

	precache_sound("slime/big1.wav");
	precache_sound("slime/big2.wav");
	precache_sound("slime/big3.wav");
	precache_sound("slime/big4.wav");

	precache_sound("slime/small1.wav");
	precache_sound("slime/small2.wav");
	precache_sound("slime/small3.wav");
	precache_sound("slime/small4.wav");
	precache_sound("slime/small5.wav");

	actor.yaw_speed = 90;

	if(!actor.slime_size)
	{
		float r = random();
		if(r < 0.33)
			actor.slime_size = 1;
		else if(r < 0.66)
			actor.slime_size = 2;
		else
			actor.slime_size = 3;
	}

	actor.scale = 1 / actor.slime_size;
	setsize(actor, this.m_mins * actor.scale, this.m_maxs * actor.scale);

	actor.solid = SOLID_CORPSE; // passes through, can still impact players

    actor.health = 70 * actor.scale;
    actor.th_stand = slime_stand;
	actor.th_walk = slime_walk1;
	actor.th_run = slime_run1;
	actor.th_pain = mcslime_pain;
	actor.th_die = mcslime_die;

	settouch(actor, mcslime_touch);

    return true;
}
#endif
