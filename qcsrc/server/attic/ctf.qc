#define FLAG_MIN (PL_MIN + '0 0 -13')
#define FLAG_MAX (PL_MAX + '0 0 -13')

.entity basewaypoint;
.entity sprite;
entity ctf_worldflaglist; // CTF flags in the map
.entity ctf_worldflagnext;
.float dropperid;
.float ctf_droptime;

.float next_take_time;			// the next time a player can pick up a flag (time + blah)
								/// I used this, in part, to fix the looping score bug. - avirox
//float FLAGSCORE_PICKUP        =  1;
//float FLAGSCORE_RETURN        =  5; // returned by owner team
//float FLAGSCORE_RETURNROGUE   = 10; // returned by rogue team
//float FLAGSCORE_CAPTURE       =  5;

#define FLAG_CARRY_POS '-15 0 7'

.float ctf_captureshielded; // set to 1 if the player is too bad to be allowed to capture

float captureshield_min_negscore; // punish at -20 points
float captureshield_max_ratio; // punish at most 30% of each team
float captureshield_force; // push force of the shield

float ctf_captureshield_shielded(entity p)
{
	float s, se;
	entity e;
	float players_worseeq, players_total;

	if(captureshield_max_ratio <= 0)
		return FALSE;

	s = PlayerScore_Add(p, SP_SCORE, 0);
	if(s >= -captureshield_min_negscore)
		return FALSE;

	players_total = players_worseeq = 0;
	FOR_EACH_PLAYER(e)
	{
		if(e.team != p.team)
			continue;
		se = PlayerScore_Add(e, SP_SCORE, 0);
		if(se <= s)
			++players_worseeq;
		++players_total;
	}

	// player is in the worse half, if >= half the players are better than him, or consequently, if < half of the players are worse
	// use this rule here

	if(players_worseeq >= players_total * captureshield_max_ratio)
		return FALSE;

	return TRUE;
}

void ctf_captureshield_update(entity p, float dir)
{
	float should;
	if(dir == p.ctf_captureshielded) // 0: shield only, 1: unshield only
	{
		should = ctf_captureshield_shielded(p);
		if(should != dir)
		{
			if(should)
			{
				Send_CSQC_Centerprint_Generic(other, CPID_CTF_CAPTURESHIELD, "^3You are ^4shielded^3 from the flag\n^3for ^1too many unsuccessful attempts^3 to capture.\n\n^3Get some defensive scores before trying again.", 5, 0);
				// TODO csqc notifier for this
			}
			else
			{
				Send_CSQC_Centerprint_Generic(p, CPID_CTF_CAPTURESHIELD, "^3You are now free.\n\n^3Feel free to ^1try to capture^3 the flag again\n^3if you think you will succeed.", 5, 0);
				// TODO csqc notifier for this
			}
			p.ctf_captureshielded = should;
		}
	}
}

float ctf_captureshield_customize()
{
	if not(other.ctf_captureshielded)
		return FALSE;
	if(self.team == other.team)
		return FALSE;
	return TRUE;
}

.float ctf_captureshield_touch_msgtime;
void ctf_captureshield_touch()
{
	if not(other.ctf_captureshielded)
		return;
	if(self.team == other.team)
		return;
	vector mymid;
	vector othermid;
	mymid = (self.absmin + self.absmax) * 0.5;
	othermid = (other.absmin + other.absmax) * 0.5;
	Damage(other, self, self, 0, DEATH_HURTTRIGGER, mymid, normalize(othermid - mymid) * captureshield_force);
	if (time - other.ctf_captureshield_touch_msgtime > 2)
		Send_CSQC_Centerprint_Generic(other, CPID_CTF_CAPTURESHIELD, "^3You are ^4shielded^3 from the flag\n^3for ^1too many unsuccessful attempts^3 to capture.\n\n^3Get some defensive scores before trying again.", 5, 0);
	other.ctf_captureshield_touch_msgtime = time;
}

void ctf_flag_spawnstuff()
{
	entity e;
	e = spawn();
	e.enemy = self;
	e.team = self.team;
	e.touch = ctf_captureshield_touch;
	e.customizeentityforclient = ctf_captureshield_customize;
	e.classname = "ctf_captureshield";
	e.effects = EF_ADDITIVE;
	e.movetype = MOVETYPE_NOCLIP;
	e.solid = SOLID_TRIGGER;
	e.avelocity = '7 0 11';
	setorigin(e, self.origin);
	setmodel(e, "models/ctf/shield.md3");
	e.scale = 0.5;
	setsize(e, e.scale * e.mins, e.scale * e.maxs);

	waypoint_spawnforitem_force(self, self.origin);
	self.nearestwaypointtimeout = 0; // activate waypointing again
	self.basewaypoint = self.nearestwaypoint;

	if(self.team == NUM_TEAM_1)
		WaypointSprite_SpawnFixed("redbase", self.origin + '0 0 61', self, sprite, RADARICON_FLAG, colormapPaletteColor(NUM_TEAM_1 - 1, FALSE));
	else
		WaypointSprite_SpawnFixed("bluebase", self.origin + '0 0 61', self, sprite, RADARICON_FLAG, colormapPaletteColor(NUM_TEAM_2 - 1, FALSE));
}

