.entity jail_door;
.float imprisoned;
.entity jailbreak_inventory;
.entity jail_ent;

#define ST_JB_ROUNDS 1

// jailbreak functions
void jb_JailPlayer(entity pl, entity nme)
{
	pl.imprisoned = TRUE;
	
	dprint("Player '", pl.netname, "' jailed!\n");
	
	if(pl.jailbreak_inventory)
	{
		remove(pl.jailbreak_inventory);
		pl.jailbreak_inventory = world;
	}
	
	pl.jailbreak_inventory = spawn();
	pl.jailbreak_inventory.items = pl.items;
	pl.jailbreak_inventory.weapons = pl.weapons;
	pl.jailbreak_inventory.weapon = pl.weapon;
	pl.jailbreak_inventory.switchweapon = pl.switchweapon;
}

void jb_FreePlayer(entity pl)
{
	pl.imprisoned = FALSE;
	pl.jail_ent = world;
	
	dprint("Player '", pl.netname, "' freed!\n");
	
	if(pl.jailbreak_inventory)
	{
		pl.items = pl.jailbreak_inventory.items;
		pl.weapons = pl.jailbreak_inventory.weapons;
		
		entity oldself = self;
		self = pl;
		W_SwitchWeapon(self.jailbreak_inventory.switchweapon);
		self = oldself;
		
		remove(pl.jailbreak_inventory);
		pl.jailbreak_inventory = world;
	}
}

// entity functions
void jail_find_target()
{
	self.jail_door = find(world, targetname, self.target);
	if(!self.jail_door)
		error("Jail: No door defined, jail cannot be accessed!\n");
		
	self.jail_door.wait = -1;
	self.jail_door.event_damage = func_null;
	self.jail_door.takedamage = DAMAGE_NO;
	self.jail_door.touch = func_null;
}

void jb_controlpoint_touch()
{
	if(!IS_PLAYER(other))
		return;
	if(other.frozen)
		return;
	if(other.deadflag != DEAD_NO)
		return;
	if(other.health < 1)
		return;
	if(!round_handler_IsRoundStarted())
		return;
	if(SAME_TEAM(other, self))
		return;
		
	entity jail = find(world, targetname, self.target);
	
	if(!jail)
	{
		print("We have a problem...\n");
		print("Jailbreak controlpoint has no jail target!\n");
	}
	
	self.team = other.team;
	
	entity oldself = self;
	self = jail.jail_door.owner;
	door_fire();
	self = oldself;
	
	entity head;
	FOR_EACH_PLAYER(head)
	if(head.imprisoned)
	if(head.jail_ent == jail)
		jb_FreePlayer(head);
}

void jb_controlpoint_think()
{
	self.nextthink = time + 0.5;
}

// spawnfuncs
void spawnfunc_info_jailbreak_jailspawn_red()
{
	if(!g_jailbreak) { remove(self); return; }
	
	self.imprisoned = TRUE;
	self.team = NUM_TEAM_1;
	//spawnfunc_info_player_deathmatch();
}
void spawnfunc_info_jailbreak_jailspawn_blue()
{
	if(!g_jailbreak) { remove(self); return; }
	
	self.imprisoned = TRUE;
	self.team = NUM_TEAM_2;
	//spawnfunc_info_player_deathmatch();
}

void spawnfunc_jailbreak_controlpoint()
{
	if(!g_jailbreak || !self.team) { remove(self); return; }

	self.classname = "jailbreak_controlpoint";
	self.touch = jb_controlpoint_touch;
	self.think = jb_controlpoint_think;
	self.nextthink = time + 0.5;
	self.solid = SOLID_TRIGGER;
	
	setmodel(self, "models/domination/dom_unclaimed.md3");
	setsize(self, PL_MIN, PL_MAX);
}
void spawnfunc_jailbreak_controlpoint_red() { self.team = NUM_TEAM_1; spawnfunc_jailbreak_controlpoint(); }
void spawnfunc_jailbreak_controlpoint_blue() { self.team = NUM_TEAM_2; spawnfunc_jailbreak_controlpoint(); }

void spawnfunc_jailbreak_jail()
{
	if(!g_jailbreak || !self.team) { remove(self); return; }

	self.classname = "jailbreak_jail";

	InitializeEntity(self, jail_find_target, INITPRIO_FINDTARGET);
}

// round handling
float total_players;
float redalive, bluealive;
.float redalive_stat, bluealive_stat;
float allowed_to_spawn;

void jb_PoisonJails(float winner_team)
{
	entity head;
	
	for(head = world; (head = find(head, classname, "jailbreak_jail")); )
	if(head.team == winner_team)
		pointparticles(particleeffectnum("poisonfield"), head.origin, '0 0 0', 3);
	
	FOR_EACH_PLAYER(head) if(head.team != winner_team) if(head.imprisoned)
	{
		if (random() < 0.5)
			animdecide_setstate(head, head.anim_state | ANIMSTATE_DEAD1, TRUE);
		else
			animdecide_setstate(head, head.anim_state | ANIMSTATE_DEAD2, TRUE);
	}
}

void JB_count_alive_players()
{
	entity e;
	total_players = redalive = bluealive = 0;
	FOR_EACH_PLAYER(e) {
		if(e.team == NUM_TEAM_1)
		{
			++total_players;
			if (!e.imprisoned) ++redalive;
		}
		else if(e.team == NUM_TEAM_2)
		{
			++total_players;
			if (!e.imprisoned) ++bluealive;
		}
	}
	FOR_EACH_REALCLIENT(e) {
		e.redalive_stat = redalive;
		e.bluealive_stat = bluealive;
	}
}

