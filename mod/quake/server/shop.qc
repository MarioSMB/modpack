#include "shop.qh"

#include "../common/shop.qh"

void shop_buyitem(entity this, string item)
{
	if(!IS_PLAYER(this) || this.health <= 0)
		return;
	if(shop_opentime < time)
	{
		sprint(this, "You can only buy items after a boss wave\n");
		return;
	}

	if(item == "heal")
	{
		if(this.tank)
		{
			sprint(this, "You can't buy health while in a tank!\n");
			return;
		}
		if(this.frags < SHOP_COST_HEAL)
		{
			sprint(this, "You do not have enough points to buy this item, keep fragging!\n");
			return;
		}
		if(T_Heal(this, 100, true))
		{
			this.frags -= SHOP_COST_HEAL;
			_sound(this, CH_TRIGGER_SINGLE, "items/r_item2.wav", 1, ATTN_NORM);
			sprint(this, "Health restored\n");
		}
		else
			sprint(this, "Already at maximum health\n");
		return;
	}

	if(item == "armor")
	{
		if(this.tank)
		{
			sprint(this, "You can't buy armor while in a tank!\n");
			return;
		}
		if(this.frags < SHOP_COST_ARMOR)
		{
			sprint(this, "You do not have enough points to buy this item, keep fragging!\n");
			return;
		}
		float type = 0.3, value = 100;
		int bit = IT_ARMOR1;

		if(this.items & IT_ARMOR1)
		{
			type = 0.6;
			value = 150;
			bit = IT_ARMOR2;
		}
		else if((this.items & IT_ARMOR2) || (this.items & IT_ARMOR3))
		{
			type = 0.8;
			value = 200;
			bit = IT_ARMOR3;
		}
		if(this.armortype * this.armorvalue >= type * value)
		{
			sprint(this, "Already at maximum armor\n");
			return;
		}
		this.frags -= SHOP_COST_ARMOR;
		this.armortype = type;
		this.armorvalue = value;
		this.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
		this.items |= bit;
		_sound(this, CH_TRIGGER_SINGLE, "items/armor1.wav", 1, ATTN_NORM);
		sprint(this, "Armor upgraded\n");
		return;
	}

	if(item == "ammo")
	{
		if(this.frags < SHOP_COST_AMMO)
		{
			sprint(this, "You do not have enough points to buy this item, keep fragging!\n");
			return;
		}
		// TODO: does not verify that the player actually gained any ammo!
		this.frags -= SHOP_COST_AMMO;
		this.ammo_shells += 30; SendItemPickup(this, IT_SHELLS, 30);
		this.ammo_nails += 60; SendItemPickup(this, IT_NAILS, 60);
		this.ammo_rockets += 20; SendItemPickup(this, IT_ROCKETS, 20);
		this.ammo_cells += 30; SendItemPickup(this, IT_CELLS, 30);
		this.ammo_lava_nails += 60; SendItemPickup(this, IT_LAVA_NAILS, 60);
		this.ammo_multi_rockets += 20; SendItemPickup(this, IT_MULTI_ROCKETS, 20);
		this.ammo_plasma += 40; SendItemPickup(this, IT_PLASMA_AMMO, 40);
		bound_other_ammo(this);
		sprint(this, "Ammunition restocked\n");
		_sound(this, CH_TRIGGER_SINGLE, "weapons/lock4.wav", 1, ATTN_NORM);
		return;
	}

	if(item == "rifle")
	{
		if(shop_passive != IT_PULSERIFLE)
		{
			sprint(this, "Invalid item\n");
			return;
		}

		if(this.frags < SHOP_COST_PASSIVE)
		{
			sprint(this, "You do not have enough points to buy this item, keep fragging!\n");
			return;
		}

		if(this.items & IT_PULSERIFLE)
		{
			sprint(this, "You already have the Pulse Rifle\n");
			return;
		}

		this.frags -= SHOP_COST_PASSIVE;
		this.items |= IT_PULSERIFLE;
		sprint(this, "Pulse Rifle Sidearm activated\n");
		_sound(this, CH_TRIGGER_SINGLE, "weapons/pulse/install.wav", 1, ATTN_NORM);
		return;
	}

	if(item == "fireball")
	{
		if(shop_passive != IT_FIREBALL)
		{
			sprint(this, "Invalid item\n");
			return;
		}

		if(this.frags < SHOP_COST_PASSIVE)
		{
			sprint(this, "You do not have enough points to buy this item, keep fragging!\n");
			return;
		}

		if(this.items & IT_FIREBALL)
		{
			sprint(this, "You already have the Fireball\n");
			return;
		}

		this.frags -= SHOP_COST_PASSIVE;
		this.items |= IT_FIREBALL;
		sprint(this, "Fireball Launcher activated\n");
		_sound(this, CH_TRIGGER_SINGLE, "weapons/pulse/install.wav", 1, ATTN_NORM);
		return;
	}

	Weapon wep = Weapon_from_name(item);
	if(wep == WEP_Null || (wep.spawnflags & WEP_FLAG_NOSTEAL) || !(shop_weapons & wep.m_wepset) || (wep.spawnflags & WEP_FLAG_CHAMPION))
	{
		sprint(this, "Invalid weapon\n");
		return;
	}

	if((STAT(WEAPONS, this) & wep.m_wepset) && (autocvar_g_weaponswitch_debug != 2 || (STAT(DUAL_WEAPONS, this) & wep.m_wepset) || (wep.spawnflags & WEP_FLAG_NODUAL)))
	{
		sprint(this, "You already have that weapon\n");
		return;
	}

	if(this.frags < SHOP_COST_WEAPON)
	{
		sprint(this, "You do not have enough points to buy this item, keep fragging!\n");
		return;
	}

	switch(wep.ammo_type)
	{
		case IT_SHELLS: this.ammo_shells += wep.aflag; break;
		case IT_NAILS: this.ammo_nails += wep.aflag; break;
		case IT_ROCKETS: this.ammo_rockets += wep.aflag; break;
		case IT_CELLS: this.ammo_cells += wep.aflag; break;
		case IT_LAVA_NAILS: this.ammo_lava_nails += wep.aflag; break;
		case IT_MULTI_ROCKETS: this.ammo_multi_rockets += wep.aflag; break;
		case IT_PLASMA_AMMO: this.ammo_plasma += wep.aflag; break;
	}

	Send_Notification(NOTIF_ONE, this, MSG_MULTI, ITEM_WEAPON_GOT, wep.m_name);
	_sound(this, CH_TRIGGER_SINGLE, "weapons/pkup.wav", 1, ATTN_NORM);

	bound_other_ammo(this);

	this.frags -= SHOP_COST_WEAPON;
	if(STAT(WEAPONS, this) & wep.m_wepset)
		STAT(DUAL_WEAPONS, this) |= wep.m_wepset;
	else
		STAT(WEAPONS, this) |= wep.m_wepset;

	if(!this.cvar_cl_autoswitch)
	{
		for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
		{
			.entity weaponentity = weaponentities[slot];
			if(wep == w_getbestweapon(this, weaponentity))
				W_SwitchWeapon(this, wep, weaponentity);
			if(autocvar_g_weaponswitch_debug != 1)
				break;
		}
	}
}