float ctf_score_value(string parameter)
{
	return cvar(strcat("g_ctf_personal", parameter));
}

void FakeTimeLimit(entity e, float t)
{
	msg_entity = e;
	WriteByte(MSG_ONE, 3); // svc_updatestat
	WriteByte(MSG_ONE, 236); // STAT_TIMELIMIT
	if(t < 0)
		WriteCoord(MSG_ONE, autocvar_timelimit);
	else
		WriteCoord(MSG_ONE, (t + 1) / 60);
}

float   flagcaptimerecord;
.float  flagpickuptime;
//.float  iscommander;
//.float  ctf_state;

void() FlagThink;
void() FlagTouch;

void place_flag()
{
	if(self.classname != "item_flag_team")
	{
		backtrace("PlaceFlag a non-flag");
		return;
	}

	setattachment(self, world, "");
	self.mdl = self.model;
	self.flags = FL_ITEM | FL_NOTARGET;
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.origin_z = self.origin_z + 6;
	self.think = FlagThink;
	self.touch = FlagTouch;
	self.nextthink = time + 0.1;
	self.cnt = FLAG_BASE;
	self.mangle = self.angles;
	self.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP | DPCONTENTS_BOTCLIP;
	//self.effects = self.effects | EF_DIMLIGHT;
	if(self.noalign)
	{
		self.dropped_origin = self.origin;
	}
	else
	{
		droptofloor();
		self.movetype = MOVETYPE_TOSS;
	}

	InitializeEntity(self, ctf_flag_spawnstuff, INITPRIO_SETLOCATION);
}

void LogCTF(string mode, float flagteam, entity actor)
{
	string s;
	if(!autocvar_sv_eventlog)
		return;
	s = strcat(":ctf:", mode);
	s = strcat(s, ":", ftos(flagteam));
	if(actor != world)
		s = strcat(s, ":", ftos(actor.playerid));
	GameLogEcho(s);
}

void RegenFlag(entity e)
{
	if(e.classname != "item_flag_team")
	{
		backtrace("RegenFlag a non-flag");
		return;
	}

	if(e.waypointsprite_attachedforcarrier)
		WaypointSprite_DetachCarrier(e);

	setattachment(e, world, "");
	e.damageforcescale = 0;
	e.takedamage = DAMAGE_NO;
	e.movetype = MOVETYPE_NONE;
	if(!e.noalign)
		e.movetype = MOVETYPE_TOSS;
	e.velocity = '0 0 0';
	e.solid = SOLID_TRIGGER;
	// TODO: play a sound here
	setorigin(e, e.dropped_origin);
	e.angles = e.mangle;
	e.cnt = FLAG_BASE;
	e.owner = world;
	e.flags = FL_ITEM | FL_NOTARGET; // clear FL_ONGROUND and any other junk
}

void ReturnFlag(entity e)
{
	if(e.classname != "item_flag_team")
	{
		backtrace("ReturnFlag a non-flag");
		return;
	}

	if (e.owner)
	if (e.owner.flagcarried == e)
	{
		WaypointSprite_DetachCarrier(e.owner);
		e.owner.flagcarried = world;

		if(e.speedrunning)
			FakeTimeLimit(e.owner, -1);
	}
	e.owner = world;
	RegenFlag(e);
}

void DropFlag(entity e, entity penalty_receiver, entity attacker)
{
	entity p;

	if(e.classname != "item_flag_team")
	{
		backtrace("DropFlag a non-flag");
		return;
	}

	if(e.speedrunning)
	{
		ReturnFlag(e);
		return;
	}

	if (!e.owner)
	{
		dprint("FLAG: drop - no owner?!?!\n");
		return;
	}
	p = e.owner;
	if (p.flagcarried != e)
	{
		dprint("FLAG: drop - owner is not carrying this flag??\n");
		return;
	}
	//bprint(p.netname, "^7 lost the ", e.netname, "\n");
	Send_KillNotification (p.netname, e.netname, "", INFO_LOSTFLAG, MSG_INFO);

	if(penalty_receiver)
		UpdateFrags(penalty_receiver, -ctf_score_value("penalty_suicidedrop"));
	else
		UpdateFrags(p, -ctf_score_value("penalty_drop"));
	PlayerScore_Add(p, SP_CTF_DROPS, +1);
	ctf_captureshield_update(p, 0); // shield only
	e.playerid = attacker.playerid;
	e.ctf_droptime = time;
	WaypointSprite_Spawn("flagdropped", 0, 0, e, '0 0 1' * 61, world, NUM_TEAM_1 + NUM_TEAM_2 - e.team, e, waypointsprite_attachedforcarrier, FALSE, RADARICON_FLAG, '0 1 1');
	WaypointSprite_Ping(e.waypointsprite_attachedforcarrier);
	
	if(p.waypointsprite_attachedforcarrier)
	{
		WaypointSprite_DetachCarrier(p);
	}
	else
	{
		bprint("\{1}^1Flag carrier had no flag sprite?!?\n");
		backtrace("Flag carrier had no flag sprite?!?");
	}
	LogCTF("dropped", p.team, p);
	sound (p, CH_TRIGGER, self.noise4, VOL_BASE, ATTN_NONE);

	setattachment(e, world, "");
	e.damageforcescale = autocvar_g_balance_ctf_damageforcescale;
	e.takedamage = DAMAGE_YES;

	if (p.flagcarried == e)
		p.flagcarried = world;
	e.owner = world;

	e.flags = FL_ITEM | FL_NOTARGET; // clear FL_ONGROUND and any other junk
	e.solid = SOLID_TRIGGER;
	e.movetype = MOVETYPE_TOSS;
	// setsize(e, '-16 -16 0', '16 16 74');
	setorigin(e, p.origin - '0 0 24' + '0 0 37');
	e.cnt = FLAG_DROPPED;
	e.velocity = '0 0 300';
	e.pain_finished = time + autocvar_g_ctf_flag_returntime;//30;

	trace_startsolid = FALSE;
	tracebox(e.origin, e.mins, e.maxs, e.origin, TRUE, e);
	if(trace_startsolid)
		dprint("FLAG FALLTHROUGH will happen SOON\n");
}

