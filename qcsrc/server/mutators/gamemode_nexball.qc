float autocvar_g_nexball_safepass_turnrate;
float autocvar_g_nexball_safepass_maxdist;
float autocvar_g_nexball_safepass_holdtime;
float autocvar_g_nexball_viewmodel_scale;
float autocvar_g_nexball_tackling;
vector autocvar_g_nexball_viewmodel_offset;

void basketball_touch();
void football_touch();
void ResetBall();
#define NBM_NONE 0
#define NBM_FOOTBALL 2
#define NBM_BASKETBALL 4
float nexball_mode;

float OtherTeam(float t)  //works only if there are two teams on the map!
{
	entity e;
	e = find(world, classname, "nexball_team");
	if(e.team == t)
		e = find(e, classname, "nexball_team");
	return e.team;
}


void LogNB(string mode, entity actor)
{
	string s;
	if(!autocvar_sv_eventlog)
		return;
	s = strcat(":nexball:", mode);
	if(actor != world)
		s = strcat(s, ":", ftos(actor.playerid));
	GameLogEcho(s);
}

void ball_restart(void)
{
	if(self.owner)
		DropBall(self, self.owner.origin, '0 0 0');
	ResetBall();
}

void nexball_setstatus(void)
{
	entity oldself;
	self.items &= ~IT_KEY1;
	if(self.ballcarried)
	{
		if(self.ballcarried.teamtime && (self.ballcarried.teamtime < time))
		{
			bprint("The ", Team_ColoredFullName(self.team), " held the ball for too long.\n");
			oldself = self;
			self = self.ballcarried;
			DropBall(self, self.owner.origin, '0 0 0');
			ResetBall();
			self = oldself;
		}
		else
			self.items |= IT_KEY1;
	}
}

void relocate_nexball(void)
{
	tracebox(self.origin, BALL_MINS, BALL_MAXS, self.origin, TRUE, self);
	if(trace_startsolid)
	{
		vector o;
		o = self.origin;
		if(!move_out_of_solid(self))
			objerror("could not get out of solid at all!");
		print("^1NOTE: this map needs FIXING. ", self.classname, " at ", vtos(o - '0 0 1'));
		print(" needs to be moved out of solid, e.g. by '", ftos(self.origin_x - o_x));
		print(" ", ftos(self.origin_y - o_y));
		print(" ", ftos(self.origin_z - o_z), "'\n");
		self.origin = o;
	}
}

void DropOwner(void)
{
	entity ownr;
	ownr = self.owner;
	DropBall(self, ownr.origin, ownr.velocity);
	makevectors(ownr.v_angle_y * '0 1 0');
	ownr.velocity += ('0 0 0.75' - v_forward) * 1000;
	ownr.flags &= ~FL_ONGROUND;
}

void GiveBall(entity plyr, entity ball)
{
	entity ownr;

	if((ownr = ball.owner))
	{
		ownr.effects &= ~autocvar_g_nexball_basketball_effects_default;
		ownr.ballcarried = world;
		if(ownr.metertime)
		{
			ownr.metertime = 0;
			ownr.weaponentity.state = WS_READY;
		}
		WaypointSprite_Kill(ownr.waypointsprite_attachedforcarrier);
	}
	else
	{
		WaypointSprite_Kill(ball.waypointsprite_attachedforcarrier);
	}

	//setattachment(ball, plyr, "");
	setorigin(ball, plyr.origin + plyr.view_ofs);

	if(ball.team != plyr.team)
		ball.teamtime = time + autocvar_g_nexball_basketball_delay_hold_forteam;

	ball.owner = ball.pusher = plyr; //"owner" is set to the player carrying, "pusher" to the last player who touched it
	ball.team = plyr.team;
	plyr.ballcarried = ball;
	ball.nb_dropper = plyr;

	plyr.effects |= autocvar_g_nexball_basketball_effects_default;
	ball.effects &= ~autocvar_g_nexball_basketball_effects_default;

	ball.velocity = '0 0 0';
	ball.movetype = MOVETYPE_NONE;
	ball.touch = func_null;
	ball.effects |= EF_NOSHADOW;
	ball.scale = 1; // scale down.

	WaypointSprite_AttachCarrier("nb-ball", plyr, RADARICON_FLAGCARRIER, BALL_SPRITECOLOR);
	WaypointSprite_UpdateRule(plyr.waypointsprite_attachedforcarrier, 0, SPRITERULE_DEFAULT);

	if(autocvar_g_nexball_basketball_delay_hold)
	{
		ball.think = DropOwner;
		ball.nextthink = time + autocvar_g_nexball_basketball_delay_hold;
	}

	ownr = self;
	self = plyr;
	self.weaponentity.weapons = self.weapons;
	self.weaponentity.switchweapon = self.weapon;
	self.weapons = WEPSET_PORTO;
	WEP_ACTION(WEP_PORTO, WR_RESETPLAYER);
	self.switchweapon = WEP_PORTO;
	W_SwitchWeapon(WEP_PORTO);
	self = ownr;
}

