// create a new spawnfunc_waypoint and automatically link it to other waypoints, and link
// them back to it as well
// (suitable for spawnfunc_waypoint editor)
entity waypoint_spawn(vector m1, vector m2, float f)
{
	entity w;
	w = find(world, classname, "waypoint");

	if not(f & WAYPOINTFLAG_PERSONAL)
	while (w)
	{
		// if a matching spawnfunc_waypoint already exists, don't add a duplicate
		if (boxesoverlap(m1, m2, w.absmin, w.absmax))
			return w;
		w = find(w, classname, "waypoint");
	}

	w = spawn();
	w.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP | DPCONTENTS_BOTCLIP;
	w.classname = "waypoint";
	w.wpflags = f;
	setorigin(w, (m1 + m2) * 0.5);
	setsize(w, m1 - w.origin, m2 - w.origin);
	if (vlen(w.size) > 0)
		w.wpisbox = TRUE;

	if(!w.wpisbox)
	{
		setsize(w, PL_MIN - '1 1 0', PL_MAX + '1 1 0');
		if(!move_out_of_solid(w))
		{
			if(!(f & WAYPOINTFLAG_GENERATED))
			{
				dprint("Killed a waypoint that was stuck in solid at ", vtos(w.origin), "\n");
				remove(w);
				return world;
			}
			else
			{
				if(autocvar_developer)
				{
					print("A generated waypoint is stuck in solid at ", vtos(w.origin), "\n");
					backtrace("Waypoint stuck");
				}
			}
		}
		setsize(w, '0 0 0', '0 0 0');
	}

	waypoint_clearlinks(w);
	//waypoint_schedulerelink(w);

	if (autocvar_g_waypointeditor)
	{
		m1 = w.mins;
		m2 = w.maxs;
		setmodel(w, "models/runematch/rune.mdl"); w.effects = EF_LOWPRECISION;
		setsize(w, m1, m2);
		if (w.wpflags & WAYPOINTFLAG_ITEM)
			w.colormod = '1 0 0';
		else if (w.wpflags & WAYPOINTFLAG_GENERATED)
			w.colormod = '1 1 0';
		else
			w.colormod = '1 1 1';
	}
	else
		w.model = "";

	return w;
}

