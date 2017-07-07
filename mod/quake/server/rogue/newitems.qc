// New Items
//
// Items added for the Rogue XPACK.

void sphere_spawn(entity this, entity toucher);

void newitems_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;
		
	// only one per person, please.
	if(this.classname == "item_sphere" && (toucher.items & IT_V_SPHERE))
		return;

	sprint(toucher, "You got the ");
	sprint(toucher, this.netname);
	sprint(toucher, "\n");

	if(deathmatch)
	{
		if(this.classname == "item_random_powerup")
		{
			this.nextthink = time + 60;
			setthink(this, random_regen);
		}
		else if(this.classname == "item_sphere")
		{
			this.mdl = this.model;
			this.nextthink = time + 60*3;
			setthink(this, SUB_regen);
		}
		else 
		{
			this.mdl = this.model;
			this.nextthink = time + 60;
			setthink(this, SUB_regen);
		}
	}	

	_sound(toucher, CHAN_VOICE, this.noise, 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");
	this.solid = SOLID_NOT;
	toucher.items |= this.items;
	this.model = string_null;

// do the apropriate action
	if(this.netname == "Power Shield")
	{
		toucher.shield_time = 1;
		toucher.shield_finished = time + 30;
	}
	else if(this.netname == "Anti-Grav Belt")
	{
		toucher.antigrav_time = 1;
		toucher.antigrav_finished = time + 45;
		toucher.gravity = 0.25;
	}
	else if(this.classname == "item_sphere")
	{
		toucher.items |= IT_V_SPHERE;
		sphere_spawn(this, toucher);
	}

	SUB_UseTargets(this, toucher, toucher); // fire all targets / killtargets
}


/*QUAKED item_powerup_shield (0 .5 .8) (-16 -16 -24) (16 16 32)
The shield upgrade
*/
spawnfunc(item_powerup_shield)
{
	if(!MP_ROGUE) { delete(this); return; }

	settouch(this, newitems_touch);

	precache_model ("progs/shield.mdl");
	precache_model ("progs/p_shield.mdl");
	precache_sound ("shield/pickup.wav");
	precache_sound ("shield/hit.wav");
	precache_sound ("shield/fadeout.wav");
	this.noise = "shield/pickup.wav";
	_setmodel(this, "progs/shield.mdl");
	this.netname = "Power Shield";
	this.items = IT_SHIELD;
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}

/*QUAKED item_powerup_belt (0 .5 .8) (-16 -16 -24) (16 16 32)
The anti-grav belt
*/
spawnfunc(item_powerup_belt)
{
	if(!MP_ROGUE) { delete(this); return; }
	
	settouch(this, newitems_touch);

	precache_model ("progs/beltup.mdl");
	precache_sound ("belt/pickup.wav");
	precache_sound ("belt/use.wav");
	precache_sound ("belt/fadeout.wav");
	this.noise = "belt/pickup.wav";
	_setmodel(this, "progs/beltup.mdl");
	this.netname = "Anti-Grav Belt";
	this.items = IT_ANTIGRAV;
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}
