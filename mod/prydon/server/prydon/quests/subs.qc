// 0 if it works
// -1 if we're below minimum / not done
// 1 if we're above max / done

// dummy for ents




float (string n) getstorybyname =
{
	local entity z;
	local float f;
	

	z = find(world, classname, "quest");
	while (z)
	{
		if ((z.story_name == n) || (z.targetname == n))
			return z.lip;
		z = find(z, classname, "quest");
	}

	f = GetOldStory(n, 0);
	spawnstory(f, n, n);
	return f;
};

float(entity e) getstorylevel =
{

	if (!e.story_name)
	{
		// try to auto detect old story ents
		if (e.lip > 15)
			e.story_name = "opt1";
		else if (e.story_min > 15)
			e.story_name = "opt1";
		else if (e.story_max > 15)
			e.story_name = "opt1";
		else
			e.story_name = "main";
	}
	return getstorybyname(e.story_name);
	
};

float(entity e, float story) setstorylevel =
{
	local entity z;
	local float n, found;

	n = getstorylevel(e);

	z = find(world, classname, "quest");
	while (z)
	{
		if (z.story_name == e.story_name)
		{
			if (z.story_name == "main")
				mainstory = story; // hack
			z.lip = story;
			found = 1;
		}
		z = find(z, classname, "quest");
	}
	if (!found)
		spawnstory(story, e.story_name, e.story_name);
	
	if (story != n)
		return TRUE;
	else
		return FALSE;
};

void() quest_update =
{
	local entity e;
	
	e = find(world, classname, "player");
	while(e)
	{
		e.questlog = 1;
		e.quest_time = time + 1;
		e = find(e, classname, "player");
	}	

};

string(entity e) getqueststring =
{
	local float lev;
	
	lev = getstorylevel(e);
	if (lev < e.impulse)
		return string_null;
	lev = lev - e.impulse;
	
	if (lev == 0)
		return e.message;
	else if (lev == 1)
		return e.message1;
	else if (lev == 2)
		return e.message2;
	else if (lev == 3)
		return e.message3;
	else if (lev == 4)
		return e.message4;
	else if (lev == 5)
		return e.message5;
	else if (lev == 6)
		return e.message6;
	else if (lev == 7)
		return e.message7;
	else if (lev == 8)
		return e.message8;
	else
		return string_null;
};