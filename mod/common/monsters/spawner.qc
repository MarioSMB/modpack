#ifndef SPAWNER_H
#define SPAWNER_H

#ifdef GAMEQC
MODEL(MON_SPAWNER, M_Model("spawner.bsp"));
#endif

CLASS(Spawner, Monster)
	ATTRIB(Spawner, spawnflags, int, MON_FLAG_HIDDEN);
    ATTRIB(Spawner, m_mins, vector, '-32 -32 -24');
    ATTRIB(Spawner, m_maxs, vector, '32 32 32');
#ifdef GAMEQC
    ATTRIB(Spawner, m_model, Model, MDL_MON_SPAWNER);
#endif
    ATTRIB(Spawner, netname, string, "spawner");
    ATTRIB(Spawner, monster_name, string, "Spawner");
ENDCLASS(Spawner)

REGISTER_MONSTER(SPAWNER, NEW(Spawner));

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

AUTOCVAR(g_monster_spawner_health, int, 400, "");
AUTOCVAR(g_monster_spawner_checkrange, float, 700, "");
AUTOCVAR(g_monster_spawner_spawn_delay, float, 5, "");
AUTOCVAR(g_monster_spawner_spawn_max, int, 10, "");
AUTOCVAR(g_monster_spawner_spawn_burst, int, 4, "");
AUTOCVAR(g_monster_spawner_spawn_range, float, 600, "");
AUTOCVAR(g_monster_spawner_spawn_default, string, "zombie");

bool M_Spawner_SpawnMonsters(entity this)
{
	entity e = spawnmonster(spawn(), this.spawnmob, 0, this, this, this.origin, false, false, 1);

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

int M_Spawner_CountMonsters(entity this)
{
	int found = 0;
	IL_EACH(g_monsters, it.realowner == this,
	{
		++found;
	});

	return found;
}

void M_Spawner_TrySpawning(entity this)
{
	int mymobs = M_Spawner_CountMonsters(this);

	if(mymobs >= autocvar_g_monster_spawner_spawn_max)
		return;

	for(int j = 0; j <= autocvar_g_monster_spawner_spawn_burst; ++j)
	{
		if(M_Spawner_SpawnMonsters(this))
			++mymobs;
		if(mymobs >= autocvar_g_monster_spawner_spawn_max)
			break;
	}
}

spawnfunc(monster_spawner) { Monster_Spawn(this, true, MON_SPAWNER.monsterid); }

METHOD(Spawner, mr_think, bool(Monster thismon, entity actor))
{
	if(time > actor.spawner_delay)
	{
		int mymobs = M_Spawner_CountMonsters(actor);
		if(mymobs >= autocvar_g_monster_spawner_spawn_max)
		{
			actor.spawner_delay = time + 3; // check every few seconds
			return true;
		}

		bool found_player = false;
		FOREACH_CLIENT(IS_PLAYER(it),
		{
			if(vdist(it.origin - actor.origin, <, autocvar_g_monster_spawner_checkrange))
			{
				found_player = true;
				break;
			}
		});
		if(found_player)
		{
			M_Spawner_TrySpawning(actor);
			actor.spawner_delay = time + autocvar_g_monster_spawner_spawn_delay;
		}
		else
			actor.spawner_delay = time + 3; // check every few seconds
	}
	return true;
}

METHOD(Spawner, mr_death, bool(Monster thismon, entity actor))
{
	// explode
	return true;
}

METHOD(Spawner, mr_setup, bool(Monster thismon, entity actor))
{
	if(!actor.spawnmob || actor.spawnmob == "") { actor.spawnmob = autocvar_g_monster_spawner_spawn_default; }
	if(!actor.health) actor.health = (autocvar_g_monster_spawner_health);
	actor.speed = actor.speed2 = actor.stopspeed = actor.damageforcescale = 0;

	set_movetype(actor, MOVETYPE_NONE);
	actor.monster_moveflags = 4;

	LOG_INFO("Setting up spawner with spawnmob", actor.spawnmob, "\n");

	return true;
}

#endif // SVQC

#endif
