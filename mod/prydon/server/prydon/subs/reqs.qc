#include "reqs.qh"

#include "subs.qh"

int CheckStory(entity e)
{
	if(!e)
		return 1;
		
	int story = getstorylevel(e);

	if(e.story_min > story)
		return -1;
	if(e.story_max)
	{
		if(e.story_max <= story)
			return 1;
	}
	if(e.worldtype && (e.worldtype != lastmap))
		return 1;
	return 0;
}

bool ck_minimum(float n1, float n2, float flg)
{
	if(!n1)
		return false;
	if(flg)
	{
		if((n1 & n2) == n1)
			return false;
		else
			return true;
	}
	else
	{
		if(n2 > n1)
			return false;
		else
			return true;
	}
}

bool ck_maximum(float n1, float n2, float flg)
{
	if(!n1)
		return false;
	if(flg)
	{
		if(n2 - (n1 & n2))
			return true;
		else
			return false;
	}
	else
	{
		if(n1 > n2)
			return false;
		else
			return true;
	}

}

bool ck_equals(float n1, float n2, float flg)
{
	if(!n1)
		return false;
	if(n1 == n2)
		return false;
	else
		return true;
}

bool TestRequirements(entity test, entity req)
{
	test = test.owner;
	// style: min, max, equal.
	if(req.req_field == nil)
		return false;
	else if(req.spawnflags & 1)
		return ck_maximum(req.req_value, test.(req.req_field), req.spawnflags & 4);
	else if(req.spawnflags & 2)
		return ck_minimum(req.req_value, test.(req.req_field), req.spawnflags & 4);
	else
		return ck_equals(req.req_value, test.(req.req_field), req.spawnflags & 4);

}

bool RequirementsMet(entity sub, entity test)
{
	if(test.owner)
		test = test.owner;
		
	if(CheckStory(sub))
	{
		LOG_DEBUG("story failed");
		return false;
	}
	else if(!test)
		return true;
	else if(sub.req_str && test.str < sub.req_str)
	{
		LOG_DEBUG("not enough strength");
		return false;
	}
	else if(sub.req_mag && test.mag < sub.req_mag)
	{
		LOG_DEBUG("not enough intelligence");
		return false;
	}
	else if(sub.req_dex && test.dex < sub.req_dex)
	{
		LOG_DEBUG("not enough dex");
		return false;
	}
	else if(sub.req_lvl && test.lvl < sub.req_lvl)
	{
		LOG_DEBUG("not enough level");
		return false;
	}
	else if(sub.req_class != '0 0 0' && test.title_y != sub.req_class_y)
	{
		LOG_DEBUG("incorrect class");
		return false;
	}
	if(sub.req_item)
	{
		if(!hassomething(sub.req_item, test))
		{
			LOG_DEBUG("missing item");
			return false;
		}
	}
	if(sub.req_field)
	{
		if(TestRequirements(test, sub))
		{
			LOG_DEBUG("Complex requirements failed");
			return false;
		}
	}
	
	if(sub.requirements)
	{
		entity o = find(NULL, targetname, sub.requirements);
		while(o)
		{
		 	if(!RequirementsMet(o, test))
		 	{
		 		LOG_DEBUG("foster requirements failed");
				return false;
			}
			o = find(o, targetname, sub.requirements);
		}
	}
	//LOG_DEBUG("passed\n");
	return true;
}
