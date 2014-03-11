.float() cbc_func;
.entity cbc_next;
.float cbc_order;

entity CallbackChain_New(string name)
{
	entity e;
	e = spawn();
	e.classname = "callbackchain";
	e.netname = name;
	return e;
}

float CallbackChain_Add(entity cb, float() func, float order)
{
	entity e;
	if(order & CBC_ORDER_FIRST)
	{
		if(order & CBC_ORDER_LAST)
			if(cb.cbc_order & CBC_ORDER_ANY)
				return 0;
		if(cb.cbc_order & CBC_ORDER_FIRST)
			return 0;
	}
	else if(order & CBC_ORDER_LAST)
	{
		if(cb.cbc_order & CBC_ORDER_LAST)
			return 0;
	}
	entity thiscb;
	thiscb = spawn();
	thiscb.classname = "callback";
	thiscb.cbc_func = func;
	thiscb.cbc_order = order;
	if(order & CBC_ORDER_FIRST)
	{
		thiscb.cbc_next = cb.cbc_next;
		cb.cbc_next = thiscb;
	}
	else if(order & CBC_ORDER_LAST)
	{
		for(e = cb; e.cbc_next; e = e.cbc_next);
		e.cbc_next = thiscb;
	}
	else
	{
		// by default we execute last, but before a possible CBC_ORDER_LAST callback
		for(e = cb; e.cbc_next && !(e.cbc_next.cbc_order & CBC_ORDER_LAST); e = e.cbc_next); // we must make sure that we insert BEFORE an CBC_ORDER_LAST mutator!
		thiscb.cbc_next = e.cbc_next;
		e.cbc_next = thiscb;
	}
	cb.cbc_order |= (order | CBC_ORDER_ANY);
	return 1;
}

float CallbackChain_Remove(entity cb, float() func)
{
	float order;
	entity e;
	float n;
	n = 0;
	order = 0;
	for(e = cb; e.cbc_next; e = e.cbc_next)
	{
		while(e.cbc_next.cbc_func == func)
		{
			// remove e.cbc_next from the chain
			entity e2;
			e2 = e.cbc_next.cbc_next;
			remove(e.cbc_next);
			e.cbc_next = e2;
			++n;
		}
		// e.cbc_next is now something we want to keep
		order |= (e.cbc_next.cbc_order & CBC_ORDER_ANY);
	}
	cb.cbc_order = order;
	return n;
}

float CallbackChain_Call(entity cb)
{
	float r;
	entity e;
	r = 0;
	for(e = cb; e.cbc_next; e = e.cbc_next)
	{
		CallbackChain_ReturnValue = r;
		r |= e.cbc_next.cbc_func();
	}
	return r; // callbacks return an error status, so 0 is default return value
}

#define MAX_MUTATORS 15
string loaded_mutators[MAX_MUTATORS];
float Mutator_Add(mutatorfunc_t func, string name)
{
	float i, j;
	j = -1;
	for(i = 0; i < MAX_MUTATORS; ++i)
	{
		if(name == loaded_mutators[i])
			return 1; // already added
		if (!(loaded_mutators[i]))
			j = i;
	}
	if(j < 0)
	{
		backtrace("WARNING: too many mutators, cannot add any more\n");
		return 0;
	}
	loaded_mutators[j] = name;

	if(func(MUTATOR_ADDING) == 0)
	{
		// good
		return 1;
	}

	backtrace("WARNING: when adding mutator: adding failed, rolling back\n");

	if(func(MUTATOR_ROLLING_BACK) != 0)
	{
		// baaaaad
		error("WARNING: when adding mutator: rolling back failed");
	}
	return 0;
}
void Mutator_Remove(float(float) func, string name)
{
	float i;
	for(i = 0; i < MAX_MUTATORS; ++i)
		if(name == loaded_mutators[i])
			break;
	if(i >= MAX_MUTATORS)
	{
		backtrace("WARNING: removing not-added mutator\n");
		return;
	}
	loaded_mutators[i] = string_null;

	if(func(MUTATOR_REMOVING) != 0)
	{
		// baaaaad
		error("Mutator_Remove: removing mutator failed");
	}
}