bool shopkeep_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_SHOPKEEP);

	WriteVector(MSG_ENTITY, this.origin);
	return true;
}

void shopkeep_spawn(entity this)
{
	precache_sound("items/r_item2.wav");
	precache_sound("items/armor1.wav");
	precache_sound("weapons/pkup.wav");
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	this.solid = SOLID_NOT;
	DropToFloor_QC_DelayedInit(this);
	set_movetype(this, MOVETYPE_NONE);
	Net_LinkEntity(this, false, 0, shopkeep_send);
}

void shop_setup_weapons()
{
	// pick a random selection of weapons for the shop
	shop_weapons = '0 0 0'; // reset initially
	for(int j = 0; j < SHOP_WEAPON_COUNT; ++j)
	{
		RandomSelection_Init();
		FOREACH(Weapons, it != WEP_Null,
		{
			if(shop_weapons & it.m_wepset)
				continue;
			if((it.spawnflags & WEP_FLAG_NOSTEAL) || (it.spawnflags & WEP_FLAG_CHAMPION))
				continue; // exclude some weapons!
			RandomSelection_AddEnt(it, 1, 1);
		});
		shop_weapons |= RandomSelection_chosen_ent.m_wepset;
	}
}

void shop_setup_passive()
{
	shop_passive = 0; // reset initially
	if(random() > 0.5)
		shop_passive = IT_PULSERIFLE;
	else
		shop_passive = IT_FIREBALL;
}

// This must be called in SV_ParseClientCommand
// input entity this
// input string cmd: same as in SV_ParseClientCommand
// output bool: true if command was handled, false if not
bool sv_shop_command(entity this, string cmd, float argc)
{
	switch(cmd)
	{
		case "shop":
		{
			if(argc == 2)
				shop_buyitem(this, strtolower(argv(1)));
			else
				sprint(this, "Usage: shop itemname\nitemname may be heal to buy health, armor or ammo to buy ammunition or a weapon name (for example, nailgun)\n");
			return true;
		}
	}
	return false;
}
