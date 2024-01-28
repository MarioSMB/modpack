#include "items.qh"

#ifdef SVQC
spawnfunc(item_tank)
{
	precache_model("progs/g_tank.mdl");
	_setmodel(this, "progs/g_tank.mdl");
	this.netname = "Tank";
	settouch(this, tankitem_touch);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

void tankitem_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher) || (toucher.items & IT_TANK) || toucher.health < 1 || STAT(SKATING, toucher) || STAT(SLIDE_ON, toucher))
		return;

	Tank_Spawn(toucher);

	Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, ITEM_TANK_GOT);

	if(deathmatch != 2 && !horde_ent)
	{
		this.model = string_null;
		this.solid = SOLID_NOT;

		this.nextthink = time + 20;
		setthink(this, SUB_regen);

		SUB_UseTargets(this, toucher, NULL);
	}
	else
	{
		setthink(this, SUB_Remove);
		this.nextthink = time;
	}
}
#endif
