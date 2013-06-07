void() havocbot_role_ka_carrier;
void() havocbot_role_ka_collector;
void() havocbot_chooserole_ka;

entity ka_ball;

// Keepaway
// If you don't have the ball, get it; if you do, kill people.

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

void havocbot_chooserole_ka()
{
	if (self.ballcarried)
		self.havocbot_role = havocbot_role_ka_carrier;
	else
		self.havocbot_role = havocbot_role_ka_collector;
}
