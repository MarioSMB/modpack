#include "havocbot.qh"
#include "role_onslaught.qc"
#include "role_keyhunt.qc"
#include "roles.qc"

void havocbot_ai()
{
	if(self.draggedby)
		return;

	if(bot_execute_commands())
		return;

	if (bot_strategytoken == self)
	if (!bot_strategytoken_taken)
	{
		if(self.havocbot_blockhead)
		{
			self.havocbot_blockhead = FALSE;
		}
		else
		{
			if not(self.jumppadcount)
				self.havocbot_role();
		}

		// TODO: tracewalk() should take care of this job (better path finding under water)
		// if we don't have a goal and we're under water look for a waypoint near the "shore" and push it
		if(self.deadflag != DEAD_NO)
		if(self.goalcurrent==world)
		if(self.waterlevel==WATERLEVEL_SWIMMING || self.aistatus & AI_STATUS_OUT_WATER)
		{
			// Look for the closest waypoint out of water
			entity newgoal, head;
			float bestdistance, distance;

			newgoal = world;
			bestdistance = 10000;
			for (head = findchain(classname, "waypoint"); head; head = head.chain)
			{
				distance = vlen(head.origin - self.origin);
				if(distance>10000)
					continue;

				if(head.origin_z < self.origin_z)
					continue;

				if(head.origin_z - self.origin_z - self.view_ofs_z > 100)
					continue;

				if (pointcontents(head.origin + head.maxs + '0 0 1') != CONTENT_EMPTY)
					continue;

				traceline(self.origin + self.view_ofs , head.origin, TRUE, head);

				if(trace_fraction<1)
					continue;

				if(distance<bestdistance)
				{
					newgoal = head;
					bestdistance = distance;
				}
			}

			if(newgoal)
			{
			//	te_wizspike(newgoal.origin);
				navigation_pushroute(newgoal);
			}
		}

		// token has been used this frame
		bot_strategytoken_taken = TRUE;
	}

	if(self.deadflag != DEAD_NO)
		return;

	havocbot_chooseenemy();
	if (self.bot_chooseweapontime < time )
	{
		self.bot_chooseweapontime = time + autocvar_bot_ai_chooseweaponinterval;
		havocbot_chooseweapon();
	}
	havocbot_aim();
	lag_update();
	if (self.bot_aimtarg)
	{
		self.aistatus |= AI_STATUS_ATTACKING;
		self.aistatus &~= AI_STATUS_ROAMING;

		if(!WEPSET_EMPTY_E(self))
		{
			weapon_action(self.weapon, WR_AIM);
			if (autocvar_bot_nofire || IS_INDEPENDENT_PLAYER(self))
			{
				self.BUTTON_ATCK = FALSE;
				self.BUTTON_ATCK2 = FALSE;
			}
			else
			{
				if(self.BUTTON_ATCK||self.BUTTON_ATCK2)
					self.lastfiredweapon = self.weapon;
			}
		}
		else
		{
			if(IS_PLAYER(self.bot_aimtarg))
				bot_aimdir(self.bot_aimtarg.origin + self.bot_aimtarg.view_ofs - self.origin - self.view_ofs , -1);
		}
	}
	else if (self.goalcurrent)
	{
		self.aistatus |= AI_STATUS_ROAMING;
		self.aistatus &~= AI_STATUS_ATTACKING;

		vector now,v,next;//,heading;
		float aimdistance,skillblend,distanceblend,blend;
		next = now = ( (self.goalcurrent.absmin + self.goalcurrent.absmax) * 0.5) - (self.origin + self.view_ofs);
		aimdistance = vlen(now);
		//heading = self.velocity;
		//dprint(self.goalstack01.classname,etos(self.goalstack01),"\n");
		if(
			self.goalstack01 != self && self.goalstack01 != world && self.aistatus & AI_STATUS_RUNNING == 0 &&
			!(self.goalcurrent.wpflags & WAYPOINTFLAG_TELEPORT)
		)
			next = ((self.goalstack01.absmin + self.goalstack01.absmax) * 0.5) - (self.origin + self.view_ofs);

		skillblend=bound(0,(skill+self.bot_moveskill-2.5)*0.5,1); //lower skill player can't preturn
		distanceblend=bound(0,aimdistance/autocvar_bot_ai_keyboard_distance,1);
		blend = skillblend * (1-distanceblend);
		//v = (now * (distanceblend) + next * (1-distanceblend)) * (skillblend) + now * (1-skillblend);
		//v = now * (distanceblend) * (skillblend) + next * (1-distanceblend) * (skillblend) + now * (1-skillblend);
		//v = now * ((1-skillblend) + (distanceblend) * (skillblend)) + next * (1-distanceblend) * (skillblend);
		v = now + blend * (next - now);
		//dprint(etos(self), " ");
		//dprint(vtos(now), ":", vtos(next), "=", vtos(v), " (blend ", ftos(blend), ")\n");
		//v = now * (distanceblend) + next * (1-distanceblend);
		if (self.waterlevel < WATERLEVEL_SWIMMING)
			v_z = 0;
		//dprint("walk at:", vtos(v), "\n");
		//te_lightning2(world, self.origin, self.goalcurrent.origin);
		bot_aimdir(v, -1);
	}
	havocbot_movetogoal();

	// if the bot is not attacking, consider reloading weapons
	if not(self.aistatus & AI_STATUS_ATTACKING)
	{
		float i;
		entity e;

		// we are currently holding a weapon that's not fully loaded, reload it
		if(skill >= 2) // bots can only reload the held weapon on purpose past this skill
		if(self.clip_load < self.clip_size)
			self.impulse = 20; // "press" the reload button, not sure if this is done right

		// if we're not reloading a weapon, switch to any weapon in our invnetory that's not fully loaded to reload it next
		// the code above executes next frame, starting the reloading then
		if(skill >= 5) // bots can only look for unloaded weapons past this skill
		if(self.clip_load >= 0) // only if we're not reloading a weapon already
		{
			for(i = WEP_FIRST; i <= WEP_LAST; ++i)
			{
				e = get_weaponinfo(i);
				if (WEPSET_CONTAINS_EW(self, i) && (e.spawnflags & WEP_FLAG_RELOADABLE) && (self.weapon_load[i] < cvar(strcat("g_balance_", e.netname, "_reload_ammo"))))
					self.switchweapon = i;
			}
		}
	}
}

