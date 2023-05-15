

void() gamestate_save =
{
	qopenwrite("gamestate.pgg");
	qwrite(ftos(SAVE_VERSION));
	qwrite(ftos(averagelvl));
	qwrite(ftos(lastmap));
	qwrite(ftos(runtime));

	qwrite(mapname);
	writedata();

	qclose();
	bprint("Gamestate saved\n");
};

void() gamestate_load =
{
	float version;

	qopenread("gamestate.pgg");
	version = stof(qread());
	if (version != SAVE_VERSION)
	{
		fileerror = 1;
		qclose();
	}
	//mainstory = stof(qread());
	averagelvl = stof(qread());
	lastmap = stof(qread());
	runtime = stof(qread());
	nextmap = strzone(qread());
	readdata();

	if (fileerror)
		nextmap = "curig2";	
	else
		qclose();
	savedata();
};



void(float cost) InnSave =
{
	local entity oself;
	oself = self;
	self = other;
	if (self.owner)
		self = self.owner;
	if (mplayer)
	{
		if (!getgold(cost))
			prompt(self, "You don't have enough gold", activator, 0);
		else
		{
			self.health = self.max_health;
			self.mana = self.max_mana;
			if (fileaccess)
				gamestate_save();
			closemenu(self);
		}
	}
	else
	{
		if (!getgold(cost))
			prompt(self, "You don't have enough gold", activator, 0);
		else
		{
			self.health = self.max_health;
			self.mana = self.max_mana;
		//	if (fileaccess)
		//		gamestate_save();
			self.fade = -250;
			closemenu(self);
			nextmap = activator.map;
		}
	}
	self = oself;
};