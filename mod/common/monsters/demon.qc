#ifndef DEMON_H
#define DEMON_H

#ifndef MENUQC
MODEL(MON_DEMON, M_Model("demon.mdl"));

MSG_INFO_NOTIF(1, INFO_DEATH_SELF_MON_DEMON_JUMP,             	2, 1, "s1 s2loc spree_lost", "s1",      "notify_death",         			_("^BG%s^K1 was pounced on by a Demon%s%s"), "")
MSG_MULTI_NOTIF(1, DEATH_SELF_MON_DEMON_JUMP,                 	NO_MSG,        							INFO_DEATH_SELF_MON_DEMON_JUMP,   	CENTER_DEATH_SELF_MONSTER)
REGISTER_DEATHTYPE(MONSTER_DEMON_JUMP,            				DEATH_SELF_MON_DEMON_JUMP,            	DEATH_MURDER_MONSTER,           	"monster")

MSG_INFO_NOTIF(1, INFO_DEATH_SELF_MON_DEMON_MELEE,            	2, 1, "s1 s2loc spree_lost", "s1",      "notify_death",         			_("^BG%s^K1 was eviscerated by a Demon%s%s"), "")
MSG_MULTI_NOTIF(1, DEATH_SELF_MON_DEMON_MELEE,                  NO_MSG,        							INFO_DEATH_SELF_MON_DEMON_MELEE,     CENTER_DEATH_SELF_MONSTER)
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
    ATTRIB(Demon, monster_name, string, _("Demon"));
ENDCLASS(Demon)

REGISTER_MONSTER(DEMON, NEW(Demon)) {
#ifndef MENUQC
    this.mr_precache(this);
#endif
}

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

float autocvar_g_monster_demon_health = 350;
float autocvar_g_monster_demon_damageforcescale = 0.35;
float autocvar_g_monster_demon_attack_melee_damage = 50;
float autocvar_g_monster_demon_attack_melee_delay = 1.2;
float autocvar_g_monster_demon_attack_leap_damage = 50;
float autocvar_g_monster_demon_attack_leap_force = 300;
float autocvar_g_monster_demon_attack_leap_speed = 700;
float autocvar_g_monster_demon_attack_leap_delay = 0.7;
float autocvar_g_monster_demon_attack_leap_mindist = 400;
float autocvar_g_monster_demon_speed_stop = 100;
float autocvar_g_monster_demon_speed_run = 300;
float autocvar_g_monster_demon_speed_walk = 95;

/*
const float demon_anim_stand	= 0;
const float demon_anim_walk		= 1;
const float demon_anim_run		= 2;
const float demon_anim_leap		= 3;
const float demon_anim_pain		= 4;
const float demon_anim_death	= 5;
const float demon_anim_attack	= 6;
*/

void M_Demon_Attack_Leap_Touch()
{
	if (self.health <= 0)
		return;

	vector angles_face;

	if(other.takedamage)
	{
		angles_face = vectoangles(self.moveto - self.origin);
		angles_face = normalize(angles_face) * (autocvar_g_monster_demon_attack_leap_force);
		Damage(other, self, self, (autocvar_g_monster_demon_attack_leap_damage) * MONSTER_SKILLMOD(self), DEATH_MONSTER_DEMON_JUMP.m_id, other.origin, angles_face);
		self.touch = Monster_Touch; // instantly turn it off to stop damage spam
		self.state = 0;
	}

	if (trace_dphitcontents)
	{
		self.state = 0;
		self.touch = Monster_Touch;
	}
}

bool M_Demon_Attack(int attack_type, entity targ)
{SELFPARAM();
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			return Monster_Attack_Melee(self.enemy, (autocvar_g_monster_demon_attack_melee_damage), self.anim_melee, self.attack_range, (autocvar_g_monster_demon_attack_melee_delay), DEATH_MONSTER_DEMON_MELEE.m_id, true);
		}
		case MONSTER_ATTACK_RANGED:
		{
			if(vlen(self.enemy.origin - self.origin) <= autocvar_g_monster_demon_attack_leap_mindist) { return false; }
			makevectors(self.angles);
			return Monster_Attack_Leap(self.anim_shoot, M_Demon_Attack_Leap_Touch, v_forward * (autocvar_g_monster_demon_attack_leap_speed) + '0 0 200', (autocvar_g_monster_demon_attack_leap_delay));
		}
	}

	return false;
}

spawnfunc(monster_demon) { Monster_Spawn(MON_DEMON.monsterid); }
spawnfunc(monster_demon1) { Monster_Spawn(MON_DEMON.monsterid); }

#endif // SVQC

		#ifdef SVQC
		METHOD(Demon, mr_think, bool(Monster thismon))
		{
			return true;
		}
		METHOD(Demon, mr_pain, bool(Monster thismon))
		{
			self.pain_finished = time + 0.5;
			setanim(self, self.anim_pain1, true, true, false);
			return true;
		}
		METHOD(Demon, mr_death, bool(Monster thismon))
		{
			SELFPARAM();
			setanim(self, self.anim_die1, false, true, true);
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Demon, mr_anim, bool(Monster thismon))
		{
			SELFPARAM();
			vector none = '0 0 0';
			self.anim_die1 = animfixfps(self, '5 1 0.5', none); // 2 seconds
			self.anim_walk = animfixfps(self, '1 1 1', none);
			self.anim_idle = animfixfps(self, '0 1 1', none);
			self.anim_pain1 = animfixfps(self, '4 1 2', none); // 0.5 seconds
			self.anim_melee = animfixfps(self, '6 1 5', none); // analyze models and set framerate
			self.anim_shoot = animfixfps(self, '3 1 5', none); // analyze models and set framerate
			self.anim_run = animfixfps(self, '2 1 1', none);

			return true;
		}
		#endif
		#ifdef SVQC
		.float speed;
		spawnfunc(item_health_large);
		METHOD(Demon, mr_setup, bool(Monster thismon))
		{
			SELFPARAM();
			if(!self.health) self.health = (autocvar_g_monster_demon_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_demon_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_demon_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_demon_speed_stop); }
			if(!self.damageforcescale) { self.damageforcescale = (autocvar_g_monster_demon_damageforcescale); }

			self.monster_loot = spawnfunc_item_health_large;
			self.monster_attackfunc = M_Demon_Attack;

			return true;
		}
		METHOD(Demon, mr_precache, bool(Monster thismon))
		{
			return true;
		}
		#endif

#endif
