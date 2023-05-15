void() storyup =
{
	local float story;
	
	self.use = storyup;
	if (other == world)
		return;
	story = getstorylevel(self);
	
	if (self.lip)
		story = story + self.lip;
	else
		story = story + 1;
	if (setstorylevel(self, story))
		quest_update();
	remove(self);
	
};

void() storyset =
{
	local float story;
	
	self.use = storyset;
	if (other == world)
		return;

	if (self.spawnflags & 2)
		story = 0;
	else
		story = self.lip;
	if (setstorylevel(self, story))
		quest_update();
	remove(self);
};
