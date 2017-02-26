#ifndef TARBABY_H
#define TARBABY_H

#ifndef MENUQC
MODEL(MON_TARBABY, M_Model("tarbaby.mdl"));
#endif

CLASS(Tarbaby, Monster)
    ATTRIB(Tarbaby, spawnflags, int, MONSTER_SIZE_QUAKE | MON_FLAG_HIDDEN | MON_FLAG_MELEE);
    ATTRIB(Tarbaby, mins, vector, '-16 -16 -24');
    ATTRIB(Tarbaby, maxs, vector, '16 16 40');
#ifndef MENUQC
    ATTRIB(Tarbaby, m_model, Model, MDL_MON_TARBABY);
#endif
    ATTRIB(Tarbaby, netname, string, "spawn");
    ATTRIB(Tarbaby, monster_name, string, "Tarbaby");
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
//AUTOCVAR(g_monster_spawn_damageforcescale, float, 0.2, "");
AUTOCVAR(g_monster_spawn_attack_explode_damage, float, 120, "");
AUTOCVAR(g_monster_spawn_attack_explode_radius, float, 100, "");
AUTOCVAR(g_monster_spawn_attack_leap_speed, float, 600, "");
AUTOCVAR(g_monster_spawn_attack_leap_delay, float, 0.5, "");
AUTOCVAR(g_monster_spawn_speed_stop, float, 50, "");
AUTOCVAR(g_monster_spawn_speed_run, float, 70, "");
AUTOCVAR(g_monster_spawn_speed_walk, float, 50, "");

void M_Tarbaby_Attack_Explode(entity this, entity directhitentity)
{
	setanim(this, this.anim_die1, false, true, true);

	this.event_damage = func_null;

	sound(this, CH_SHOTS, SND_GRENADE_IMPACT, VOL_BASE, ATTEN_NORM);

	Send_Effect(EFFECT_EXPLOSION_SMALL, this.origin, '0 0 0', 1);
	RadiusDamage (this, this, (autocvar_g_monster_spawn_attack_explode_damage), (autocvar_g_monster_spawn_attack_explode_damage) * 0.5, (autocvar_g_monster_spawn_attack_explode_radius), NULL, NULL, 50, DEATH_MONSTER_MAGE.m_id, directhitentity);

	Monster_Remove(this);
}

void M_Tarbaby_Attack_Leap_Touch(entity this, entity toucher)
{
	if (this.health <= 0)
		return;

	if(toucher.takedamage)
		M_Tarbaby_Attack_Explode(this, toucher);

	if (trace_dphitcontents)
	{
		this.state = 0;
		settouch(this, Monster_Touch);
	}
}

bool M_Tarbaby_Attack(int attack_type, entity actor, entity targ, .entity weaponentity)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			M_Tarbaby_Attack_Explode(actor, NULL); // we don't count this as a direct hit, despite monster being close
			return true;
		}
		case MONSTER_ATTACK_RANGED:
		{
			makevectors(actor.angles);
			return Monster_Attack_Leap(actor, actor.anim_jump, M_Tarbaby_Attack_Leap_Touch, v_forward * (autocvar_g_monster_spawn_attack_leap_speed) + '0 0 200', (autocvar_g_monster_spawn_attack_leap_delay));
		}
	}

	return false;
}

spawnfunc(monster_tarbaby) { Monster_Spawn(this, true, MON_TARBABY.monsterid); }
#endif // SVQC

		#ifdef SVQC
		METHOD(Tarbaby, mr_think, bool(Tarbaby thismon, entity actor))
		{
			return true;
		}
		METHOD(Tarbaby, mr_death, bool(Tarbaby thismon, entity actor))
		{
			M_Tarbaby_Attack_Explode(actor, NULL);
			return true;
		}
		#endif
		#ifndef MENUQC
		METHOD(Tarbaby, mr_anim, bool(Tarbaby thismon, entity actor))
		{
			vector none = '0 0 0';
			actor.anim_walk = animfixfps(actor, '0 2.4 1', none);
			actor.anim_idle = animfixfps(actor, '0 2.4 1', none);
			actor.anim_jump = animfixfps(actor, '2 0.5 1', none); // analyze models and set framerate
			actor.anim_run = animfixfps(actor, '1 2.4 1', none);
			actor.anim_die1 = animfixfps(actor, '4 0.1 1', none);
			//actor.anim_fly = animfixfps(actor, '8 1 1', none);

			return true;
		}
		#endif
		#ifdef SVQC
		METHOD(Tarbaby, mr_setup, bool(Tarbaby thismon, entity actor))
		{
			if(!actor.health) actor.health = (autocvar_g_monster_spawn_health);
			if(!actor.speed) { actor.speed = (autocvar_g_monster_spawn_speed_walk); }
			if(!actor.speed2) { actor.speed2 = (autocvar_g_monster_spawn_speed_run); }
			if(!actor.stopspeed) { actor.stopspeed = (autocvar_g_monster_spawn_speed_stop); }

			actor.monster_loot = ITEM_Rockets;
			actor.monster_attackfunc = M_Tarbaby_Attack;
			actor.damageforcescale = 0.01; // no push while spawning

			return true;
		}
		METHOD(Tarbaby, mr_precache, bool(Tarbaby thismon))
		{
			return true;
		}
		#endif

#endif
