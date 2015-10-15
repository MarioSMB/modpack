#ifndef TARBABY_H
#define TARBABY_H

#ifndef MENUQC
MODEL(MON_TARBABY, "models/monsters/tarbaby.mdl");
#endif

CLASS(Tarbaby, Monster)
    ATTRIB(Tarbaby, spawnflags, int, MON_FLAG_MELEE);
    ATTRIB(Tarbaby, mins, vector, '-16 -16 -24');
    ATTRIB(Tarbaby, maxs, vector, '16 16 40');
#ifndef MENUQC
    ATTRIB(Tarbaby, m_model, Model, MDL_MON_TARBABY);
#endif
    ATTRIB(Tarbaby, netname, string, "spawn");
    ATTRIB(Tarbaby, monster_name, string, _("Tarbaby"));
ENDCLASS(Tarbaby)

REGISTER_MONSTER(TARBABY, NEW(Tarbaby)) {
#ifndef MENUQC
    this.mr_precache(this);
#endif
}

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC
AUTOCVAR(g_monster_spawn_health, float, 80, "");
AUTOCVAR(g_monster_spawn_damageforcescale, float, 0.2, "");
AUTOCVAR(g_monster_spawn_attack_explode_damage, float, 120, "");
AUTOCVAR(g_monster_spawn_attack_explode_radius, float, 100, "");
AUTOCVAR(g_monster_spawn_attack_leap_speed, float, 600, "");
AUTOCVAR(g_monster_spawn_attack_leap_delay, float, 0.5, "");
AUTOCVAR(g_monster_spawn_speed_stop, float, 50, "");
AUTOCVAR(g_monster_spawn_speed_run, float, 70, "");
AUTOCVAR(g_monster_spawn_speed_walk, float, 50, "");

void M_Tarbaby_Attack_Explode(entity this)
{
	setanim(this, this.anim_die1, false, true, true);

	this.event_damage = func_null;

	sound(this, CH_SHOTS, SND_GRENADE_IMPACT, VOL_BASE, ATTEN_NORM);

	Send_Effect(EFFECT_EXPLOSION_SMALL, this.origin, '0 0 0', 1);
	RadiusDamage (this, this, (autocvar_g_monster_spawn_attack_explode_damage), (autocvar_g_monster_spawn_attack_explode_damage) * 0.5, (autocvar_g_monster_spawn_attack_explode_radius), world, world, 50, DEATH_MONSTER_MAGE.m_id, other);

	Monster_Remove(this);
}

void M_Tarbaby_Attack_Leap_Touch()
{SELFPARAM();
	if (self.health <= 0)
		return;

	if(other.takedamage)
		M_Tarbaby_Attack_Explode(self);

	if (trace_dphitcontents)
	{
		self.state = 0;
		self.touch = Monster_Touch;
	}
}

float M_Tarbaby_Attack(float attack_type, entity targ)
{SELFPARAM();
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			M_Tarbaby_Attack_Explode(self);
			return true;
		}
		case MONSTER_ATTACK_RANGED:
		{
			makevectors(self.angles);
			return Monster_Attack_Leap(self.anim_jump, M_Tarbaby_Attack_Leap_Touch, v_forward * (autocvar_g_monster_spawn_attack_leap_speed) + '0 0 200', (autocvar_g_monster_spawn_attack_leap_delay));
		}
	}

	return false;
}

spawnfunc(monster_tarbaby) { Monster_Spawn(MON_TARBABY.monsterid); }
#endif // SVQC

		#ifdef SVQC
		METHOD(Tarbaby, mr_think, bool(Tarbaby thismon))
		{
			return true;
		}
		METHOD(Tarbaby, mr_pain, bool(Tarbaby thismon))
		{
			return true;
		}
		METHOD(Tarbaby, mr_death, bool(Tarbaby thismon))
		{
			SELFPARAM();

			M_Tarbaby_Attack_Explode(self);
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Tarbaby, mr_anim, bool(Tarbaby thismon))
		{
			SELFPARAM();
			vector none = '0 0 0';
			self.anim_walk = animfixfps(self, '0 2.4 1', none);
			self.anim_idle = animfixfps(self, '0 2.4 1', none);
			self.anim_jump = animfixfps(self, '2 0.5 1', none); // analyze models and set framerate
			self.anim_run = animfixfps(self, '1 2.4 1', none);
			self.anim_die1 = animfixfps(self, '4 0.1 1', none);
			//self.anim_fly = animfixfps(self, '8 1 1', none);

			return true;
		}
		#endif
		#ifdef SVQC
		METHOD(Tarbaby, mr_setup, bool(Tarbaby thismon))
		{
			if(!self.health) self.health = (autocvar_g_monster_spawn_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_spawn_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_spawn_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_spawn_speed_stop); }

			self.monster_loot = spawnfunc_item_rockets;
			self.monster_attackfunc = M_Tarbaby_Attack;
			self.damageforcescale = 0.01; // no push while spawning

			return true;
		}
		METHOD(Tarbaby, mr_precache, bool(Tarbaby thismon))
		{
			return true;
		}
		#endif

#endif