void FlagThink()
{
	entity e;

	self.nextthink = time + 0.1;

	// sorry, we have to reset the flag size if it got squished by something
	if(self.mins != FLAG_MIN || self.maxs != FLAG_MAX)
	{
		// if we can grow back, grow back
		tracebox(self.origin, FLAG_MIN, FLAG_MAX, self.origin, MOVE_NOMONSTERS, self);
		if(!trace_startsolid)
			setsize(self, FLAG_MIN, FLAG_MAX);
	}

	if(self == ctf_worldflaglist) // only for the first flag
	{
		FOR_EACH_CLIENT(e)
			ctf_captureshield_update(e, 1); // release shield only
	}

	if(self.speedrunning)
	if(self.cnt == FLAG_CARRY)
	{
		if(self.owner)
		if(flagcaptimerecord)
		if(time >= self.flagpickuptime + flagcaptimerecord)
		{
			bprint("The ", self.netname, " became impatient after ", ftos_decimals(flagcaptimerecord, 2), " seconds and returned itself\n");

			sound (self, CH_TRIGGER, self.noise3, VOL_BASE, ATTN_NONE);
			self.owner.impulse = 141; // returning!

			e = self;
			self = self.owner;
			ReturnFlag(e);
			ImpulseCommands();
			self = e;
			return;
		}
	}

	if (self.cnt == FLAG_BASE)
		return;

	if (self.cnt == FLAG_DROPPED)
	{
		// flag fallthrough? FIXME remove this if bug is really fixed now
		if(self.origin_z < -131072)
		{
			dprint("FLAG FALLTHROUGH just happened\n");
			self.pain_finished = 0;
		}
		setattachment(self, world, "");
		if (time > self.pain_finished)
		{
			bprint("The ", self.netname, " has returned to base\n");
			sound (self, CH_TRIGGER, self.noise3, VOL_BASE, ATTN_NONE);
			LogCTF("returned", self.team, world);
			ReturnFlag(self);
		}
		return;
	}

	e = self.owner;
	if (e.classname != "player" || (e.deadflag) || (e.flagcarried != self))
	{
		dprint("CANNOT HAPPEN - player dead and STILL had a flag!\n");
		DropFlag(self, world, world);
		return;
	}
}

float ctf_usekey()
{
	if(self.flagcarried)
	{
		DropFlag(self.flagcarried, self, world);
		return TRUE;
	}
	return FALSE;
}

void flag_cap_ring_spawn(vector org)
{
	shockwave_spawn("models/ctf/shockwavetransring.md3", org - '0 0 15', -0.8, 0, 1);
}

