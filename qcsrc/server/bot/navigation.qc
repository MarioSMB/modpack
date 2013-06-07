void bot_debug(string input)
{
	switch(autocvar_bot_debug)
	{
		case 1: dprint(input); break;
		case 2: print(input); break;
	}
}

// rough simulation of walking from one point to another to test if a path
// can be traveled, used for waypoint linking and havocbot

float tracewalk(entity e, vector start, vector m1, vector m2, vector end, float movemode)
{
	vector org;
	vector move;
	vector dir;
	float dist;
	float totaldist;
	float stepdist;
	float yaw;
	float ignorehazards;
	float swimming;

	if(autocvar_bot_debug_tracewalk)
	{
		debugresetnodes();
		debugnode(start);
	}

	move = end - start;
	move_z = 0;
	org = start;
	dist = totaldist = vlen(move);
	dir = normalize(move);
	stepdist = 32;
	ignorehazards = FALSE;
	swimming = FALSE;

	// Analyze starting point
	traceline(start, start, MOVE_NORMAL, e);
	if (trace_dpstartcontents & (DPCONTENTS_SLIME | DPCONTENTS_LAVA))
		ignorehazards = TRUE;
	else
	{
		traceline( start, start + '0 0 -65536', MOVE_NORMAL, e);
		if (trace_dpstartcontents & (DPCONTENTS_SLIME | DPCONTENTS_LAVA))
		{
			ignorehazards = TRUE;
			swimming = TRUE;
		}
	}
	tracebox(start, m1, m2, start, MOVE_NOMONSTERS, e);
	if (trace_startsolid)
	{
		// Bad start
		if(autocvar_bot_debug_tracewalk)
			debugnodestatus(start, DEBUG_NODE_FAIL);

		//print("tracewalk: ", vtos(start), " is a bad start\n");
		return FALSE;
	}

	// Movement loop
	yaw = vectoyaw(move);
	move = end - org;
	for (;;)
	{
		if (boxesoverlap(end, end, org + m1 + '-1 -1 -1', org + m2 + '1 1 1'))
		{
			// Succeeded
			if(autocvar_bot_debug_tracewalk)
				debugnodestatus(org, DEBUG_NODE_SUCCESS);

			//print("tracewalk: ", vtos(start), " can reach ", vtos(end), "\n");
			return TRUE;
		}
		if(autocvar_bot_debug_tracewalk)
			debugnode(org);

		if (dist <= 0)
			break;
		if (stepdist > dist)
			stepdist = dist;
		dist = dist - stepdist;
		traceline(org, org, MOVE_NORMAL, e);
		if (!ignorehazards)
		{
			if (trace_dpstartcontents & (DPCONTENTS_SLIME | DPCONTENTS_LAVA))
			{
				// hazards blocking path
				if(autocvar_bot_debug_tracewalk)
					debugnodestatus(org, DEBUG_NODE_FAIL);

				//print("tracewalk: ", vtos(start), " hits a hazard when trying to reach ", vtos(end), "\n");
				return FALSE;
			}
		}
		if (trace_dpstartcontents & DPCONTENTS_LIQUIDSMASK)
		{
			move = normalize(end - org);
			tracebox(org, m1, m2, org + move * stepdist, movemode, e);

			if(autocvar_bot_debug_tracewalk)
				debugnode(trace_endpos);

			if (trace_fraction < 1)
			{
				swimming = TRUE;
				org = trace_endpos - normalize(org - trace_endpos) * stepdist;
				for(; org_z < end_z + self.maxs_z; org_z += stepdist)
				{
						if(autocvar_bot_debug_tracewalk)
							debugnode(org);

				        if(pointcontents(org) == CONTENT_EMPTY)
							break;
				}

				if not (pointcontents(org + '0 0 1') == CONTENT_EMPTY)
				{
					if(autocvar_bot_debug_tracewalk)
						debugnodestatus(org, DEBUG_NODE_FAIL);

					return FALSE;
					//print("tracewalk: ", vtos(start), " failed under water\n");
				}
				continue;

			}
			else
				org = trace_endpos;
		}
		else
		{
			move = dir * stepdist + org;
			tracebox(org, m1, m2, move, movemode, e);

			if(autocvar_bot_debug_tracewalk)
				debugnode(trace_endpos);

			// hit something
			if (trace_fraction < 1)
			{
				// check if we can walk over this obstacle, possibly by jumpstepping
				tracebox(org + stepheightvec, m1, m2, move + stepheightvec, movemode, e);
				if (trace_fraction < 1 || trace_startsolid)
				{
					tracebox(org + jumpstepheightvec, m1, m2, move + jumpstepheightvec, movemode, e);
					if (trace_fraction < 1 || trace_startsolid)
					{
						if(autocvar_bot_debug_tracewalk)
							debugnodestatus(trace_endpos, DEBUG_NODE_WARNING);

						// check for doors
						traceline( org, move, movemode, e);
						if ( trace_ent.classname == "door_rotating" || trace_ent.classname == "door")
						{
							vector nextmove;
							move = trace_endpos;
							while(trace_ent.classname == "door_rotating" || trace_ent.classname == "door")
							{
								nextmove = move + (dir * stepdist);
								traceline( move, nextmove, movemode, e);
								move = nextmove;
							}
						}
						else
						{
							if(autocvar_bot_debug_tracewalk)
								debugnodestatus(trace_endpos, DEBUG_NODE_FAIL);

							//print("tracewalk: ", vtos(start), " hit something when trying to reach ", vtos(end), "\n");
							//te_explosion(trace_endpos);
							//print(ftos(e.dphitcontentsmask), "\n");
							return FALSE; // failed
						}
					}
					else
						move = trace_endpos;
				}
				else
					move = trace_endpos;
			}
			else
				move = trace_endpos;

			// trace down from stepheight as far as possible and move there,
			// if this starts in solid we try again without the stepup, and
			// if that also fails we assume it is a wall
			// (this is the same logic as the Quake walkmove function used)
			tracebox(move, m1, m2, move + '0 0 -65536', movemode, e);

			// moved successfully
			if(swimming)
			{
				float c;
				c = pointcontents(org + '0 0 1');
				if not(c == CONTENT_WATER || c == CONTENT_LAVA || c == CONTENT_SLIME)
					swimming = FALSE;
				else
					continue;
			}

			org = trace_endpos;
		}
	}

	//print("tracewalk: ", vtos(start), " did not arrive at ", vtos(end), " but at ", vtos(org), "\n");

	// moved but didn't arrive at the intended destination
	if(autocvar_bot_debug_tracewalk)
		debugnodestatus(org, DEBUG_NODE_FAIL);

	return FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// goal stack
/////////////////////////////////////////////////////////////////////////////

// completely empty the goal stack, used when deciding where to go
void navigation_clearroute()
{
	//print("bot ", etos(self), " clear\n");
	self.navigation_hasgoals = FALSE;
	self.goalcurrent = world;
	self.goalstack01 = world;
	self.goalstack02 = world;
	self.goalstack03 = world;
	self.goalstack04 = world;
	self.goalstack05 = world;
	self.goalstack06 = world;
	self.goalstack07 = world;
	self.goalstack08 = world;
	self.goalstack09 = world;
	self.goalstack10 = world;
	self.goalstack11 = world;
	self.goalstack12 = world;
	self.goalstack13 = world;
	self.goalstack14 = world;
	self.goalstack15 = world;
	self.goalstack16 = world;
	self.goalstack17 = world;
	self.goalstack18 = world;
	self.goalstack19 = world;
	self.goalstack20 = world;
	self.goalstack21 = world;
	self.goalstack22 = world;
	self.goalstack23 = world;
	self.goalstack24 = world;
	self.goalstack25 = world;
	self.goalstack26 = world;
	self.goalstack27 = world;
	self.goalstack28 = world;
	self.goalstack29 = world;
	self.goalstack30 = world;
	self.goalstack31 = world;
}

// add a new goal at the beginning of the stack
// (in other words: add a new prerequisite before going to the later goals)
// NOTE: when a waypoint is added, the WP gets pushed first, then the
// next-closest WP on the shortest path to the WP
// That means, if the stack overflows, the bot will know how to do the FIRST 32
// steps to the goal, and then recalculate the path.
void navigation_pushroute(entity e)
{
	//print("bot ", etos(self), " push ", etos(e), "\n");
	self.goalstack31 = self.goalstack30;
	self.goalstack30 = self.goalstack29;
	self.goalstack29 = self.goalstack28;
	self.goalstack28 = self.goalstack27;
	self.goalstack27 = self.goalstack26;
	self.goalstack26 = self.goalstack25;
	self.goalstack25 = self.goalstack24;
	self.goalstack24 = self.goalstack23;
	self.goalstack23 = self.goalstack22;
	self.goalstack22 = self.goalstack21;
	self.goalstack21 = self.goalstack20;
	self.goalstack20 = self.goalstack19;
	self.goalstack19 = self.goalstack18;
	self.goalstack18 = self.goalstack17;
	self.goalstack17 = self.goalstack16;
	self.goalstack16 = self.goalstack15;
	self.goalstack15 = self.goalstack14;
	self.goalstack14 = self.goalstack13;
	self.goalstack13 = self.goalstack12;
	self.goalstack12 = self.goalstack11;
	self.goalstack11 = self.goalstack10;
	self.goalstack10 = self.goalstack09;
	self.goalstack09 = self.goalstack08;
	self.goalstack08 = self.goalstack07;
	self.goalstack07 = self.goalstack06;
	self.goalstack06 = self.goalstack05;
	self.goalstack05 = self.goalstack04;
	self.goalstack04 = self.goalstack03;
	self.goalstack03 = self.goalstack02;
	self.goalstack02 = self.goalstack01;
	self.goalstack01 = self.goalcurrent;
	self.goalcurrent = e;
}

// remove first goal from stack
// (in other words: remove a prerequisite for reaching the later goals)
// (used when a spawnfunc_waypoint is reached)
void navigation_poproute()
{
	//print("bot ", etos(self), " pop\n");
	self.goalcurrent = self.goalstack01;
	self.goalstack01 = self.goalstack02;
	self.goalstack02 = self.goalstack03;
	self.goalstack03 = self.goalstack04;
	self.goalstack04 = self.goalstack05;
	self.goalstack05 = self.goalstack06;
	self.goalstack06 = self.goalstack07;
	self.goalstack07 = self.goalstack08;
	self.goalstack08 = self.goalstack09;
	self.goalstack09 = self.goalstack10;
	self.goalstack10 = self.goalstack11;
	self.goalstack11 = self.goalstack12;
	self.goalstack12 = self.goalstack13;
	self.goalstack13 = self.goalstack14;
	self.goalstack14 = self.goalstack15;
	self.goalstack15 = self.goalstack16;
	self.goalstack16 = self.goalstack17;
	self.goalstack17 = self.goalstack18;
	self.goalstack18 = self.goalstack19;
	self.goalstack19 = self.goalstack20;
	self.goalstack20 = self.goalstack21;
	self.goalstack21 = self.goalstack22;
	self.goalstack22 = self.goalstack23;
	self.goalstack23 = self.goalstack24;
	self.goalstack24 = self.goalstack25;
	self.goalstack25 = self.goalstack26;
	self.goalstack26 = self.goalstack27;
	self.goalstack27 = self.goalstack28;
	self.goalstack28 = self.goalstack29;
	self.goalstack29 = self.goalstack30;
	self.goalstack30 = self.goalstack31;
	self.goalstack31 = world;
}

float navigation_waypoint_will_link(vector v, vector org, entity ent, float walkfromwp, float bestdist)
{
	float dist;
	dist = vlen(v - org);
	if (bestdist > dist)
	{
		traceline(v, org, TRUE, ent);
		if (trace_fraction == 1)
		{
			if (walkfromwp)
			{
				if (tracewalk(ent, v, PL_MIN, PL_MAX, org, bot_navigation_movemode))
					return TRUE;
			}
			else
			{
				if (tracewalk(ent, org, PL_MIN, PL_MAX, v, bot_navigation_movemode))
					return TRUE;
			}
		}
	}
	return FALSE;
}

// find the spawnfunc_waypoint near a dynamic goal such as a dropped weapon
entity navigation_findnearestwaypoint_withdist(entity ent, float walkfromwp, float bestdist)
{
	entity waylist, w, best;
	vector v, org, pm1, pm2;

	pm1 = ent.origin + ent.mins;
	pm2 = ent.origin + ent.maxs;
	waylist = findchain(classname, "waypoint");

	// do two scans, because box test is cheaper
	w = waylist;
	while (w)
	{
		// if object is touching spawnfunc_waypoint
		if(w != ent)
			if (boxesoverlap(pm1, pm2, w.absmin, w.absmax))
				return w;
		w = w.chain;
	}

	org = ent.origin + 0.5 * (ent.mins + ent.maxs);
	org_z = ent.origin_z + ent.mins_z - PL_MIN_z; // player height
	// TODO possibly make other code have the same support for bboxes
	if(ent.tag_entity)
		org = org + ent.tag_entity.origin;
	if (navigation_testtracewalk)
		te_plasmaburn(org);

	best = world;

	// box check failed, try walk
	w = waylist;
	while (w)
	{
		// if object can walk from spawnfunc_waypoint
		if(w != ent)
		{
			if (w.wpisbox)
			{
				vector wm1, wm2;
				wm1 = w.origin + w.mins;
				wm2 = w.origin + w.maxs;
				v_x = bound(wm1_x, org_x, wm2_x);
				v_y = bound(wm1_y, org_y, wm2_y);
				v_z = bound(wm1_z, org_z, wm2_z);
			}
			else
				v = w.origin;
			if(navigation_waypoint_will_link(v, org, ent, walkfromwp, bestdist))
			{
				bestdist = vlen(v - org);
				best = w;
			}
		}
		w = w.chain;
	}
	return best;
}
entity navigation_findnearestwaypoint(entity ent, float walkfromwp)
{
	return navigation_findnearestwaypoint_withdist(ent, walkfromwp, 1050);
}

// finds the waypoints near the bot initiating a navigation query
float navigation_markroutes_nearestwaypoints(entity waylist, float maxdist)
{
	entity head;
	vector v, m1, m2, diff;
	float c;
//	navigation_testtracewalk = TRUE;
	c = 0;
	head = waylist;
	while (head)
	{
		if (!head.wpconsidered)
		{
			if (head.wpisbox)
			{
				m1 = head.origin + head.mins;
				m2 = head.origin + head.maxs;
				v = self.origin;
				v_x = bound(m1_x, v_x, m2_x);
				v_y = bound(m1_y, v_y, m2_y);
				v_z = bound(m1_z, v_z, m2_z);
			}
			else
				v = head.origin;
			diff = v - self.origin;
			diff_z = max(0, diff_z);
			if (vlen(diff) < maxdist)
			{
				head.wpconsidered = TRUE;
				if (tracewalk(self, self.origin, self.mins, self.maxs, v, bot_navigation_movemode))
				{
					head.wpnearestpoint = v;
					head.wpcost = vlen(v - self.origin) + head.dmg;
					head.wpfire = 1;
					head.enemy = world;
					c = c + 1;
				}
			}
		}
		head = head.chain;
	}
	//navigation_testtracewalk = FALSE;
	return c;
}

// updates a path link if a spawnfunc_waypoint link is better than the current one
void navigation_markroutes_checkwaypoint(entity w, entity wp, float cost2, vector p)
{
	vector m1;
	vector m2;
	vector v;
	if (wp.wpisbox)
	{
		m1 = wp.absmin;
		m2 = wp.absmax;
		v_x = bound(m1_x, p_x, m2_x);
		v_y = bound(m1_y, p_y, m2_y);
		v_z = bound(m1_z, p_z, m2_z);
	}
	else
		v = wp.origin;
	cost2 = cost2 + vlen(v - p);
	if (wp.wpcost > cost2)
	{
		wp.wpcost = cost2;
		wp.enemy = w;
		wp.wpfire = 1;
		wp.wpnearestpoint = v;
	}
}

// queries the entire spawnfunc_waypoint network for pathes leading away from the bot
void navigation_markroutes(entity fixed_source_waypoint)
{
	entity w, wp, waylist;
	float searching, cost, cost2;
	vector p;
	w = waylist = findchain(classname, "waypoint");
	while (w)
	{
		w.wpconsidered = FALSE;
		w.wpnearestpoint = '0 0 0';
		w.wpcost = 10000000;
		w.wpfire = 0;
		w.enemy = world;
		w = w.chain;
	}

	if(fixed_source_waypoint)
	{
		fixed_source_waypoint.wpconsidered = TRUE;
		fixed_source_waypoint.wpnearestpoint = fixed_source_waypoint.origin + 0.5 * (fixed_source_waypoint.mins + fixed_source_waypoint.maxs);
		fixed_source_waypoint.wpcost = fixed_source_waypoint.dmg;
		fixed_source_waypoint.wpfire = 1;
		fixed_source_waypoint.enemy = world;
	}
	else
	{
		// try a short range search for the nearest waypoints, and expand the search repeatedly if none are found
		// as this search is expensive we will use lower values if the bot is on the air
		float i, increment, maxdistance;
		if(self.flags & FL_ONGROUND)
		{
			increment = 750;
			maxdistance = 50000;
		}
		else
		{
			increment = 500;
			maxdistance = 1500;
		}

		for(i=increment;!navigation_markroutes_nearestwaypoints(waylist, i)&&i<maxdistance;i+=increment);
	}

	searching = TRUE;
	while (searching)
	{
		searching = FALSE;
		w = waylist;
		while (w)
		{
			if (w.wpfire)
			{
				searching = TRUE;
				w.wpfire = 0;
				cost = w.wpcost;
				p = w.wpnearestpoint;
				wp = w.wp00;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp00mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp01;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp01mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp02;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp02mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp03;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp03mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp04;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp04mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp05;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp05mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp06;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp06mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp07;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp07mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp08;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp08mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp09;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp09mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp10;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp10mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp11;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp11mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp12;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp12mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp13;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp13mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp14;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp14mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp15;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp15mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp16;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp16mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp17;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp17mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp18;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp18mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp19;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp19mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp20;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp20mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp21;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp21mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp22;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp22mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp23;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp23mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp24;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp24mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp25;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp25mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp26;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp26mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp27;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp27mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp28;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp28mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp29;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp29mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp30;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp30mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp31;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp31mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
			}
			w = w.chain;
		}
	}
}

// queries the entire spawnfunc_waypoint network for pathes leading to the bot
void navigation_markroutes_inverted(entity fixed_source_waypoint)
{
	entity w, wp, waylist;
	float searching, cost, cost2;
	vector p;
	w = waylist = findchain(classname, "waypoint");
	while (w)
	{
		w.wpconsidered = FALSE;
		w.wpnearestpoint = '0 0 0';
		w.wpcost = 10000000;
		w.wpfire = 0;
		w.enemy = world;
		w = w.chain;
	}

	if(fixed_source_waypoint)
	{
		fixed_source_waypoint.wpconsidered = TRUE;
		fixed_source_waypoint.wpnearestpoint = fixed_source_waypoint.origin + 0.5 * (fixed_source_waypoint.mins + fixed_source_waypoint.maxs);
		fixed_source_waypoint.wpcost = fixed_source_waypoint.dmg; // the cost to get from X to fixed_source_waypoint
		fixed_source_waypoint.wpfire = 1;
		fixed_source_waypoint.enemy = world;
	}
	else
	{
		error("need to start with a waypoint\n");
	}

	searching = TRUE;
	while (searching)
	{
		searching = FALSE;
		w = waylist;
		while (w)
		{
			if (w.wpfire)
			{
				searching = TRUE;
				w.wpfire = 0;
				cost = w.wpcost; // cost to walk from w to home
				p = w.wpnearestpoint;
				for(wp = waylist; wp; wp = wp.chain)
				{
					if(w != wp.wp00) if(w != wp.wp01) if(w != wp.wp02) if(w != wp.wp03)
					if(w != wp.wp04) if(w != wp.wp05) if(w != wp.wp06) if(w != wp.wp07)
					if(w != wp.wp08) if(w != wp.wp09) if(w != wp.wp10) if(w != wp.wp11)
					if(w != wp.wp12) if(w != wp.wp13) if(w != wp.wp14) if(w != wp.wp15)
					if(w != wp.wp16) if(w != wp.wp17) if(w != wp.wp18) if(w != wp.wp19)
					if(w != wp.wp20) if(w != wp.wp21) if(w != wp.wp22) if(w != wp.wp23)
					if(w != wp.wp24) if(w != wp.wp25) if(w != wp.wp26) if(w != wp.wp27)
					if(w != wp.wp28) if(w != wp.wp29) if(w != wp.wp30) if(w != wp.wp31)
						continue;
					cost2 = cost + wp.dmg;
					navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				}
			}
			w = w.chain;
		}
	}
}

// updates the best goal according to a weighted calculation of travel cost and item value of a new proposed item
void navigation_routerating(entity e, float f, float rangebias)
{
	entity nwp;
	vector o;
	if (!e)
		return;

	if(e.blacklisted)
		return;

	o = (e.absmin + e.absmax) * 0.5;

	//print("routerating ", etos(e), " = ", ftos(f), " - ", ftos(rangebias), "\n");

	// Evaluate path using jetpack
	if(g_jetpack)
	if(self.items & IT_JETPACK)
	if(autocvar_bot_ai_navigation_jetpack)
	if(vlen(self.origin - o) > autocvar_bot_ai_navigation_jetpack_mindistance)
	{
		vector pointa, pointb;

		bot_debug(strcat("jetpack ai: evaluating path for ", e.classname, "\n"));

		// Point A
		traceline(self.origin, self.origin + '0 0 65535', MOVE_NORMAL, self);
		pointa = trace_endpos - '0 0 1';

		// Point B
		traceline(o, o + '0 0 65535', MOVE_NORMAL, e);
		pointb = trace_endpos - '0 0 1';

		// Can I see these two points from the sky?
		traceline(pointa, pointb, MOVE_NORMAL, self);

		if(trace_fraction==1)
		{
			bot_debug("jetpack ai: can bridge these two points\n");

			// Lower the altitude of these points as much as possible
			float zdistance, xydistance, cost, t, fuel;
			vector down, npa, npb;

			down = '0 0 -1' * (PL_MAX_z - PL_MIN_z) * 10;

			do{
				npa = pointa + down;
				npb = pointb + down;

				if(npa_z<=self.absmax_z)
					break;

				if(npb_z<=e.absmax_z)
					break;

				traceline(npa, npb, MOVE_NORMAL, self);
				if(trace_fraction==1)
				{
					pointa = npa;
					pointb = npb;
				}
			}
			while(trace_fraction == 1);


			// Rough estimation of fuel consumption
			// (ignores acceleration and current xyz velocity)
			xydistance = vlen(pointa - pointb);
			zdistance = fabs(pointa_z - self.origin_z);

			t = zdistance / autocvar_g_jetpack_maxspeed_up;
			t += xydistance / autocvar_g_jetpack_maxspeed_side;
			fuel = t * autocvar_g_jetpack_fuel * 0.8;
			
			bot_debug(strcat("jetpack ai: required fuel ", ftos(fuel), " self.ammo_fuel ", ftos(self.ammo_fuel), "\n"));

			// enough fuel ?
			if(self.ammo_fuel>fuel)
			{
				// Estimate cost
				// (as onground costs calculation is mostly based on distances, here we do the same establishing some relationship
				//  - between air and ground speeds)

				cost = xydistance / (autocvar_g_jetpack_maxspeed_side/autocvar_sv_maxspeed);
				cost += zdistance / (autocvar_g_jetpack_maxspeed_up/autocvar_sv_maxspeed);
				cost *= 1.5;

				// Compare against other goals
				f = f * rangebias / (rangebias + cost);

				if (navigation_bestrating < f)
				{
					bot_debug(strcat("jetpack path: added goal ", e.classname, " (with rating ", ftos(f), ")\n"));
					navigation_bestrating = f;
					navigation_bestgoal = e;
					self.navigation_jetpack_goal = e;
					self.navigation_jetpack_point = pointb;
				}
				return;
			}
		}
	}

	//te_wizspike(e.origin);
	//bprint(etos(e));
	//bprint("\n");
	// update the cached spawnfunc_waypoint link on a dynamic item entity
	if(e.classname == "waypoint" && !(e.wpflags & WAYPOINTFLAG_PERSONAL))
	{
		nwp = e;
	}
	else
	{
		float search;

		search = TRUE;

		if(e.flags & FL_ITEM)
		{
			if not(e.flags & FL_WEAPON)
			if(e.nearestwaypoint)
				search = FALSE;
		}
		else if (e.flags & FL_WEAPON)
		{
			if(e.classname != "droppedweapon")
			if(e.nearestwaypoint)
				search = FALSE;
		}

		if(search)
		if (time > e.nearestwaypointtimeout)
		{
			nwp = navigation_findnearestwaypoint(e, TRUE);
			if(nwp)
				e.nearestwaypoint = nwp;
			else
			{
				bot_debug(strcat("FAILED to find a nearest waypoint to '", e.classname, "' #", etos(e), "\n"));

				if(e.flags & FL_ITEM)
					e.blacklisted = TRUE;
				else if (e.flags & FL_WEAPON)
				{
					if(e.classname != "droppedweapon")
						e.blacklisted = TRUE;
				}

				if(e.blacklisted)
				{
					bot_debug(strcat("The entity '", e.classname, "' is going to be excluded from path finding during this match\n"));
					return;
				}
			}

			// TODO: Cleaner solution, probably handling this timeout from ctf.qc
			if(e.classname=="item_flag_team")
				e.nearestwaypointtimeout = time + 2;
			else
				e.nearestwaypointtimeout = time + random() * 3 + 5;
		}
		nwp = e.nearestwaypoint;
	}

	bot_debug(strcat("-- checking ", e.classname, " (with cost ", ftos(nwp.wpcost), ")\n"));
	if (nwp)
	if (nwp.wpcost < 10000000)
	{
		//te_wizspike(nwp.wpnearestpoint);
		bot_debug(strcat(e.classname, " ", ftos(f), "/(1+", ftos((nwp.wpcost + vlen(e.origin - nwp.wpnearestpoint))), "/", ftos(rangebias), ") = "));
		f = f * rangebias / (rangebias + (nwp.wpcost + vlen(o - nwp.wpnearestpoint)));
		bot_debug(strcat("considering ", e.classname, " (with rating ", ftos(f), ")\n"));
		if (navigation_bestrating < f)
		{
			bot_debug(strcat("ground path: added goal ", e.classname, " (with rating ", ftos(f), ")\n"));
			navigation_bestrating = f;
			navigation_bestgoal = e;
		}
	}
}

// adds an item to the the goal stack with the path to a given item
float navigation_routetogoal(entity e, vector startposition)
{
	self.goalentity = e;

	// if there is no goal, just exit
	if (!e)
		return FALSE;

	self.navigation_hasgoals = TRUE;

	// put the entity on the goal stack
	//print("routetogoal ", etos(e), "\n");
	navigation_pushroute(e);

	if(g_jetpack)
	if(e==self.navigation_jetpack_goal)
		return TRUE;

	// if it can reach the goal there is nothing more to do
	if (tracewalk(self, startposition, PL_MIN, PL_MAX, (e.absmin + e.absmax) * 0.5, bot_navigation_movemode))
		return TRUE;

	// see if there are waypoints describing a path to the item
	if(e.classname != "waypoint" || (e.wpflags & WAYPOINTFLAG_PERSONAL))
		e = e.nearestwaypoint;
	else
		e = e.enemy; // we already have added it, so...

	if(e == world)
		return FALSE;

	for (;;)
	{
		// add the spawnfunc_waypoint to the path
		navigation_pushroute(e);
		e = e.enemy;

		if(e==world)
			break;
	}

	return FALSE;
}

// removes any currently touching waypoints from the goal stack
// (this is how bots detect if they reached a goal)
void navigation_poptouchedgoals()
{
	vector org, m1, m2;
	org = self.origin;
	m1 = org + self.mins;
	m2 = org + self.maxs;

	if(self.goalcurrent.wpflags & WAYPOINTFLAG_TELEPORT)
	{
		if(self.lastteleporttime>0)
		if(time-self.lastteleporttime<(self.goalcurrent.wpflags & WAYPOINTFLAG_PERSONAL)?2:0.15)
		{
			if(self.aistatus & AI_STATUS_WAYPOINT_PERSONAL_GOING)
			if(self.goalcurrent.wpflags & WAYPOINTFLAG_PERSONAL && self.goalcurrent.owner==self)
			{
				self.aistatus &~= AI_STATUS_WAYPOINT_PERSONAL_GOING;
				self.aistatus |= AI_STATUS_WAYPOINT_PERSONAL_REACHED;
			}
			navigation_poproute();
			return;
		}
	}

	// If for some reason the bot is closer to the next goal, pop the current one
	if(self.goalstack01)
	if(vlen(self.goalcurrent.origin - self.origin) > vlen(self.goalstack01.origin - self.origin))
	if(checkpvs(self.origin + self.view_ofs, self.goalstack01))
	if(tracewalk(self, self.origin, self.mins, self.maxs, (self.goalstack01.absmin + self.goalstack01.absmax) * 0.5, bot_navigation_movemode))
	{
		bot_debug(strcat("path optimized for ", self.netname, ", removed a goal from the queue\n"));
		navigation_poproute();
		// TODO this may also be a nice idea to do "early" (e.g. by
		// manipulating the vlen() comparisons) to shorten paths in
		// general - this would make bots walk more "on rails" than
		// "zigzagging" which they currently do with sufficiently
		// random-like waypoints, and thus can make a nice bot
		// personality property
	}

	// HACK: remove players/bots as goals, they can lead a bot to unexpected places (cliffs, lava, etc)
	// TODO: rate waypoints near the targetted player at that moment, instead of the player itself
	if(IS_PLAYER(self.goalcurrent))
		navigation_poproute();

	// aid for detecting jump pads better (distance based check fails sometimes)
	if(self.goalcurrent.wpflags & WAYPOINTFLAG_TELEPORT && self.jumppadcount > 0 )
		navigation_poproute();

	// Loose goal touching check when running
	if(self.aistatus & AI_STATUS_RUNNING)
	if(self.speed >= autocvar_sv_maxspeed) // if -really- running
	if(self.goalcurrent.classname=="waypoint")
	{
		if(vlen(self.origin - self.goalcurrent.origin)<150)
		{
			traceline(self.origin + self.view_ofs , self.goalcurrent.origin, TRUE, world);
			if(trace_fraction==1)
			{
				// Detect personal waypoints
				if(self.aistatus & AI_STATUS_WAYPOINT_PERSONAL_GOING)
				if(self.goalcurrent.wpflags & WAYPOINTFLAG_PERSONAL && self.goalcurrent.owner==self)
				{
					self.aistatus &~= AI_STATUS_WAYPOINT_PERSONAL_GOING;
					self.aistatus |= AI_STATUS_WAYPOINT_PERSONAL_REACHED;
				}

				navigation_poproute();
			}
		}
	}

	while (self.goalcurrent && boxesoverlap(m1, m2, self.goalcurrent.absmin, self.goalcurrent.absmax))
	{
		// Detect personal waypoints
		if(self.aistatus & AI_STATUS_WAYPOINT_PERSONAL_GOING)
		if(self.goalcurrent.wpflags & WAYPOINTFLAG_PERSONAL && self.goalcurrent.owner==self)
		{
			self.aistatus &~= AI_STATUS_WAYPOINT_PERSONAL_GOING;
			self.aistatus |= AI_STATUS_WAYPOINT_PERSONAL_REACHED;
		}

		navigation_poproute();
	}
}

// begin a goal selection session (queries spawnfunc_waypoint network)
void navigation_goalrating_start()
{
	if(self.aistatus & AI_STATUS_STUCK)
		return;

	self.navigation_jetpack_goal = world;
	navigation_bestrating = -1;
	self.navigation_hasgoals = FALSE;
	navigation_clearroute();
	navigation_bestgoal = world;
	navigation_markroutes(world);
}

// ends a goal selection session (updates goal stack to the best goal)
void navigation_goalrating_end()
{
	if(self.aistatus & AI_STATUS_STUCK)
		return;

	navigation_routetogoal(navigation_bestgoal, self.origin);
	bot_debug(strcat("best goal ", self.goalcurrent.classname , "\n"));

	// If the bot got stuck then try to reach the farthest waypoint
	if not (self.navigation_hasgoals)
	if (autocvar_bot_wander_enable)
	{
		if not(self.aistatus & AI_STATUS_STUCK)
		{
			bot_debug(strcat(self.netname, " cannot walk to any goal\n"));
			self.aistatus |= AI_STATUS_STUCK;
		}

		self.navigation_hasgoals = FALSE; // Reset this value
	}
}

void botframe_updatedangerousobjects(float maxupdate)
{
	entity head, bot_dodgelist;
	vector m1, m2, v, o;
	float c, d, danger;
	c = 0;
	bot_dodgelist = findchainfloat(bot_dodge, TRUE);
	botframe_dangerwaypoint = find(botframe_dangerwaypoint, classname, "waypoint");
	while (botframe_dangerwaypoint != world)
	{
		danger = 0;
		m1 = botframe_dangerwaypoint.mins;
		m2 = botframe_dangerwaypoint.maxs;
		head = bot_dodgelist;
		while (head)
		{
			v = head.origin;
			v_x = bound(m1_x, v_x, m2_x);
			v_y = bound(m1_y, v_y, m2_y);
			v_z = bound(m1_z, v_z, m2_z);
			o = (head.absmin + head.absmax) * 0.5;
			d = head.bot_dodgerating - vlen(o - v);
			if (d > 0)
			{
				traceline(o, v, TRUE, world);
				if (trace_fraction == 1)
					danger = danger + d;
			}
			head = head.chain;
		}
		botframe_dangerwaypoint.dmg = danger;
		c = c + 1;
		if (c >= maxupdate)
			break;
		botframe_dangerwaypoint = find(botframe_dangerwaypoint, classname, "waypoint");
	}
}

void navigation_unstuck()
{
	float search_radius = 1000;

	if not(autocvar_bot_wander_enable)
		return;

	if not(bot_waypoint_queue_owner)
	{
		bot_debug(strcat(self.netname, " sutck, taking over the waypoints queue\n"));
		bot_waypoint_queue_owner = self;
		bot_waypoint_queue_bestgoal = world;
		bot_waypoint_queue_bestgoalrating = 0;
	}

	if(bot_waypoint_queue_owner!=self)
		return;

	if (bot_waypoint_queue_goal)
	{
		// evaluate the next goal on the queue
		float d = vlen(self.origin - bot_waypoint_queue_goal.origin);
		bot_debug(strcat(self.netname, " evaluating ", bot_waypoint_queue_goal.classname, " with distance ", ftos(d), "\n"));
		if(tracewalk(bot_waypoint_queue_goal, self.origin, PL_MIN, PL_MAX, bot_waypoint_queue_goal.origin, bot_navigation_movemode))
		{
			if( d > bot_waypoint_queue_bestgoalrating)
			{
				bot_waypoint_queue_bestgoalrating = d;
				bot_waypoint_queue_bestgoal = bot_waypoint_queue_goal;
			}
		}
		bot_waypoint_queue_goal = bot_waypoint_queue_goal.bot_waypoint_queue_nextgoal;

		if not(bot_waypoint_queue_goal)
		{
			if (bot_waypoint_queue_bestgoal)
			{
				bot_debug(strcat(self.netname, " stuck, reachable waypoint found, heading to it\n"));
				navigation_routetogoal(bot_waypoint_queue_bestgoal, self.origin);
				self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
				self.aistatus &~= AI_STATUS_STUCK;
			}
			else
			{
				bot_debug(strcat(self.netname, " stuck, cannot walk to any waypoint at all\n"));
			}

			bot_waypoint_queue_owner = world;
		}
	}
	else
	{
		if(bot_strategytoken!=self)
			return;

		// build a new queue
		bot_debug(strcat(self.netname, " stuck, scanning reachable waypoints within ", ftos(search_radius)," qu\n"));

		entity head, first;

		first = world;
		head = findradius(self.origin, search_radius);

		while(head)
		{
			if(head.classname=="waypoint")
		//	if(!(head.wpflags & WAYPOINTFLAG_GENERATED))
			{
				if(bot_waypoint_queue_goal)
					bot_waypoint_queue_goal.bot_waypoint_queue_nextgoal = head;
				else
					first = head;

				bot_waypoint_queue_goal = head;
				bot_waypoint_queue_goal.bot_waypoint_queue_nextgoal = world;
			}

			head = head.chain;
		}

		if (first)
			bot_waypoint_queue_goal = first;
		else
		{
			bot_debug(strcat(self.netname, " stuck, cannot walk to any waypoint at all\n"));
			bot_waypoint_queue_owner = world;
		}
	}
}

// Support for debugging tracewalk visually

void debugresetnodes()
{
	debuglastnode = '0 0 0';
}

void debugnode(vector node)
{
	if not(IS_PLAYER(self))
		return;

	if(debuglastnode=='0 0 0')
	{
		debuglastnode = node;
		return;
	}

	te_lightning2(world, node, debuglastnode);
	debuglastnode = node;
}

void debugnodestatus(vector position, float status)
{
	vector c;

	switch (status)
	{
		case DEBUG_NODE_SUCCESS:
			c = '0 15 0';
			break;
		case DEBUG_NODE_WARNING:
			c = '15 15 0';
			break;
		case DEBUG_NODE_FAIL:
			c = '15 0 0';
			break;
		default:
			c = '15 15 15';
	}

	te_customflash(position, 40,  2, c);
}

// Support for debugging the goal stack visually

.float goalcounter;
.vector lastposition;

// Debug the goal stack visually
void debuggoalstack()
{
	entity goal;
	vector org, go;

	if(self.goalcounter==0)goal=self.goalcurrent;
	else if(self.goalcounter==1)goal=self.goalstack01;
	else if(self.goalcounter==2)goal=self.goalstack02;
	else if(self.goalcounter==3)goal=self.goalstack03;
	else if(self.goalcounter==4)goal=self.goalstack04;
	else if(self.goalcounter==5)goal=self.goalstack05;
	else if(self.goalcounter==6)goal=self.goalstack06;
	else if(self.goalcounter==7)goal=self.goalstack07;
	else if(self.goalcounter==8)goal=self.goalstack08;
	else if(self.goalcounter==9)goal=self.goalstack09;
	else if(self.goalcounter==10)goal=self.goalstack10;
	else if(self.goalcounter==11)goal=self.goalstack11;
	else if(self.goalcounter==12)goal=self.goalstack12;
	else if(self.goalcounter==13)goal=self.goalstack13;
	else if(self.goalcounter==14)goal=self.goalstack14;
	else if(self.goalcounter==15)goal=self.goalstack15;
	else if(self.goalcounter==16)goal=self.goalstack16;
	else if(self.goalcounter==17)goal=self.goalstack17;
	else if(self.goalcounter==18)goal=self.goalstack18;
	else if(self.goalcounter==19)goal=self.goalstack19;
	else if(self.goalcounter==20)goal=self.goalstack20;
	else if(self.goalcounter==21)goal=self.goalstack21;
	else if(self.goalcounter==22)goal=self.goalstack22;
	else if(self.goalcounter==23)goal=self.goalstack23;
	else if(self.goalcounter==24)goal=self.goalstack24;
	else if(self.goalcounter==25)goal=self.goalstack25;
	else if(self.goalcounter==26)goal=self.goalstack26;
	else if(self.goalcounter==27)goal=self.goalstack27;
	else if(self.goalcounter==28)goal=self.goalstack28;
	else if(self.goalcounter==29)goal=self.goalstack29;
	else if(self.goalcounter==30)goal=self.goalstack30;
	else if(self.goalcounter==31)goal=self.goalstack31;
	else goal=world;

	if(goal==world)
	{
		self.goalcounter = 0;
		self.lastposition='0 0 0';
		return;
	}

	if(self.lastposition=='0 0 0')
		org = self.origin;
	else
		org = self.lastposition;


	go = ( goal.absmin + goal.absmax ) * 0.5;
	te_lightning2(world, org, go);
	self.lastposition = go;

	self.goalcounter++;
}
