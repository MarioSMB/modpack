#include "items.qh"

#include "monsters/monsters.qh"
#include "rogue/sphere.qh"
#include "rogue/rogue.qh"
#include "triggers/subs.qh"
#include "triggers/triggers.qh"
#include "weapons.qh"
#include "weapons/selection.qh"

void SendItemPickup(entity this, int item, float amount)
{
	if(!item || amount <= 0 || !IS_REAL_CLIENT(this))
		return;

	msg_entity = this;
	WriteHeader(MSG_ONE, TE_CSQC_ITEMPICKUP);
	WriteByte(MSG_ONE, item);
	WriteShort(MSG_ONE, rint(amount));
}

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
	if(!(this.items & IT_KEY1) && !(this.items & IT_KEY2))
		this.flags = FL_ITEM;		// make extra wide
	this.solid = SOLID_TRIGGER;
	if(this.spawnflags & DROPTOFLOOR_DISABLE)
		set_movetype(this, MOVETYPE_NONE);
	else
		set_movetype(this, MOVETYPE_TOSS);	
	this.velocity = '0 0 0';
	setorigin(this, this.origin + '0 0 6');
	this.m_min = this.mins;
	this.m_max = this.maxs;
	setthink(this, FixItem);
	this.nextthink = time + 1; // initial delay
	if(!this.noalign)
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
	if(autocvar_horde && (serverflags & 2))
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