// TODO add FlagDamage, replace weird hurttrigger handling inside trigger_hurt code by it
void FlagTouch()
{
	if(gameover) return;

	float t;
	entity player;
	string s, s0, h0, h1;

	if (self.cnt == FLAG_CARRY)
		return;

	if (self.cnt == FLAG_DROPPED)
	{
		if(ITEM_TOUCH_NEEDKILL())
		{
			self.pain_finished = 0; // return immediately
			return;
		}
	}

	if (other.classname != "player")
		return;
	if (other.health < 1) // ignore dead players
		return;

	if (self.cnt == FLAG_BASE)
	if (other.team == self.team)
	if (other.flagcarried) // he's got a flag
	if (other.flagcarried.team != self.team) // capture
	{
		if (other.flagcarried == world)
		{
			return;
		}
		if(autocvar_g_ctf_captimerecord_always || player_count - currentbots <= 1) // at most one human
		{
			t = time - other.flagcarried.flagpickuptime;
			s = ftos_decimals(t, 2);
			s0 = ftos_decimals(flagcaptimerecord, 2);
			h0 = db_get(ServerProgsDB, strcat(GetMapname(), "/captimerecord/netname"));
			h1 = other.netname;
			if(h0 == h1)
				h0 = "their";
			else
				h0 = strcat(h0, "^7's"); // h0: display text for previous netname
			if (flagcaptimerecord == 0)
			{
				s = strcat(" in ", s, " seconds");
				flagcaptimerecord = t;
				db_put(ServerProgsDB, strcat(GetMapname(), "/captimerecord/time"), ftos(t));
				db_put(ServerProgsDB, strcat(GetMapname(), "/captimerecord/netname"), h1);
				write_recordmarker(other, time - t, t);
			}
			else if (t < flagcaptimerecord)
			{
				s = strcat(" in ", s, " seconds, breaking ", h0, " previous record of ", s0, " seconds");
				flagcaptimerecord = t;
				db_put(ServerProgsDB, strcat(GetMapname(), "/captimerecord/time"), ftos(t));
				db_put(ServerProgsDB, strcat(GetMapname(), "/captimerecord/netname"), h1);
				write_recordmarker(other, time - t, t);
			}
			else
			{
				s = strcat(" in ", s, " seconds, failing to break ", h0, " record of ", s0, " seconds");
			}
		}
		else
			s = "";

		Send_KillNotification (other.netname, other.flagcarried.netname, s, INFO_CAPTUREFLAG, MSG_INFO);

		PlayerTeamScore_Add(other, SP_CTF_CAPS, ST_CTF_CAPS, 1);
		LogCTF("capture", other.flagcarried.team, other);
		// give credit to the individual player
		UpdateFrags(other, ctf_score_value("score_capture"));

		if (autocvar_g_ctf_flag_capture_effects) {
			if (other.team == NUM_TEAM_1) { // red team scores effect
				pointparticles(particleeffectnum("red_ground_quake"), self.origin, '0 0 0', 1);
				flag_cap_ring_spawn(self.origin);
			}
			if (other.team == NUM_TEAM_2) { // blue team scores effect
				pointparticles(particleeffectnum("blue_ground_quake"), self.origin, '0 0 0', 1);
				flag_cap_ring_spawn(self.origin);
			}
		}

		sound (other, CH_TRIGGER, self.noise2, VOL_BASE, ATTN_NONE);
		WaypointSprite_DetachCarrier(other);
		if(self.speedrunning)
			FakeTimeLimit(other, -1);
		RegenFlag (other.flagcarried);
		other.flagcarried = world;
		other.next_take_time = time + 1;
	}
	if (self.cnt == FLAG_BASE)
	if (other.team == NUM_TEAM_1 || other.team == NUM_TEAM_2) // only red and blue team can steal flags
	if (other.team != self.team)
	if (!other.flagcarried)
	if (!other.ctf_captureshielded)
	{
		if(MUTATOR_CALLHOOK(ItemTouch))
			return;
		
		if (other.next_take_time > time)
			return;

		if (autocvar_g_ctf_flag_pickup_effects) // pickup effect
			pointparticles(particleeffectnum("smoke_ring"), 0.5 * (self.absmin + self.absmax), '0 0 0', 1);

		// pick up
		self.flagpickuptime = time; // used for timing runs
		self.speedrunning = other.speedrunning; // if speedrunning, flag will self-return and teleport the owner back after the record
		if(other.speedrunning)
		if(flagcaptimerecord)
			FakeTimeLimit(other, time + flagcaptimerecord);
		self.solid = SOLID_NOT;
		setorigin(self, self.origin); // relink
		self.owner = other;
		other.flagcarried = self;
		self.cnt = FLAG_CARRY;
		self.angles = '0 0 0';
		//bprint(other.netname, "^7 got the ", self.netname, "\n");
		Send_KillNotification (other.netname, self.netname, "", INFO_GOTFLAG, MSG_INFO);
		UpdateFrags(other, ctf_score_value("score_pickup_base"));
		self.dropperid = other.playerid;
		PlayerScore_Add(other, SP_CTF_PICKUPS, 1);
		LogCTF("steal", self.team, other);
		sound (other, CH_TRIGGER, self.noise, VOL_BASE, ATTN_NONE);

		FOR_EACH_PLAYER(player)
			if(player.team == self.team)
				centerprint(player, "The enemy got your flag! Retrieve it!");

		self.movetype = MOVETYPE_NONE;
		setorigin(self, FLAG_CARRY_POS);
		setattachment(self, other, "");
		WaypointSprite_AttachCarrier("flagcarrier", other, RADARICON_FLAGCARRIER, '1 1 0');
		WaypointSprite_Ping(self.sprite);

		return;
	}

	if (self.cnt == FLAG_DROPPED)
	{
		self.flags = FL_ITEM | FL_NOTARGET; // clear FL_ONGROUND and any other junk
		if (other.team == self.team || (other.team != NUM_TEAM_1 && other.team != NUM_TEAM_2))
		{
			// return flag
			Send_KillNotification (other.netname, self.netname, "", INFO_RETURNFLAG, MSG_INFO);
			//bprint(other.netname, "^7 returned the ", self.netname, "\n");

			// punish the player who last had it
			FOR_EACH_PLAYER(player)
				if(player.playerid == self.dropperid)
				{
					PlayerScore_Add(player, SP_SCORE, -ctf_score_value("penalty_returned"));
					ctf_captureshield_update(player, 0); // shield only
				}

			// punish the team who was last carrying it
			if(self.team == NUM_TEAM_1)
				TeamScore_AddToTeam(NUM_TEAM_2, ST_SCORE, -ctf_score_value("penalty_returned"));
			else
				TeamScore_AddToTeam(NUM_TEAM_1, ST_SCORE, -ctf_score_value("penalty_returned"));

			// reward the player who returned it
			if(other.playerid == self.playerid) // is this the guy who killed the FC last?
			{
				if (other.team == NUM_TEAM_1 || other.team == NUM_TEAM_2)
					UpdateFrags(other, ctf_score_value("score_return_by_killer"));
				else
					UpdateFrags(other, ctf_score_value("score_return_rogue_by_killer"));
			}
			else
			{
				if (other.team == NUM_TEAM_1 || other.team == NUM_TEAM_2)
					UpdateFrags(other, ctf_score_value("score_return"));
				else
					UpdateFrags(other, ctf_score_value("score_return_rogue"));
			}
			PlayerScore_Add(other, SP_CTF_RETURNS, 1);
			LogCTF("return", self.team, other);
			sound (other, CH_TRIGGER, self.noise1, VOL_BASE, ATTN_NONE);
			ReturnFlag(self);
		}
		else if (!other.flagcarried && (other.playerid != self.dropperid || time > self.ctf_droptime + autocvar_g_balance_ctf_delay_collect))
		{
			if(self.waypointsprite_attachedforcarrier)
				WaypointSprite_DetachCarrier(self);

			if (autocvar_g_ctf_flag_pickup_effects) // field pickup effect
				pointparticles(particleeffectnum("smoke_ring"), 0.5 * (self.absmin + self.absmax), '0 0 0', 1);

			// pick up
			self.solid = SOLID_NOT;
			setorigin(self, self.origin); // relink
			self.owner = other;
			other.flagcarried = self;
			self.cnt = FLAG_CARRY;
			Send_KillNotification (other.netname, self.netname, "", INFO_PICKUPFLAG, MSG_INFO);
			//bprint(other.netname, "^7 picked up the ", self.netname, "\n");

			float f;
			f = bound(0, (self.pain_finished - time) / autocvar_g_ctf_flag_returntime, 1);
			//print("factor is ", ftos(f), "\n");
			f = ctf_score_value("score_pickup_dropped_late") * (1-f)
			  + ctf_score_value("score_pickup_dropped_early") * f;
			f = floor(f + 0.5);
			self.dropperid = other.playerid;
			//print("score is ", ftos(f), "\n");

			UpdateFrags(other, f);
			PlayerScore_Add(other, SP_CTF_PICKUPS, 1);
			LogCTF("pickup", self.team, other);
			sound (other, CH_TRIGGER, self.noise, VOL_BASE, ATTN_NONE);

			FOR_EACH_PLAYER(player)
				if(player.team == self.team)
					centerprint(player, "The enemy got your flag! Retrieve it!");

			self.movetype = MOVETYPE_NONE;	// flag must have MOVETYPE_NONE here, otherwise it will drop through the floor...
			setorigin(self, FLAG_CARRY_POS);
			setattachment(self, other, "");
			self.damageforcescale = 0;
			self.takedamage = DAMAGE_NO;
			WaypointSprite_AttachCarrier("flagcarrier", other, RADARICON_FLAGCARRIER, '1 1 0');
		}
	}
}

