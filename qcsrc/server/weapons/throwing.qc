void thrown_wep_think()
{
	self.nextthink = time;
	if(self.oldorigin != self.origin)
	{
		self.SendFlags |= ISF_LOCATION;
		self.oldorigin = self.origin;
	}
	self.owner = world;
	float timeleft = self.savenextthink - time;
	if(timeleft > 1)
		SUB_SetFade(self, self.savenextthink - 1, 1);
	else if(timeleft > 0)
		SUB_SetFade(self, time, timeleft);
	else
		SUB_VanishOrRemove(self);
}

// returns amount of ammo used as string, or -1 for failure, or 0 for no ammo count
string W_ThrowNewWeapon(entity own, float wpn, float doreduce, vector org, vector velo)
{
	entity oldself, wep;
	float thisammo, i;
	string s;
	var .float ammotype = (get_weaponinfo(wpn)).ammo_field;

	wep = spawn();

	setorigin(wep, org);
	wep.classname = "droppedweapon";
	wep.velocity = velo;
	wep.owner = wep.enemy = own;
	wep.flags |= FL_TOSSED;
	wep.colormap = own.colormap;
	
	W_DropEvent(WR_DROP,own,wpn,wep);

	if(WepSet_FromWeapon(wpn) & WEPSET_SUPERWEAPONS)
	{
		if(own.items & IT_UNLIMITED_SUPERWEAPONS)
		{
			wep.superweapons_finished = time + autocvar_g_balance_superweapons_time;
		}
		else
		{
			float superweapons = 1;
			for(i = WEP_FIRST; i <= WEP_LAST; ++i)
				if(WepSet_FromWeapon(i) & WEPSET_SUPERWEAPONS)
					if(own.weapons & WepSet_FromWeapon(i))
						++superweapons;
			if(superweapons <= 1)
			{
				wep.superweapons_finished = own.superweapons_finished;
				own.superweapons_finished = 0;
			}
			else
			{
				float timeleft = own.superweapons_finished - time;
				float weptimeleft = timeleft / superweapons;
				wep.superweapons_finished = time + weptimeleft;
				own.superweapons_finished -= weptimeleft;
			}
		}
	}

	oldself = self;
	self = wep;
	weapon_defaultspawnfunc(wpn);
	self = oldself;
	if(startitem_failed)
		return string_null;
	wep.glowmod = own.weaponentity_glowmod;
	wep.think = thrown_wep_think;
	wep.savenextthink = wep.nextthink;
	wep.nextthink = min(wep.nextthink, time + 0.5);
	wep.pickup_anyway = TRUE; // these are ALWAYS pickable
	
	//wa = W_AmmoItemCode(wpn);
	if(ammotype == ammo_none)
	{
		return "";
	}
	else
	{
		s = "";

		if(doreduce && g_weapon_stay == 2)
		{
			// if our weapon is loaded, give its load back to the player
			if(self.(weapon_load[self.weapon]) > 0)
			{
				own.ammotype += self.(weapon_load[self.weapon]);
				self.(weapon_load[self.weapon]) = -1; // schedule the weapon for reloading
			}

			wep.ammotype = 0;
		}
		else if(doreduce)
		{
			// if our weapon is loaded, give its load back to the player
			if(self.(weapon_load[self.weapon]) > 0)
			{
				own.ammotype += self.(weapon_load[self.weapon]);
				self.(weapon_load[self.weapon]) = -1; // schedule the weapon for reloading
			}

			thisammo = min(own.ammotype, wep.ammotype);
			wep.ammotype = thisammo;
			own.ammotype -= thisammo;

			switch(ammotype)
			{
				case ammo_shells:  s = sprintf("%s and %d shells", s, thisammo);  break;
				case ammo_nails:   s = sprintf("%s and %d nails", s, thisammo);   break;
				case ammo_rockets: s = sprintf("%s and %d rockets", s, thisammo); break;
				case ammo_cells:   s = sprintf("%s and %d cells", s, thisammo);   break;
				case ammo_plasma:  s = sprintf("%s and %d plasma", s, thisammo);  break;
				case ammo_fuel:    s = sprintf("%s and %d fuel", s, thisammo);    break;
			}

			s = substring(s, 5, -1);
		}
		return s;
	}
}

float W_IsWeaponThrowable(float w)
{
	if (!autocvar_g_pickup_items)
		return 0;
	if (g_weaponarena)
		return 0;
	if (g_cts)
		return 0;
	if (g_nexball && w == WEP_MORTAR)
		return 0;
    if(w == 0)
        return 0;

	#if 0
	if(start_weapons & WepSet_FromWeapon(w))
	{
		// start weapons that take no ammo can't be dropped (this prevents dropping the laser, as long as it continues to use no ammo)
		if(start_items & IT_UNLIMITED_WEAPON_AMMO)
			return 0;
		if((get_weaponinfo(w)).ammo_field == ammo_none)
			return 0;
	}
	return 1;
	#else
	return (get_weaponinfo(w)).weaponthrowable;
	#endif
}

// toss current weapon
void W_ThrowWeapon(vector velo, vector delta, float doreduce)
{
	float w;
	string a;

	w = self.weapon;
	if (w == 0)
		return; // just in case
	if(MUTATOR_CALLHOOK(ForbidThrowCurrentWeapon))
		return;
	if(!autocvar_g_weapon_throwable)
		return;
	if(self.weaponentity.state != WS_READY)
		return;
	if(!W_IsWeaponThrowable(w))
		return;

	if(!(self.weapons & WepSet_FromWeapon(w)))
		return;
	self.weapons &= ~WepSet_FromWeapon(w);

	W_SwitchWeapon_Force(self, w_getbestweapon(self));
	a = W_ThrowNewWeapon(self, w, doreduce, self.origin + delta, velo);
	
	if(!a) return;
	Send_Notification(NOTIF_ONE, self, MSG_MULTI, ITEM_WEAPON_DROP, a, w);
}

void SpawnThrownWeapon(vector org, float w)
{
	if(self.weapons & WepSet_FromWeapon(self.weapon))
		if(W_IsWeaponThrowable(self.weapon))
			W_ThrowNewWeapon(self, self.weapon, FALSE, org, randomvec() * 125 + '0 0 200');
}