void havocbot_keyboard_movement(vector destorg)
{
	vector keyboard;
	float blend, maxspeed;
	float sk;

	sk = skill + self.bot_moveskill;

	maxspeed = autocvar_sv_maxspeed;

	if (time < self.havocbot_keyboardtime)
		return;

	self.havocbot_keyboardtime =
		max(
			self.havocbot_keyboardtime
				+ 0.05/max(1, sk+self.havocbot_keyboardskill)
				+ random()*0.025/max(0.00025, skill+self.havocbot_keyboardskill)
		, time);
	keyboard = self.movement * (1.0 / maxspeed);

	float trigger, trigger1;
	blend = bound(0,sk*0.1,1);
	trigger = autocvar_bot_ai_keyboard_threshold;
	trigger1 = 0 - trigger;

	// categorize forward movement
	// at skill < 1.5 only forward
	// at skill < 2.5 only individual directions
	// at skill < 4.5 only individual directions, and forward diagonals
	// at skill >= 4.5, all cases allowed
	if (keyboard_x > trigger)
	{
		keyboard_x = 1;
		if (sk < 2.5)
			keyboard_y = 0;
	}
	else if (keyboard_x < trigger1 && sk > 1.5)
	{
		keyboard_x = -1;
		if (sk < 4.5)
			keyboard_y = 0;
	}
	else
	{
		keyboard_x = 0;
		if (sk < 1.5)
			keyboard_y = 0;
	}
	if (sk < 4.5)
		keyboard_z = 0;

	if (keyboard_y > trigger)
		keyboard_y = 1;
	else if (keyboard_y < trigger1)
		keyboard_y = -1;
	else
		keyboard_y = 0;

	if (keyboard_z > trigger)
		keyboard_z = 1;
	else if (keyboard_z < trigger1)
		keyboard_z = -1;
	else
		keyboard_z = 0;

	self.havocbot_keyboard = keyboard * maxspeed;
	if (self.havocbot_ducktime>time) self.BUTTON_CROUCH=TRUE;

	keyboard = self.havocbot_keyboard;
	blend = bound(0,vlen(destorg-self.origin)/autocvar_bot_ai_keyboard_distance,1); // When getting close move with 360 degree
	//dprint("movement ", vtos(self.movement), " keyboard ", vtos(keyboard), " blend ", ftos(blend), "\n");
	self.movement = self.movement + (keyboard - self.movement) * blend;
}

void havocbot_bunnyhop(vector dir)
{
	float bunnyhopdistance;
	vector deviation;
	float maxspeed;
	vector gco, gno;

	if(autocvar_g_midair)
		return;

	// Don't jump when attacking
	if(self.aistatus & AI_STATUS_ATTACKING)
		return;

	if(IS_PLAYER(self.goalcurrent))
		return;

	maxspeed = autocvar_sv_maxspeed;

	if(self.aistatus & AI_STATUS_DANGER_AHEAD)
	{
		self.aistatus &~= AI_STATUS_RUNNING;
		self.BUTTON_JUMP = FALSE;
		self.bot_canruntogoal = 0;
		self.bot_timelastseengoal = 0;
		return;
	}

	if(self.waterlevel > WATERLEVEL_WETFEET)
	{
		self.aistatus &~= AI_STATUS_RUNNING;
		return;
	}

	if(self.bot_lastseengoal != self.goalcurrent && !(self.aistatus & AI_STATUS_RUNNING))
	{
		self.bot_canruntogoal = 0;
		self.bot_timelastseengoal = 0;
	}

	gco = (self.goalcurrent.absmin + self.goalcurrent.absmax) * 0.5;
	bunnyhopdistance = vlen(self.origin - gco);

	// Run only to visible goals
	if(self.flags & FL_ONGROUND)
	if(self.speed==maxspeed)
	if(checkpvs(self.origin + self.view_ofs, self.goalcurrent))
	{
			self.bot_lastseengoal = self.goalcurrent;

			// seen it before
			if(self.bot_timelastseengoal)
			{
				// for a period of time
				if(time - self.bot_timelastseengoal > autocvar_bot_ai_bunnyhop_firstjumpdelay)
				{
					float checkdistance;
					checkdistance = TRUE;

					// don't run if it is too close
					if(self.bot_canruntogoal==0)
					{
						if(bunnyhopdistance > autocvar_bot_ai_bunnyhop_startdistance)
							self.bot_canruntogoal = 1;
						else
							self.bot_canruntogoal = -1;
					}

					if(self.bot_canruntogoal != 1)
						return;

					if(self.aistatus & AI_STATUS_ROAMING)
					if(self.goalcurrent.classname=="waypoint")
					if not(self.goalcurrent.wpflags & WAYPOINTFLAG_PERSONAL)
					if(fabs(gco_z - self.origin_z) < self.maxs_z - self.mins_z)
					if(self.goalstack01!=world)
					{
						gno = (self.goalstack01.absmin + self.goalstack01.absmax) * 0.5;
						deviation = vectoangles(gno - self.origin) - vectoangles(gco - self.origin);
						while (deviation_y < -180) deviation_y = deviation_y + 360;
						while (deviation_y > 180) deviation_y = deviation_y - 360;

						if(fabs(deviation_y) < 20)
						if(bunnyhopdistance < vlen(self.origin - gno))
						if(fabs(gno_z - gco_z) < self.maxs_z - self.mins_z)
						{
							if(vlen(gco - gno) > autocvar_bot_ai_bunnyhop_startdistance)
							if(checkpvs(self.origin + self.view_ofs, self.goalstack01))
							{
								checkdistance = FALSE;
							}
						}
					}

					if(checkdistance)
					{
						self.aistatus &~= AI_STATUS_RUNNING;
						if(bunnyhopdistance > autocvar_bot_ai_bunnyhop_stopdistance)
							self.BUTTON_JUMP = TRUE;
					}
					else
					{
						self.aistatus |= AI_STATUS_RUNNING;
						self.BUTTON_JUMP = TRUE;
					}
				}
			}
			else
			{
				self.bot_timelastseengoal = time;
			}
	}
	else
	{
		self.bot_timelastseengoal = 0;
	}

#if 0
	// Release jump button
	if(!cvar("sv_pogostick"))
	if(self.flags & FL_ONGROUND == 0)
	{
		if(self.velocity_z < 0 || vlen(self.velocity)<maxspeed)
			self.BUTTON_JUMP = FALSE;

		// Strafe
		if(self.aistatus & AI_STATUS_RUNNING)
		if(vlen(self.velocity)>maxspeed)
		{
			deviation = vectoangles(dir) - vectoangles(self.velocity);
			while (deviation_y < -180) deviation_y = deviation_y + 360;
			while (deviation_y > 180) deviation_y = deviation_y - 360;

			if(fabs(deviation_y)>10)
				self.movement_x = 0;

			if(deviation_y>10)
				self.movement_y = maxspeed * -1;
			else if(deviation_y<10)
				self.movement_y = maxspeed;

		}
	}
#endif
}