void DropBall(entity ball, vector org, vector vel)
{
	ball.effects |= autocvar_g_nexball_basketball_effects_default;
	ball.effects &= ~EF_NOSHADOW;
	ball.owner.effects &= ~autocvar_g_nexball_basketball_effects_default;

	setattachment(ball, world, "");
	setorigin(ball, org);
	ball.movetype = MOVETYPE_BOUNCE;
	ball.flags &= ~FL_ONGROUND;
	ball.scale = ball_scale;
	ball.velocity = vel;
	ball.nb_droptime = time;
	ball.touch = basketball_touch;
	ball.think = ResetBall;
	ball.nextthink = min(time + autocvar_g_nexball_delay_idle, ball.teamtime);

	if(ball.owner.metertime)
	{
		ball.owner.metertime = 0;
		ball.owner.weaponentity.state = WS_READY;
	}

	WaypointSprite_Kill(ball.owner.waypointsprite_attachedforcarrier);
	WaypointSprite_Spawn("nb-ball", 0, 0, ball, '0 0 64', world, ball.team, ball, waypointsprite_attachedforcarrier, FALSE, RADARICON_FLAGCARRIER, BALL_SPRITECOLOR); // no health bar please
	WaypointSprite_UpdateRule(ball.waypointsprite_attachedforcarrier, 0, SPRITERULE_DEFAULT);

	ball.owner.ballcarried = world;
	ball.owner = world;
}

void InitBall(void)
{
	if(gameover) return;
	self.flags &= ~FL_ONGROUND;
	self.movetype = MOVETYPE_BOUNCE;
	if(self.classname == "nexball_basketball")
		self.touch = basketball_touch;
	else if(self.classname == "nexball_football")
		self.touch = football_touch;
	self.cnt = 0;
	self.think = ResetBall;
	self.nextthink = time + autocvar_g_nexball_delay_idle + 3;
	self.teamtime = 0;
	self.pusher = world;
	self.team = FALSE;
	sound(self, CH_TRIGGER, self.noise1, VOL_BASE, ATTEN_NORM);
	WaypointSprite_Ping(self.waypointsprite_attachedforcarrier);
	LogNB("init", world);
}

void ResetBall(void)
{
	if(self.cnt < 2)	// step 1
	{
		if(time == self.teamtime)
			bprint("The ", Team_ColoredFullName(self.team), " held the ball for too long.\n");

		self.touch = func_null;
		self.movetype = MOVETYPE_NOCLIP;
		self.velocity = '0 0 0'; // just in case?
		if(!self.cnt)
			LogNB("resetidle", world);
		self.cnt = 2;
		self.nextthink = time;
	}
	else if(self.cnt < 4)	  // step 2 and 3
	{
//		dprint("Step ", ftos(self.cnt), ": Calculated velocity: ", vtos(self.spawnorigin - self.origin), ", time: ", ftos(time), "\n");
		self.velocity = (self.spawnorigin - self.origin) * (self.cnt - 1); // 1 or 0.5 second movement
		self.nextthink = time + 0.5;
		self.cnt += 1;
	}
	else	 // step 4
	{
//		dprint("Step 4: time: ", ftos(time), "\n");
		if(vlen(self.origin - self.spawnorigin) > 10)  // should not happen anymore
			dprint("The ball moved too far away from its spawn origin.\nOffset: ",
				   vtos(self.origin - self.spawnorigin), " Velocity: ", vtos(self.velocity), "\n");
		self.velocity = '0 0 0';
		setorigin(self, self.spawnorigin); // make sure it's positioned correctly anyway
		self.movetype = MOVETYPE_NONE;
		self.think = InitBall;
		self.nextthink = max(time, game_starttime) + autocvar_g_nexball_delay_start;
	}
}

