#define HAVOCBOT_AST_ROLE_NONE 		0
#define HAVOCBOT_AST_ROLE_DEFENSE	2
#define HAVOCBOT_AST_ROLE_OFFENSE	4

.float havocbot_role_flags;
.float havocbot_attack_time;

.void() havocbot_role;
.void() havocbot_previous_role;

void() havocbot_role_ast_defense;
void() havocbot_role_ast_offense;
.entity havocbot_ast_target;

void(entity bot) havocbot_ast_reset_role;

void(float ratingscale, vector org, float sradius) havocbot_goalrating_items;
void(float ratingscale, vector org, float sradius) havocbot_goalrating_enemyplayers;

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

		if not(ad.bot_attack)
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

	if(bot.team==assault_attacker_team)
		havocbot_role_ast_setrole(bot, HAVOCBOT_AST_ROLE_OFFENSE);
	else
		havocbot_role_ast_setrole(bot, HAVOCBOT_AST_ROLE_DEFENSE);
}

void havocbot_chooserole_ast()
{
	havocbot_ast_reset_role(self);
}
