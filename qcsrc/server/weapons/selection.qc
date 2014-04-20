// switch between weapons
void Send_WeaponComplain(entity e, float wpn, float type)
{
	msg_entity = e;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_WEAPONCOMPLAIN);
	WriteByte(MSG_ONE, wpn);
	WriteByte(MSG_ONE, type);
}

float client_hasweapon(entity cl, float wpn, float andammo, float complain)
{
	float f;
	entity oldself;

	if(time < self.hasweapon_complain_spam)
		complain = 0;

	if(wpn == WEP_HOOK && !g_grappling_hook && autocvar_g_nades && !((cl.weapons | weaponsInMap) & WepSet_FromWeapon(wpn)))
		complain = 0;
		
	if(complain)
		self.hasweapon_complain_spam = time + 0.2;

	if (wpn < WEP_FIRST || wpn > WEP_LAST)
	{
		if (complain)
			sprint(self, "Invalid weapon\n");
		return FALSE;
	}
	if (cl.weapons & WepSet_FromWeapon(wpn))
	{
		if (andammo)
		{
			if(cl.items & IT_UNLIMITED_WEAPON_AMMO)
			{
				f = 1;
			}
			else
			{
				oldself = self;
				self = cl;
				f = WEP_ACTION(wpn, WR_CHECKAMMO1);
				f = f + WEP_ACTION(wpn, WR_CHECKAMMO2);

				// always allow selecting the Mine Layer if we placed mines, so that we can detonate them
				entity mine;
				if(wpn == WEP_MINE_LAYER)
				for(mine = world; (mine = find(mine, classname, "mine")); ) if(mine.owner == self)
					f = 1;

				self = oldself;
			}
			if (!f)
			{
				if (complain)
				if(IS_REAL_CLIENT(cl))
				{
					play2(cl, "weapons/unavailable.wav");
					Send_WeaponComplain (cl, wpn, 0);
				}
				return FALSE;
			}
		}
		return TRUE;
	}
	if (complain)
	{
		// DRESK - 3/16/07
		// Report Proper Weapon Status / Modified Weapon Ownership Message
		if (weaponsInMap & WepSet_FromWeapon(wpn))
		{
			Send_WeaponComplain(cl, wpn, 1);

			if(autocvar_g_showweaponspawns)
			{
				entity e;

				for(e = world; (e = findfloat(e, weapon, wpn)); )
				{
					if(e.classname == "droppedweapon")
						continue;
					if(!(e.flags & FL_ITEM))
						continue;
					WaypointSprite_Spawn(
						(get_weaponinfo(wpn)).wpmodel,
						1, 0,
						world, e.origin,
						self, 0,
						world, enemy,
						0,
						RADARICON_NONE, '0 0 0'
					);
				}
			}
		}
		else
		{
			Send_WeaponComplain (cl, wpn, 2);
		}

		play2(cl, "weapons/unavailable.wav");
	}
	return FALSE;
}