void havocbot_movetogoal()
{
	vector destorg;
	vector diff;
	vector dir;
	vector flatdir;
	vector m1;
	vector m2;
	vector evadeobstacle;
	vector evadelava;
	float s;
	float maxspeed;
	vector gco;
	//float dist;
	vector dodge;
	//if (self.goalentity)
	//	te_lightning2(self, self.origin, (self.goalentity.absmin + self.goalentity.absmax) * 0.5);
	self.movement = '0 0 0';
	maxspeed = autocvar_sv_maxspeed;

	// Jetpack navigation
	if(self.goalcurrent)
	if(self.navigation_jetpack_goal)
	if(self.goalcurrent==self.navigation_jetpack_goal)
	if(self.ammo_fuel)
	{
		if(autocvar_bot_debug_goalstack)
		{
			debuggoalstack();
			te_wizspike(self.navigation_jetpack_point);
		}

		// Take off
		if not(self.aistatus & AI_STATUS_JETPACK_FLYING)
		{
			// Brake almost completely so it can get a good direction
			if(vlen(self.velocity)>10)
				return;
			self.aistatus |= AI_STATUS_JETPACK_FLYING;
		}

		makevectors(self.v_angle_y * '0 1 0');
		dir = normalize(self.navigation_jetpack_point - self.origin);

		// Landing
		if(self.aistatus & AI_STATUS_JETPACK_LANDING)
		{
			// Calculate brake distance in xy
			float db, v, d;
			vector dxy;

			dxy = self.origin - ( ( self.goalcurrent.absmin + self.goalcurrent.absmax ) * 0.5 ); dxy_z = 0;
			d = vlen(dxy);
			v = vlen(self.velocity -  self.velocity_z * '0 0 1');
			db = (pow(v,2) / (autocvar_g_jetpack_acceleration_side * 2)) + 100;
		//	dprint("distance ", ftos(ceil(d)), " velocity ", ftos(ceil(v)), " brake at ", ftos(ceil(db)), "\n");
			if(d < db || d < 500)
			{
				// Brake
				if(fabs(self.velocity_x)>maxspeed*0.3)
				{
					self.movement_x = dir * v_forward * -maxspeed;
					return;
				}
				// Switch to normal mode
				self.navigation_jetpack_goal = world;
				self.aistatus &~= AI_STATUS_JETPACK_LANDING;
				self.aistatus &~= AI_STATUS_JETPACK_FLYING;
				return;
			}
		}
		else if(checkpvs(self.origin,self.goalcurrent))
		{
			// If I can see the goal switch to landing code
			self.aistatus &~= AI_STATUS_JETPACK_FLYING;
			self.aistatus |= AI_STATUS_JETPACK_LANDING;
			return;
		}

		// Flying
		self.BUTTON_HOOK = TRUE;
		if(self.navigation_jetpack_point_z - PL_MAX_z + PL_MIN_z < self.origin_z)
		{
			self.movement_x = dir * v_forward * maxspeed;
			self.movement_y = dir * v_right * maxspeed;
		}
		return;
	}

	// Handling of jump pads
	if(self.jumppadcount)
	{
		// If got stuck on the jump pad try to reach the farthest visible waypoint
		if(self.aistatus & AI_STATUS_OUT_JUMPPAD)
		{
			if(fabs(self.velocity_z)<50)
			{
				entity head, newgoal = world;
				float distance, bestdistance = 0;

				for (head = findchain(classname, "waypoint"); head; head = head.chain)
				{

					distance = vlen(head.origin - self.origin);
					if(distance>1000)
						continue;

					traceline(self.origin + self.view_ofs , ( ( head.absmin + head.absmax ) * 0.5 ), TRUE, world);

					if(trace_fraction<1)
						continue;

					if(distance>bestdistance)
					{
						newgoal = head;
						bestdistance = distance;
					}
				}

				if(newgoal)
				{
					self.ignoregoal = self.goalcurrent;
					self.ignoregoaltime = time + autocvar_bot_ai_ignoregoal_timeout;
					navigation_clearroute();
					navigation_routetogoal(newgoal, self.origin);
					self.aistatus &~= AI_STATUS_OUT_JUMPPAD;
				}
			}
			else
				return;
		}
		else
		{
			if(self.velocity_z>0)
			{
				float threshold, sxy;
				vector velxy = self.velocity; velxy_z = 0;
				sxy = vlen(velxy);
				threshold = maxspeed * 0.2;
				if(sxy < threshold)
				{
					dprint("Warning: ", self.netname, " got stuck on a jumppad (velocity in xy is ", ftos(sxy), "), trying to get out of it now\n");
					self.aistatus |= AI_STATUS_OUT_JUMPPAD;
				}
				return;
			}

			// Don't chase players while using a jump pad
			if(IS_PLAYER(self.goalcurrent) || IS_PLAYER(self.goalstack01))
				return;
		}
	}
	else if(self.aistatus & AI_STATUS_OUT_JUMPPAD)
		self.aistatus &~= AI_STATUS_OUT_JUMPPAD;

	// If there is a trigger_hurt right below try to use the jetpack or make a rocketjump
	if(skill>6)
	if not(self.flags & FL_ONGROUND)
	{
		tracebox(self.origin, self.mins, self.maxs, self.origin + '0 0 -65536', MOVE_NOMONSTERS, self);
		if(tracebox_hits_trigger_hurt(self.origin, self.mins, self.maxs, trace_endpos ))
		if(self.items & IT_JETPACK)
		{
			tracebox(self.origin, self.mins, self.maxs, self.origin + '0 0 65536', MOVE_NOMONSTERS, self);
			if(tracebox_hits_trigger_hurt(self.origin, self.mins, self.maxs, trace_endpos + '0 0 1' ))
			{
				if(self.velocity_z<0)
				{
					self.BUTTON_HOOK = TRUE;
				}
			}
			else
				self.BUTTON_HOOK = TRUE;

			// If there is no goal try to move forward

			if(self.goalcurrent==world)
				dir = v_forward;
			else
				dir = normalize(( ( self.goalcurrent.absmin + self.goalcurrent.absmax ) * 0.5 ) - self.origin);

			vector xyvelocity = self.velocity; xyvelocity_z = 0;
			float xyspeed = xyvelocity * dir;

			if(xyspeed < (maxspeed / 2))
			{
				makevectors(self.v_angle_y * '0 1 0');
				tracebox(self.origin, self.mins, self.maxs, self.origin + (dir * maxspeed * 3), MOVE_NOMONSTERS, self);
				if(trace_fraction==1)
				{
					self.movement_x = dir * v_forward * maxspeed;
					self.movement_y = dir * v_right * maxspeed;
					if (skill < 10)
						havocbot_keyboard_movement(self.origin + dir * 100);
				}
			}

			self.havocbot_blockhead = TRUE;

			return;
		}
		else if(self.health>autocvar_g_balance_rocketlauncher_damage*0.5)
		{
			if(self.velocity_z < 0)
			if(client_hasweapon(self, WEP_ROCKET_LAUNCHER, TRUE, FALSE))
			{
				self.movement_x = maxspeed;

				if(self.rocketjumptime)
				{
					if(time > self.rocketjumptime)
					{
						self.BUTTON_ATCK2 = TRUE;
						self.rocketjumptime = 0;
					}
					return;
				}

				self.switchweapon = WEP_ROCKET_LAUNCHER;
				self.v_angle_x = 90;
				self.BUTTON_ATCK = TRUE;
				self.rocketjumptime = time + autocvar_g_balance_rocketlauncher_detonatedelay;
				return;
			}
		}
		else
		{
			// If there is no goal try to move forward
			if(self.goalcurrent==world)
				self.movement_x = maxspeed;
		}
	}

	// If we are under water with no goals, swim up
	if(self.waterlevel)
	if(self.goalcurrent==world)
	{
		dir = '0 0 0';
		if(self.waterlevel>WATERLEVEL_SWIMMING)
			dir_z = 1;
		else if(self.velocity_z >= 0 && !(self.waterlevel == WATERLEVEL_WETFEET && self.watertype == CONTENT_WATER))
			self.BUTTON_JUMP = TRUE;
		else
			self.BUTTON_JUMP = FALSE;
		makevectors(self.v_angle_y * '0 1 0');
		self.movement_x = dir * v_forward * maxspeed;
		self.movement_y = dir * v_right * maxspeed;
		self.movement_z = dir * v_up * maxspeed;
	}

	// if there is nowhere to go, exit
	if (self.goalcurrent == world)
		return;

	if (self.goalcurrent)
		navigation_poptouchedgoals();

	// if ran out of goals try to use an alternative goal or get a new strategy asap
	if(self.goalcurrent == world)
	{
		self.bot_strategytime = 0;
		return;
	}


	if(autocvar_bot_debug_goalstack)
		debuggoalstack();

	m1 = self.goalcurrent.origin + self.goalcurrent.mins;
	m2 = self.goalcurrent.origin + self.goalcurrent.maxs;
	destorg = self.origin;
	destorg_x = bound(m1_x, destorg_x, m2_x);
	destorg_y = bound(m1_y, destorg_y, m2_y);
	destorg_z = bound(m1_z, destorg_z, m2_z);
	diff = destorg - self.origin;
	//dist = vlen(diff);
	dir = normalize(diff);
	flatdir = diff;flatdir_z = 0;
	flatdir = normalize(flatdir);
	gco = (self.goalcurrent.absmin + self.goalcurrent.absmax) * 0.5;

	//if (self.bot_dodgevector_time < time)
	{
	//	self.bot_dodgevector_time = time + cvar("bot_ai_dodgeupdateinterval");
	//	self.bot_dodgevector_jumpbutton = 1;
		evadeobstacle = '0 0 0';
		evadelava = '0 0 0';

		if (self.waterlevel)
		{
			if(self.waterlevel>WATERLEVEL_SWIMMING)
			{
			//	flatdir_z = 1;
				self.aistatus |= AI_STATUS_OUT_WATER;
			}
			else
			{
				if(self.velocity_z >= 0 && !(self.watertype == CONTENT_WATER && gco_z < self.origin_z) &&
					( !(self.waterlevel == WATERLEVEL_WETFEET && self.watertype == CONTENT_WATER) || self.aistatus & AI_STATUS_OUT_WATER))
					self.BUTTON_JUMP = TRUE;
				else
					self.BUTTON_JUMP = FALSE;
			}
			dir = normalize(flatdir);
			makevectors(self.v_angle_y * '0 1 0');
		}
		else
		{
			if(self.aistatus & AI_STATUS_OUT_WATER)
				self.aistatus &~= AI_STATUS_OUT_WATER;

			// jump if going toward an obstacle that doesn't look like stairs we
			// can walk up directly
			tracebox(self.origin, self.mins, self.maxs, self.origin + self.velocity * 0.2, FALSE, self);
			if (trace_fraction < 1)
			if (trace_plane_normal_z < 0.7)
			{
				s = trace_fraction;
				tracebox(self.origin + stepheightvec, self.mins, self.maxs, self.origin + self.velocity * 0.2 + stepheightvec, FALSE, self);
				if (trace_fraction < s + 0.01)
				if (trace_plane_normal_z < 0.7)
				{
					s = trace_fraction;
					tracebox(self.origin + jumpstepheightvec, self.mins, self.maxs, self.origin + self.velocity * 0.2 + jumpstepheightvec, FALSE, self);
					if (trace_fraction > s)
						self.BUTTON_JUMP = 1;
				}
			}

			// avoiding dangers and obstacles
			vector dst_ahead, dst_down;
			makevectors(self.v_angle_y * '0 1 0');
			dst_ahead = self.origin + self.view_ofs + (self.velocity * 0.4) + (v_forward * 32 * 3);
			dst_down = dst_ahead + '0 0 -1500';

			// Look ahead
			traceline(self.origin + self.view_ofs , dst_ahead, TRUE, world);

			// Check head-banging against walls
			if(vlen(self.origin + self.view_ofs - trace_endpos) < 25 && !(self.aistatus & AI_STATUS_OUT_WATER))
			{
				self.BUTTON_JUMP = TRUE;
				if(self.facingwalltime && time > self.facingwalltime)
				{
					self.ignoregoal = self.goalcurrent;
					self.ignoregoaltime = time + autocvar_bot_ai_ignoregoal_timeout;
					self.bot_strategytime = 0;
					return;
				}
				else
				{
					self.facingwalltime = time + 0.05;
				}
			}
			else
			{
				self.facingwalltime = 0;

				if(self.ignoregoal != world && time > self.ignoregoaltime)
				{
					self.ignoregoal = world;
					self.ignoregoaltime = 0;
				}
			}

			// Check for water/slime/lava and dangerous edges
			// (only when the bot is on the ground or jumping intentionally)
			self.aistatus &~= AI_STATUS_DANGER_AHEAD;

			if(trace_fraction == 1 && self.jumppadcount == 0 && !self.goalcurrent.wphardwired )
			if(self.flags & FL_ONGROUND || self.aistatus & AI_STATUS_RUNNING || self.BUTTON_JUMP == TRUE)
			{
				// Look downwards
				traceline(dst_ahead , dst_down, TRUE, world);
			//	te_lightning2(world, self.origin, dst_ahead);	// Draw "ahead" look
			//	te_lightning2(world, dst_ahead, dst_down);		// Draw "downwards" look
				if(trace_endpos_z < self.origin_z + self.mins_z)
				{
					s = pointcontents(trace_endpos + '0 0 1');
					if (s != CONTENT_SOLID)
					if (s == CONTENT_LAVA || s == CONTENT_SLIME)
						evadelava = normalize(self.velocity) * -1;
					else if (s == CONTENT_SKY)
						evadeobstacle = normalize(self.velocity) * -1;
					else if (!boxesoverlap(dst_ahead - self.view_ofs + self.mins, dst_ahead - self.view_ofs + self.maxs,
								self.goalcurrent.absmin, self.goalcurrent.absmax))
					{
						// if ain't a safe goal with "holes" (like the jumpad on soylent)
						// and there is a trigger_hurt below
						if(tracebox_hits_trigger_hurt(dst_ahead, self.mins, self.maxs, trace_endpos))
						{
							// Remove dangerous dynamic goals from stack
							dprint("bot ", self.netname, " avoided the goal ", self.goalcurrent.classname, " ", etos(self.goalcurrent), " because it led to a dangerous path; goal stack cleared\n");
							navigation_clearroute();
							return;
						}
					}
				}
			}

			dir = flatdir;
			evadeobstacle_z = 0;
			evadelava_z = 0;
			makevectors(self.v_angle_y * '0 1 0');

			if(evadeobstacle!='0 0 0'||evadelava!='0 0 0')
				self.aistatus |= AI_STATUS_DANGER_AHEAD;
		}

		dodge = havocbot_dodge();
		dodge = dodge * bound(0,0.5+(skill+self.bot_dodgeskill)*0.1,1);
		evadelava = evadelava * bound(1,3-(skill+self.bot_dodgeskill),3); //Noobs fear lava a lot and take more distance from it
		traceline(self.origin, ( ( self.enemy.absmin + self.enemy.absmax ) * 0.5 ), TRUE, world);
		if(IS_PLAYER(trace_ent))
			dir = dir * bound(0,(skill+self.bot_dodgeskill)/7,1);

		dir = normalize(dir + dodge + evadeobstacle + evadelava);
	//	self.bot_dodgevector = dir;
	//	self.bot_dodgevector_jumpbutton = self.BUTTON_JUMP;
	}

	if(time < self.ladder_time)
	{
		if(self.goalcurrent.origin_z + self.goalcurrent.mins_z > self.origin_z + self.mins_z)
		{
			if(self.origin_z + self.mins_z  < self.ladder_entity.origin_z + self.ladder_entity.maxs_z)
				dir_z = 1;
		}
		else
		{
			if(self.origin_z + self.mins_z  > self.ladder_entity.origin_z + self.ladder_entity.mins_z)
				dir_z = -1;
		}
	}

	//dir = self.bot_dodgevector;
	//if (self.bot_dodgevector_jumpbutton)
	//	self.BUTTON_JUMP = 1;
	self.movement_x = dir * v_forward * maxspeed;
	self.movement_y = dir * v_right * maxspeed;
	self.movement_z = dir * v_up * maxspeed;

	// Emulate keyboard interface
	if (skill < 10)
		havocbot_keyboard_movement(destorg);

	// Bunnyhop!
//	if(self.aistatus & AI_STATUS_ROAMING)
	if(self.goalcurrent)
	if(skill+self.bot_moveskill >= autocvar_bot_ai_bunnyhop_skilloffset)
		havocbot_bunnyhop(dir);

	if ((dir * v_up) >= autocvar_sv_jumpvelocity*0.5 && (self.flags & FL_ONGROUND)) self.BUTTON_JUMP=1;
	if (((dodge * v_up) > 0) && random()*frametime >= 0.2*bound(0,(10-skill-self.bot_dodgeskill)*0.1,1)) self.BUTTON_JUMP=TRUE;
	if (((dodge * v_up) < 0) && random()*frametime >= 0.5*bound(0,(10-skill-self.bot_dodgeskill)*0.1,1)) self.havocbot_ducktime=time+0.3/bound(0.1,skill+self.bot_dodgeskill,10);
}

