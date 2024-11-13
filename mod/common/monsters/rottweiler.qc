#ifndef ROTTWEILER_H
#define ROTTWEILER_H

#ifdef GAMEQC
MODEL(MON_ROTTWEILER, M_Model("dog.mdl"));

MSG_INFO_NOTIF(DEATH_SELF_MON_ROTTWEILER_MELEE,             1, 2, 1, "s1 s2loc spree_lost", "s1",    "notify_death",         "^BG%s^K1 was mauled by a Rottweiler%s%s", "")
MSG_MULTI_NOTIF(DEATH_SELF_MON_ROTTWEILER_MELEE,                1,  NULL,           INFO_DEATH_SELF_MON_ROTTWEILER_MELEE,               CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_ROTTWEILER_MELEE,            			DEATH_SELF_MON_ROTTWEILER_MELEE,        DEATH_MURDER_MONSTER,           NULL, NULL,	"monster")
#endif

CLASS(Rottweiler, Monster)
    ATTRIB(Rottweiler, spawnflags, int, MONSTER_SIZE_QUAKE | MON_FLAG_HIDDEN | MON_FLAG_MELEE | MON_FLAG_RIDE);
    ATTRIB(Rottweiler, m_mins, vector, '-16 -16 -24');
    ATTRIB(Rottweiler, m_maxs, vector, '16 16 12');
#ifdef GAMEQC
    ATTRIB(Rottweiler, m_model, Model, MDL_MON_ROTTWEILER);
#endif
    ATTRIB(Rottweiler, netname, string, "rottweiler");
    ATTRIB(Rottweiler, monster_name, string, "Rottweiler");
ENDCLASS(Rottweiler)

REGISTER_MONSTER(ROTTWEILER, NEW(Rottweiler));

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

AUTOCVAR(g_monster_rottweiler_health, float, 80, "");
AUTOCVAR(g_monster_rottweiler_damageforcescale, float, 0.7, "");
AUTOCVAR(g_monster_rottweiler_attack_melee_damage, float, 25, "");
AUTOCVAR(g_monster_rottweiler_attack_melee_delay, float, 0.8, "");
AUTOCVAR(g_monster_rottweiler_speed_stop, float, 100, "");
AUTOCVAR(g_monster_rottweiler_speed_run, float, 300, "");
AUTOCVAR(g_monster_rottweiler_speed_walk, float, 70, "");

/*
const float rottweiler_anim_attack1		= 0;
const float rottweiler_anim_death1		= 1;
const float rottweiler_anim_death2		= 2;
const float rottweiler_anim_attack2		= 3;
const float rottweiler_anim_pain		= 4;
const float rottweiler_anim_run			= 5;
const float rottweiler_anim_leap		= 6;
const float rottweiler_anim_idle		= 7;
const float rottweiler_anim_walk		= 8;
*/

bool M_Rottweiler_Attack(int attack_type, entity actor, entity targ, .entity weaponentity)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			return Monster_Attack_Melee(actor, targ, (autocvar_g_monster_rottweiler_attack_melee_damage), ((random() >= 0.5) ? actor.anim_melee1 : actor.anim_melee2), actor.attack_range, (autocvar_g_monster_rottweiler_attack_melee_delay), DEATH_MONSTER_ROTTWEILER_MELEE.m_id, true);
		}
		case MONSTER_ATTACK_RANGED:
		{
			// TODO: pounce!
			return false;
		}
	}

	return false;
}

spawnfunc(monster_rottweiler) { Monster_Spawn(this, true, MON_ROTTWEILER.monsterid); }
spawnfunc(monster_dog) { Monster_Spawn(this, true, MON_ROTTWEILER.monsterid); }

#endif // SVQC

		#ifdef SVQC
		METHOD(Rottweiler, mr_think, bool(Monster thismon, entity actor))
		{
			return true;
		}
		METHOD(Rottweiler, mr_pain, float(Monster thismon, entity actor, float damage_take, entity attacker, float deathtype))
		{
			if(random() <= 0.3)
			{
				setanim(actor, actor.anim_pain1, true, true, false);
				if(actor.animstate_endtime > time)
					actor.pain_finished = actor.animstate_endtime;
				else
					actor.pain_finished = time + 0.5; // short burst?
			}
			return damage_take;
		}
		METHOD(Rottweiler, mr_death, bool(Monster thismon, entity actor))
		{
			setanim(actor, ((random() > 0.5) ? actor.anim_die1 : actor.anim_die2), false, true, true);
			return true;
		}
		#endif
		#ifdef GAMEQC
		METHOD(Rottweiler, mr_anim, bool(Monster thismon, entity actor))
		{
			vector none = '0 0 0';
			actor.anim_die1 = animfixfps(actor, '1 1 0.5', none); // 2 seconds
			actor.anim_die2 = animfixfps(actor, '2 1 0.5', none); // 2 seconds
			actor.anim_walk = animfixfps(actor, '8 1 1', none);
			actor.anim_idle = animfixfps(actor, '7 1 1', none);
			actor.anim_pain1 = animfixfps(actor, '4 1 2', none); // 0.5 seconds
			actor.anim_melee1 = animfixfps(actor, '0 1 5', none); // analyze models and set framerate
			actor.anim_melee2 = animfixfps(actor, '3 1 5', none); // analyze models and set framerate
			actor.anim_shoot = animfixfps(actor, '6 1 5', none); // analyze models and set framerate
			actor.anim_run = animfixfps(actor, '5 1 1', none);

			return true;
		}
		#endif
		#ifdef SVQC
		.float speed;
		METHOD(Rottweiler, mr_setup, bool(Monster thismon, entity actor))
		{
			if(!GetResource(actor, RES_HEALTH)) SetResourceExplicit(actor, RES_HEALTH, autocvar_g_monster_rottweiler_health);
			if(!actor.speed) { actor.speed = (autocvar_g_monster_rottweiler_speed_walk); }
			if(!actor.speed2) { actor.speed2 = (autocvar_g_monster_rottweiler_speed_run); }
			if(!actor.stopspeed) { actor.stopspeed = (autocvar_g_monster_rottweiler_speed_stop); }
			if(!actor.damageforcescale) { actor.damageforcescale = (autocvar_g_monster_rottweiler_damageforcescale); }

			actor.monster_loot = ITEM_HealthSmall;
			actor.monster_attackfunc = M_Rottweiler_Attack;

			return true;
		}
		#endif

#endif
