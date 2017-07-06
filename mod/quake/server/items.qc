void W_SwitchWeapon(entity this, float to_wep);
void W_SetCurrentAmmo(entity this);
/* ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD
BE .8 .3 .4 IN COLOR */


void SUB_regen(entity this)
{
	this.model = this.mdl;		// restore original model
	this.solid = SOLID_TRIGGER;	// allow it to be touched again
	_sound(this, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);	// play respawn sound
	setorigin(this, this.origin);
}



/*QUAKED noclass(0 0 0)(-8 -8 -8)(8 8 8)
prints a warning message when spawned
*/
spawnfunc(noclass)
{
	LOG_DEBUGF("noclass spawned at %v\n", this.origin);
	delete(this);
}

.vector m_min;
.vector m_max;
void FixItem(entity this)
{
	this.nextthink = time + 0.5;
	// sanity checks
	//if(!this.noalign)
	if(this.mins != this.m_min || this.maxs != this.m_max)
	{ // reset the item boundaries in case it got squished
		LOG_TRACE("wtf the item got squashed?");
		setsize(this, this.m_min, this.m_max);
	}
}


/*
============
PlaceItem

plants the object on the floor
============
*/

void PlaceItem(entity this)
{
	this.mdl = this.model;		// so it can be restored on respawn
	this.flags = FL_ITEM;		// make extra wide
	this.solid = SOLID_TRIGGER;
	set_movetype(this, MOVETYPE_TOSS);	
	this.velocity = '0 0 0';
	this.origin_z = this.origin_z + 6;
	this.m_min = this.mins;
	this.m_max = this.maxs;
	setthink(this, FixItem);
	this.nextthink = time + 1; // initial delay
	bool didit = false;
	WITHSELF(this, didit = builtin_droptofloor());
	if(!didit)
	{
		LOG_DEBUGF("Bonus item fell out of level at %v\n", this.origin);
		delete(this);
		return;
	}
}

/*
============
StartItem

Sets the clipping size and plants the object on the floor
============
*/
void StartItem(entity this)
{
	this.nextthink = time + 0.2;	// items start after other solids
	setthink(this, PlaceItem);
}

/*
=========================================================================

HEALTH BOX

=========================================================================
*/
//
// T_Heal: add health to an entity, limiting health to max_health
// "ignore" will ignore max_health limit
//
bool T_Heal(entity e, float healamount, bool ignore)
{
	if(e.health <= 0)
		return false;
	if((!ignore) &&(e.health >= e.max_health))
		return false;
	healamount = ceil(healamount);

	e.health = e.health + healamount;
	if((!ignore) &&(e.health >= e.max_health))
		e.health = e.max_health;
		
	if(e.health > 250)
		e.health = 250;
	return true;
}

/*QUAKED item_health(.3 .3 1)(0 0 0)(32 32 32) rotten megahealth
Health box. Normally gives 25 points.
Rotten box heals 5-10 points,
megahealth will add 100 health, then 
rot you down to your maximum health limit, 
one point per second.
*/

const int H_ROTTEN = BIT(0);
const int H_MEGA = BIT(1);
.float	healamount, healtype;
void health_touch(entity this, entity toucher);
void item_megahealth_rot(entity this);

spawnfunc(item_health)
{	
	settouch(this, health_touch);

	if(this.spawnflags & H_ROTTEN)
	{
		precache_model("maps/b_bh10.bsp");

		precache_sound("items/r_item1.wav");
		_setmodel(this, "maps/b_bh10.bsp");
		this.noise = "items/r_item1.wav";
		this.healamount = 15;
		this.healtype = 0;
	}
	else
	if(this.spawnflags & H_MEGA)
	{
		precache_model("maps/b_bh100.bsp");
		precache_sound("items/r_item2.wav");
		_setmodel(this, "maps/b_bh100.bsp");
		this.noise = "items/r_item2.wav";
		this.healamount = 100;
		this.healtype = 2;
	}
	else
	{
		precache_model("maps/b_bh25.bsp");
		precache_sound("items/health1.wav");
		_setmodel(this, "maps/b_bh25.bsp");
		this.noise = "items/health1.wav";
		this.healamount = 25;
		this.healtype = 1;
	}
	setsize(this, '0 0 0', '32 32 56');
	StartItem(this);
}

bool RuneHasElder(entity who);
void health_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	
	if(this.healtype == 2) // Megahealth?  Ignore max_health...
	{
		if(toucher.health >= 250)
			return;
		if(!T_Heal(toucher, this.healamount, true))
			return;
	}
	else
	{
		if(!T_Heal(toucher, this.healamount, false))
			return;
	}

	sprint(toucher, sprintf("You receive %d health\n", this.healamount));
	
// health touch sound
	_sound(toucher, CHAN_ITEM, this.noise, 1, ATTN_NORM);

	stuffcmd(toucher, "bf\n");
	
	this.model = string_null;
	this.solid = SOLID_NOT;

	// Megahealth = rot down the player's super health
	if(this.healtype == 2 && (!MP_ROGUE || !RuneHasElder(toucher)))
	{
		if(!MP_HIPNOTIC)
		{
			if(MP_ROGUE)
				toucher.items2 |= IT2_SUPERHEALTH;
			else
				toucher.items |= IT_SUPERHEALTH;
		}
		this.nextthink = time + 5;
		setthink(this, item_megahealth_rot);
		this.owner = toucher;
	}
	else
	{
		if(deathmatch != 2)		// deathmatch 2 is the silly old rules
		{
			if(deathmatch)
			{
				this.nextthink = time + 20;
				setthink(this, SUB_regen);
			}
		}
	}

	SUB_UseTargets(this, toucher, NULL);				// fire all targets / killtargets
}	

void item_megahealth_rot(entity this)
{
	if(this.owner.health > this.owner.max_health)
	{
		this.owner.health = this.owner.health - 1;
		this.nextthink = time + 1;
		return;
	}

// it is possible for a player to die and respawn between rots, so don't
// just blindly subtract the flag off
	if(!MP_HIPNOTIC)
	{
		if(MP_ROGUE)
			this.owner.items2 &= ~IT2_SUPERHEALTH;
		else
			this.owner.items &= ~IT_SUPERHEALTH;
	}
	
	if(deathmatch == 1)	// deathmatch 2 is silly old rules
	{
		this.nextthink = time + 20;
		setthink(this, SUB_regen);
	}
}

