// random functions
void assault_objective_use()
{
	// activate objective
	self.health = 100;
	//print("^2Activated objective ", self.targetname, "=", etos(self), "\n");
	//print("Activator is ", activator.classname, "\n");

	entity oldself;
	oldself = self;

	for(self = world; (self = find(self, target, oldself.targetname)); )
	{
		if(self.classname == "target_objective_decrease")
			target_objective_decrease_activate();
	}

	self = oldself;
}

vector target_objective_spawn_evalfunc(entity player, entity spot, vector current)
{
	if(self.health < 0 || self.health >= ASSAULT_VALUE_INACTIVE)
		return '-1 0 0';
	return current;
}

// reset this objective. Used when spawning an objective
// and when a new round starts
void assault_objective_reset()
{
	self.health = ASSAULT_VALUE_INACTIVE;
}

// decrease the health of targeted objectives
void assault_objective_decrease_use()
{
	if(activator.team != assault_attacker_team)
	{
		// wrong team triggered decrease
		return;
	}

	if(other.assault_sprite)
	{
		WaypointSprite_Disown(other.assault_sprite, waypointsprite_deadlifetime);
		if(other.classname == "func_assault_destructible")
			other.sprite = world;
	}
	else
		return; // already activated! cannot activate again!

	if(self.enemy.health < ASSAULT_VALUE_INACTIVE)
	{
		if(self.enemy.health - self.dmg > 0.5)
		{
			PlayerScore_Add(activator, SP_SCORE, self.dmg);
			self.enemy.health = self.enemy.health - self.dmg;
		}
		else
		{
			PlayerScore_Add(activator, SP_SCORE, self.enemy.health);
			PlayerTeamScore_Add(activator, SP_ASSAULT_OBJECTIVES, ST_ASSAULT_OBJECTIVES, 1);
			self.enemy.health = -1;

			entity oldself, oldactivator;

			oldself = self;
			self = oldself.enemy;
			if(self.message)
			{
				entity player;
				string s;
				FOR_EACH_PLAYER(player)
				{
					s = strcat(self.message, "\n");
					centerprint(player, s);
				}
			}

			oldactivator = activator;
			activator = oldself;
			SUB_UseTargets();
			activator = oldactivator;
			self = oldself;
		}
	}
}

void assault_setenemytoobjective()
{
	entity objective;
	for(objective = world; (objective = find(objective, targetname, self.target)); )
	{
		if(objective.classname == "target_objective")
		{
			if(self.enemy == world)
				self.enemy = objective;
			else
				objerror("more than one objective as target - fix the map!");
			break;
		}
	}

	if(self.enemy == world)
		objerror("no objective as target - fix the map!");
}

float assault_decreaser_sprite_visible(entity e)
{
	entity decreaser;

	decreaser = self.assault_decreaser;

	if(decreaser.enemy.health >= ASSAULT_VALUE_INACTIVE)
		return FALSE;

	return TRUE;
}

void target_objective_decrease_activate()
{
	entity ent, spr;
	self.owner = world;
	for(ent = world; (ent = find(ent, target, self.targetname)); )
	{
		if(ent.assault_sprite != world)
		{
			WaypointSprite_Disown(ent.assault_sprite, waypointsprite_deadlifetime);
			if(ent.classname == "func_assault_destructible")
				ent.sprite = world;
		}

		spr = WaypointSprite_SpawnFixed("<placeholder>", 0.5 * (ent.absmin + ent.absmax), ent, assault_sprite, RADARICON_OBJECTIVE, '1 0.5 0');
		spr.assault_decreaser = self;
		spr.waypointsprite_visible_for_player = assault_decreaser_sprite_visible;
		spr.classname = "sprite_waypoint";
		WaypointSprite_UpdateRule(spr, assault_attacker_team, SPRITERULE_TEAMPLAY);
		if(ent.classname == "func_assault_destructible")
		{
			WaypointSprite_UpdateSprites(spr, "as-defend", "as-destroy", "as-destroy");
			WaypointSprite_UpdateMaxHealth(spr, ent.max_health);
			WaypointSprite_UpdateHealth(spr, ent.health);
			ent.sprite = spr;
			ent.colormod = '2 2 2';
		}
		else
			WaypointSprite_UpdateSprites(spr, "as-defend", "as-push", "as-push");
	}
}

void target_objective_decrease_findtarget()
{
	assault_setenemytoobjective();
}

void target_assault_roundend_reset()
{
	//print("round end reset\n");
	self.cnt = self.cnt + 1; // up round counter
	self.winning = 0; // up round
}

void target_assault_roundend_use()
{
	self.winning = 1; // round has been won by attackers
}

