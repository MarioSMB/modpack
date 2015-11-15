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
	entity head;
	entity closest_targ = world;
	FOR_EACH_PLAYER(head) if(head != player)
	if(vlen(player.origin - head.origin) < autocvar_g_monsters_target_range)
	if(!closest_targ || vlen(player.origin - closest_targ.origin) > vlen(player.origin - head.origin))
		closest_targ = head;

	if(!closest_targ)
	{
		FOR_EACH_MONSTER(head)
		if(vlen(player.origin - head.origin) < autocvar_g_monsters_target_range)
		if(!closest_targ || vlen(player.origin - closest_targ.origin) > vlen(player.origin - head.origin))
			closest_targ = head;
	}

	// otherwise, attempt any entity nearby
	if(!closest_targ)
	{
		for(head = world; (head = findfloat(head, monster_attack, true)); )
		if(head.takedamage && head != player)
		if(vlen(player.origin - head.origin) < autocvar_g_monsters_target_range)
		if(!closest_targ || vlen(player.origin - closest_targ.origin) > vlen(player.origin - head.origin))
			closest_targ = head;
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
	self.switchweapon = 0;
	self.stat_pl_min = mon.mins;
	self.stat_pl_max = mon.maxs;
	self.stat_pl_crouch_min = mon.mins;
	self.stat_pl_crouch_max = mon.maxs;
	self.stat_pl_crouch_view_ofs = self.za_viewofs;
	self.stat_pl_view_ofs = self.za_viewofs;
	self.stat_sv_jumpvelocity = 0;

	self.stat_sv_maxspeed = self.speed2;
	self.stat_sv_maxairspeed = self.speed2;
	self.BUTTON_CROUCH = false;

	return false;
}

MUTATOR_HOOKFUNCTION(za, PlayerPreThink)
{
	if(!self.monsterid || time < self.attack_finished_single[0]) { return false; }

	Monster mon = get_monsterinfo(self.monsterid);
	mon.mr_think(mon);

	if(self.BUTTON_ATCK)
	if(self.monster_attackfunc)
	{
		za_SetEnemy(self);
		if(self.monster_attackfunc(MONSTER_ATTACK_MELEE, self.enemy))
			animdecide_setaction(self, ANIMACTION_MELEE, false);
	}

	if(self.BUTTON_ATCK2)
	if(self.monster_attackfunc)
	{
		za_SetEnemy(self);
		if(self.monster_attackfunc(MONSTER_ATTACK_RANGED, self.enemy))
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
	self.switchweapon = 0;
	self.stat_pl_min = mon.mins;
	self.stat_pl_max = mon.maxs;
	self.stat_pl_crouch_min = mon.mins;
	self.stat_pl_crouch_max = mon.maxs;
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
	entity head;

	// count dead monsters too (zombies)
	FOR_EACH_MONSTER(head) ++n_monsters;

	while(n_monsters < maxmon)
	{
		++n_monsters;
		za_SpawnMonster();
	}

	za_spawn_delay = time + autocvar_g_za_spawn_delay;

	return false;
}