// add a new link to the spawnfunc_waypoint, replacing the furthest link it already has
void waypoint_addlink(entity from, entity to)
{
	float c;

	if (from == to)
		return;
	if (from.wpflags & WAYPOINTFLAG_NORELINK)
		return;

	if (from.wp00 == to) return;if (from.wp01 == to) return;if (from.wp02 == to) return;if (from.wp03 == to) return;
	if (from.wp04 == to) return;if (from.wp05 == to) return;if (from.wp06 == to) return;if (from.wp07 == to) return;
	if (from.wp08 == to) return;if (from.wp09 == to) return;if (from.wp10 == to) return;if (from.wp11 == to) return;
	if (from.wp12 == to) return;if (from.wp13 == to) return;if (from.wp14 == to) return;if (from.wp15 == to) return;
	if (from.wp16 == to) return;if (from.wp17 == to) return;if (from.wp18 == to) return;if (from.wp19 == to) return;
	if (from.wp20 == to) return;if (from.wp21 == to) return;if (from.wp22 == to) return;if (from.wp23 == to) return;
	if (from.wp24 == to) return;if (from.wp25 == to) return;if (from.wp26 == to) return;if (from.wp27 == to) return;
	if (from.wp28 == to) return;if (from.wp29 == to) return;if (from.wp30 == to) return;if (from.wp31 == to) return;

	if (to.wpisbox || from.wpisbox)
	{
		// if either is a box we have to find the nearest points on them to
		// calculate the distance properly
		vector v1, v2, m1, m2;
		v1 = from.origin;
		m1 = to.absmin;
		m2 = to.absmax;
		v1_x = bound(m1_x, v1_x, m2_x);
		v1_y = bound(m1_y, v1_y, m2_y);
		v1_z = bound(m1_z, v1_z, m2_z);
		v2 = to.origin;
		m1 = from.absmin;
		m2 = from.absmax;
		v2_x = bound(m1_x, v2_x, m2_x);
		v2_y = bound(m1_y, v2_y, m2_y);
		v2_z = bound(m1_z, v2_z, m2_z);
		v2 = to.origin;
		c = vlen(v2 - v1);
	}
	else
		c = vlen(to.origin - from.origin);

	if (from.wp31mincost < c) return;
	if (from.wp30mincost < c) {from.wp31 = to;from.wp31mincost = c;return;} from.wp31 = from.wp30;from.wp31mincost = from.wp30mincost;
	if (from.wp29mincost < c) {from.wp30 = to;from.wp30mincost = c;return;} from.wp30 = from.wp29;from.wp30mincost = from.wp29mincost;
	if (from.wp28mincost < c) {from.wp29 = to;from.wp29mincost = c;return;} from.wp29 = from.wp28;from.wp29mincost = from.wp28mincost;
	if (from.wp27mincost < c) {from.wp28 = to;from.wp28mincost = c;return;} from.wp28 = from.wp27;from.wp28mincost = from.wp27mincost;
	if (from.wp26mincost < c) {from.wp27 = to;from.wp27mincost = c;return;} from.wp27 = from.wp26;from.wp27mincost = from.wp26mincost;
	if (from.wp25mincost < c) {from.wp26 = to;from.wp26mincost = c;return;} from.wp26 = from.wp25;from.wp26mincost = from.wp25mincost;
	if (from.wp24mincost < c) {from.wp25 = to;from.wp25mincost = c;return;} from.wp25 = from.wp24;from.wp25mincost = from.wp24mincost;
	if (from.wp23mincost < c) {from.wp24 = to;from.wp24mincost = c;return;} from.wp24 = from.wp23;from.wp24mincost = from.wp23mincost;
	if (from.wp22mincost < c) {from.wp23 = to;from.wp23mincost = c;return;} from.wp23 = from.wp22;from.wp23mincost = from.wp22mincost;
	if (from.wp21mincost < c) {from.wp22 = to;from.wp22mincost = c;return;} from.wp22 = from.wp21;from.wp22mincost = from.wp21mincost;
	if (from.wp20mincost < c) {from.wp21 = to;from.wp21mincost = c;return;} from.wp21 = from.wp20;from.wp21mincost = from.wp20mincost;
	if (from.wp19mincost < c) {from.wp20 = to;from.wp20mincost = c;return;} from.wp20 = from.wp19;from.wp20mincost = from.wp19mincost;
	if (from.wp18mincost < c) {from.wp19 = to;from.wp19mincost = c;return;} from.wp19 = from.wp18;from.wp19mincost = from.wp18mincost;
	if (from.wp17mincost < c) {from.wp18 = to;from.wp18mincost = c;return;} from.wp18 = from.wp17;from.wp18mincost = from.wp17mincost;
	if (from.wp16mincost < c) {from.wp17 = to;from.wp17mincost = c;return;} from.wp17 = from.wp16;from.wp17mincost = from.wp16mincost;
	if (from.wp15mincost < c) {from.wp16 = to;from.wp16mincost = c;return;} from.wp16 = from.wp15;from.wp16mincost = from.wp15mincost;
	if (from.wp14mincost < c) {from.wp15 = to;from.wp15mincost = c;return;} from.wp15 = from.wp14;from.wp15mincost = from.wp14mincost;
	if (from.wp13mincost < c) {from.wp14 = to;from.wp14mincost = c;return;} from.wp14 = from.wp13;from.wp14mincost = from.wp13mincost;
	if (from.wp12mincost < c) {from.wp13 = to;from.wp13mincost = c;return;} from.wp13 = from.wp12;from.wp13mincost = from.wp12mincost;
	if (from.wp11mincost < c) {from.wp12 = to;from.wp12mincost = c;return;} from.wp12 = from.wp11;from.wp12mincost = from.wp11mincost;
	if (from.wp10mincost < c) {from.wp11 = to;from.wp11mincost = c;return;} from.wp11 = from.wp10;from.wp11mincost = from.wp10mincost;
	if (from.wp09mincost < c) {from.wp10 = to;from.wp10mincost = c;return;} from.wp10 = from.wp09;from.wp10mincost = from.wp09mincost;
	if (from.wp08mincost < c) {from.wp09 = to;from.wp09mincost = c;return;} from.wp09 = from.wp08;from.wp09mincost = from.wp08mincost;
	if (from.wp07mincost < c) {from.wp08 = to;from.wp08mincost = c;return;} from.wp08 = from.wp07;from.wp08mincost = from.wp07mincost;
	if (from.wp06mincost < c) {from.wp07 = to;from.wp07mincost = c;return;} from.wp07 = from.wp06;from.wp07mincost = from.wp06mincost;
	if (from.wp05mincost < c) {from.wp06 = to;from.wp06mincost = c;return;} from.wp06 = from.wp05;from.wp06mincost = from.wp05mincost;
	if (from.wp04mincost < c) {from.wp05 = to;from.wp05mincost = c;return;} from.wp05 = from.wp04;from.wp05mincost = from.wp04mincost;
	if (from.wp03mincost < c) {from.wp04 = to;from.wp04mincost = c;return;} from.wp04 = from.wp03;from.wp04mincost = from.wp03mincost;
	if (from.wp02mincost < c) {from.wp03 = to;from.wp03mincost = c;return;} from.wp03 = from.wp02;from.wp03mincost = from.wp02mincost;
	if (from.wp01mincost < c) {from.wp02 = to;from.wp02mincost = c;return;} from.wp02 = from.wp01;from.wp02mincost = from.wp01mincost;
	if (from.wp00mincost < c) {from.wp01 = to;from.wp01mincost = c;return;} from.wp01 = from.wp00;from.wp01mincost = from.wp00mincost;
	from.wp00 = to;from.wp00mincost = c;return;
}

