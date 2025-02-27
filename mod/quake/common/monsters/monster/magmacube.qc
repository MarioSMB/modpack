#include "magmacube.qh"

#ifdef SVQC
const int anim_magmacube_pain = 32;

.int magmacube_size; // NOTE: larger = smaller, silly maths

void magmacube_hop(entity this, float dist, float distz)
{
	fixedmakevectors(this.angles);
	if(this.enemy)
	{
		if(vdist(this.enemy.origin - this.origin, >=, 150))
		{
			dist *= max(0.33, (random() * this.scale));
			distz *= max(0.33, (random() * this.scale));
		}
		else
		{
			dist *= 0.33;
			distz *= 0.33;
		}
	}
	vector dir = v_forward * dist + v_up * distz;

	UNSET_ONGROUND(this);
	this.velocity = dir;

	if(this.magmacube_size >= 3)
		sound(this, CH_VOICE, SND_MON_MAGMACUBE_SMALL_RANDOM(), 1, ATTN_NORM);
	else
		sound(this, CH_VOICE, SND_MON_MAGMACUBE_JUMP_RANDOM(), 1, ATTN_NORM);
}

void magmacube_stand(entity this) { set_anim(this, 0, magmacube_stand); ai_stand(this); }

void magmacube_walk1(entity this);
void magmacube_walk3(entity this)
{
	set_anim(this, 5, magmacube_walk3);
	if(IS_ONGROUND(this))
		setthink(this, magmacube_walk1);
}
void magmacube_walk2(entity this) { set_anim(this, 3, magmacube_walk3); magmacube_hop(this, 150, 150); }
void magmacube_walk1(entity this) { set_anim(this, 0, magmacube_walk2); ai_walk(this, 0); this.nextthink = time + 1 * this.scale; }

void magmacube_run1(entity this);
void magmacube_run3(entity this)
{
	set_anim(this, 5, magmacube_run3);
	if(IS_ONGROUND(this))
		setthink(this, magmacube_run1);
}
void magmacube_run2(entity this) { set_anim(this, 3, magmacube_run3); magmacube_hop(this, 400, 500); }
void magmacube_run1(entity this) { set_anim(this, 0, magmacube_run2); ai_run(this, 0); ai_face(this); this.nextthink = time + 1 * this.scale; }

//===========================================================================

