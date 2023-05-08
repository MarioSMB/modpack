// Rogue Teamplay Variants
// Jan'97 by ZOID <zoid@threewave.com>
// Under contract to id software for Rogue Entertainment

void T_Damage(entity targ, entity inflictor, entity attacker, float damage, int deathtype);

// Prototypes
void W_SetCurrentAmmo(entity this);
void bound_other_ammo(entity toucher);
void Deathmatch_Weapon(entity this, float o, Weapon newwep);
void BackpackTouch(entity this, entity toucher);
void EnableComboWeapons(entity this);

// Return a name for the color of a team
string GetTeamColor(int Team)
{
	switch(Team)
	{
		case 1: return ("White");
		case 2: return ("Brown");
		case 3: return ("Light blue");
		case 4: return ("Green");
		case 5: return ("Red");
		case 6: return ("Olive");
		case 7: return ("Orange");
		case 8: return ("Peech");
		case 9: return ("Purple");
		case 10: return ("Majenta");
		case 11: return ("Grey");
		case 12: return ("Aqua");
		case 13: return ("Yellow");
		case 14: return ("Blue");
		default: return "Unknown";
	}
}

string GetCTFTeam(int Team)
{
	if(Team == TEAM1) return "Red";
	else if(Team == TEAM2) return "Blue";
	else if(Team == TEAM3) return "Grey";
	return "UNKNOWN";

}

/*
================
TeamArmorDam

Return true if the target's armor can take damage from this attacker.
================
*/

bool TeamArmorDam(entity targ, entity inflictor, entity attacker, float damage)
{
	if(teamplay <= 0)
		return true; // PGM bug? fix

	// teamplay modes 4,5,6 protect armor
	if((teamplay == TEAM_CTF ||
		teamplay == TEAM_CTF_ONEFLAG ||
		teamplay == TEAM_CTF_ALT) &&
		attacker.steam == targ.steam && 
		attacker != targ &&
		!(cvar("gamecfg") & GAMECFG_TEAM_ARMOR_DMG)) {
		// Armor is protected
		return false;
	}
	return true;
}

/*
================
TeamHealthDam

Return true if the target can take health damage from this attacker.
================
*/

bool TeamHealthDam(entity targ, entity inflictor, entity attacker, float damage)
{
	if(teamplay <= 0)
		return true;

	if(teamplay == TEAM_NORMAL_NODAMAGE && attacker.steam == targ.steam)
		return false;

	// teamplay modes 4,5,6 protect health
	if((teamplay == TEAM_CTF ||
		teamplay == TEAM_CTF_ONEFLAG ||
		teamplay == TEAM_CTF_ALT) &&
		attacker.steam == targ.steam && 
		attacker != targ &&
		!(cvar("gamecfg") & GAMECFG_TEAM_HEALTH_DMG)) {
		// Health is protected
		return false;
	}
	return true;
}

void TeamResetCarrier(entity who)
{
	// When the flag carrier dies, reset the last_hurt_carrier field in
	// all players on the opposite team from the flag carrier.  The carrier
	// has been killed, so there is no longer a reason to award points for
	// killing off his assailants
	if(teamplay >= TEAM_CTF &&
		(who.ctf_flags & (CTF_FLAG_TEAM1 | CTF_FLAG_TEAM2))) {

		FOREACH_CLIENT(IS_PLAYER(it),
		{	
			if(teamplay == TEAM_CTF_ONEFLAG ||
				((who.ctf_flags & CTF_FLAG_TEAM1) && it.steam == TEAM1) ||
				((who.ctf_flags & CTF_FLAG_TEAM2) && it.steam == TEAM2))
				it.ctf_lasthurtcarrier = -10;
		});
	}
}

