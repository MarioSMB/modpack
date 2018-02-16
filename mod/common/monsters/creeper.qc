// TODO
#ifndef IMPLEMENTATION

#include "creeper.qh"

#ifdef SVQC
float autocvar_g_monster_creeper_health = 200;
float autocvar_g_monster_creeper_damageforcescale = 0.1;
float autocvar_g_monster_creeper_attack_explode_damage = 100;
float autocvar_g_monster_creeper_attack_explode_edgedamage = 80;
float autocvar_g_monster_creeper_attack_explode_radius = 260;
float autocvar_g_monster_creeper_attack_explode_force = 300;
float autocvar_g_monster_creeper_attack_explode_prime_delay = 0.9;
float autocvar_g_monster_creeper_speed_stop = 200;
float autocvar_g_monster_creeper_speed_run = 380;
float autocvar_g_monster_creeper_speed_walk = 220;

/*
const int creeper_anim_idle = 0;
const int creeper_anim_walk = 1;
const int creeper_anim_die = 2;
*/

.bool creeper_primed;

bool M_Creeper_Attack(int attack_type, entity actor, entity targ, .entity weaponentity)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
            actor.state = MONSTER_ATTACK_MELEE; // freeze monster
            setanim(actor, actor.anim_idle, true, false, false);
            if(actor.creeper_primed)
            {
                Send_Effect(EFFECT_EXPLOSION_MEDIUM, actor.origin, '0 0 0', 1);
                sound(actor, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTEN_NORM);

                RadiusDamage(actor, actor, autocvar_g_monster_creeper_attack_explode_damage, autocvar_g_monster_creeper_attack_explode_edgedamage, autocvar_g_monster_creeper_attack_explode_radius,
                        NULL, NULL, autocvar_g_monster_creeper_attack_explode_force, DEATH_MONSTER_CREEPER.m_id, DMG_NOWEP, NULL);

                Damage(actor, NULL, NULL, actor.health + actor.max_health + 200, DEATH_KILL.m_id, DMG_NOWEP, actor.origin, '0 0 0'); // ensure monster death
                actor.event_damage = func_null;
            }
            else
            {
                actor.creeper_primed = true; // next time we have a melee attack, explode!
                actor.colormod = '1 0 0'; // red tint for primed
                Monster_Sound(actor, monstersound_ranged, 0, false, CH_VOICE);
                actor.anim_finished = actor.attack_finished_single[0] = time + autocvar_g_monster_creeper_attack_explode_prime_delay; // set this for the delay
            }

			return true;
		}
		case MONSTER_ATTACK_RANGED:
		{
			// creeper has no ranged attack
			return false;
		}
	}

	return false;
}

spawnfunc(monster_creeper) { Monster_Spawn(this, true, MON_CREEPER.monsterid); }
#endif // SVQC

#ifdef SVQC
METHOD(Creeper, mr_think, bool(Creeper this, entity actor))
{
    TC(Creeper, this);
    if(actor.creeper_primed && (!actor.enemy || vdist(actor.origin - actor.enemy.origin, >=, actor.attack_range * 2)))
        actor.creeper_primed = false;
    if(actor.health > 0 && time > actor.attack_finished_single[0])
        actor.colormod = '1 1 1';
    return true;
}

METHOD(Creeper, mr_pain, float(Creeper this, entity actor, float damage_take, entity attacker, float deathtype))
{
    TC(Creeper, this);
    actor.pain_finished = time + 0.5;
    // no pain animation yet
    //setanim(actor, actor.anim_pain1, true, true, false);
    return damage_take;
}

METHOD(Creeper, mr_death, bool(Creeper this, entity actor))
{
    TC(Creeper, this);
    setanim(actor, actor.anim_die1, false, true, true);
    return true;
}
#endif
#ifdef GAMEQC
METHOD(Creeper, mr_anim, bool(Creeper this, entity actor))
{
    TC(Creeper, this);
    vector none = '0 0 0';
    actor.anim_die1 = animfixfps(actor, '2 1 0.5', none); // 2 seconds
    actor.anim_walk = animfixfps(actor, '1 1 1', none);
    actor.anim_idle = animfixfps(actor, '0 1 1', none);
    actor.anim_run = animfixfps(actor, '1 1 1', none);
    return true;
}
#endif
#ifdef SVQC
.float animstate_endtime;
METHOD(Creeper, mr_setup, bool(Creeper this, entity actor))
{
    TC(Creeper, this);
    if(!actor.health) actor.health = (autocvar_g_monster_creeper_health);
    if(!actor.attack_range) actor.attack_range = 150;
    if(!actor.speed) { actor.speed = (autocvar_g_monster_creeper_speed_walk); }
    if(!actor.speed2) { actor.speed2 = (autocvar_g_monster_creeper_speed_run); }
    if(!actor.stopspeed) { actor.stopspeed = (autocvar_g_monster_creeper_speed_stop); }
    if(!actor.damageforcescale) { actor.damageforcescale = (autocvar_g_monster_creeper_damageforcescale); }
    if(!actor.wander_delay) actor.wander_delay = 10;
    if(!actor.wander_distance) actor.wander_distance = 200;

    actor.monster_loot = ITEM_Rockets;

    setanim(actor, actor.anim_idle, false, true, true);
    actor.spawn_time = actor.animstate_endtime;
    actor.spawnshieldtime = actor.spawn_time;
    actor.monster_attackfunc = M_Creeper_Attack;

    actor.colormod = '1 1 1';

    return true;
}
#endif

#endif