float W_GetCycleWeapon(entity pl, string weaponorder, float dir, float imp, float complain, float skipmissing)
{
	// We cannot tokenize in this function, as GiveItems calls this
	// function. Thus we must use car/cdr.
	float weaponwant, first_valid, prev_valid, switchtonext, switchtolast, c;
	string rest;
	switchtonext = switchtolast = 0;
	first_valid = prev_valid = 0;
	float weaponcur;
	entity wep;

	if(skipmissing || pl.selectweapon == 0)
		weaponcur = pl.switchweapon;
	else
		weaponcur = pl.selectweapon;

	if(dir == 0)
		switchtonext = 1;

	c = 0;

	rest = weaponorder;
	while(rest != "")
	{
		weaponwant = stof(car(rest)); rest = cdr(rest);
		wep = get_weaponinfo(weaponwant);
		if(imp >= 0)
			if(wep.impulse != imp)
				continue;

		// skip weapons we don't own that aren't normal and aren't in the map
		if(!(pl.weapons & WepSet_FromWeapon(weaponwant)))
			if(!((get_weaponinfo(weaponwant)).spawnflags & WEP_FLAG_NORMAL))
				if(!(weaponsInMap & WepSet_FromWeapon(weaponwant)))
					continue;

		++c;

		if(!skipmissing || client_hasweapon(pl, weaponwant, TRUE, FALSE))
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
	// complain (but only for one weapon on the button that has been pressed)
	if(complain)
	{
		self.weaponcomplainindex += 1;
		c = mod(self.weaponcomplainindex, c) + 1;
		rest = weaponorder;
		while(rest != "")
		{
			weaponwant = stof(car(rest)); rest = cdr(rest);
			wep = get_weaponinfo(weaponwant);
			if(imp >= 0)
				if(wep.impulse != imp)
					continue;

			// skip weapons we don't own that aren't normal and aren't in the map
			if(!(pl.weapons & WepSet_FromWeapon(weaponwant)))
				if(!((get_weaponinfo(weaponwant)).spawnflags & WEP_FLAG_NORMAL))
					if(!(weaponsInMap & WepSet_FromWeapon(weaponwant)))
						continue;

			--c;
			if(c == 0)
			{
				client_hasweapon(pl, weaponwant, TRUE, TRUE);
				break;
			}
		}
	}
	return 0;
}

void W_SwitchWeapon_Force(entity e, float w)
{
	e.cnt = e.switchweapon;
	e.switchweapon = w;
	e.selectweapon = w;
}

// perform weapon to attack (weaponstate and attack_finished check is here)
void W_SwitchToOtherWeapon(entity pl)
{
	// hack to ensure it switches to an OTHER weapon (in case the other fire mode still has ammo, we want that anyway)
	float w, ww;
	w = pl.weapon;
	if(pl.weapons & WepSet_FromWeapon(w))
	{
		pl.weapons &= ~WepSet_FromWeapon(w);
		ww = w_getbestweapon(pl);
		pl.weapons |= WepSet_FromWeapon(w);
	}
	else
		ww = w_getbestweapon(pl);
	if(ww)
		W_SwitchWeapon_Force(pl, ww);
}

void W_SwitchWeapon(float imp)
{
	if (self.switchweapon != imp)
	{
		if (client_hasweapon(self, imp, TRUE, TRUE))
			W_SwitchWeapon_Force(self, imp);
		else
			self.selectweapon = imp; // update selectweapon ANYWAY
	}
	else { WEP_ACTION(self.weapon, WR_RELOAD); }
}

void W_CycleWeapon(string weaponorder, float dir)
{
	float w;
	w = W_GetCycleWeapon(self, weaponorder, dir, -1, 1, TRUE);
	if(w > 0)
		W_SwitchWeapon(w);
}

void W_NextWeaponOnImpulse(float imp)
{
	float w;
	w = W_GetCycleWeapon(self, self.cvar_cl_weaponpriority, +1, imp, 1, (self.cvar_cl_weaponimpulsemode == 0));
	if(w > 0)
		W_SwitchWeapon(w);
}

// next weapon
void W_NextWeapon(float list)
{
	if(list == 0)
		W_CycleWeapon(weaponorder_byid, -1);
	else if(list == 1)
		W_CycleWeapon(self.weaponorder_byimpulse, -1);
	else if(list == 2)
		W_CycleWeapon(self.cvar_cl_weaponpriority, -1);
}

// prev weapon
void W_PreviousWeapon(float list)
{
	if(list == 0)
		W_CycleWeapon(weaponorder_byid, +1);
	else if(list == 1)
		W_CycleWeapon(self.weaponorder_byimpulse, +1);
	else if(list == 2)
		W_CycleWeapon(self.cvar_cl_weaponpriority, +1);
}

// previously used if exists and has ammo, (second) best otherwise
void W_LastWeapon(void)
{
	if(client_hasweapon(self, self.cnt, TRUE, FALSE))
		W_SwitchWeapon(self.cnt);
	else
		W_SwitchToOtherWeapon(self);
}
