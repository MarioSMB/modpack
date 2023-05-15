
void() updateskins =
{
	if (self.misc & MISC_FULL_SKINS)
	{
		// fix me, hard coded hackage
		if (self.cold_time > time)
			self.skin = self.oldskin;
		else if (self.poison_count > 0 )
			self.skin = self.oldskin + 7;
		else
			self.skin = self.oldskin + 14;
	}
	else if (self.misc & MISC_NO_SKINS)
		self.skin = self.oldskin;
	else if (self.cold_time > time)
		self.skin = 0;
	else if (self.poison_count > 0 )
		self.skin = 1;
	else
		self.skin = 2 + self.oldskin;
};
