// ===========================================================
//  Keepaway game mode coding, written by Samual and Diabolik
//  Last updated: September, 2012
// ===========================================================

float ka_ballcarrier_waypointsprite_visible_for_player(entity e) // runs on waypoints which are attached to ballcarriers, updates once per frame 
{
	if(e.ballcarried)
		if(IS_SPEC(other)) 
			return FALSE; // we don't want spectators of the ballcarrier to see the attached waypoint on the top of their screen
		
	// TODO: Make the ballcarrier lack a waypointsprite whenever they have the invisibility powerup

	return TRUE;
}

void ka_EventLog(string mode, entity actor) // use an alias for easy changing and quick editing later
{
	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":ka:", mode, ((actor != world) ? (strcat(":", ftos(actor.playerid))) : "")));
}

void ka_RespawnBall() // runs whenever the ball needs to be relocated
{
	if(gameover) { return; }
	vector oldballorigin = self.origin;
	
	if(MoveToRandomMapLocation(self, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 1024, 256))
	{
		makevectors(self.angles);
		self.movetype = MOVETYPE_BOUNCE;
		self.velocity = '0 0 200';
		self.angles = '0 0 0';
		self.effects = autocvar_g_keepawayball_effects;
		self.think = ka_RespawnBall;
		self.nextthink = time + autocvar_g_keepawayball_respawntime;
		
		pointparticles(particleeffectnum("electro_combo"), oldballorigin, '0 0 0', 1);
		pointparticles(particleeffectnum("electro_combo"), self.origin, '0 0 0', 1);

		WaypointSprite_Spawn("ka-ball", 0, 0, self, '0 0 64', world, self.team, self, waypointsprite_attachedforcarrier, FALSE, RADARICON_FLAGCARRIER, '0 1 1');
		WaypointSprite_Ping(self.waypointsprite_attachedforcarrier);	

		sound(self, CH_TRIGGER, "keepaway/respawn.wav", VOL_BASE, ATTN_NONE); // ATTN_NONE (it's a sound intended to be heard anywhere) 
	}
	else
	{
		ka_RespawnBall(); // finding a location failed, retry 
	}
}

void ka_TimeScoring()
{
	if(self.owner.ballcarried)
	{ // add points for holding the ball after a certain amount of time
		if(autocvar_g_keepaway_score_timepoints)
			PlayerScore_Add(self.owner, SP_SCORE, autocvar_g_keepaway_score_timepoints);
			
		PlayerScore_Add(self.owner, SP_KEEPAWAY_BCTIME, (autocvar_g_keepaway_score_timeinterval / 1)); // interval is divided by 1 so that time always shows "seconds"
		self.nextthink = time + autocvar_g_keepaway_score_timeinterval;
	}
}

void ka_TouchEvent() // runs any time that the ball comes in contact with something
{
	if(gameover) { return; }
	if(!self) { return; }
	if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{ // The ball fell off the map, respawn it since players can't get to it
		ka_RespawnBall();
		return;
	}
	if(other.deadflag != DEAD_NO) { return; }
	if not(IS_PLAYER(other)) 
	{  // The ball just touched an object, most likely the world
		pointparticles(particleeffectnum("kaball_sparks"), self.origin, '0 0 0', 1);
		sound(self, CH_TRIGGER, "keepaway/touch.wav", VOL_BASE, ATTN_NORM);
		return; 
	}
	else if(self.wait > time) { return; }

	// attach the ball to the player
	self.owner = other;
	other.ballcarried = self;
	setattachment(self, other, "");
	setorigin(self, '0 0 0');
	
	// make the ball invisible/unable to do anything/set up time scoring
	self.velocity = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.effects |= EF_NODRAW;
	self.touch = func_null;
	self.think = ka_TimeScoring;
	self.nextthink = time + autocvar_g_keepaway_score_timeinterval;
	self.takedamage = DAMAGE_NO;

	// apply effects to player
	other.glow_color = autocvar_g_keepawayball_trail_color;
	other.glow_trail = TRUE;
	other.effects |= autocvar_g_keepaway_ballcarrier_effects;
	
	// messages and sounds
	ka_EventLog("pickup", other);
	Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_KEEPAWAY_PICKUP, other.netname);
	Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_KEEPAWAY_PICKUP, other.netname);
	sound(self.owner, CH_TRIGGER, "keepaway/pickedup.wav", VOL_BASE, ATTN_NONE); // ATTN_NONE (it's a sound intended to be heard anywhere) 
	
	// scoring
	PlayerScore_Add(other, SP_KEEPAWAY_PICKUPS, 1);

	// waypoints
	WaypointSprite_AttachCarrier("ka-ballcarrier", other, RADARICON_FLAGCARRIER, '1 0 0');
	other.waypointsprite_attachedforcarrier.waypointsprite_visible_for_player = ka_ballcarrier_waypointsprite_visible_for_player;
	WaypointSprite_UpdateRule(other.waypointsprite_attachedforcarrier, 0, SPRITERULE_DEFAULT);
	WaypointSprite_Ping(other.waypointsprite_attachedforcarrier);	
	WaypointSprite_Kill(self.waypointsprite_attachedforcarrier);
}