void football_touch(void)
{
	if(other.solid == SOLID_BSP)
	{
		if(time > self.lastground + 0.1)
		{
			sound(self, CH_TRIGGER, self.noise, VOL_BASE, ATTEN_NORM);
			self.lastground = time;
		}
		if(vlen(self.velocity) && !self.cnt)
			self.nextthink = time + autocvar_g_nexball_delay_idle;
		return;
	}
	if (!IS_PLAYER(other))
		return;
	if(other.health < 1)
		return;
	if(!self.cnt)
		self.nextthink = time + autocvar_g_nexball_delay_idle;

	self.pusher = other;
	self.team = other.team;

	if(autocvar_g_nexball_football_physics == -1)	// MrBougo try 1, before decompiling Rev's original
	{
		if(vlen(other.velocity))
			self.velocity = other.velocity * 1.5 + '0 0 1' * autocvar_g_nexball_football_boost_up;
	}
	else if(autocvar_g_nexball_football_physics == 1)	  // MrBougo's modded Rev style: partially independant of the height of the aiming point
	{
		makevectors(other.v_angle);
		self.velocity = other.velocity + v_forward * autocvar_g_nexball_football_boost_forward + '0 0 1' * autocvar_g_nexball_football_boost_up;
	}
	else if(autocvar_g_nexball_football_physics == 2)	  // 2nd mod try: totally independant. Really playable!
	{
		makevectors(other.v_angle_y * '0 1 0');
		self.velocity = other.velocity + v_forward * autocvar_g_nexball_football_boost_forward + v_up * autocvar_g_nexball_football_boost_up;
	}
	else	 // Revenant's original style (from the original mod's disassembly, acknowledged by Revenant)
	{
		makevectors(other.v_angle);
		self.velocity = other.velocity + v_forward * autocvar_g_nexball_football_boost_forward + v_up * autocvar_g_nexball_football_boost_up;
	}
	self.avelocity = -250 * v_forward;  // maybe there is a way to make it look better?
}

void basketball_touch(void)
{
	if(other.ballcarried)
	{
		football_touch();
		return;
	}
	if(!self.cnt && IS_PLAYER(other) && !other.frozen && !other.deadflag && (other != self.nb_dropper || time > self.nb_droptime + autocvar_g_nexball_delay_collect))
	{
		if(other.health <= 0)
			return;
		LogNB("caught", other);
		GiveBall(other, self);
	}
	else if(other.solid == SOLID_BSP)
	{
		sound(self, CH_TRIGGER, self.noise, VOL_BASE, ATTEN_NORM);
		if(vlen(self.velocity) && !self.cnt)
			self.nextthink = min(time + autocvar_g_nexball_delay_idle, self.teamtime);
	}
}

void GoalTouch(void)
{
	entity ball;
	float isclient, pscore, otherteam;
	string pname;

	if(gameover) return;
	if((self.spawnflags & GOAL_TOUCHPLAYER) && other.ballcarried)
		ball = other.ballcarried;
	else
		ball = other;
	if(ball.classname != "nexball_basketball")
		if(ball.classname != "nexball_football")
			return;
	if((!ball.pusher && self.team != GOAL_OUT) || ball.cnt)
		return;
	EXACTTRIGGER_TOUCH;


	if(nb_teams == 2)
		otherteam = OtherTeam(ball.team);
	else
		otherteam = 0;

	if((isclient = IS_CLIENT(ball.pusher)))
		pname = ball.pusher.netname;
	else
		pname = "Someone (?)";

	if(ball.team == self.team)		 //owngoal (regular goals)
	{
		LogNB("owngoal", ball.pusher);
		bprint("Boo! ", pname, "^7 scored a goal against their own team!\n");
		pscore = -1;
	}
	else if(self.team == GOAL_FAULT)
	{
		LogNB("fault", ball.pusher);
		if(nb_teams == 2)
			bprint(Team_ColoredFullName(otherteam), " gets a point due to ", pname, "^7's silliness.\n");
		else
			bprint(Team_ColoredFullName(ball.team), " loses a point due to ", pname, "^7's silliness.\n");
		pscore = -1;
	}
	else if(self.team == GOAL_OUT)
	{
		LogNB("out", ball.pusher);
		if((self.spawnflags & GOAL_TOUCHPLAYER) && ball.owner)
			bprint(pname, "^7 went out of bounds.\n");
		else
			bprint("The ball was returned.\n");
		pscore = 0;
	}
	else							   //score
	{
		LogNB(strcat("goal:", ftos(self.team)), ball.pusher);
		bprint("Goaaaaal! ", pname, "^7 scored a point for the ", Team_ColoredFullName(ball.team), ".\n");
		pscore = 1;
	}

	sound(ball, CH_TRIGGER, self.noise, VOL_BASE, ATTEN_NONE);

	if(ball.team && pscore)
	{
		if(nb_teams == 2 && pscore < 0)
			TeamScore_AddToTeam(otherteam, ST_NEXBALL_GOALS, -pscore);
		else
			TeamScore_AddToTeam(ball.team, ST_NEXBALL_GOALS, pscore);
	}
	if(isclient)
	{
		if(pscore > 0)
			PlayerScore_Add(ball.pusher, SP_NEXBALL_GOALS, pscore);
		else if(pscore < 0)
			PlayerScore_Add(ball.pusher, SP_NEXBALL_FAULTS, -pscore);
	}

	if(ball.owner)  // Happens on spawnflag GOAL_TOUCHPLAYER
		DropBall(ball, ball.owner.origin, ball.owner.velocity);

	WaypointSprite_Ping(ball.waypointsprite_attachedforcarrier);

	ball.cnt = 1;
	ball.think = ResetBall;
	if(ball.classname == "nexball_basketball")
		ball.touch = football_touch; // better than func_null: football control until the ball gets reset
	ball.nextthink = time + autocvar_g_nexball_delay_goal * (self.team != GOAL_OUT);
}

