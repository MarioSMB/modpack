#include "main.qh"

#include "../subs/_mod.qh"

void prydon_StartFrame()
{
	if(world.map)
	{
		if(mplayer)
		{
			if(time > 2)
			{
				if(fileaccess)
				{
					gamestate_load();
					changelevel(nextmap);
				}
			}
			return;
		}
		total_monsters = rint(monsvalue);
		if(mapname == "save")
		{
			if(time > 3)
				changelevel("curig2");
			return;
		}
		if(time > 3)
		{
			serverflags = recode(serverflags, 3, 1); // Quick and Dirty Harb fix
			changelevel(world.map);
		}
	}
	else
	{
		QueryDayNight();
		
		dovis();
		serverflags = recode(serverflags, 1, mainstory);

	}
	float timelimit = autocvar_timelimit;
	if(timelimit)
		if(time > timelimit*60)
			changelevel(mapname);

	serverflags = recode(serverflags, 2, averagelvl);
}