void TeamAssists(entity targ, entity attacker)
{
	if((targ.ctf_flags & (CTF_FLAG_TEAM1 | CTF_FLAG_TEAM2)) &&
		targ.steam != attacker.steam)
	{
		//ZOID: one team fragged the other team's flag carrier

		// Mark the attacker with the time at which he killed the flag
		// carrier, for awarding assist points
		attacker.ctf_lastfraggedcarrier = time;

		// give player only the normal amount of frags
		// if the carrier has only had the flag for a few seconds, to
		// prevent ppl intentionally allowing enemies to grab the flag,
		// then immediately fragging them
		if(targ.ctf_flagsince + CTF_CARRIER_FLAG_SINCE_TIMEOUT > time)
		{
			sprint(attacker, "Enemy flag carrier killed, no bonus\n");
		}
		else
		{
			attacker.frags = attacker.frags + CTF_FRAG_CARRIER_BONUS;
			sprint(attacker, strcat("Enemy flag carrier killed: ", ftos(CTF_FRAG_CARRIER_BONUS), " bonus frags\n"));
		}
	}
	
	// This code checks for all game-critical kills OTHER THAN fragging the enemy
	// flag carrier, like killing players who are trying to kill your flag carrier
	// or trying to grab your flag, and hands out bonus frags.

	// The two variables below track whether special bonus frags have already
	// been awarded for the attacker or target being near the flag or flag carrier.  

	float flag_radius = 0;
	float flag_carrier_radius = 0;

	// get a string for the attacker's team now, for later announcements
	string s = GetCTFTeam(attacker.steam);

	if((targ.ctf_lasthurtcarrier + CTF_CARRIER_DANGER_PROTECT_TIMEOUT > time) &&
		!(attacker.ctf_flags & (CTF_FLAG_TEAM1 | CTF_FLAG_TEAM2))) {
		// a player on the same team as the flag carrier killed 
		// someone who recently shot the flag carrier
		attacker.frags = attacker.frags + CTF_CARRIER_DANGER_PROTECT_BONUS;
		flag_carrier_radius = 1;
		// NOTE: getting CARRIER_DANGER_PROTECT_BONUS precludes getting
		// other kinds of bonuses for defending the flag carrier, since
		// it's worth more points
		bprintf("%s ^7defends %s^7's flag carrier against an aggressive enemy\n", attacker.netname, s);
	}

	// Bonusus for defending the flag carrier or the flag itself.
	// Extra frags are awarded if either the attacker or the target are
	// 1. within 40 feet of a flag carrier on the same team as the attacker
	// 2. within 40 feet of the attacker's flag
	// These bonuses are cumulative with respect to defending both the
	// flag and the flag carrier at the same time, but not cumulative with
	// respect to both the target and attacker being near the object being defended

	// find flags or flag carriers within a radius of the attacker
	entity head = findradius(attacker.origin, CTF_ATTACKER_PROTECT_RADIUS);

	while (head)
	{
		if(IS_PLAYER(head))
		{
			if((head.steam == attacker.steam) &&
				 (head.ctf_flags & (CTF_FLAG_TEAM1 | CTF_FLAG_TEAM2)) &&
				 (head != attacker) && // this defense
				 (!flag_carrier_radius))
			{ 
				// attacker was near his own flag carrier
				attacker.frags = attacker.frags + CTF_CARRIER_PROTECT_BONUS;
				flag_carrier_radius = 1;
				bprintf("%s defends %s's flag carrier\n", attacker.netname, s);
			}
		}
		if((attacker.steam == TEAM1 && head.classname == "item_flag_team1") ||
			(attacker.steam == TEAM2 && head.classname == "item_flag_team2") ||
			head.classname == "item_flag")
		{  // one flag mode
			// attacker was near his own flag
			attacker.frags = attacker.frags + CTF_FLAG_DEFENSE_BONUS;
			flag_radius = 1;
			bprintf("%s defends the %s flag\n", attacker.netname, ((teamplay != TEAM_CTF_ONEFLAG) ? strcat(" ", s) : ""));
		}
		head = head.chain;
	}

	// find flags or flag carriers within a radius from the target
	head = findradius(targ.origin, CTF_TARGET_PROTECT_RADIUS);
	while (head)
	{
		if(IS_PLAYER(head))
		{
			if((head.steam == attacker.steam) &&
				 (head.ctf_flags & (CTF_FLAG_TEAM1 | CTF_FLAG_TEAM2)) &&
				 (head != attacker) &&
				 (!flag_carrier_radius))
			{ // prevents redundant points awarded
				// target was near attacker's flag carrier
				attacker.frags = attacker.frags + CTF_CARRIER_PROTECT_BONUS;
				flag_carrier_radius = 1;
				bprintf("%s defends %s's flag carrier\n", attacker.netname, s);
			}
		}
		if(((attacker.steam == TEAM1 && head.classname == "item_flag_team1") || (attacker.steam == TEAM2 && head.classname == "item_flag_team2") || head.classname == "item_flag") && !flag_radius)
		{ // prevents redundant points awarded
			// target was near attacker's flag
			attacker.frags = attacker.frags + CTF_FLAG_DEFENSE_BONUS;
			flag_radius = 1;
			bprintf("%s defends the %s flag\n", attacker.netname, ((teamplay != TEAM_CTF_ONEFLAG) ? strcat(" ", s) : ""));
		}
		head = head.chain;
	}
}
 
/*
==================
TeamColorIsLegal

Return true if the indicated color is legal
==================
*/
bool TeamColorIsLegal(int thecolor)
{
	// All colors are legal if teamplay is not CTF
	if(teamplay < TEAM_CTF)
	{
		if(thecolor > 0)
			return true;
		return false;
	}

	// In regular CTF and CTF_ONEFLAG, only two colors are legal
	if(teamplay == TEAM_CTF || teamplay == TEAM_CTF_ONEFLAG)
		if(thecolor == TEAM1 || thecolor == TEAM2)
			return true;
		else
			return false;

	// In ALT CTF, three colors are legal
	if(teamplay == TEAM_CTF_ALT)
		if(thecolor == TEAM1 || thecolor == TEAM2 || thecolor == TEAM3)
			return true;
		else
			return false;

	// dunno what teamplay we're in, let'em all be ok
	return true;
}

/* TeamSetSkin - set the skin of the player model to the
   apropriate skin based on team and teamplay settings.
*/
void TeamSetSkin(entity this)
{
	this.skin = 0;
	if(deathmatch)
	{
		if(teamplay >= TEAM_CTF)
			this.skin = 1;
	}
}

/*
==================
TeamCheckTeam

Check if the team this is on is legal, and put this in a legal team if not.
==================
*/
void TeamCheckTeam(entity this)
{
	if(this.steam >= 0 || teamplay < TEAM_CTF)
	{
		if(TeamColorIsLegal(this.team))
		{
			this.steam = this.team;
			TeamSetSkin(this);
			return;
		}
	}

	// Assign the player to a team.

	// Sum the players on all the teams.
	int team1count = 0, team2count = 0, team3count = 0;

	FOREACH_CLIENT(IS_PLAYER(it) && it != this,
	{
		if(it.steam == TEAM1)
			team1count += 1;
		else if(it.steam == TEAM2)
			team2count += 1;
		else if(it.steam == TEAM3)
			team3count += 1;
	});

	// Find the team with the least players.
	int newcolor = TEAM1;
	int t = team1count;

	if(team2count < t || (team2count == t && random() < 0.5))
	{
		newcolor = TEAM2;
		t = team2count;
	}

	// in CTF_ALT, there's three teams
	team3count = team3count * 2; // grey team only gets half as many players
	if(teamplay == TEAM_CTF_ALT && team3count < t)
	{
		newcolor = TEAM3;
		t = team3count;
	}

	// Put the player on a the new team.
	this.ctf_flags |= CTF_FLAG_STUFF_COLOR;

	string n = GetCTFTeam(newcolor);
	sprint(this, strcat("You have been assigned to ", n, " team.\n"));

	this.steam = newcolor;      // Remember what team we're on
	this.team = newcolor;
	TeamSetSkin(this);
}

