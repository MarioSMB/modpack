//FEATURE: Zombie Apocalypse mutator, which spawns random monsters around the map constantly

float za_spawn_delay;
AUTOCVAR(g_za, bool, false, _("Enable zombie apocalypse mutator"));

REGISTER_MUTATOR(za, autocvar_g_za && autocvar_g_monsters && !g_nexball && !g_invasion && !g_cts && !g_race)
{
	MUTATOR_ONADD
	{
		za_spawn_delay = time + game_starttime;
	}
}

AUTOCVAR(g_za_max_monsters, int, 20, "");
AUTOCVAR(g_za_spawnmonster, string, "zombie", _("Spawn this type of monster, can be random or any of the mobs in 'spawnmob list'"));
AUTOCVAR(g_za_spawn_delay, float, 5, "");

void za_SpawnMonster()
{
	if(game_stopped) { return; }

	entity e = spawn();

	if(MoveToRandomMapLocation(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 1024, 256))
	{
		e.angles = '0 0 0';
		spawnmonster(e, autocvar_g_za_spawnmonster, MON_Null, NULL, NULL, e.origin, false, false, 2);
	}
}

MUTATOR_HOOKFUNCTION(za, SV_StartFrame)
{
	if(time < za_spawn_delay || autocvar_g_za_max_monsters <= 0 || !autocvar_g_za)
		return;

	int n_monsters = 0, maxmon = autocvar_g_za_max_monsters;

	// count dead monsters too (zombies)
	IL_EACH(g_monsters, true,
	{
		++n_monsters;
	});

	while(n_monsters < maxmon)
	{
		++n_monsters;
		za_SpawnMonster();
	}

	za_spawn_delay = time + autocvar_g_za_spawn_delay;
}
