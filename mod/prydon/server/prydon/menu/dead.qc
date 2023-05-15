

void() m_dead =
{
	local float i;
	
	if (self.menu < 1)
		self.menu = 2;
	else if (self.menu > 2)
		self.menu = 1;

	if (self.button1)
	{
		self.button1 = 0;
		if (self.menu == 2 || mplayer)
		{
			closemenu(self);
			self.player = world;
			self.misc = self.misc | MISC_RESPAWN;
			PutClientInServer();
			self.health = self.max_health;			
			return;
		}
		else
		{
			closemenu(self);
			localcmd("restart\n");
		}
	}
	
	if (self.m_refresh >= time)
		return;
	if (mplayer)
	{
		centerprint(self, "You have perished.\n\n\{141}\[\1\] Naked run    \n");
	}
	else
	{
		if (self.menu == 1)
			centerprint(self, "You have perished.\n\n\{141}\[\1\] Restart level\n \[\2\] Naked run    \n");
		else
			centerprint(self, "You have perished.\n\n \[\1\] Restart level\n\{141}\[\2\] Naked run    \n");
	}
};