/* Check for team changing and perform whatever actions are neccessary.  */
void TeamCheckLock(entity this)
{
	if(!deathmatch || teamplay < TEAM_CTF)
	{
		// all colors are legal, no force
		this.steam = this.team;
		return;
	}

	int n;
	if(this.ctf_flags & CTF_FLAG_STUFF_COLOR)
	{
		this.ctf_flags = this.ctf_flags - CTF_FLAG_STUFF_COLOR;
		stuffcmd(this, "color ");
		n = this.steam - 1;
		stuffcmd(this, ftos(n));
		stuffcmd(this, "\n");
		TeamSetSkin(this);
		return;
	}

	if(!TeamColorIsLegal(this.team) && this.team == this.steam)
		this.steam = -1; // full reset

	// Check to see if the player has changed colors
	if(this.team != this.steam)
	{
		if(this.steam >= 0)
		{
			if(TeamColorIsLegal(this.steam))
			{
				if(!(cvar("gamecfg") & GAMECFG_ALLOW_CHG))
				{
					// changing teams sucks, kill him

					// if he has tried to change teams several
					// times, kick him off the server.
					if(this.suicide_count > 3)
					{
						sprint(this, "You were told you can't change teams.\nGo play color games somewhere else.\n");
						stuffcmd(this, "disconnect\n");
						bprint(strcat(this.netname, " has bad color sense\n"));
					}
					// case base respawn
					if(this.ctf_killed != 1)
						this.ctf_killed = 2;
					T_Damage(this, this, this, 1000, DEATH_KILL.m_id);  // Kill the player
					// trying to change teams counts as a suicide
					this.suicide_count = this.suicide_count + 1;

					sprint(this, "You cannot change teams.\n");
					n = this.steam - 1;
					stuffcmd(this, strcat("color ", ftos(n), "\n"));
					this.team = this.steam;
					return;
				}
			}
			else
			{
				// If we're on an illegal team, force a change.
				this.steam = -50;
			}
		}

		if(this.steam > 0)
		{
			// case base respawn
			if(this.ctf_killed != 1)
				this.ctf_killed = 2;
			T_Damage(this, this, this, 1000, DEATH_TEAMCHANGE.m_id);  // Kill the player
		}
		this.frags = 0;                 // Zero out frags
		TeamCheckTeam(this); // re-assignment
	}
}

.int cnt;
.float touch_time;
void RegenFlag(entity this)
{
	set_movetype(this, MOVETYPE_TOSS);
	this.solid = SOLID_TRIGGER;
	_sound(this, CH_INFO, "items/itembk2.wav", 1, ATTN_NORM);	// play respawn sound
	setorigin(this, this.oldorigin);
	this.angles = this.mangle;
	this.cnt = FLAG_AT_BASE; // it's at home base
	this.owner = NULL;
	this.touch_time = time + 1; // prevent touching again for a bit, to prevent instant cap loops
}

void TeamReturnFlag(entity this)
{
	RegenFlag(this);

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		if(teamplay == TEAM_CTF_ONEFLAG) // one flag mode?
			centerprint(it, "The flag has been returned!\n");
		else {
			if(teamplay == TEAM_CTF_ALT) {
				if(this.team == TEAM1)
					centerprint(it, "Red flag has been returned to base!\n");
				else if(this.team == TEAM2)
					centerprint(it, "Blue flag has been returned to base!\n");
				else
					centerprint(it, "Some flag has been returned to base!\n");
			} else {
				if(it.steam != this.team)
					centerprint(it, "Enemy flag has been returned to base!\n");
				else if(it.steam == this.team)
					centerprint(it, "Your flag has been returned to base!\n");
			}
		}
	});
}

void TeamRegenFlags()
{
	if(teamplay == TEAM_CTF_ONEFLAG)
	{
		FOREACH_ENTITY_CLASS("item_flag", true,
		{
			RegenFlag(it);
		});
		return;
	}

	FOREACH_ENTITY_CLASS("item_flag_team1", true,
	{
		RegenFlag(it);
	});

	FOREACH_ENTITY_CLASS("item_flag_team2", true,
	{
		RegenFlag(it);
	});
}

void TeamDropFlag(entity this)
{
	entity own = this.owner;

	if(teamplay == TEAM_CTF_ONEFLAG)
		bprint(strcat(own.netname, " the flag!\n"));
	else
	{
		if(this.team == TEAM1)
			bprint(strcat(own.netname, " the ^1Red flag^7!\n")); // red
		else
			bprint(strcat(own.netname, " the ^4Blue flag^7!\n")); // blue
	}

	setorigin(this, own.origin - '0 0 24');
	this.cnt = FLAG_DROPPED;
	this.velocity_z = 300;
	this.velocity_x = 0;
	this.velocity_y = 0;
	this.flags = FL_ITEM;
	this.solid = SOLID_TRIGGER;
	set_movetype(this, MOVETYPE_TOSS);
	setsize(this, '-16 -16 0', '16 16 74');
	// return it after so long
	this.super_time = time + CTF_FLAG_RETURN_TIME;
}

void TeamDropFlagOfPlayer(entity player)
{
	string kn;

	if(teamplay == TEAM_CTF_ONEFLAG && (player.ctf_flags & CTF_FLAG_FLAG))
		kn = "item_flag";
	else if(player.ctf_flags & CTF_FLAG_TEAM1) 
		kn = "item_flag_team1";
	else if(player.ctf_flags & CTF_FLAG_TEAM2) 
		kn = "item_flag_team2";
	else
		return; // doesn't have a flg
	player.ctf_flags &= ~(CTF_FLAG_FLAG | CTF_FLAG_TEAM1 | CTF_FLAG_TEAM2);
	entity e = find(NULL, classname, kn);
	if(e != NULL)
		TeamDropFlag(e);
}

