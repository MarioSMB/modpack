
#ifndef ROTFISH_H
#define ROTFISH_H

#ifdef GAMEQC
MODEL(MON_ROTFISH, M_Model("fish.mdl"));

MSG_INFO_NOTIF(DEATH_SELF_MON_ROTFISH_MELEE,             1, 2, 1, "s1 s2loc spree_lost", "s1",    "notify_death",         "^BG%s^K1 let a Rotfish nibble their toes%s%s", "")
MSG_MULTI_NOTIF(DEATH_SELF_MON_ROTFISH_MELEE,                1,  NULL,           INFO_DEATH_SELF_MON_ROTFISH_MELEE,               CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_ROTFISH_MELEE,            				DEATH_SELF_MON_ROTFISH_MELEE,            	DEATH_MURDER_MONSTER,           	"monster")
#endif

CLASS(Rotfish, Monster)
    ATTRIB(Rotfish, spawnflags, int, MONSTER_SIZE_QUAKE | MON_FLAG_HIDDEN | MON_FLAG_MELEE | MONSTER_TYPE_SWIM);
    ATTRIB(Rotfish, m_mins, vector, '-20 -20 -31');
    ATTRIB(Rotfish, m_maxs, vector, '20 20 20');
#ifdef GAMEQC
    ATTRIB(Rotfish, m_model, Model, MDL_MON_ROTFISH);
#endif
    ATTRIB(Rotfish, netname, string, "rotfish");
    ATTRIB(Rotfish, monster_name, string, "Rotfish");
ENDCLASS(Rotfish)

REGISTER_MONSTER(ROTFISH, NEW(Rotfish)) {
#ifdef GAMEQC
    this.mr_precache(this);
#endif
}

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

AUTOCVAR(g_monster_rotfish_health, int, 30, "");
AUTOCVAR(g_monster_rotfish_damageforcescale, float, 0.8, "");
AUTOCVAR(g_monster_rotfish_attack_melee_damage, float, 20, "");
AUTOCVAR(g_monster_rotfish_attack_melee_delay, float, 1.7, "");
//AUTOCVAR(g_monster_rotfish_attack_range, float, 80, "");
AUTOCVAR(g_monster_rotfish_speed_stop, float, 100, "");
AUTOCVAR(g_monster_rotfish_speed_run, float, 100, "");
AUTOCVAR(g_monster_rotfish_speed_walk, float, 80, "");

/*
const float rotfish_anim_attack = 0;
const float rotfish_anim_death  = 1;
const float rotfish_anim_swim   = 2;
const float rotfish_anim_pain   = 3;
*/

bool M_Rotfish_Attack(int attack_type, entity actor, entity targ, .entity weaponentity)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			return Monster_Attack_Melee(actor, targ, (autocvar_g_monster_rotfish_attack_melee_damage), actor.anim_melee, actor.attack_range, (autocvar_g_monster_rotfish_attack_melee_delay), DEATH_MONSTER_ROTFISH_MELEE.m_id, true);
		}
		case MONSTER_ATTACK_RANGED:
		{
			// rotfish has no ranged attack yet
			return false;
		}
	}

	return false;
}

spawnfunc(monster_rotfish) { Monster_Spawn(this, true, MON_ROTFISH.monsterid); }
spawnfunc(monster_fish) { Monster_Spawn(this, true, MON_ROTFISH.monsterid); }

#endif // SVQC

		#ifdef SVQC
		METHOD(Rotfish, mr_think, bool(Monster thismon, entity actor))
		{
			return true;
		}
		METHOD(Rotfish, mr_pain, float(Monster thismon, entity actor, float damage_take, entity attacker, float deathtype))
		{
			actor.pain_finished = 0.8;
			setanim(actor, actor.anim_pain1, true, true, false);
			return damage_take;
		}
		METHOD(Rotfish, mr_death, bool(Monster thismon, entity actor))
		{
			setanim(actor, actor.anim_die1, false, true, true);
			return true;
		}
		#endif
		#ifdef GAMEQC
		METHOD(Rotfish, mr_anim, bool(Monster thismon, entity actor))
		{
			vector none = '0 0 0';
			actor.anim_die1 = animfixfps(actor, '1 1 0.5', none); // 2 seconds
			actor.anim_walk = animfixfps(actor, '2 1 1', none);
			actor.anim_idle = animfixfps(actor, '2 1 1', none);
			actor.anim_pain1 = animfixfps(actor, '3 1 2', none); // 0.5 seconds
			actor.anim_melee = animfixfps(actor, '0 1 5', none); // analyze models and set framerate
			actor.anim_run = animfixfps(actor, '2 1 1', none);

			return true;
		}
		#endif
		#ifdef SVQC
		.float speed;
		METHOD(Rotfish, mr_setup, bool(Monster thismon, entity actor))
		{
			if(!actor.health) actor.health = (autocvar_g_monster_rotfish_health);
			if(!actor.speed) { actor.speed = (autocvar_g_monster_rotfish_speed_walk); }
			if(!actor.speed2) { actor.speed2 = (autocvar_g_monster_rotfish_speed_run); }
			if(!actor.stopspeed) { actor.stopspeed = (autocvar_g_monster_rotfish_speed_stop); }
			if(!actor.damageforcescale) { actor.damageforcescale = (autocvar_g_monster_rotfish_damageforcescale); }

			//actor.monster_loot = ITEM_HealthBig;
			actor.monster_attackfunc = M_Rotfish_Attack;

			return true;
		}
		METHOD(Rotfish, mr_precache, bool(Monster thismon))
		{
			return true;
		}
		#endif

#endif
