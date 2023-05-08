#include "selection.qh"

#include "weaponsystem.qh"

bool client_hasweapon(entity this, Weapon wpn, float andammo, bool complain)
{
	float f = 0;

	if (time < this.hasweapon_complain_spam)
		complain = 0;

	if (complain)
		this.hasweapon_complain_spam = time + 0.2;

	if (wpn == WEP_Null)
	{
		if (complain)
			sprint(this, "Invalid weapon\n");
		return false;
	}
	if (STAT(WEAPONS, this) & WepSet_FromWeapon(wpn))
	{
		if (andammo)
		{
			f = wpn.wr_checkammo1(wpn, this);
			if (!f)
			{
				return false;
			}
		}
		return true;
	}
	return false;
}

float W_GetCycleWeapon(entity this, string weaponorder, float dir, float imp, float complain, float skipmissing)
{
	// We cannot tokenize in this function, as GiveItems calls this
	// function. Thus we must use car/cdr.
	float weaponwant, first_valid, prev_valid, switchtonext, switchtolast;
	WepSet wepset = '0 0 0';
	switchtonext = switchtolast = 0;
	first_valid = prev_valid = 0;
	float weaponcur;
	entity wep;

	weaponcur = this.weaponentity.m_weapon.m_id;

	if(dir == 0)
		switchtonext = 1;

	int c = 0;

	string rest = weaponorder;
	while(rest != "")
	{
		weaponwant = stof(car(rest)); rest = cdr(rest);
		wep = REGISTRY_GET(Weapons, weaponwant);
		wepset = wep.m_wepset;
		if(imp >= 0)
		if(wep.impulse != imp)
			continue;

		bool have_other = false;
		FOREACH(Weapons, it != WEP_Null, {
			if(i != weaponwant)
			if(it.impulse == imp || imp < 0)
			if(STAT(WEAPONS, this) & (it.m_wepset))
				have_other = true;
		});

		// skip weapons we don't own that aren't normal and aren't in the map
		if(!(STAT(WEAPONS, this) & wepset))
		if(have_other)
			continue;

		++c;

		if(!skipmissing || client_hasweapon(this, wep, true, false))
		{
			if(switchtonext)
				return weaponwant;
			if(!first_valid)
				first_valid = weaponwant;
			if(weaponwant == weaponcur)
			{
				if(dir >= 0)
					switchtonext = 1;
				else if(prev_valid)
					return prev_valid;
				else
					switchtolast = 1;
			}
			prev_valid = weaponwant;
		}
	}
	if(first_valid)
	{
		if(switchtolast)
			return prev_valid;
		else
			return first_valid;
	}
	return 0;
}

void W_SwitchWeapon_Force(entity this, Weapon wep)
{
	TC(Weapon, wep);
	entity w_ent = this.weaponentity;
	w_ent.cnt = w_ent.m_weapon.m_id;
	w_ent.m_weapon = wep;
	W_SetCurrentAmmo(this);
}

// perform weapon to attack (weaponstate and attack_finished check is here)
void W_SwitchToOtherWeapon(entity this)
{
	// hack to ensure it switches to an OTHER weapon (in case the other fire mode still has ammo, we want that anyway)
	Weapon ww;
	WepSet set = WepSet_FromWeapon(this.weaponentity.m_weapon);
	if (STAT(WEAPONS, this) & set)
	{
		STAT(WEAPONS, this) &= ~set;
		ww = w_getbestweapon(this);
		STAT(WEAPONS, this) |= set;
	}
	else
	{
		ww = w_getbestweapon(this);
	}
	if (ww == WEP_Null) return;
	W_SwitchWeapon_Force(this, ww);
}

bool W_SwitchWeapon(entity this, Weapon w)
{
	if(this.weaponentity.m_weapon != w)
	{
		if(client_hasweapon(this, w, true, true))
		{
			W_SwitchWeapon_Force(this, w);
			return true;
		}
		else
		{
			return false;
		}
	}

	return true;
}

void W_SwitchWeapon_TryOthers(entity this, Weapon w)
{
	if(!W_SwitchWeapon(this, w) && this.cvar_cl_weapon_switch_fallback_to_impulse)
		W_NextWeaponOnImpulse(this, w.impulse);
}

void W_CycleWeapon(entity this, string weaponorder, float dir)
{
	float w;
	w = W_GetCycleWeapon(this, weaponorder, dir, -1, 1, true);
	if(w > 0)
		W_SwitchWeapon(this, REGISTRY_GET(Weapons, w));
}

void W_NextWeaponOnImpulse(entity this, float imp)
{
	float w;
	w = W_GetCycleWeapon(this, this.cvar_cl_weaponpriority, +1, imp, 1, (this.cvar_cl_weaponimpulsemode == 0));
	if(w > 0)
		W_SwitchWeapon(this, REGISTRY_GET(Weapons, w));
}

// next weapon
void W_NextWeapon(entity this, int list)
{
	if(list == 0)
		W_CycleWeapon(this, weaponorder_byid, -1);
	else if(list == 1)
		W_CycleWeapon(this, this.weaponorder_byimpulse, -1);
	else if(list == 2)
		W_CycleWeapon(this, this.cvar_cl_weaponpriority, -1);
}

// prev weapon
void W_PreviousWeapon(entity this, float list)
{
	if(list == 0)
		W_CycleWeapon(this, weaponorder_byid, +1);
	else if(list == 1)
		W_CycleWeapon(this, this.weaponorder_byimpulse, +1);
	else if(list == 2)
		W_CycleWeapon(this, this.cvar_cl_weaponpriority, +1);
}

// previously used if exists and has ammo, (second) best otherwise
void W_LastWeapon(entity this)
{
	Weapon wep = REGISTRY_GET(Weapons, this.weaponentity.cnt);
	if (client_hasweapon(this, wep, true, false))
		W_SwitchWeapon(this, wep);
	else
		W_SwitchToOtherWeapon(this);
}

// fix switchweapon (needed when spectating is disabled, as PutClientInServer comes too early)
// not needed with quake
#if 0
REPLICATE_APPLYCHANGE("cl_quake_weaponpriority",
	if(this.weaponentity && this.weaponentity.m_weapon != WEP_Null)
		this.weaponentity.m_weapon = w_getbestweapon(this);
);
#endif