// A flag was touched.  In one flag mode, the player always just picks it up
// (the flagbase models at each base will cause the score).  In two flag mode,
// it could be the guy returning his flag, or the guy getting the enemy flag
// Three team mode gets more complicated as the third team touches the 
// flagbase to score
void TeamFlagTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher) || toucher.health <= 0)
		return;

	if(this.touch_time > time)
		return;

	if(toucher.team != toucher.steam)
		return; // something is fishy, somebody is playing with colors

	if(this.cnt == FLAG_CARRIED)
		return; // huh?

	// Ok, first up, let's do it for one flag mode
	if(teamplay == TEAM_CTF_ONEFLAG)
	{
		// in one flag mode, we always pick up the flag.  The touch of the
		// flagbase entities does the scoring
		bprint(strcat(toucher.netname, " the flag!\n"));
		if(CTF_FLAG_BONUS)
			toucher.frags = toucher.frags + CTF_FLAG_BONUS;
		centerprint(toucher, "YOU GOT THE FLAG\n\nTAKE IT TO ENEMY BASE\n");
		  //centerprint(toucher, "ÙÏÕ ÇÏÔ ÔÈÅ ÆÌÁÇ\n\nÔÁËÅ ÉÔ ÔÏ ÅÎÅÍÙ ÂÁÓÅ\n");

		_sound(toucher, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);

		toucher.ctf_flags |= CTF_FLAG_FLAG;
		toucher.items |= this.items;
		toucher.ctf_flagsince = time;

		// pick up the flag
		this.cnt = FLAG_CARRIED;
		set_movetype(this, MOVETYPE_NOCLIP);
		this.solid = SOLID_NOT;
		this.owner = toucher;

		FOREACH_CLIENT(IS_PLAYER(it),
		{
			if(it != toucher)
				centerprint(it, "The flag has been taken!\n");
		});
		return;
	}

	// Regular and Alt CTF mode
	if(teamplay != TEAM_CTF && teamplay != TEAM_CTF_ALT)
		return; // odd, but ignore it

	if(this.team == toucher.steam)
	{
		// same team, if the flag is *not* at the base, return
		// it to base.  we overload the 'cnt' field for this
		if(this.cnt == FLAG_AT_BASE)
		{
			// the flag is at home base.  if the player has the enemy
			// flag, he's just won!
			if((this.team == TEAM1 && (toucher.ctf_flags & CTF_FLAG_TEAM2)) ||
				(this.team == TEAM2 && (toucher.ctf_flags & CTF_FLAG_TEAM1)))
			{
				bprintf("%s ^7captured the %s flag^7!\n", toucher.netname, ((toucher.team == TEAM1) ? "^4Blue" : "^1Red"));
				toucher.items &= ~(IT_KEY1 | IT_KEY2);

				_sound(toucher, CH_INFO, "misc/flagcap.wav", 1, ATTN_NONE);

				// toucher gets antoucher 10 frag bonus
				toucher.frags = toucher.frags + CTF_CAPTURE_BONUS;

				// Ok, let's do the player loop, hand out the bonuses
				FOREACH_CLIENT(IS_PLAYER(it),
				{
					if(it.team == toucher.team && it != toucher)
						it.frags = it.frags + CTF_TEAM_BONUS;
					if(it.team != toucher.team)
					{
						if(it.team == TEAM3)
							if(toucher.team == TEAM1)
								centerprint(it, "Blue flag was captured!\n");
							else
								centerprint(it, "Red flag was captured!\n");
						else 
							centerprint(it, "Your flag was captured!\n");
						// reset the last_hurt_carrier variable in all enemy players, so that you don't get
						// bonuses for defending the flag carrier if the flag carrier has already
						// completed a capture
						it.ctf_lasthurtcarrier = -5;
					}
					else if(it.team == toucher.team)
					{
						// done to all players on the capturing team
						centerprint(it, "Your team captured the flag!\n");
						// award extra points for capture assists
						if(it.ctf_lastreturnedflag + CTF_RETURN_FLAG_ASSIST_TIMEOUT > time)
						{
							if(it.team == TEAM1)
								bprint(strcat(it.netname, " gets an assist for returning the Red flag!\n"));
							else
								bprint(strcat(it.netname, " gets an assist for returning the Blue flag!\n"));
							it.frags = it.frags + CTF_RETURN_FLAG_ASSIST_BONUS;
						}
						if(it.ctf_lastfraggedcarrier + CTF_FRAG_CARRIER_ASSIST_TIMEOUT > time)
						{
							bprint(strcat(it.netname, " gets an assist for fragging the flag carrier!\n"));
							it.frags = it.frags + CTF_FRAG_CARRIER_ASSIST_BONUS;
						}
					}
					it.ctf_flags &= ~(CTF_FLAG_TEAM1 | CTF_FLAG_TEAM2);
				});
				// respawn flags
				TeamRegenFlags();
				return;
			}
			return; // its at home base already
		}	
		// hey, its not home.  return it by teleporting it back
		bprintf("%s ^7returned the %s flag^7!\n", toucher.netname, ((toucher.team == TEAM1) ? "^1Red" : "^4Blue"));
		toucher.frags = toucher.frags + CTF_RECOVERY_BONUS;
		toucher.ctf_lastreturnedflag = time;
		_sound(toucher, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
		TeamReturnFlag(this);
		return;
	}

	// if we have any flags, leave now
	if((toucher.ctf_flags & CTF_FLAG_TEAM1) || (toucher.ctf_flags & CTF_FLAG_TEAM2))
		return;

	// hey, its not our flag, pick it up
	bprintf("%s ^7got the %s flag^7!\n", toucher.netname, ((this.team == TEAM1) ? "^1Red" : "^4Blue"));
	toucher.frags = toucher.frags + CTF_FLAG_BONUS;

	// if in three team, messages are a little different
	if(toucher.team == TEAM3)
	{
//		centerprint(toucher, "YOU GOT THE ENEMY FLAG\n\nRETURN IT TO THE OTHER BASE!\n");
		centerprint(toucher, "You got the Grey flag\n\ntake it to the enemy base!\n");
	}
	else
	{
//		centerprint(toucher, "YOU GOT THE ENEMY FLAG!\n\nRETURN TO BASE!\n");
		centerprint(toucher, "You got the enemy flag\n\nReturn to base!\n");
	}
	_sound(toucher, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);

	if(this.team == TEAM1)
		toucher.ctf_flags |= CTF_FLAG_TEAM1;
	else
		toucher.ctf_flags |= CTF_FLAG_TEAM2;
	toucher.items |= this.items;

	toucher.ctf_flagsince = time;

	// pick up the flag
	this.cnt = FLAG_CARRIED;
	set_movetype(this, MOVETYPE_NOCLIP);
	this.solid = SOLID_NOT;
	this.owner = toucher;

	// PGM Fix - 03/06/97 Made it work right in three team. 
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		if(it != toucher) 
		{
			if(it.steam == this.team)
			{
				centerprint(it, "Your flag has been taken!\n");
			}
			else if(it.steam == toucher.team)
			{
				if(this.team == TEAM1)
					centerprint(it, "Your team has the Red flag!\n");	// Red Flag
				else
					centerprint(it, "Your team has the Blue flag!\n");	// Blue Flag
			}
			else
			{
				if(this.team == TEAM1)
					if(toucher.steam == TEAM2)
						centerprint(it, "Blue team has the Red flag!\n"); // Blue has red
					else // must be team3
						centerprint(it, "Grey team has the Red flag!\n"); // grey has red
				else
					if(toucher.steam == TEAM1)
						centerprint(it, "Red team has the Blue flag!\n"); // red has blue
					else // must be team3
						centerprint(it, "Grey team has the Blue flag!\n");// grey has blue
			}
		}
	});
}