//=======================//
//	   team ents	   //
//=======================//
void spawnfunc_nexball_team(void)
{
	if(!g_nexball)
	{
		remove(self);
		return;
	}
	self.team = self.cnt + 1;
}

void nb_spawnteam(string teamname, float teamcolor)
{
	dprint("^2spawned team ", teamname, "\n");
	entity e;
	e = spawn();
	e.classname = "nexball_team";
	e.netname = teamname;
	e.cnt = teamcolor;
	e.team = e.cnt + 1;
	nb_teams += 1;
}

void nb_spawnteams(void)
{
	float t_r = 0, t_b = 0, t_y = 0, t_p = 0;
	entity e;
	for(e = world; (e = find(e, classname, "nexball_goal"));)
	{
		switch(e.team)
		{
		case NUM_TEAM_1:
			if(!t_r)
			{
				nb_spawnteam(NAME_TEAM_1, e.team-1);
				t_r = 1;
			}
			break;
		case NUM_TEAM_2:
			if(!t_b)
			{
				nb_spawnteam(NAME_TEAM_2, e.team-1);
				t_b = 1;
			}
			break;
		case NUM_TEAM_3:
			if(!t_y)
			{
				nb_spawnteam(NAME_TEAM_3, e.team-1);
				t_y = 1;
			}
			break;
		case NUM_TEAM_4:
			if(!t_p)
			{
				nb_spawnteam(NAME_TEAM_4, e.team-1);
				t_p = 1;
			}
			break;
		}
	}
}

