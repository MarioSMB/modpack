#include "saves.qh"

#include "data.qh"

void gamestate_save()
{
	qopenwrite("gamestate.pgg");
	qwrite(ftos(SAVE_VERSION));
	qwrite(ftos(averagelvl));
	qwrite(ftos(lastmap));
	qwrite(ftos(runtime));

	qwrite(mapname);
	writedata();

	qclose();
	bprint("Gamestate saved\n");
}

void gamestate_load()
{
	qopenread("gamestate.pgg");
	float version = stof(qread());
	if(version != SAVE_VERSION)
	{
		fileerror = 1;
		qclose();
	}
	//mainstory = stof(qread());
	averagelvl = stof(qread());
	lastmap = stof(qread());
	runtime = stof(qread());
	nextmap = strzone(qread());
	readdata();

	if(fileerror)
		nextmap = "curig2";	
	else
		qclose();
	savedata();
}

void InnSave(entity actor, entity trigger, float cost)
{
	if(trigger.owner)
		trigger = trigger.owner;
	if(mplayer)
	{
		if(!getgold(trigger, cost))
			prompt(trigger, "You don't have enough gold", actor, 0);
		else
		{
			trigger.health = trigger.max_health;
			trigger.mana = trigger.max_mana;
			if(fileaccess)
				gamestate_save();
			closemenu(trigger);
		}
	}
	else
	{
		if(!getgold(trigger, cost))
			prompt(trigger, "You don't have enough gold", actor, 0);
		else
		{
			trigger.health = trigger.max_health;
			trigger.mana = trigger.max_mana;
		//	if(fileaccess)
		//		gamestate_save();
			trigger.fade = -250;
			closemenu(trigger);
			nextmap = actor.map;
		}
	}
}