float JB_GetWinnerTeam()
{
	float winner_team = 0;
	if(redalive >= 1)
		winner_team = NUM_TEAM_1;
	if(bluealive >= 1)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_2;
	}
	if(winner_team)
		return winner_team;
	return -1; // no player left
}

#define JB_ALIVE_TEAMS() ((redalive > 0) + (bluealive > 0))
#define JB_ALIVE_TEAMS_OK() (JB_ALIVE_TEAMS() == 2)
float JB_CheckWinner()
{
	entity e;
	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_OVER);
		allowed_to_spawn = FALSE;
		round_handler_Init(5, autocvar_g_jailbreak_warmup, autocvar_g_jailbreak_round_timelimit);
		FOR_EACH_PLAYER(e)
			nades_Clear(e);
		return 1;
	}

	JB_count_alive_players();
	if(JB_ALIVE_TEAMS() > 1)
		return 0;

	float winner_team = JB_GetWinnerTeam();
	if(winner_team > 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, APP_TEAM_NUM_2(winner_team, CENTER_ROUND_TEAM_WIN_));
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_2(winner_team, INFO_ROUND_TEAM_WIN_));
		TeamScore_AddToTeam(winner_team, ST_JB_ROUNDS, +1);
	}
	else if(winner_team == -1)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_TIED);
	}
	
	jb_PoisonJails(winner_team);

	allowed_to_spawn = FALSE;
	round_handler_Init(10, autocvar_g_jailbreak_warmup, autocvar_g_jailbreak_round_timelimit);

	FOR_EACH_PLAYER(e)
		nades_Clear(e);

	return 1;
}

void JB_RoundStart()
{
	if(warmup_stage)
		allowed_to_spawn = TRUE;
	else
		allowed_to_spawn = FALSE;
}

float prev_total_players;
float JB_CheckTeams()
{
	allowed_to_spawn = TRUE;
	JB_count_alive_players();
	if(JB_ALIVE_TEAMS_OK())
	{
		if(prev_total_players > 0)
			Kill_Notification(NOTIF_ALL, world, MSG_CENTER_CPID, CPID_MISSING_TEAMS);
		prev_total_players = -1;
		return 1;
	}
	if(prev_total_players != total_players)
	{
		float p1 = 0, p2 = 0, p3 = 0, p4 = 0;
		if(!redalive) p1 = NUM_TEAM_1;
		if(!bluealive) p2 = NUM_TEAM_2;
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_MISSING_TEAMS, p1, p2, p3, p4);
		prev_total_players = total_players;
	}
	return 0;
}

// mutator hooks
MUTATOR_HOOKFUNCTION(jb_ResetMap)
{
	FOR_EACH_PLAYER(self)
	{
		self.imprisoned = FALSE;
		PutClientInServer();
	}
	return TRUE;
}

MUTATOR_HOOKFUNCTION(jb_PlayerSpawn)
{
	if(self.imprisoned)
	{
		entity head;
		if(self.jail_ent == world || wasfreed(self.jail_ent))
		{
			RandomSelection_Init();
			
			for(head = world; (head = find(head, classname, "jailbreak_jail")); )
			if(DIFF_TEAM(head, self))
				RandomSelection_Add(head, 0, string_null, 1, 1);
				
			self.jail_ent = RandomSelection_chosen_ent;
		}
		
		if(!self.jail_ent)
		{
			print("Jailbreak: no spawn found for imprisoned player!\n");
			return FALSE;
		}
		
		entity jailspawn = self.jail_ent;
			
		setorigin(self, jailspawn.origin);
		self.oldorigin = self.origin;
		self.angles = jailspawn.angles;
		self.angles_z = 0;
		self.fixangle = TRUE;
		
		self.weapon = 0;
		self.switchweapon = 0;
		self.weapons = '0 0 0';
		self.items = 0;
	}
	return FALSE;
}

MUTATOR_HOOKFUNCTION(jb_PlayerDies)
{
	if(!frag_target.imprisoned)
	if(frag_attacker != frag_target)
	if(IS_PLAYER(frag_attacker))
	if(DIFF_TEAM(frag_target, frag_attacker))
		jb_JailPlayer(frag_target, frag_attacker);
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(jb_GetTeamCount)
{
	ret_float = 2;
	return TRUE;
}

// initialization
void jb_Initialize()
{
	allowed_to_spawn = TRUE;
	
	CheckAllowedTeams(world);
	ScoreRules_basics(2, SFL_SORT_PRIO_PRIMARY, 0, TRUE);
	ScoreInfo_SetLabel_TeamScore(ST_JB_ROUNDS, "rounds", SFL_SORT_PRIO_PRIMARY);
	ScoreRules_basics_end();

	round_handler_Spawn(JB_CheckTeams, JB_CheckWinner, JB_RoundStart);
	round_handler_Init(5, autocvar_g_jailbreak_warmup, autocvar_g_jailbreak_round_timelimit);

	addstat(STAT_REDALIVE, AS_INT, redalive_stat);
	addstat(STAT_BLUEALIVE, AS_INT, bluealive_stat);
}

MUTATOR_DEFINITION(gamemode_jailbreak)
{
	MUTATOR_HOOK(reset_map_global, jb_ResetMap, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, jb_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, jb_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetTeamCount, jb_GetTeamCount, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		jb_Initialize();
	}

	MUTATOR_ONREMOVE
	{
		print("This is a game type and it cannot be removed at runtime.");
		return -1;
	}

	return 0;
}
