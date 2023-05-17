#include "ents.qh"

#include "subs.qh"

void storyup_use(entity this, entity actor, entity trigger)
{
	if(!trigger)
		return;
	float story = getstorylevel(this);
	
	if(this.lip)
		story += this.lip;
	else
		story += 1;
	if(setstorylevel(this, story))
		quest_update();
	delete(this);
}

spawnfunc(storyup)
{
	this.use = storyup_use;
}

void storyset_use(entity this, entity actor, entity trigger)
{
	float story;

	if(!trigger)
		return;

	if(this.spawnflags & 2)
		story = 0;
	else
		story = this.lip;
	if(setstorylevel(this, story))
		quest_update();
	delete(this);
}

spawnfunc(storyset)
{
	this.use = storyset_use;
}
