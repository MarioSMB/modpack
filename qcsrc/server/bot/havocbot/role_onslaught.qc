#define HAVOCBOT_ONS_ROLE_NONE 		0
#define HAVOCBOT_ONS_ROLE_DEFENSE	2
#define HAVOCBOT_ONS_ROLE_ASSISTANT	4
#define HAVOCBOT_ONS_ROLE_OFFENSE	8

.float havocbot_role_flags;
.float havocbot_attack_time;

.void() havocbot_role;
.void() havocbot_previous_role;

void() havocbot_role_ons_defense;
void() havocbot_role_ons_offense;
void() havocbot_role_ons_assistant;

void(entity bot) havocbot_ons_reset_role;
void(float ratingscale, vector org, float sradius) havocbot_goalrating_items;
void(float ratingscale, vector org, float sradius) havocbot_goalrating_enemyplayers;

.float isshielded;
.float iscaptured;
.float islinked;
.float isgenneighbor_blue, iscpneighbor_blue;
.float isgenneighbor_red, iscpneighbor_red;

.entity havocbot_ons_target;

void havocbot_goalrating_ons_offenseitems(float ratingscale, vector org, float sradius)
{
	entity head;
	float t, i, c, needarmor = FALSE, needweapons = FALSE;

	// Needs armor/health?
	if(self.health<100)
		needarmor = TRUE;

	// Needs weapons?
	c = 0;
	for(i = WEP_FIRST; i <= WEP_LAST ; ++i)
	{
		// Find weapon
		if(self.weapons & WepSet_FromWeapon(i))
		if(++c>=4)
			break;
	}

	if(c<4)
		needweapons = TRUE;

	if(!needweapons && !needarmor)
		return;

//	dprint(self.netname, " needs weapons ", ftos(needweapons) , "\n");
//	dprint(self.netname, " needs armor ", ftos(needarmor) , "\n");

	// See what is around
	head = findchainfloat(bot_pickup, TRUE);
	while (head)
	{
		// gather health and armor only
		if (head.solid)
		if ( ((head.health || head.armorvalue) && needarmor) || (head.weapons && needweapons ) )
		if (vlen(head.origin - org) < sradius)
		{
			t = head.bot_pickupevalfunc(self, head);
			if (t > 0)
				navigation_routerating(head, t * ratingscale, 500);
		}
		head = head.chain;
	}
}

void havocbot_role_ons_setrole(entity bot, float role)
{
	dprint(strcat(bot.netname," switched to "));
	switch(role)
	{
		case HAVOCBOT_ONS_ROLE_DEFENSE:
			dprint("defense");
			bot.havocbot_role = havocbot_role_ons_defense;
			bot.havocbot_role_flags = HAVOCBOT_ONS_ROLE_DEFENSE;
			bot.havocbot_role_timeout = 0;
			break;
		case HAVOCBOT_ONS_ROLE_ASSISTANT:
			dprint("assistant");
			bot.havocbot_role = havocbot_role_ons_assistant;
			bot.havocbot_role_flags = HAVOCBOT_ONS_ROLE_ASSISTANT;
			bot.havocbot_role_timeout = 0;
			break;
		case HAVOCBOT_ONS_ROLE_OFFENSE:
			dprint("offense");
			bot.havocbot_role = havocbot_role_ons_offense;
			bot.havocbot_role_flags = HAVOCBOT_ONS_ROLE_OFFENSE;
			bot.havocbot_role_timeout = 0;
			break;
	}
	dprint("\n");
}

float havocbot_ons_teamcount(entity bot, float role)
{
	float c = 0;
	entity head;

	FOR_EACH_PLAYER(head)
	if(head.team==self.team)
	if(head.havocbot_role_flags & role)
		++c;

	return c;
}