void health_touch(entity this, entity toucher)
{
	if(toucher.exptime != 0)
		return;
	if(!IS_PLAYER(toucher))
		return;

	bool pickedup = false;
	if(this.healamount)
	{
		if(this.healtype == 2) // Megahealth?  Ignore max_health...
		{
			if(toucher.health < 250 && T_Heal(toucher, this.healamount, true))
				pickedup = true;
		}
		else
		{
			if(T_Heal(toucher, this.healamount, false))
				pickedup = true;
		}
	}

	if(!pickedup)
		return;

	// NOTE: disabling spammy message as you already know from the HUD that you got it!
	//sprint(toucher, sprintf("You receive %d health\n", this.healamount));
	
// health touch sound
	_sound(toucher, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	
	this.model = string_null;
	this.solid = SOLID_NOT;

	// Megahealth = rot down the player's super health
	if(this.healtype == 2)
	{
		if(!MP_HIPNOTIC) // TODO: why?
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
	else if(this.wait)
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

.float armorid; // temporary hack to make spawned items work
void armor_touch(entity this, entity toucher)
{
	if(toucher.health <= 0)
		return;
	if(!IS_PLAYER(toucher))
		return;

	bool pickedup = false;
	float type = 0.3, value = 100;
	int bit = IT_ARMOR1;

	if(this.armorvalue)
	{
		type = this.armortype;
		value = this.armorvalue;
		bit = this.armorid;
		if(!(toucher.armortype * toucher.armorvalue >= type * value))
			pickedup = true;
	}

	if(!pickedup)
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
	this.armorid = IT_ARMOR1;
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
	this.armorid = IT_ARMOR2;
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
	this.armorid = IT_ARMOR3;
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

/*
=============
Deathmatch_Weapon

Deathmatch weapon change rules for picking up a weapon

.int		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
=============
*/
void Deathmatch_Weapon(entity this, int old, Weapon newwep)
{
	Weapon best = w_getbestweapon(this);
	if(best == newwep)
		W_SwitchWeapon(this, newwep);
}

bool weapon_customize(entity this, entity client)
{
	Weapon wep = REGISTRY_GET(Weapons, this.weapon);
	//if(STAT(WEAPONS, client) & wep.m_wepset)
		//wep = W_Apply_Weaponreplace(client, wep);
	if((deathmatch == 2 || coop) && (STAT(WEAPONS, client) & wep.m_wepset))
		return false;
	return true;
}


bool pulserifle_customize(entity this, entity client)
{
	bool have_item = false;
	if(this.classname == "weapon_rifle" && (client.items & IT_PULSERIFLE))
		have_item = true;
	if((deathmatch == 2 || coop) && have_item)
		return false;
	return true;
}

void pulserifle_touch(entity this, entity toucher)
{
	if(toucher.health <= 0)
		return;
	if(!IS_PLAYER(toucher))
		return;
	
	int newitems = 0;
	bool leave = (coop || deathmatch == 2 || deathmatch == 3 || deathmatch == 5);
	switch(this.classname)
	{
		case "weapon_rifle":
		{
			if(leave && (toucher.items & IT_PULSERIFLE))
				return;
			newitems = IT_PULSERIFLE;
			toucher.ammo_cells = toucher.ammo_cells + 24;
			break;
		}
		default:
		{
			objerror(this, "pulserifle_touch: unknown classname");
			break;
		}
	}

	if(this.classname == "weapon_rifle")
	{
		_sound(toucher, CHAN_AUTO, "weapons/pulse/install.wav", 1, ATTN_NORM);
		_sound(toucher, CHAN_WEAPON, "enviro/pinhead/pinfire.wav", 1, ATTN_NORM);
		if(!(toucher.items & IT_PULSERIFLE))
			centerprint(toucher, "[ ARMOR LASER SYSTEM ACTIVATED ]\n");
	}
	else
		_sound(toucher, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);

	bound_other_ammo(toucher);
	toucher.items |= newitems;

	W_SetCurrentAmmo(toucher);
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

void EnableComboWeapons(entity this)
{
	if(!IS_PLAYER(this))
		return;
	
	if (!(STAT(WEAPONS, this) & WEPSET(LAVA_NAILGUN)))
	{
		if (this.ammo_lava_nails > 0 && (STAT(WEAPONS, this) & WEPSET(NAILGUN)))
		{
			// NOTE: disabling spammy message as you already know from the HUD that you got it!
			//sprint (this, "Lava Enabled\n");
			STAT(WEAPONS, this) |= WEPSET(LAVA_NAILGUN);
		}
	}

	if (!(STAT(WEAPONS, this) & WEPSET(LAVA_SUPER_NAILGUN)))
	{
		if (this.ammo_lava_nails > 0 && 
							(STAT(WEAPONS, this) & WEPSET(SUPER_NAILGUN)))
		{
			// NOTE: disabling spammy message as you already know from the HUD that you got it!
			//sprint (this, "Super Lava Enabled\n");
			STAT(WEAPONS, this) |= WEPSET(LAVA_SUPER_NAILGUN);		
		}
	}

	if (!(STAT(WEAPONS, this) & WEPSET(MULTI_GRENADE)))
	{
		if (this.ammo_multi_rockets > 0 && 
							(STAT(WEAPONS, this) & WEPSET(GRENADE_LAUNCHER)))
		{
			// NOTE: disabling spammy message as you already know from the HUD that you got it!
			//sprint (this, "Multi Grenades Enabled\n");
			STAT(WEAPONS, this) |= WEPSET(MULTI_GRENADE);		
		}
	}

	if (!(STAT(WEAPONS, this) & WEPSET(MULTI_ROCKET)))
	{
		if (this.ammo_multi_rockets > 0 && 
							(STAT(WEAPONS, this) & WEPSET(ROCKET_LAUNCHER)))
		{
			// NOTE: disabling spammy message as you already know from the HUD that you got it!
			//sprint (this, "Multi Rockets Enabled\n");
			STAT(WEAPONS, this) |= WEPSET(MULTI_ROCKET);		
		}
	}

	if (!(STAT(WEAPONS, this) & WEPSET(PLASMA_GUN)))
	{
		if (this.ammo_plasma > 0 && (STAT(WEAPONS, this) & WEPSET(LIGHTNING)))
		{
			// NOTE: disabling spammy message as you already know from the HUD that you got it!
			//sprint (this, "Plasma Gun Enabled\n");
			STAT(WEAPONS, this) |= WEPSET(PLASMA_GUN);		
		}
	}
}

Weapon W_Apply_Weaponreplace(entity this, Weapon wep)
{
	FOREACH(Weapons, it != WEP_Null && it != wep && it.weaponreplace == wep.netname,
	{
		// if the player already has the weapon, skip it
		// if the player doesn't have ammo for it, also skip TODO: maybe allow swapping to the special weapons if you don't have ammo?
		if((STAT(WEAPONS, this) & it.m_wepset) || !it.wr_checkammo1(it, this))
			continue;
		wep = it;
		break; // one replacement at a time please!
	});

	return wep;
}

/*
=============
weapon_touch
=============
*/

void weapon_touch(entity this, entity toucher)
{
	if(toucher.health <= 0)
		return;
	if(!IS_PLAYER(toucher))
		return;

	Weapon wep = toucher.weaponentity.m_weapon;
// if the player was using their best weapon, change up to the new one if better		
	//int best = W_BestWeapon(toucher);

	bool leave = (coop || deathmatch == 2 || deathmatch == 3 || deathmatch == 5);

	// if we have the weapon already, try for replacements
	Weapon newwep = REGISTRY_GET(Weapons, this.weapon);
	//if(STAT(WEAPONS,toucher) & newwep.m_wepset)
		//newwep = W_Apply_Weaponreplace(toucher, newwep);
	if(leave && (STAT(WEAPONS, toucher) & newwep.m_wepset))
		return;

	wep = newwep;
	switch(newwep.ammo_type)
	{
		case IT_SHELLS: toucher.ammo_shells += newwep.aflag; break;
		case IT_NAILS: toucher.ammo_nails += newwep.aflag; break;
		case IT_ROCKETS: toucher.ammo_rockets += newwep.aflag; break;
		case IT_CELLS: toucher.ammo_cells += newwep.aflag; break;
		case IT_LAVA_NAILS: toucher.ammo_lava_nails += newwep.aflag; break;
		case IT_MULTI_ROCKETS: toucher.ammo_multi_rockets += newwep.aflag; break;
		case IT_PLASMA_AMMO: toucher.ammo_plasma += newwep.aflag; break;
	}

	if(!(STAT(WEAPONS, toucher) & wep.m_wepset))
	{
		if(this.netname != "")
			Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, ITEM_WEAPON_GOT, this.netname);
		else
			Send_Notification(NOTIF_ONE, toucher, MSG_INFO, INFO_ITEM_WEAPON_PICKUP);
	}
// weapon touch sound
	_sound(toucher, CH_TRIGGER_SINGLE, "weapons/pkup.wav", 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");

	bound_other_ammo(toucher);

// change to the weapon
	int old = toucher.weaponentity.m_weapon.m_id;
	STAT(WEAPONS, toucher) |= wep.m_wepset;

	if(!deathmatch)
		W_SwitchWeapon(toucher, wep);
	else
		Deathmatch_Weapon(toucher, old, wep);

	// Moved up so the targets are fired even in coop, but only once.
	SUB_UseTargets(this, toucher, NULL);

	if(leave)
	{
		this.target = string_null;
		if(this.state == 0)
			this.state = H_ROTTEN;
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
	else if(this.wait)
	{
		this.nextthink = time + this.wait;
		setthink(this, SUB_regen);
	}
}

// map-specific hacks
SPAWNFUNC_WEAPON_COND(weapon_supershotgun, (world.model == "maps/aop2m3.bsp"), WEP_GRENADE_LAUNCHER, WEP_SUPER_SHOTGUN);

SPAWNFUNC_WEAPON_COND(weapon_lightning, (world.model == "maps/aop2m2.bsp"), WEP_LIGHTME, WEP_LIGHTNING);

Weapon W_RandomizeWeapon(Weapon wpn)
{
	RandomSelection_Init();
	FOREACH(Weapons, it != WEP_Null,
	{
		if(it.ammo_type != wpn.ammo_type)
			continue;
		RandomSelection_AddEnt(it, 1, 1);
	});

	return RandomSelection_chosen_ent;
}

void weapon_defaultspawnfunc(entity this, Weapon wpn)
{
	if(autocvar_skill == 3)
		wpn = W_RandomizeWeapon(wpn);

	if(!MP_HIPNOTIC && (wpn.spawnflags & WEP_FLAG_HIPNOTIC)) { delete(this); return; }
	if(!MP_ROGUE && (wpn.spawnflags & WEP_FLAG_ROGUE)) { delete(this); return; }
	if(!MP_IMPEL && (wpn.spawnflags & WEP_FLAG_IMPEL)) { delete(this); return; }

	string mymdl = strcat("progs/g_", wpn.mdl, ".mdl");
	precache_model(mymdl); // TODO: model registry
	_setmodel(this, mymdl);
	this.weapon = wpn.m_id;
	this.netname = wpn.m_name;
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

spawnfunc(weapon_rifle)
{
	if(!MP_IMPEL) { delete(this); return; }

	precache_model("progs/g_tek.mdl");
	_setmodel(this, "progs/g_tek.mdl");
	this.netname = "Armor Laser System";
	settouch(this, pulserifle_touch);
	setcefc(this, pulserifle_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

#if 0
spawnfunc(weapon_rifleupgrade)
{
	if(!MP_IMPEL) { delete(this); return; }

	precache_model("progs/wing.mdl");
	_setmodel(this, "progs/wing.mdl");
	this.netname = "Laser System Upgrade";
	settouch(this, pulserifle_touch);
	setcefc(this, pulserifle_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
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
	Weapon best = w_getbestweapon(toucher);
	bool pickedup = false;

	if(this.ammo_shells && toucher.ammo_shells < 100)
	{
		toucher.ammo_shells += this.ammo_shells;
		SendItemPickup(toucher, this.items, this.ammo_shells);
		pickedup = true;
	}
	if(this.ammo_nails && toucher.ammo_nails < 200)
	{
		toucher.ammo_nails += this.ammo_nails;
		SendItemPickup(toucher, this.items, this.ammo_nails);
		pickedup = true;
	}
	if(this.ammo_rockets && toucher.ammo_rockets < 100)
	{
		toucher.ammo_rockets += this.ammo_rockets;
		SendItemPickup(toucher, this.items, this.ammo_rockets);
		pickedup = true;
	}
	if(this.ammo_cells && toucher.ammo_cells < 100)
	{
		toucher.ammo_cells += this.ammo_cells;
		SendItemPickup(toucher, this.items, this.ammo_cells);
		pickedup = true;
	}
	if(this.ammo_lava_nails && toucher.ammo_lava_nails < 200)
	{
		toucher.ammo_lava_nails += this.ammo_lava_nails;
		SendItemPickup(toucher, this.items, this.ammo_lava_nails);
		pickedup = true;
	}
	if(this.ammo_multi_rockets && toucher.ammo_multi_rockets < 100)
	{
		toucher.ammo_multi_rockets += this.ammo_multi_rockets;
		SendItemPickup(toucher, this.items, this.ammo_multi_rockets);
		pickedup = true;
	}
	if(this.ammo_plasma && toucher.ammo_plasma < 100)
	{
		toucher.ammo_plasma += this.ammo_plasma;
		SendItemPickup(toucher, this.items, this.ammo_plasma);
		pickedup = true;
	}

	if(!pickedup)
		return;

	bound_other_ammo(toucher);

// ammo touch sound
	if(this.noise && this.noise != "")
		_sound(toucher, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);

// change to a better weapon if appropriate

	if(toucher.weaponentity.m_weapon == best)
		W_SwitchWeapon(toucher, w_getbestweapon(toucher));

// if changed current ammo, update it
	W_SetCurrentAmmo(toucher);

// remove it in single player, or setup for respawning in deathmatch
	this.model = string_null;
	this.solid = SOLID_NOT;

	setthink(this, SUB_regen);
	if(coop && this.wait <= 0) //Wait overrides coop respawn behaviour
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
	else if(this.wait)
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
	this.ammo_shells = this.aflag;
	this.weapon = 1;
	this.items = IT_SHELLS;
	this.netname = "shells";
	this.noise = "weapons/lock4.wav";
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
	this.ammo_nails = this.aflag;
	this.weapon = 2;
	this.items = IT_NAILS;
	this.netname = "nails";
	this.noise = "weapons/lock4.wav";
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
	this.ammo_lava_nails = this.aflag;
	this.weapon = 5;
	this.items = IT_LAVA_NAILS;
	this.netname = "lava nails";
	this.noise = "weapons/lock4.wav";
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
	this.ammo_rockets = this.aflag;
	this.weapon = 3;
	this.items = IT_ROCKETS;
	this.netname = "rockets";
	this.noise = "weapons/lock4.wav";
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
	this.ammo_multi_rockets = this.aflag;
	this.weapon = 6;
	this.items = IT_MULTI_ROCKETS;
	this.netname = "multi rockets";
	this.noise = "weapons/lock4.wav";
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
	this.ammo_cells = this.aflag;
	this.weapon = 4;
	this.items = IT_CELLS;
	this.netname = "cells";
	this.noise = "weapons/lock4.wav";
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
	this.ammo_plasma = this.aflag;
	this.weapon = 7;
	this.items = IT_PLASMA_AMMO;
	this.netname = "plasma";
	this.noise = "weapons/lock4.wav";
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
		this.ammo_shells = this.aflag;
		this.weapon = WEP_SHOTGUN.m_id;
		this.netname = "shells";
	}

	if(this.spawnflags & WEAPON_SPIKES)
	{
		if(this.spawnflags & WEAPON_BIG)
		{
			setmodel(this, MDL_ITEM_NAILS_BIG);
			this.aflag = 40;
			this.weapon = WEP_SUPER_NAILGUN.m_id;
		}
		else
		{
			setmodel(this, MDL_ITEM_NAILS);
			this.aflag = 20;
			this.weapon = WEP_NAILGUN.m_id;
		}
		this.ammo_rockets = this.aflag;
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
		this.ammo_rockets = this.aflag;
		this.weapon = WEP_ROCKET_LAUNCHER.m_id;
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
	if(substring(world.model, 0, 6) != "maps/e")
	{
		int lastPickup = SUB_LeftShift(this.spawnflags & SIGIL_ALL, SIGIL_NUMBITS);
    	serverflags |= (this.spawnflags & SIGIL_ALL) | lastPickup;
	}
	else
		serverflags = serverflags | (this.spawnflags & 15);
	if(autocvar_horde && (this.spawnflags & SIGIL_E2)) // Hunger
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

// hacked in fallback method for spawning a monster with the horn of conjuring
// used for horns that somehow spawn without a target
void horn_spawnmonster(entity item, entity actor)
{
	RandomSelection_Init();
	FOREACH(Monsters, it != MON_Null,
	{
		if(!MP_HIPNOTIC && (it.spawnflags & MON_FLAG_HIPNOTIC))
			continue;
		if(!MP_ROGUE && (it.spawnflags & MON_FLAG_ROGUE))
			continue;
		if(!MP_IMPEL && (it.spawnflags & MON_FLAG_IMPEL))
			continue;
		if((it.spawnflags & MONSTER_TYPE_SWIM) && actor.waterlevel < 1)
			continue;
		if(it.spawnflags & MONSTER_TYPE_DECOY)
			continue; // no decoys please!
		if((it.spawnflags & MONSTER_TYPE_BOSS) || (it.spawnflags & MON_FLAG_STATIONARY) || (it.spawnflags & MON_FLAG_HIDDEN) || (it.spawnflags & MONSTER_TYPE_UNDEAD))
			continue;
		RandomSelection_AddEnt(it, 1, 1);
	});
	Monster mon = RandomSelection_chosen_ent;
	if(!mon)
		return;

	entity monster = new(monster);
	monster.monsterdef = mon;
	monster.flags |= FL_MONSTER;
	//monster.owner = actor;
	monster.colormod = '0 1 0';
	monster.spawnfunc_checked = true;
	setmodel(monster, mon.m_model);
	setsize(monster, mon.m_mins, mon.m_maxs);
	if(mon.spawnflags & MONSTER_TYPE_SWIM) { monster.flags |= FL_SWIM; }
	if(mon.spawnflags & MONSTER_TYPE_FLY) { monster.flags |= FL_FLY; }
	monster.solid = SOLID_SLIDEBOX;
	if(monster.flags & FL_FLY)
		set_movetype(monster, MOVETYPE_QCENTITY);
	else
		set_movetype(monster, MOVETYPE_STEP);

	if(!(monster.flags & FL_SWIM))
	{
		IL_PUSH(g_damagedbycontents, monster);
		monster.damagedbycontents	= true;
	}

	mon.mr_setup(mon, monster);
	monster.health = max(monster.health, 1000);
	monster.max_health = monster.health;
	monster.charmer = actor;
	monster.charmed = 1;
	monster.angles = '0 0 0';
	monster.angles_y = actor.angles_y;
	vector org = item.origin;
	org.z += -mon.m_mins.z; // offset based on size
	setorigin(monster, org + '0 0 1');
	setcefc(monster, monster_customize);
	setup_minionsupport(monster);

	if(!(mon.spawnflags & MONSTER_TYPE_FLY))
		droptofloor(monster);
	
	tracebox(monster.origin, monster.mins, monster.maxs, monster.origin, MOVE_NOMONSTERS, monster);
	if(trace_startsolid)
		LOG_DEBUG("Monster in wall at ", vtos(monster.origin), "\n");
	monster.takedamage = DAMAGE_AIM;
	monster.ideal_yaw = monster.angles * '0 1 0';
	if(!monster.yaw_speed)
		monster.yaw_speed = 20;
	monster.view_ofs = '0 0 25';
	monster.use = monster_use;
	monster.effects |= EF_DIMLIGHT;
	setthink(monster, monster_start_go);
	monster.nextthink = time + 0.1;
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
	// TODO: apply this logic to all powerups?
	if((this.powerups & POWERUP_V_SPHERE) && (toucher.powerups & POWERUP_V_SPHERE))
		return; // one per person please
	if((this.powerups & POWERUP_FIREFLOWER) && (toucher.powerups & POWERUP_FIREFLOWER))
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
			if((this.powerups & POWERUP_INVISIBILITY) || (this.powerups & POWERUP_INVISIBILITY))
				this.nextthink = time + 60 * 5;
			else
				this.nextthink = time + 60;
			
			setthink(this, SUB_regen);
		}
	}
	else if(this.wait)
	{
		this.nextthink = time + this.wait;
		setthink(this, SUB_regen);
	}

	_sound(toucher, CH_VOICE, this.noise, 1, ATTN_NORM);
	this.solid = SOLID_NOT;
	if(!(this.powerups & POWERUP_HORN_OF_CONJURING))
		toucher.powerups |= this.powerups;
	this.model = string_null;

	SUB_UseTargets(this, toucher, NULL);

	float powerups_maxtime = 30;
	if(horde_ent)
		powerups_maxtime = 5;

// do the apropriate action
	if(this.powerups & POWERUP_SUIT)
	{
		toucher.rad_time = 1;
		toucher.radsuit_finished = time + 30; // give wetsuits full duration
		if(coop) // Respawn biosuit in coop, since it might be required for progression
		{
			this.target = string_null; // but don't fire off targets again
			setthink(this, SUB_regen);
			this.nextthink = time + 2.5;
		}
	}

	if(this.powerups & POWERUP_INVULNERABILITY)
	{
		toucher.invincible_time = 1;
		toucher.invincible_finished = time + powerups_maxtime;
	}

	if(this.powerups & POWERUP_INVISIBILITY)
	{
		toucher.invisible_time = 1;
		toucher.invisible_finished = time + powerups_maxtime;
	}

	if(this.powerups & POWERUP_QUAD)
	{
		toucher.super_time = 1;
		toucher.super_damage_finished = time + powerups_maxtime;
	}

	if(this.powerups & POWERUP_FIELDGEN)
	{
		toucher.field_generator_health = this.health;
		toucher.field_generator_time = -150;
		toucher.field_generator_finished = time + powerups_maxtime;
	}

	if(this.powerups & POWERUP_WETSUIT)
	{
		toucher.wetsuit_time = 1;
		toucher.wetsuit_finished = time + 30; // give wetsuits full duration
	}

	if(this.powerups & POWERUP_EMPATHY_SHIELDS)
	{
		toucher.empathy_time = 1;
		toucher.empathy_finished = time + powerups_maxtime;
	}

	if(this.powerups & POWERUP_HORN_OF_CONJURING)
	{
		// horns with a target will use the regular func_spawn method
		if(!this.target || this.target == "")
		{
			// otherwise attempt to spawn in a random monster
			horn_spawnmonster(this, toucher);
		}
	}

	if(this.powerups & POWERUP_ANTIGRAV)
	{
		toucher.antigrav_time = 1;
		toucher.antigrav_finished = time + 45; // give antigrav full duration
		toucher.gravity = 0.25;
	}

	if(this.powerups & POWERUP_SHIELD)
	{
		toucher.shield_time = 1;
		toucher.shield_finished = time + powerups_maxtime;
	}

	if(this.powerups & POWERUP_V_SPHERE)
	{
		sphere_spawn(this, toucher);
	}

	if(this.powerups & POWERUP_FIREFLOWER)
	{
		sprint(toucher, "Secondary attacks enabled!\n");
		toucher.fireflower_time = 1;
		toucher.fireflower_finished = time + 30; // always give full duration
	}
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
}

/*QUAKED item_powerup_shield (0 .5 .8) (-16 -16 -24) (16 16 32)
The shield upgrade
*/
spawnfunc(item_powerup_shield)
{
	if(!MP_ROGUE) { delete(this); return; }

	settouch(this, powerup_touch);

	precache_model ("progs/shield.mdl");
	precache_model ("progs/p_shield.mdl");
	precache_sound ("shield/pickup.wav");
	precache_sound ("shield/hit.wav");
	precache_sound ("shield/fadeout.wav");
	this.noise = "shield/pickup.wav";
	_setmodel(this, "progs/shield.mdl");
	this.netname = "Power Shield";
	this.powerups = POWERUP_SHIELD;
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}

/*QUAKED item_powerup_belt (0 .5 .8) (-16 -16 -24) (16 16 32)
The anti-grav belt
*/
spawnfunc(item_powerup_belt)
{
	if(!MP_ROGUE) { delete(this); return; }
	
	settouch(this, powerup_touch);

	precache_model ("progs/beltup.mdl");
	precache_sound ("belt/pickup.wav");
	precache_sound ("belt/use.wav");
	precache_sound ("belt/fadeout.wav");
	this.noise = "belt/pickup.wav";
	_setmodel(this, "progs/beltup.mdl");
	this.netname = "Anti-Grav Belt";
	this.powerups = POWERUP_ANTIGRAV;
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}

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

/*QUAKED item_powerup_fireflower(0 .5 .8)(-16 -16 -24)(16 16 32)
Provides a secondary attack of fireballs
*/
spawnfunc(item_powerup_fireflower)
{
	settouch(this, powerup_touch);

	precache_model("progs/g_fflower.mdl");
	precache_model("progs/fireball.mdl");
	precache_sound("items/powerup_mario.wav");
	precache_sound("items/powerdown_mario.wav");
	precache_sound("items/mario_attack.wav");
	this.noise = "items/powerup_mario.wav";
	_setmodel(this, "progs/g_fflower.mdl");
	this.netname = "Fire Flower";
	this.powerups = POWERUP_FIREFLOWER;
	setsize(this, '-16 -16 0', '16 16 32');
	StartItem(this);
}

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

	//if(toucher == this.owner && ((this.nextthink - time) > 119))
		//return; // don't let owner pick up his own backpack for a second

	int newitem = this.weapon;
	Weapon wep = REGISTRY_GET(Weapons, newitem);
	string wepmsg = "";
	if(wep != WEP_Null && !(STAT(WEAPONS, toucher) & wep.m_wepset) && this.netname && this.netname != "")
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

	//if(!newitem)
		//newitem = toucher.weapon;
	int old = toucher.weaponentity.m_weapon.m_id;

	if(this.ammo_shells)
		SendItemPickup(toucher, IT_SHELLS, this.ammo_shells);
	if(this.ammo_rockets)
		SendItemPickup(toucher, IT_ROCKETS, this.ammo_rockets);
	if(this.ammo_cells)
		SendItemPickup(toucher, IT_CELLS, this.ammo_cells);
	if(this.ammo_lava_nails)
		SendItemPickup(toucher, IT_LAVA_NAILS, this.ammo_lava_nails);
	if(this.ammo_multi_rockets)
		SendItemPickup(toucher, IT_MULTI_ROCKETS, this.ammo_multi_rockets);
	if(this.ammo_plasma)
		SendItemPickup(toucher, IT_PLASMA_AMMO, this.ammo_plasma);

	if(wepmsg != "")
		Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, ITEM_WEAPON_GOT, wepmsg);

// backpack touch sound
	_sound(toucher, CH_TRIGGER_SINGLE, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");

	STAT(WEAPONS, toucher) |= STAT(WEAPONS, this);
	if(wep != WEP_Null)
		STAT(WEAPONS, toucher) |= wep.m_wepset;
	bound_other_ammo(toucher);

	// continue as normal?
// remove the backpack
	delete(this);

	EnableComboWeapons(toucher);

// change to the weapon
	if(wep != WEP_Null)
	{
		if((toucher.flags & FL_INWATER) && wep == WEP_LIGHTNING)
			return; // lol

		if(!deathmatch)
			W_SwitchWeapon(toucher, wep);
		else
			Deathmatch_Weapon(toucher, old, wep);
	}
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

	if(STAT(SKATING, this))
		return; // skaters don't drop loot!

	// Yoder Sept24 2021 Horde Merge
	// don't drop backpacks in horde mode
	if(horde_ent)
		return; 

	entity item = spawn();
	setorigin(item, this.origin - '0 0 24');

	Weapon wep = this.weaponentity.m_weapon;
	item.weapon = wep.m_id;
	item.netname = wep.m_name;
	STAT(WEAPONS, item) = STAT(WEAPONS, this);

	item.ammo_shells = this.ammo_shells;
	item.ammo_nails = this.ammo_nails;
	item.ammo_rockets = this.ammo_rockets;
	item.ammo_cells = this.ammo_cells;

	// include some ammo in the backpack if the weapon is being given
	if(item.ammo_shells < 5 && wep.ammo_type == IT_SHELLS)
		item.ammo_shells = 5;

	if(item.ammo_nails < 20 && wep.ammo_type == IT_NAILS)
		item.ammo_nails = 20;

	if(item.ammo_rockets < 5 && wep.ammo_type == IT_ROCKETS)
		item.ammo_rockets = 5;

	if(item.ammo_cells < 15 && wep.ammo_type == IT_CELLS)
		item.ammo_cells = 15;

	// rogue
	item.ammo_lava_nails = this.ammo_lava_nails;
	item.ammo_multi_rockets = this.ammo_multi_rockets;
	item.ammo_plasma = this.ammo_plasma;

	item.velocity_z = 300;
	item.velocity_x = -100 +(random() * 200);
	item.velocity_y = -100 +(random() * 200);

	item.flags |= FL_ITEM;
	item.owner = this;

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