// relink this spawnfunc_waypoint
// (precompile a list of all reachable waypoints from this spawnfunc_waypoint)
// (SLOW!)
void waypoint_think()
{
	entity e;
	vector sv, sm1, sm2, ev, em1, em2, dv;

	bot_calculate_stepheightvec();

	bot_navigation_movemode = ((autocvar_bot_navigation_ignoreplayers) ? MOVE_NOMONSTERS : MOVE_NORMAL);

	//dprint("waypoint_think wpisbox = ", ftos(self.wpisbox), "\n");
	sm1 = self.origin + self.mins;
	sm2 = self.origin + self.maxs;
	for(e = world; (e = find(e, classname, "waypoint")); )
	{
		if (boxesoverlap(self.absmin, self.absmax, e.absmin, e.absmax))
		{
			waypoint_addlink(self, e);
			waypoint_addlink(e, self);
		}
		else
		{
			++relink_total;
			if(!checkpvs(self.origin, e))
			{
				++relink_pvsculled;
				continue;
			}
			sv = e.origin;
			sv_x = bound(sm1_x, sv_x, sm2_x);
			sv_y = bound(sm1_y, sv_y, sm2_y);
			sv_z = bound(sm1_z, sv_z, sm2_z);
			ev = self.origin;
			em1 = e.origin + e.mins;
			em2 = e.origin + e.maxs;
			ev_x = bound(em1_x, ev_x, em2_x);
			ev_y = bound(em1_y, ev_y, em2_y);
			ev_z = bound(em1_z, ev_z, em2_z);
			dv = ev - sv;
			dv_z = 0;
			if (vlen(dv) >= 1050) // max search distance in XY
			{
				++relink_lengthculled;
				continue;
			}
			navigation_testtracewalk = 0;
			if (!self.wpisbox)
			{
				tracebox(sv - PL_MIN_z * '0 0 1', PL_MIN, PL_MAX, sv, FALSE, self);
				if (!trace_startsolid)
				{
					//dprint("sv deviation", vtos(trace_endpos - sv), "\n");
					sv = trace_endpos + '0 0 1';
				}
			}
			if (!e.wpisbox)
			{
				tracebox(ev - PL_MIN_z * '0 0 1', PL_MIN, PL_MAX, ev, FALSE, e);
				if (!trace_startsolid)
				{
					//dprint("ev deviation", vtos(trace_endpos - ev), "\n");
					ev = trace_endpos + '0 0 1';
				}
			}
			//traceline(self.origin, e.origin, FALSE, world);
			//if (trace_fraction == 1)
			if (!self.wpisbox && tracewalk(self, sv, PL_MIN, PL_MAX, ev, MOVE_NOMONSTERS))
				waypoint_addlink(self, e);
			else
				relink_walkculled += 0.5;
			if (!e.wpisbox && tracewalk(e, ev, PL_MIN, PL_MAX, sv, MOVE_NOMONSTERS))
				waypoint_addlink(e, self);
			else
				relink_walkculled += 0.5;
		}
	}
	navigation_testtracewalk = 0;
	self.wplinked = TRUE;
}

void waypoint_clearlinks(entity wp)
{
	// clear links to other waypoints
	float f;
	f = 10000000;
	wp.wp00 = wp.wp01 = wp.wp02 = wp.wp03 = wp.wp04 = wp.wp05 = wp.wp06 = wp.wp07 = world;
	wp.wp08 = wp.wp09 = wp.wp10 = wp.wp11 = wp.wp12 = wp.wp13 = wp.wp14 = wp.wp15 = world;
	wp.wp16 = wp.wp17 = wp.wp18 = wp.wp19 = wp.wp20 = wp.wp21 = wp.wp22 = wp.wp23 = world;
	wp.wp24 = wp.wp25 = wp.wp26 = wp.wp27 = wp.wp28 = wp.wp29 = wp.wp30 = wp.wp31 = world;

	wp.wp00mincost = wp.wp01mincost = wp.wp02mincost = wp.wp03mincost = wp.wp04mincost = wp.wp05mincost = wp.wp06mincost = wp.wp07mincost = f;
	wp.wp08mincost = wp.wp09mincost = wp.wp10mincost = wp.wp11mincost = wp.wp12mincost = wp.wp13mincost = wp.wp14mincost = wp.wp15mincost = f;
	wp.wp16mincost = wp.wp17mincost = wp.wp18mincost = wp.wp19mincost = wp.wp20mincost = wp.wp21mincost = wp.wp22mincost = wp.wp23mincost = f;
	wp.wp24mincost = wp.wp25mincost = wp.wp26mincost = wp.wp27mincost = wp.wp28mincost = wp.wp29mincost = wp.wp30mincost = wp.wp31mincost = f;

	wp.wplinked = FALSE;
}

