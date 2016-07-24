#ifndef SPAWNER_H
#define SPAWNER_H

#ifndef MENUQC
MODEL(MON_SPAWNER, M_Model("spawner.bsp"));
#endif

CLASS(Spawner, Monster)
	ATTRIB(Spawner, spawnflags, int, MON_FLAG_MELEE | MON_FLAG_RANGED);
    ATTRIB(Spawner, mins, vector, '-32 -32 -24');
    ATTRIB(Spawner, maxs, vector, '32 32 32');
#ifndef MENUQC
    ATTRIB(Spawner, m_model, Model, MDL_MON_SPAWNER);
#endif
    ATTRIB(Spawner, netname, string, "spawner");
    ATTRIB(Spawner, monster_name, string, "Spawner");
ENDCLASS(Spawner)

REGISTER_MONSTER(SPAWNER, NEW(Spawner)) {
#ifndef MENUQC
    this.mr_precache(this);
#endif
}

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

AUTOCVAR(g_monster_spawner_health, int, 400, "");
AUTOCVAR(g_monster_spawner_spawn_delay, float, 5, "");
AUTOCVAR(g_monster_spawner_spawn_max, int, 10, "");
AUTOCVAR(g_monster_spawner_spawn_burst, int, 4, "");
AUTOCVAR(g_monster_spawner_spawn_range, float, 600, "");
AUTOCVAR(g_monster_spawner_spawn_default, string, "zombie");

.int spawner_count;
.string spawner_mob;

bool M_Spawner_SpawnMonsters(entity this)
{
	entity e = spawnmonster(this.spawner_mob, 0, this, this, this.origin, false, false, 1);

	vector spawn_extra_size = '1 1 1' * autocvar_g_monster_spawner_spawn_range;

	// a nice side effect of this may be the smoke particle that plays at the spawner's location
	if(!MoveToRandomLocationWithinBounds(e, this.absmin - spawn_extra_size, this.absmax + spawn_extra_size, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, 
		DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 512, 256))
	{
		Monster_Remove(e); // too bad
		LOG_INFO("Fail!\n");
		return false;
	}

	return true;
}

bool M_Spawner_Attack(int attack_type, entity actor, entity targ)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			if(actor.spawner_count >= autocvar_g_monster_spawner_spawn_max)
				return false;

			for(int i = 0; i <= autocvar_g_monster_spawner_spawn_burst; ++i)
			{
				if(M_Spawner_SpawnMonsters(actor))
					++actor.spawner_count;
				if(actor.spawner_count >= autocvar_g_monster_spawner_spawn_max)
					break;
			}
			
			actor.attack_finished_single[0] = time + (autocvar_g_monster_spawner_spawn_delay);
			return true;
		}
	}

	return false;
}

spawnfunc(monster_spawner) { Monster_Spawn(this, MON_SPAWNER.monsterid); }

		METHOD(Spawner, mr_think, bool(Monster thismon, entity actor))
		{
			thismon.state = MONSTER_ATTACK_MELEE; // always use this state
			return true;
		}

		METHOD(Spawner, mr_death, bool(Monster thismon, entity actor))
		{
			// explode
			return true;
		}

		METHOD(Spawner, mr_setup, bool(Monster thismon, entity actor))
		{
			if(!actor.spawner_mob || actor.spawner_mob == "") { actor.spawner_mob = autocvar_g_monster_spawner_spawn_default; }
			if(!actor.health) actor.health = (autocvar_g_monster_spawner_health);
			actor.speed = actor.speed2 = actor.stopspeed = actor.damageforcescale = 0;

			actor.monster_attackfunc = M_Spawner_Attack;

			set_movetype(actor, MOVETYPE_NONE);
			actor.monster_moveflags = 4;
			actor.spawner_count = 0;

			LOG_INFO("Setting up spawner with spawner_mob", actor.spawner_mob, "\n");

			return true;
		}

#endif // SVQC

#endif
