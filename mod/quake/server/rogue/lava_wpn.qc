#include "lava_wpn.qh"

/*
===============
launch_lava_spike

Used for both the player and the ogre
===============
*/
void lavaspike_touch(entity this, entity toucher);
entity launch_lava_spike(entity this, vector org, vector dir)
{
	entity newmis = new(lava_spike);
	newmis.owner = this;
	set_movetype(newmis, MOVETYPE_FLYMISSILE);
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	settouch(newmis, lavaspike_touch);
	setthink(newmis, SUB_Remove);
	newmis.nextthink = time + 6;
	_setmodel(newmis, "progs/lspike.mdl");	
	setsize(newmis, '0 0 0', '0 0 0');		
	setorigin(newmis, org);

	newmis.velocity = dir * 1000;

	return newmis;
}

// =============== Lava Spike Touch Routines

void lavaspike_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
// hit something that bleeds
	if(toucher.takedamage)
	{
		spawn_touchblood(this, 9, toucher);
		if(IS_PLAYER(toucher))
		{
			float old_armortype = toucher.armortype;
			float old_armorvalue = toucher.armorvalue;
			int old_armormask = toucher.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
			toucher.armortype = 0;
			toucher.armorvalue = 0;
			T_Damage(toucher, this, this.owner, 9, this.projectiledeathtype);
			toucher.armortype = old_armortype;
			toucher.armorvalue = old_armorvalue;
			toucher.items |= old_armormask;
		}
		else		// is a monster
		{
			if(toucher.monsterdef != MON_LAVAMAN)
				T_Damage(toucher, this, this.owner, 15, this.projectiledeathtype);
		}
	}
	else
	{
		if(this.classname == "wizard_spike")
			te_wizspike(this.origin);
		else if(this.classname == "knight_spike")
			te_knightspike(this.origin);
		else
			te_spike(this.origin);
	}

	delete(this);
}

void superlavaspike_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
// hit something that bleeds
	if(toucher.takedamage)
	{
		spawn_touchblood(this, 18, toucher);
		
		// halve the effectiveness of the armor for players..
		if(IS_PLAYER(toucher))
		{
			// save the old armor values...
			float old_armortype = toucher.armortype;
//			old_armorvalue = toucher.armorvalue;
			toucher.armortype = toucher.armortype * 0.5;
//			toucher.armorvalue = 0;
			T_Damage(toucher, this, this.owner, 18, this.projectiledeathtype);
			
			// if the damage didn't wipe out the armor, armortype 
			if(toucher.armortype != 0)
			{
				toucher.armortype = old_armortype;
//				toucher.armorvalue = old_armorvalue;
			}
		}
		else		// is a monster, do 50% more damage
		{
			if(toucher.monsterdef != MON_LAVAMAN)
			{
				T_Damage(toucher, this, this.owner, 30, this.projectiledeathtype);
			}
		}
	}
	else
		te_superspike(this.origin);

	delete(this);
}