void ka_DropEvent(entity plyr) // runs any time that a player is supposed to lose the ball
{
	entity ball;
	ball = plyr.ballcarried;

	if(!ball) { return; }
	
	// reset the ball
	setattachment(ball, world, "");
	ball.movetype = MOVETYPE_BOUNCE;
	ball.wait = time + 1; 
	ball.touch = ka_TouchEvent;
	ball.think = ka_RespawnBall;
	ball.nextthink = time + autocvar_g_keepawayball_respawntime;
	ball.takedamage = DAMAGE_YES;
	ball.effects &~= EF_NODRAW; 
	setorigin(ball, plyr.origin + '0 0 10');
	ball.velocity = '0 0 200' + '0 100 0'*crandom() + '100 0 0'*crandom();
	ball.owner.ballcarried = world; // I hope nothing checks to see if the world has the ball in the rest of my code :P 
	ball.owner = world;
	
	// reset the player effects
	plyr.glow_trail = FALSE;
	plyr.effects &~= autocvar_g_keepaway_ballcarrier_effects;

	// messages and sounds
	ka_EventLog("dropped", plyr);
	Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_KEEPAWAY_DROPPED, plyr.netname);
	Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_KEEPAWAY_DROPPED, plyr.netname);
	sound(other, CH_TRIGGER, "keepaway/dropped.wav", VOL_BASE, ATTN_NONE);	// ATTN_NONE (it's a sound intended to be heard anywhere) 
	
	// scoring
	// PlayerScore_Add(plyr, SP_KEEPAWAY_DROPS, 1); Not anymore, this is 100% the same as pickups and is useless.
	
	// waypoints
	WaypointSprite_Spawn("ka-ball", 0, 0, ball, '0 0 64', world, ball.team, ball, waypointsprite_attachedforcarrier, FALSE, RADARICON_FLAGCARRIER, '0 1 1');
	WaypointSprite_UpdateRule(ball.waypointsprite_attachedforcarrier, 0, SPRITERULE_DEFAULT);
	WaypointSprite_Ping(ball.waypointsprite_attachedforcarrier);	
	WaypointSprite_Kill(plyr.waypointsprite_attachedforcarrier);
}

void ka_Reset() // used to clear the ballcarrier whenever the match switches from warmup to normal
{
	if((self.owner) && (IS_PLAYER(self.owner)))
		ka_DropEvent(self.owner);

	ka_RespawnBall();
}


// ================
// Bot player logic
// ================

void havocbot_goalrating_ball(float ratingscale, vector org)
{
	float t;
	entity ball_owner;
	ball_owner = ka_ball.owner;

	if (ball_owner == self)
		return;

	// If ball is carried by player then hunt them down.
	if (ball_owner)
	{
		t = (self.health + self.armorvalue) / (ball_owner.health + ball_owner.armorvalue);
		navigation_routerating(ball_owner, t * ratingscale, 2000);
	}

	// Ball has been dropped so collect.
	navigation_routerating(ka_ball, ratingscale, 2000);
}

