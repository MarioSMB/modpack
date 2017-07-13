/* Items QuickC program
	By Jim Dose'  9/13/96
	Copyright (c)1996 Hipnotic Interactive, Inc.
	All rights reserved.
	Distributed (unsupported) on 3.12.97
*/

/*
===============================================================================

HIPNOTIC ITEMS

===============================================================================
*/
//
// hip_powerup_touch function
//
void hip_powerup_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;

	sprint(toucher, sprintf("You got the %s\n", this.netname));

	if(deathmatch)
	{
		this.mdl = this.model;

//      if((this.classname == "item_artifact_invulnerability") ||
//         (this.classname == "item_artifact_invisibility"))
//         this.nextthink = time + 60*5;
//      else
		this.nextthink = time + 60;

		setthink(this, SUB_regen);
	}

	_sound(toucher, CHAN_VOICE, this.noise, 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");
	this.solid = SOLID_NOT;
	toucher.items |= this.items;
	this.model = string_null;

// do the apropriate action
	if(this.classname == "item_artifact_wetsuit")
	{
		toucher.wetsuit_time = 1;
		toucher.wetsuit_finished = time + 30;
	}
	if(this.classname == "item_artifact_empathy_shields")
	{
		toucher.empathy_time = 1;
		toucher.empathy_finished = time + 30;
	}

	SUB_UseTargets(this, toucher, toucher); // fire all targets / killtargets
}


/*QUAKED item_artifact_wetsuit (0 .5 .8) (-16 -16 -24) (16 16 32)
Player takes no damage from electrical attacks and swims faster for 30 seconds
*/
spawnfunc(item_artifact_wetsuit)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	
	settouch(this, hip_powerup_touch);

	precache_model("progs/wetsuit.mdl");
	precache_sound("misc/wetsuit.wav");
	precache_sound("misc/weton.wav");
	precache_sound("items/suit2.wav");
	this.noise = "misc/weton.wav";
	_setmodel(this, "progs/wetsuit.mdl");
	this.netname = "Wetsuit";
	this.items = IT_WETSUIT;
	setsize(this, '-16 -16 -24', '16 16 32');

	StartItem(this);
}

/*
===============================================================================
//
// Horn of Conjuring
//
===============================================================================
*/

void horn_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;

	if(deathmatch)
	{
		this.mdl = this.model;

		this.nextthink = time + 60;
		setthink(this, SUB_regen);
	}

	this.solid = SOLID_NOT;
	this.model = string_null;
	sprint(toucher, "You got the Horn of Conjuring\n");
	_sound(toucher, CHAN_VOICE, this.noise, 1, ATTN_NONE);
	stuffcmd(toucher, "bf\n");
	//toucher.items |= IT_HORN_OF_CONJURING; // TODO: make a proper item out of this?
	SUB_UseTargets(this, toucher, toucher); // fire all targets / killtargets
}

/*QUAKED item_hornofconjuring (0 .5 .8) (-16 -16 0) (16 16 32)
Horn of Conjuring.
You must make func_spawn entities connected to this entity
to spawn the charmed creature.
*/
spawnfunc(item_hornofconjuring)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	settouch(this, horn_touch);

	precache_model("progs/horn.mdl");
	precache_sound("hipitems/horn.wav");
	_setmodel(this, "progs/horn.mdl");
	this.noise = "hipitems/horn.wav";
	this.items = IT_HORN_OF_CONJURING;
	setsize(this, '-16 -16 0', '16 16 32');
	StartItem(this);
}

/*QUAKED item_artifact_empathy_shields (0 .5 .8) (-16 -16 0) (16 16 32)
Empathy Shield.
*/
spawnfunc(item_artifact_empathy_shields)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	settouch(this, hip_powerup_touch);

	precache_model("progs/empathy.mdl");
	precache_sound("hipitems/empathy.wav");
	precache_sound("hipitems/empathy2.wav");
	precache_sound("items/suit2.wav");
	_setmodel(this, "progs/empathy.mdl");
	this.noise = "hipitems/empathy.wav";
	this.netname = "Empathy Shields";
	this.items = IT_EMPATHY_SHIELDS;
	setsize(this, '-16 -16 0', '16 16 32');
	StartItem(this);
}
/*
===============================================================================

HIPNOTIC WEAPONS

===============================================================================
*/

/*QUAKED weapon_mjolnir (0 .5 .8) (-16 -16 0) (16 16 32)
*/

spawnfunc(weapon_mjolnir)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	precache_model ("progs/g_hammer.mdl");
	_setmodel(this, "progs/g_hammer.mdl");
	this.weapon = WEP_MJOLNIR;
	this.netname = "Mjolnir";
	//this.weapons = WEP_MJOLNIR;
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

/*QUAKED weapon_laser_gun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

spawnfunc(weapon_laser_gun)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	precache_model ("progs/g_laserg.mdl");
	_setmodel(this, "progs/g_laserg.mdl");
	this.weapon = WEP_LASER_CANNON;
	this.netname = "Laser Cannon";
	//this.weapons = WEP_LASER_CANNON;
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

/*QUAKED weapon_proximity_gun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

spawnfunc(weapon_proximity_gun)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	precache_model ("progs/g_prox.mdl");
	_setmodel(this, "progs/g_prox.mdl");
	this.weapon = WEP_PROXIMITY_GUN;
	this.netname = "Proximity Gun";
	//this.weapons = WEP_PROXIMITY_GUN;
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}
