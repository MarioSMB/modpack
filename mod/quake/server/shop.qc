#include "shop.qh"

#include "../common/shop.qh"

void shop_buyitem(entity this, string item)
{
	if(!IS_PLAYER(this) || this.health <= 0)
		return;
	if(shop_open < time)
	{
		sprint(this, "You can only buy items after a boss wave\n");
		return;
	}

	if(item == "heal")
	{
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
		if(MP_ROGUE)
		{
			this.ammo_lava_nails += 60; SendItemPickup(this, IT_LAVA_NAILS, 60);
			this.ammo_multi_rockets += 20; SendItemPickup(this, IT_MULTI_ROCKETS, 20);
			this.ammo_plasma += 40; SendItemPickup(this, IT_PLASMA_AMMO, 40);
		}
		bound_other_ammo(this);
		sprint(this, "Ammunition restocked\n");
		_sound(this, CH_TRIGGER_SINGLE, "weapons/lock4.wav", 1, ATTN_NORM);
		return;
	}

	Weapon wep = Weapon_from_name(item);
	if(STAT(WEAPONS, this) & wep.m_wepset)
	{
		sprint(this, "You already have that weapon\n");
		return;
	}

	if(wep == WEP_Null || (wep.spawnflags & WEP_FLAG_NOSTEAL))
	{
		sprint(this, "Invalid weapon\n");
		return;
	}

	if((!MP_HIPNOTIC && (wep.spawnflags & WEP_FLAG_HIPNOTIC)) || (!MP_ROGUE && (wep.spawnflags & WEP_FLAG_ROGUE)) || (!MP_IMPEL && (wep.spawnflags & WEP_FLAG_IMPEL)))
	{
		sprint(this, "Weapons from that mission pack are unavailable\n");
		return;
	}

	float cost = (wep.m_cost) ? wep.m_cost : SHOP_COST_WEAPON;
	if(this.frags < cost)
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

	this.frags -= cost;
	STAT(WEAPONS, this) |= wep.m_wepset;

	if(wep == w_getbestweapon(this))
		W_SwitchWeapon(this, wep);
}

bool shopkeep_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_SHOPKEEP);

	WriteVector(MSG_ENTITY, this.origin);
	return true;
}

void shopkeep_spawn(entity this)
{
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	this.solid = SOLID_NOT;
	droptofloor(this);
	set_movetype(this, MOVETYPE_NONE);
	Net_LinkEntity(this, false, 0, shopkeep_send);
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
