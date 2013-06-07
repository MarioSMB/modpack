#define HAVOCBOT_CTF_ROLE_NONE 		0
#define HAVOCBOT_CTF_ROLE_DEFENSE	2
#define HAVOCBOT_CTF_ROLE_MIDDLE	4
#define HAVOCBOT_CTF_ROLE_OFFENSE	8
#define HAVOCBOT_CTF_ROLE_CARRIER	16
#define HAVOCBOT_CTF_ROLE_RETRIEVER	32
#define HAVOCBOT_CTF_ROLE_ESCORT	64

.void() havocbot_role;
.void() havocbot_previous_role;

void() havocbot_role_ctf_middle;
void() havocbot_role_ctf_defense;
void() havocbot_role_ctf_offense;
void() havocbot_role_ctf_carrier;
void() havocbot_role_ctf_retriever;
void() havocbot_role_ctf_escort;

void(entity bot) havocbot_ctf_reset_role;
void(float ratingscale, vector org, float sradius) havocbot_goalrating_items;
void(float ratingscale, vector org, float sradius) havocbot_goalrating_enemyplayers;

.float havocbot_cantfindflag;
.float havocbot_role_timeout;
.entity ctf_worldflagnext;
.entity bot_basewaypoint;

entity ctf_worldflaglist;
vector havocbot_ctf_middlepoint;
float havocbot_ctf_middlepoint_radius;

entity havocbot_ctf_find_flag(entity bot)
{
	entity f;
	f = ctf_worldflaglist;
	while (f)
	{
		if (bot.team == f.team)
			return f;
		f = f.ctf_worldflagnext;
	}
	return world;
}

entity havocbot_ctf_find_enemy_flag(entity bot)
{
	entity f;
	f = ctf_worldflaglist;
	while (f)
	{
		if (bot.team != f.team)
			return f;
		f = f.ctf_worldflagnext;
	}
	return world;
}

float havocbot_ctf_teamcount(entity bot, vector org, float radius)
{
	if not(teamplay)
		return 0;

	float c = 0;
	entity head;

	FOR_EACH_PLAYER(head)
	{
		if(head.team!=bot.team || head.deadflag != DEAD_NO || head == bot)
			continue;

		if(vlen(head.origin - org) < radius)
			++c;
	}

	return c;
}

void havocbot_goalrating_ctf_ourflag(float ratingscale)
{
	entity head;
	head = ctf_worldflaglist;
	while (head)
	{
		if (self.team == head.team)
			break;
		head = head.ctf_worldflagnext;
	}
	if (head)
		navigation_routerating(head, ratingscale, 10000);
}

void havocbot_goalrating_ctf_ourbase(float ratingscale)
{
	entity head;
	head = ctf_worldflaglist;
	while (head)
	{
		if (self.team == head.team)
			break;
		head = head.ctf_worldflagnext;
	}
	if not(head)
		return;

	navigation_routerating(head.bot_basewaypoint, ratingscale, 10000);
}

void havocbot_goalrating_ctf_enemyflag(float ratingscale)
{
	entity head;
	head = ctf_worldflaglist;
	while (head)
	{
		if (self.team != head.team)
			break;
		head = head.ctf_worldflagnext;
	}
	if (head)
		navigation_routerating(head, ratingscale, 10000);
}

void havocbot_goalrating_ctf_enemybase(float ratingscale)
{
	if not(bot_waypoints_for_items)
	{
		havocbot_goalrating_ctf_enemyflag(ratingscale);
		return;
	}

	entity head;

	head = havocbot_ctf_find_enemy_flag(self);

	if not(head)
		return;

	navigation_routerating(head.bot_basewaypoint, ratingscale, 10000);
}

void havocbot_goalrating_ctf_ourstolenflag(float ratingscale)
{
	entity mf;

	mf = havocbot_ctf_find_flag(self);

	if(mf.ctf_status == FLAG_BASE)
		return;

	if(mf.tag_entity)
		navigation_routerating(mf.tag_entity, ratingscale, 10000);
}

void havocbot_goalrating_ctf_droppedflags(float ratingscale, vector org, float radius)
{
	entity head;
	head = ctf_worldflaglist;
	while (head)
	{
		// flag is out in the field
		if(head.ctf_status != FLAG_BASE)
		if(head.tag_entity==world)	// dropped
		{
			if(radius)
			{
				if(vlen(org-head.origin)<radius)
					navigation_routerating(head, ratingscale, 10000);
			}
			else
				navigation_routerating(head, ratingscale, 10000);
		}

		head = head.ctf_worldflagnext;
	}
}

