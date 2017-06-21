// TODO
#ifndef IMPLEMENTATION

#include "troll.qh"

#ifdef SVQC
float autocvar_g_monster_troll_health = 900;
float autocvar_g_monster_troll_damageforcescale = 0.1;
float autocvar_g_monster_troll_attack_claw_damage = 90;
float autocvar_g_monster_troll_speed_stop = 300;
float autocvar_g_monster_troll_speed_run = 300;
float autocvar_g_monster_troll_speed_walk = 190;

/*
const float troll_anim_attack		= 0;
const float troll_anim_idle			= 1;
const float troll_anim_walk			= 2;
const float troll_anim_death		= 3;
const float troll_anim_dead         = 4;
const float troll_anim_run			= 5;
*/

void M_Troll_Attack_Swing(entity this)
{
    Monster_Attack_Melee(this, this.enemy, (autocvar_g_monster_troll_attack_claw_damage), this.anim_melee1, this.attack_range, 0.5, DEATH_MONSTER_TROLL_MELEE.m_id, true);
}

bool M_Troll_Attack(int attack_type, entity actor, entity targ, .entity weaponentity)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
            actor.state = MONSTER_ATTACK_MELEE; // freeze monster
            setanim(actor, actor.anim_melee1, false, true, true);
			Monster_Delay(actor, 1, 0.6, M_Troll_Attack_Swing);
            actor.anim_finished = actor.attack_finished_single[0] = time + 0.6; // set this for the delay
			return true;
		}
		case MONSTER_ATTACK_RANGED:
		{
			// troll has no ranged attack
			return false;
		}
	}

	return false;
}

spawnfunc(monster_troll) { Monster_Spawn(this, true, MON_TROLL.monsterid); }
#endif // SVQC

#ifdef SVQC
METHOD(Troll, mr_think, bool(Troll this, entity actor))
{
    TC(Troll, this);
    return true;
}

METHOD(Troll, mr_pain, float(Troll this, entity actor, float damage_take, entity attacker, float deathtype))
{
    TC(Troll, this);
    actor.pain_finished = time + 0.5;
    // no pain animation yet
    //setanim(actor, actor.anim_pain1, true, true, false);
    return damage_take;
}

METHOD(Troll, mr_death, bool(Troll this, entity actor))
{
    TC(Troll, this);
    setanim(actor, actor.anim_die1, false, true, true);
    return true;
}
#endif
#ifdef GAMEQC
METHOD(Troll, mr_anim, bool(Troll this, entity actor))
{
    TC(Troll, this);
    vector none = '0 0 0';
    actor.anim_die1 = animfixfps(actor, '3 1 1', none); // 2 seconds
    actor.anim_walk = animfixfps(actor, '2 1 1', none);
    actor.anim_idle = animfixfps(actor, '1 1 1', none);
    actor.anim_melee1 = animfixfps(actor, '0 1 1', none); // analyze models and set framerate
    actor.anim_run = animfixfps(actor, '5 1 1', none);
    return true;
}
#endif
#ifdef SVQC
.float animstate_endtime;
METHOD(Troll, mr_setup, bool(Troll this, entity actor))
{
    TC(Troll, this);
    if(!actor.health) actor.health = (autocvar_g_monster_troll_health);
    if(!actor.attack_range) actor.attack_range = 150;
    if(!actor.speed) { actor.speed = (autocvar_g_monster_troll_speed_walk); }
    if(!actor.speed2) { actor.speed2 = (autocvar_g_monster_troll_speed_run); }
    if(!actor.stopspeed) { actor.stopspeed = (autocvar_g_monster_troll_speed_stop); }
    if(!actor.damageforcescale) { actor.damageforcescale = (autocvar_g_monster_troll_damageforcescale); }

    actor.view_ofs = '0 0 35'; // we swing at a lower height than our eyes

    actor.monster_loot = ITEM_ArmorBig;
    actor.weapon = WEP_MORTAR.m_id;

    setanim(actor, actor.anim_idle, false, true, true);
    actor.spawn_time = actor.animstate_endtime;
    actor.spawnshieldtime = actor.spawn_time;
    actor.monster_attackfunc = M_Troll_Attack;

    return true;
}
#endif

#endif