// scoreboard setup
void nb_ScoreRules(float teams)
{
	ScoreRules_basics(teams, 0, 0, TRUE);
	ScoreInfo_SetLabel_TeamScore(   ST_NEXBALL_GOALS,  "goals", SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore( SP_NEXBALL_GOALS,  "goals", SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore(SP_NEXBALL_FAULTS, "faults", SFL_SORT_PRIO_SECONDARY | SFL_LOWER_IS_BETTER);
	ScoreRules_basics_end();
}

void nb_delayedinit(void)
{
	if(find(world, classname, "nexball_team") == world)
		nb_spawnteams();
	nb_ScoreRules(nb_teams);
}


//=======================//
//	  spawnfuncs	   //
//=======================//

void SpawnBall(void)
{
	if(!g_nexball) { remove(self); return; }

//	balls += 4; // using the remaining bits to count balls will leave more than the max edict count, so it's fine

	if(self.model == "")
	{
		self.model = "models/nexball/ball.md3";
		self.scale = 1.3;
	}

	precache_model(self.model);
	setmodel(self, self.model);
	setsize(self, BALL_MINS, BALL_MAXS);
	ball_scale = self.scale;

	relocate_nexball();
	self.spawnorigin = self.origin;

	self.effects = self.effects | EF_LOWPRECISION;

	if(cvar(strcat("g_", self.classname, "_trail")))  //nexball_basketball :p
	{
		self.glow_color = autocvar_g_nexball_trail_color;
		self.glow_trail = TRUE;
	}

	self.movetype = MOVETYPE_FLY;

	if(!autocvar_g_nexball_sound_bounce)
		self.noise = "";
	else if(self.noise == "")
		self.noise = "sound/nexball/bounce.wav";
	//bounce sound placeholder (FIXME)
	if(self.noise1 == "")
		self.noise1 = "sound/nexball/drop.wav";
	//ball drop sound placeholder (FIXME)
	if(self.noise2 == "")
		self.noise2 = "sound/nexball/steal.wav";
	//stealing sound placeholder (FIXME)
	if(self.noise) precache_sound(self.noise);
	precache_sound(self.noise1);
	precache_sound(self.noise2);

	WaypointSprite_AttachCarrier("nb-ball", self, RADARICON_FLAGCARRIER, BALL_SPRITECOLOR); // the ball's team is not set yet, no rule update needed

	self.reset = ball_restart;
	self.think = InitBall;
	self.nextthink = game_starttime + autocvar_g_nexball_delay_start;
}

void spawnfunc_nexball_basketball(void)
{
	nexball_mode |= NBM_BASKETBALL;
	self.classname = "nexball_basketball";
	if (!(balls & BALL_BASKET))
	{
		/*
		CVTOV(g_nexball_basketball_effects_default);
		CVTOV(g_nexball_basketball_delay_hold);
		CVTOV(g_nexball_basketball_delay_hold_forteam);
		CVTOV(g_nexball_basketball_teamsteal);
		*/
		autocvar_g_nexball_basketball_effects_default = autocvar_g_nexball_basketball_effects_default & BALL_EFFECTMASK;
	}
	if(!self.effects)
		self.effects = autocvar_g_nexball_basketball_effects_default;
	self.solid = SOLID_TRIGGER;
	balls |= BALL_BASKET;
	self.bouncefactor = autocvar_g_nexball_basketball_bouncefactor;
	self.bouncestop = autocvar_g_nexball_basketball_bouncestop;
	SpawnBall();
}

void spawnfunc_nexball_football(void)
{
	nexball_mode |= NBM_FOOTBALL;
	self.classname = "nexball_football";
	self.solid = SOLID_TRIGGER;
	balls |= BALL_FOOT;
	self.bouncefactor = autocvar_g_nexball_football_bouncefactor;
	self.bouncestop = autocvar_g_nexball_football_bouncestop;
	SpawnBall();
}

float nb_Goal_Customize()
{
	entity e, wp_owner;
	e = WaypointSprite_getviewentity(other);
	wp_owner = self.owner;
	if(SAME_TEAM(e, wp_owner)) { return FALSE; }

	return TRUE;
}

void SpawnGoal(void)
{
	if(!g_nexball) { remove(self); return; }

	EXACTTRIGGER_INIT;

	if(self.team != GOAL_OUT && Team_TeamToNumber(self.team) != -1)
	{
		WaypointSprite_SpawnFixed("goal", (self.absmin + self.absmax) * 0.5, self, sprite, RADARICON_NONE, ((self.team) ? Team_ColorRGB(self.team) : '1 0.5 0'));
		self.sprite.customizeentityforclient = nb_Goal_Customize;
	}

	self.classname = "nexball_goal";
	if(self.noise == "")
		self.noise = "ctf/respawn.wav";
	precache_sound(self.noise);
	self.touch = GoalTouch;
}

void spawnfunc_nexball_redgoal(void)
{
	self.team = NUM_TEAM_1;
	SpawnGoal();
}
void spawnfunc_nexball_bluegoal(void)
{
	self.team = NUM_TEAM_2;
	SpawnGoal();
}
void spawnfunc_nexball_yellowgoal(void)
{
	self.team = NUM_TEAM_3;
	SpawnGoal();
}
void spawnfunc_nexball_pinkgoal(void)
{
	self.team = NUM_TEAM_4;
	SpawnGoal();
}

void spawnfunc_nexball_fault(void)
{
	self.team = GOAL_FAULT;
	if(self.noise == "")
		self.noise = "misc/typehit.wav";
	SpawnGoal();
}

void spawnfunc_nexball_out(void)
{
	self.team = GOAL_OUT;
	if(self.noise == "")
		self.noise = "misc/typehit.wav";
	SpawnGoal();
}

//
//Spawnfuncs preserved for compatibility
//

void spawnfunc_ball(void)
{
	spawnfunc_nexball_football();
}
void spawnfunc_ball_football(void)
{
	spawnfunc_nexball_football();
}
void spawnfunc_ball_basketball(void)
{
	spawnfunc_nexball_basketball();
}
// The "red goal" is defended by blue team. A ball in there counts as a point for red.
void spawnfunc_ball_redgoal(void)
{
	spawnfunc_nexball_bluegoal();	// I blame Revenant
}
void spawnfunc_ball_bluegoal(void)
{
	spawnfunc_nexball_redgoal();	// but he didn't mean to cause trouble :p
}
void spawnfunc_ball_fault(void)
{
	spawnfunc_nexball_fault();
}
void spawnfunc_ball_bound(void)
{
	spawnfunc_nexball_out();
}

//=======================//
//	  Weapon code	  //
//=======================//


void W_Nexball_Think()
{
	//dprint("W_Nexball_Think\n");
	//vector new_dir = steerlib_arrive(self.enemy.origin, 2500);
	vector new_dir = normalize(self.enemy.origin + '0 0 50' - self.origin);
	vector old_dir = normalize(self.velocity);
	float _speed = vlen(self.velocity);
	vector new_vel = normalize(old_dir + (new_dir * autocvar_g_nexball_safepass_turnrate)) * _speed;
	//vector new_vel = (new_dir * autocvar_g_nexball_safepass_turnrate

	self.velocity = new_vel;

	self.nextthink = time;
}

void W_Nexball_Touch(void)
{
	entity ball, attacker;
	attacker = self.owner;
	//self.think = func_null;
	//self.enemy = world;

	PROJECTILE_TOUCH;
	if(attacker.team != other.team || autocvar_g_nexball_basketball_teamsteal)
		if((ball = other.ballcarried) && !other.frozen && !other.deadflag && (IS_PLAYER(attacker)))
		{
			other.velocity = other.velocity + normalize(self.velocity) * other.damageforcescale * autocvar_g_balance_nexball_secondary_force;
			other.flags &= ~FL_ONGROUND;
			if(!attacker.ballcarried)
			{
				LogNB("stole", attacker);
				sound(other, CH_TRIGGER, ball.noise2, VOL_BASE, ATTEN_NORM);

				if(attacker.team == other.team && time > attacker.teamkill_complain)
				{
					attacker.teamkill_complain = time + 5;
					attacker.teamkill_soundtime = time + 0.4;
					attacker.teamkill_soundsource = other;
				}

				GiveBall(attacker, other.ballcarried);
			}
		}
	remove(self);
}

void W_Nexball_Attack(float t)
{
	entity ball;
	float mul, mi, ma;
	if(!(ball = self.ballcarried))
		return;

	W_SetupShot(self, FALSE, 4, "nexball/shoot1.wav", CH_WEAPON_A, 0);
	tracebox(w_shotorg, BALL_MINS, BALL_MAXS, w_shotorg, MOVE_WORLDONLY, world);
	if(trace_startsolid)
	{
		if(self.metertime)
			self.metertime = 0; // Shot failed, hide the power meter
		return;
	}

	//Calculate multiplier
	if(t < 0)
		mul = 1;
	else
	{
		mi = autocvar_g_nexball_basketball_meter_minpower;
		ma = max(mi, autocvar_g_nexball_basketball_meter_maxpower); // avoid confusion
		//One triangle wave period with 1 as max
		mul = 2 * mod(t, g_nexball_meter_period) / g_nexball_meter_period;
		if(mul > 1)
			mul = 2 - mul;
		mul = mi + (ma - mi) * mul; // range from the minimal power to the maximal power
	}

	DropBall(ball, w_shotorg, W_CalculateProjectileVelocity(self.velocity, w_shotdir * autocvar_g_balance_nexball_primary_speed * mul, FALSE));


	//TODO: use the speed_up cvar too ??
}

void W_Nexball_Attack2(void)
{
	if(self.ballcarried.enemy)
	{
		entity _ball = self.ballcarried;
		W_SetupShot(self, FALSE, 4, "nexball/shoot1.wav", CH_WEAPON_A, 0);
		DropBall(_ball, w_shotorg, trigger_push_calculatevelocity(_ball.origin, _ball.enemy, 32));
		_ball.think = W_Nexball_Think;
		_ball.nextthink = time;
		return;
	}

	if(!autocvar_g_nexball_tackling)
		return;

	entity missile;
	if(!(balls & BALL_BASKET))
		return;
	W_SetupShot(self, FALSE, 2, "nexball/shoot2.wav", CH_WEAPON_A, 0);
	missile = spawn();

	missile.owner = self;
	missile.classname = "ballstealer";

	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);

	//setmodel(missile, "models/elaser.mdl");  // precision set below
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, w_shotorg);

	W_SetupProjVelocity_Basic(missile, autocvar_g_balance_nexball_secondary_speed, 0);
	missile.angles = vectoangles(missile.velocity);
	missile.touch = W_Nexball_Touch;
	missile.think = SUB_Remove;
	missile.nextthink = time + autocvar_g_balance_nexball_secondary_lifetime; //FIXME: use a distance instead?

	missile.effects = EF_BRIGHTFIELD | EF_LOWPRECISION;
	missile.flags = FL_PROJECTILE;

	CSQCProjectile(missile, TRUE, PROJECTILE_ELECTRO, TRUE);
}