// A flagbase was touched.  In one flag mode, this is how a capture is made.
// in three team mode, only team3 touches this.  In regular CTF, this is
// ignored
void TeamFlagBaseTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;
	if(toucher.team != toucher.steam)
		return; // something is fishy, somebody is playing with colors

	// Ok, first up, let's do it for one flag mode
	if(teamplay == TEAM_CTF_ONEFLAG)
	{
		// ok, if they guy touching it has the flag and this is his
		// base, capture!
		if(((this.team == TEAM1 && toucher.steam == TEAM2) || 
			(this.team == TEAM2 && toucher.steam == TEAM1)) && 
			(toucher.ctf_flags & CTF_FLAG_FLAG)) {
			// he just touched enemy base, capture it
			bprint(strcat(toucher.netname, " ^7captured the ^9flag^7!\n"));
			toucher.items &= ~(IT_KEY1 | IT_KEY2);
			_sound(toucher, CH_INFO, "misc/flagcap.wav", 1, ATTN_NONE);

			// toucher gets antoucher 10 frag bonus
			toucher.frags = toucher.frags + CTF_CAPTURE_BONUS;

			// Ok, let's do the player loop, hand out the bonuses
			FOREACH_CLIENT(IS_PLAYER(it),
			{
				if(it.team == toucher.team && it != toucher)
					it.frags = it.frags + CTF_TEAM_BONUS;
				if(it.team != toucher.team)
				{
					it.ctf_lasthurtcarrier = -5;
				}
				else if(it.team == toucher.team)
				{
					// award extra points for capture assists
					if(it.ctf_lastfraggedcarrier + CTF_FRAG_CARRIER_ASSIST_TIMEOUT > time)
					{
						bprint(strcat(it.netname, " gets an assist for fragging the flag carrier!\n"));
						it.frags = it.frags + CTF_FRAG_CARRIER_ASSIST_BONUS;
					}
				}
				it.ctf_flags &= ~CTF_FLAG_FLAG;
			});
			// respawn flags
			TeamRegenFlags();
			return;
		}
	}

	// in three team mode (TEAM_CTF_ALT) and we're on team3, see if we capture
	if(teamplay != TEAM_CTF_ALT || toucher.steam != TEAM3)
		return;

	if(((toucher.ctf_flags & CTF_FLAG_TEAM1) && (this.team == TEAM2)) ||
		((toucher.ctf_flags & CTF_FLAG_TEAM2) && (this.team == TEAM1))) {
		// third team captured

		bprintf("%s ^7captured the %s flag^7!\n", toucher.netname, ((this.team == TEAM1) ? "^4Blue" : "^1Red"));
		toucher.items &= ~(IT_KEY1 | IT_KEY2);

		_sound(toucher, CH_INFO, "misc/flagcap.wav", 1, ATTN_NONE);

		// toucher gets antoucher 10 frag bonus
		toucher.frags = toucher.frags + CTF_ALT_CAPTURE_BONUS;

		// Ok, let's do the player loop, hand out the bonuses
		FOREACH_CLIENT(IS_PLAYER(it),
		{
			if(it.team == toucher.team && it != toucher)
				it.frags = it.frags + CTF_ALT_TEAM_BONUS;
			if(it.team != toucher.team)
			{
				if((toucher.ctf_flags & CTF_FLAG_TEAM1) && it.team == TEAM1)
					centerprint(it, "Your flag was captured!\n");
				else if((toucher.ctf_flags & CTF_FLAG_TEAM2) && it.team == TEAM2)
					centerprint(it, "The enemy flag was captured!\n");
				// reset the last_hurt_carrier variable in all enemy players, so that you don't get
				// bonuses for defending the flag carrier if the flag carrier has already
				// completed a capture
				it.ctf_lasthurtcarrier = -5;
			}
			else if(it.team == toucher.team)
			{
				// done to all players on the capturing team
				centerprint(it, "Your team captured the flag!\n");
			}
		});
		// respawn flags
		if(toucher.ctf_flags & CTF_FLAG_TEAM1)
		{
			entity f = find(NULL, classname, "item_flag_team1");
			if(f != NULL)
				RegenFlag(f);
		}
		else
		{ // must be flag2
			entity f = find(NULL, classname, "item_flag_team2");
			if(f != NULL)
				RegenFlag(f);
		}
		toucher.ctf_flags &= ~(CTF_FLAG_TEAM1 | CTF_FLAG_TEAM2);
		return;
	}
}