// tell a spawnfunc_waypoint to relink
void waypoint_schedulerelink(entity wp)
{
	if (wp == world)
		return;
	// TODO: add some sort of visible box in edit mode for box waypoints
	if (autocvar_g_waypointeditor)
	{
		vector m1, m2;
		m1 = wp.mins;
		m2 = wp.maxs;
		setmodel(wp, "models/runematch/rune.mdl"); wp.effects = EF_LOWPRECISION;
		setsize(wp, m1, m2);
		if (wp.wpflags & WAYPOINTFLAG_ITEM)
			wp.colormod = '1 0 0';
		else if (wp.wpflags & WAYPOINTFLAG_GENERATED)
			wp.colormod = '1 1 0';
		else
			wp.colormod = '1 1 1';
	}
	else
		wp.model = "";
	wp.wpisbox = vlen(wp.size) > 0;
	wp.enemy = world;
	if (!(wp.wpflags & WAYPOINTFLAG_PERSONAL))
		wp.owner = world;
	if (!(wp.wpflags & WAYPOINTFLAG_NORELINK))
		waypoint_clearlinks(wp);
	// schedule an actual relink on next frame
	wp.think = waypoint_think;
	wp.nextthink = time;
	wp.effects = EF_LOWPRECISION;
}

// spawnfunc_waypoint map entity
void spawnfunc_waypoint()
{
	setorigin(self, self.origin);
	// schedule a relink after other waypoints have had a chance to spawn
	waypoint_clearlinks(self);
	//waypoint_schedulerelink(self);
}

// remove a spawnfunc_waypoint, and schedule all neighbors to relink
void waypoint_remove(entity e)
{
	// tell all linked waypoints that they need to relink
	waypoint_schedulerelink(e.wp00);
	waypoint_schedulerelink(e.wp01);
	waypoint_schedulerelink(e.wp02);
	waypoint_schedulerelink(e.wp03);
	waypoint_schedulerelink(e.wp04);
	waypoint_schedulerelink(e.wp05);
	waypoint_schedulerelink(e.wp06);
	waypoint_schedulerelink(e.wp07);
	waypoint_schedulerelink(e.wp08);
	waypoint_schedulerelink(e.wp09);
	waypoint_schedulerelink(e.wp10);
	waypoint_schedulerelink(e.wp11);
	waypoint_schedulerelink(e.wp12);
	waypoint_schedulerelink(e.wp13);
	waypoint_schedulerelink(e.wp14);
	waypoint_schedulerelink(e.wp15);
	waypoint_schedulerelink(e.wp16);
	waypoint_schedulerelink(e.wp17);
	waypoint_schedulerelink(e.wp18);
	waypoint_schedulerelink(e.wp19);
	waypoint_schedulerelink(e.wp20);
	waypoint_schedulerelink(e.wp21);
	waypoint_schedulerelink(e.wp22);
	waypoint_schedulerelink(e.wp23);
	waypoint_schedulerelink(e.wp24);
	waypoint_schedulerelink(e.wp25);
	waypoint_schedulerelink(e.wp26);
	waypoint_schedulerelink(e.wp27);
	waypoint_schedulerelink(e.wp28);
	waypoint_schedulerelink(e.wp29);
	waypoint_schedulerelink(e.wp30);
	waypoint_schedulerelink(e.wp31);
	// and now remove the spawnfunc_waypoint
	remove(e);
}

// empties the map of waypoints
void waypoint_removeall()
{
	entity head, next;
	head = findchain(classname, "waypoint");
	while (head)
	{
		next = head.chain;
		remove(head);
		head = next;
	}
}

// tell all waypoints to relink
// (is this useful at all?)
void waypoint_schedulerelinkall()
{
	entity head;
	relink_total = relink_walkculled = relink_pvsculled = relink_lengthculled = 0;
	head = findchain(classname, "waypoint");
	while (head)
	{
		waypoint_schedulerelink(head);
		head = head.chain;
	}
}