void havocbot_chooseenemy()
{
	entity head, best, head2;
	float rating, bestrating, i, hf;
	vector eye, v;
	if (autocvar_bot_nofire || IS_INDEPENDENT_PLAYER(self))
	{
		self.enemy = world;
		return;
	}
	if (self.enemy)
	{
		if (!bot_shouldattack(self.enemy))
		{
			// enemy died or something, find a new target
			self.enemy = world;
			self.havocbot_chooseenemy_finished = time;
		}
		else if (self.havocbot_stickenemy)
		{
			// tracking last chosen enemy
			// if enemy is visible
			// and not really really far away
			// and we're not severely injured
			// then keep tracking for a half second into the future
			traceline(self.origin+self.view_ofs, ( self.enemy.absmin + self.enemy.absmax ) * 0.5,FALSE,world);
			if (trace_ent == self.enemy || trace_fraction == 1)
			if (vlen((( self.enemy.absmin + self.enemy.absmax ) * 0.5) - self.origin) < 1000)
			if (self.health > 30)
			{
				// remain tracking him for a shot while (case he went after a small corner or pilar
				self.havocbot_chooseenemy_finished = time + 0.5;
				return;
			}
			// enemy isn't visible, or is far away, or we're injured severely
			// so stop preferring this enemy
			// (it will still take a half second until a new one is chosen)
			self.havocbot_stickenemy = 0;
		}
	}
	if (time < self.havocbot_chooseenemy_finished)
		return;
	self.havocbot_chooseenemy_finished = time + autocvar_bot_ai_enemydetectioninterval;
	eye = self.origin + self.view_ofs;
	best = world;
	bestrating = 100000000;
	head = head2 = findchainfloat(bot_attack, TRUE);

	// Backup hit flags
	hf = self.dphitcontentsmask;

	// Search for enemies, if no enemy can be seen directly try to look through transparent objects

	self.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;

	for(i = 0; ; ++i)
	{
		while (head)
		{
			v = (head.absmin + head.absmax) * 0.5;
			rating = vlen(v - eye);
			if (rating<autocvar_bot_ai_enemydetectionradius)
			if (bestrating > rating)
			if (bot_shouldattack(head))
			{
				traceline(eye, v, TRUE, self);
				if (trace_ent == head || trace_fraction >= 1)
				{
					best = head;
					bestrating = rating;
				}
			}
			head = head.chain;
		}

		// I want to do a second scan if no enemy was found or I don't have weapons
		// TODO: Perform the scan when using the rifle (requires changes on the rifle code)
		if(best || !WEPSET_EMPTY_E(self)) // || self.weapon == WEP_RIFLE
			break;
		if(i)
			break;

		// Set flags to see through transparent objects
		self.dphitcontentsmask |= DPCONTENTS_OPAQUE;

		head = head2;
	}

	// Restore hit flags
	self.dphitcontentsmask = hf;

	self.enemy = best;
	self.havocbot_stickenemy = TRUE;
}

