void round_handler_Think()
{
	float f;

	if(time < game_starttime)
	{
		round_handler_Reset(game_starttime);
		return;
	}

	if(gameover)
	{
		round_handler_Reset(0);
		round_handler_Remove();
		return;
	}

	if(self.wait)
	{
		self.wait = FALSE;
		self.cnt = self.count + 1; // init countdown
		round_starttime = time + self.count;
		reset_map(TRUE);
	}

	if(self.cnt > 0) // countdown running
	{
		if(self.canRoundStart())
		{
			if(self.cnt == self.count + 1)
				round_starttime = time + self.count;
			f = self.cnt - 1;
			if(f == 0)
			{
				self.cnt = 0;
				self.round_endtime = (self.round_timelimit) ? time + self.round_timelimit : 0;
				self.nextthink = time;
				if(self.roundStart)
					self.roundStart();
				return;
			}
			self.cnt = self.cnt - 1;
		}
		else
		{
			round_handler_Reset(0);
		}
		self.nextthink = time + 1; // canRoundStart every second
	}
	else
	{
		if(self.canRoundEnd())
		{
			// schedule a new round
			self.wait = TRUE;
			self.nextthink = time + self.delay;
		}
		else
		{
			self.nextthink = time; // canRoundEnd every frame
		}
	}
}

void round_handler_Init(float the_delay, float the_count, float the_round_timelimit)
{
	round_handler.delay = (the_delay > 0) ? the_delay : 0;
	round_handler.count = fabs(floor(the_count));
	round_handler.cnt = round_handler.count + 1;
	round_handler.round_timelimit = (the_round_timelimit > 0) ? the_round_timelimit : 0;
}

// NOTE: this is only needed because if round_handler spawns at time 1
// gamestarttime isn't initialized yet
void round_handler_FirstThink()
{
	round_starttime = max(time, game_starttime) + round_handler.count;
	round_handler.think = round_handler_Think;
	round_handler.nextthink = max(time, game_starttime);
}

void round_handler_Spawn(float() canRoundStart_func, float() canRoundEnd_func, void() roundStart_func)
{
	if(round_handler)
	{
		backtrace("Can't spawn round_handler again!");
		return;
	}
	round_handler = spawn();
	round_handler.classname = "round_handler";

	round_handler.think = round_handler_FirstThink;
	round_handler.canRoundStart = canRoundStart_func;
	round_handler.canRoundEnd = canRoundEnd_func;
	round_handler.roundStart = roundStart_func;
	round_handler.wait = FALSE;
	round_handler_Init(5, 5, 180);
	round_handler.nextthink = time;
}

void round_handler_Reset(float next_think)
{
	round_handler.wait = FALSE;
	if(round_handler.count)
	if(round_handler.cnt < round_handler.count + 1)
		round_handler.cnt = round_handler.count + 1;
	round_handler.nextthink = next_think;
	round_starttime = (next_think) ? (next_think + round_handler.count) : -1;
}

void round_handler_Remove()
{
	remove(round_handler);
	round_handler = world;
}