// Load waypoint links from file
float waypoint_load_links()
{
	string filename, s;
	float file, tokens, c = 0, found;
	entity wp_from = world, wp_to;
	vector wp_to_pos, wp_from_pos;
	filename = strcat("maps/", mapname);
	filename = strcat(filename, ".waypoints.cache");
	file = fopen(filename, FILE_READ);

	if (file < 0)
	{
		dprint("waypoint links load from ");
		dprint(filename);
		dprint(" failed\n");
		return FALSE;
	}

	while ((s = fgets(file)))
	{
		tokens = tokenizebyseparator(s, "*");

		if (tokens!=2)
		{
			// bad file format
			fclose(file);
			return FALSE;
		}

		wp_from_pos	= stov(argv(0));
		wp_to_pos	= stov(argv(1));

		// Search "from" waypoint
		if(!wp_from || wp_from.origin!=wp_from_pos)
		{
			wp_from = findradius(wp_from_pos, 1);
			found = FALSE;
			while(wp_from)
			{
				if(vlen(wp_from.origin-wp_from_pos)<1)
				if(wp_from.classname == "waypoint")
				{
					found = TRUE;
					break;
				}
				wp_from = wp_from.chain;
			}

			if(!found)
			{
				dprint("waypoint_load_links: couldn't find 'from' waypoint at ", vtos(wp_from.origin),"\n");
				continue;
			}

		}

		// Search "to" waypoint
		wp_to = findradius(wp_to_pos, 1);
		found = FALSE;
		while(wp_to)
		{
			if(vlen(wp_to.origin-wp_to_pos)<1)
			if(wp_to.classname == "waypoint")
			{
				found = TRUE;
				break;
			}
			wp_to = wp_to.chain;
		}

		if(!found)
		{
			dprint("waypoint_load_links: couldn't find 'to' waypoint at ", vtos(wp_to.origin),"\n");
			continue;
		}

		++c;
		waypoint_addlink(wp_from, wp_to);
	}

	fclose(file);

	dprint("loaded ");
	dprint(ftos(c));
	dprint(" waypoint links from maps/");
	dprint(mapname);
	dprint(".waypoints.cache\n");

	botframe_cachedwaypointlinks = TRUE;
	return TRUE;
}

void waypoint_load_links_hardwired()
{
	string filename, s;
	float file, tokens, c = 0, found;
	entity wp_from = world, wp_to;
	vector wp_to_pos, wp_from_pos;
	filename = strcat("maps/", mapname);
	filename = strcat(filename, ".waypoints.hardwired");
	file = fopen(filename, FILE_READ);

	botframe_loadedforcedlinks = TRUE;

	if (file < 0)
	{
		dprint("waypoint links load from ");
		dprint(filename);
		dprint(" failed\n");
		return;
	}

	while ((s = fgets(file)))
	{
		if(substring(s, 0, 2)=="//")
			continue;

		if(substring(s, 0, 1)=="#")
			continue;

		tokens = tokenizebyseparator(s, "*");

		if (tokens!=2)
			continue;

		wp_from_pos	= stov(argv(0));
		wp_to_pos	= stov(argv(1));

		// Search "from" waypoint
		if(!wp_from || wp_from.origin!=wp_from_pos)
		{
			wp_from = findradius(wp_from_pos, 5);
			found = FALSE;
			while(wp_from)
			{
				if(vlen(wp_from.origin-wp_from_pos)<5)
				if(wp_from.classname == "waypoint")
				{
					found = TRUE;
					break;
				}
				wp_from = wp_from.chain;
			}

			if(!found)
			{
				print(strcat("NOTICE: Can not find waypoint at ", vtos(wp_from_pos), ". Path skipped\n"));
				continue;
			}
		}

		// Search "to" waypoint
		wp_to = findradius(wp_to_pos, 5);
		found = FALSE;
		while(wp_to)
		{
			if(vlen(wp_to.origin-wp_to_pos)<5)
			if(wp_to.classname == "waypoint")
			{
				found = TRUE;
				break;
			}
			wp_to = wp_to.chain;
		}

		if(!found)
		{
			print(strcat("NOTICE: Can not find waypoint at ", vtos(wp_to_pos), ". Path skipped\n"));
			continue;
		}

		++c;
		waypoint_addlink(wp_from, wp_to);
		wp_from.wphardwired = TRUE;
		wp_to.wphardwired = TRUE;
	}

	fclose(file);

	dprint("loaded ");
	dprint(ftos(c));
	dprint(" waypoint links from maps/");
	dprint(mapname);
	dprint(".waypoints.hardwired\n");
}