float ball_customize()
{
	if(!self.owner)
	{
		self.effects &= ~EF_FLAME;
		self.scale = 1;
		self.customizeentityforclient = func_null;
		return TRUE;
	}

	if(other == self.owner)
	{
		self.scale = autocvar_g_nexball_viewmodel_scale;
		if(self.enemy)
			self.effects |= EF_FLAME;
		else
			self.effects &= ~EF_FLAME;
	}
	else
	{
		self.effects &= ~EF_FLAME;
		self.scale = 1;
	}

	return TRUE;
}

float w_nexball_weapon(float req)
{
	if(req == WR_THINK)
	{
		if(self.BUTTON_ATCK)
			if(weapon_prepareattack(0, autocvar_g_balance_nexball_primary_refire))
				if(autocvar_g_nexball_basketball_meter)
				{
					if(self.ballcarried && !self.metertime)
						self.metertime = time;
					else
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_nexball_primary_animtime, w_ready);
				}
				else
				{
					W_Nexball_Attack(-1);
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_nexball_primary_animtime, w_ready);
				}
		if(self.BUTTON_ATCK2)
			if(weapon_prepareattack(1, autocvar_g_balance_nexball_secondary_refire))
			{
				W_Nexball_Attack2();
				weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_nexball_secondary_animtime, w_ready);
			}

		if(!self.BUTTON_ATCK && self.metertime && self.ballcarried)
		{
			W_Nexball_Attack(time - self.metertime);
			// DropBall or stealing will set metertime back to 0
			weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_nexball_primary_animtime, w_ready);
		}
	}
	else if(req == WR_INIT)
	{
		precache_model("models/weapons/g_porto.md3");
		precache_model("models/weapons/v_porto.md3");
		precache_model("models/weapons/h_porto.iqm");
		precache_model("models/elaser.mdl");
		precache_sound("nexball/shoot1.wav");
		precache_sound("nexball/shoot2.wav");
		precache_sound("misc/typehit.wav");
	}
	else if(req == WR_SETUP)
	{
		//weapon_setup(WEP_PORTO);
	}
	// No need to check WR_CHECKAMMO* or WR_AIM, it should always return TRUE
	return TRUE;
}