void TeamFlagThink(entity this)
{
	this.nextthink = time + 0.1;

	if(this.cnt == FLAG_AT_BASE)
		return; // just sitting around waiting to be picked up

	if(this.cnt == FLAG_DROPPED)
	{
		if(time - this.super_time > CTF_FLAG_RETURN_TIME)
			TeamReturnFlag(this);
		return;
	}

	if(this.cnt != FLAG_CARRIED)
		objerror(this, "Flag in invalid state\n");

	entity e = this.owner;
	if(!IS_PLAYER(e) || e.deadflag)
	{
		TeamDropFlag(this);
		return;
	}

	if(teamplay == TEAM_CTF_ONEFLAG && !(e.ctf_flags & CTF_FLAG_FLAG))
	{
		TeamDropFlag(this);
		return;
	}
	// must be TEAM_CTF or TEAM_CTF_ALT
	if((!(e.ctf_flags & CTF_FLAG_TEAM1) && this.team == TEAM1) ||
		(!(e.ctf_flags & CTF_FLAG_TEAM2) && this.team == TEAM2))
	{
		TeamDropFlag(this);
		return;
	}

	makevectors(e.angles);
	vector v = v_forward;
	v.z = (-1) * v.z; // reverse z component

	float f = 14;
	if(this.owner.frame >= 29 && this.owner.frame <= 40)
	{
		if(this.owner.frame >= 29 && this.owner.frame <= 34)
		{ //axpain
			if      (this.owner.frame == 29) f = f + 2; 
			else if(this.owner.frame == 30) f = f + 8;
			else if(this.owner.frame == 31) f = f + 12;
			else if(this.owner.frame == 32) f = f + 11;
			else if(this.owner.frame == 33) f = f + 10;
			else if(this.owner.frame == 34) f = f + 4;
		}
		else if(this.owner.frame >= 35 && this.owner.frame <= 40)
		{ // pain
			if      (this.owner.frame == 35) f = f + 2; 
			else if(this.owner.frame == 36) f = f + 10;
			else if(this.owner.frame == 37) f = f + 10;
			else if(this.owner.frame == 38) f = f + 8;
			else if(this.owner.frame == 39) f = f + 4;
			else if(this.owner.frame == 40) f = f + 2;
		}
	}
	else if(this.owner.frame >= 103 && this.owner.frame <= 118)
	{
		if      (this.owner.frame >= 103 && this.owner.frame <= 104) f = f + 6;  //nailattack
		else if(this.owner.frame >= 105 && this.owner.frame <= 106) f = f + 6;  //light 
		else if(this.owner.frame >= 107 && this.owner.frame <= 112) f = f + 7;  //rocketattack
		else if(this.owner.frame >= 112 && this.owner.frame <= 118) f = f + 7;  //shotattack
	}
	this.origin = e.origin + '0 0 -16' - f*v + v_right * 22;
	this.angles = e.angles + '0 0 -45';
	setorigin(this, this.origin);
	this.nextthink = time + 0.01;
}

void TeamFlagStatusReport(entity this)
{
	if(!deathmatch)
		return;

	if(teamplay != TEAM_CTF && teamplay != TEAM_CTF_ONEFLAG &&
		teamplay != TEAM_CTF_ALT)
	{
		sprint(this, "Capture the Flag is not enabled.\n");
		return;
	}

	entity flag1, flag2;
	if(teamplay == TEAM_CTF_ONEFLAG)
	{
		flag1 = find(NULL, classname, "item_flag");
		if(flag1 == NULL)
			sprint(this, "The flag is missing!\n");
		else if(flag1.cnt == FLAG_AT_BASE)
			sprint(this, "The flag is at base!\n");
		else if(flag1.cnt == FLAG_DROPPED)
			sprint(this, "The flag is lying about!\n");
		else if(flag1.cnt == FLAG_CARRIED) {
			if(flag1.owner == this)
				sprint(this, "You have the flag!\n");
			else {
				sprint(this, flag1.owner.netname);
				string n = GetCTFTeam(flag1.owner.steam);
				sprint(this, " of the ");
				sprint(this, n);
				sprint(this, " team has the flag!\n");
			}
		} else 
			sprint(this, "The flag is screwed up!\n");
		return;
	}

	// normal CTF
	if(teamplay == TEAM_CTF)
	{
		// Find the flags at home base
		flag1 = find(NULL, classname, "item_flag_team1");
		flag2 = find(NULL, classname, "item_flag_team2");

		// If on team 2 switch meanings of flags
		if(this.team != TEAM1)
		{
			entity p = flag1;
			flag1 = flag2;
			flag2 = p;
		}

		if(flag1 != NULL && flag1.cnt == FLAG_CARRIED)
		{
			sprint(this, strcat(flag1.owner.netname, " has your flag. "));
		}
		else
		{
			if(flag1 == NULL)
				sprint(this, "Your flag is missing!\n");
			else if(flag1.cnt == FLAG_AT_BASE)
				sprint(this, "Your flag is in your base.\n");
			else if(flag1.cnt == FLAG_DROPPED)
				sprint(this, "Your flag is lying about.\n");
			else
				sprint(this, "Your flag is corrupt.\n");
		}

		if(flag2 != NULL && flag2.cnt == FLAG_CARRIED)
		{
			if(this == flag2.owner) 
				sprint(this, "You have the enemy flag.\n");
			else
			{
				sprint(this, strcat(flag2.owner.netname, " has the enemy flag.\n"));
			}
		}
		else
		{
			if(flag2 == NULL)
				sprint(this, "The enemy flag is missing!\n");
			else if(flag2.cnt == FLAG_AT_BASE)
				sprint(this, "The enemy flag is in their base.\n");
			else if(flag2.cnt == FLAG_DROPPED)
				sprint(this, "The enemy flag is lying about.\n");
			else
				sprint(this, "The enemy flag is corrupt.\n");
		}
	}

	// three team CTF
	if(teamplay == TEAM_CTF_ALT)
	{
		string n;

		// Find the flags at home base
		flag1 = find(NULL, classname, "item_flag_team1");
		flag2 = find(NULL, classname, "item_flag_team2");

		if(flag1 != NULL && flag1.cnt == FLAG_CARRIED)
		{
			if(flag1.owner == this)
				sprint(this, "You have the Red flag!\n");
			else
			{
				n = GetCTFTeam(flag1.owner.steam);
				sprint(this, sprintf("%s of the %s team has the Red Flag.\n", flag1.owner.netname, n));
			}
		}
		else
		{
			string redmessage_you = ((this.steam == flag1.team) ? "Your" : "Red");
			string redmessage_msg;
			if(flag1 == NULL)
				redmessage_msg = "missing!";
			if(flag1.cnt == FLAG_AT_BASE)
				redmessage_msg = "at base.";
			else if(flag1.cnt == FLAG_DROPPED)
				redmessage_msg = "lying about.";
			else
				redmessage_msg = "corrupt.";
			sprint(this, strcat(redmessage_you, " flag is ", redmessage_msg, "\n"));
		}

		if(flag2 != NULL && flag2.cnt == FLAG_CARRIED)
		{
			if(flag2.owner == this) 
				sprint(this, "You have the Blue flag.\n");
			else
			{
				n = GetCTFTeam(flag2.owner.steam);
				sprint(this, sprintf("%s of the %s team has the Blue Flag.\n", flag2.owner.netname, n));
			}
		}
		else
		{
			string bluemessage_you = ((this.steam == flag2.team) ? "Your" : "Blue");
			string bluemessage_msg;
			if(flag2 == NULL)
				bluemessage_msg = "missing!";
			if(flag2.cnt == FLAG_AT_BASE)
				bluemessage_msg = "at base.";
			else if(flag2.cnt == FLAG_DROPPED)
				bluemessage_msg = "lying about.";
			else
				bluemessage_msg = "corrupt.";
			sprint(this, strcat(bluemessage_you, " flag is ", bluemessage_msg, "\n"));
		}
	}
}

