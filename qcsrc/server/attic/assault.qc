void spawnfunc_func_breakable();
void target_objective_decrease_activate();
.entity assault_decreaser;
.entity assault_sprite;

void spawnfunc_info_player_attacker() {
	if(!g_assault)
	{
		remove(self);
		return;
	}
	self.team = NUM_TEAM_1; // red, gets swapped every round
	spawnfunc_info_player_deathmatch();
}

void spawnfunc_info_player_defender() {
	if(!g_assault)
	{
		remove(self);
		return;
	}
	self.team = NUM_TEAM_2; // blue, gets swapped every round
	spawnfunc_info_player_deathmatch();
}

// reset this objective. Used when spawning an objective
// and when a new round starts
void assault_objective_reset() {
	self.health = ASSAULT_VALUE_INACTIVE;
}

void assault_objective_use() {
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

void spawnfunc_target_objective() {
	if(!g_assault)
	{
		remove(self);
		return;
	}
	self.classname = "target_objective";
	self.use = assault_objective_use;
	assault_objective_reset();
	self.reset = assault_objective_reset;
	self.spawn_evalfunc = target_objective_spawn_evalfunc;
}


// decrease the health of targeted objectives
void assault_objective_decrease_use() {
	if(activator.team != assault_attacker_team) {
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
			PlayerTeamScore_Add(activator, SP_SCORE, ST_SCORE, self.dmg);
			self.enemy.health = self.enemy.health - self.dmg;
		}
		else
		{
			PlayerTeamScore_Add(activator, SP_SCORE, ST_SCORE, self.enemy.health);
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
	for(objective = world; (objective = find(objective, targetname, self.target)); ) {
		if(objective.classname == "target_objective") {
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
		}
		else
			WaypointSprite_UpdateSprites(spr, "as-defend", "as-push", "as-push");
	}
}

void target_objective_decrease_findtarget()
{
	assault_setenemytoobjective();
}

//=============================================================================

void spawnfunc_target_objective_decrease() {
	if(!g_assault)
	{
		remove(self);
		return;
	}

	self.classname = "target_objective_decrease";

	if(!self.dmg) {
		self.dmg = 101;
	}
	self.use = assault_objective_decrease_use;
	self.health = ASSAULT_VALUE_INACTIVE;
	self.max_health = ASSAULT_VALUE_INACTIVE;
	self.enemy = world;

	InitializeEntity(self, target_objective_decrease_findtarget, INITPRIO_FINDTARGET);
}

// destructible walls that can be used to trigger target_objective_decrease
void spawnfunc_func_assault_destructible() {
	if(!g_assault)
	{
		remove(self);
		return;
	}
	self.spawnflags = 3;
	self.classname = "func_assault_destructible";
	if(assault_attacker_team == NUM_TEAM_1) {
		self.team = NUM_TEAM_2;
	} else {
		self.team = NUM_TEAM_1;
	}
	spawnfunc_func_breakable();
}

void assault_wall_think() {
	if(self.enemy.health < 0) {
		self.model = "";
		self.solid = SOLID_NOT;
	} else {
		self.model = self.mdl;
		self.solid = SOLID_BSP;
	}

	self.nextthink = time + 0.2;
}

void spawnfunc_func_assault_wall() {
	if(!g_assault)
	{
		remove(self);
		return;
	}
	self.classname = "func_assault_wall";
	self.mdl = self.model;
	setmodel(self, self.mdl);
	self.solid = SOLID_BSP;
	self.think = assault_wall_think;
	self.nextthink = time;
	InitializeEntity(self, assault_setenemytoobjective, INITPRIO_FINDTARGET);
}


void target_assault_roundend_reset() {
	//print("round end reset\n");
	self.cnt = self.cnt + 1; // up round counter
	self.winning = 0; // up round
}

void target_assault_roundend_use() {
	self.winning = 1; // round has been won by attackers
}

void spawnfunc_target_assault_roundend() {
	if(!g_assault)
	{
		remove(self);
		return;
	}
	self.winning = 0; // round not yet won by attackers
	self.classname = "target_assault_roundend";
	self.use = target_assault_roundend_use;
	self.cnt = 0; // first round
	self.reset = target_assault_roundend_reset;
}

void assault_roundstart_use() {

	activator = self;
	SUB_UseTargets();


#ifdef TTURRETS_ENABLED
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
		turret_stdproc_respawn();

		ent = find(ent, classname, "turret_main");
	}
	self = oldself;
#endif


}

void spawnfunc_target_assault_roundstart() {
	if(!g_assault)
	{
		remove(self);
		return;
	}
	assault_attacker_team = NUM_TEAM_1;
	self.classname = "target_assault_roundstart";
	self.use = assault_roundstart_use;
	self.reset2 = assault_roundstart_use;
	InitializeEntity(self, assault_roundstart_use, INITPRIO_FINDTARGET);
}

// trigger new round
// reset objectives, toggle spawnpoints, reset triggers, ...
void vehicles_clearrturn();
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
            vehicles_exit(VHEF_RELESE);
    }

    self = findchainflags(vehicle_flags, VHF_ISVEHICLE);
    while(self)
    {
        vehicles_clearrturn();
        vehicles_spawn();
        self = self.chain;
    }

    self = oldself;

	// up round counter
	self.winning = self.winning + 1;

	// swap attacker/defender roles
	if(assault_attacker_team == NUM_TEAM_1) {
		assault_attacker_team = NUM_TEAM_2;
	} else {
		assault_attacker_team = NUM_TEAM_1;
	}


	entity ent;
	for(ent = world; (ent = nextent(ent)); )
	{
		if(IS_NOT_A_CLIENT(ent))
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
