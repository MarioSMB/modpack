//.float(entity,entity) sort_cmp;
.entity sort_next, sort_prev;

entity Sort_Spawn()
{
	entity sort;
	sort = spawn();
	sort.sort_next = world;
	sort.chain = sort;
	return sort;
}
/*
entity Sort_New(float(entity,entity) cmp)
{
	entity sort;
	sort = spawn();
	sort.sort_cmp = cmp;
	sort.sort_next = world;
	sort.chain = sort;
	return sort;
}

void Sort_Remove(entity sort)
{
	entity next;
	while(sort.sort_next)
	{
		next = sort.sort_next;
		remove(sort);
		sort = next;
	}
	remove(sort);
}

void Sort_Add(entity sort, entity ent)
{
	entity next, parent;
	parent = sort;
	next = sort.sort_next;
	while(next)
	{
		if(!sort.sort_cmp(next, ent))
			break;
		parent = next;
		next = next.sort_next;
	}
	ent.sort_next = next;
	ent.sort_prev = parent;
	parent.sort_next = ent;
	if(next)
		next.sort_prev = ent;
}

void Sort_Reset(entity sort)
{
	sort.chain = sort;
}

float Sort_HasNext(entity sort)
{
	return (sort.chain.sort_next != world);
}

entity Sort_Next(entity sort)
{
	entity next;
	next = sort.chain.sort_next;
	if(!next) {
		next = spawn();
		sort.chain.sort_next = next;
		next.sort_prev = sort.chain;
		next.sort_next = world;
	}
	sort.chain = next;
	return next;
}

void Sort_Finish(entity sort)
{
	entity next;
	next = sort.chain;
	if(!next)
		return;

	while(next.sort_next)
	{
		sort = next.sort_next;
		next.sort_next = sort.sort_next;
		remove(sort);
	}
}

entity Sort_Get(entity sort, float i)
{
	for(; sort.sort_next && i > 0; --i)
		sort = sort.sort_next;
	return sort;
}
*/

/**
 * Swap two neighbours in a sortlist.
 * @param a FIRST entity
 * @param b entity after a
 */
#define SORT_SWAP(a,b)									\
	b.sort_prev = a.sort_prev;							\
	a.sort_next = b.sort_next;							\
	if(b.sort_next) b.sort_next.sort_prev = a;			\
	if(a.sort_prev) a.sort_prev.sort_next = b;			\
	a.sort_prev = b;									\
	b.sort_next = a

/*
void Sort_Erase(entity ent)
{
	ent.sort_prev.sort_next = ent.sort_next;
	if(ent.sort_next)
		ent.sort_next.sort_prev = ent.sort_prev;
	remove(ent);
}

void Sort_RemoveOld(entity sort)
{
	entity tmp;
	for(tmp = sort.sort_next; tmp; tmp = tmp.sort_next)
	{
		if(tmp.frame < time)
		{
			tmp = tmp.sort_prev;
			Sort_Erase(tmp.sort_next);
		}
	}
}
*/
