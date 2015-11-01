#ifndef ROTTWEILER_H
#define ROTTWEILER_H

#ifndef MENUQC
MODEL(MON_ROTTWEILER, M_Model("dog.mdl"));

MSG_INFO_NOTIF(1, INFO_DEATH_SELF_MON_ROTTWEILER_MELEE,            	2, 1, "s1 s2loc spree_lost", "s1",      "notify_death",         					_("^BG%s^K1 was mauled by a Rottweiler%s%s"), "")
MSG_MULTI_NOTIF(1, DEATH_SELF_MON_ROTTWEILER_MELEE,                 NO_MSG,        							INFO_DEATH_SELF_MON_ROTTWEILER_MELEE,     	CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_ROTTWEILER_MELEE,            			DEATH_SELF_MON_ROTTWEILER_MELEE,        DEATH_MURDER_MONSTER,           			"monster")
#endif

CLASS(Rottweiler, Monster)
    ATTRIB(Rottweiler, spawnflags, int, MONSTER_SIZE_QUAKE | MON_FLAG_MELEE | MON_FLAG_RIDE);
    ATTRIB(Rottweiler, mins, vector, '-16 -16 -24');
    ATTRIB(Rottweiler, maxs, vector, '16 16 12');
#ifndef MENUQC
    ATTRIB(Rottweiler, m_model, Model, MDL_MON_ROTTWEILER);
#endif
    ATTRIB(Rottweiler, netname, string, "rottweiler");
    ATTRIB(Rottweiler, monster_name, string, _("Rottweiler"));
ENDCLASS(Rottweiler)

REGISTER_MONSTER(ROTTWEILER, NEW(Rottweiler)) {
#ifndef MENUQC
    this.mr_precache(this);
#endif
}

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

float autocvar_g_monster_rottweiler_health;
float autocvar_g_monster_rottweiler_damageforcescale = 0.7;
float autocvar_g_monster_rottweiler_attack_melee_damage;
float autocvar_g_monster_rottweiler_attack_melee_delay;
float autocvar_g_monster_rottweiler_speed_stop;
float autocvar_g_monster_rottweiler_speed_run;
float autocvar_g_monster_rottweiler_speed_walk;

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

bool M_Rottweiler_Attack(int attack_type, entity targ)
{SELFPARAM();
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			return Monster_Attack_Melee(self.enemy, (autocvar_g_monster_rottweiler_attack_melee_damage), ((random() >= 0.5) ? self.anim_melee1 : self.anim_melee2), self.attack_range, (autocvar_g_monster_rottweiler_attack_melee_delay), DEATH_MONSTER_ROTTWEILER_MELEE.m_id, true);
		}
		case MONSTER_ATTACK_RANGED:
		{
			// TODO: pounce!
			return false;
		}
	}

	return false;
}

spawnfunc(monster_rottweiler) { Monster_Spawn(MON_ROTTWEILER.monsterid); }
spawnfunc(monster_dog) { Monster_Spawn(MON_ROTTWEILER.monsterid); }

#endif // SVQC

		#ifdef SVQC
		METHOD(Rottweiler, mr_think, bool(Monster thismon))
		{
			return true;
		}
		METHOD(Rottweiler, mr_pain, bool(Monster thismon))
		{
			if(random() <= 0.3)
			{
				self.pain_finished = time + 1.5;
				setanim(self, self.anim_pain1, true, true, false);
			}
			return true;
		}
		METHOD(Rottweiler, mr_death, bool(Monster thismon))
		{
			SELFPARAM();
			setanim(self, ((random() > 0.5) ? self.anim_die1 : self.anim_die2), false, true, true);
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Rottweiler, mr_anim, bool(Monster thismon))
		{
			SELFPARAM();
			vector none = '0 0 0';
			self.anim_die1 = animfixfps(self, '5 1 0.5', none); // 2 seconds
			self.anim_die2 = animfixfps(self, '1 1 0.5', none); // 2 seconds
			self.anim_walk = animfixfps(self, '2 1 1', none);
			self.anim_idle = animfixfps(self, '7 1 1', none);
			self.anim_pain1 = animfixfps(self, '4 1 2', none); // 0.5 seconds
			self.anim_melee1 = animfixfps(self, '0 1 5', none); // analyze models and set framerate
			self.anim_melee2 = animfixfps(self, '3 1 5', none); // analyze models and set framerate
			self.anim_shoot = animfixfps(self, '6 1 5', none); // analyze models and set framerate
			self.anim_run = animfixfps(self, '5 1 1', none);

			return true;
		}
		#endif
		#ifdef SVQC
		.float speed;
		spawnfunc(item_health_small);
		METHOD(Rottweiler, mr_setup, bool(Monster thismon))
		{
			SELFPARAM();
			if(!self.health) self.health = (autocvar_g_monster_rottweiler_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_rottweiler_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_rottweiler_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_rottweiler_speed_stop); }
			if(!self.damageforcescale) { self.damageforcescale = (autocvar_g_monster_rottweiler_damageforcescale); }

			self.monster_loot = spawnfunc_item_health_small;

			return true;
		}
		METHOD(Rottweiler, mr_precache, bool(Monster thismon))
		{
			return true;
		}
		#endif

#endif
