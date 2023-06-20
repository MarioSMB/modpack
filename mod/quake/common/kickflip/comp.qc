#include "comp.qh"

#ifdef SVQC
void comp_start(entity this)
{
	if(!skate_active)
	{
		delete(this);
		return;
	}
	comp_started = true;
	comp_timelimit = time + 120;		//2 minutes

//reset frags to 0!!!
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		it.frags = 0;
	});
//all frags reset

	Send_Notification(NOTIF_ALL, NULL, MSG_MULTI, COMPETITION_START);
}


void comp_check_time()
{
	if(!comp_started)
		return;

	if(comp_timelimit < time)	//time is over
	{
		entity best = NULL; 
		FOREACH_CLIENT(IS_PLAYER(it),
		{
			if(!best || it.frags > best.frags)
				best = it;
		});
		if(best)
			bprintf("\n\n%s is the winner!\n", best.netname);
		mapname = "kfqstart";
		NextLevel();
		comp_started = false;
	}
}

STATIC_INIT_LATE(comp_init)
{
	entity comp = new(comp);
	setthink(comp, comp_start);
	comp.nextthink = time + 5;
}

#endif