void havocbot_goalrating_ctf_carrieritems(float ratingscale, vector org, float sradius)
{
	entity head;
	float t;
	head = findchainfloat(bot_pickup, TRUE);
	while (head)
	{
		// gather health and armor only
		if (head.solid)
		if (head.health || head.armorvalue)
		if (vlen(head.origin - org) < sradius)
		{
			// get the value of the item
			t = head.bot_pickupevalfunc(self, head) * 0.0001;
			if (t > 0)
				navigation_routerating(head, t * ratingscale, 500);
		}
		head = head.chain;
	}
}

void havocbot_role_ctf_setrole(entity bot, float role)
{
	dprint(strcat(bot.netname," switched to "));
	switch(role)
	{
		case HAVOCBOT_CTF_ROLE_CARRIER:
			dprint("carrier");
			bot.havocbot_role = havocbot_role_ctf_carrier;
			bot.havocbot_role_timeout = 0;
			bot.havocbot_cantfindflag = time + 10;
			bot.bot_strategytime = 0;
			break;
		case HAVOCBOT_CTF_ROLE_DEFENSE:
			dprint("defense");
			bot.havocbot_role = havocbot_role_ctf_defense;
			bot.havocbot_role_timeout = 0;
			break;
		case HAVOCBOT_CTF_ROLE_MIDDLE:
			dprint("middle");
			bot.havocbot_role = havocbot_role_ctf_middle;
			bot.havocbot_role_timeout = 0;
			break;
		case HAVOCBOT_CTF_ROLE_OFFENSE:
			dprint("offense");
			bot.havocbot_role = havocbot_role_ctf_offense;
			bot.havocbot_role_timeout = 0;
			break;
		case HAVOCBOT_CTF_ROLE_RETRIEVER:
			dprint("retriever");
			bot.havocbot_previous_role = bot.havocbot_role;
			bot.havocbot_role = havocbot_role_ctf_retriever;
			bot.havocbot_role_timeout = time + 10;
			bot.bot_strategytime = 0;
			break;
		case HAVOCBOT_CTF_ROLE_ESCORT:
			dprint("escort");
			bot.havocbot_previous_role = bot.havocbot_role;
			bot.havocbot_role = havocbot_role_ctf_escort;
			bot.havocbot_role_timeout = time + 30;
			bot.bot_strategytime = 0;
			break;
	}
	dprint("\n");
}

void havocbot_role_ctf_carrier()
{
	if(self.deadflag != DEAD_NO)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.flagcarried == world)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;

		navigation_goalrating_start();
		havocbot_goalrating_ctf_ourbase(50000);

		if(self.health<100)
			havocbot_goalrating_ctf_carrieritems(1000, self.origin, 1000);

		navigation_goalrating_end();

		if (self.navigation_hasgoals)
			self.havocbot_cantfindflag = time + 10;
		else if (time > self.havocbot_cantfindflag)
		{
			// Can't navigate to my own base, suicide!
			// TODO: drop it and wander around
			Damage(self, self, self, 100000, DEATH_KILL, self.origin, '0 0 0');
			return;
		}
	}
}

void havocbot_role_ctf_escort()
{
	entity mf, ef;

	if(self.deadflag != DEAD_NO)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.flagcarried)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_CARRIER);
		return;
	}

	// If enemy flag is back on the base switch to previous role
	ef = havocbot_ctf_find_enemy_flag(self);
	if(ef.ctf_status==FLAG_BASE)
	{
		self.havocbot_role = self.havocbot_previous_role;
		self.havocbot_role_timeout = 0;
		return;
	}

	// If the flag carrier reached the base switch to defense
	mf = havocbot_ctf_find_flag(self);
	if(mf.ctf_status!=FLAG_BASE)
	if(vlen(ef.origin - mf.dropped_origin) < 300)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_DEFENSE);
		return;
	}

	// Set the role timeout if necessary
	if (!self.havocbot_role_timeout)
	{
		self.havocbot_role_timeout = time + random() * 30 + 60;
	}

	// If nothing happened just switch to previous role
	if (time > self.havocbot_role_timeout)
	{
		self.havocbot_role = self.havocbot_previous_role;
		self.havocbot_role_timeout = 0;
		return;
	}

	// Chase the flag carrier
	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
		navigation_goalrating_start();
		havocbot_goalrating_ctf_enemyflag(30000);
		havocbot_goalrating_ctf_ourstolenflag(40000);
		havocbot_goalrating_items(10000, self.origin, 10000);
		navigation_goalrating_end();
	}
}

