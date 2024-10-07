#include "items.qh"

#include "monsters/monsters.qh"
#include "rogue/sphere.qh"
#include "rogue/rogue.qh"
#include "../common/triggers/subs.qh"
#include "../common/triggers/triggers.qh"
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
================================
ItemUse

triggering an item
 - if it regenerates, stop regenerating
 - if it doesn't, force it to respawn
items which have yet to be spawned have a different .use
================================
*/
void ItemSpawn(entity this, entity actor, entity trigger);
void ItemUse(entity this, entity actor, entity trigger)
{
	if(this.wait > 0)
	{
		this.wait = 0;
		setthink(this, SUB_Remove);	// if nextthink is in the future, don't respawn again
		return;
	}
	this.alpha = 1;
	ItemSpawn(this, actor, trigger);
}

/*
============
PlaceItem

plants the object on the floor
============
*/
const int ITEM_SUSPENDED = 4;

void ItemSpawn(entity this, entity actor, entity trigger)
{
	this.solid = SOLID_TRIGGER;
	this.model = this.mdl;
	setthink(this, FixItem);
	this.nextthink = time + 0.5;
}

void PlaceItem(entity this)
{
	this.mdl = this.model;		// so it can be restored on respawn
	if(!(this.items & IT_KEY1) && !(this.items & IT_KEY2))
		this.flags = FL_ITEM;		// make extra wide
	this.solid = SOLID_TRIGGER;
	if(this.classname != "item_sigil" && ((this.spawnflags & DROPTOFLOOR_DISABLE) || (this.spawnflags & ITEM_SUSPENDED)))
		set_movetype(this, MOVETYPE_NONE);
	else
		set_movetype(this, MOVETYPE_TOSS);	
	this.velocity = '0 0 0';
	setorigin(this, this.origin + '0 0 6');
	//if(this.use != SUB_regen)
		this.use = ItemUse;
	this.m_min = this.mins;
	this.m_max = this.maxs;
	setthink(this, FixItem);
	this.nextthink = time + 1; // initial delay
	if(!this.noalign && !(this.spawnflags & ITEM_SUSPENDED))
		DropToFloor_QC_DelayedInit(this);

	if(SUB_VerifyTriggerable(this))
	{
		this.solid = SOLID_NOT;
		this.model = string_null;
		this.use = ItemSpawn;
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
	if(this.classname != "item_sigil" && (Inhibit_Coop(this) || RemovedOutsideCoop(this)))
	{
		delete(this);
		return;
	}
	this.nextthink = time + 0.25;	// items start after other solids
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
	float hp_heal_max = e.max_health;
	if(e.tank)
		return false;
	if(e.clockwork)
		return false;
	if(world.worldtype == WORLDTYPE_DODGEBALL)
		return false;
	if(e.m_champion)
		hp_heal_max *= e.m_champion.qcc_health_heal_max;
	if(e.health <= 0)
		return false;
	if((!ignore) &&(e.health >= hp_heal_max))
		return false;
	healamount = ceil(healamount);

	// AY Dec13 2021, horde rune of hunger
	if(autocvar_horde && (serverflags & 2))
		e.hunger_time = time + HUNGER_MAX;

	e.health = e.health + healamount;
	if((!ignore) &&(e.health >= hp_heal_max))
		e.health = hp_heal_max;

	float hp_heal_cap = 250;
	if(e.m_champion)
		hp_heal_cap *= e.m_champion.qcc_health_heal_cap;
	if(e.health > hp_heal_cap)
		e.health = hp_heal_cap;
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

bool health_customize(entity this, entity client)
{
	return !(client.m_champion && client.m_champion.qcc_health_nopickup && this.healtype != 2);
}

spawnfunc(item_health)
{
	if(!(this.spawnflags & H_MEGA))
	{
		if(qonquer_itemreplace(this))
		{
			delete(this);
			return;
		}
	}

	settouch(this, health_touch);
	setcefc(this, health_customize);

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
	if(toucher.tank)
		return;
	if(toucher.clockwork)
		return;
	if(toucher.m_transform)
		return;
	if(toucher.m_champion && toucher.m_champion.qcc_health_nopickup && this.healtype != 2)
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
	if(toucher.tank)
		return;
	if(toucher.m_transform)
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

	if(toucher.m_champion && toucher.m_champion.m_pickup_armor)
		toucher.m_champion.m_pickup_armor(toucher.m_champion, toucher, this);

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
	if(qonquer_itemreplace(this))
	{
		delete(this);
		return;
	}

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
	if(qonquer_itemreplace(this))
	{
		delete(this);
		return;
	}
	
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
	this.ammo_shells = min(this.ammo_shells, GetAmmoLimit(this, IT_SHELLS));
	this.ammo_nails = min(this.ammo_nails, GetAmmoLimit(this, IT_NAILS));
	this.ammo_rockets = min(this.ammo_rockets, GetAmmoLimit(this, IT_ROCKETS));
	this.ammo_cells = min(this.ammo_cells, GetAmmoLimit(this, IT_CELLS));

	this.ammo_lava_nails = min(this.ammo_lava_nails, GetAmmoLimit(this, IT_LAVA_NAILS));
	this.ammo_multi_rockets = min(this.ammo_multi_rockets, GetAmmoLimit(this, IT_MULTI_ROCKETS));
	this.ammo_plasma = min(this.ammo_plasma, GetAmmoLimit(this, IT_PLASMA_AMMO));
}

int GetAmmoLimit(entity this, int itemid)
{
	float ascale = 1;
	if(STAT(PASSIVES, this) & PASSIVE_AMMOPOUCH)
		ascale *= 2;
	switch(itemid)
	{
		case IT_SHELLS: return 100 * ascale;
		case IT_NAILS: return 200 * ascale;
		case IT_ROCKETS: return 100 * ascale;
		case IT_CELLS: return 100 * ascale;
		case IT_LAVA_NAILS: return 200 * ascale;
		case IT_MULTI_ROCKETS: return 100 * ascale;
		case IT_PLASMA_AMMO: return 100 * ascale;
	}

	// TODO? mention if anything gets here!
	return 0;
}

/*
=============
Deathmatch_Weapon

Deathmatch weapon change rules for picking up a weapon

.int		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
=============
*/
void Deathmatch_Weapon(entity this, Weapon newwep, .entity weaponentity)
{
	if(!this.cvar_cl_autoswitch)
		return;
	Weapon best = w_getbestweapon(this, weaponentity);
	if(best == newwep)
		W_SwitchWeapon(this, newwep, weaponentity);
}

bool weapon_customize(entity this, entity client)
{
	Weapon wep = REGISTRY_GET(Weapons, this.weapon);
	if((deathmatch == 2 || coop) && (STAT(WEAPONS, client) & wep.m_wepset))
	{
		if((STAT(DUAL_WEAPONS, client) & wep.m_wepset) || (wep.spawnflags & WEP_FLAG_NODUAL))
			return false;
		if(client.collected_weapons & wep.m_wepset)
			return false;
	}
	return true;
}


bool pulserifle_customize(entity this, entity client)
{
	bool have_item = false;
	if(this.classname == "weapon_rifle" && (STAT(PASSIVES, client) & PASSIVE_PULSERIFLE))
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
			if(leave && (STAT(PASSIVES, toucher) & PASSIVE_PULSERIFLE))
				return;
			newitems = PASSIVE_PULSERIFLE;
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
		if(!(STAT(PASSIVES, toucher) & PASSIVE_PULSERIFLE))
			centerprint(toucher, "[ ARMOR LASER SYSTEM ACTIVATED ]\n");
	}
	else
		_sound(toucher, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);

	bound_other_ammo(toucher);
	STAT(PASSIVES, toucher) |= newitems;

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
	
	if(!(STAT(WEAPONS, this) & WEPSET(LAVA_NAILGUN)))
	{
		if(this.ammo_lava_nails > 0 && (STAT(WEAPONS, this) & WEPSET(NAILGUN)))
		{
			// NOTE: disabling spammy message as you already know from the HUD that you got it!
			//sprint (this, "Lava Enabled\n");
			STAT(WEAPONS, this) |= WEPSET(LAVA_NAILGUN);
		}
	}

	if(!(STAT(WEAPONS, this) & WEPSET(LAVA_SUPER_NAILGUN)))
	{
		if(this.ammo_lava_nails > 0 && 
							(STAT(WEAPONS, this) & WEPSET(SUPER_NAILGUN)))
		{
			// NOTE: disabling spammy message as you already know from the HUD that you got it!
			//sprint (this, "Super Lava Enabled\n");
			STAT(WEAPONS, this) |= WEPSET(LAVA_SUPER_NAILGUN);		
		}
	}

	if(!(STAT(WEAPONS, this) & WEPSET(MULTI_GRENADE)))
	{
		if(this.ammo_multi_rockets > 0 && 
							(STAT(WEAPONS, this) & WEPSET(GRENADE_LAUNCHER)))
		{
			// NOTE: disabling spammy message as you already know from the HUD that you got it!
			//sprint (this, "Multi Grenades Enabled\n");
			STAT(WEAPONS, this) |= WEPSET(MULTI_GRENADE);		
		}
	}

	if(!(STAT(WEAPONS, this) & WEPSET(MULTI_ROCKET)))
	{
		if(this.ammo_multi_rockets > 0 && 
							(STAT(WEAPONS, this) & WEPSET(ROCKET_LAUNCHER)))
		{
			// NOTE: disabling spammy message as you already know from the HUD that you got it!
			//sprint (this, "Multi Rockets Enabled\n");
			STAT(WEAPONS, this) |= WEPSET(MULTI_ROCKET);		
		}
	}

	if(!(STAT(WEAPONS, this) & WEPSET(PLASMA_GUN)))
	{
		if(this.ammo_plasma > 0 && (STAT(WEAPONS, this) & WEPSET(LIGHTNING)))
		{
			// NOTE: disabling spammy message as you already know from the HUD that you got it!
			//sprint (this, "Plasma Gun Enabled\n");
			STAT(WEAPONS, this) |= WEPSET(PLASMA_GUN);		
		}
	}
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

	.entity weaponentity = weaponentities[0]; // TODO?
	Weapon wep = toucher.(weaponentity).m_weapon;
// if the player was using their best weapon, change up to the new one if better		
	//int best = W_BestWeapon(toucher);

	bool leave = (coop || deathmatch == 2 || deathmatch == 3 || deathmatch == 5);

	// if we have the weapon already, try for replacements
	Weapon newwep = REGISTRY_GET(Weapons, this.weapon);
	if(leave && (STAT(WEAPONS, toucher) & newwep.m_wepset) && ((STAT(DUAL_WEAPONS, toucher) & newwep.m_wepset) || (newwep.spawnflags & WEP_FLAG_NODUAL) || (toucher.collected_weapons & newwep.m_wepset)))
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

	if(toucher.m_champion && toucher.m_champion.m_pickup_weapon)
		toucher.m_champion.m_pickup_weapon(toucher.m_champion, toucher, this);

// change to the weapon
	if((STAT(WEAPONS, toucher) & wep.m_wepset) && (coop || deathmatch == 2))
		STAT(DUAL_WEAPONS, toucher) |= wep.m_wepset;
	else
		STAT(WEAPONS, toucher) |= wep.m_wepset;

	//if(!(toucher.dual_weapons & wep.m_wepset))
	//{
	if(toucher.cvar_cl_autoswitch)
	{
		if(!deathmatch)
			W_SwitchWeapon(toucher, wep, weaponentity);
		else
			Deathmatch_Weapon(toucher, wep, weaponentity);
	}
	//}

	toucher.collected_weapons |= wep.m_wepset;

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
	if(wpn == WEP_AXE || wpn == WEP_SHOTGUN)
		return wpn;
	RandomSelection_Init();
	FOREACH(Weapons, it != WEP_Null && it != WEP_AXE && it != WEP_SHOTGUN && it != WEP_BALL && !(it.spawnflags & WEP_FLAG_CHAMPION),
	{
		// hack to allow instruments to replace regular weapon spawns
		if(deathmatch && (it.spawnflags & WEP_FLAG_MUSIC))
			continue; // but not in deathmatch
		int mytype = it.ammo_type;
		switch(it)
		{
			case WEP_PIANO:
			case WEP_KAZOO:
			{
				if(random() > 0.5)
					mytype = IT_NAILS;
				break;
			}
			case WEP_DOOT:
			{
				if(random() > 0.5)
					mytype = IT_SHELLS;
				break;
			}
			case WEP_TUBA:
			case WEP_MAYO:
			{
				if(random() > 0.5)
					mytype = IT_ROCKETS;
				break;
			}
			case WEP_CANNON:
			{
				if(random() < 0.33)
					mytype = IT_ROCKETS;
				break;
			}
			case WEP_OTAMATONE:
			{
				if(random() > 0.5)
					mytype = IT_CELLS;
				break;
			}
			case WEP_MIC:
			{
				if(random() > 0.5)
					mytype = IT_CELLS;
				break;
			}
			case WEP_OCARINA:
			{
				if(random() > 0.5)
					mytype = IT_CELLS;
				break;
			}
			case WEP_BANJO:
			{
				if(random() > 0.33)
					mytype = IT_SHELLS;
				break;
			}
			case WEP_BONGOS:
			{
				if(random() > 0.33)
					mytype = IT_SHELLS;
				break;
			}
			case WEP_ORGAN:
			{
				if(random() > 0.33)
					mytype = IT_NAILS;
				break;
			}
			case WEP_CHIMES:
			{
				if(random() > 0.33)
					mytype = IT_ROCKETS;
				break;
			}
			case WEP_HAMMER:
			{
				if(random() > 0.5)
					mytype = IT_CELLS;
				break;
			}
		}
		if(mytype != wpn.ammo_type)
			continue;
		RandomSelection_AddEnt(it, 1, 1);
	});

	return RandomSelection_chosen_ent;
}

void weapon_defaultspawnfunc(entity this, Weapon wpn)
{
	if(autocvar_skill == 3 || deathmatch)
		wpn = W_RandomizeWeapon(wpn);

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
	.entity weaponentity = weaponentities[0]; // TODO
	Weapon best = w_getbestweapon(toucher, weaponentity);
	bool pickedup = false;

	if(this.ammo_shells && toucher.ammo_shells < GetAmmoLimit(toucher, IT_SHELLS))
	{
		toucher.ammo_shells += this.ammo_shells;
		SendItemPickup(toucher, this.items, this.ammo_shells);
		pickedup = true;
	}
	if(this.ammo_nails && toucher.ammo_nails < GetAmmoLimit(toucher, IT_NAILS))
	{
		toucher.ammo_nails += this.ammo_nails;
		SendItemPickup(toucher, this.items, this.ammo_nails);
		pickedup = true;
	}
	if(this.ammo_rockets && toucher.ammo_rockets < GetAmmoLimit(toucher, IT_ROCKETS))
	{
		toucher.ammo_rockets += this.ammo_rockets;
		SendItemPickup(toucher, this.items, this.ammo_rockets);
		pickedup = true;
	}
	if(this.ammo_cells && toucher.ammo_cells < GetAmmoLimit(toucher, IT_CELLS))
	{
		toucher.ammo_cells += this.ammo_cells;
		SendItemPickup(toucher, this.items, this.ammo_cells);
		pickedup = true;
	}
	if(this.ammo_lava_nails && toucher.ammo_lava_nails < GetAmmoLimit(toucher, IT_LAVA_NAILS))
	{
		toucher.ammo_lava_nails += this.ammo_lava_nails;
		SendItemPickup(toucher, this.items, this.ammo_lava_nails);
		pickedup = true;
	}
	if(this.ammo_multi_rockets && toucher.ammo_multi_rockets < GetAmmoLimit(toucher, IT_MULTI_ROCKETS))
	{
		toucher.ammo_multi_rockets += this.ammo_multi_rockets;
		SendItemPickup(toucher, this.items, this.ammo_multi_rockets);
		pickedup = true;
	}
	if(this.ammo_plasma && toucher.ammo_plasma < GetAmmoLimit(toucher, IT_PLASMA_AMMO))
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

	if(!toucher.cvar_cl_autoswitch && toucher.(weaponentity).m_weapon == best)
		W_SwitchWeapon(toucher, w_getbestweapon(toucher, weaponentity), weaponentity);

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
	if(qonquer_ammoreplace(this))
	{
		delete(this);
		return;
	}
	
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
	if(qonquer_ammoreplace(this))
	{
		delete(this);
		return;
	}

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
	if(qonquer_ammoreplace(this))
	{
		delete(this);
		return;
	}

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
	if(qonquer_ammoreplace(this))
	{
		delete(this);
		return;
	}

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
	if(qonquer_ammoreplace(this))
	{
		delete(this);
		return;
	}

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
	if(qonquer_ammoreplace(this))
	{
		delete(this);
		return;
	}

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
	if(qonquer_ammoreplace(this))
	{
		delete(this);
		return;
	}

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
	if(!autocvar_sv_quake_globalkeys && (toucher.items & this.items))
		return;

	string keyname = (this.netname != "") ? this.netname : "key";
	Send_Notification(NOTIF_ALL_EXCEPT, toucher, MSG_MULTI, ITEM_KEY_GOT, toucher.netname, keyname);
	Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, ITEM_KEY_GOT_SELF, keyname);

	_sound(toucher, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");

	if(!coop)
	{	
		this.solid = SOLID_NOT;
		this.model = string_null;
	}
	SUB_UseTargets(this, toucher, NULL);				// fire all targets / killtargets
	this.target = string_null; // only fire the trigger once though
	if(autocvar_sv_quake_globalkeys)
	{
		horde_key_give(this.items);
		delete(this);
	}
	else
		toucher.items |= this.items;

	if(toucher.m_champion && toucher.m_champion.m_pickup_key)
		toucher.m_champion.m_pickup_key(toucher.m_champion, toucher, this);
}

bool key_customize(entity this, entity client)
{
	if(autocvar_sv_quake_globalkeys)
		return true;
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
		precache_sound("misc/basekey.wav");
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

	Send_Notification(NOTIF_ALL_EXCEPT, toucher, MSG_MULTI, ITEM_RUNE_GOT, toucher.netname);
	Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, ITEM_RUNE_GOT_SELF);

	_sound(toucher, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");
	this.solid = SOLID_NOT;
	this.model = string_null;
	this.noise = string_null; // so triggers don't play it again
	this.classname = ""; // so rune doors won't find it
	if(substring(world.model, 0, 10) == "maps/banjo")
		serverflags |= (this.spawnflags);
	else if(substring(world.model, 0, 6) != "maps/e")
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

	if(toucher.m_champion && toucher.m_champion.m_pickup_sigil)
		toucher.m_champion.m_pickup_sigil(toucher.m_champion, toucher, this);

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
	if(this.svflags > 0)
		this.spawnflags = this.svflags;

	if(!this.spawnflags)
		this.spawnflags |= SIGIL_E1;

	if(!this.noise || this.noise == "")
		this.noise = "misc/runekey.wav";

	precache_sound(this.noise);

	if(this.spawnflags & SIGIL_E1)
	{
		this.spawnflags = SIGIL_E1;
		if(!this.model || this.model == "")
			this.model = "progs/end1.mdl";
	}
	if(this.spawnflags & SIGIL_E2)
	{
		this.spawnflags = SIGIL_E2;
		if(!this.model || this.model == "")
			this.model = "progs/end2.mdl";
	}
	if(this.spawnflags & SIGIL_E3)
	{
		this.spawnflags = SIGIL_E3;
		if(!this.model || this.model == "")
			this.model = "progs/end3.mdl";
	}
	if(this.spawnflags & SIGIL_E4)
	{
		this.spawnflags = SIGIL_E4;
		if(!this.model || this.model == "")
			this.model = "progs/end4.mdl";
	}

	precache_model(this.model);
	_setmodel(this, this.model);

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
entity horn_spawnmonster(vector spawnpos, entity actor, Monster mon)
{
	if(!mon || mon == MON_Null)
	{
		bool seasonlocked = Monsters_SeasonLocked();
		RandomSelection_Init();
		FOREACH(Monsters, it != MON_Null,
		{
			if((it.spawnflags & MONSTER_TYPE_SWIM) && actor.waterlevel < 1)
				continue;
			if(it.spawnflags & MONSTER_TYPE_DECOY)
				continue; // no decoys please!
			if((it.spawnflags & MONSTER_TYPE_BOSS) || (it.spawnflags & MON_FLAG_STATIONARY) || (it.spawnflags & MON_FLAG_HIDDEN) || (it.spawnflags & MONSTER_TYPE_UNDEAD))
				continue;
			if((it.spawnflags & MON_FLAG_XMAS) && seasonlocked)
				continue;
			RandomSelection_AddEnt(it, 1, 1);
		});
		mon = RandomSelection_chosen_ent;
	}

	if(!mon || mon == MON_Null)
		return NULL;

	entity monster = new(monster);
	monster.monsterdef = mon;
	monster.flags |= FL_MONSTER;
	//monster.owner = actor;
	monster.spawnfunc_checked = true;
	monster.solid = SOLID_SLIDEBOX;
	setmodel(monster, mon.m_model);
	setsize(monster, mon.m_mins, mon.m_maxs);
	if(mon.spawnflags & MONSTER_TYPE_SWIM) { monster.flags |= FL_SWIM; }
	if(mon.spawnflags & MONSTER_TYPE_FLY) { monster.flags |= FL_FLY; }
	if(monster.flags & FL_FLY)
		set_movetype(monster, MOVETYPE_QCENTITY);
	else
		set_movetype(monster, MOVETYPE_STEP);

	if(!(monster.flags & FL_SWIM) && !(mon.spawnflags & MONSTER_TYPE_BOSS))
	{
		IL_PUSH(g_damagedbycontents, monster);
		monster.damagedbycontents	= true;
	}

	if(actor)
	{
		monster.charmed = true;
		monster.charmer = actor;
		monster.colormod = '0 1 0';
	}

	setthink(monster, monster_start_go);
	monster.nextthink = time + 0.1;
	mon.mr_setup(mon, monster);
	if(monster.charmed)
		monster.health = max(monster.health, 1000);

	monster.max_health = monster.health;
	monster.angles = '0 0 0';
	if(actor)
		monster.angles_y = actor.angles_y;
	vector org = spawnpos;
	org.z += -mon.m_mins.z; // offset based on size
	setorigin(monster, org + '0 0 1');
	setcefc(monster, monster_customize);
	setup_minionsupport(monster);

	if(!(mon.spawnflags & MONSTER_TYPE_FLY))
		DropToFloor_QC_DelayedInit(monster);
	
	tracebox(monster.origin, monster.mins, monster.maxs, monster.origin, MOVE_NOMONSTERS, monster);
	if(trace_startsolid)
		LOG_DEBUG("Monster in wall at ", vtos(monster.origin), "\n");
	monster.takedamage = DAMAGE_AIM;
	monster.ideal_yaw = monster.angles * '0 1 0';
	if(!monster.yaw_speed)
		monster.yaw_speed = 20;
	monster.view_ofs = '0 0 25';
	monster.use = monster_use;
	//monster.effects |= EF_DIMLIGHT;
	return monster;
}

// hacked copy of what monsters do during ai_run
void invis_enemy_dropaggro(entity this)
{
	this.enemy = NULL;
	if(this.is_frozen)
		return;
	if(this.charmed)
	{
		HuntCharmer(this);
		return;
	}
	// FIXME: look all around for other targets
	if(this.oldenemy.health > 0 && !(this.oldenemy.flags & FL_NOTARGET) && !StatusEffects_active(STATUSEFFECT_Invisibility, this.oldenemy))
	{
		this.enemy = this.oldenemy;
		HuntTarget(this);
	}
	else
	{
		if(this.movetarget && this.th_walk)
		{
			setthink(this, this.th_walk);
			this.nextthink = time;
		}
		else if(this.th_stand)
		{
			setthink(this, this.th_stand);
			this.nextthink = time;
		}
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
	if(toucher.tank && this.classname != "item_hornofconjuring" && this.classname != "item_revival")
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
			if(this.invincible_finished || this.invisible_finished)
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
	else if(horde_ent)
	{
		setthink(this, SUB_Remove);
		this.nextthink = time;
	}

	_sound(toucher, CH_VOICE, this.noise, 1, ATTN_NORM);
	this.solid = SOLID_NOT;
	if(!(this.powerups & POWERUP_HORN_OF_CONJURING) && !(this.powerups & POWERUP_REVIVAL))
		toucher.powerups |= this.powerups;
	this.model = string_null;

	SUB_UseTargets(this, toucher, NULL);

// do the apropriate action
	if(this.radsuit_finished)
	{
		StatusEffects_apply(STATUSEFFECT_Biosuit, toucher, time + 30, 0);
		if(coop && !horde_ent) // Respawn this powerup in coop, since it might be required for progression
		{
			this.target = string_null; // but don't fire off targets again
			setthink(this, SUB_regen);
			this.nextthink = time + 2.5;
		}
	}

	if(this.invincible_finished)
	{
		float invulntime = (horde_ent) ? 5 : 30;
		StatusEffects_apply(STATUSEFFECT_Invulnerability, toucher, time + invulntime, 0);
	}

	if(this.invisible_finished)
	{
		float invistime = (horde_ent) ? 5 : 30;
		StatusEffects_apply(STATUSEFFECT_Invisibility, toucher, time + invistime, 0);
	}

	if(this.super_damage_finished)
	{
		float quadtime = (horde_ent) ? 5 : 30;
		StatusEffects_apply(STATUSEFFECT_Quad, toucher, time + quadtime, 0);
	}

	if(this.field_generator_finished)
	{
		toucher.field_generator_health = this.health;
		toucher.field_generator_time = -150;
		float fieldtime = (horde_ent) ? 15 : 30;
		StatusEffects_apply(STATUSEFFECT_FieldGen, toucher, time + fieldtime, 0);
	}

	if(this.wetsuit_finished)
	{
		StatusEffects_apply(STATUSEFFECT_Wetsuit, toucher, time + 30, 0);
		if(coop && !horde_ent) // Respawn this powerup in coop, since it might be required for progression
		{
			this.target = string_null; // but don't fire off targets again
			setthink(this, SUB_regen);
			this.nextthink = time + 2.5;
		}
	}

	if(this.empathy_finished)
	{
		float etime = (horde_ent) ? 15 : 30;
		StatusEffects_apply(STATUSEFFECT_EmpathyShields, toucher, time + etime, 0);
	}

	if(this.powerups & POWERUP_HORN_OF_CONJURING)
	{
		// horns with a target will use the regular func_spawn method
		if(!this.target || this.target == "")
		{
			// otherwise attempt to spawn in a random monster
			horn_spawnmonster(this.origin, toucher, MON_Null);
		}
	}

	if(this.antigrav_finished)
	{
		StatusEffects_apply(STATUSEFFECT_Antigrav, toucher, time + 45, 0);
		if(coop && !horde_ent) // Respawn this powerup in coop, since it might be required for progression
		{
			this.target = string_null; // but don't fire off targets again
			setthink(this, SUB_regen);
			this.nextthink = time + 2.5;
		}
	}

	if(this.shield_finished)
	{
		float shieldtime = (horde_ent) ? 15 : 30;
		StatusEffects_apply(STATUSEFFECT_Shield, toucher, time + shieldtime, 0);
	}

	if(this.powerups & POWERUP_V_SPHERE)
	{
		sphere_spawn(this, toucher);
		sphere_spawn(this, toucher);
		sphere_spawn(this, toucher);
		toucher.vsphere_last = time + 0.5; // give player a chance to see they have them!
	}

	if(this.jboots_finished)
	{
		StatusEffects_apply(STATUSEFFECT_JumpBoots, toucher, time + 30, 0);
		if(coop && !horde_ent) // Respawn this powerup in coop, since it might be required for progression
		{
			this.target = string_null; // but don't fire off targets again
			setthink(this, SUB_regen);
			this.nextthink = time + 2.5;
		}
	}

	if(this.sharp_finished)
	{
		float sharptime = (horde_ent) ? 10 : 30;
		StatusEffects_apply(STATUSEFFECT_SharpShooter, toucher, time + sharptime, 0);
	}

	if(this.powerups & POWERUP_REVIVAL)
	{
		if(horde_ent)
			RespawnAllPlayers();
	}

	if(toucher.m_champion && toucher.m_champion.m_pickup_powerup)
		toucher.m_champion.m_pickup_powerup(toucher.m_champion, toucher, this);
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
	if(!this.invincible_finished)
		this.invincible_finished = 30;
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
	if(!this.radsuit_finished)
		this.radsuit_finished = 30;
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
	if(!this.invisible_finished)
		this.invisible_finished = 30;
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
	if(!this.super_damage_finished)
		this.super_damage_finished = 30;
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
	if(!this.field_generator_finished)
		this.field_generator_finished = 30;
	setsize(this, '-16 -16 -24', '16 16 32');
	this.health = 200;
	StartItem(this);
}

/*QUAKED item_powerup_shield (0 .5 .8) (-16 -16 -24) (16 16 32)
The shield upgrade
*/
spawnfunc(item_powerup_shield)
{
	settouch(this, powerup_touch);

	precache_model("progs/shield.mdl");
	precache_model("progs/p_shield.mdl");
	precache_sound("shield/pickup.wav");
	precache_sound("shield/hit.wav");
	precache_sound("shield/fadeout.wav");
	this.noise = "shield/pickup.wav";
	_setmodel(this, "progs/shield.mdl");
	this.netname = "Power Shield";
	this.powerups = POWERUP_SHIELD;
	if(!this.shield_finished)
		this.shield_finished = 30;
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}

/*QUAKED item_powerup_belt (0 .5 .8) (-16 -16 -24) (16 16 32)
The anti-grav belt
*/
spawnfunc(item_powerup_belt)
{	
	settouch(this, powerup_touch);

	precache_model("progs/beltup.mdl");
	precache_sound("belt/pickup.wav");
	precache_sound("belt/use.wav");
	precache_sound("belt/fadeout.wav");
	this.noise = "belt/pickup.wav";
	_setmodel(this, "progs/beltup.mdl");
	this.netname = "Anti-Grav Belt";
	this.powerups = POWERUP_ANTIGRAV;
	if(!this.antigrav_finished)
		this.antigrav_finished = 45;
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}

/*QUAKED item_artifact_wetsuit (0 .5 .8) (-16 -16 -24) (16 16 32)
Player takes no damage from electrical attacks and swims faster for 30 seconds
*/
spawnfunc(item_artifact_wetsuit)
{
	settouch(this, powerup_touch);

	precache_model("progs/wetsuit.mdl");
	precache_sound("misc/wetsuit.wav");
	precache_sound("misc/weton.wav");
	precache_sound("items/suit2.wav");
	this.noise = "misc/weton.wav";
	_setmodel(this, "progs/wetsuit.mdl");
	this.netname = "Wetsuit";
	this.powerups = POWERUP_WETSUIT;
	if(!this.wetsuit_finished)
		this.wetsuit_finished = 30;
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
	settouch(this, powerup_touch);

	precache_model("progs/empathy.mdl");
	precache_sound("hipitems/empathy.wav");
	precache_sound("hipitems/empathy2.wav");
	precache_sound("items/suit2.wav");
	this.noise = "hipitems/empathy.wav";
	_setmodel(this, "progs/empathy.mdl");
	this.netname = "Empathy Shields";
	this.powerups = POWERUP_EMPATHY_SHIELDS;
	if(!this.empathy_finished)
		this.empathy_finished = 30;
	setsize(this, '-16 -16 0', '16 16 32');
	StartItem(this);
}

spawnfunc(item_jboots)
{
	settouch(this, powerup_touch);

	precache_model("progs/jumpblue.mdl");
	precache_sound("items/jboots_got_timed.wav");
	precache_sound("items/jboots_timed.wav");
	precache_sound("items/goomba.wav");
	this.noise = "items/jboots_got_timed.wav";
	_setmodel(this, "progs/jumpblue.mdl");
	this.netname = "Jump Boots";
	this.powerups = POWERUP_JUMPBOOTS;
	if(!this.jboots_finished)
		this.jboots_finished = 30;
	setsize(this, '-16 -16 0', '16 16 32');
	StartItem(this);
}

spawnfunc(item_jboots_timed)
{
	// we don't have super jump boots, just allow spawns to work
	spawnfunc_item_jboots(this);
}

/*QUAKED item_artifact_sharp_shooter(0 .5 .8)(-16 -16 -24)(16 16 32)
From Arcane Dimensions, reused as an infinite ammo powerup
*/
spawnfunc(item_artifact_sharp_shooter)
{
	settouch(this, powerup_touch);

	precache_model("progs/artifact_sharp.mdl");
	precache_sound("items/sharp.wav");
	precache_sound("items/sharp2.wav");
	precache_sound("items/sharp3.wav");
	this.noise = "items/sharp.wav";
	_setmodel(this, "progs/artifact_sharp.mdl");
	this.netname = "Sharp Shooter";
	this.powerups = POWERUP_SHARPSHOOTER;
	if(!this.sharp_finished)
		this.sharp_finished = 30;
	setsize(this, '-16 -16 -24', '16 16 32');
	StartItem(this);
}

/*QUAKED item_revival (0 .5 .8) (-16 -16 0) (16 16 32)
Revival heart, brings back fallen allies
Does nothing outside of horde
*/
spawnfunc(item_revival)
{
	settouch(this, powerup_touch);

	precache_model("progs/revival.mdl");
	precache_sound("items/revival.wav");
	_setmodel(this, "progs/revival.mdl");
	this.noise = "items/revival.wav";
	this.netname = "Revival";
	this.powerups = POWERUP_REVIVAL;
	setsize(this, '-16 -16 0', '16 16 32');
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

	bool valid_owner = false;
	if(this.crypto_idfp && this.crypto_idfp != "" && this.crypto_idfp == toucher.crypto_idfp)
		valid_owner = true;
	if(this.realowner == toucher)
		valid_owner = true;
	if(!valid_owner && (this.realowner || this.crypto_idfp))
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
	.entity weaponentity = weaponentities[0];

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
	strfree(this.crypto_idfp);
	delete(this);

	EnableComboWeapons(toucher);

// change to the weapon
	if(wep != WEP_Null && toucher.cvar_cl_autoswitch)
	{
		if((toucher.flags & FL_INWATER) && wep == WEP_LIGHTNING)
			return; // lol

		if(!deathmatch)
			W_SwitchWeapon(toucher, wep, weaponentity);
		else
			Deathmatch_Weapon(toucher, wep, weaponentity);
	}
}

bool BackpackCustomize(entity this, entity client)
{
	bool valid_owner = false;
	if(this.crypto_idfp && this.crypto_idfp != "" && this.crypto_idfp == client.crypto_idfp)
		valid_owner = true;
	if(this.realowner == client)
		valid_owner = true;
	return ((!this.realowner && (!this.crypto_idfp || this.crypto_idfp == "")) || valid_owner);
}

/*
===============
DropBackpack
===============
*/
void DropBackpack(entity this)
{
	WepSet weps = STAT(WEAPONS, this);
	weps &= ~WEPSET_CHAMPIONS;

	if(weps == '0 0 0' && !(this.ammo_shells + this.ammo_nails + this.ammo_rockets + this.ammo_cells + this.ammo_lava_nails + this.ammo_multi_rockets + this.ammo_plasma))
		return;	// nothing in it

	if(STAT(SKATING, this))
		return; // skaters don't drop loot!
	if(this.charmed)
		return; // no pet looting thank you very much

	// Yoder Sept24 2021 Horde Merge
	// don't drop backpacks in horde mode
	if(horde_ent)
		return; 

	entity item = spawn();
	traceline(this.origin, this.origin - '0 0 24', MOVE_NORMAL, this);
	setorigin(item, trace_endpos);

	.entity weaponentity = weaponentities[0];
	Weapon wep = this.(weaponentity).m_weapon;
	if(wep.spawnflags & WEP_FLAG_CHAMPION)
		wep = REGISTRY_GET(Weapons, this.(weaponentity).cnt);
	item.weapon = wep.m_id;
	item.netname = wep.m_name;
	STAT(WEAPONS, item) = weps;

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
	item.effects |= EF_FULLBRIGHT;
	item.owner = this;

	item.solid = SOLID_TRIGGER;
	set_movetype(item, MOVETYPE_TOSS);
	_setmodel(item, "progs/backpack.mdl");
	vector mi = '-16 -16 0', ma = '16 16 56';
	// TODO: this hack causes a crash, find a better way to move items out of solid!
#if 0
	// some enemies can be smaller than items so we must account for that and not put the item in the wall!
	tracebox(item.origin, mi, ma, item.origin, MOVE_NOMONSTERS, item);
	if(trace_startsolid)
	{
		mi.x = max(mi.x, this.mins_x);
		mi.y = max(mi.y, this.mins_y);
		mi.z = max(mi.z, this.mins_z);
		ma.x = min(ma.x, this.maxs_x);
		ma.y = min(ma.y, this.maxs_y);
		ma.z = min(ma.z, this.maxs_z);
	}
#endif
	setsize(item, mi, ma);
	settouch(item, BackpackTouch);
	if(autocvar_sv_quake_instance_backpacks && IS_PLAYER(this) && IS_REAL_CLIENT(this))
	{
		item.realowner = this;
		if(this.crypto_idfp)
			strcpy(item.crypto_idfp, this.crypto_idfp);
		setcefc(item, BackpackCustomize);
	}
	
	item.nextthink = time + 240;
	setthink(item, SUB_Remove);
}

/*
===============================================================================

DROPPING

===============================================================================
*/

void ItemFall(entity this)
{
	if(!(this.spawnflags & ITEM_SUSPENDED))
		return;
	this.solid = SOLID_TRIGGER;
	set_movetype(this, MOVETYPE_TOSS);	
	this.velocity = '0 0 1';
	this.spawnflags &= ~ITEM_SUSPENDED;
}

void target_drop_do(string tname)
{
	if(!tname || tname == "")
		return;
		
	entity t = NULL;
	
	do
	{
		t = find(t, targetname, tname);
		if(!t)
			break;
		
		ItemFall(t);
	} while(t);
}

void target_drop_use(entity this, entity actor, entity trigger)
{
	target_drop_do(this.target);
	target_drop_do(this.target2);
	target_drop_do(this.target3);
	target_drop_do(this.target4);
}

/*QUAKED target_drop (0.75 0.25 0) (-16 -16 -16) (16 16 16) ?
Causes all targeted items which are SUSPENDED to drop when triggered.
*/
/*FGD
@PointClass base(Appearflags, Targetname) size(32 32 32) color(192 64 0) = target_drop : 
"Target Drop. Causes all targeted items which are suspended to drop when triggered."
[
	target(target_destination) : "Target: acts on all items with a matching targetname" 
	target2(target_destination) : "Target 2: acts on all items with a matching targetname" 
	target3(target_destination) : "Target 3: acts on all items with a matching targetname" 
	target4(target_destination) : "Target 4: acts on all items with a matching targetname" 
]
*/
spawnfunc(target_drop)
{
	this.use = target_drop_use;
}



/*
===============================================================================

GIVING/TAKING/CHECKING

===============================================================================
*/

// nasty series of hacks copied from copper to make maps mostly functional

const int SPAWN_TGTITEMS_TAKE = 1;
const int SPAWN_TGTITEMS_OVERRIDE = 2;
const int SPAWN_TGTITEMS_FLASH = 4;
const int SPAWN_TGTITEMS_TEST = 8;
const int SPAWN_TGTITEMS_MIN = 16;

const float ARMORTYPE_GREEN = 0.3;
const float ARMORTYPE_YELLOW = 0.5;
const float ARMORTYPE_RED = 0.7;

const int IT_INVISIBILITY			= 524288;
const int IT_INVULNERABILITY		= 1048576;
const int IT_SUIT					= 2097152;
const int IT_QUAD					= 4194304;

.string deathtype;

/*FGD
@baseclass = TrigItems [
	svflags(flags) =
	[
		1 : "E1 complete" : 0
		2 : "E2 complete" : 0
		4 : "E3 complete" : 0
		8 : "E4 complete" : 0
		16 : "Unused" : 0
		32 : "Unused" : 0
		64 : "Unused" : 0
		128 : "Unused" : 0
	]
	items(flags) =
	[
		1 : "Shotgun" : 0
		2 : "Super Shotgun" : 0
		4 : "Nailgun" : 0
		8 : "Perforator" : 0
		16 : "Grenade Laucher" : 0
		32 : "Rocket Launcher" : 0
		64 : "Lightning Gun" : 0
		4096 : "Axe" : 0
		131072 : "Silver Key" : 0
		262144 : "Gold Key" : 0
		524288 : "Ring" : 0
		1048576 : "Pent" : 0
		2097152 : "Biosuit" : 0
		4194304 : "Quad" : 0
	]
	ammo_shells(integer) : "Shells" : 0
	ammo_nails(integer) : "Nails" : 0
	ammo_rockets(integer) : "Rockets" : 0
	ammo_cells(integer) : "Cells" : 0
	health(integer) : "Health" : 0
	armorvalue(integer) : "Armor" : 0
	armortype(choices) : "Armor Strength" = [
		0.0 : "Ignore"
		0.3 : "Green (30%)"
		0.5 : "Yellow (50%)"
		0.7 : "Red (70%)"
	]
]
*/
void armor_set_type(entity e)
{
	if(!IS_PLAYER(e))
		return;
	
	e.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
	if(!e.armorvalue)
	{
		e.armortype = 0;
		return;
	}
	
	if(e.armortype < ARMORTYPE_YELLOW)
		e.items |= IT_ARMOR1;
	else if(e.armortype < ARMORTYPE_RED)
		e.items |= IT_ARMOR2;
	else
		e.items |= IT_ARMOR3;
	
	e.armorvalue = min(e.armorvalue, 500);
}

void target_items_takeweapon(entity player, Weapon wep)
{
	if(STAT(DUAL_WEAPONS, player) & wep.m_wepset)
		STAT(DUAL_WEAPONS, player) &= ~wep.m_wepset;
	else
	{
		STAT(WEAPONS, player) &= ~wep.m_wepset;
		.entity weaponentity = weaponentities[0];
		if(player.(weaponentity).m_weapon == wep)
			W_SwitchWeapon(player, w_getbestweapon(player, weaponentity), weaponentity);
	}

	// since this is a nasty ass trigger, let's be nice and let them gather a new dual weapon!
	player.collected_weapons &= ~wep.m_wepset;
}

void target_items_giveweapon(entity player, Weapon wep)
{
	if(STAT(WEAPONS, player) & wep.m_wepset)
		STAT(DUAL_WEAPONS, player) |= wep.m_wepset;
	else
		STAT(WEAPONS, player) |= wep.m_wepset;

	if(player.cvar_cl_autoswitch)
	{
		.entity weaponentity = weaponentities[0]; // TODO?
		if(!deathmatch)
			W_SwitchWeapon(player, wep, weaponentity);
		else
			Deathmatch_Weapon(player, wep, weaponentity);
	}

	player.collected_weapons |= wep.m_wepset;
}

void target_items_setweapon(entity this, entity e, int dotake)
{
	Weapon wep = REGISTRY_GET(Weapons, this.weapon);
	if(dotake == 2)
	{
		if(STAT(WEAPONS, e) & wep.m_wepset)
			target_items_takeweapon(e, wep);
		else
			target_items_giveweapon(e, wep);
	}
	else if(dotake == 1)
		target_items_takeweapon(e, wep);
	else
		target_items_giveweapon(e, wep);
}

void target_items_giveinv_min(entity this, entity e)
{
	if(this.health && this.health > e.health)
		T_Heal(e, (this.health - e.health), true);
	
	float arm = zeroconvert(this.armorvalue);
	if(arm > e.armorvalue)
	{
		int bit = IT_ARMOR1;
		if(this.armortype >= ARMORTYPE_RED)
			bit = IT_ARMOR3;
		else if(this.armortype >= ARMORTYPE_YELLOW)
			bit = IT_ARMOR2;
		else
			bit = IT_ARMOR1;
		e.armortype = this.armortype;
		e.armorvalue = arm;
		e.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
		e.items |= bit;
	}

	if(this.ammo_shells) e.ammo_shells =	max(e.ammo_shells,	zeroconvert(this.ammo_shells));
	if(this.ammo_nails) e.ammo_nails =		max(e.ammo_nails,	zeroconvert(this.ammo_nails));
	if(this.ammo_rockets) e.ammo_rockets =	max(e.ammo_rockets,	zeroconvert(this.ammo_rockets));
	if(this.ammo_cells) e.ammo_cells =		max(e.ammo_cells,	zeroconvert(this.ammo_cells));
}

void target_items_giveinv(entity this, entity e)
{
	if(this.spawnflags & SPAWN_TGTITEMS_MIN)
	{
		target_items_giveinv_min(this, e);
	}
	else
	{
		if(this.health)
			T_Heal(e, this.health, true);
			
		if(this.armorvalue)
		{
			float avalue = zeroconvert(this.armorvalue);
			if(avalue > e.armorvalue)
			{
				int bit = IT_ARMOR1;
				if(this.armortype >= ARMORTYPE_RED)
					bit = IT_ARMOR3;
				else if(this.armortype >= ARMORTYPE_YELLOW)
					bit = IT_ARMOR2;
				else
					bit = IT_ARMOR1;
				e.armortype = this.armortype;
				e.armorvalue = avalue;
				e.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
				e.items |= bit;
			}
		}

		if(this.ammo_shells) e.ammo_shells += zeroconvert(this.ammo_shells);
		if(this.ammo_nails) e.ammo_nails += zeroconvert(this.ammo_nails);
		if(this.ammo_rockets) e.ammo_rockets += zeroconvert(this.ammo_rockets);
		if(this.ammo_cells) e.ammo_cells += zeroconvert(this.ammo_cells);
	}
	bound_other_ammo(e);
	
	if(this.svflags)
		serverflags |= zeroconvert(this.svflags);

	if(this.items)
	{
		float it = zeroconvert(this.items);
		
		// set artifact timers properly
		if(it & IT_INVISIBILITY)
			StatusEffects_apply(STATUSEFFECT_Invisibility, e, time + this.length, 0);
		if(it & IT_INVULNERABILITY)
			StatusEffects_apply(STATUSEFFECT_Invulnerability, e, time + this.length, 0);
		if(it & IT_SUIT)
			StatusEffects_apply(STATUSEFFECT_Biosuit, e, time + this.length, 0);
		if(it & IT_QUAD)
			StatusEffects_apply(STATUSEFFECT_Quad, e, time + this.length, 0);
		
		if(it & IT_KEY1)
		{
			if(autocvar_sv_quake_globalkeys)
			{
				horde_key_give(IT_KEY1);
				//delete(this);
			}
			else
				e.items |= IT_KEY1;
		}
		if(it & IT_KEY2)
		{
			if(autocvar_sv_quake_globalkeys)
			{
				horde_key_give(IT_KEY2);
				//delete(this);
			}
			else
				e.items |= IT_KEY2;
		}
	}

	if(this.weapon)
		target_items_setweapon(this, e, 0);
}

bool target_items_testinv(entity this, entity e)
{
	if(this.health > 0 && this.health > e.health) return false;
	if(this.armorvalue && this.armorvalue > e.armorvalue) return false;
	if(this.armortype && this.armortype > e.armortype) return false;

	if(this.svflags)
	{
		float sf = zeroconvert(this.svflags);
		if((sf & serverflags) != sf)
			return false;
	}

	if(this.ammo_shells && this.ammo_shells > e.ammo_shells) return false;
	if(this.ammo_nails && this.ammo_nails > e.ammo_nails) return false;
	if(this.ammo_rockets && this.ammo_rockets > e.ammo_rockets) return false;
	if(this.ammo_cells && this.ammo_cells > e.ammo_cells) return false;

	if(this.items)
	{
		float it = zeroconvert(this.items);
		if(it & e.items != it)
			return false;
	}

	if(this.weapon)
	{
		Weapon wep = REGISTRY_GET(Weapons, this.weapon);
		if(!(STAT(WEAPONS, e) & wep.m_wepset))
			return false;
	}

	return true;
}

bool target_items_takeinv(entity this, entity e, entity actor)
{
	if(!(this.spawnflags & SPAWN_TGTITEMS_MIN))
	{
		if(!target_items_testinv(this, e))
			return false;
	}
	
	if(this.armorvalue)
	{
		e.armorvalue = max(0, e.armorvalue - this.armorvalue);
		armor_set_type(e);
	}

	if(this.health > 0)
	{
		string oldmessage = this.message;
		this.message = this.deathtype;
		T_Damage(e, this, actor, min(e.health, this.health), DEATH_HURTTRIGGER.m_id);
		this.message = oldmessage;
		if(e.health <= 0)
			return false;
	}
		
	if(this.svflags)
	{
		float sf = zeroconvert(this.svflags);
		serverflags &= ~sf;
	}

	if(this.ammo_shells)
	{
		e.ammo_shells = max(0, e.ammo_shells - zeroconvert(this.ammo_shells));
	}
	if(this.ammo_nails)
	{
		e.ammo_nails = max(0, e.ammo_nails - zeroconvert(this.ammo_nails));
	}
	if(this.ammo_rockets)
	{
		e.ammo_rockets = max(0, e.ammo_rockets - zeroconvert(this.ammo_rockets));
	}
	if(this.ammo_cells)
	{
		e.ammo_cells = max(0, e.ammo_cells - zeroconvert(this.ammo_cells));
	}

	if(this.items)
	{
		float it = zeroconvert(this.items);
		
		// set artifact timers properly
		if(it & IT_INVISIBILITY)
			StatusEffects_remove(STATUSEFFECT_Invisibility, e, STATUSEFFECT_REMOVE_CLEAR);

		if(it & IT_INVULNERABILITY)
			StatusEffects_remove(STATUSEFFECT_Invulnerability, e, STATUSEFFECT_REMOVE_CLEAR);

		if(it & IT_SUIT)
			StatusEffects_remove(STATUSEFFECT_Biosuit, e, STATUSEFFECT_REMOVE_CLEAR);

		if(it & IT_QUAD)
			StatusEffects_remove(STATUSEFFECT_Quad, e, STATUSEFFECT_REMOVE_CLEAR);

		if(it & IT_KEY1)
		{
			if(autocvar_sv_quake_globalkeys)
			{
				horde_key_spend(IT_KEY1);
				//delete(this);
			}
			else
				e.items &= ~IT_KEY1;
		}
		if(it & IT_KEY2)
		{
			if(autocvar_sv_quake_globalkeys)
			{
				horde_key_spend(IT_KEY2);
				//delete(this);
			}
			else
				e.items &= ~IT_KEY2;
		}
	}

	if(this.weapon)
		target_items_setweapon(this, e, 1);
	
	return true;
}


void target_items_setinv(entity this, entity e, entity actor)
{
	if(this.health > 0)
		e.health = this.health;
		
	if(this.armorvalue)
	{
		e.armorvalue = zeroconvert(this.armorvalue);
		if(this.armortype)
		{
			e.armortype = this.armortype;
		}
		else	// value but no type: assume a color from amount given
		{
			if(this.armorvalue > 150)
				e.armortype = ARMORTYPE_RED;
			else if(this.armorvalue > 100)
				e.armortype = ARMORTYPE_YELLOW;
			else
				e.armortype = ARMORTYPE_GREEN;
		}
		armor_set_type(e);
	}
	else if(this.armortype && e.armorvalue)	// type but not value: override color on player
	{
		e.armortype = this.armortype;
		armor_set_type(e);
	}

	if(this.svflags)
		serverflags = zeroconvert(this.svflags);		

	if(this.ammo_shells) e.ammo_shells = zeroconvert(this.ammo_shells);
	if(this.ammo_nails) e.ammo_nails = zeroconvert(this.ammo_nails);
	if(this.ammo_rockets) e.ammo_rockets = zeroconvert(this.ammo_rockets);
	if(this.ammo_cells) e.ammo_cells = zeroconvert(this.ammo_cells);
	bound_other_ammo(e);
	
	if(this.items)
	{
		float it = zeroconvert(this.items);
			
		// set artifact timers properly
		if(it & IT_INVISIBILITY)
			StatusEffects_apply(STATUSEFFECT_Invisibility, e, time + this.length, 0);
		else
			StatusEffects_remove(STATUSEFFECT_Invisibility, e, STATUSEFFECT_REMOVE_CLEAR);

		if(it & IT_INVULNERABILITY)
			StatusEffects_apply(STATUSEFFECT_Invulnerability, e, time + this.length, 0);
		else
			StatusEffects_remove(STATUSEFFECT_Invulnerability, e, STATUSEFFECT_REMOVE_CLEAR);

		if(it & IT_SUIT)
			StatusEffects_apply(STATUSEFFECT_Biosuit, e, time + this.length, 0);
		else
			StatusEffects_remove(STATUSEFFECT_Biosuit, e, STATUSEFFECT_REMOVE_CLEAR);

		if(it & IT_QUAD)
			StatusEffects_apply(STATUSEFFECT_Quad, e, time + this.length, 0);
		else
			StatusEffects_remove(STATUSEFFECT_Quad, e, STATUSEFFECT_REMOVE_CLEAR);

		if(autocvar_sv_quake_globalkeys)
		{
			horde_key_spend(IT_KEY1);
			//delete(this);
		}
		else
			e.items &= ~IT_KEY1;

		if(autocvar_sv_quake_globalkeys)
		{
			horde_key_spend(IT_KEY2);
			//delete(this);
		}
		else
			e.items &= ~IT_KEY2;

		e.worldtype = 0;
		if(it & IT_KEY1)
		{
			if(autocvar_sv_quake_globalkeys)
			{
				horde_key_give(IT_KEY1);
				//delete(this);
			}
			else
				e.items |= IT_KEY1;
		}
		if(it & IT_KEY2)
		{
			if(autocvar_sv_quake_globalkeys)
			{
				horde_key_give(IT_KEY2);
				//delete(this);
			}
			else
				e.items |= IT_KEY2;
		}
	}

	if(this.weapon)
		target_items_setweapon(this, e, 2);
	
	// after resetweaponstate or else deadthink will be overwritten
	if(this.health < 0)
	{
		string oldmessage = this.message;
		this.message = this.deathtype;
		T_Damage(e, this, actor, e.health, DEATH_HURTTRIGGER.m_id);
		this.message = oldmessage;
	}
}

void target_items_use(entity this, entity actor, entity trigger)
{
	entity act = actor;
	if(!IS_PLAYER(act))
		return;
	if(act.health <= 0)
		return;
	
	if(this.spawnflags & SPAWN_TGTITEMS_OVERRIDE)
	{
		target_items_setinv(this, act, actor);
	}
	else if(this.spawnflags & SPAWN_TGTITEMS_TEST)
	{
		// TAKE reverses the polarity of TEST, so that it only tests if you don't
		// have all the specified inventory
		if(target_items_testinv(this, act) != !!(this.spawnflags & SPAWN_TGTITEMS_TAKE))
		{
			actor = act;
			SUB_UseTargetsSilent(this, actor, trigger);
		}
		else
		{
			SUB_PrintMessage(this, actor);
			return;
		}
	}
	else if(this.spawnflags & SPAWN_TGTITEMS_TAKE)
	{
		if(target_items_takeinv(this, act, actor))
		{
			actor = act;
			SUB_UseTargetsSilent(this, actor, trigger);
		}
		else
		{
			SUB_PrintMessage(this, actor);
			return;
		}
	}
	else
	{
		target_items_giveinv(this, act);
	}
	//if(this.spawnflags & SPAWN_TGTITEMS_FLASH)
		//stuffcmd(act, "bf\n");
	if(this.noise && this.noise != "")
		_sound(act, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
		
	actor = act;
}

/*QUAKED target_items (0.75 0.25 0) (-8 -8 -8) (8 8 8) TAKE OVERRIDE FLASH TEST MINIMUM
Gives weapons, ammo, items, health, armor, and/or runes to the activating player when triggered. 

Keyvalues:
"ammo_shells" number of shells player should receive - same for _cells, _rockets, and _nails
"health" health (will overheal beyond 100)
"armorvalue" armor (protection color scales automatically)
"armortype" armor strength (0.3+ green, 0.5+ yellow, 0.7+ red)
"weapon" item bitflag (not impulse number!) of the weapon the player should swap to (if he has it)
"items" bitmask of what items the player should get (see below for reference)
"svflags" bitmask of serverflags to alter (1/2/4/8 are the episode runes, 16+ are invisible)
"length" length of powerup time in seconds if any are given (default 30)
"noise" wav file to play on activator

Spawnflags:
FLASH: flash the recipient's screen when triggered, defaults to being stealthy
MINIMUM: for numeric amounts, give the player enough to have a minimum of the amount specified
TAKE: subtract specified inventory amounts instead of adding
  - subtracting enough health WILL kill the player
  - will fire its targets if all items can be successfully taken
  - will print "message" and take nothing instead
  - TAKE with MINIMUM will skip the test and take whatever it can, firing no targets either way
OVERRIDE: force the player's inventory to all specified amounts (mainly useful triggered from spawnpoints), specify -1 for any keyvalue to force a 0 (-1 does not work for health)
TEST: behaves like TAKE, but doesn't take anything 
  - fires targets if activator has the matching inventory
  - prints "message" if not
  - TEST with TAKE will reverse the test (fire if player doesn't have)
  - beware of how this interacts with triggers: it will only test the first client to touch a trigger in coop unless it has ALL_CLIENTS set

Item Bitmask Reference:
	SG	= 1		SSG	= 2
	NG	= 4		SNG	= 8
	GL	= 16	RL	= 32
	LG	= 64	Axe	= 4096
	
	Silver	= 131072
	Gold	= 262144
	Ring	= 524288
	Pent	= 1048576
	Biosuit	= 2097152
	Quad	= 4194304
*/
/*FGD
@PointClass base(Appearflags, Target, Targetname, TrigItems, Deathtype) size(32 32 32) color(192 64 0) = target_items : 
"Target: Give. Adds weapons, ammo, items, health, armor, and/or runes to the activating player when triggered.

Spawnflag Usage:
'Take': subtract specified inventory amounts instead of adding
  - subtracting enough health WILL kill the player
  - will fire its targets if all items are successfully taken
  - will print 'message' if fewer than all items are successfully taken
'Override': force the player's inventory to all specified amounts (mainly useful triggered from spawnpoints), specify -1 for any keyvalue to force a 0 (-1 does not work for items or health)
'Test Only': behaves like TAKE, but without taking anything 
  - fires targets if activator has the matching inventory
  - prints 'message' if not
  - TEST with TAKE will reverse the test (fire if player doesn't have)
  - beware of how this interacts with triggers: it will only test the first client to touch a trigger in coop!
'Minimum': for numeric amounts, give the player enough to have a minimum of the amount specified
'Flash screen': flash the recipient's screen when triggered, defaults to being stealthy"
[
	length(integer) : "Override powerup duration" : 0
	message(string) : "Message to print if Take was unsuccessful"
	spawnflags(flags) =
	[
		1 : "Take instead" : 0
		2 : "Override instead" : 0
		4 : "Flash screen" : 0
		8 : "Test only" : 0
		16 : "Minimum" : 0
	]
	weapon(choices) : "Force Select Weapon" = 
	[
		0 : "Don't"
		1 : "Shotgun"
		2 : "Super Shotgun"
		4 : "Nailgun"
		8 : "Perforator"
		16 : "Grenade Laucher"
		32 : "Rocket Launcher"
		64 : "Lightning Gun"
		4096 : "Axe"
	]
	noise(string) : "wav file to play on activator"
]
*/
spawnfunc(target_items)
{
	this.use = target_items_use;
	
	if(this.length <= 0)
		this.length = 30;
	if(!this.deathtype || this.deathtype == "")
		this.deathtype = "had their life removed";

	// force selection not fully supported, as players can disable autoswitch
	switch(this.weapon)
	{
		case 1: this.weapon = WEP_SHOTGUN.m_id; break;
		case 2: this.weapon = WEP_SUPER_SHOTGUN.m_id; break;
		case 4: this.weapon = WEP_NAILGUN.m_id; break;
		case 8: this.weapon = WEP_SUPER_NAILGUN.m_id; break;
		case 16: this.weapon = WEP_GRENADE_LAUNCHER.m_id; break;
		case 32: this.weapon = WEP_ROCKET_LAUNCHER.m_id; break;
		case 64: this.weapon = WEP_LIGHTNING.m_id; break;
		case 4096: this.weapon = WEP_AXE.m_id; break;
	}

	// now we must hack away their dumb version of weapons
	if(this.items & 1)
	{
		this.weapon = WEP_SHOTGUN.m_id;
		this.items &= ~1;
	}
	if(this.items & 2)
	{
		this.weapon = WEP_SUPER_SHOTGUN.m_id;
		this.items &= ~2;
	}
	if(this.items & 4)
	{
		this.weapon = WEP_NAILGUN.m_id;
		this.items &= ~4;
	}
	if(this.items & 8)
	{
		this.weapon = WEP_SUPER_NAILGUN.m_id;
		this.items &= ~8;
	}
	if(this.items & 16)
	{
		this.weapon = WEP_GRENADE_LAUNCHER.m_id;
		this.items &= ~16;
	}
	if(this.items & 32)
	{
		this.weapon = WEP_ROCKET_LAUNCHER.m_id;
		this.items &= ~32;
	}
	if(this.items & 64)
	{
		this.weapon = WEP_LIGHTNING.m_id;
		this.items &= ~64;
	}
	if(this.items & 4096)
	{
		this.weapon = WEP_AXE.m_id;
		this.items &= ~4096;
	}
	
	if(this.items > 0)
	{
		// clear the item flags that are only for HUD switches so we can be sloppy with .items later
		this.items &= ~(IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS | 
									 IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
	}
	
	// snap armor color to only allowed values
	if(this.armortype >= ARMORTYPE_RED)
		this.armortype = ARMORTYPE_RED;
	else if(this.armortype >= ARMORTYPE_YELLOW)
		this.armortype = ARMORTYPE_YELLOW;
	else if(this.armortype >= ARMORTYPE_GREEN)
		this.armortype = ARMORTYPE_GREEN;
	else
		this.armortype = 0;
	
	if(this.noise && this.noise != "")
		precache_sound(this.noise);
}
spawnfunc(target_give)
{
	spawnfunc_target_items(this);
}


// ==========================================================

// mode flags
const int SPAWN_NOTEASY = 256;
const int SPAWN_NOTNORMAL = 512;
const int SPAWN_NOTHARD = 1024;
const int SPAWN_NOTDM = 2048;
//const int SPAWN_COOPONLY = 4096;
//const int SPAWN_NOTCOOP = 8192;

const int SPAWNFLAG_ALL_CLIENTS = 16;

spawnfunc(trigger_multiple);
spawnfunc(trigger_inventory)
{
	LOG_DEBUG("trigger_inventory is deprecated; use an ALL_CLIENTS trigger with a target_items");
	
	// dumb rearguard action to support this entity I shouldn't have made: copy ourself
	// to an ALL_CLIENTS trigger, then turn ourself into a target_items that it triggers
	entity trig = spawn();
	trig.model = this.model;
	trig.wait = this.wait;
	trig.delay = this.delay;
	trig.spawnflags = (this.spawnflags & SPAWNFLAG_TRIGGER_FIRST) | SPAWNFLAG_ALL_CLIENTS;
	spawnfunc_trigger_multiple(trig);
	trig.targetname = this.targetname;
	
	vector bb = trig.origin + 0.5 * (trig.mins + trig.maxs);
	trig.target = ftos(fabs(bb_x+bb_y+bb_z));	// we need a unique-ish targetname ...
	this.targetname = trig.target;
	setorigin(this,bb);
	float inv = !(this.spawnflags & 1);
	this.spawnflags &= ~(SPAWN_NOTEASY - 1);
	this.spawnflags |= SPAWN_TGTITEMS_TEST + (SPAWN_TGTITEMS_TAKE * inv);
	spawnfunc_target_items(this);
}
