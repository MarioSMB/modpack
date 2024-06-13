#include "oncount.qh"

#ifdef SVQC

int counter_GetCount(entity counter)
{
	if(counter.classname == "counter")
		return counter.state;

	return 0;
}

void oncount_use(entity this, entity actor, entity trigger)
{
	if(counter_GetCount(trigger) == this.count)
		SUB_UseTargets(this, actor, actor);
}

/*QUAKED func_oncount (0 0 0.5) (0 0 0) (16 16 16)
Must be used as the target for func_counter.  When the counter
reaches the value set by count, func_oncount triggers its targets.

"count" specifies the value to trigger on.  Default is 1.

"delay" how much time to wait before firing after being triggered.
*/

spawnfunc(func_oncount)
{
	this.count = floor(this.count);
	if(this.count <= 0)
		this.count = 1;

	this.classname = "oncount";
	this.use = oncount_use;
	setthink(this, func_null);
}

#endif
