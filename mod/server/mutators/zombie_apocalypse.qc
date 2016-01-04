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
		mon = spawnmonster(autocvar_g_za_spawnmonster, 0, self, self, e.origin, false, false, 2);

	e.think = SUB_Remove_self;
	e.nextthink = time + 0.1;
}

void za_SetEnemy(entity player)
{
	// prefer players
	entity closest_targ = world;
	FOREACH_CLIENT(IS_PLAYER(it) && it != player, LAMBDA(
		if(vdist(player.origin - it.origin, <, autocvar_g_monsters_target_range))
		if(!closest_targ || vlen2(player.origin - closest_targ.origin) > vlen2(player.origin - it.origin))
			closest_targ = it;
	));

	if(!closest_targ)
	{
		FOREACH_ENTITY_FLAGS(flags, FL_MONSTER, LAMBDA(
			if(vdist(player.origin - it.origin, <, autocvar_g_monsters_target_range))
			if(!closest_targ || vlen2(player.origin - closest_targ.origin) > vlen2(player.origin - it.origin))
				closest_targ = it;
		));
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
	if(self.monsterid)
		ret_string = (get_monsterinfo(self.monsterid)).model;
	return false;
}

MUTATOR_HOOKFUNCTION(za, PlayerPhysics)
{
	if(!self.monsterid) { return false; }

	entity mon = get_monsterinfo(self.monsterid);

	self.weapons = '0 0 0';
	PS(self).m_switchweapon = WEP_Null;
	self.stat_PL_MIN = mon.mins;
	self.stat_PL_MAX = mon.maxs;
	self.stat_PL_CROUCH_MIN = mon.mins;
	self.stat_PL_CROUCH_MAX = mon.maxs;
	self.stat_PL_CROUCH_VIEW_OFS = self.za_viewofs;
	self.stat_PL_VIEW_OFS = self.za_viewofs;
	self.stat_MOVEVARS_JUMPVELOCITY = 0;

	self.stat_MOVEVARS_MAXSPEED = self.speed2;
	self.stat_MOVEVARS_MAXAIRSPEED = self.speed2;
	self.BUTTON_CROUCH = false;

	return false;
}

MUTATOR_HOOKFUNCTION(za, PlayerPreThink)
{
	if(!self.monsterid || time < self.attack_finished_single[0]) { return false; }

	Monster mon = get_monsterinfo(self.monsterid);
	mon.mr_think(mon, self);

	if(self.BUTTON_ATCK)
	if(self.monster_attackfunc)
	{
		za_SetEnemy(self);
		if(self.monster_attackfunc(MONSTER_ATTACK_MELEE, self, self.enemy))
			animdecide_setaction(self, ANIMACTION_MELEE, false);
	}

	if(self.BUTTON_ATCK2)
	if(self.monster_attackfunc)
	{
		za_SetEnemy(self);
		if(self.monster_attackfunc(MONSTER_ATTACK_RANGED, self, self.enemy))
			animdecide_setaction(self, ANIMACTION_SHOOT, false);
	}

	return false;
}

MUTATOR_HOOKFUNCTION(za, PlayerRegen)
{
	if(self.monsterid)
	if(self.za_maxhealth)
	{
		regen_health_rotstable = self.za_maxhealth;
		regen_health_stable = self.za_maxhealth;
	}
	return false;
}

MUTATOR_HOOKFUNCTION(za, ItemTouch)
{
	if(other.monsterid)
		return MUT_ITEMTOUCH_RETURN;

	return false;
}

MUTATOR_HOOKFUNCTION(za, PlayerDies)
{
	if(!IS_MONSTER(frag_attacker) || !autocvar_g_za_infect)
	{
		self.monsterid = 0;
		return false;
	}

	entity mon = get_monsterinfo(frag_attacker.monsterid);

	self.monsterid = mon.monsterid;
	self.health = frag_attacker.max_health;
	self.za_maxhealth = frag_attacker.max_health;
	self.weapons = '0 0 0';
	PS(self).m_switchweapon = WEP_Null;
	self.stat_PL_MIN = mon.mins;
	self.stat_PL_MAX = mon.maxs;
	self.stat_PL_CROUCH_MIN = mon.mins;
	self.stat_PL_CROUCH_MAX = mon.maxs;
	self.monster_attack = false;
	self.speed = frag_attacker.speed;
	self.speed2 = frag_attacker.speed2;
	self.stopspeed = frag_attacker.stopspeed;
	self.view_ofs = self.za_viewofs = frag_attacker.view_ofs;
	self.attack_range = ((frag_attacker.attack_range) ? frag_attacker.attack_range : 150);
	//self.attack_range = frag_attacker.attack_range;
	self.monster_attackfunc = frag_attacker.monster_attackfunc;
	setsize(self, frag_attacker.mins, frag_attacker.maxs);

	return false;
}

MUTATOR_HOOKFUNCTION(za, SV_StartFrame)
{
	if(time < za_spawn_delay || autocvar_g_za_max_monsters <= 0 || !autocvar_g_za)
		return false;

	float n_monsters = 0, maxmon = autocvar_g_za_max_monsters;

	// count dead monsters too (zombies)
	FOREACH_ENTITY_FLAGS(flags, FL_MONSTER, LAMBDA(++n_monsters));

	while(n_monsters < maxmon)
	{
		++n_monsters;
		za_SpawnMonster();
	}

	za_spawn_delay = time + autocvar_g_za_spawn_delay;

	return false;
}
