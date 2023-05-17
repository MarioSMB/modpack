#include "questitem.qh"

entity get_questitem(float n)
{
	entity e = find(NULL, classname, "questitem");
	while(e)
	{
		if(e.slot1_x == n)
			return e;
		e = find(e, classname, "questitem");
	}

	return NULL;
}

spawnfunc(questitem)
{
	if(this.items)
	{
		this.slot1 = legacy_itemv1(this.items);
		this.items = this.slot1_x;
		if(this.spell > 16)
			this.spell = this.spell + 8;
		if(this.gotstuff > 16)
			this.gotstuff = this.gotstuff + 8;
	}
	entity e = get_questitem(this.slot1_x);
	if(e && e != this)
		delete(e);
	if(cache)
	{
		precache_model(this.model);
		precache_sound(this.noise);
	}
}