float havocbot_chooseweapon_checkreload(float new_weapon)
{
	// bots under this skill cannot find unloaded weapons to reload idly when not in combat,
	// so skip this for them, or they'll never get to reload their weapons at all.
	// this also allows bots under this skill to be more stupid, and reload more often during combat :)
	if(skill < 5)
		return FALSE;

	// if this weapon is scheduled for reloading, don't switch to it during combat
	if (self.weapon_load[new_weapon] < 0)
	{
		float i, other_weapon_available = FALSE;
		for(i = WEP_FIRST; i <= WEP_LAST; ++i)
		{
			// if we are out of ammo for all other weapons, it's an emergency to switch to anything else
			if (weapon_action(i, WR_CHECKAMMO1) + weapon_action(i, WR_CHECKAMMO2))
				other_weapon_available = TRUE;
		}
		if(other_weapon_available)
			return TRUE;
	}

	return FALSE;
}

void havocbot_chooseweapon()
{
	float i;

	// ;)
	if(WEPSET_EQ_AW(g_weaponarena_weapons, WEP_TUBA))
	{
		self.switchweapon = WEP_TUBA;
		return;
	}

	// TODO: clean this up by moving it to weapon code
	if(self.enemy==world)
	{
		// If no weapon was chosen get the first available weapon
		if(self.weapon==0)
		for(i=WEP_LASER + 1; i < WEP_COUNT ; ++i)
		{
			if(client_hasweapon(self, i, TRUE, FALSE))
			{
				self.switchweapon = i;
				return;
			}
		}
		return;
	}

	// Do not change weapon during the next second after a combo
	i = time - self.lastcombotime;
	if(i < 1)
		return;

	float w;
	float distance; distance=bound(10,vlen(self.origin-self.enemy.origin)-200,10000);

	// Should it do a weapon combo?
	float af, ct, combo_time, combo;

	af = ATTACK_FINISHED(self);
	ct = autocvar_bot_ai_weapon_combo_threshold;

	// Bots with no skill will be 4 times more slower than "godlike" bots when doing weapon combos
	// Ideally this 4 should be calculated as longest_weapon_refire / bot_ai_weapon_combo_threshold
	combo_time = time + ct + (ct * ((-0.3*(skill+self.bot_weaponskill))+3));

	combo = FALSE;

	if(autocvar_bot_ai_weapon_combo)
	if(self.weapon == self.lastfiredweapon)
	if(af > combo_time)
	{
		combo = TRUE;
		self.lastcombotime = time;
	}

	distance *= pow(2, self.bot_rangepreference);

	// Custom weapon list based on distance to the enemy
	if(bot_custom_weapon){

		// Choose weapons for far distance
		if ( distance > bot_distance_far ) {
			for(i=0; i < WEP_COUNT && bot_weapons_far[i] != -1 ; ++i){
				w = bot_weapons_far[i];
				if ( client_hasweapon(self, w, TRUE, FALSE) )
				{
					if ((self.weapon == w && combo) || havocbot_chooseweapon_checkreload(w))
						continue;
					self.switchweapon = w;
					return;
				}
			}
		}

		// Choose weapons for mid distance
		if ( distance > bot_distance_close) {
			for(i=0; i < WEP_COUNT && bot_weapons_mid[i] != -1 ; ++i){
				w = bot_weapons_mid[i];
				if ( client_hasweapon(self, w, TRUE, FALSE) )
				{
					if ((self.weapon == w && combo) || havocbot_chooseweapon_checkreload(w))
						continue;
					self.switchweapon = w;
					return;
				}
			}
		}

		// Choose weapons for close distance
		for(i=0; i < WEP_COUNT && bot_weapons_close[i] != -1 ; ++i){
			w = bot_weapons_close[i];
			if ( client_hasweapon(self, w, TRUE, FALSE) )
			{
				if ((self.weapon == w && combo) || havocbot_chooseweapon_checkreload(w))
					continue;
				self.switchweapon = w;
				return;
			}
		}
	}
}