MUTATOR_HOOKFUNCTION(nexball_BallDrop)
{
	if(self.ballcarried && g_nexball)
		DropBall(self.ballcarried, self.origin, self.velocity);

	return 0;
}

MUTATOR_HOOKFUNCTION(nexball_PlayerPreThink)
{
	makevectors(self.v_angle);
	if(nexball_mode & NBM_BASKETBALL)
	{
		if(self.ballcarried)
		{
			// 'view ball'
			self.ballcarried.velocity = self.velocity;
			self.ballcarried.customizeentityforclient = ball_customize;

			setorigin(self.ballcarried, self.origin + self.view_ofs +
					  v_forward * autocvar_g_nexball_viewmodel_offset_x +
					  v_right * autocvar_g_nexball_viewmodel_offset_y +
					  v_up * autocvar_g_nexball_viewmodel_offset_z);

			// 'safe passing'
			if(autocvar_g_nexball_safepass_maxdist)
			{
				if(self.ballcarried.wait < time && self.ballcarried.enemy)
				{
					//centerprint(self, sprintf("Lost lock on %s", self.ballcarried.enemy.netname));
					self.ballcarried.enemy = world;
				}


				//tracebox(self.origin + self.view_ofs, '-2 -2 -2', '2 2 2', self.origin + self.view_ofs + v_forward * autocvar_g_nexball_safepass_maxdist);
				crosshair_trace(self);
				if( trace_ent &&
					IS_CLIENT(trace_ent) &&
					trace_ent.deadflag == DEAD_NO &&
					trace_ent.team == self.team &&
					vlen(trace_ent.origin - self.origin) <= autocvar_g_nexball_safepass_maxdist )
				{

					//if(self.ballcarried.enemy != trace_ent)
					//	centerprint(self, sprintf("Locked to %s", trace_ent.netname));
					self.ballcarried.enemy = trace_ent;
					self.ballcarried.wait = time + autocvar_g_nexball_safepass_holdtime;


				}
			}
		}
		else
		{
			if(self.weaponentity.weapons)
			{
				self.weapons = self.weaponentity.weapons;
				WEP_ACTION(WEP_PORTO, WR_RESETPLAYER);
				self.switchweapon = self.weaponentity.switchweapon;
				W_SwitchWeapon(self.switchweapon);

		self.weaponentity.weapons = '0 0 0';
			}
		}

	}

	nexball_setstatus();

	return FALSE;
}