/*QUAKED spawnfunc_info_player_team1 (1 0 0) (-16 -16 -24) (16 16 24)
CTF Starting point for a player
in team one (Red).

Keys:
"angle"
 viewing angle when spawning
*/
void spawnfunc_info_player_team1()
{
	if(g_assault)
	{
		remove(self);
		return;
	}
	self.team = NUM_TEAM_1; // red
	spawnfunc_info_player_deathmatch();
}
//self.team = 4;self.classname = "info_player_start";spawnfunc_info_player_start();}

/*QUAKED spawnfunc_info_player_team2 (1 0 0) (-16 -16 -24) (16 16 24)
CTF Starting point for a player in
team two (Blue).

Keys:
"angle"
 viewing angle when spawning
*/
void spawnfunc_info_player_team2()
{
	if(g_assault)
	{
		remove(self);
		return;
	}
	self.team = NUM_TEAM_2; // blue
	spawnfunc_info_player_deathmatch();
}
//self.team = 13;self.classname = "info_player_start";spawnfunc_info_player_start();}

/*QUAKED spawnfunc_info_player_team3 (1 0 0) (-16 -16 -24) (16 16 24)
CTF Starting point for a player in
team three (Yellow).

Keys:
"angle"
 viewing angle when spawning
*/
void spawnfunc_info_player_team3()
{
	if(g_assault)
	{
		remove(self);
		return;
	}
	self.team = NUM_TEAM_3; // yellow
	spawnfunc_info_player_deathmatch();
}


/*QUAKED spawnfunc_info_player_team4 (1 0 0) (-16 -16 -24) (16 16 24)
CTF Starting point for a player in
team four (Magenta).

Keys:
"angle"
 viewing angle when spawning
*/
void spawnfunc_info_player_team4()
{
	if(g_assault)
	{
		remove(self);
		return;
	}
	self.team = NUM_TEAM_4; // purple
	spawnfunc_info_player_deathmatch();
}