void havocbot_aim()
{
	vector selfvel, enemyvel;
//	if(self.flags & FL_INWATER)
//		return;
	if (time < self.nextaim)
		return;
	self.nextaim = time + 0.1;
	selfvel = self.velocity;
	if (!self.waterlevel)
		selfvel_z = 0;
	if (self.enemy)
	{
		enemyvel = self.enemy.velocity;
		if (!self.enemy.waterlevel)
			enemyvel_z = 0;
		lag_additem(time + self.ping, 0, 0, self.enemy, self.origin, selfvel, (self.enemy.absmin + self.enemy.absmax) * 0.5, enemyvel);
	}
	else
		lag_additem(time + self.ping, 0, 0, world, self.origin, selfvel, ( self.goalcurrent.absmin + self.goalcurrent.absmax ) * 0.5, '0 0 0');
}

float havocbot_moveto_refresh_route()
{
	// Refresh path to goal if necessary
	entity wp;
	wp = self.havocbot_personal_waypoint;
	navigation_goalrating_start();
	navigation_routerating(wp, 10000, 10000);
	navigation_goalrating_end();
	return self.navigation_hasgoals;
}

float havocbot_moveto(vector pos)
{
	entity wp;

	if(self.aistatus & AI_STATUS_WAYPOINT_PERSONAL_GOING)
	{
		// Step 4: Move to waypoint
		if(self.havocbot_personal_waypoint==world)
		{
			dprint("Error: ", self.netname, " trying to walk to a non existent personal waypoint\n");
			self.aistatus &~= AI_STATUS_WAYPOINT_PERSONAL_GOING;
			return CMD_STATUS_ERROR;
		}

		if (!bot_strategytoken_taken)
		if(self.havocbot_personal_waypoint_searchtime<time)
		{
			bot_strategytoken_taken = TRUE;
			if(havocbot_moveto_refresh_route())
			{
				dprint(self.netname, " walking to its personal waypoint (after ", ftos(self.havocbot_personal_waypoint_failcounter), " failed attempts)\n");
				self.havocbot_personal_waypoint_searchtime = time + 10;
				self.havocbot_personal_waypoint_failcounter = 0;
			}
			else
			{
				self.havocbot_personal_waypoint_failcounter += 1;
				self.havocbot_personal_waypoint_searchtime = time + 2;
				if(self.havocbot_personal_waypoint_failcounter >= 30)
				{
					dprint("Warning: can't walk to the personal waypoint located at ", vtos(self.havocbot_personal_waypoint.origin),"\n");
					self.aistatus &~= AI_STATUS_WAYPOINT_PERSONAL_LINKING;
					remove(self.havocbot_personal_waypoint);
					return CMD_STATUS_ERROR;
				}
				else
					dprint(self.netname, " can't walk to its personal waypoint (after ", ftos(self.havocbot_personal_waypoint_failcounter), " failed attempts), trying later\n");
			}
		}

		if(autocvar_bot_debug_goalstack)
			debuggoalstack();

		// Heading
		vector dir = ( ( self.goalcurrent.absmin + self.goalcurrent.absmax ) * 0.5 ) - (self.origin + self.view_ofs);
		dir_z = 0;
		bot_aimdir(dir, -1);

		// Go!
		havocbot_movetogoal();

		if(self.aistatus & AI_STATUS_WAYPOINT_PERSONAL_REACHED)
		{
			// Step 5: Waypoint reached
			dprint(self.netname, "'s personal waypoint reached\n");
			remove(self.havocbot_personal_waypoint);
			self.aistatus &~= AI_STATUS_WAYPOINT_PERSONAL_REACHED;
			return CMD_STATUS_FINISHED;
		}

		return CMD_STATUS_EXECUTING;
	}

	// Step 2: Linking waypoint
	if(self.aistatus & AI_STATUS_WAYPOINT_PERSONAL_LINKING)
	{
		// Wait until it is linked
		if(!self.havocbot_personal_waypoint.wplinked)
		{
			dprint(self.netname, " waiting for personal waypoint to be linked\n");
			return CMD_STATUS_EXECUTING;
		}

		self.havocbot_personal_waypoint_searchtime = time; // so we set the route next frame
		self.aistatus &~= AI_STATUS_WAYPOINT_PERSONAL_LINKING;
		self.aistatus |= AI_STATUS_WAYPOINT_PERSONAL_GOING;

		// Step 3: Route to waypoint
		dprint(self.netname, " walking to its personal waypoint\n");

		return CMD_STATUS_EXECUTING;
	}

	// Step 1: Spawning waypoint
	wp = waypoint_spawnpersonal(pos);
	if(wp==world)
	{
		dprint("Error: Can't spawn personal waypoint at ",vtos(pos),"\n");
		return CMD_STATUS_ERROR;
	}

	self.havocbot_personal_waypoint = wp;
	self.havocbot_personal_waypoint_failcounter = 0;
	self.aistatus |= AI_STATUS_WAYPOINT_PERSONAL_LINKING;

	// if pos is inside a teleport, then let's mark it as teleport waypoint
	entity head;
	for(head = world; (head = find(head, classname, "trigger_teleport")); )
	{
		if(WarpZoneLib_BoxTouchesBrush(pos, pos, head, world))
		{
			wp.wpflags |= WAYPOINTFLAG_TELEPORT;
			self.lastteleporttime = 0;
		}
	}

/*
	if(wp.wpflags & WAYPOINTFLAG_TELEPORT)
		print("routing to a teleporter\n");
	else
		print("routing to a non-teleporter\n");
*/

	return CMD_STATUS_EXECUTING;
}