void havocbot_role_ka_carrier()
{
	if (self.deadflag != DEAD_NO)
		return;

	if (time > self.bot_strategytime)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;

		navigation_goalrating_start();
		havocbot_goalrating_items(10000, self.origin, 10000);
		havocbot_goalrating_enemyplayers(20000, self.origin, 10000);
		//havocbot_goalrating_waypoints(1, self.origin, 1000);
		navigation_goalrating_end();
	}

	if (!self.ballcarried)
	{
		self.havocbot_role = havocbot_role_ka_collector;
		self.bot_strategytime = 0;
	}
}

void havocbot_role_ka_collector()
{
	if (self.deadflag != DEAD_NO)
		return;

	if (time > self.bot_strategytime)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;

		navigation_goalrating_start();
		havocbot_goalrating_items(10000, self.origin, 10000);
		havocbot_goalrating_enemyplayers(1000, self.origin, 10000);
		havocbot_goalrating_ball(20000, self.origin);
		navigation_goalrating_end();
	}

	if (self.ballcarried)
	{
		self.havocbot_role = havocbot_role_ka_carrier;
		self.bot_strategytime = 0;
	}
}


// ==============
// Hook Functions
// ==============

MUTATOR_HOOKFUNCTION(ka_Scoring)
{
	if((frag_attacker != frag_target) && (IS_PLAYER(frag_attacker)))
	{
		if(frag_target.ballcarried) { // add to amount of times killing carrier
			PlayerScore_Add(frag_attacker, SP_KEEPAWAY_CARRIERKILLS, 1);
			if(autocvar_g_keepaway_score_bckill) // add bckills to the score
				PlayerScore_Add(frag_attacker, SP_SCORE, autocvar_g_keepaway_score_bckill);
		}
		else if(!frag_attacker.ballcarried)
			if(autocvar_g_keepaway_noncarrier_warn)
				Send_Notification(NOTIF_ONE_ONLY, frag_attacker, MSG_CENTER, CENTER_KEEPAWAY_WARN);

		if(frag_attacker.ballcarried) // add to amount of kills while ballcarrier
			PlayerScore_Add(frag_attacker, SP_SCORE, autocvar_g_keepaway_score_killac);
	}

	if(self.ballcarried) { ka_DropEvent(self); } // a player with the ball has died, drop it
	return 0;
}

MUTATOR_HOOKFUNCTION(ka_GiveFragsForKill)
{
	frag_score = 0; // no frags counted in keepaway
	return 1; // you deceptive little bugger ;3 This needs to be true in order for this function to even count. 
}

MUTATOR_HOOKFUNCTION(ka_PlayerPreThink)
{
	// clear the item used for the ball in keepaway
	self.items &~= IT_KEY1;
	
	// if the player has the ball, make sure they have the item for it (Used for HUD primarily)
	if(self.ballcarried)
		self.items |= IT_KEY1;

	return 0;
}

MUTATOR_HOOKFUNCTION(ka_PlayerUseKey)
{
	if(MUTATOR_RETURNVALUE == 0)
	if(self.ballcarried)
	{
		ka_DropEvent(self);
		return 1;
	}
	return 0;
}

MUTATOR_HOOKFUNCTION(ka_PlayerDamage) // for changing damage and force values that are applied to players in g_damage.qc
{
	if(frag_attacker.ballcarried) // if the attacker is a ballcarrier
	{
		if(frag_target == frag_attacker) // damage done to yourself
		{
			frag_damage *= autocvar_g_keepaway_ballcarrier_selfdamage;
			frag_force *= autocvar_g_keepaway_ballcarrier_selfforce;
		}
		else // damage done to noncarriers
		{
			frag_damage *= autocvar_g_keepaway_ballcarrier_damage;
			frag_force *= autocvar_g_keepaway_ballcarrier_force;
		}
	}
	else if not(frag_target.ballcarried) // if the target is a noncarrier
	{
		if(frag_target == frag_attacker) // damage done to yourself
		{
			frag_damage *= autocvar_g_keepaway_noncarrier_selfdamage;
			frag_force *= autocvar_g_keepaway_noncarrier_selfforce;
		}
		else // damage done to other noncarriers
		{
			frag_damage *= autocvar_g_keepaway_noncarrier_damage;
			frag_force *= autocvar_g_keepaway_noncarrier_force;
		}
	}
	return 0;
}