/////////////////////////////////////////////////////////////////////////

$cd id1/models/flag
$base base
$skin skin

void place_flag(entity this)
{
	this.mdl = this.model;		// so it can be restored on respawn
	this.flags = FL_ITEM;		// make extra wide
	this.solid = SOLID_TRIGGER;
	set_movetype(this, MOVETYPE_TOSS);	
	this.velocity = '0 0 0';
	this.origin_z = this.origin_z + 6;
	setthink(this, TeamFlagThink);
	settouch(this, TeamFlagTouch);
	this.nextthink = time + 0.1;
	this.cnt = FLAG_AT_BASE;
	this.mangle = this.angles;
	this.effects |= EF_DIMLIGHT;
	droptofloor(this);
	this.oldorigin = this.origin; // save for flag return
}

void place_flagbase(entity flg, string cname)
{
	entity base = spawn();
	base.classname = cname;
	setorigin(base, flg.origin);
	base.angles = flg.angles;
	precache_model("progs/ctfbase.mdl");
	_setmodel(base, "progs/ctfbase.mdl");
	base.skin = flg.skin;
	base.team = flg.team;
//	setsize(base, '-8 -8 -4', '8 8 4');
	setsize(base, '-8 -8 0', '8 8 8');
	base.flags = FL_ITEM;		// make extra wide
	set_movetype(base, MOVETYPE_TOSS);
	base.velocity = '0 0 0';
	base.origin_z = base.origin_z + 6;
	if(teamplay == TEAM_CTF_ONEFLAG || teamplay == TEAM_CTF_ALT)
	{
		base.solid = SOLID_TRIGGER;
		settouch(base, TeamFlagBaseTouch);
	}
	else
		base.solid = SOLID_NOT;
	droptofloor(base);
}

// ZOID Capture the flag
/*QUAKED item_flag_team1 (0 .5 .8) (-8 -8 -32) (8 8 24)
red team flag
Only appears in CTF teamplay

The flag waves 90 degrees off from the entity angle. If
you want the flag to point at 180, set then entity angle
to 90.
*/
spawnfunc(item_flag_team1)
{
	if(!MP_ROGUE) { delete(this); return; }
	if(!deathmatch) { delete(this); return; }

	if(teamplay == TEAM_CTF_ONEFLAG)
	{
		precache_sound("misc/flagtk.wav");		// flag taken
		precache_sound("misc/flagcap.wav");	// flag capture
		this.skin = 0;
		this.team = TEAM1;
		place_flagbase(this, "item_flagbase_team1");
		delete(this);
		return;
	}

	if(teamplay == TEAM_CTF || teamplay == TEAM_CTF_ALT)
	{
		this.team = TEAM1;
		this.items = IT_KEY2;
		precache_model("progs/ctfmodel.mdl");
		_setmodel(this, "progs/ctfmodel.mdl");
		this.skin = 0;
		precache_sound("misc/flagtk.wav");		// flag taken
		precache_sound("misc/flagcap.wav");	// flag capture
		precache_sound("misc/flagret.wav");	// flag return
		this.noise = "misc/flagtk.wav";
		this.noise1 = "misc/flagret.wav";
		setsize(this, '-16 -16 0', '16 16 74');
		this.nextthink = time + 0.2;	// items start after other solids
		setthink(this, place_flag);
		place_flagbase(this, "item_flagbase_team1");
	}
	else
	{
		delete(this); // not teamplay or deathmatch
	}
}

/*QUAKED item_flag_team2 (0 .5 .8) (-8 -8 -32) (8 8 24)
blue team flag
Only appears in CTF teamplay

The flag waves 90 degrees off from the entity angle. If
you want the flag to point at 180, set then entity angle
to 90.
*/
spawnfunc(item_flag_team2)
{
	if(!MP_ROGUE) { delete(this); return; }
	if(!deathmatch) { delete(this); return; }

	if(teamplay == TEAM_CTF_ONEFLAG) {
		precache_sound ("misc/flagtk.wav");		// flag taken
		precache_sound ("misc/flagcap.wav");	// flag capture
		this.team = TEAM2;
		this.skin = 1;
		place_flagbase(this, "item_flagbase_team2");
		delete(this);
		return;
	}

	if(teamplay == TEAM_CTF || teamplay == TEAM_CTF_ALT)
	{
		this.team = TEAM2;
		this.items = IT_KEY1;
		precache_model("progs/ctfmodel.mdl");
		_setmodel(this, "progs/ctfmodel.mdl");
		this.skin = 1;
		precache_sound("misc/flagtk.wav");		// flag taken
		precache_sound("misc/flagcap.wav");	// flag capture
		precache_sound("misc/flagret.wav");	// flag return
		this.noise = "misc/flagtk.wav";
		this.noise1 = "misc/flagret.wav";
		setsize(this, '-16 -16 0', '16 16 74');
		this.nextthink = time + 0.2;	// items start after other solids
		setthink(this, place_flag);
		place_flagbase(this, "item_flagbase_team2");
	}
	else
	{
		delete(this); // not teamplay or deathmatch
	}
}