void item_flag_reset()
{
	DropFlag(self, world, world);
	if(self.waypointsprite_attachedforcarrier)
		WaypointSprite_DetachCarrier(self);
	ReturnFlag(self);
}

void item_flag_postspawn()
{ // Check CTF Item Flag Post Spawn

	// Flag Glow Trail Support
	if(autocvar_g_ctf_flag_glowtrails)
	{ // Provide Flag Glow Trail
		if(self.team == NUM_TEAM_1)
			// Red
			self.glow_color = 251;
		else
		if(self.team == NUM_TEAM_2)
			// Blue
			self.glow_color = 210;

		self.glow_size = 25;
		self.glow_trail = 1;
	}
}

/*QUAKED spawnfunc_item_flag_team1 (0 0.5 0.8) (-48 -48 -37) (48 48 37)
CTF flag for team one (Red).
Multiple are allowed.

Keys:
"angle"
 Angle the flag will point
(minus 90 degrees)
"model"
 model to use, note this needs red and blue as skins 0 and 1
 (default models/ctf/flag.md3)
"noise"
 sound played when flag is picked up
 (default ctf/take.wav)
"noise1"
 sound played when flag is returned by a teammate
 (default ctf/return.wav)
"noise2"
 sound played when flag is captured
 (default ctf/redcapture.wav)
"noise3"
 sound played when flag is lost in the field and respawns itself
 (default ctf/respawn.wav)
*/

void spawnfunc_item_flag_team2();
void spawnfunc_item_flag_team1()
{
	if (!g_ctf)
	{
		remove(self);
		return;
	}

	if (g_ctf_reverse)
	{
		float old_g_ctf_reverse = g_ctf_reverse;
		g_ctf_reverse = 0; // avoid an endless loop
		spawnfunc_item_flag_team2();
		g_ctf_reverse = old_g_ctf_reverse;
		return;
	}

	// link flag into ctf_worldflaglist
	self.ctf_worldflagnext = ctf_worldflaglist;
	ctf_worldflaglist = self;

	self.classname = "item_flag_team";
	self.team = NUM_TEAM_1; // color 4 team (red)
	self.items = IT_KEY2; // gold key (redish enough)
	self.netname = "^1RED^7 flag";
	self.target = "###item###";
	self.skin = autocvar_g_ctf_flag_red_skin;
	if(self.spawnflags & 1)
		self.noalign = 1;
	if (!self.model)
		self.model = autocvar_g_ctf_flag_red_model;
	if (!self.noise)
		self.noise = "ctf/red_taken.wav";
	if (!self.noise1)
		self.noise1 = "ctf/red_returned.wav";
	if (!self.noise2)
		self.noise2 = "ctf/red_capture.wav"; // blue team scores by capturing the red flag
	if (!self.noise3)
		self.noise3 = "ctf/flag_respawn.wav";
	if (!self.noise4)
		self.noise4 = "ctf/red_dropped.wav";
	precache_model (self.model);
	setmodel (self, self.model); // precision set below
	precache_sound (self.noise);
	precache_sound (self.noise1);
	precache_sound (self.noise2);
	precache_sound (self.noise3);
	precache_sound (self.noise4);
	//setsize(self, '-16 -16 -37', '16 16 37');
	setsize(self, FLAG_MIN, FLAG_MAX);
	setorigin(self, self.origin + '0 0 37');
	self.nextthink = time + 0.2; // start after doors etc
	self.think = place_flag;

	if(!self.scale)
		self.scale = 0.6;
	//if(!self.glow_size)
	//	self.glow_size = 50;

	self.effects = self.effects | EF_LOWPRECISION;
	if(autocvar_g_ctf_fullbrightflags)
		self.effects |= EF_FULLBRIGHT;
	if(autocvar_g_ctf_dynamiclights)
		self.effects |= EF_RED;

	// From Spidflisk
	item_flag_postspawn();

	precache_model("models/ctf/shield.md3");
	precache_model("models/ctf/shockwavetransring.md3");

	self.reset = item_flag_reset;
}

/*QUAKED spawnfunc_item_flag_team2 (0 0.5 0.8) (-48 -48 -24) (48 48 64)
CTF flag for team two (Blue).
Multiple are allowed.

Keys:
"angle"
 Angle the flag will point
(minus 90 degrees)
"model"
 model to use, note this needs red and blue as skins 0 and 1
 (default models/ctf/flag.md3)
"noise"
 sound played when flag is picked up
 (default ctf/take.wav)
"noise1"
 sound played when flag is returned by a teammate
 (default ctf/return.wav)
"noise2"
 sound played when flag is captured
 (default ctf/bluecapture.wav)
"noise3"
 sound played when flag is lost in the field and respawns itself
 (default ctf/respawn.wav)
*/