MUTATOR_HOOKFUNCTION(ka_RemovePlayer)
{
	if(self.ballcarried) { ka_DropEvent(self); } // a player with the ball has left the match, drop it
	return 0;
}

MUTATOR_HOOKFUNCTION(ka_PlayerPowerups)
{
	// In the future this hook is supposed to allow me to do some extra stuff with waypointsprites and invisibility powerup
	// So bare with me until I can fix a certain bug with ka_ballcarrier_waypointsprite_visible_for_player() 
	
	self.effects &~= autocvar_g_keepaway_ballcarrier_effects;

	if(self.ballcarried)
		self.effects |= autocvar_g_keepaway_ballcarrier_effects;
	
	return 0;
}

MUTATOR_HOOKFUNCTION(ka_BotRoles)
{
	if (self.ballcarried)
		self.havocbot_role = havocbot_role_ka_carrier;
	else
		self.havocbot_role = havocbot_role_ka_collector;
	return TRUE;
}


// ==============
// Initialization
// ==============

void ka_SpawnBall() // loads various values for the ball, runs only once at start of match
{
	if(!g_keepaway) { return; }
	
	entity e;
	e = spawn();
	e.model = "models/orbs/orbblue.md3";	
	precache_model(e.model);
	setmodel(e, e.model);
	setsize(e, '-16 -16 -20', '16 16 20'); // 20 20 20 was too big, player is only 16 16 24... gotta cheat with the Z (20) axis so that the particle isn't cut off
	e.classname = "keepawayball";
	e.damageforcescale = autocvar_g_keepawayball_damageforcescale;
	e.takedamage = DAMAGE_YES;
	e.solid = SOLID_TRIGGER;
	e.movetype = MOVETYPE_BOUNCE;
	e.glow_color = autocvar_g_keepawayball_trail_color;
	e.glow_trail = TRUE;
	e.flags = FL_ITEM;
	e.reset = ka_Reset;
	e.touch = ka_TouchEvent;
	e.owner = world;
	ka_ball = e;

	InitializeEntity(e, ka_RespawnBall, INITPRIO_SETLOCATION); // is this the right priority? Neh, I have no idea.. Well-- it works! So. 
}

void ka_ScoreRules()
{
	ScoreRules_basics(0, SFL_SORT_PRIO_PRIMARY, 0, TRUE); // SFL_SORT_PRIO_PRIMARY
	ScoreInfo_SetLabel_PlayerScore(SP_KEEPAWAY_PICKUPS,			"pickups",		0);
	ScoreInfo_SetLabel_PlayerScore(SP_KEEPAWAY_CARRIERKILLS,	"bckills",		0);
	ScoreInfo_SetLabel_PlayerScore(SP_KEEPAWAY_BCTIME,			"bctime",		SFL_SORT_PRIO_SECONDARY);
	ScoreRules_basics_end();
}

void ka_Initialize() // run at the start of a match, initiates game mode
{
	if(!g_keepaway)
		return;
		
	precache_sound("keepaway/pickedup.wav");
	precache_sound("keepaway/dropped.wav");
	precache_sound("keepaway/respawn.wav");
	precache_sound("keepaway/touch.wav");

	ka_ScoreRules();
	ka_SpawnBall();
}


MUTATOR_DEFINITION(gamemode_keepaway)
{
	MUTATOR_HOOK(MakePlayerObserver, ka_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, ka_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, ka_Scoring, CBC_ORDER_ANY);
	MUTATOR_HOOK(GiveFragsForKill, ka_GiveFragsForKill, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, ka_PlayerPreThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, ka_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPowerups, ka_PlayerPowerups, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerUseKey, ka_PlayerUseKey, CBC_ORDER_ANY);
	MUTATOR_HOOK(HavocBot_ChooseRule, ka_BotRoles, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		ka_Initialize();
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back ka_Initialize here
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