// Save all waypoint links to a file
void waypoint_save_links()
{
	string filename, s;
	float file, c, i;
	entity w, link;
	filename = strcat("maps/", mapname);
	filename = strcat(filename, ".waypoints.cache");
	file = fopen(filename, FILE_WRITE);
	if (file < 0)
	{
		print("waypoint links save to ");
		print(filename);
		print(" failed\n");
	}
	c = 0;
	w = findchain(classname, "waypoint");
	while (w)
	{
		for(i=0;i<32;++i)
		{
			// :S
			link = world;
			switch(i)
			{
				//	for i in $(seq -w 0 31); do echo "case $i:link = w.wp$i; break;"; done;
				case  0:link = w.wp00; break;
				case  1:link = w.wp01; break;
				case  2:link = w.wp02; break;
				case  3:link = w.wp03; break;
				case  4:link = w.wp04; break;
				case  5:link = w.wp05; break;
				case  6:link = w.wp06; break;
				case  7:link = w.wp07; break;
				case  8:link = w.wp08; break;
				case  9:link = w.wp09; break;
				case 10:link = w.wp10; break;
				case 11:link = w.wp11; break;
				case 12:link = w.wp12; break;
				case 13:link = w.wp13; break;
				case 14:link = w.wp14; break;
				case 15:link = w.wp15; break;
				case 16:link = w.wp16; break;
				case 17:link = w.wp17; break;
				case 18:link = w.wp18; break;
				case 19:link = w.wp19; break;
				case 20:link = w.wp20; break;
				case 21:link = w.wp21; break;
				case 22:link = w.wp22; break;
				case 23:link = w.wp23; break;
				case 24:link = w.wp24; break;
				case 25:link = w.wp25; break;
				case 26:link = w.wp26; break;
				case 27:link = w.wp27; break;
				case 28:link = w.wp28; break;
				case 29:link = w.wp29; break;
				case 30:link = w.wp30; break;
				case 31:link = w.wp31; break;
			}

			if(link==world)
				continue;

			s = strcat(vtos(w.origin), "*", vtos(link.origin), "\n");
			fputs(file, s);
			++c;
		}
		w = w.chain;
	}
	fclose(file);
	botframe_cachedwaypointlinks = TRUE;

	print("saved ");
	print(ftos(c));
	print(" waypoints links to maps/");
	print(mapname);
	print(".waypoints.cache\n");
}

// save waypoints to gamedir/data/maps/mapname.waypoints
void waypoint_saveall()
{
	string filename, s;
	float file, c;
	entity w;
	filename = strcat("maps/", mapname);
	filename = strcat(filename, ".waypoints");
	file = fopen(filename, FILE_WRITE);
	if (file >= 0)
	{
		c = 0;
		w = findchain(classname, "waypoint");
		while (w)
		{
			if (!(w.wpflags & WAYPOINTFLAG_GENERATED))
			{
				s = strcat(vtos(w.origin + w.mins), "\n");
				s = strcat(s, vtos(w.origin + w.maxs));
				s = strcat(s, "\n");
				s = strcat(s, ftos(w.wpflags));
				s = strcat(s, "\n");
				fputs(file, s);
				c = c + 1;
			}
			w = w.chain;
		}
		fclose(file);
		bprint("saved ");
		bprint(ftos(c));
		bprint(" waypoints to maps/");
		bprint(mapname);
		bprint(".waypoints\n");
	}
	else
	{
		bprint("waypoint save to ");
		bprint(filename);
		bprint(" failed\n");
	}
	waypoint_save_links();
	botframe_loadedforcedlinks = FALSE;
}

// load waypoints from file
float waypoint_loadall()
{
	string filename, s;
	float file, cwp, cwb, fl;
	vector m1, m2;
	cwp = 0;
	cwb = 0;
	filename = strcat("maps/", mapname);
	filename = strcat(filename, ".waypoints");
	file = fopen(filename, FILE_READ);
	if (file >= 0)
	{
		while ((s = fgets(file)))
		{
			m1 = stov(s);
			s = fgets(file);
			if not(s)
				break;
			m2 = stov(s);
			s = fgets(file);
			if not(s)
				break;
			fl = stof(s);
			waypoint_spawn(m1, m2, fl);
			if (m1 == m2)
				cwp = cwp + 1;
			else
				cwb = cwb + 1;
		}
		fclose(file);
		dprint("loaded ");
		dprint(ftos(cwp));
		dprint(" waypoints and ");
		dprint(ftos(cwb));
		dprint(" wayboxes from maps/");
		dprint(mapname);
		dprint(".waypoints\n");
	}
	else
	{
		dprint("waypoint load from ");
		dprint(filename);
		dprint(" failed\n");
	}
	return cwp + cwb;
}

vector waypoint_fixorigin(vector position)
{
	tracebox(position + '0 0 1' * (1 - PL_MIN_z), PL_MIN, PL_MAX, position + '0 0 -512', MOVE_NOMONSTERS, world);
	if(trace_fraction < 1)
		position = trace_endpos;
	//traceline(position, position + '0 0 -512', MOVE_NOMONSTERS, world);
	//print("position is ", ftos(trace_endpos_z - position_z), " above solid\n");
	return position;
}