MUTATOR_HOOKFUNCTION(nexball_PlayerSpawn)
{
	self.weaponentity.weapons = '0 0 0';

	if(nexball_mode & NBM_BASKETBALL)
		self.weapons |= WEPSET_PORTO;
	else
		self.weapons = '0 0 0';

	return FALSE;
}

MUTATOR_HOOKFUNCTION(nexball_PlayerPhysics)
{
	if(self.ballcarried)
	{
		self.stat_sv_airspeedlimit_nonqw *= autocvar_g_nexball_basketball_carrier_highspeed;
		self.stat_sv_maxspeed *= autocvar_g_nexball_basketball_carrier_highspeed;
	}
	return FALSE;
}

MUTATOR_HOOKFUNCTION(nexball_SetStartItems)
{
	start_items |= IT_UNLIMITED_SUPERWEAPONS; // FIXME BAD BAD BAD BAD HACK, NEXBALL SHOULDN'T ABUSE PORTO'S WEAPON SLOT

	return FALSE;
}

MUTATOR_HOOKFUNCTION(nexball_GetTeamCount)
{
	ret_string = "nexball_team";
	return TRUE;
}

MUTATOR_HOOKFUNCTION(nexball_ForbidThrowing)
{
	if(self.weapon == WEP_MORTAR)
		return TRUE;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(nexball_FilterItem)
{
	if(self.classname == "droppedweapon")
	if(self.weapon == WEP_MORTAR)
		return TRUE;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(nexball_WantWeapon)
{
	ret_float = 0; // weapon is set a few lines later
	return FALSE;
}

MUTATOR_HOOKFUNCTION(nexball_AllowMobSpawning)
{
	ret_string = "You cannot spawn monsters in nexball!";
	return TRUE;
}

MUTATOR_DEFINITION(gamemode_nexball)
{
	MUTATOR_HOOK(PlayerDies, nexball_BallDrop, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, nexball_BallDrop, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, nexball_BallDrop, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, nexball_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, nexball_PlayerPreThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPhysics, nexball_PlayerPhysics, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetStartItems, nexball_SetStartItems, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetTeamCount, nexball_GetTeamCount, CBC_ORDER_ANY);
	MUTATOR_HOOK(ForbidThrowCurrentWeapon, nexball_ForbidThrowing, CBC_ORDER_ANY);
	MUTATOR_HOOK(FilterItem, nexball_FilterItem, CBC_ORDER_ANY);
	MUTATOR_HOOK(WantWeapon, nexball_WantWeapon, CBC_ORDER_ANY);
	MUTATOR_HOOK(AllowMobSpawning, nexball_AllowMobSpawning, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		g_nexball_meter_period = autocvar_g_nexball_meter_period;
		if(g_nexball_meter_period <= 0)
			g_nexball_meter_period = 2; // avoid division by zero etc. due to silly users
		g_nexball_meter_period = rint(g_nexball_meter_period * 32) / 32; //Round to 1/32ths to send as a byte multiplied by 32
		addstat(STAT_NB_METERSTART, AS_FLOAT, metertime);

		// General settings
		/*
		CVTOV(g_nexball_football_boost_forward);   //100
		CVTOV(g_nexball_football_boost_up);		//200
		CVTOV(g_nexball_delay_idle);			   //10
		CVTOV(g_nexball_football_physics);		 //0
		*/
		radar_showennemies = autocvar_g_nexball_radar_showallplayers;

		InitializeEntity(world, nb_delayedinit, INITPRIO_GAMETYPE);
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back nb_delayedinit here
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