void assault_roundstart_use()
{
	activator = self;
	SUB_UseTargets();

	entity ent, oldself;

	//(Re)spawn all turrets
	oldself = self;
	ent = find(world, classname, "turret_main");
	while(ent) {
		// Swap turret teams
		if(ent.team == NUM_TEAM_1)
			ent.team = NUM_TEAM_2;
		else
			ent.team = NUM_TEAM_1;

		self = ent;

		// Dubbles as teamchange
		turret_respawn();

		ent = find(ent, classname, "turret_main");
	}
	self = oldself;
}

void assault_wall_think()
{
	if(self.enemy.health < 0)
	{
		self.model = "";
		self.solid = SOLID_NOT;
	}
	else
	{
		self.model = self.mdl;
		self.solid = SOLID_BSP;
	}

	self.nextthink = time + 0.2;
}

// trigger new round
// reset objectives, toggle spawnpoints, reset triggers, ...
void vehicles_clearreturn(entity veh);
void vehicles_spawn();
void assault_new_round()
{
    entity oldself;
	//bprint("ASSAULT: new round\n");

	oldself = self;
	// Eject players from vehicles
    FOR_EACH_PLAYER(self)
    {
        if(self.vehicle)
            vehicles_exit(VHEF_RELEASE);
    }

    self = findchainflags(vehicle_flags, VHF_ISVEHICLE);
    while(self)
    {
        vehicles_clearreturn(self);
        vehicles_spawn();
        self = self.chain;
    }

    self = oldself;

	// up round counter
	self.winning = self.winning + 1;

	// swap attacker/defender roles
	if(assault_attacker_team == NUM_TEAM_1)
		assault_attacker_team = NUM_TEAM_2;
	else
		assault_attacker_team = NUM_TEAM_1;

	entity ent;
	for(ent = world; (ent = nextent(ent)); )
	{
		if(clienttype(ent) == CLIENTTYPE_NOTACLIENT)
		{
			if(ent.team_saved == NUM_TEAM_1)
				ent.team_saved = NUM_TEAM_2;
			else if(ent.team_saved == NUM_TEAM_2)
				ent.team_saved = NUM_TEAM_1;
		}
	}

	// reset the level with a countdown
	cvar_set("timelimit", ftos(ceil(time - game_starttime) / 60));
	ReadyRestart_force(); // sets game_starttime
}

// spawnfuncs
void spawnfunc_info_player_attacker()
{
	if (!g_assault) { remove(self); return; }

	self.team = NUM_TEAM_1; // red, gets swapped every round
	spawnfunc_info_player_deathmatch();
}

void spawnfunc_info_player_defender()
{
	if (!g_assault) { remove(self); return; }

	self.team = NUM_TEAM_2; // blue, gets swapped every round
	spawnfunc_info_player_deathmatch();
}

void spawnfunc_target_objective()
{
	if (!g_assault) { remove(self); return; }

	self.classname = "target_objective";
	self.use = assault_objective_use;
	assault_objective_reset();
	self.reset = assault_objective_reset;
	self.spawn_evalfunc = target_objective_spawn_evalfunc;
}

void spawnfunc_target_objective_decrease()
{
	if (!g_assault) { remove(self); return; }

	self.classname = "target_objective_decrease";

	if(!self.dmg)
		self.dmg = 101;

	self.use = assault_objective_decrease_use;
	self.health = ASSAULT_VALUE_INACTIVE;
	self.max_health = ASSAULT_VALUE_INACTIVE;
	self.enemy = world;

	InitializeEntity(self, target_objective_decrease_findtarget, INITPRIO_FINDTARGET);
}

// destructible walls that can be used to trigger target_objective_decrease
void spawnfunc_func_assault_destructible()
{
	if (!g_assault) { remove(self); return; }

	self.spawnflags = 3;
	self.classname = "func_assault_destructible";

	if(assault_attacker_team == NUM_TEAM_1)
		self.team = NUM_TEAM_2;
	else
		self.team = NUM_TEAM_1;

	spawnfunc_func_breakable();
}

void spawnfunc_func_assault_wall()
{
	if (!g_assault) { remove(self); return; }

	self.classname = "func_assault_wall";
	self.mdl = self.model;
	setmodel(self, self.mdl);
	self.solid = SOLID_BSP;
	self.think = assault_wall_think;
	self.nextthink = time;
	InitializeEntity(self, assault_setenemytoobjective, INITPRIO_FINDTARGET);
}