void waypoint_spawnforitem_force(entity e, vector org)
{
	entity w;

	// Fix the waypoint altitude if necessary
	org = waypoint_fixorigin(org);

	// don't spawn an item spawnfunc_waypoint if it already exists
	w = findchain(classname, "waypoint");
	while (w)
	{
		if (w.wpisbox)
		{
			if (boxesoverlap(org, org, w.absmin, w.absmax))
			{
				e.nearestwaypoint = w;
				return;
			}
		}
		else
		{
			if (vlen(w.origin - org) < 16)
			{
				e.nearestwaypoint = w;
				return;
			}
		}
		w = w.chain;
	}
	e.nearestwaypoint = waypoint_spawn(org, org, WAYPOINTFLAG_GENERATED | WAYPOINTFLAG_ITEM);
}

void waypoint_spawnforitem(entity e)
{
	if(!bot_waypoints_for_items)
		return;

	waypoint_spawnforitem_force(e, e.origin);
}

void waypoint_spawnforteleporter_boxes(entity e, vector org1, vector org2, vector destination1, vector destination2, float timetaken)
{
	entity w;
	entity dw;
	w = waypoint_spawn(org1, org2, WAYPOINTFLAG_GENERATED | WAYPOINTFLAG_TELEPORT | WAYPOINTFLAG_NORELINK);
	dw = waypoint_spawn(destination1, destination2, WAYPOINTFLAG_GENERATED);
	// one way link to the destination
	w.wp00 = dw;
	w.wp00mincost = timetaken; // this is just for jump pads
	// the teleporter's nearest spawnfunc_waypoint is this one
	// (teleporters are not goals, so this is probably useless)
	e.nearestwaypoint = w;
	e.nearestwaypointtimeout = time + 1000000000;
}

void waypoint_spawnforteleporter_v(entity e, vector org, vector destination, float timetaken)
{
	org = waypoint_fixorigin(org);
	destination = waypoint_fixorigin(destination);
	waypoint_spawnforteleporter_boxes(e, org, org, destination, destination, timetaken);
}

void waypoint_spawnforteleporter(entity e, vector destination, float timetaken)
{
	destination = waypoint_fixorigin(destination);
	waypoint_spawnforteleporter_boxes(e, e.absmin, e.absmax, destination, destination, timetaken);
}

entity waypoint_spawnpersonal(vector position)
{
	entity w;

	// drop the waypoint to a proper location:
	//   first move it up by a player height
	//   then move it down to hit the floor with player bbox size
	position = waypoint_fixorigin(position);

	w = waypoint_spawn(position, position, WAYPOINTFLAG_GENERATED | WAYPOINTFLAG_PERSONAL);
	w.nearestwaypoint = world;
	w.nearestwaypointtimeout = 0;
	w.owner = self;

	waypoint_schedulerelink(w);

	return w;
}

void botframe_showwaypointlinks()
{
	entity player, head, w;
	if (time < botframe_waypointeditorlightningtime)
		return;
	botframe_waypointeditorlightningtime = time + 0.5;
	player = find(world, classname, "player");
	while (player)
	{
		if (!player.isbot)
		if (player.flags & FL_ONGROUND || player.waterlevel > WATERLEVEL_NONE)
		{
			//navigation_testtracewalk = TRUE;
			head = navigation_findnearestwaypoint(player, FALSE);
		//	print("currently selected WP is ", etos(head), "\n");
			//navigation_testtracewalk = FALSE;
			if (head)
			{
				w = head     ;if (w) te_lightning2(world, w.origin, player.origin);
				w = head.wp00;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp01;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp02;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp03;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp04;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp05;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp06;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp07;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp08;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp09;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp10;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp11;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp12;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp13;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp14;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp15;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp16;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp17;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp18;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp19;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp20;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp21;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp22;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp23;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp24;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp25;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp26;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp27;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp28;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp29;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp30;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp31;if (w) te_lightning2(world, w.origin, head.origin);
			}
		}
		player = find(player, classname, "player");
	}
}

float botframe_autowaypoints_fixdown(vector v)
{
	tracebox(v, PL_MIN, PL_MAX, v + '0 0 -64', MOVE_NOMONSTERS, world);
	if(trace_fraction >= 1)
		return 0;
	return 1;
}

float botframe_autowaypoints_createwp(vector v, entity p, .entity fld)
{
	entity w;

	w = find(world, classname, "waypoint");
	while (w)
	{
		// if a matching spawnfunc_waypoint already exists, don't add a duplicate
		if (boxesoverlap(v - '32 32 32', v + '32 32 32', w.absmin, w.absmax))
		//if (boxesoverlap(v - '4 4 4', v + '4 4 4', w.absmin, w.absmax))
			return 0;
		w = find(w, classname, "waypoint");
	}

	waypoint_schedulerelink(p.fld = waypoint_spawn(v, v, 0));
	return 1;
}

