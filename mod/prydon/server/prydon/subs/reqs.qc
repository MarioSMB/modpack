
float(entity e) CheckStory =
{
	local float story;
	
	if (!e)
		return 1;
		
	story = getstorylevel(e);

	if (e.story_min > story)
		return -1;
	if (e.story_max)
	{
		if (e.story_max <= story)
			return 1;
	}
	if (e.worldtype && (e.worldtype != lastmap))
		return 1;
	return 0;
};
float (float n1, float n2, float flg) ck_minimum =
{
	if (!n1)
		return 0;
	if (flg)
	{
		if ((n1 & n2) == n1)
			return 0;
		else
			return 1;
	}
	else
	{
		if (n2 > n1)
			return 0;
		else
			return 1;
	}
};

float (float n1, float n2, float flg) ck_maximum =
{
	if (!n1)
		return 0;
	if (flg)
	{
		if (n2 - (n1 & n2))
			return 1;
		else
			return 0;
	}
	else
	{
		if (n1 > n2)
			return 0;
		else
			return 1;
	}

};
float (float n1, float n2, float flg) ck_equals =
{
	if (!n1)
		return 0;
	if (n1 == n2)
		return 0;
	else
		return 1;
};
float(entity test, entity req) TestRequirements =
{
	test = test.owner;
	// style: min, max, equal.
	if (!(float)(req.req_field))
		return FALSE;
	else if (req.spawnflags & 1)
		return ck_maximum(req.req_value, test.(req.req_field), req.spawnflags & 4);
	else if (req.spawnflags & 2)
		return ck_minimum(req.req_value, test.(req.req_field), req.spawnflags & 4);
	else
		return ck_equals(req.req_value, test.(req.req_field), req.spawnflags & 4);

};
float (entity sub, entity test) RequirementsMet =
{
	local entity o;
	
	if (test.owner)
		test = test.owner;
		
	if (CheckStory(sub))
	{
		dprint("story failed\n");
		return FALSE;
	}
	else if (!test)
		return TRUE;
	else if (sub.req_str && test.str < sub.req_str)
	{
		dprint("not enough strength\n");
		return FALSE;
	}
	else if (sub.req_mag && test.mag < sub.req_mag)
	{
		dprint("not enough intelligence\n");
		return FALSE;
	}
	else if (sub.req_dex && test.dex < sub.req_dex)
	{
		dprint("not enough dex\n");
		return FALSE;
	}
	else if (sub.req_lvl && test.lvl < sub.req_lvl)
	{
		dprint("not enough level\n");
		return FALSE;
	}
	else if (sub.req_class != '0 0 0' && test.title_y != sub.req_class_y)
	{
		dprint("incorrect class\n");
		return FALSE;
	}
	if (sub.req_item)
	{
		if (!hassomething(sub.req_item, test))
		{
			dprint("missing item\n");
			return FALSE;
		}
	}
	if (sub.req_field)
	{
		if (TestRequirements(test, sub))
		{
			dprint("Complex requirements failed\n");
			return FALSE;
		}
	}
	
	if (sub.requirements)
	{
		o = find(world, targetname, sub.requirements);
		while(o)
		{
		 	if (!RequirementsMet(o, test))
		 	{
		 		dprint("foster requirements failed\n");
				return FALSE;
			}
			o = find(o, targetname, sub.requirements);
		}
	}
	//dprint("passed\n");
	return TRUE;
};
