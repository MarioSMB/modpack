#ifndef DEMON_H
#define DEMON_H

#ifndef MENUQC
MODEL(MON_DEMON, M_Model("demon.mdl"));

MSG_INFO_NOTIF(DEATH_SELF_MON_DEMON_JUMP,             1, 2, 1, "s1 s2loc spree_lost", "s1",    "notify_death",         "^BG%s^K1 was pounced on by a Demon%s%s", "")
MSG_MULTI_NOTIF(DEATH_SELF_MON_DEMON_JUMP,                1,  NULL,           INFO_DEATH_SELF_MON_DEMON_JUMP,               CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_DEMON_JUMP,            				DEATH_SELF_MON_DEMON_JUMP,            	DEATH_MURDER_MONSTER,           	"monster")

MSG_INFO_NOTIF(DEATH_SELF_MON_DEMON_MELEE,             1, 2, 1, "s1 s2loc spree_lost", "s1",    "notify_death",         "^BG%s^K1 was eviscerated by a Demon%s%s", "")
MSG_MULTI_NOTIF(DEATH_SELF_MON_DEMON_MELEE,                1,  NULL,           INFO_DEATH_SELF_MON_DEMON_MELEE,               CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_DEMON_MELEE,            				DEATH_SELF_MON_DEMON_MELEE,            	DEATH_MURDER_MONSTER,           	"monster")
#endif

CLASS(Demon, Monster)
    ATTRIB(Demon, spawnflags, int, MONSTER_SIZE_QUAKE | MON_FLAG_MELEE | MON_FLAG_RANGED);
    ATTRIB(Demon, mins, vector, '-32 -32 -24');
    ATTRIB(Demon, maxs, vector, '32 32 24');
#ifndef MENUQC
    ATTRIB(Demon, m_model, Model, MDL_MON_DEMON);
#endif
    ATTRIB(Demon, netname, string, "demon");
    ATTRIB(Demon, monster_name, string, "Demon");
ENDCLASS(Demon)

REGISTER_MONSTER(DEMON, NEW(Demon)) {
#ifndef MENUQC
    this.mr_precache(this);
#endif
}

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

AUTOCVAR(g_monster_demon_health, float, 350, "");
AUTOCVAR(g_monster_demon_damageforcescale, float, 0.35, "");
AUTOCVAR(g_monster_demon_attack_melee_damage, float, 50, "");
AUTOCVAR(g_monster_demon_attack_melee_delay, float, 1.2, "");
AUTOCVAR(g_monster_demon_attack_leap_damage, float, 50, "");
AUTOCVAR(g_monster_demon_attack_leap_force, float, 300, "");
AUTOCVAR(g_monster_demon_attack_leap_speed, float, 700, "");
AUTOCVAR(g_monster_demon_attack_leap_delay, float, 0.7, "");
AUTOCVAR(g_monster_demon_attack_leap_mindist, float, 400, "");
AUTOCVAR(g_monster_demon_speed_stop, float, 100, "");
AUTOCVAR(g_monster_demon_speed_run, float, 300, "");
AUTOCVAR(g_monster_demon_speed_walk, float, 95, "");

/*
const float demon_anim_stand	= 0;
const float demon_anim_walk		= 1;
const float demon_anim_run		= 2;
const float demon_anim_leap		= 3;
const float demon_anim_pain		= 4;
const float demon_anim_death	= 5;
const float demon_anim_attack	= 6;
*/

void M_Demon_Attack_Leap_Touch(entity this, entity toucher)
{
	if (this.health <= 0)
		return;

	vector angles_face;

	if(toucher.takedamage)
	{
		angles_face = vectoangles(this.moveto - this.origin);
		angles_face = normalize(angles_face) * (autocvar_g_monster_demon_attack_leap_force);
		Damage(toucher, this, this, (autocvar_g_monster_demon_attack_leap_damage) * MONSTER_SKILLMOD(this), DEATH_MONSTER_DEMON_JUMP.m_id, toucher.origin, angles_face);
		settouch(this, Monster_Touch); // instantly turn it off to stop damage spam
		this.state = 0;
	}

	if (trace_dphitcontents)
	{
		this.state = 0;
		settouch(this, Monster_Touch);
	}
}

bool M_Demon_Attack(int attack_type, entity actor, entity targ)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			return Monster_Attack_Melee(actor, targ, (autocvar_g_monster_demon_attack_melee_damage), actor.anim_melee, actor.attack_range, (autocvar_g_monster_demon_attack_melee_delay), DEATH_MONSTER_DEMON_MELEE.m_id, true);
		}
		case MONSTER_ATTACK_RANGED:
		{
			if(vdist(targ.origin - actor.origin, <=, autocvar_g_monster_demon_attack_leap_mindist))
				return false;
			makevectors(actor.angles);
			return Monster_Attack_Leap(actor, actor.anim_shoot, M_Demon_Attack_Leap_Touch, v_forward * (autocvar_g_monster_demon_attack_leap_speed) + '0 0 200', (autocvar_g_monster_demon_attack_leap_delay));
		}
	}

	return false;
}

spawnfunc(monster_demon) { Monster_Spawn(this, MON_DEMON.monsterid); }
spawnfunc(monster_demon1) { Monster_Spawn(this, MON_DEMON.monsterid); }

#endif // SVQC

		#ifdef SVQC
		METHOD(Demon, mr_think, bool(Monster thismon, entity actor))
		{
			return true;
		}
		METHOD(Demon, mr_pain, float(Monster thismon, entity actor, float damage_take, entity attacker, float deathtype))
		{
			actor.pain_finished = time + 0.5;
			setanim(actor, actor.anim_pain1, true, true, false);
			return damage_take;
		}
		METHOD(Demon, mr_death, bool(Monster thismon, entity actor))
		{
			setanim(actor, actor.anim_die1, false, true, true);
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Demon, mr_anim, bool(Monster thismon, entity actor))
		{
			vector none = '0 0 0';
			actor.anim_die1 = animfixfps(actor, '5 1 0.5', none); // 2 seconds
			actor.anim_walk = animfixfps(actor, '1 1 1', none);
			actor.anim_idle = animfixfps(actor, '0 1 1', none);
			actor.anim_pain1 = animfixfps(actor, '4 1 2', none); // 0.5 seconds
			actor.anim_melee = animfixfps(actor, '6 1 5', none); // analyze models and set framerate
			actor.anim_shoot = animfixfps(actor, '3 1 5', none); // analyze models and set framerate
			actor.anim_run = animfixfps(actor, '2 1 1', none);

			return true;
		}
		#endif
		#ifdef SVQC
		.float speed;
		spawnfunc(item_health_large);
		METHOD(Demon, mr_setup, bool(Monster thismon, entity actor))
		{
			if(!actor.health) actor.health = (autocvar_g_monster_demon_health);
			if(!actor.speed) { actor.speed = (autocvar_g_monster_demon_speed_walk); }
			if(!actor.speed2) { actor.speed2 = (autocvar_g_monster_demon_speed_run); }
			if(!actor.stopspeed) { actor.stopspeed = (autocvar_g_monster_demon_speed_stop); }
			if(!actor.damageforcescale) { actor.damageforcescale = (autocvar_g_monster_demon_damageforcescale); }

			actor.monster_loot = spawnfunc_item_health_large;
			actor.monster_attackfunc = M_Demon_Attack;

			return true;
		}
		METHOD(Demon, mr_precache, bool(Monster thismon))
		{
			return true;
		}
		#endif

#endif