// return value:
//    1 = WP created
//    0 = no action needed
//   -1 = temp fail, try from world too
//   -2 = permanent fail, do not retry
float botframe_autowaypoints_fix_from(entity p, float walkfromwp, entity wp, .entity fld)
{
	// make it possible to go from p to wp, if we can
	// if wp is world, nearest is chosen

	entity w;
	vector porg;
	float t, tmin, tmax;
	vector o;
	vector save;

	if(!botframe_autowaypoints_fixdown(p.origin))
		return -2;
	porg = trace_endpos;

	if(wp)
	{
		// if any WP w fulfills wp -> w -> porg, then switch from wp to w

		// if wp -> porg, then OK
		float maxdist;
		if(navigation_waypoint_will_link(wp.origin, porg, p, walkfromwp, 1050))
		{
			// we may find a better one
			maxdist = vlen(wp.origin - porg);
		}
		else
		{
			// accept any "good"
			maxdist = 2100;
		}

		float bestdist;
		bestdist = maxdist;
		w = find(world, classname, "waypoint");
		while (w)
		{
			if(w != wp && !(w.wpflags & WAYPOINTFLAG_NORELINK))
			{
				float d;
				d = vlen(wp.origin - w.origin) + vlen(w.origin - porg);
				if(d < bestdist)
					if(navigation_waypoint_will_link(wp.origin, w.origin, p, walkfromwp, 1050))
						if(navigation_waypoint_will_link(w.origin, porg, p, walkfromwp, 1050))
						{
							bestdist = d;
							p.fld = w;
						}
			}
			w = find(w, classname, "waypoint");
		}
		if(bestdist < maxdist)
		{
			print("update chain to new nearest WP ", etos(p.fld), "\n");
			return 0;
		}

		if(bestdist < 2100)
		{
			// we know maxdist < 2100
			// so wp -> porg is still valid
			// all is good
			p.fld = wp;
			return 0;
		}

		// otherwise, no existing WP can fix our issues
	}
	else
	{
		save = p.origin;
		setorigin(p, porg);
		w = navigation_findnearestwaypoint(p, walkfromwp);
		setorigin(p, save);
		if(w)
		{
			p.fld = w;
			return 0;
		}
	}

	tmin = 0;
	tmax = 1;
	for(;;)
	{
		if(tmax - tmin < 0.001)
		{
			// did not get a good candidate
			return -1;
		}

		t = (tmin + tmax) * 0.5;
		o = antilag_takebackorigin(p, time - t);
		if(!botframe_autowaypoints_fixdown(o))
			return -1;
		o = trace_endpos;

		if(wp)
		{
			if(!navigation_waypoint_will_link(wp.origin, o, p, walkfromwp, 1050))
			{
				// we cannot walk from wp.origin to o
				// get closer to tmax
				tmin = t;
				continue;
			}
		}
		else
		{
			save = p.origin;
			setorigin(p, o);
			w = navigation_findnearestwaypoint(p, walkfromwp);
			setorigin(p, save);
			if(!w)
			{
				// we cannot walk from any WP to o
				// get closer to tmax
				tmin = t;
				continue;
			}
		}

		// if we get here, o is valid regarding waypoints
		// check if o is connected right to the player
		// we break if it succeeds, as that means o is a good waypoint location
		if(navigation_waypoint_will_link(o, porg, p, walkfromwp, 1050))
			break;

		// o is no good, we need to get closer to the player
		tmax = t;
	}

	print("spawning a waypoint for connecting to ", etos(wp), "\n");
	botframe_autowaypoints_createwp(o, p, fld);
	return 1;
}

// automatically create missing waypoints
.entity botframe_autowaypoints_lastwp0, botframe_autowaypoints_lastwp1;
void botframe_autowaypoints_fix(entity p, float walkfromwp, .entity fld)
{
	float r;
	r = botframe_autowaypoints_fix_from(p, walkfromwp, p.fld, fld);
	if(r != -1)
		return;
	r = botframe_autowaypoints_fix_from(p, walkfromwp, world, fld);
	if(r != -1)
		return;

	print("emergency: got no good nearby WP to build a link from, starting a new chain\n");
	if(!botframe_autowaypoints_fixdown(p.origin))
		return; // shouldn't happen, caught above
	botframe_autowaypoints_createwp(trace_endpos, p, fld);
}

void botframe_autowaypoints()
{
	entity p;
	FOR_EACH_REALPLAYER(p)
	{
		if(p.deadflag)
			continue;
		// going back is broken, so only fix waypoints to walk TO the player
		//botframe_autowaypoints_fix(p, FALSE, botframe_autowaypoints_lastwp0);
		botframe_autowaypoints_fix(p, TRUE, botframe_autowaypoints_lastwp1);
		//te_explosion(p.botframe_autowaypoints_lastwp0.origin);
	}
}