/*QUAKED item_flag (0 .5 .8) (-8 -8 -32) (8 8 24)
flag for OneTeam play.
Only appears in CTF teamplay

The flag waves 90 degrees off from the entity angle. If
you want the flag to point at 180, set then entity angle
to 90.
*/
spawnfunc(item_flag)
{
	if(!MP_ROGUE) { delete(this); return; }

	if(teamplay != TEAM_CTF_ONEFLAG)
	{
		delete(this);
		return;
	}
	this.team = 0; // no team
	this.items = IT_KEY1 | IT_KEY2;
//	precache_model ("progs/flag.mdl");
//	_setmodel(this, "progs/flag.mdl");
	precache_model("progs/ctfmodel.mdl");		// PGM 01/18/97
	_setmodel(this, "progs/ctfmodel.mdl");	// PGM 01/18/97
	this.skin = 2;
	precache_sound("misc/flagtk.wav");		// flag taken
	precache_sound("misc/flagcap.wav");	// flag capture
	precache_sound("misc/flagret.wav");	// flag return
	this.noise = "misc/flagtk.wav";
	this.noise1 = "misc/flagret.wav";
	setsize(this, '-16 -16 0', '16 16 74');
	this.nextthink = time + 0.2;	// items start after other solids
	setthink(this, place_flag);
	place_flagbase(this, "item_flagbase");
}

/*QUAKED info_player_team1 (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for CTF games team 1.
*/
spawnfunc(info_player_team1) 
{
	if(!MP_ROGUE) { delete(this); return; }
}

/*QUAKED info_player_team2 (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for CTF games team 2.
*/
spawnfunc(info_player_team2) 
{
	if(!MP_ROGUE) { delete(this); return; }
}

void TeamSetUpdate()
{
	nextteamupdtime = time + CTF_UPDATE_TIME;
}

void TeamCheckUpdate()
{
	if(nextteamupdtime > time || teamplay < 1 || !deathmatch)
		return;

	TeamSetUpdate();

	// count up total
	float total1 = 0, total2 = 0, total3 = 0;

	string ts1 = GetCTFTeam(TEAM1);
	string ts2 = GetCTFTeam(TEAM2);
	string ts3 = GetCTFTeam(TEAM3);

	if(teamplay == TEAM_CTF || teamplay == TEAM_CTF_ALT || teamplay == TEAM_CTF_ONEFLAG)
	{
		FOREACH_CLIENT(IS_PLAYER(it),
		{
			if(it.steam == TEAM1)
				total1 = total1 + it.frags;
			else if(it.steam == TEAM2)
				total2 = total2 + it.frags;
			else if(it.steam == TEAM3)
				total3 = total3 + it.frags;
		});

		string s;
		if(teamplay == TEAM_CTF || teamplay == TEAM_CTF_ONEFLAG)
		{
			if(total1 > total2)
			{
				s = ftos(total1 - total2);
				bprintf("%s team is leading by %s points!\n", ts1, s);
			}
			else if(total1 < total2)
			{
				s = ftos(total2 - total1);
				bprintf("%s team is leading by %s points\n", ts2, s);
			}
			else
			{
				s = ftos(total1);
				bprintf("%s and %s teams are tied with %s points!\n", ts1, ts2, s);
			}
		}
		else if(teamplay == TEAM_CTF_ALT)
		{
			if(total1 > total2 && total1 > total3)
			{
				if(total2 > total3)
					s = ftos(total1 - total2);
				else
					s = ftos(total1 - total3);
				bprintf("%s team is leading by %s points!\n", ts1, s);
			}
			else if(total2 > total1 && total2 > total3)
			{
				if(total1 > total3)
					s = ftos(total2 - total1);
				else
					s = ftos(total2 - total3);
				bprintf("%s team is leading by %s points!\n", ts2, s);
			}
			else if(total3 > total1 && total3 > total2)
			{
				if(total1 > total2)
					s = ftos(total3 - total1);
				else
					s = ftos(total3 - total2);
				bprintf("%s team is leading by %s points!\n", ts3, s);
			}
			else if(total1 == total2)
			{
				s = ftos(total1);
				bprintf("%s and %s teams are tied with %s points!\n", ts1, ts2, s);
			}
			else if(total3 == total2)
			{
				s = ftos(total3);
				bprintf("%s and %s teams are tied with %s points!\n", ts2, ts3, s);
			}
			else if(total3 == total1)
			{
				s = ftos(total1);
				bprintf("%s and %s teams are tied with %s points!\n", ts1, ts3, s);
			}
			else
			{
				s = ftos(total1);
				bprintf("%s, %s and %s teams are tied with %s points!\n", ts1, ts2, ts3, s);
			}
		}
	}
}

/*QUAKED func_ctf_wall (0 .5 .8) ?
This is just a solid wall if not inhibitted
Only appears in CTF teamplay
*/
spawnfunc(func_ctf_wall)
{
	if(!MP_ROGUE) { delete(this); return; }

	if(teamplay == TEAM_CTF || teamplay == TEAM_CTF_ONEFLAG ||
		teamplay == TEAM_CTF_ALT)
	{
		this.angles = '0 0 0';
		set_movetype(this, MOVETYPE_PUSH);	// so it doesn't get pushed by anything
		this.solid = SOLID_BSP;
		_setmodel(this, this.model);
	}
	else
		delete(this);
}