void spawnfunc_item_flag_team2()
{
	if (!g_ctf)
	{
		remove(self);
		return;
	}

	if (g_ctf_reverse)
	{
		float old_g_ctf_reverse = g_ctf_reverse;
		g_ctf_reverse = 0; // avoid an endless loop
		spawnfunc_item_flag_team1();
		g_ctf_reverse = old_g_ctf_reverse;
		return;
	}

	// link flag into ctf_worldflaglist
	self.ctf_worldflagnext = ctf_worldflaglist;
	ctf_worldflaglist = self;

	self.classname = "item_flag_team";
	self.team = NUM_TEAM_2; // color 13 team (blue)
	self.items = IT_KEY1; // silver key (bluish enough)
	self.netname = "^4BLUE^7 flag";
	self.target = "###item###";
	self.skin = autocvar_g_ctf_flag_blue_skin;
	if(self.spawnflags & 1)
		self.noalign = 1;
	if (!self.model)
		self.model = autocvar_g_ctf_flag_blue_model;
	if (!self.noise)
		self.noise = "ctf/blue_taken.wav";
	if (!self.noise1)
		self.noise1 = "ctf/blue_returned.wav";
	if (!self.noise2)
		self.noise2 = "ctf/blue_capture.wav"; // blue team scores by capturing the red flag
	if (!self.noise3)
		self.noise3 = "ctf/flag_respawn.wav";
	if (!self.noise4)
		self.noise4 = "ctf/blue_dropped.wav";
	precache_model (self.model);
	setmodel (self, self.model); // precision set below
	precache_sound (self.noise);
	precache_sound (self.noise1);
	precache_sound (self.noise2);
	precache_sound (self.noise3);
	precache_sound (self.noise4);
	//setsize(self, '-16 -16 -37', '16 16 37');
	setsize(self, FLAG_MIN, FLAG_MAX);
	setorigin(self, self.origin + '0 0 37');
	self.nextthink = time + 0.2; // start after doors etc
	self.think = place_flag;

	if(!self.scale)
		self.scale = 0.6;
	//if(!self.glow_size)
	//	self.glow_size = 50;

	self.effects = self.effects | EF_LOWPRECISION;
	if(autocvar_g_ctf_fullbrightflags)
		self.effects |= EF_FULLBRIGHT;
	if(autocvar_g_ctf_dynamiclights)
		self.effects |= EF_BLUE;

	// From Spidflisk
	item_flag_postspawn();

	precache_model("models/ctf/shield.md3");
	precache_model("models/ctf/shockwavetransring.md3");

	self.reset = item_flag_reset;
}


/*QUAKED spawnfunc_ctf_team (0 .5 .8) (-16 -16 -24) (16 16 32)
Team declaration for CTF gameplay, this allows you to decide what team
names and control point models are used in your map.

Note: If you use spawnfunc_ctf_team entities you must define at least 2!  However, unlike
domination, you don't need to make a blank one too.

Keys:
"netname"
 Name of the team (for example Red, Blue, Green, Yellow, Life, Death, Offense, Defense, etc)
"cnt"
 Scoreboard color of the team (for example 4 is red and 13 is blue)

*/

void spawnfunc_ctf_team()
{
	if (!g_ctf)
	{
		remove(self);
		return;
	}
	self.classname = "ctf_team";
	self.team = self.cnt + 1;
}

// code from here on is just to support maps that don't have control point and team entities
void ctf_spawnteam (string teamname, float teamcolor)
{
	entity oldself;
	oldself = self;
	self = spawn();
	self.classname = "ctf_team";
	self.netname = teamname;
	self.cnt = teamcolor;

	spawnfunc_ctf_team();

	self = oldself;
}

// spawn some default teams if the map is not set up for ctf
void ctf_spawnteams()
{
	float numteams;

	numteams = 2;//cvar("g_ctf_default_teams");

	ctf_spawnteam("Red", NUM_TEAM_1 - 1);
	ctf_spawnteam("Blue", NUM_TEAM_2 - 1);
}

void ctf_delayedinit()
{
	// if no teams are found, spawn defaults
	if (find(world, classname, "ctf_team") == world)
		ctf_spawnteams();

	ScoreRules_ctf();
}

void ctf_init()
{
	InitializeEntity(world, ctf_delayedinit, INITPRIO_GAMETYPE);
	flagcaptimerecord = stof(db_get(ServerProgsDB, strcat(GetMapname(), "/captimerecord/time")));

	captureshield_min_negscore = autocvar_g_ctf_shield_min_negscore;
	captureshield_max_ratio = autocvar_g_ctf_shield_max_ratio;
	captureshield_force = autocvar_g_ctf_shield_force;
}

void ctf_setstatus2(entity flag, float shift)
{
	if (flag.cnt ==	FLAG_CARRY)
		if (flag.owner == self)
			self.items |= shift * 3;
		else
			self.items |= shift * 1;
	else if (flag.cnt == FLAG_DROPPED)
		self.items |= shift * 2;
	else
	{
		// no status bits
	}
}