void magmacube_pain6(entity this) { set_animofs(this, anim_magmacube_pain, 5, magmacube_run1); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void magmacube_pain5(entity this) { set_animofs(this, anim_magmacube_pain, 5, magmacube_pain6); }
void magmacube_pain4(entity this) { set_animofs(this, anim_magmacube_pain, 4, magmacube_pain5); this.colormod = '1 0.8 0.8'; }
void magmacube_pain3(entity this) { set_animofs(this, anim_magmacube_pain, 3, magmacube_pain4);}
void magmacube_pain2(entity this) { set_animofs(this, anim_magmacube_pain, 2, magmacube_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void magmacube_pain1(entity this) { set_animofs(this, anim_magmacube_pain, 1, magmacube_pain2); ai_pain(this, 6); }

void magmacube_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	if(this.magmacube_size >= 3)
		sound(this, CH_VOICE, SND_MON_MAGMACUBE_SMALL_RANDOM(), 1, ATTN_NORM);
	else
		sound(this, CH_VOICE, SND_MON_MAGMACUBE_BIG_RANDOM(), 1, ATTN_NORM);

	this.pain_finished = time + 0.5;
	this.colormod = '1 0.9 0.9';

	magmacube_pain1(this);
}

//===========================================================================

void magmacube_split(entity this, vector org)
{
	Monster mon = (this.monsterdef) ? this.monsterdef : MON_MAGMACUBE;

	entity monster = new(monster);
	monster.magmacube_size = this.magmacube_size + 1;
	minion_spawn(this, org, monster, mon);
	monster.nextthink = time + random() * 1;
}

vector magmacube_randompos(entity this)
{
	vector mypos = this.origin + randomvec() * 16;
	mypos.z = this.origin_z;
	traceline(this.origin, mypos, MOVE_NOMONSTERS, this);
	return trace_endpos;
}

void magmacube_vanish(entity this)
{
	if(this.magmacube_size > 0 && this.magmacube_size < 3)
	{
		this.colormod = '1 1 1'; // don't break clone's colormod TODO
		magmacube_split(this, magmacube_randompos(this));
		magmacube_split(this, magmacube_randompos(this));
		if(random() < 0.5)
			magmacube_split(this, magmacube_randompos(this));
	}

	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void magmacube_die7(entity this) { set_anim(this, 0, magmacube_vanish); this.nextthink = time + 0.7; this.angles_z = 90; }
void magmacube_die6(entity this) { set_anim(this, 0, magmacube_die7); this.angles_z = 90; }
void magmacube_die5(entity this) { set_anim(this, 0, magmacube_die6); this.angles_z = 75; }
void magmacube_die4(entity this) { set_anim(this, 0, magmacube_die5); this.angles_z = 60; }
void magmacube_die3(entity this) { set_anim(this, 0, magmacube_die4); this.angles_z = 45; }
void magmacube_die2(entity this) { set_anim(this, 0, magmacube_die3); this.angles_z = 30; }
void magmacube_die1(entity this) { set_anim(this, 0, magmacube_die2); this.solid = SOLID_NOT; this.angles_z = 15; }

void magmacube_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.magmacube_size >= 3)
		sound(this, CH_VOICE, SND_MON_MAGMACUBE_SMALL_RANDOM(), 1, ATTN_NORM);
	else
		sound(this, CH_VOICE, SND_MON_MAGMACUBE_BIG_RANDOM(), 1, ATTN_NORM);

	switch(deathtype)
	{
		case DEATH_VOID.m_id:
		case DEATH_HURTTRIGGER.m_id:
		case DEATH_KILL.m_id:
		case DEATH_GENERIC.m_id:
		case DEATH_LAVA.m_id:
		case DEATH_CHECKPOINT.m_id:
		{
			Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
			delete(this);
			return;
		}
	}

	this.colormod = '1 0.6 0.6';
	this.angles_z = 0;
	magmacube_die1(this);
}

void magmacube_touch(entity this, entity toucher)
{
	if(this.health <= 0 || (!this.takedamage))
		return;
	if(toucher.monsterdef == this.monsterdef)
		return; // no slimy action ever
	if(!Damage_ValidTarget(toucher, this))
		return;

	if(toucher.takedamage && toucher.pain_finished < time)
	{
		float ldmg = (20 * this.scale) * random();
		T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_MAGMACUBE.m_id);

		float burntime = floor(this.scale + 2 + 2*random());
		// only add more burn time if there isn't already a longer timer running!
		float curtime = StatusEffects_gettime(STATUSEFFECT_Burning, toucher);
		if((time + burntime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Burning, toucher, time + burntime, 0);
	}
}

/*QUAKED monster_magmacube (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_magmacube) { monster_start(this, true, MON_MAGMACUBE); }
#endif // SVQC

#ifdef SVQC
METHOD(MagmaCube, mr_setup, bool(MagmaCube this, entity actor))
{
    TC(MagmaCube, this);

	actor.yaw_speed = 90;

	if(!actor.magmacube_size)
	{
		float r = random();
		if(r < 0.33)
			actor.magmacube_size = 1;
		else if(r < 0.66)
			actor.magmacube_size = 2;
		else
			actor.magmacube_size = 3;
	}

	actor.scale = 1 / actor.magmacube_size;
	setsize(actor, this.m_mins * actor.scale, this.m_maxs * actor.scale);

	actor.solid = SOLID_CORPSE; // passes through, can still impact players

    actor.health = 70 * actor.scale;
    actor.th_stand = magmacube_stand;
	actor.th_walk = magmacube_walk1;
	actor.th_run = magmacube_run1;
	actor.th_pain = magmacube_pain;
	actor.th_die = magmacube_die;

	settouch(actor, magmacube_touch);

    return true;
}
#endif
