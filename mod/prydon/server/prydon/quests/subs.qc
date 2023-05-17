#include "subs.qh"

#include "index.qh"
#include "quest.qh"

// 0 if it works
// -1 if we're below minimum / not done
// 1 if we're above max / done

// dummy for ents

float getstorybyname(string n)
{
	entity z = find(NULL, classname, "quest");
	while(z)
	{
		if((z.story_name == n) || (z.targetname == n))
			return z.lip;
		z = find(z, classname, "quest");
	}

	float f = GetOldStory(n, 0);
	spawnstory(f, n, n);
	return f;
}

float getstorylevel(entity e)
{

	if(!e.story_name)
	{
		// try to auto detect old story ents
		if(e.lip > 15)
			e.story_name = "opt1";
		else if(e.story_min > 15)
			e.story_name = "opt1";
		else if(e.story_max > 15)
			e.story_name = "opt1";
		else
			e.story_name = "main";
	}
	return getstorybyname(e.story_name);
}

float setstorylevel(entity e, float story)
{
	bool found = false;
	float n = getstorylevel(e);
	entity z = find(NULL, classname, "quest");
	while(z)
	{
		if(z.story_name == e.story_name)
		{
			if(z.story_name == "main")
				mainstory = story; // hack
			z.lip = story;
			found = true;
		}
		z = find(z, classname, "quest");
	}
	if(!found)
		spawnstory(story, e.story_name, e.story_name);
	
	return (story != n);
}

void quest_update()
{
	entity e = find(NULL, classname, "player");
	while(e)
	{
		e.questlog = 1;
		e.quest_time = time + 1;
		e = find(e, classname, "player");
	}
}

string getqueststring(entity e)
{
	float lev = getstorylevel(e);
	if(lev < e.impulse)
		return string_null;
	lev -= e.impulse;
	
	if(lev == 0)
		return e.message;
	else if(lev == 1)
		return e.message1;
	else if(lev == 2)
		return e.message2;
	else if(lev == 3)
		return e.message3;
	else if(lev == 4)
		return e.message4;
	else if(lev == 5)
		return e.message5;
	else if(lev == 6)
		return e.message6;
	else if(lev == 7)
		return e.message7;
	else if(lev == 8)
		return e.message8;
	else
		return string_null;
}