/*
===============================================================================

ARMOR

===============================================================================
*/

void armor_touch(entity this, entity toucher)
{
	if(toucher.health <= 0)
		return;
	if(!IS_PLAYER(toucher))
		return;

	float type = 0, value = 0;
	int bit = 0;

	if(this.classname == "item_armor1")
	{
		type = 0.3;
		value = 100;
		bit = ((MP_ROGUE) ? IT2_ARMOR1 : IT_ARMOR1);
	}
	if(this.classname == "item_armor2")
	{
		type = 0.6;
		value = 150;
		bit = ((MP_ROGUE) ? IT2_ARMOR2 : IT_ARMOR2);
	}
	if(this.classname == "item_armorInv")
	{
		type = 0.8;
		value = 200;
		bit = ((MP_ROGUE) ? IT2_ARMOR3 : IT_ARMOR3);
	}
	if(toucher.armortype*toucher.armorvalue >= type*value)
		return;
		
	toucher.armortype = type;
	toucher.armorvalue = value;
	if(MP_ROGUE)
	{
		toucher.items2 &= ~(IT2_ARMOR1 | IT2_ARMOR2 | IT2_ARMOR3);
		toucher.items2 |= bit;
	}
	else
	{
		toucher.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
		toucher.items |= bit;
	}

	this.solid = SOLID_NOT;
	this.model = string_null;
	if(deathmatch == 1)
	{
		this.nextthink = time + 20;
		setthink(this, SUB_regen);
	}

	sprint(toucher, "You got armor\n");
// armor touch sound
	_sound(toucher, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");

	SUB_UseTargets(this, toucher, NULL);				// fire all targets / killtargets
}


/*QUAKED item_armor1(0 .5 .8)(-16 -16 0)(16 16 32)
*/

spawnfunc(item_armor1)
{
	settouch(this, armor_touch);
	precache_model("progs/armor.mdl");
	_setmodel(this, "progs/armor.mdl");
	this.skin = 0;
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

/*QUAKED item_armor2(0 .5 .8)(-16 -16 0)(16 16 32)
*/

spawnfunc(item_armor2)
{
	settouch(this, armor_touch);
	precache_model("progs/armor.mdl");
	_setmodel(this, "progs/armor.mdl");
	this.skin = 1;
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

/*QUAKED item_armorInv(0 .5 .8)(-16 -16 0)(16 16 32)
*/

spawnfunc(item_armorInv)
{
	settouch(this, armor_touch);
	precache_model("progs/armor.mdl");
	_setmodel(this, "progs/armor.mdl");
	this.skin = 2;
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

/*
===============================================================================

WEAPONS

===============================================================================
*/

void rogue_bound_other_ammo(entity this)
{
	if(this.ammo_shells1 > 100)
		this.ammo_shells1 = 100;
	if(this.ammo_nails1 > 200)
		this.ammo_nails1 = 200;
	if(this.ammo_rockets1 > 100)
		this.ammo_rockets1 = 100;		
	if(this.ammo_cells1 > 100)
		this.ammo_cells1 = 100;

	if(this.ammo_lava_nails > 200)
		this.ammo_lava_nails = 200;
	if(this.ammo_multi_rockets > 100)
		this.ammo_multi_rockets = 100;
	if(this.ammo_plasma > 100)
		this.ammo_plasma = 100;
}

void bound_other_ammo(entity this)
{
	if(MP_ROGUE)
	{
		rogue_bound_other_ammo(this);
		return;
	}

	if(this.ammo_shells > 100)
		this.ammo_shells = 100;
	if(this.ammo_nails > 200)
		this.ammo_nails = 200;
	if(this.ammo_rockets > 100)
		this.ammo_rockets = 100;		
	if(this.ammo_cells > 100)
		this.ammo_cells = 100;
}

int HIP_RankForWeapon(int w)
{
	switch(w)
	{
		case IT_LIGHTNING: 			return 1;
		case IT_ROCKET_LAUNCHER: 	return 2;
		case IT_LASER_CANNON: 		return 3;
		case IT_SUPER_NAILGUN: 		return 4;
		case IT_PROXIMITY_GUN: 		return 5;
		case IT_GRENADE_LAUNCHER: 	return 6;
		case IT_SUPER_SHOTGUN: 		return 7;
		case IT_NAILGUN: 			return 8;
		case IT_MJOLNIR: 			return 9;
		default: 					return 10;
	}
}

int Rogue_RankForWeapon(int w)
{
	switch(w)
	{
		case IT_PLASMA_GUN:			return 1;
		case IT_LIGHTNING: 			return 2;
		case IT_MULTI_ROCKET: 		return 3;
		case IT_ROCKET_LAUNCHER: 	return 4;
		case IT_LAVA_SUPER_NAILGUN: return 5;
		case IT_SUPER_NAILGUN: 		return 6;
		case IT_MULTI_GRENADE: 		return 7;
		case IT_GRENADE_LAUNCHER: 	return 8;
		case IT_LAVA_NAILGUN: 		return 9;
		case IT_SUPER_SHOTGUN: 		return 10;
		case IT_NAILGUN: 			return 11;
		default: 					return 12;
	}
}

int RankForWeapon(int w)
{
	if(MP_HIPNOTIC)
		return HIP_RankForWeapon(w);
	if(MP_ROGUE)
		return Rogue_RankForWeapon(w);

	switch(w)
	{
		case IT_LIGHTNING: 			return 1;
		case IT_ROCKET_LAUNCHER: 	return 2;
		case IT_SUPER_NAILGUN: 		return 3;
		case IT_GRENADE_LAUNCHER: 	return 4;
		case IT_SUPER_SHOTGUN: 		return 5;
		case IT_NAILGUN: 			return 6;
		default: 					return 7;
	}
}

/*
=============
Deathmatch_Weapon

Deathmatch weapon change rules for picking up a weapon

.int		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
or rogue:
.int		ammo_shells1, ammo_nails1, ammo_rockets1, ammo_cells1;
=============
*/
void Deathmatch_Weapon(entity this, int old, int new)
{
	if(MP_ROGUE && this.weapon == IT_GRAPPLE && this.button0)
		return;

// change this.weapon if desired
	int or = RankForWeapon(this.weapon);
	int nr = RankForWeapon(new);
	if(nr < or)
		W_SwitchWeapon(this, new);
}

bool weapon_customize(entity this, entity client)
{
	if((deathmatch == 2 || coop) && (client.items & this.weapon))
		return false;
	return true;
}

void EnableComboWeapons(entity this)
{
	if(!IS_PLAYER(this))
		return;
	
	if (!(this.items & IT_LAVA_NAILGUN))
	{
		if (this.ammo_lava_nails > 0 && (this.items & IT_NAILGUN))
		{
			sprint (this, "Lava Enabled\n");
			this.items |= IT_LAVA_NAILGUN;
		}
	}

	if (!(this.items & IT_LAVA_SUPER_NAILGUN))
	{
		if (this.ammo_lava_nails > 0 && 
							(this.items & IT_SUPER_NAILGUN))
		{
			sprint (this, "Super Lava Enabled\n");
			this.items |= IT_LAVA_SUPER_NAILGUN;		
		}
	}

	if (!(this.items & IT_MULTI_GRENADE))
	{
		if (this.ammo_multi_rockets > 0 && 
							(this.items & IT_GRENADE_LAUNCHER))
		{
			sprint (this, "Multi Grenades Enabled\n");
			this.items |= IT_MULTI_GRENADE;		
		}
	}

	if (!(this.items & IT_MULTI_ROCKET))
	{
		if (this.ammo_multi_rockets > 0 && 
							(this.items & IT_ROCKET_LAUNCHER))
		{
			sprint (this, "Multi Rockets Enabled\n");
			this.items |= IT_MULTI_ROCKET;		
		}
	}

	if (!(this.items & IT_PLASMA_GUN))
	{
		if (this.ammo_plasma > 0 && (this.items & IT_LIGHTNING))
		{
			sprint (this, "Plasma Gun Enabled\n");
			this.items |= IT_PLASMA_GUN;		
		}
	}
}

/*
=============
weapon_touch
=============
*/
int W_BestWeapon(entity this, float except);

void weapon_touch(entity this, entity toucher)
{
	if(!IS_CLIENT(toucher))
		return;

	int hadammo = 0, new = 0;
// if the player was using his best weapon, change up to the new one if better		
	//int best = W_BestWeapon(toucher);

	bool leave = (deathmatch == 2 || coop);
	
	switch(this.classname)
	{
		case "weapon_nailgun":
		{
			if(leave && (toucher.items & IT_NAILGUN))
				return;
			hadammo = ((MP_ROGUE) ? toucher.ammo_nails1 : toucher.ammo_nails);			
			new = IT_NAILGUN;
			if(MP_ROGUE && leave)
				toucher.ammo_lava_nails += 20;
			if(MP_ROGUE)
				toucher.ammo_nails1 = toucher.ammo_nails1 + 30;
			else
				toucher.ammo_nails = toucher.ammo_nails + 30;
			break;
		}
		case "weapon_supernailgun":
		{
			if(leave && (toucher.items & IT_SUPER_NAILGUN))
				return;
			hadammo = ((MP_ROGUE) ? toucher.ammo_rockets1 : toucher.ammo_rockets);			
			new = IT_SUPER_NAILGUN;
			if(MP_ROGUE && leave)
				toucher.ammo_lava_nails += 20;
			if(MP_ROGUE)
				toucher.ammo_nails1 = toucher.ammo_nails1 + 30;
			else
				toucher.ammo_nails = toucher.ammo_nails + 30;
			break;
		}
		case "weapon_supershotgun":
		{
			if(leave && (toucher.items & IT_SUPER_SHOTGUN))
				return;
			hadammo = ((MP_ROGUE) ? toucher.ammo_rockets1 : toucher.ammo_rockets);		
			new = IT_SUPER_SHOTGUN;
			if(MP_ROGUE)
				toucher.ammo_shells1 = toucher.ammo_shells1 + 5;
			else
				toucher.ammo_shells = toucher.ammo_shells + 5;
			break;
		}
		case "weapon_rocketlauncher":
		{
			if(leave && (toucher.items & IT_ROCKET_LAUNCHER))
				return;
			hadammo = ((MP_ROGUE) ? toucher.ammo_rockets1 : toucher.ammo_rockets);		
			new = IT_ROCKET_LAUNCHER;
			if(MP_ROGUE && leave)
				toucher.ammo_multi_rockets += 3;
			if(MP_ROGUE)
				toucher.ammo_rockets1 = toucher.ammo_rockets1 + 5;
			else
				toucher.ammo_rockets = toucher.ammo_rockets + 5;
			break;
		}
		case "weapon_grenadelauncher":
		{
			if(leave && (toucher.items & IT_GRENADE_LAUNCHER))
				return;
			hadammo = ((MP_ROGUE) ? toucher.ammo_rockets1 : toucher.ammo_rockets);			
			new = IT_GRENADE_LAUNCHER;
			toucher.ammo_rockets = toucher.ammo_rockets + 5;
			break;
		}
		case "weapon_lightning":
		{
			if(leave && (toucher.items & IT_LIGHTNING))
				return;
			hadammo = ((MP_ROGUE) ? toucher.ammo_rockets1 : toucher.ammo_rockets);			
			new = IT_LIGHTNING;
			if(MP_ROGUE && leave)
				toucher.ammo_plasma += 5;
			if(MP_ROGUE)
				toucher.ammo_cells1 = toucher.ammo_cells1 + 15;
			else
				toucher.ammo_cells = toucher.ammo_cells + 15;
			break;
		}
		case "weapon_laser_gun":
		{
	      	if (leave && (toucher.items & IT_LASER_CANNON) )
				return;
			hadammo = ((MP_ROGUE) ? toucher.ammo_rockets1 : toucher.ammo_rockets);
	      	new = IT_LASER_CANNON;
		if(MP_ROGUE)
			toucher.ammo_cells1 = toucher.ammo_cells1 + 30;
		else
	      		toucher.ammo_cells = toucher.ammo_cells + 30;
	      	break;
		}
	   	case "weapon_mjolnir":
		{
	      	if (leave && (toucher.items & IT_MJOLNIR) )
				return;
			hadammo = ((MP_ROGUE) ? toucher.ammo_rockets1 : toucher.ammo_rockets);
	      	new = IT_MJOLNIR;
		if(MP_ROGUE)
			toucher.ammo_cells1 = toucher.ammo_cells1 + 30;
		else
	      		toucher.ammo_cells = toucher.ammo_cells + 30;
	      	break;
		}
	   	case "weapon_proximity_gun":
		{
	      	if(leave && (toucher.items & IT_PROXIMITY_GUN) )
				return;
			hadammo = ((MP_ROGUE) ? toucher.ammo_rockets1 : toucher.ammo_rockets);
	      	new = IT_PROXIMITY_GUN;
		if(MP_ROGUE)
			toucher.ammo_rockets1 = toucher.ammo_rockets1 + 6;
		else
	      		toucher.ammo_rockets = toucher.ammo_rockets + 6;
	      	break;
		}
		default:
		{
			objerror(this, "weapon_touch: unknown classname");
			break;
		}
	}

	if(this.netname != "")
		sprint(toucher, sprintf("You got the %s\n", this.netname));
	else
		sprint(toucher, sprintf("You picked up a weapon\n"));
// weapon touch sound
	_sound(toucher, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");

	bound_other_ammo(toucher);

// change to the weapon
	int old = toucher.items;
	toucher.items |= new;

	if(MP_ROGUE)
		EnableComboWeapons(toucher);

	// PGM - fake picking up the plasma gun.
	if(!MP_ROGUE) { /* do nothing */ }
	else if(new == IT_LIGHTNING)
	{
		if(toucher.ammo_plasma > 0)
			new = IT_PLASMA_GUN;
	}
	else if(new == IT_ROCKET_LAUNCHER)
	{
		if(toucher.ammo_multi_rockets > 0)
			new = IT_MULTI_ROCKET;
	}
	else if(new == IT_GRENADE_LAUNCHER)
	{
		if(toucher.ammo_multi_rockets > 0)
			new = IT_MULTI_GRENADE;
	}
	else if(new == IT_SUPER_NAILGUN)
	{
		if(toucher.ammo_lava_nails > 1)
			new = IT_LAVA_SUPER_NAILGUN;
	}
	else if(new == IT_NAILGUN)
	{
		if(toucher.ammo_lava_nails > 0)
			new = IT_LAVA_NAILGUN;
	}

	if(!deathmatch)
		W_SwitchWeapon(toucher, new);
	else
		Deathmatch_Weapon(toucher, old, new);

	if(MP_ROGUE)
		UpdateAmmoCounts(this);

	if(leave)
		return;

// remove it in single player, or setup for respawning in deathmatch
	this.model = string_null;
	this.solid = SOLID_NOT;
	if(deathmatch == 1)
	{
		this.nextthink = time + 30;
		setthink(this, SUB_regen);
	}

	SUB_UseTargets(this, toucher, NULL);				// fire all targets / killtargets
}


/*QUAKED weapon_supershotgun(0 .5 .8)(-16 -16 0)(16 16 32)
*/

spawnfunc(weapon_supershotgun)
{
	precache_model("progs/g_shot.mdl");
	_setmodel(this, "progs/g_shot.mdl");
	this.weapon = IT_SUPER_SHOTGUN;
	this.netname = "Double-barrelled Shotgun";
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

/*QUAKED weapon_nailgun(0 .5 .8)(-16 -16 0)(16 16 32)
*/

spawnfunc(weapon_nailgun)
{
	precache_model("progs/g_nail.mdl");
	_setmodel(this, "progs/g_nail.mdl");
	this.weapon = IT_NAILGUN;
	this.netname = "nailgun";
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

/*QUAKED weapon_supernailgun(0 .5 .8)(-16 -16 0)(16 16 32)
*/

spawnfunc(weapon_supernailgun)
{
	precache_model("progs/g_nail2.mdl");
	_setmodel(this, "progs/g_nail2.mdl");
	this.weapon = IT_SUPER_NAILGUN;
	this.netname = "Super Nailgun";
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

/*QUAKED weapon_grenadelauncher(0 .5 .8)(-16 -16 0)(16 16 32)
*/

spawnfunc(weapon_grenadelauncher)
{
	precache_model("progs/g_rock.mdl");
	_setmodel(this, "progs/g_rock.mdl");
	this.weapon = IT_GRENADE_LAUNCHER;
	this.netname = "Grenade Launcher";
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

/*QUAKED weapon_rocketlauncher(0 .5 .8)(-16 -16 0)(16 16 32)
*/

spawnfunc(weapon_rocketlauncher)
{
	precache_model("progs/g_rock2.mdl");
	_setmodel(this, "progs/g_rock2.mdl");
	this.weapon = IT_ROCKET_LAUNCHER;
	this.netname = "Rocket Launcher";
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}


/*QUAKED weapon_lightning(0 .5 .8)(-16 -16 0)(16 16 32)
*/

spawnfunc(weapon_lightning)
{
	precache_model("progs/g_light.mdl");
	_setmodel(this, "progs/g_light.mdl");
	this.weapon = IT_LIGHTNING;
	this.netname = "Thunderbolt";
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}


/*
===============================================================================

AMMO

===============================================================================
*/

void rogue_ammo_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;

// if the player was using his best weapon, change up to the new one if better		
	int best = W_BestWeapon(toucher, 0);


// shotgun
	if(this.weapon == 1)
	{
		if(toucher.ammo_shells >= 100)
			return;
		toucher.ammo_shells = toucher.ammo_shells + this.aflag;
	}

// spikes
	if(this.weapon == 2)
	{
		if(toucher.ammo_nails >= 200)
			return;
		toucher.ammo_nails = toucher.ammo_nails + this.aflag;
	}

//	rockets
	if(this.weapon == 3)
	{
		if(toucher.ammo_rockets >= 100)
			return;
		toucher.ammo_rockets = toucher.ammo_rockets + this.aflag;
	}

//	cells
	if(this.weapon == 4)
	{
		if(toucher.ammo_cells >= 100)
			return;
		toucher.ammo_cells = toucher.ammo_cells + this.aflag;
	}

	bound_other_ammo(toucher);

	if(this.netname != "")
		sprint(toucher, sprintf("You got the %s\n", this.netname));
	else
		sprint(toucher, sprintf("You picked up some ammo\n"));
// ammo touch sound
	_sound(toucher, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");

// change to a better weapon if appropriate

	if( toucher.weapon == best )
		W_SwitchWeapon(toucher, W_BestWeapon(toucher, 0));

// if changed current ammo, update it
	W_SetCurrentAmmo(toucher);

// remove it in single player, or setup for respawning in deathmatch
	this.model = string_null;
	this.solid = SOLID_NOT;
	if(deathmatch == 1)
	{
		this.nextthink = time + 30;
		setthink(this, SUB_regen);
	}

	SUB_UseTargets(this, toucher, NULL);				// fire all targets / killtargets
}

void ammo_touch(entity this, entity toucher)
{
	if(MP_ROGUE)
	{
		rogue_ammo_touch(this, toucher);
		return;
	}

	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;

// if the player was using his best weapon, change up to the new one if better		
	int best = W_BestWeapon(toucher, 0);


// shotgun
	if(this.weapon == 1)
	{
		if(toucher.ammo_shells >= 100)
			return;
		toucher.ammo_shells = toucher.ammo_shells + this.aflag;
	}

// spikes
	if(this.weapon == 2)
	{
		if(toucher.ammo_nails >= 200)
			return;
		toucher.ammo_nails = toucher.ammo_nails + this.aflag;
	}

//	rockets
	if(this.weapon == 3)
	{
		if(toucher.ammo_rockets >= 100)
			return;
		toucher.ammo_rockets = toucher.ammo_rockets + this.aflag;
	}

//	cells
	if(this.weapon == 4)
	{
		if(toucher.ammo_cells >= 100)
			return;
		toucher.ammo_cells = toucher.ammo_cells + this.aflag;
	}

	bound_other_ammo(toucher);

	if(this.netname != "")
		sprint(toucher, sprintf("You got the %s\n", this.netname));
	else
		sprint(toucher, sprintf("You picked up some ammo\n"));
// ammo touch sound
	_sound(toucher, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");

// change to a better weapon if appropriate

	if( toucher.weapon == best )
		W_SwitchWeapon(toucher, W_BestWeapon(toucher, 0));

// if changed current ammo, update it
	W_SetCurrentAmmo(toucher);

// remove it in single player, or setup for respawning in deathmatch
	this.model = string_null;
	this.solid = SOLID_NOT;
	if(deathmatch == 1)
	{
		this.nextthink = time + 30;
		setthink(this, SUB_regen);
	}

	SUB_UseTargets(this, toucher, NULL);				// fire all targets / killtargets
}




const int WEAPON_BIG2 = BIT(0);

/*QUAKED item_shells(0 .5 .8)(0 0 0)(32 32 32) big
Small box is 20, Big box is 40.
*/

spawnfunc(item_shells)
{
	settouch(this, ammo_touch);

	if(this.spawnflags & WEAPON_BIG2)
	{
		setmodel(this, MDL_ITEM_SHELLS_BIG);
		this.aflag = 40;
	}
	else
	{
		setmodel(this, MDL_ITEM_SHELLS);
		this.aflag = 20;
	}
	this.weapon = 1;
	this.netname = "shells";
	setsize(this, '0 0 0', '32 32 56');
	StartItem(this);
}

/*QUAKED item_spikes(0 .5 .8)(0 0 0)(32 32 32) big
Small box is 25, Big box is 50.
*/

spawnfunc(item_spikes)
{
	settouch(this, ammo_touch);

	if(this.spawnflags & WEAPON_BIG2)
	{
		setmodel(this, MDL_ITEM_NAILS_BIG);
		this.aflag = 50;
	}
	else
	{
		setmodel(this, MDL_ITEM_NAILS);
		this.aflag = 25;
	}
	this.weapon = 2;
	this.netname = "nails";
	setsize(this, '0 0 0', '32 32 56');
	StartItem(this);
}

/*QUAKED item_lava_spikes (0 .5 .8) (0 0 0) (32 32 32) big
Small box is 25, Big box is 50.
*/

spawnfunc(item_lava_spikes)
{
	if(!MP_ROGUE) { delete(this); return; }

	settouch(this, ammo_touch);

	if(this.spawnflags & WEAPON_BIG2)
	{
		precache_model("maps/b_lnail1.bsp");
		_setmodel(this, "maps/b_lnail1.bsp");
		this.aflag = 50;
	}
	else
	{
		precache_model("maps/b_lnail0.bsp");
		_setmodel(this, "maps/b_lnail0.bsp");
		this.aflag = 25;
	}
	this.weapon = 5;
	this.netname = "lava nails";
	setsize(this, '0 0 0', '32 32 56');
	StartItem(this);
}


/*QUAKED item_rockets(0 .5 .8)(0 0 0)(32 32 32) big
Small box is 5, Big box is 10.
*/

spawnfunc(item_rockets)
{
	settouch(this, ammo_touch);

	if(this.spawnflags & WEAPON_BIG2)
	{
		setmodel(this, MDL_ITEM_ROCKETS_BIG);
		this.aflag = 10;
	}
	else
	{
		setmodel(this, MDL_ITEM_ROCKETS);
		this.aflag = 5;
	}
	this.weapon = 3;
	this.netname = "rockets";
	setsize(this, '0 0 0', '32 32 56');
	StartItem(this);
}


/*QUAKED item_multi_rockets (0 .5 .8) (0 0 0) (32 32 32) big
Small box is 5, Big box is 10.
*/

spawnfunc(item_multi_rockets)
{
	if(!MP_ROGUE) { delete(this); return; }

	settouch(this, ammo_touch);

	if(this.spawnflags & WEAPON_BIG2)
	{
		precache_model("maps/b_mrock1.bsp");
		_setmodel(this, "maps/b_mrock1.bsp");
		this.aflag = 10;
	}
	else
	{
		precache_model("maps/b_mrock0.bsp");
		_setmodel(this, "maps/b_mrock0.bsp");
		this.aflag = 5;
	}
	this.weapon = 6;
	this.netname = "multi rockets";
	setsize(this, '0 0 0', '32 32 56');
	StartItem(this);
}


/*QUAKED item_cells(0 .5 .8)(0 0 0)(32 32 32) big
Small box is 6, Big box is 12.
*/

spawnfunc(item_cells)
{
	settouch(this, ammo_touch);

	if(this.spawnflags & WEAPON_BIG2)
	{
		setmodel(this, MDL_ITEM_CELLS_BIG);
		this.aflag = 12;
	}
	else
	{
		setmodel(this, MDL_ITEM_CELLS);
		this.aflag = 6;
	}
	this.weapon = 4;
	this.netname = "cells";
	setsize(this, '0 0 0', '32 32 56');
	StartItem(this);
}


/*QUAKED item_plasma (0 .5 .8) (0 0 0) (32 32 32) big
Small box is 6, Big box is 12.
*/
spawnfunc(item_plasma)
{
	if(!MP_ROGUE) { delete(this); return; }

	settouch(this, ammo_touch);

	if(this.spawnflags & WEAPON_BIG2)
	{
		precache_model("maps/b_plas1.bsp");
		_setmodel(this, "maps/b_plas1.bsp");
		this.aflag = 12;
	}
	else
	{
		precache_model("maps/b_plas0.bsp");
		_setmodel(this, "maps/b_plas0.bsp");
		this.aflag = 6;
	}
	this.weapon = 7;
	this.netname = "plasma";
	setsize(this, '0 0 0', '32 32 56');
	StartItem(this);
}


/*QUAKED item_weapon(0 .5 .8)(0 0 0)(32 32 32) shotgun rocket spikes big
DO NOT USE THIS!!!! IT WILL BE REMOVED!
*/

const int WEAPON_SHOTGUN = BIT(0);
const int WEAPON_ROCKET = BIT(1);
const int WEAPON_SPIKES = BIT(2);
const int WEAPON_BIG = BIT(3);
spawnfunc(item_weapon)
{
	settouch(this, ammo_touch);

	if(this.spawnflags & WEAPON_SHOTGUN)
	{
		if(this.spawnflags & WEAPON_BIG)
		{
			setmodel(this, MDL_ITEM_SHELLS_BIG);
			this.aflag = 40;
		}
		else
		{
			setmodel(this, MDL_ITEM_SHELLS);
			this.aflag = 20;
		}
		this.weapon = IT_SHOTGUN;
		this.netname = "shells";
	}

	if(this.spawnflags & WEAPON_SPIKES)
	{
		if(this.spawnflags & WEAPON_BIG)
		{
			setmodel(this, MDL_ITEM_NAILS_BIG);
			this.aflag = 40;
			this.weapon = IT_SUPER_NAILGUN;
		}
		else
		{
			setmodel(this, MDL_ITEM_NAILS);
			this.aflag = 20;
			this.weapon = IT_NAILGUN;
		}
		this.netname = "spikes";
	}

	if(this.spawnflags & WEAPON_ROCKET)
	{
		if(this.spawnflags & WEAPON_BIG)
		{
			setmodel(this, MDL_ITEM_ROCKETS_BIG);
			this.aflag = 10;
		}
		else
		{
			setmodel(this, MDL_ITEM_ROCKETS);
			this.aflag = 5;
		}
		this.weapon = IT_ROCKET_LAUNCHER;
		this.netname = "rockets";
	}
	
	setsize(this, '0 0 0', '32 32 56');
	StartItem(this);
}


/*
===============================================================================

KEYS

===============================================================================
*/

void key_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;
	if(toucher.items & this.items)
		return;

	if(this.netname != "")
		sprint(toucher, sprintf("You got the %s\n", this.netname));
	else
		sprint(toucher, sprintf("You picked up a key\n"));

	_sound(toucher, CHAN_ITEM, this.noise, 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");
	toucher.items |= this.items;

	if(!coop)
	{	
		this.solid = SOLID_NOT;
		this.model = string_null;
	}
	else
	{
		if(this.netname != "")
			bprintf("%s^7 got the %s\n", toucher.netname, this.netname);
		else
			bprintf("%s^7 picked up a key\n");
	}
	SUB_UseTargets(this, toucher, NULL);				// fire all targets / killtargets
}

bool key_customize(entity this, entity client)
{
	return !(client.items & this.items);
}

void key_setsounds(entity this)
{
	if(world.worldtype == 0)
	{
		precache_sound("misc/medkey.wav");
		this.noise = "misc/medkey.wav";
	}
	if(world.worldtype == 1)
	{
		precache_sound("misc/runekey.wav");
		this.noise = "misc/runekey.wav";
	}
	if(world.worldtype == 2)
	{
		precache_sound2("misc/basekey.wav");
		this.noise = "misc/basekey.wav";
	}
}

/*QUAKED item_key1(0 .5 .8)(-16 -16 -24)(16 16 32)
SILVER key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base
*/

spawnfunc(item_key1)
{
	if(world.worldtype == 0)
	{
		setmodel(this, MDL_ITEM_SILVERKEY);
		this.netname = "silver key";
	}
	else if(world.worldtype == 1)
	{
		setmodel(this, MDL_ITEM_SILVERRUNEKEY);
		this.netname = "silver runekey";
	}
	else if(world.worldtype == 2)
	{
		setmodel(this, MDL_ITEM_SILVERKEYCARD);
		this.netname = "silver keycard";
	}
	key_setsounds(this);
	setcefc(this, key_customize);
	settouch(this, key_touch);
	this.items = IT_KEY1;
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}

/*QUAKED item_key2(0 .5 .8)(-16 -16 -24)(16 16 32)
GOLD key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base
*/

spawnfunc(item_key2)
{
	if(world.worldtype == 0)
	{
		setmodel(this, MDL_ITEM_GOLDKEY);
		this.netname = "gold key";
	}
	if(world.worldtype == 1)
	{
		setmodel(this, MDL_ITEM_GOLDRUNEKEY);
		this.netname = "gold runekey";
	}
	if(world.worldtype == 2)
	{
		setmodel(this, MDL_ITEM_GOLDKEYCARD);
		this.netname = "gold keycard";
	}
	key_setsounds(this);
	setcefc(this, key_customize);
	settouch(this, key_touch);
	this.items = IT_KEY2;
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}



/*
===============================================================================

END OF LEVEL RUNES

===============================================================================
*/

void sigil_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;

	centerprint(toucher, "You got the rune!");

	_sound(toucher, CHAN_ITEM, this.noise, 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");
	this.solid = SOLID_NOT;
	this.model = string_null;
	serverflags = serverflags |(this.spawnflags & 15);
	this.classname = "";		// so rune doors won't find it
	SUB_UseTargets(this, toucher, NULL);				// fire all targets / killtargets
}


/*QUAKED item_sigil(0 .5 .8)(-16 -16 -24)(16 16 32) E1 E2 E3 E4
End of level sigil, pick up to end episode and return to jrstart.
*/

spawnfunc(item_sigil)
{
	if(!this.spawnflags)
		objerror(this, "no spawnflags");

	precache_sound("misc/runekey.wav");
	this.noise = "misc/runekey.wav";

	if(this.spawnflags & 1)
	{
		precache_model("progs/end1.mdl");
		_setmodel(this, "progs/end1.mdl");
	}
	if(this.spawnflags & 2)
	{
		precache_model2("progs/end2.mdl");
		_setmodel(this, "progs/end2.mdl");
	}
	if(this.spawnflags & 4)
	{
		precache_model2("progs/end3.mdl");
		_setmodel(this, "progs/end3.mdl");
	}
	if(this.spawnflags & 8)
	{
		precache_model2("progs/end4.mdl");
		_setmodel(this, "progs/end4.mdl");
	}
	
	settouch(this, sigil_touch);
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}

/*
===============================================================================

POWERUPS

===============================================================================
*/

void random_regen(entity this);

void powerup_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;

	if(this.netname != "")
		sprint(toucher, sprintf("You got the %s\n", this.netname));
	else
		sprint(toucher, sprintf("You picked up a powerup\n"));

	if(deathmatch)
	{
		this.mdl = this.model;
		
		if(this.classname == "item_random_powerup")
		{
			this.nextthink = time + 30;
			setthink(this, random_regen);
		}
		else
		{
			if((this.classname == "item_artifact_invulnerability") ||
				(this.classname == "item_artifact_invisibility"))
				this.nextthink = time + 60*5;
			else
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
	bool cname;

	cname = ((MP_ROGUE) ? (this.netname == "Biosuit") : (this.classname == "item_artifact_envirosuit"));
	if(cname)
	{
		toucher.rad_time = 1;
		toucher.radsuit_finished = time + 30;
	}

	cname = ((MP_ROGUE) ? (this.netname == "Pentagram of Protection") : (this.classname == "item_artifact_invulnerability"));
	if(cname)
	{
		toucher.invincible_time = 1;
		toucher.invincible_finished = time + 30;
	}

	cname = ((MP_ROGUE) ? (this.netname == "Ring of Shadows") : (this.classname == "item_artifact_invisibility"));
	if(cname)
	{
		toucher.invisible_time = 1;
		toucher.invisible_finished = time + 30;
	}

	cname = ((MP_ROGUE) ? (this.netname == "Quad Damage") : (this.classname == "item_artifact_super_damage"));
	if(cname)
	{
		toucher.super_time = 1;
		toucher.super_damage_finished = time + 30;
	}	
	SUB_UseTargets(this, toucher, NULL);				// fire all targets / killtargets
}



/*QUAKED item_artifact_invulnerability(0 .5 .8)(-16 -16 -24)(16 16 32)
Player is invulnerable for 30 seconds
*/
spawnfunc(item_artifact_invulnerability)
{
	settouch(this, powerup_touch);

	precache_model("progs/invulner.mdl");
	precache_sound("items/protect.wav");
	precache_sound("items/protect2.wav");
	precache_sound("items/protect3.wav");
	this.noise = "items/protect.wav";
	_setmodel(this, "progs/invulner.mdl");
	this.netname = "Pentagram of Protection";
	this.items = IT_INVULNERABILITY;
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}

/*QUAKED item_artifact_envirosuit(0 .5 .8)(-16 -16 -24)(16 16 32)
Player takes no damage from water or slime for 30 seconds
*/
spawnfunc(item_artifact_envirosuit)
{
	settouch(this, powerup_touch);

	precache_model("progs/suit.mdl");
	precache_sound("items/suit.wav");
	precache_sound("items/suit2.wav");
	this.noise = "items/suit.wav";
	_setmodel(this, "progs/suit.mdl");
	this.netname = "Biosuit";
	this.items = IT_SUIT;
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}


/*QUAKED item_artifact_invisibility(0 .5 .8)(-16 -16 -24)(16 16 32)
Player is invisible for 30 seconds
*/
spawnfunc(item_artifact_invisibility)
{
	settouch(this, powerup_touch);

	precache_model("progs/invisibl.mdl");
	precache_sound("items/inv1.wav");
	precache_sound("items/inv2.wav");
	precache_sound("items/inv3.wav");
	this.noise = "items/inv1.wav";
	_setmodel(this, "progs/invisibl.mdl");
	this.netname = "Ring of Shadows";
	this.items = IT_INVISIBILITY;
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}


/*QUAKED item_artifact_super_damage(0 .5 .8)(-16 -16 -24)(16 16 32)
The next attack from the player will do 4x damage
*/
spawnfunc(item_artifact_super_damage)
{
	settouch(this, powerup_touch);

	precache_model("progs/quaddama.mdl");
	precache_sound("items/damage.wav");
	precache_sound("items/damage2.wav");
	precache_sound("items/damage3.wav");
	this.noise = "items/damage.wav";
	_setmodel(this, "progs/quaddama.mdl");
	this.netname = "Quad Damage";
	this.items = IT_QUAD;
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}



/*
===============================================================================

PLAYER BACKPACKS

===============================================================================
*/

void BackpackTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;

	if(MP_ROGUE && toucher == this.owner && ((this.nextthink - time) > 119))
		return; // don't let owner pick up his own backpack for a second

	bool acount = false;
	sprint(toucher, "You get ");

	if(this.items)
		if((toucher.items & this.items) == 0)
		{
			acount = true;
			sprint(toucher, "the ");
			sprint(toucher, this.netname);
		}

// if the player was using his best weapon, change up to the new one if better
	//int best = W_BestWeapon(toucher);

// change weapons
	if(MP_ROGUE)
	{
		toucher.ammo_shells1 = toucher.ammo_shells1 + this.ammo_shells1;
		toucher.ammo_nails1 = toucher.ammo_nails1 + this.ammo_nails1;
		toucher.ammo_rockets1 = toucher.ammo_rockets1 + this.ammo_rockets1;
		toucher.ammo_cells1 = toucher.ammo_cells1 + this.ammo_cells1;
		toucher.ammo_lava_nails += this.ammo_lava_nails;
		toucher.ammo_multi_rockets += this.ammo_multi_rockets;
		toucher.ammo_plasma += this.ammo_plasma;
	}
	else
	{
		toucher.ammo_shells = toucher.ammo_shells + this.ammo_shells;
		toucher.ammo_nails = toucher.ammo_nails + this.ammo_nails;
		toucher.ammo_rockets = toucher.ammo_rockets + this.ammo_rockets;
		toucher.ammo_cells = toucher.ammo_cells + this.ammo_cells;
	}

	int newitem = this.items;
	//if(!newitem)
		//newitem = toucher.weapon;
	int old = toucher.items;
	if(newitem)
		toucher.items |= newitem;
	
	bound_other_ammo(toucher);

	if(MP_ROGUE)
	{
		if(this.ammo_shells1)
		{
			if(acount)
				sprint(toucher, ", ");
			acount = true;
			sprint(toucher, sprintf("%d shells", this.ammo_shells1));
		}
		if(this.ammo_nails1)
		{
			if(acount)
				sprint(toucher, ", ");
			acount = true;
			sprint(toucher, sprintf("%d nails", this.ammo_nails1));
		}
		if(this.ammo_rockets1)
		{
			if(acount)
				sprint(toucher, ", ");
			acount = true;
			sprint(toucher, sprintf("%d rockets", this.ammo_rockets1));
		}
		if(this.ammo_cells1)
		{
			if(acount)
				sprint(toucher, ", ");
			acount = true;
			sprint(toucher, sprintf("%d cells", this.ammo_cells1));
		}
		if(this.ammo_lava_nails)
		{
			if(acount)
				sprint(toucher, ", ");
			acount = true;
			sprint(toucher, sprintf("%d cells", this.ammo_lava_nails));
		}
		if(this.ammo_multi_rockets)
		{
			if(acount)
				sprint(toucher, ", ");
			acount = true;
			sprint(toucher, sprintf("%d cells", this.ammo_multi_rockets));
		}
		if(this.ammo_plasma)
		{
			if(acount)
				sprint(toucher, ", ");
			acount = true;
			sprint(toucher, sprintf("%d cells", this.ammo_plasma));
		}
	}
	else
	{
		if(this.ammo_shells)
		{
			if(acount)
				sprint(toucher, ", ");
			acount = true;
			sprint(toucher, sprintf("%d shells", this.ammo_shells));
		}
		if(this.ammo_nails)
		{
			if(acount)
				sprint(toucher, ", ");
			acount = true;
			sprint(toucher, sprintf("%d nails", this.ammo_nails));
		}
		if(this.ammo_rockets)
		{
			if(acount)
				sprint(toucher, ", ");
			acount = true;
			sprint(toucher, sprintf("%d rockets", this.ammo_rockets));
		}
		if(this.ammo_cells)
		{
			if(acount)
				sprint(toucher, ", ");
			acount = true;
			sprint(toucher, sprintf("%d cells", this.ammo_cells));
		}
	}
	
	sprint(toucher, "\n");
// backpack touch sound
	_sound(toucher, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");

// remove the backpack, change this to the player
	delete(this);

	if(MP_ROGUE)
		EnableComboWeapons(toucher);

// change to the weapon
	if(newitem)
	if(!deathmatch)
		W_SwitchWeapon(toucher, newitem);
	else
		Deathmatch_Weapon(toucher, old, newitem);

	if(MP_ROGUE)
		UpdateAmmoCounts(toucher);
}

/*
===============
DropBackpack
===============
*/
void DropBackpack(entity this)
{
	// this is to compensate for the new way we're hacking the ammo
	// counts. If they're monsters, just copy shells->shells1 etc.
	if(MP_ROGUE && IS_MONSTER(this))
	{
		this.ammo_shells1 = this.ammo_shells;
		this.ammo_nails1 = this.ammo_nails;
		this.ammo_rockets1 = this.ammo_rockets;
		this.ammo_cells1 = this.ammo_cells;

		if(!(this.ammo_shells1 + this.ammo_nails1 + this.ammo_rockets1 + this.ammo_cells1 + 
				this.ammo_lava_nails + this.ammo_multi_rockets))
			return;	// nothing in it
	}
	else if(!(this.ammo_shells + this.ammo_nails + this.ammo_rockets + this.ammo_cells))
			return;	// nothing in it

	entity item = spawn();
	item.origin = this.origin - '0 0 24';
	
	item.items = this.weapon;
	switch(this.items)
	{
		case IT_AXE: 				item.netname = "Axe"; break;
		case IT_SHOTGUN: 			item.netname = "Shotgun"; break;
		case IT_SUPER_SHOTGUN: 		item.netname = "Double-barrelled Shotgun"; break;
		case IT_NAILGUN: 			item.netname = "Nailgun"; break;
		case IT_SUPER_NAILGUN: 		item.netname = "Super Nailgun"; break;
		case IT_GRENADE_LAUNCHER: 	item.netname = "Grenade Launcher"; break;
		case IT_ROCKET_LAUNCHER: 	item.netname = "Rocket Launcher"; break;
		case IT_LIGHTNING: 			item.netname = "Thunderbolt"; break;
		case IT_LASER_CANNON: 		item.netname = "Laser Cannon"; break;
		case IT_PROXIMITY_GUN: 		item.netname = "Proximity Gun"; break;
		case IT_MJOLNIR: 			item.netname = "Mjolnir"; break;
		case IT_LAVA_NAILGUN: 		item.netname = "Lava Nail Gun"; break;
		case IT_LAVA_SUPER_NAILGUN: item.netname = "Super Lava Nail Gun"; break;
		case IT_MULTI_GRENADE: 		item.netname = "Multi Grenade Launcher"; break;
		case IT_MULTI_ROCKET: 		item.netname = "Multi Rocket Launcher"; break;
		case IT_PLASMA_GUN: 		item.netname = "Plasma Gun"; break;
		default: 					item.netname = ""; break;
	}

	if(MP_ROGUE)
	{
		item.ammo_shells1 = this.ammo_shells1;
		item.ammo_nails1 = this.ammo_nails1;
		item.ammo_rockets1 = this.ammo_rockets1;
		item.ammo_cells1 = this.ammo_cells1;
		item.ammo_lava_nails = this.ammo_lava_nails;
		item.ammo_multi_rockets = this.ammo_multi_rockets;
		item.ammo_plasma = this.ammo_plasma;
	}
	else
	{
		item.ammo_shells = this.ammo_shells;
		item.ammo_nails = this.ammo_nails;
		item.ammo_rockets = this.ammo_rockets;
		item.ammo_cells = this.ammo_cells;
	}

	item.velocity_z = 300;
	item.velocity_x = -100 +(random() * 200);
	item.velocity_y = -100 +(random() * 200);
	
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	set_movetype(item, MOVETYPE_TOSS);
	_setmodel(item, "progs/backpack.mdl");
	setsize(item, '-16 -16 0', '16 16 56');
	settouch(item, BackpackTouch);
	
	item.nextthink = time + 120;	// remove after 2 minutes
	setthink(item, SUB_Remove);
}