void spawnfunc_target_assault_roundend()
{
	if (!g_assault) { remove(self); return; }

	self.winning = 0; // round not yet won by attackers
	self.classname = "target_assault_roundend";
	self.use = target_assault_roundend_use;
	self.cnt = 0; // first round
	self.reset = target_assault_roundend_reset;
}

void spawnfunc_target_assault_roundstart()
{
	if (!g_assault) { remove(self); return; }

	assault_attacker_team = NUM_TEAM_1;
	self.classname = "target_assault_roundstart";
	self.use = assault_roundstart_use;
	self.reset2 = assault_roundstart_use;
	InitializeEntity(self, assault_roundstart_use, INITPRIO_FINDTARGET);
}

// legacy bot code
void havocbot_goalrating_ast_targets(float ratingscale)
{
	entity ad, best, wp, tod;
	float radius, found, bestvalue;
	vector p;

	ad = findchain(classname, "func_assault_destructible");

	for (; ad; ad = ad.chain)
	{
		if (ad.target == "")
			continue;

		if (!ad.bot_attack)
			continue;

		found = FALSE;
		for(tod = world; (tod = find(tod, targetname, ad.target)); )
		{
			if(tod.classname == "target_objective_decrease")
			{
				if(tod.enemy.health > 0 && tod.enemy.health < ASSAULT_VALUE_INACTIVE)
				{
				//	dprint(etos(ad),"\n");
					found = TRUE;
					break;
				}
			}
		}

		if(!found)
		{
		///	dprint("target not found\n");
			continue;
		}
		/// dprint("target #", etos(ad), " found\n");


		p = 0.5 * (ad.absmin + ad.absmax);
	//	dprint(vtos(ad.origin), " ", vtos(ad.absmin), " ", vtos(ad.absmax),"\n");
	//	te_knightspike(p);
	//	te_lightning2(world, '0 0 0', p);

		// Find and rate waypoints around it
		found = FALSE;
		best = world;
		bestvalue = 99999999999;
		for(radius=0; radius<1500 && !found; radius+=500)
		{
			for(wp=findradius(p, radius); wp; wp=wp.chain)
			{
				if(!(wp.wpflags & WAYPOINTFLAG_GENERATED))
				if(wp.classname=="waypoint")
				if(checkpvs(wp.origin, ad))
				{
					found = TRUE;
					if(wp.cnt<bestvalue)
					{
						best = wp;
						bestvalue = wp.cnt;
					}
				}
			}
		}

		if(best)
		{
		///	dprint("waypoints around target were found\n");
		//	te_lightning2(world, '0 0 0', best.origin);
		//	te_knightspike(best.origin);

			navigation_routerating(best, ratingscale, 4000);
			best.cnt += 1;

			self.havocbot_attack_time = 0;

			if(checkpvs(self.view_ofs,ad))
			if(checkpvs(self.view_ofs,best))
			{
			//	dprint("increasing attack time for this target\n");
				self.havocbot_attack_time = time + 2;
			}
		}
	}
}

void havocbot_role_ast_offense()
{
	if(self.deadflag != DEAD_NO)
	{
		self.havocbot_attack_time = 0;
		havocbot_ast_reset_role(self);
		return;
	}

	// Set the role timeout if necessary
	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + 120;

	if (time > self.havocbot_role_timeout)
	{
		havocbot_ast_reset_role(self);
		return;
	}

	if(self.havocbot_attack_time>time)
		return;

	if (self.bot_strategytime < time)
	{
		navigation_goalrating_start();
		havocbot_goalrating_enemyplayers(20000, self.origin, 650);
		havocbot_goalrating_ast_targets(20000);
		havocbot_goalrating_items(15000, self.origin, 10000);
		navigation_goalrating_end();

		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
	}
}

void havocbot_role_ast_defense()
{
	if(self.deadflag != DEAD_NO)
	{
		self.havocbot_attack_time = 0;
		havocbot_ast_reset_role(self);
		return;
	}

	// Set the role timeout if necessary
	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + 120;

	if (time > self.havocbot_role_timeout)
	{
		havocbot_ast_reset_role(self);
		return;
	}

	if(self.havocbot_attack_time>time)
		return;

	if (self.bot_strategytime < time)
	{
		navigation_goalrating_start();
		havocbot_goalrating_enemyplayers(20000, self.origin, 3000);
		havocbot_goalrating_ast_targets(20000);
		havocbot_goalrating_items(15000, self.origin, 10000);
		navigation_goalrating_end();

		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
	}
}

