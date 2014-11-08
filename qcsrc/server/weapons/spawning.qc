string W_Apply_Weaponreplace(string in)
{
	float n = tokenize_console(in);
	string out = "", s, replacement;
	float i, j;
	entity e;
	for(i = 0; i < n; ++i)
	{
		replacement = "";
		s = argv(i);
		
		for(j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			if(e.netname == s)
			{
				replacement = e.weaponreplace;
			}
		}

		if(replacement == "")
			out = strcat(out, " ", s);
		else if(replacement != "0")
			out = strcat(out, " ", replacement);
	}
	return substring(out, 1, -1);
}

void weapon_defaultspawnfunc(float wpn)
{
	entity e;
	float t;
	string s;
	entity oldself;
	float i, j;
	float f;

	if(self.classname != "droppedweapon" && self.classname != "replacedweapon")
	{
		e = get_weaponinfo(wpn);

		if(e.spawnflags & WEP_FLAG_MUTATORBLOCKED)
		{
			objerror("Attempted to spawn a mutator-blocked weapon rejected");
			startitem_failed = TRUE;
			return;
		}

		s = W_Apply_Weaponreplace(e.netname);
		ret_string = s;
		other = e;
		MUTATOR_CALLHOOK(SetWeaponreplace);
		s = ret_string;
		if(s == "")
		{
			remove(self);
			startitem_failed = TRUE;
			return;
		}
		t = tokenize_console(s);
		if(t >= 2)
		{
			self.team = --internalteam;
			oldself = self;
			for(i = 1; i < t; ++i)
			{
				s = argv(i);
				for(j = WEP_FIRST; j <= WEP_LAST; ++j)
				{
					e = get_weaponinfo(j);
					if(e.netname == s)
					{
						self = spawn();
						copyentity(oldself, self);
						self.classname = "replacedweapon";
						weapon_defaultspawnfunc(j);
						break;
					}
				}
				if(j > WEP_LAST)
				{
					print("The weapon replace list for ", oldself.classname, " contains an unknown weapon ", s, ". Skipped.\n");
				}
			}
			self = oldself;
		}
		if(t >= 1) // always the case!
		{
			s = argv(0);
			wpn = 0;
			for(j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if(e.netname == s)
				{
					wpn = j;
					break;
				}
			}
			if(j > WEP_LAST)
			{
				print("The weapon replace list for ", self.classname, " contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
		if(wpn == 0)
		{
			remove(self);
			startitem_failed = TRUE;
			return;
		}
	}

	e = get_weaponinfo(wpn);

	if(!self.respawntime)
	{
		if(e.weapons & WEPSET_SUPERWEAPONS)
		{
			self.respawntime = g_pickup_respawntime_superweapon;
			self.respawntimejitter = g_pickup_respawntimejitter_superweapon;
		}
		else
		{
			self.respawntime = g_pickup_respawntime_weapon;
			self.respawntimejitter = g_pickup_respawntimejitter_weapon;
		}
	}

	if(e.weapons & WEPSET_SUPERWEAPONS)
		if(!self.superweapons_finished)
			self.superweapons_finished = autocvar_g_balance_superweapons_time;

	// if we don't already have ammo, give us some ammo
	if(!self.(e.ammo_field))
	{
		switch(e.ammo_field)
		{
			case ammo_shells:  self.ammo_shells  = cvar("g_pickup_shells_weapon");  break;
			case ammo_nails:   self.ammo_nails   = cvar("g_pickup_nails_weapon");   break;
			case ammo_rockets: self.ammo_rockets = cvar("g_pickup_rockets_weapon"); break;
			case ammo_cells:   self.ammo_cells   = cvar("g_pickup_cells_weapon");   break;
			case ammo_plasma:  self.ammo_plasma  = cvar("g_pickup_plasma_weapon");  break;
			case ammo_fuel:    self.ammo_fuel    = cvar("g_pickup_fuel_weapon");    break;
		}
	}

	#if 0 // WEAPONTODO
	if(e.items)
	{
		for(i = 0, j = 1; i < 24; ++i, j *= 2)
		{
			if(e.items & j)
			{
				ammotype = Item_CounterField(j);
				if(!self.ammotype)
					self.ammotype = cvar(strcat("g_pickup_", Item_CounterFieldName(j), "_weapon"));
			}
		}
	}
	#endif

	// pickup anyway
	if(g_pickup_weapons_anyway)
		self.pickup_anyway = TRUE;

	f = FL_WEAPON;

	// no weapon-stay on superweapons
	if(e.weapons & WEPSET_SUPERWEAPONS)
		f |= FL_NO_WEAPON_STAY;

	// weapon stay isn't supported for teamed weapons
	if(self.team)
		f |= FL_NO_WEAPON_STAY;

	StartItem(e.model, "weapons/weaponpickup.wav", self.respawntime, self.respawntimejitter, e.message, 0, e.weapon, f, weapon_pickupevalfunc, e.bot_pickupbasevalue);
	#if 0 // WEAPONTODO
	if (self.modelindex) // don't precache if self was removed
		WEP_ACTION(e.weapon, WR_INIT);
	#endif
}
