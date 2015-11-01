
#ifndef ROTFISH_H
#define ROTFISH_H

#ifndef MENUQC
MODEL(MON_ROTFISH, M_Model("fish.mdl"));

MSG_INFO_NOTIF(1, INFO_DEATH_SELF_MON_ROTFISH_MELEE,            	2, 1, "s1 s2loc spree_lost", "s1",      	"notify_death",         			_("^BG%s^K1 was chopped into bits by an Ogre%s%s"), "")
MSG_MULTI_NOTIF(1, DEATH_SELF_MON_ROTFISH_MELEE,                  	NO_MSG,        								INFO_DEATH_SELF_MON_ROTFISH_MELEE,  CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_ROTFISH_MELEE,            				DEATH_SELF_MON_ROTFISH_MELEE,            	DEATH_MURDER_MONSTER,           	"monster")
#endif

CLASS(Rotfish, Monster)
    ATTRIB(Rotfish, spawnflags, int, MONSTER_SIZE_QUAKE | MON_FLAG_MELEE | MONSTER_TYPE_SWIM);
    ATTRIB(Rotfish, mins, vector, '-20 -20 -31');
    ATTRIB(Rotfish, maxs, vector, '20 20 20');
#ifndef MENUQC
    ATTRIB(Rotfish, m_model, Model, MDL_MON_ROTFISH);
#endif
    ATTRIB(Rotfish, netname, string, "rotfish");
    ATTRIB(Rotfish, monster_name, string, _("Rotfish"));
ENDCLASS(Rotfish)

REGISTER_MONSTER(ROTFISH, NEW(Rotfish)) {
#ifndef MENUQC
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
AUTOCVAR(g_monster_rotfish_attack_range, float, 80, "");
AUTOCVAR(g_monster_rotfish_speed_stop, float, 100, "");
AUTOCVAR(g_monster_rotfish_speed_run, float, 100, "");
AUTOCVAR(g_monster_rotfish_speed_walk, float, 80, "");

/*
const float rotfish_anim_attack = 0;
const float rotfish_anim_death  = 1;
const float rotfish_anim_swim   = 2;
const float rotfish_anim_pain   = 3;
*/

float M_Rotfish_Attack(float attack_type, entity targ)
{SELFPARAM();
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			return Monster_Attack_Melee(self.enemy, (autocvar_g_monster_rotfish_attack_melee_damage), self.anim_melee, self.attack_range, (autocvar_g_monster_rotfish_attack_melee_delay), DEATH_MONSTER_ROTFISH_MELEE.m_id, true);
		}
		case MONSTER_ATTACK_RANGED:
		{
			// rotfish has no ranged attack yet
			return false;
		}
	}

	return false;
}

spawnfunc(monster_rotfish) { Monster_Spawn(MON_ROTFISH.monsterid); }
spawnfunc(monster_fish) { Monster_Spawn(MON_ROTFISH.monsterid); }

#endif // SVQC

		#ifdef SVQC
		METHOD(Rotfish, mr_think, bool(Monster thismon))
		{
			return true;
		}
		METHOD(Rotfish, mr_pain, bool(Monster thismon))
		{
			self.pain_finished = 0.8;
			setanim(self, self.anim_pain1, true, true, false);
			return true;
		}
		METHOD(Rotfish, mr_death, bool(Monster thismon))
		{
			SELFPARAM();
			setanim(self, self.anim_die1, false, true, true);
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Rotfish, mr_anim, bool(Monster thismon))
		{
			SELFPARAM();
			vector none = '0 0 0';
			self.anim_die1 = animfixfps(self, '1 1 0.5', none); // 2 seconds
			self.anim_walk = animfixfps(self, '2 1 1', none);
			self.anim_idle = animfixfps(self, '2 1 1', none);
			self.anim_pain1 = animfixfps(self, '3 1 2', none); // 0.5 seconds
			self.anim_melee = animfixfps(self, '0 1 5', none); // analyze models and set framerate
			self.anim_run = animfixfps(self, '2 1 1', none);

			return true;
		}
		#endif
		#ifdef SVQC
		.float speed;
		//spawnfunc(item_health_large);
		METHOD(Rotfish, mr_setup, bool(Monster thismon))
		{
			SELFPARAM();
			if(!self.health) self.health = (autocvar_g_monster_rotfish_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_rotfish_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_rotfish_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_rotfish_speed_stop); }
			if(!self.damageforcescale) { self.damageforcescale = (autocvar_g_monster_rotfish_damageforcescale); }

			//self.monster_loot = spawnfunc_item_health_large;
			self.monster_attackfunc = M_Rotfish_Attack;

			return true;
		}
		METHOD(Rotfish, mr_precache, bool(Monster thismon))
		{
			return true;
		}
		#endif

#endif