float havocbot_resetgoal()
{
	navigation_clearroute();
	return CMD_STATUS_FINISHED;
}

void havocbot_setupbot()
{
	self.bot_ai = havocbot_ai;
	self.cmd_moveto = havocbot_moveto;
	self.cmd_resetgoal = havocbot_resetgoal;

	havocbot_chooserole();
}

vector havocbot_dodge()
{
	// LordHavoc: disabled because this is too expensive
	return '0 0 0';
#if 0
	entity head;
	vector dodge, v, n;
	float danger, bestdanger, vl, d;
	dodge = '0 0 0';
	bestdanger = -20;
	// check for dangerous objects near bot or approaching bot
	head = findchainfloat(bot_dodge, TRUE);
	while(head)
	{
		if (head.owner != self)
		{
			vl = vlen(head.velocity);
			if (vl > autocvar_sv_maxspeed * 0.3)
			{
				n = normalize(head.velocity);
				v = self.origin - head.origin;
				d = v * n;
				if (d > (0 - head.bot_dodgerating))
				if (d < (vl * 0.2 + head.bot_dodgerating))
				{
					// calculate direction and distance from the flight path, by removing the forward axis
					v = v - (n * (v * n));
					danger = head.bot_dodgerating - vlen(v);
					if (bestdanger < danger)
					{
						bestdanger = danger;
						// dodge to the side of the object
						dodge = normalize(v);
					}
				}
			}
			else
			{
				danger = head.bot_dodgerating - vlen(head.origin - self.origin);
				if (bestdanger < danger)
				{
					bestdanger = danger;
					dodge = normalize(self.origin - head.origin);
				}
			}
		}
		head = head.chain;
	}
	return dodge;
#endif
}