void havocbot_goalrating_ons_controlpoints_attack(float ratingscale)
{
	entity cp, cp1, cp2, best, pl, wp;
	float radius, found, bestvalue, c;

	cp1 = cp2 = findchain(classname, "onslaught_controlpoint");

	// Filter control points
	for (; cp2; cp2 = cp2.chain)
	{
		cp2.wpcost = c = 0;
		cp2.wpconsidered = FALSE;

		if(cp2.isshielded)
			continue;

		// Ignore owned controlpoints
		if(self.team == NUM_TEAM_1)
		{
			if( (cp2.isgenneighbor_blue || cp2.iscpneighbor_blue) && !(cp2.isgenneighbor_red || cp2.iscpneighbor_red) )
				continue;
		}
		else if(self.team == NUM_TEAM_2)
		{
			if( (cp2.isgenneighbor_red || cp2.iscpneighbor_red) && !(cp2.isgenneighbor_blue || cp2.iscpneighbor_blue) )
				continue;
		}

		// Count team mates interested in this control point
		// (easier and cleaner than keeping counters per cp and teams)
		FOR_EACH_PLAYER(pl)
		if(pl.team==self.team)
		if(pl.havocbot_role_flags & HAVOCBOT_ONS_ROLE_OFFENSE)
		if(pl.havocbot_ons_target==cp2)
			++c;

		// NOTE: probably decrease the cost of attackable control points
		cp2.wpcost = c;
		cp2.wpconsidered = TRUE;
	}

	// We'll consider only the best case
	bestvalue = 99999999999;
	cp = world;
	for (; cp1; cp1 = cp1.chain)
	{
		if not(cp1.wpconsidered)
			continue;

		if(cp1.wpcost<bestvalue)
		{
			bestvalue = cp1.wpcost;
			cp = cp1;
			self.havocbot_ons_target = cp1;
		}
	}

	if not(cp)
		return;

//	dprint(self.netname, " chose cp ranked ", ftos(bestvalue), "\n");

	if(cp.goalentity)
	{
		// Should be attacked
		// Rate waypoints near it
		found = FALSE;
		best = world;
		bestvalue = 99999999999;
		for(radius=0; radius<1000 && !found; radius+=500)
		{
			for(wp=findradius(cp.origin,radius); wp; wp=wp.chain)
			{
				if(!(wp.wpflags & WAYPOINTFLAG_GENERATED))
				if(wp.classname=="waypoint")
				if(checkpvs(wp.origin,cp))
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
			navigation_routerating(best, ratingscale, 10000);
			best.cnt += 1;

			self.havocbot_attack_time = 0;
			if(checkpvs(self.view_ofs,cp))
			if(checkpvs(self.view_ofs,best))
				self.havocbot_attack_time = time + 2;
		}
		else
		{
			navigation_routerating(cp, ratingscale, 10000);
		}
	//	dprint(self.netname, " found an attackable controlpoint at ", vtos(cp.origin) ,"\n");
	}
	else
	{
		// Should be touched
		// dprint(self.netname, " found a touchable controlpoint at ", vtos(cp.origin) ,"\n");
		found = FALSE;

		// Look for auto generated waypoint
		if not(bot_waypoints_for_items)
		for (wp = findradius(cp.origin,100); wp; wp = wp.chain)
		{
			if(wp.classname=="waypoint")
			{
				navigation_routerating(wp, ratingscale, 10000);
				found = TRUE;
			}
		}

		// Nothing found, rate the controlpoint itself
		if not(found)
			navigation_routerating(cp, ratingscale, 10000);
	}
}

float havocbot_goalrating_ons_generator_attack(float ratingscale)
{
	entity g, wp, bestwp;
	float found, best;

	for (g = findchain(classname, "onslaught_generator"); g; g = g.chain)
	{
		if(g.team == self.team || g.isshielded)
			continue;

		// Should be attacked
		// Rate waypoints near it
		found = FALSE;
		bestwp = world;
		best = 99999999999;

		for(wp=findradius(g.origin,400); wp; wp=wp.chain)
		{
			if(wp.classname=="waypoint")
			if(checkpvs(wp.origin,g))
			{
				found = TRUE;
				if(wp.cnt<best)
				{
					bestwp = wp;
					best = wp.cnt;
				}
			}
		}

		if(bestwp)
		{
		//	dprint("waypoints found around generator\n");
			navigation_routerating(bestwp, ratingscale, 10000);
			bestwp.cnt += 1;

			self.havocbot_attack_time = 0;
			if(checkpvs(self.view_ofs,g))
			if(checkpvs(self.view_ofs,bestwp))
				self.havocbot_attack_time = time + 5;

			return TRUE;
		}
		else
		{
		//	dprint("generator found without waypoints around\n");
			// if there aren't waypoints near the generator go straight to it
			navigation_routerating(g, ratingscale, 10000);
			self.havocbot_attack_time = 0;
			return TRUE;
		}
	}
	return FALSE;
}

void havocbot_role_ons_offense()
{
	if(self.deadflag != DEAD_NO)
	{
		self.havocbot_attack_time = 0;
		havocbot_ons_reset_role(self);
		return;
	}

	// Set the role timeout if necessary
	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + 120;

	if (time > self.havocbot_role_timeout)
	{
		havocbot_ons_reset_role(self);
		return;
	}

	if(self.havocbot_attack_time>time)
		return;

	if (self.bot_strategytime < time)
	{
		navigation_goalrating_start();
		havocbot_goalrating_enemyplayers(20000, self.origin, 650);
		if(!havocbot_goalrating_ons_generator_attack(20000))
			havocbot_goalrating_ons_controlpoints_attack(20000);
		havocbot_goalrating_ons_offenseitems(10000, self.origin, 10000);
		navigation_goalrating_end();

		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
	}
}

void havocbot_role_ons_assistant()
{
	havocbot_ons_reset_role(self);
}

void havocbot_role_ons_defense()
{
	havocbot_ons_reset_role(self);
}

void havocbot_ons_reset_role(entity bot)
{
	entity head;
	float c;

	if(self.deadflag != DEAD_NO)
		return;

	bot.havocbot_ons_target = world;

	// TODO: Defend control points or generator if necessary

	// if there is only me on the team switch to offense
	c = 0;
	FOR_EACH_PLAYER(head)
	if(head.team==self.team)
		++c;

	if(c==1)
	{
		havocbot_role_ons_setrole(bot, HAVOCBOT_ONS_ROLE_OFFENSE);
		return;
	}

	havocbot_role_ons_setrole(bot, HAVOCBOT_ONS_ROLE_OFFENSE);
}

void havocbot_chooserole_ons()
{
	havocbot_ons_reset_role(self);
}