void havocbot_role_ctf_offense()
{
	entity mf, ef;
	vector pos;

	if(self.deadflag != DEAD_NO)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.flagcarried)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_CARRIER);
		return;
	}

	// Check flags
	mf = havocbot_ctf_find_flag(self);
	ef = havocbot_ctf_find_enemy_flag(self);

	// Own flag stolen
	if(mf.ctf_status!=FLAG_BASE)
	{
		if(mf.tag_entity)
			pos = mf.tag_entity.origin;
		else
			pos = mf.origin;

		// Try to get it if closer than the enemy base
		if(vlen(self.origin-ef.dropped_origin)>vlen(self.origin-pos))
		{
			havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_RETRIEVER);
			return;
		}
	}

	// Escort flag carrier
	if(ef.ctf_status!=FLAG_BASE)
	{
		if(ef.tag_entity)
			pos = ef.tag_entity.origin;
		else
			pos = ef.origin;

		if(vlen(pos-mf.dropped_origin)>700)
		{
			havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_ESCORT);
			return;
		}
	}

	// About to fail, switch to middlefield
	if(self.health<50)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_MIDDLE);
		return;
	}

	// Set the role timeout if necessary
	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + 120;

	if (time > self.havocbot_role_timeout)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
		navigation_goalrating_start();
		havocbot_goalrating_ctf_ourstolenflag(50000);
		havocbot_goalrating_ctf_enemybase(20000);
		havocbot_goalrating_items(5000, self.origin, 1000);
		havocbot_goalrating_items(1000, self.origin, 10000);
		navigation_goalrating_end();
	}
}

// Retriever (temporary role):
void havocbot_role_ctf_retriever()
{
	entity mf;

	if(self.deadflag != DEAD_NO)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.flagcarried)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_CARRIER);
		return;
	}

	// If flag is back on the base switch to previous role
	mf = havocbot_ctf_find_flag(self);
	if(mf.ctf_status==FLAG_BASE)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + 20;

	if (time > self.havocbot_role_timeout)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.bot_strategytime < time)
	{
		float radius;
		radius = 10000;

		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
		navigation_goalrating_start();
		havocbot_goalrating_ctf_ourstolenflag(50000);
		havocbot_goalrating_ctf_droppedflags(40000, self.origin, radius);
		havocbot_goalrating_ctf_enemybase(30000);
		havocbot_goalrating_items(500, self.origin, radius);
		navigation_goalrating_end();
	}
}

void havocbot_role_ctf_middle()
{
	entity mf;

	if(self.deadflag != DEAD_NO)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.flagcarried)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_CARRIER);
		return;
	}

	mf = havocbot_ctf_find_flag(self);
	if(mf.ctf_status!=FLAG_BASE)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_RETRIEVER);
		return;
	}

	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + 10;

	if (time > self.havocbot_role_timeout)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.bot_strategytime < time)
	{
		vector org;

		org = havocbot_ctf_middlepoint;
		org_z = self.origin_z;

		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
		navigation_goalrating_start();
		havocbot_goalrating_ctf_ourstolenflag(50000);
		havocbot_goalrating_ctf_droppedflags(30000, self.origin, 10000);
		havocbot_goalrating_enemyplayers(10000, org, havocbot_ctf_middlepoint_radius * 0.5);
		havocbot_goalrating_items(5000, org, havocbot_ctf_middlepoint_radius * 0.5);
		havocbot_goalrating_items(2500, self.origin, 10000);
		havocbot_goalrating_ctf_enemybase(2500);
		navigation_goalrating_end();
	}
}