void ctf_setstatus()
{
	self.items &~= IT_RED_FLAG_TAKEN;
	self.items &~= IT_RED_FLAG_LOST;
	self.items &~= IT_BLUE_FLAG_TAKEN;
	self.items &~= IT_BLUE_FLAG_LOST;
	self.items &~= IT_CTF_SHIELDED;

	entity flag;
	float redflags, blueflags;

	if(self.ctf_captureshielded)
		self.items |= IT_CTF_SHIELDED;

	redflags = 0;
	blueflags = 0;

	for (flag = ctf_worldflaglist; flag; flag = flag.ctf_worldflagnext) if(flag.cnt != FLAG_BASE)
	{
		if(flag.items & IT_KEY2) // blue
			++redflags;
		else if(flag.items & IT_KEY1) // red
			++blueflags;
	}

	// blinking magic: if there is more than one flag, show one of these in a clever way
	if(redflags)
		redflags = mod(floor(time * redflags * 0.75), redflags);
	if(blueflags)
		blueflags = mod(floor(time * blueflags * 0.75), blueflags);

	for (flag = ctf_worldflaglist; flag; flag = flag.ctf_worldflagnext) if(flag.cnt != FLAG_BASE)
	{
		if(flag.items & IT_KEY2) // blue
		{
			if(--redflags == -1) // happens exactly once (redflags is in 0..count-1, and will --'ed count times)
				ctf_setstatus2(flag, IT_RED_FLAG_TAKEN);
		}
		else if(flag.items & IT_KEY1) // red
		{
			if(--blueflags == -1) // happens exactly once
				ctf_setstatus2(flag, IT_BLUE_FLAG_TAKEN);
		}
	}
}
/*
entity ctf_team_has_commander(float cteam)
{
	entity pl;
	if(cteam != NUM_TEAM_1 || cteam != NUM_TEAM_2)
		return world;

	FOR_EACH_REALPLAYER(pl) {
		if(pl.team == cteam && pl.iscommander) {
			return pl;
		}
	}
	return world;
}

void ctf_setstate(entity e, float st)
{
	e.ctf_state = st;
	++e.version;
}

void ctf_new_commander(float cteam)
{
	entity pl, plmax;

	plmax = world;
	FOR_EACH_REALPLAYER(pl) {
		if(pl.team == cteam) {
			if(pl.iscommander) { // don't reassign if alreay there
				return;
			}
			if(plmax == world || plmax.frags < pl.frags) <<<<<<<<<<<<<<<<< BROKEN in new scoring system
				plmax = pl;
		}
	}
	if(plmax == world) {
		bprint(strcat(ColoredTeamName(cteam), " Team has no Commander!\n"));
		return;
	}

	plmax.iscommander = TRUE;
	ctf_setstate(plmax, 3);
	sprint(plmax, "^3You're the commander now!\n");
	centerprint(plmax, "^3You're the commander now!\n");
}

void ctf_clientconnect()
{
	self.iscommander = FALSE;

	if(!self.team || self.classname != "player") {
		ctf_setstate(self, -1);
	} else
		ctf_setstate(self, 0);

	self.team_saved = self.team;

	if(self.team != 0 && self.classname == "player" && !ctf_team_has_commander(self.team)) {
		ctf_new_commander(self.team);
	}
}

void ctf_playerchanged()
{
	if(!self.team || self.classname != "player") {
		ctf_setstate(self, -1);
	} else if(self.ctf_state < 0 && self.classname == "player") {
		ctf_setstate(self, 0);
	}

	if(self.iscommander &&
	   (self.classname != "player" || self.team != self.team_saved)
		)
	{
		self.iscommander = FALSE;
		if(self.classname == "player")
			ctf_setstate(self, 0);
		else
			ctf_setstate(self, -1);
		ctf_new_commander(self.team_saved);
	}

	self.team_saved = self.team;

	ctf_new_commander(self.team);
}

void ctf_clientdisconnect()
{
	if(self.iscommander)
	{
		ctf_new_commander(self.team);
	}
}

entity GetPlayer(string);
float ctf_clientcommand()
{
	entity e;
	if(argv(0) == "order") {
		if(!g_ctf) {
			sprint(self, "This command is not supported in this gamemode.\n");
			return TRUE;
		}
		if(!self.iscommander) {
			sprint(self, "^1You are not the commander!\n");
			return TRUE;
		}
		if(argv(2) == "") {
			sprint(self, "Usage: order #player status   - (playernumber as in status)\n");
			return TRUE;
		}
		e = GetPlayer(argv(1));
		if(e == world) {
			sprint(self, "Invalid player.\nUsage: order #player status   - (playernumber as in status)\n");
			return TRUE;
		}
		if(e.team != self.team) {
			sprint(self, "^3You can only give orders to your own team!\n");
			return TRUE;
		}
		if(argv(2) == "attack") {
			sprint(self, strcat("Ordering ", e.netname, " to attack!\n"));
			sprint(e, "^1Attack!\n");
			centerprint(e, "^7You've been ordered to^9\n^1Attack!\n");
			ctf_setstate(e, 1);
		} else if(argv(2) == "defend") {
			sprint(self, strcat("Ordering ", e.netname, " to defend!\n"));
			sprint(e, "^Defend!\n");
			centerprint(e, "^7You've been ordered to^9\n^2Defend!\n");
			ctf_setstate(e, 2);
		} else {
			sprint(self, "^7Invalid command, use ^3attack^7, or ^3defend^7.\n");
		}
		return TRUE;
	}
	return FALSE;
}
*/
