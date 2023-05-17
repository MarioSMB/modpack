#include "quest.qh"

#include "index.qh"

spawnfunc(quest)
{
	//load stored values
	this.classname = "quest";

	if(!this.story_name)
	{
		// try to auto detect old story ents
		if(this.impulse > 15)
			this.story_name = "opt1";
		else if(this.story_min > 15)
			this.story_name = "opt1";
		else if(this.story_max > 15)
			this.story_name = "opt1";
		else
			this.story_name = "main";
		this.targetname = this.story_name;
	}
	
	this.lip = GetOldStory(this.targetname, this.lip);

	// remove redundant ents
	entity z = find(NULL, classname, "quest");
	while(z)
	{
		if(z != this)
		{
			if(this.targetname)
			{
				if(z.targetname == this.targetname)
				{
					if(this.impulse == z.impulse)
					{
						this.lip = z.lip;
						delete(z);
					}
				}
			}
			if(z.story_name == this.story_name)
			{
				if(this.impulse == z.impulse)
				{
					this.lip = z.lip;
					delete(z);
				}
			}
		}
		z = find(z, classname, "quest");
	}
	if(!fileaccess)
	{
		if(this.spawnflags & 1)
			this.lip = 0;
	}
}

void spawnstory(float lv, string name, string storage)
{
	entity e = spawn();
	e.lip = lv;
	e.story_name = name;
	e.targetname = storage;
	SetOldStory(storage, lv);
	spawnfunc_quest(e);
}
