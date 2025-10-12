#include "golem_head.qh"

#ifdef SVQC
const int anim_golem_head = 0;

void golem_head_run1(entity this);
void golem_head_side1(entity this);

/*
=================
GolemHeadCheckAttack
=================
*/
bool GolemHeadCheckAttack(entity this)
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
			golem_head_run1(this);
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
			golem_head_run1(this);
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
			golem_head_run1(this);
		}
	}
	else
	{
		if(this.health <= (this.max_health * 0.5))
		{
			if(this.attack_state != AS_DODGING)
			{
				this.attack_state = AS_DODGING;
				golem_head_side1(this);
			}
		}
		else
		{
			if(this.attack_state != AS_SLIDING)
			{
				this.attack_state = AS_SLIDING;
				golem_head_side1(this);
			}
		}
	}
	
	return false;
}

/*
=================
GolemHeadAttackFinished
=================
*/
void GolemHead_Missile(entity this);
void GolemHeadAttackFinished(entity this)
{
	this.skin = 0;
	if(this.enemy_range >= RANGE_MID || !this.enemy_visible)
	{
		this.attack_state = AS_STRAIGHT;
		setthink(this, golem_head_run1);
	}
	else
	{
		this.attack_state = AS_SLIDING;
		setthink(this, golem_head_side1);
	}
}

/*
==============================================================================

FAST ATTACKS

==============================================================================
*/

void GolemHead_StartFast(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "jungle_golem/laser_fire.wav", 1, ATTN_NORM);
	fixedmakevectors(this.angles);

	vector dir = this.enemy.origin - this.origin;

	entity newmis;
	newmis = HIP_LaunchLaser(this, this.origin + v_up * 48 + v_right * 12, dir, 0);
	newmis.projectiledeathtype = DEATH_MONSTER_GOLEM_HEAD.m_id;

	newmis = HIP_LaunchLaser(this, this.origin + v_up * 48 + v_right * -12, dir, 0);
	newmis.projectiledeathtype = DEATH_MONSTER_GOLEM_HEAD.m_id;
}

void golem_head_stand1(entity this) { set_anim(this, anim_golem_head, golem_head_stand1); ai_stand(this); }

void golem_head_walk1(entity this) { set_anim(this, anim_golem_head, golem_head_walk1); ai_walk(this, 8); }

void golem_head_side1(entity this) { set_anim(this, anim_golem_head, golem_head_side1); ai_run(this, 8); }

void golem_head_run1(entity this) { set_anim(this, anim_golem_head, golem_head_run1); ai_run(this, 16); }

void golem_head_fast10(entity this) { set_anim(this, anim_golem_head, golem_head_run1); ai_face(this); GolemHeadAttackFinished(this); }
void golem_head_fast9(entity this) { set_anim(this, anim_golem_head, golem_head_fast10); ai_face(this); }
void golem_head_fast8(entity this) { set_anim(this, anim_golem_head, golem_head_fast9); ai_face(this); }
void golem_head_fast7(entity this) { set_anim(this, anim_golem_head, golem_head_fast8); ai_face(this); GolemHead_StartFast(this); }
void golem_head_fast6(entity this) { set_anim(this, anim_golem_head, golem_head_fast7); ai_face(this); }
void golem_head_fast5(entity this) { set_anim(this, anim_golem_head, golem_head_fast6); ai_face(this); GolemHead_StartFast(this);  }
void golem_head_fast4(entity this) { set_anim(this, anim_golem_head, golem_head_fast5); ai_face(this); }
void golem_head_fast3(entity this) { set_anim(this, anim_golem_head, golem_head_fast4); ai_face(this); }
void golem_head_fast2(entity this) { set_anim(this, anim_golem_head, golem_head_fast3); ai_face(this); GolemHead_StartFast(this); }
void golem_head_fast1(entity this) { set_anim(this, anim_golem_head, golem_head_fast2); ai_face(this); }

void golem_head_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "jungle_golem/explode.wav", 1, 0.5);
	Send_Effect(EFFECT_EXPLOSION_SMALL, CENTER_OR_VIEWOFS(this), '0 0 0', 1);
	if(this.charmer && this.charmer.monsterdef == MON_JUNGLE_GOLEM && this.charmer.golem_head == this)
		this.charmer.golem_head = NULL;
	delete(this);
}

void GolemHead_Pain(entity this, entity attacker, float damage, int deathtype)
{
	spamsound(this, CH_VOICE, SND_MECHBOSS_HIT, 1, ATTN_NORM);
}

void GolemHead_Missile(entity this)
{
	this.attack_finished = time + 1 + (2 * random());
	golem_head_fast1(this);
}

/*QUAKED monster_golem_head(1 0 0)(-16 -16 -24)(16 16 40) Ambush
*/
//spawnfunc(monster_golem_head) { monster_start(this, true, MON_GOLEM_HEAD); }
#endif // SVQC

#ifdef SVQC
METHOD(GolemHead, mr_setup, bool(GolemHead this, entity actor))
{
    TC(GolemHead, this);

	precache_sound("jungle_golem/laser_fire.wav");
	precache_sound("jungle_golem/explode.wav");

    actor.health = 1000;
    actor.th_stand = golem_head_stand1;
	actor.th_walk = golem_head_walk1;
	actor.th_run = golem_head_run1;
	actor.th_missile = GolemHead_Missile;
	actor.th_pain = GolemHead_Pain;
	actor.th_die = golem_head_die;

	actor.checkattack = GolemHeadCheckAttack;

    return true;
}
#endif
