/*QUAKED item_artifact_wetsuit (0 .5 .8) (-16 -16 -24) (16 16 32)
Player takes no damage from electrical attacks and swims faster for 30 seconds
*/
spawnfunc(item_artifact_wetsuit)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	
	settouch(this, powerup_touch);

	precache_model("progs/wetsuit.mdl");
	precache_sound("misc/wetsuit.wav");
	precache_sound("misc/weton.wav");
	precache_sound("items/suit2.wav");
	this.noise = "misc/weton.wav";
	_setmodel(this, "progs/wetsuit.mdl");
	this.netname = "Wetsuit";
	this.powerups = POWERUP_WETSUIT;
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

/*QUAKED item_hornofconjuring (0 .5 .8) (-16 -16 0) (16 16 32)
Horn of Conjuring.
You must make func_spawn entities connected to this entity
to spawn the charmed creature.
*/
spawnfunc(item_hornofconjuring)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	settouch(this, powerup_touch);

	precache_model("progs/horn.mdl");
	precache_sound("hipitems/horn.wav");
	_setmodel(this, "progs/horn.mdl");
	this.noise = "hipitems/horn.wav";
	this.netname = "Horn of Conjuring";
	this.powerups = POWERUP_HORN_OF_CONJURING;
	setsize(this, '-16 -16 0', '16 16 32');
	StartItem(this);
}

/*QUAKED item_artifact_empathy_shields (0 .5 .8) (-16 -16 0) (16 16 32)
Empathy Shield.
*/
spawnfunc(item_artifact_empathy_shields)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	settouch(this, powerup_touch);

	precache_model("progs/empathy.mdl");
	precache_sound("hipitems/empathy.wav");
	precache_sound("hipitems/empathy2.wav");
	precache_sound("items/suit2.wav");
	_setmodel(this, "progs/empathy.mdl");
	this.noise = "hipitems/empathy.wav";
	this.netname = "Empathy Shields";
	this.powerups = POWERUP_EMPATHY_SHIELDS;
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
	this.weapon = WEP_MJOLNIR.m_id;
	this.netname = "Mjolnir";
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
	this.weapon = WEP_LASER_CANNON.m_id;
	this.netname = "Laser Cannon";
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
	this.weapon = WEP_PROXIMITY_GUN.m_id;
	this.netname = "Proximity Gun";
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}