void havocbot_role_ast_setrole(entity bot, float role)
{
	switch(role)
	{
		case HAVOCBOT_AST_ROLE_DEFENSE:
			bot.havocbot_role = havocbot_role_ast_defense;
			bot.havocbot_role_flags = HAVOCBOT_AST_ROLE_DEFENSE;
			bot.havocbot_role_timeout = 0;
			break;
		case HAVOCBOT_AST_ROLE_OFFENSE:
			bot.havocbot_role = havocbot_role_ast_offense;
			bot.havocbot_role_flags = HAVOCBOT_AST_ROLE_OFFENSE;
			bot.havocbot_role_timeout = 0;
			break;
	}
}

void havocbot_ast_reset_role(entity bot)
{
	if(self.deadflag != DEAD_NO)
		return;

	if(bot.team == assault_attacker_team)
		havocbot_role_ast_setrole(bot, HAVOCBOT_AST_ROLE_OFFENSE);
	else
		havocbot_role_ast_setrole(bot, HAVOCBOT_AST_ROLE_DEFENSE);
}

// mutator hooks
MUTATOR_HOOKFUNCTION(assault_PlayerSpawn)
{
	if(self.team == assault_attacker_team)
		Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_ASSAULT_ATTACKING);
	else
		Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_ASSAULT_DEFENDING);

	return FALSE;
}

MUTATOR_HOOKFUNCTION(assault_TurretSpawn)
{
	if(!self.team || self.team == MAX_SHOT_DISTANCE)
		self.team = 5; // this gets reversed when match starts?

	return FALSE;
}

MUTATOR_HOOKFUNCTION(assault_VehicleSpawn)
{
	self.nextthink = time + 0.5;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(assault_BotRoles)
{
	havocbot_ast_reset_role(self);
	return TRUE;
}

MUTATOR_HOOKFUNCTION(assault_GetTeamCount)
{
	c1 = c2 = 0; // assault always has 2 teams
	return TRUE;
}

.float assault_repair_delay;
MUTATOR_HOOKFUNCTION(assault_PlayerThink)
{
	if(self.team == assault_attacker_team) { return FALSE; }
	if(autocvar_g_assault_repair_amount <= 0) { return FALSE; }
	if(time < self.assault_repair_delay) { return FALSE; }
	if(gameover || self.frozen || self.deadflag != DEAD_NO || self.vehicle)
		return FALSE;

	float n_players = 0;
	entity cp = findchain(classname, "func_assault_destructible"), head;
	self.assault_repair_delay = time + 0.5;
	
	FOR_EACH_PLAYER(head) if(SAME_TEAM(head, self)) { ++n_players; }

	for(; cp; cp = cp.chain)
	if(vlen((cp.origin + 0.5 * (cp.absmin + cp.absmax)) - self.origin) < 300)
	if(cp.health > 0)
	if(cp.health < cp.max_health)
	if(cp.target != "")
	if(time - cp.pain_finished > 3)
	{
		cp.health += autocvar_g_assault_repair_amount / n_players;
		if(cp.sprite) { WaypointSprite_UpdateHealth(cp.sprite, cp.health); }
	}
	return FALSE;
}

MUTATOR_HOOKFUNCTION(assault_OnEntityPreSpawn)
{
	switch(self.classname)
	{
		case "info_player_team1": return TRUE;
		case "info_player_team2": return TRUE;
		case "info_player_team3": return TRUE;
		case "info_player_team4": return TRUE;
	}

	return FALSE;
}

// scoreboard setup
void assault_ScoreRules()
{
	ScoreRules_basics(2, SFL_SORT_PRIO_PRIMARY, 0, TRUE);
	ScoreInfo_SetLabel_TeamScore(  ST_ASSAULT_DESTROYED,     "destroyed",       SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_TeamScore(  ST_ASSAULT_OBJECTIVES,    "objectives",      0);
	ScoreInfo_SetLabel_PlayerScore(SP_ASSAULT_OBJECTIVES,    "objectives",      0);
	ScoreRules_basics_end();
}

void assault_Initialize()
{
	assault_ScoreRules();
	warmup_stage = 0;
}

MUTATOR_DEFINITION(gamemode_assault)
{
	MUTATOR_HOOK(PlayerSpawn, assault_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(TurretSpawn, assault_TurretSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(VehicleSpawn, assault_VehicleSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(HavocBot_ChooseRole, assault_BotRoles, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetTeamCount, assault_GetTeamCount, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, assault_PlayerThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(OnEntityPreSpawn, assault_OnEntityPreSpawn, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		assault_Initialize();
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back assault_Initialize here
		// BUT: we don't need to! If this gets called, adding always
		// succeeds.
	}

	MUTATOR_ONREMOVE
	{
		print("This is a game type and it cannot be removed at runtime.");
		return -1;
	}

	return 0;
}
