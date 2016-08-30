float za_spawn_delay;

REGISTER_MUTATOR(za, cvar("g_za") && cvar("g_monsters") && !g_nexball && !g_invasion && !g_cts && !g_race)
{
	MUTATOR_ONADD
	{
		za_spawn_delay = time + game_starttime;
	}
}

AUTOCVAR(g_za, bool, false, _("Enable zombie apocalypse mutator"));
AUTOCVAR(g_za_max_monsters, int, 20, "");
AUTOCVAR(g_za_infect, bool, false, _("On death, players become playable monsters"));
AUTOCVAR(g_za_spawnmonster, string, "zombie", _("Spawn this type of monster, can be random or any of the mobs in 'spawnmob list'"));
AUTOCVAR(g_za_spawn_delay, float, 5, "");

.vector za_viewofs;
.float za_maxhealth;

void za_SpawnMonster()
{
	if(gameover) { return; }

	entity e = spawn(), mon;

	if(MoveToRandomMapLocation(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 1024, 256))
		mon = spawnmonster(autocvar_g_za_spawnmonster, 0, NULL, NULL, e.origin, false, false, 2);

	setthink(e, SUB_Remove);
	e.nextthink = time + 0.1;
}

void za_SetEnemy(entity player)
{
	// prefer players
	entity closest_targ = NULL;
	FOREACH_CLIENT(IS_PLAYER(it) && it != player, LAMBDA(
		if(vdist(player.origin - it.origin, <, autocvar_g_monsters_target_range))
		if(!closest_targ || vlen2(player.origin - closest_targ.origin) > vlen2(player.origin - it.origin))
			closest_targ = it;
	));

	if(!closest_targ)
	{
		IL_EACH(g_monsters, true,
		{
			if(vdist(player.origin - it.origin, <, autocvar_g_monsters_target_range))
			if(!closest_targ || vlen2(player.origin - closest_targ.origin) > vlen2(player.origin - it.origin))
				closest_targ = it;
		});
	}

	// otherwise, attempt any entity nearby
	if(!closest_targ)
	{
		FOREACH_ENTITY_FLOAT(monster_attack, true, LAMBDA(
			if(it.takedamage && it != player)
			if(vdist(player.origin - it.origin, <, autocvar_g_monsters_target_range))
			if(!closest_targ || vlen2(player.origin - closest_targ.origin) > vlen2(player.origin - it.origin))
				closest_targ = it;
		));
	}

	if(closest_targ)
		player.enemy = closest_targ;
}

MUTATOR_HOOKFUNCTION(za, FixPlayermodel)
{
	entity player = M_ARGV(2, entity);

	if(player.monsterid)
		M_ARGV(0, string) = (Monsters_from(player.monsterid)).m_model.model_str();
}

MUTATOR_HOOKFUNCTION(za, PlayerPhysics)
{
	entity player = M_ARGV(0, entity);

	if(!player.monsterid) { return; }

	entity mon = Monsters_from(player.monsterid);

	player.weapons = '0 0 0';
	PS(player).m_switchweapon = WEP_Null;
	STAT(PL_MIN, player) = mon.mins;
	STAT(PL_MAX, player) = mon.maxs;
	STAT(PL_CROUCH_MIN, player) = mon.mins;
	STAT(PL_CROUCH_MAX, player) = mon.maxs;
	STAT(PL_VIEW_OFS, player) = player.za_viewofs;
	STAT(PL_CROUCH_VIEW_OFS, player) = player.za_viewofs;
	//PHYS_JUMPVELOCITY(player) = 0;

	PHYS_MAXSPEED(player) = player.speed2;
	PHYS_MAXAIRSPEED(player) = player.speed2;
	PHYS_INPUT_BUTTON_CROUCH(player) = false;
}

MUTATOR_HOOKFUNCTION(za, PlayerPreThink)
{
	entity player = M_ARGV(0, entity);

	if(!player.monsterid || time < player.attack_finished_single[0]) { return false; }

	Monster mon = Monsters_from(player.monsterid);
	mon.mr_think(mon, player);

	if(PHYS_INPUT_BUTTON_ATCK(player))
	if(player.monster_attackfunc)
	{
		za_SetEnemy(player);
		if(player.monster_attackfunc(MONSTER_ATTACK_MELEE, player, player.enemy))
			animdecide_setaction(player, ANIMACTION_MELEE, false);
	}

	if(PHYS_INPUT_BUTTON_ATCK2(player))
	if(player.monster_attackfunc)
	{
		za_SetEnemy(player);
		if(player.monster_attackfunc(MONSTER_ATTACK_RANGED, player, player.enemy))
			animdecide_setaction(player, ANIMACTION_SHOOT, false);
	}
}

MUTATOR_HOOKFUNCTION(za, PlayerRegen)
{
	entity player = M_ARGV(0, entity);
	
	if(player.monsterid)
	if(player.za_maxhealth)
	{
		M_ARGV(9, float) = player.za_maxhealth;
		M_ARGV(10, float) = player.za_maxhealth;
	}
}

MUTATOR_HOOKFUNCTION(za, ItemTouch)
{
	entity toucher = M_ARGV(1, entity);

	if(IS_PLAYER(toucher) && toucher.monsterid)
		return MUT_ITEMTOUCH_RETURN;

	return MUT_ITEMTOUCH_CONTINUE;
}

MUTATOR_HOOKFUNCTION(za, PlayerDies)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);

	if(!IS_MONSTER(frag_attacker) || !autocvar_g_za_infect)
	{
		frag_target.monsterid = 0;
		return;
	}

	Monster mon = Monsters_from(frag_attacker.monsterid);

	frag_target.monsterid = mon.monsterid;
	frag_target.health = frag_attacker.max_health;
	frag_target.za_maxhealth = frag_attacker.max_health;
	frag_target.weapons = '0 0 0';
	frag_attacker.enemy = NULL;
	PS(frag_target).m_switchweapon = WEP_Null;
	STAT(PL_MIN, frag_target) = mon.mins;
	STAT(PL_MAX, frag_target) = mon.maxs;
	STAT(PL_CROUCH_MIN, frag_target) = mon.mins;
	STAT(PL_CROUCH_MAX, frag_target) = mon.maxs;
	frag_target.monster_attack = false;
	frag_target.speed = frag_attacker.speed;
	frag_target.speed2 = frag_attacker.speed2;
	frag_target.stopspeed = frag_attacker.stopspeed;
	STAT(PL_VIEW_OFS, frag_target) = frag_target.za_viewofs = frag_attacker.view_ofs;
	STAT(PL_CROUCH_VIEW_OFS, frag_target) = frag_attacker.view_ofs;
	frag_target.attack_range = ((frag_attacker.attack_range) ? frag_attacker.attack_range : 150);
	//frag_target.attack_range = frag_attacker.attack_range;
	frag_target.monster_attackfunc = frag_attacker.monster_attackfunc;
	setsize(frag_target, frag_attacker.mins, frag_attacker.maxs);

	if(mon.spawnflags & MONSTER_TYPE_FLY)
		set_movetype(frag_target, MOVETYPE_FLY);
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