void havocbot_role_ctf_defense()
{
	entity mf;

	if(self.deadflag != DEAD_NO)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.flagcarried)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_CARRIER);
		return;
	}

	// If own flag was captured
	mf = havocbot_ctf_find_flag(self);
	if(mf.ctf_status!=FLAG_BASE)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_RETRIEVER);
		return;
	}

	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + 30;

	if (time > self.havocbot_role_timeout)
	{
		havocbot_ctf_reset_role(self);
		return;
	}
	if (self.bot_strategytime < time)
	{
		float radius;
		vector org;

		org = mf.dropped_origin;
		radius = havocbot_ctf_middlepoint_radius;

		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
		navigation_goalrating_start();

		// if enemies are closer to our base, go there
		entity head, closestplayer = world;
		float distance, bestdistance = 10000;
		FOR_EACH_PLAYER(head)
		{
			if(head.deadflag!=DEAD_NO)
				continue;

			distance = vlen(org - head.origin);
			if(distance<bestdistance)
			{
				closestplayer = head;
				bestdistance = distance;
			}
		}

		if(closestplayer)
		if(closestplayer.team!=self.team)
		if(vlen(org - self.origin)>1000)
		if(checkpvs(self.origin,closestplayer)||random()<0.5)
			havocbot_goalrating_ctf_ourbase(30000);

		havocbot_goalrating_ctf_ourstolenflag(20000);
		havocbot_goalrating_ctf_droppedflags(20000, org, radius);
		havocbot_goalrating_enemyplayers(15000, org, radius);
		havocbot_goalrating_items(10000, org, radius);
		havocbot_goalrating_items(5000, self.origin, 10000);
		navigation_goalrating_end();
	}
}

void havocbot_calculate_middlepoint()
{
	entity f;
	vector s = '0 0 0';
	vector fo = '0 0 0';
	float n = 0;

	f = ctf_worldflaglist;
	while (f)
	{
		fo = f.origin;
		s = s + fo;
		f = f.ctf_worldflagnext;
	}
	if(!n)
		return;
	havocbot_ctf_middlepoint = s * (1.0 / n);
	havocbot_ctf_middlepoint_radius	 = vlen(fo - havocbot_ctf_middlepoint);
}

void havocbot_ctf_reset_role(entity bot)
{
	float cdefense, cmiddle, coffense;
	entity mf, ef, head;
	float c;

	if(bot.deadflag != DEAD_NO)
		return;

	if(vlen(havocbot_ctf_middlepoint)==0)
		havocbot_calculate_middlepoint();

	// Check ctf flags
	if (bot.flagcarried)
	{
		havocbot_role_ctf_setrole(bot, HAVOCBOT_CTF_ROLE_CARRIER);
		return;
	}

	mf = havocbot_ctf_find_flag(bot);
	ef = havocbot_ctf_find_enemy_flag(bot);

	// Retrieve stolen flag
	if(mf.ctf_status!=FLAG_BASE)
	{
		havocbot_role_ctf_setrole(bot, HAVOCBOT_CTF_ROLE_RETRIEVER);
		return;
	}

	// If enemy flag is taken go to the middle to intercept pursuers
	if(ef.ctf_status!=FLAG_BASE)
	{
		havocbot_role_ctf_setrole(bot, HAVOCBOT_CTF_ROLE_MIDDLE);
		return;
	}

	// if there is only me on the team switch to offense
	c = 0;
	FOR_EACH_PLAYER(head)
	if(head.team==bot.team)
		++c;

	if(c==1)
	{
		havocbot_role_ctf_setrole(bot, HAVOCBOT_CTF_ROLE_OFFENSE);
		return;
	}

	// Evaluate best position to take
	// Count mates on middle position
	cmiddle = havocbot_ctf_teamcount(bot, havocbot_ctf_middlepoint, havocbot_ctf_middlepoint_radius * 0.5);

	// Count mates on defense position
	cdefense = havocbot_ctf_teamcount(bot, mf.dropped_origin, havocbot_ctf_middlepoint_radius * 0.5);

	// Count mates on offense position
	coffense = havocbot_ctf_teamcount(bot, ef.dropped_origin, havocbot_ctf_middlepoint_radius);

	if(cdefense<=coffense)
		havocbot_role_ctf_setrole(bot, HAVOCBOT_CTF_ROLE_DEFENSE);
	else if(coffense<=cmiddle)
		havocbot_role_ctf_setrole(bot, HAVOCBOT_CTF_ROLE_OFFENSE);
	else
		havocbot_role_ctf_setrole(bot, HAVOCBOT_CTF_ROLE_MIDDLE);
}

void havocbot_chooserole_ctf()
{
	havocbot_ctf_reset_role(self);
}
