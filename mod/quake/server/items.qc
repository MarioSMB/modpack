#include "items.qh"

#include "rogue/rogue.qh"
#include "triggers/subs.qh"
#include "triggers/triggers.qh"
#include "weapons.qh"

void W_SwitchWeapon(entity this, float to_wep);
void W_SetCurrentAmmo(entity this);
/* ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD
BE .8 .3 .4 IN COLOR */


void SUB_regen(entity this)
{
	this.model = this.mdl;		// restore original model
	this.solid = SOLID_TRIGGER;	// allow it to be touched again
	_sound(this, CH_VOICE, "items/itembk2.wav", 1, ATTN_NORM);	// play respawn sound
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
	if(MP_MG && (this.spawnflags & DROPTOFLOOR_DISABLE))
		set_movetype(this, MOVETYPE_NONE);
	else
		set_movetype(this, MOVETYPE_TOSS);	
	this.velocity = '0 0 0';
	this.origin_z = this.origin_z + 6;
	this.m_min = this.mins;
	this.m_max = this.maxs;
	setthink(this, FixItem);
	this.nextthink = time + 1; // initial delay
	droptofloor(this);
}

/*
============
StartItem

Sets the clipping size and plants the object on the floor
============
*/
void StartItem(entity this)
{
	if(MP_MG && (Inhibit_Coop(this) || RemovedOutsideCoop(this)))
	{
		delete(this);
		return;
	}
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

	// AY Dec13 2021, horde rune of hunger
	if(MP_MG && autocvar_horde && (serverflags & 2))
		e.hunger_time = time + HUNGER_MAX;

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
	else if(this.spawnflags & H_MEGA)
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
	if(MP_IMPEL && toucher.exptime != 0)
		return;
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

	// NOTE: disabling spammy message as you already know from the HUD that you got it!
	//sprint(toucher, sprintf("You receive %d health\n", this.healamount));
	
// health touch sound
	_sound(toucher, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);

	stuffcmd(toucher, "bf\n");
	
	this.model = string_null;
	this.solid = SOLID_NOT;

	// Megahealth = rot down the player's super health
	if(this.healtype == 2 && (!MP_ROGUE || !RuneHasElder(toucher)))
	{
		if(!MP_HIPNOTIC)
			toucher.items |= IT_SUPERHEALTH;

		toucher.healthrot_nextcheck = time + 5;
	}

	if(deathmatch && deathmatch != 2) // deathmatch 2 is the silly old rules
	{
		if(this.healtype == 2)
			this.nextthink = time + 120;
		else
			this.nextthink = time + 20;
		setthink(this, SUB_regen);
	}
	else if(MP_MG && this.wait)
	{
		this.enemy = NULL;
		this.nextthink = time + this.wait;
		setthink(this, SUB_regen);
	}

	SUB_UseTargets(this, toucher, NULL);				// fire all targets / killtargets
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

	float type = 0.3, value = 100;
	int bit = IT_ARMOR1;

	if(this.classname == "item_armor1")
	{
		type = 0.3;
		value = 100;
		bit = IT_ARMOR1;
	}
	else if(this.classname == "item_armor2")
	{
		type = 0.6;
		value = 150;
		bit = IT_ARMOR2;
	}
	else if(this.classname == "item_armorInv")
	{
		type = 0.8;
		value = 200;
		bit = IT_ARMOR3;
	}
	if(toucher.armortype*toucher.armorvalue >= type * value)
		return;
		
	toucher.armortype = type;
	toucher.armorvalue = value;
	toucher.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
	toucher.items |= bit;

	this.solid = SOLID_NOT;
	this.model = string_null;
	if(deathmatch && deathmatch != 2)
	{
		this.nextthink = time + 20;
		setthink(this, SUB_regen);
	}

	// NOTE: disabling spammy message as you already know from the HUD that you got it!
	//sprint(toucher, "You got armor\n");
// armor touch sound
	_sound(toucher, CH_TRIGGER_SINGLE, "items/armor1.wav", 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");

	SUB_UseTargets(this, toucher, NULL);				// fire all targets / killtargets
}


/*QUAKED item_armor1(0 .5 .8)(-16 -16 0)(16 16 32)
*/

spawnfunc(item_armor1)
{
	settouch(this, armor_touch);
	this.armortype = 0.3;
	this.armorvalue = 100;
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
	this.armortype = 0.6;
	this.armorvalue = 150;
	precache_model("progs/armor.mdl");
	_setmodel(this, "progs/armor.mdl");
	this.skin = 1;
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

/*QUAKED item_armorInv(0 .5 .8)(-16 -16 0)(16 16 32)
*/
spawnfunc(item_artifact_field_generator);

spawnfunc(item_armorInv)
{
	settouch(this, armor_touch);
	this.armortype = 0.8;
	this.armorvalue = 200;
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

void bound_other_ammo(entity this)
{
	if(this.ammo_shells > 100)
		this.ammo_shells = 100;
	if(this.ammo_nails > 200)
		this.ammo_nails = 200;
	if(this.ammo_rockets > 100)
		this.ammo_rockets = 100;		
	if(this.ammo_cells > 100)
		this.ammo_cells = 100;

	// rogue
	if(this.ammo_lava_nails > 200)
		this.ammo_lava_nails = 200;
	if(this.ammo_multi_rockets > 100)
		this.ammo_multi_rockets = 100;
	if(this.ammo_plasma > 100)
		this.ammo_plasma = 100;
}

int RankForWeapon(int w)
{
	switch(w)
	{
		case WEP_PLASMA_GUN:		return 1;
		case WEP_LIGHTNING: 		return 2;
		case WEP_PULSERIFLE: 		return 3;
		case WEP_MULTI_ROCKET: 		return 4;
		case WEP_ROCKET_LAUNCHER: 	return 5;
		case WEP_LIGHTME: 			return 6;
		case WEP_LASER_CANNON: 		return 7;
		case WEP_SPEAR: 			return 8;
		case WEP_LAVA_SUPER_NAILGUN:return 9;
		case WEP_SUPER_NAILGUN: 	return 10;
		case WEP_MULTI_GRENADE: 	return 11;
		case WEP_PROXIMITY_GUN: 	return 12;
		case WEP_GRENADE_LAUNCHER: 	return 13;
		case WEP_NAPALM: 			return 14;
		case WEP_LAVA_NAILGUN: 		return 15;
		case WEP_SUPER_SHOTGUN: 	return 16;
		case WEP_NAILGUN: 			return 17;
		case WEP_MJOLNIR: 			return 18;
		default: 					return 19;
	}
}

/*
=============
Deathmatch_Weapon

Deathmatch weapon change rules for picking up a weapon

.int		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
=============
*/
void Deathmatch_Weapon(entity this, int old, int new)
{
	if(MP_ROGUE && this.weapon == WEP_GRAPPLE && this.button0)
		return;

// change this.weapon if desired
	int or = RankForWeapon(this.weapon);
	int nr = RankForWeapon(new);
	if(nr < or)
		W_SwitchWeapon(this, new);
}

bool weapon_customize(entity this, entity client)
{
	if((deathmatch == 2 || coop) && (client.weapons & this.weapon))
		return false;
	return true;
}

void EnableComboWeapons(entity this)
{
	if(!IS_PLAYER(this))
		return;
	
	if (!(this.weapons & WEP_LAVA_NAILGUN))
	{
		if (this.ammo_lava_nails > 0 && (this.weapons & WEP_NAILGUN))
		{
			// NOTE: disabling spammy message as you already know from the HUD that you got it!
			//sprint (this, "Lava Enabled\n");
			this.weapons |= WEP_LAVA_NAILGUN;
		}
	}

	if (!(this.weapons & WEP_LAVA_SUPER_NAILGUN))
	{
		if (this.ammo_lava_nails > 0 && 
							(this.weapons & WEP_SUPER_NAILGUN))
		{
			// NOTE: disabling spammy message as you already know from the HUD that you got it!
			//sprint (this, "Super Lava Enabled\n");
			this.weapons |= WEP_LAVA_SUPER_NAILGUN;		
		}
	}

	if (!(this.weapons & WEP_MULTI_GRENADE))
	{
		if (this.ammo_multi_rockets > 0 && 
							(this.weapons & WEP_GRENADE_LAUNCHER))
		{
			// NOTE: disabling spammy message as you already know from the HUD that you got it!
			//sprint (this, "Multi Grenades Enabled\n");
			this.weapons |= WEP_MULTI_GRENADE;		
		}
	}

	if (!(this.weapons & WEP_MULTI_ROCKET))
	{
		if (this.ammo_multi_rockets > 0 && 
							(this.weapons & WEP_ROCKET_LAUNCHER))
		{
			// NOTE: disabling spammy message as you already know from the HUD that you got it!
			//sprint (this, "Multi Rockets Enabled\n");
			this.weapons |= WEP_MULTI_ROCKET;		
		}
	}

	if (!(this.weapons & WEP_PLASMA_GUN))
	{
		if (this.ammo_plasma > 0 && (this.weapons & WEP_LIGHTNING))
		{
			// NOTE: disabling spammy message as you already know from the HUD that you got it!
			//sprint (this, "Plasma Gun Enabled\n");
			this.weapons |= WEP_PLASMA_GUN;		
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
	if(toucher.health <= 0)
		return;
	if(!IS_CLIENT(toucher))
		return;

	int hadammo = 0, newitem = toucher.weapon;
// if the player was using their best weapon, change up to the new one if better		
	//int best = W_BestWeapon(toucher);

	bool leave = (coop || deathmatch == 2 || deathmatch == 3 || deathmatch == 5);
	
	switch(this.classname)
	{
		case "weapon_nailgun":
		{
			if(leave && (toucher.weapons & WEP_NAILGUN))
				return;
			hadammo = toucher.ammo_nails;			
			newitem = WEP_NAILGUN;
			if(MP_ROGUE && leave)
				toucher.ammo_lava_nails += 20;
			toucher.ammo_nails = toucher.ammo_nails + 30;
			break;
		}
		case "weapon_supernailgun":
		{
			if(leave && (toucher.weapons & WEP_SUPER_NAILGUN))
				return;
			hadammo = toucher.ammo_rockets;			
			newitem = WEP_SUPER_NAILGUN;
			if(MP_ROGUE && leave)
				toucher.ammo_lava_nails += 20;
			toucher.ammo_nails = toucher.ammo_nails + 30;
			break;
		}
		case "weapon_supershotgun":
		{
			if(leave && (toucher.weapons & WEP_SUPER_SHOTGUN))
				return;
			hadammo = toucher.ammo_rockets;		
			newitem = WEP_SUPER_SHOTGUN;
			toucher.ammo_shells = toucher.ammo_shells + 5;
			break;
		}
		case "weapon_rocketlauncher":
		{
			if(leave && (toucher.weapons & WEP_ROCKET_LAUNCHER))
				return;
			hadammo = toucher.ammo_rockets;		
			newitem = WEP_ROCKET_LAUNCHER;
			if(MP_ROGUE && leave)
				toucher.ammo_multi_rockets += 3;
			toucher.ammo_rockets = toucher.ammo_rockets + 5;
			break;
		}
		case "weapon_grenadelauncher":
		{
			if(leave && (toucher.weapons & WEP_GRENADE_LAUNCHER))
				return;
			hadammo = toucher.ammo_rockets;			
			newitem = WEP_GRENADE_LAUNCHER;
			toucher.ammo_rockets = toucher.ammo_rockets + 5;
			break;
		}
		case "weapon_lightning":
		{
			if(leave && (toucher.weapons & WEP_LIGHTNING))
				return;
			hadammo = toucher.ammo_rockets;			
			newitem = WEP_LIGHTNING;
			if(MP_ROGUE && leave)
				toucher.ammo_plasma += 5;
			toucher.ammo_cells = toucher.ammo_cells + 15;
			break;
		}
		case "weapon_laser_gun":
		{
	      	if(leave && (toucher.weapons & WEP_LASER_CANNON))
				return;
			hadammo = toucher.ammo_rockets;
	      	newitem = WEP_LASER_CANNON;
			toucher.ammo_cells = toucher.ammo_cells + 30;
	      	break;
		}
	   	case "weapon_mjolnir":
		{
	      	if (leave && (toucher.weapons & WEP_MJOLNIR) )
				return;
			hadammo = toucher.ammo_rockets;
	      	newitem = WEP_MJOLNIR;
			toucher.ammo_cells = toucher.ammo_cells + 30;
	      	break;
		}
	   	case "weapon_proximity_gun":
		{
	      	if(leave && (toucher.weapons & WEP_PROXIMITY_GUN) )
				return;
			hadammo = toucher.ammo_rockets;
	      	newitem = WEP_PROXIMITY_GUN;
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
		Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, ITEM_WEAPON_GOT, this.netname);
	else
		Send_Notification(NOTIF_ONE, toucher, MSG_INFO, INFO_ITEM_WEAPON_PICKUP);
// weapon touch sound
	_sound(toucher, CH_TRIGGER_SINGLE, "weapons/pkup.wav", 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");

	bound_other_ammo(toucher);

// change to the weapon
	int old = toucher.weapons;
	toucher.weapons |= newitem;

	if(MP_ROGUE)
		EnableComboWeapons(toucher);

	// PGM - fake picking up the plasma gun.
	if(!MP_ROGUE) { /* do nothing */ }
	else if(newitem == WEP_LIGHTNING)
	{
		if(toucher.ammo_plasma > 0)
			newitem = WEP_PLASMA_GUN;
	}
	else if(newitem == WEP_ROCKET_LAUNCHER)
	{
		if(toucher.ammo_multi_rockets > 0)
			newitem = WEP_MULTI_ROCKET;
	}
	else if(newitem == WEP_GRENADE_LAUNCHER)
	{
		if(toucher.ammo_multi_rockets > 0)
			newitem = WEP_MULTI_GRENADE;
	}
	else if(newitem == WEP_SUPER_NAILGUN)
	{
		if(toucher.ammo_lava_nails > 1)
			newitem = WEP_LAVA_SUPER_NAILGUN;
	}
	else if(newitem == WEP_NAILGUN)
	{
		if(toucher.ammo_lava_nails > 0)
			newitem = WEP_LAVA_NAILGUN;
	}

	if(W_WantsToChangeWeapon(toucher, old, newitem))
	{
		if(!deathmatch)
			W_SwitchWeapon(toucher, newitem);
		else
			Deathmatch_Weapon(toucher, old, newitem);
	}

	// Moved up so the targets are fired even in coop, but only once.
	if(MP_MG)
		SUB_UseTargets(this, toucher, NULL);

	if(leave)
	{
		if(MP_MG)
			this.target = string_null;
		if(MP_IMPEL && this.state == 0)
		{
			SUB_UseTargets(this, toucher, NULL);
			this.state = H_ROTTEN;
		}
		return;
	}

// remove it in single player, or setup for respawning in deathmatch
	this.model = string_null;
	this.solid = SOLID_NOT;
	if(deathmatch && deathmatch != 2)
	{
		this.nextthink = time + 30;
		setthink(this, SUB_regen);
	}
	else if(MP_MG && this.wait)
	{
		this.nextthink = time + this.wait;
		setthink(this, SUB_regen);
	}

	if(!MP_MG)
		SUB_UseTargets(this, toucher, NULL);				// fire all targets / killtargets
}


/*QUAKED weapon_supershotgun(0 .5 .8)(-16 -16 0)(16 16 32)
*/

spawnfunc(weapon_grenadelauncher);
spawnfunc(weapon_supershotgun)
{
	if(world.model == "maps/aop2m3.bsp")
	{
		this.classname = "weapon_grenadelauncher";
		spawnfunc_weapon_grenadelauncher(this);
		return;
	}
	precache_model("progs/g_shot.mdl");
	_setmodel(this, "progs/g_shot.mdl");
	this.weapon = WEP_SUPER_SHOTGUN;
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
	this.weapon = WEP_NAILGUN;
	this.netname = "Nailgun";
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
	this.weapon = WEP_SUPER_NAILGUN;
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
	this.weapon = WEP_GRENADE_LAUNCHER;
	this.netname = "Grenade Launcher";
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

/*QUAKED weapon_rocketlauncher(0 .5 .8)(-16 -16 0)(16 16 32)
*/
spawnfunc(weapon_not_a_spear);

spawnfunc(weapon_rocketlauncher)
{
	precache_model("progs/g_rock2.mdl");
	_setmodel(this, "progs/g_rock2.mdl");
	this.weapon = WEP_ROCKET_LAUNCHER;
	this.netname = "Rocket Launcher";
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}


/*QUAKED weapon_lightning(0 .5 .8)(-16 -16 0)(16 16 32)
*/
spawnfunc(weapon_rifle);

spawnfunc(weapon_lightning)
{
	if(world.model == "maps/aop2m2.bsp")
	{
		this.classname = "weapon_rifle";
		spawnfunc_weapon_rifle(this);
		return;
	}
	precache_model("progs/g_light.mdl");
	_setmodel(this, "progs/g_light.mdl");
	this.weapon = WEP_LIGHTNING;
	this.netname = "Thunderbolt";
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

// impel weapons
void impel_weapon_touch(entity this, entity toucher)
{
	if(!IS_CLIENT(toucher))
		return;
	float hadammo = 0;
	int newitems = 0, new = 0;
	bool leave = (deathmatch == 2 || coop);

	if(this.classname == "weapon_lightme")
	{
		if(leave && (toucher.weapons & WEP_LIGHTME))
			return;
		hadammo = toucher.ammo_cells;
		new = WEP_LIGHTME;
		toucher.ammo_cells = toucher.ammo_cells + 12;
	}
	else if(this.classname == "weapon_napalm")
	{
		if(leave && (toucher.weapons & WEP_NAPALM))
			return;
		hadammo = toucher.ammo_rockets;
		new = WEP_NAPALM;
		toucher.ammo_rockets = (toucher.ammo_rockets + 9);
	}
	else if(this.classname == "weapon_not_a_spear")
	{
		if(leave && (toucher.weapons & WEP_SPEAR))
			return;
		hadammo = toucher.ammo_rockets;
		new = WEP_SPEAR;
		toucher.ammo_rockets = toucher.ammo_rockets + 10;
	}
	else if(this.classname == "weapon_rifle")
	{
		if(leave && (toucher.weapons & WEP_PULSERIFLE))
			return;
		hadammo = toucher.ammo_cells;
		new = WEP_PULSERIFLE;
		toucher.ammo_cells = toucher.ammo_cells + 24;
	}
	else if(this.classname == "weapon_rifleupgrade")
	{
		if(leave && (toucher.items & IT_PULSEPOWER2))
			return;
		if(!(toucher.weapons & WEP_PULSERIFLE))
			return;
		hadammo = toucher.ammo_cells;
		toucher.ammo_cells = toucher.ammo_cells + 24;
		if(toucher.items & IT_PULSEPOWER2)
			newitems = IT_PULSEPOWER2;
		else if(toucher.items & IT_PULSEPOWER1)
			newitems = IT_PULSEPOWER2;
		else if(toucher.weapons & WEP_PULSERIFLE)
			newitems = IT_PULSEPOWER1;
		else
			return;
	}
	else
	{
		objerror(this, "impel_weapon_touch: unknown classname");
		return; // don't try to give it anyway!
	}
	if(this.classname == "weapon_rifleupgrade")
	{
		if(toucher.items & IT_PULSEPOWER2)
		{
			_sound(toucher, CHAN_ITEM, "enviro/pinhead/pinfire.wav", 1, ATTN_NORM);
			sprint(toucher, "You got ammo out of the upgrade\n");
		}
		else if(toucher.items & IT_PULSEPOWER1)
		{
			_sound(toucher, CHAN_AUTO, "weapons/pulse/install.wav", 1, ATTN_NORM);
			_sound(toucher, CHAN_ITEM, "enviro/pinhead/pinfire.wav", 1, ATTN_NORM);
			sprint(toucher, "You got the Level III Laser System upgrade\n");
		}
		else if(toucher.weapons & WEP_PULSERIFLE)
		{
			_sound(toucher, CHAN_AUTO, "weapons/pulse/install.wav", 1, ATTN_NORM);
			_sound(toucher, CHAN_ITEM, "enviro/pinhead/pinfire.wav", 1, ATTN_NORM);
			sprint(toucher, "You got the Level II Laser System upgrade\n");
		}
		else
			return;
	}
	else
		Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, ITEM_WEAPON_GOT, this.netname);
	if(this.classname == "weapon_rifle")
	{
		_sound(toucher, CHAN_AUTO, "weapons/pulse/install.wav", 1, ATTN_NORM);
		_sound(toucher, CHAN_WEAPON, "enviro/pinhead/pinfire.wav", 1, ATTN_NORM);
		if(!(toucher.weapons & WEP_PULSERIFLE))
			centerprint(toucher, "[ ARMOR LASER SYSTEM ACTIVATED ]\n");
	}
	else
		_sound(toucher, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");
	bound_other_ammo(toucher);
	toucher.items |= newitems;
	toucher.weapons |= new;
	if(newitems == IT_PULSEPOWER1 || newitems == IT_PULSEPOWER2)
		new = WEP_PULSERIFLE;
	if(new != WEP_PULSERIFLE) // offhand
	{
		toucher.weapon = new;
		W_SetCurrentAmmo(toucher);
	}
	if(leave)
	{
		if(this.state == 0)
		{
			SUB_UseTargets(this, toucher, NULL);
			this.state = H_ROTTEN;
		}
		return;
	}
	this.model = string_null;
	this.solid = SOLID_NOT;
	if(deathmatch == 1)
	{
		this.nextthink = time + 30;
		setthink(this, SUB_regen);
	}
	SUB_UseTargets(this, toucher, NULL);
}

spawnfunc(weapon_lightme)
{
	if(!MP_IMPEL) { delete(this); return; }

	precache_model("progs/g_light2.mdl");
	_setmodel(this, "progs/g_light2.mdl");
	this.weapon = 3;
	this.netname = "LG-2 Prototype";
	settouch(this, impel_weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

spawnfunc(weapon_rifle)
{
	if(!MP_IMPEL) { delete(this); return; }

	precache_model("progs/g_tek.mdl");
	_setmodel(this, "progs/g_tek.mdl");
	this.weapon = WEP_LIGHTME;
	this.netname = "Armor Laser System";
	settouch(this, impel_weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

spawnfunc(weapon_rifleupgrade)
{
	if(!MP_IMPEL) { delete(this); return; }

	precache_model("progs/wing.mdl");
	_setmodel(this, "progs/wing.mdl");
	this.weapon = WEP_PULSERIFLE;
	this.netname = "Laser System Upgrade";
	settouch(this, impel_weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

spawnfunc(weapon_napalm)
{
	if(!MP_IMPEL) { delete(this); return; }

	precache_model("progs/g_rock.mdl");
	_setmodel(this, "progs/g_rock.mdl");
	this.weapon = WEP_NAPALM;
	this.netname = "Napalm Gun";
	settouch(this, impel_weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

spawnfunc(weapon_not_a_spear)
{
	if(!MP_IMPEL) { delete(this); return; }

	precache_model("progs/g_implr.mdl");
	_setmodel(this, "progs/g_implr.mdl");
	this.weapon = WEP_SPEAR;
	this.netname = "Rocket Powered Impaler";
	settouch(this, impel_weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

#if 0
void Impel_powerup_touch(entity this, entity toucher)
{
	if(toucher.classname != "player" || toucher.health <= 0)
		return;
	sprint(toucher, sprintf("You got the %s\n", this.netname));
	if(deathmatch)
	{
		this.mdl = this.model;
		this.nextthink = time + 60;
		setthink(this, SUB_regen);
	}
	_sound(toucher, CHAN_VOICE, this.noise, 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");
	this.solid = SOLID_NOT;
	this.model = string_null;
	SUB_UseTargets(this, toucher, NULL);
}
#endif


/*
===============================================================================

AMMO

===============================================================================
*/

void ammo_touch(entity this, entity toucher)
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
		toucher.ammo_shells += this.aflag;
	}

// spikes
	if(this.weapon == 2)
	{
		if(toucher.ammo_nails >= 200)
			return;
		toucher.ammo_nails += this.aflag;
	}

//	rockets
	if(this.weapon == 3)
	{
		if(toucher.ammo_rockets >= 100)
			return;
		toucher.ammo_rockets += this.aflag;
	}

//	cells
	if(this.weapon == 4)
	{
		if(toucher.ammo_cells >= 100)
			return;
		toucher.ammo_cells += this.aflag;
	}

	// lava nails
	if(this.weapon == 5)
	{
		if(toucher.ammo_lava_nails >= 200)
			return;
		toucher.ammo_lava_nails += this.aflag;
	}

	// multi rockets
	if(this.weapon == 6)
	{
		if(toucher.ammo_multi_rockets >= 100)
			return;
		toucher.ammo_multi_rockets += this.aflag;
	}

	// plasma
	if(this.weapon == 7)
	{
		if(toucher.ammo_plasma >= 100)
			return;
		toucher.ammo_plasma += this.aflag;
	}

	bound_other_ammo(toucher);

	if(this.netname != "")
		Send_Notification(NOTIF_ONE, toucher, MSG_INFO, INFO_ITEM_AMMO_GOT, this.netname, this.aflag);
	else
		Send_Notification(NOTIF_ONE, toucher, MSG_INFO, INFO_ITEM_AMMO_PICKUP); // TODO: icon?
// ammo touch sound
	_sound(toucher, CH_TRIGGER_SINGLE, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");

// change to a better weapon if appropriate

	if(toucher.weapon == best && W_WantsToChangeWeapon(toucher, 0, 1))
		W_SwitchWeapon(toucher, W_BestWeapon(toucher, 0));

// if changed current ammo, update it
	W_SetCurrentAmmo(toucher);

// remove it in single player, or setup for respawning in deathmatch
	this.model = string_null;
	this.solid = SOLID_NOT;

	setthink(this, SUB_regen);
	if(coop && (!MP_MG || this.wait <= 0)) //Wait overrides coop respawn behaviour
	{
		this.cnt++;
		int num_players = 0;
		FOREACH_CLIENT(IS_PLAYER(it),
		{
			num_players += 1;
		});
		if(this.cnt < num_players) //Not been picked up by all players yet.
		{
			this.nextthink = time + 1; 
			setthink(this, SUB_regen); // Respawn almost immediately
		}
		else
		{
			this.enemy = NULL;
			this.cnt = 0;
			this.nextthink = time + 4 * 60;
			setthink(this, SUB_regen); // Respawn after 4 mins in case the players get stuck on something hard.
		}
	}
	else if(deathmatch)
	{
		if(deathmatch == 3 || deathmatch == 5)
			this.nextthink = time + 15;
		else if(deathmatch != 2)
			this.nextthink = time + 30;
	}
	else if(MP_MG && this.wait)
	{
		this.enemy = NULL;
		this.nextthink = time + this.wait;
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
		this.weapon = WEP_SHOTGUN;
		this.netname = "shells";
	}

	if(this.spawnflags & WEAPON_SPIKES)
	{
		if(this.spawnflags & WEAPON_BIG)
		{
			setmodel(this, MDL_ITEM_NAILS_BIG);
			this.aflag = 40;
			this.weapon = WEP_SUPER_NAILGUN;
		}
		else
		{
			setmodel(this, MDL_ITEM_NAILS);
			this.aflag = 20;
			this.weapon = WEP_NAILGUN;
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
		this.weapon = WEP_ROCKET_LAUNCHER;
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

	string keyname = (this.netname != "") ? this.netname : "key";
	Send_Notification(NOTIF_ALL_EXCEPT, toucher, MSG_MULTI, ITEM_KEY_GOT, toucher.netname, keyname);
	Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, ITEM_KEY_GOT_SELF, keyname);

	_sound(toucher, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");
	toucher.items |= this.items;

	if(!coop)
	{	
		this.solid = SOLID_NOT;
		this.model = string_null;
	}
	SUB_UseTargets(this, toucher, NULL);				// fire all targets / killtargets
	if(MP_MG)
		this.target = string_null; // only fire the trigger once though
}

bool key_customize(entity this, entity client)
{
	return !(client.items & this.items);
}

void key_setsounds(entity this)
{
	// yoder mod jan 13, 2021
	if(this.worldtype == WORLDTYPE_MEDIEVAL)
	{
		precache_sound("misc/medkey.wav");
		this.noise = "misc/medkey.wav";
	}
	if(this.worldtype == WORLDTYPE_METAL)
	{
		precache_sound("misc/runekey.wav");
		this.noise = "misc/runekey.wav";
	}
	if(this.worldtype == WORLDTYPE_BASE)
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
	SUB_SetWorldtype(this);
	if(this.worldtype == WORLDTYPE_MEDIEVAL || this.worldtype == WORLDTYPE_HUB)
	{
		setmodel(this, MDL_ITEM_SILVERKEY);
		this.netname = "silver key";
	}
	else if(this.worldtype == WORLDTYPE_METAL)
	{
		setmodel(this, MDL_ITEM_SILVERRUNEKEY);
		this.netname = "silver runekey";
	}
	else if(this.worldtype == WORLDTYPE_BASE)
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
	SUB_SetWorldtype(this);
	if(this.worldtype == WORLDTYPE_MEDIEVAL || this.worldtype == WORLDTYPE_HUB)
	{
		setmodel(this, MDL_ITEM_GOLDKEY);
		this.netname = "gold key";
	}
	if(this.worldtype == WORLDTYPE_METAL)
	{
		setmodel(this, MDL_ITEM_GOLDRUNEKEY);
		this.netname = "gold runekey";
	}
	if(this.worldtype == WORLDTYPE_BASE)
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

	_sound(toucher, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");
	this.solid = SOLID_NOT;
	this.model = string_null;
	this.classname = ""; // so rune doors won't find it
	if(MP_MG)
	{
		int lastPickup = SUB_LeftShift(this.spawnflags & SIGIL_ALL, SIGIL_NUMBITS);
    	serverflags |= (this.spawnflags & SIGIL_ALL) | lastPickup;
	}
	else
		serverflags = serverflags | (this.spawnflags & 15);
	if(MP_MG && autocvar_horde && (this.spawnflags & SIGIL_E2)) // Hunger
	{
		FOREACH_CLIENT(IS_PLAYER(it),
		{
			it.hunger_time = time + HUNGER_MAX;
		});
	}

	SUB_UseTargets(this, toucher, NULL); // fire all targets / killtargets
}

int sigil_getLastPickup()
{
    int lastPickup = SUB_RightShift(serverflags, SIGIL_NUMBITS) & SIGIL_ALL;
    return lastPickup;
}

void sigil_clearLastPickup()
{
    serverflags &= ~SUB_LeftShift(SIGIL_ALL, SIGIL_NUMBITS);
}

/*QUAKED item_sigil(0 .5 .8)(-16 -16 -24)(16 16 32) E1 E2 E3 E4
End of level sigil, pick up to end episode and return to jrstart.
*/

spawnfunc(item_sigil)
{
	if(!this.spawnflags)
		this.spawnflags |= SIGIL_E1;

	precache_sound("misc/runekey.wav");
	this.noise = "misc/runekey.wav";

	if(this.spawnflags & SIGIL_E1)
	{
		this.spawnflags = SIGIL_E1;
		precache_model("progs/end1.mdl");
		_setmodel(this, "progs/end1.mdl");
	}
	if(this.spawnflags & SIGIL_E2)
	{
		this.spawnflags = SIGIL_E2;
		precache_model2("progs/end2.mdl");
		_setmodel(this, "progs/end2.mdl");
	}
	if(this.spawnflags & SIGIL_E3)
	{
		this.spawnflags = SIGIL_E3;
		precache_model2("progs/end3.mdl");
		_setmodel(this, "progs/end3.mdl");
	}
	if(this.spawnflags & SIGIL_E4)
	{
		this.spawnflags = SIGIL_E4;
		precache_model2("progs/end4.mdl");
		_setmodel(this, "progs/end4.mdl");
	}
	
	settouch(this, sigil_touch);
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}

const int RUNE_INDICATOR_ACTIVE = 64;

void misc_rune_indicator_use(entity this, entity actor, entity trigger)
{
	this.alpha = 1.0;
	SUB_UseTargets(this, actor, trigger);
}

void misc_rune_indicator_usetargets(entity this)
{
	SUB_UseTargets(this, NULL, NULL);
}

spawnfunc(misc_rune_indicator)
{
	if(!MP_MG) { delete(this); return; }
	bool isactive = (this.spawnflags & RUNE_INDICATOR_ACTIVE);
	this.spawnflags &= ~RUNE_INDICATOR_ACTIVE;
	if(!this.spawnflags)
		this.spawnflags |= SIGIL_E1;
	this.spawnflags &= SIGIL_ALL_ALL_ALLLL;

    string mymdl = string_null;

	if(this.spawnflags & SIGIL_E1)
	{
        this.spawnflags = SIGIL_E1;
		mymdl = "progs/mg1_rune1.mdl";
	}
	else if(this.spawnflags & SIGIL_E2)
	{
		this.spawnflags = SIGIL_E2;
        mymdl = "progs/mg1_rune2.mdl";
	}
	else if(this.spawnflags & SIGIL_E3)
	{
		this.spawnflags = SIGIL_E3;
        mymdl = "progs/mg1_rune3.mdl";
	}
	else if(this.spawnflags & SIGIL_E4)
	{
		this.spawnflags = SIGIL_E4;
        mymdl = "progs/mg1_rune4.mdl";
	}
	else if(this.spawnflags & SIGIL_E5)
	{
		this.spawnflags = SIGIL_E5;
        mymdl = "progs/mg1_rune5.mdl";
	}
	else if(this.spawnflags & SIGIL_E6)
	{
		this.spawnflags = SIGIL_E6;
        mymdl = "progs/mg1_rune6.mdl";
	}
    
    precache_model(mymdl);
    _setmodel(this, mymdl);

	this.use = misc_rune_indicator_use;

	if(((this.spawnflags & serverflags) == this.spawnflags) || isactive)
    {
		setthink(this, misc_rune_indicator_usetargets);
		this.nextthink = time + 0.2;
	}
	else
	{
		//Show a ghost of the rune before you collect it.
		this.alpha = 0.2;
	}
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

	string pname = (this.netname != "") ? this.netname : "Powerup";
	Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, ITEM_POWERUP_GOT, pname);

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
	else if(MP_MG && this.wait)
	{
		this.nextthink = time + this.wait;
		setthink(this, SUB_regen);
	}

	_sound(toucher, CH_VOICE, this.noise, 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");
	this.solid = SOLID_NOT;
	toucher.powerups |= this.powerups;
	this.model = string_null;

	if(MP_MG)
		SUB_UseTargets(this, toucher, NULL);

// do the apropriate action
	bool cname;

	cname = ((MP_ROGUE) ? (this.netname == "Biosuit") : (this.classname == "item_artifact_envirosuit"));
	if(cname)
	{
		toucher.rad_time = 1;
		toucher.radsuit_finished = time + 30;
		if(MP_MG && coop) // Respawn biosuit in coop, since it might be required for progression
		{
			this.target = string_null;
			setthink(this, SUB_regen);
			this.nextthink = time + 2.5;
		}
	}

	cname = ((MP_ROGUE) ? (this.netname == "Pentagram of Protection") : (this.classname == "item_artifact_invulnerability"));
	if(cname)
	{
		toucher.invincible_time = 1;
		// Yoder Sept24 2021 Horde Merge
		if(MP_MG && horde_ent)
			toucher.invincible_finished = time + 5;
		else
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
		// Yoder Sept24 2021 Horde Merge
		if(MP_MG && horde_ent)
			toucher.super_damage_finished = time + 5;
		else
			toucher.super_damage_finished = time + 30;
	}
	if(this.netname == "item_artifact_field_generator")
	{
		toucher.field_generator_health = this.health;
		toucher.field_generator_time = -150;
		toucher.field_generator_finished = time + 30;
	}
	if(!MP_MG)
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
	this.powerups = POWERUP_INVULNERABILITY;
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
	this.powerups = POWERUP_SUIT;
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
	this.powerups = POWERUP_INVISIBILITY;
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
	this.powerups = POWERUP_QUAD;
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}


/*QUAKED item_artifact_field_generator(0 .5 .8)(-16 -16 -24)(16 16 32)
Generates a force field around the player
*/
spawnfunc(item_artifact_field_generator)
{
	settouch(this, powerup_touch);
	precache_model("progs/fieldgen.mdl");
	precache_sound("weapons/field/genlev.wav");
	precache_sound("weapons/field/genpulse.wav");
	precache_sound("weapons/field/genhit1.wav");
	precache_sound("weapons/field/genhit2.wav");
	precache_sound("weapons/field/genhit3.wav");
	precache_sound("weapons/field/genactiv.wav");
	precache_sound("weapons/field/genstop.wav");
	this.noise = "weapons/field/genactiv.wav";
	_setmodel(this, "progs/fieldgen.mdl");
	this.netname = "Force Field Generator";
	this.powerups = POWERUP_FIELDGEN;
	setsize(this, '-16 -16 -24', '16 16 32');
	this.health = 200;
	StartItem(this);
};

/*
===============================================================================

PLAYER BACKPACKS

===============================================================================
*/

string cons_sep(string a, string sep, string b)
{
	if (a == "") return b;
	if (b == "") return a;
	return strcat(a, sep, b);
}

void BackpackTouch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;
	if(this.realowner && toucher != this.realowner && IS_PLAYER(this.realowner))
		return; // don't let other players grab a backpack they can't see

	if(MP_ROGUE && toucher == this.owner && ((this.nextthink - time) > 119))
		return; // don't let owner pick up his own backpack for a second

	string wepmsg = "";
	if(this.weapons && !(toucher.weapons & this.weapons) && this.netname && this.netname != "")
		wepmsg = this.netname;

// if the player was using his best weapon, change up to the new one if better
	//int best = W_BestWeapon(toucher);

// change weapons
	toucher.ammo_shells = toucher.ammo_shells + this.ammo_shells;
	toucher.ammo_nails = toucher.ammo_nails + this.ammo_nails;
	toucher.ammo_rockets = toucher.ammo_rockets + this.ammo_rockets;
	toucher.ammo_cells = toucher.ammo_cells + this.ammo_cells;
	toucher.ammo_lava_nails += this.ammo_lava_nails;
	toucher.ammo_multi_rockets += this.ammo_multi_rockets;
	toucher.ammo_plasma += this.ammo_plasma;

	int newitem = this.weapons;
	//if(!newitem)
		//newitem = toucher.weapon;
	int old = toucher.weapons;

	if(!MP_IMPEL)
	{
		bound_other_ammo(toucher);
		if(newitem)
			toucher.weapons |= newitem;
	}

	string theitems = "";
	if(this.ammo_shells)
		theitems = cons_sep(theitems, ", ", strcat(ftos(this.ammo_shells), " shells"));
	if(this.ammo_rockets)
		theitems = cons_sep(theitems, ", ", strcat(ftos(this.ammo_rockets), " rockets"));
	if(this.ammo_cells)
		theitems = cons_sep(theitems, ", ", strcat(ftos(this.ammo_cells), " cells"));
	if(this.ammo_lava_nails)
		theitems = cons_sep(theitems, ", ", strcat(ftos(this.ammo_lava_nails), " lava nails"));
	if(this.ammo_multi_rockets)
		theitems = cons_sep(theitems, ", ", strcat(ftos(this.ammo_multi_rockets), " multi rockets"));
	if(this.ammo_plasma)
		theitems = cons_sep(theitems, ", ", strcat(ftos(this.ammo_plasma), " plasma"));

	if(theitems != "")
	{
		if(wepmsg != "")
			Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, ITEM_BACKPACK_GOT_WEAPON, wepmsg, theitems);
		else
			Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, ITEM_BACKPACK_GOT, theitems);
	}
	else if(wepmsg != "")
		Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, ITEM_WEAPON_GOT, wepmsg);

// backpack touch sound
	_sound(toucher, CH_TRIGGER_SINGLE, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");

	if(MP_IMPEL)
	{
		if(toucher.weapon == WEP_PULSERIFLE)
		{
			delete(this);
			W_SetCurrentAmmo(toucher);
			return;
		}
		if(IS_MONSTER(this.owner))
		{
			delete(this);
			W_SetCurrentAmmo(toucher);
			return;
		}
		if(newitem)
			toucher.weapons |= newitem;
		bound_other_ammo(toucher);
		// continue as normal?
	}
// remove the backpack
	delete(this);

	if(MP_ROGUE)
		EnableComboWeapons(toucher);

// change to the weapon
	if(newitem && W_WantsToChangeWeapon(toucher, old, newitem) && newitem != WEP_PULSERIFLE) // offhand
	{
		if((this.flags & FL_INWATER) && newitem == WEP_LIGHTNING)
			return; // lol

		if(!deathmatch)
			W_SwitchWeapon(toucher, newitem);
		else
			Deathmatch_Weapon(toucher, old, newitem);
	}
}

string Weapon_PrettyName(int wepid)
{
	switch(wepid)
	{
		case WEP_AXE: 				 return "Axe";
		case WEP_SHOTGUN: 			 return "Shotgun";
		case WEP_SUPER_SHOTGUN: 	 return "Double-barrelled Shotgun";
		case WEP_NAILGUN: 			 return "Nailgun";
		case WEP_SUPER_NAILGUN: 	 return "Super Nailgun";
		case WEP_GRENADE_LAUNCHER: 	 return "Grenade Launcher";
		case WEP_ROCKET_LAUNCHER: 	 return "Rocket Launcher";
		case WEP_LIGHTNING: 		 return "Thunderbolt";
		case WEP_LASER_CANNON: 		 return "Laser Cannon";
		case WEP_PROXIMITY_GUN: 	 return "Proximity Gun";
		case WEP_MJOLNIR: 			 return "Mjolnir";
		case WEP_LAVA_NAILGUN: 		 return "Lava Nail Gun";
		case WEP_LAVA_SUPER_NAILGUN: return "Super Lava Nail Gun";
		case WEP_MULTI_GRENADE: 	 return "Multi Grenade Launcher";
		case WEP_MULTI_ROCKET: 		 return "Multi Rocket Launcher";
		case WEP_PLASMA_GUN: 		 return "Plasma Gun";
		case WEP_LIGHTME:			 return "LG-2 Prototype";
		case WEP_SPEAR:				 return "Rocket Powered Impaler";
		case WEP_NAPALM:			 return "Napalm Gun";
		case WEP_PULSERIFLE:		 return "Armor laser System";
	}

	return "";
}

bool BackpackCustomize(entity this, entity client)
{
	return (!this.realowner || this.realowner == client || !IS_PLAYER(this.realowner));
}

/*
===============
DropBackpack
===============
*/
void DropBackpack(entity this)
{
	if(!(this.ammo_shells + this.ammo_nails + this.ammo_rockets + this.ammo_cells + this.ammo_lava_nails + this.ammo_multi_rockets + this.ammo_plasma))
			return;	// nothing in it

	// Yoder Sept24 2021 Horde Merge
	// don't drop backpacks in horde mode
	if(MP_MG && horde_ent)
		return; 

	entity item = spawn();
	item.origin = this.origin - '0 0 24';
	
	item.weapons = this.weapon;
	item.netname = Weapon_PrettyName(item.weapons);

	item.ammo_shells = this.ammo_shells;
	item.ammo_nails = this.ammo_nails;
	item.ammo_rockets = this.ammo_rockets;
	item.ammo_cells = this.ammo_cells;

	// include some ammo in the backpack if the weapon is being given
	if(item.ammo_shells < 5 && (this.weapon == WEP_SHOTGUN || this.weapon == WEP_SUPER_SHOTGUN))
		item.ammo_shells = 5;

	if(item.ammo_nails < 20 && (this.weapon == WEP_NAILGUN || this.weapon == WEP_SUPER_NAILGUN))
		item.ammo_nails = 20;

	if(item.ammo_rockets < 5 && (this.weapon == WEP_GRENADE_LAUNCHER || this.weapon == WEP_ROCKET_LAUNCHER))
		item.ammo_rockets = 5;

	if(item.ammo_cells < 15 && this.weapon == WEP_LIGHTNING)
		item.ammo_cells = 15;

	// rogue
	item.ammo_lava_nails = this.ammo_lava_nails;
	item.ammo_multi_rockets = this.ammo_multi_rockets;
	item.ammo_plasma = this.ammo_plasma;

	item.velocity_z = 300;
	item.velocity_x = -100 +(random() * 200);
	item.velocity_y = -100 +(random() * 200);

	if(MP_IMPEL)
	{
		item.flags |= FL_ITEM;
		item.owner = this;
	}
	else
		item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	set_movetype(item, MOVETYPE_TOSS);
	_setmodel(item, "progs/backpack.mdl");
	setsize(item, '-16 -16 0', '16 16 56');
	settouch(item, BackpackTouch);
	if(autocvar_sv_quake_instance_backpacks && IS_PLAYER(this) && IS_REAL_CLIENT(this))
	{
		item.realowner = this;
		setcefc(item, BackpackCustomize);
	}
	
	item.nextthink = time + 120;	// remove after 2 minutes
	setthink(item, SUB_Remove);
}
